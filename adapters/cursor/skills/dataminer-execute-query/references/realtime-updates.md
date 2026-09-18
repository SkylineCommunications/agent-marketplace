# DataMiner Real-Time Query Updates

Subscribe to a **live** GQI query so the DataMiner server pushes row updates over a kept-open WebSocket as the underlying data changes — no repeated fetches needed.

This is the real-time counterpart to the one-shot fetch (`OpenQuerySessionAsync`). Use this when the UI must stay continuously in sync with the system (control surfaces, dashboards, status views, anything driven by an ad hoc/custom GQI data source that emits updates).

---

## The one rule that makes or breaks real-time

Real-time push requires **all three** of these. Get any one wrong and you receive zero update frames (often with no error, or an HTTP 500):

1. **Endpoint must be `ObserveQuerySessionAsync`** — NOT `OpenQuerySessionAsync`. `OpenQuerySessionAsync` is one-shot and never emits update frames, even with `EnableUpdates: true`.
2. **`options.EnableUpdates` must be `true`**.
3. **The POST body must include the `connection` field.** Omitting `connection` returns HTTP 500 and the session is never created, so no events ever arrive. (This field is easy to forget because the GQI query envelope itself does not contain it.)

---

## Overview

Real-time query subscription happens over a single, persistent WebSocket:

1. Bind the socket to the HTTP session (`SetConnectionID`).
2. Subscribe to the event queue (`GetEvents`).
3. Open a live session — HTTP POST to `ObserveQuerySessionAsync` (`EnableUpdates: true`, `connection` included). Returns a session ID and column metadata.
4. Page in the initial rows (`GetNextQuerySessionPage` until `IsLast: true`).
5. Keep the socket open. The server pushes `DMAEvent` frames for every change.

For base WebSocket setup (URL, `SetConnectionID`, `ClientSubscriptionID` semantics) and the GQI query envelope, see the **dataminer-api** skill and the `websocket-protocol.md` reference in this skill.

---

## ObserveQuerySessionAsync HTTP call

```
POST ../../API/v1/Internal.asmx/ObserveQuerySessionAsync
```

```json
{
  "connection": "<connection-string>",
  "queueID": <number>,
  "clientSubscriptionID": <SUBSCRIPTION_ID>,
  "query": { "<same query object as OpenQuerySessionAsync>" },
  "options": {
    "OptimizationType": 0,
    "TimeZoneID": "Europe/Brussels",
    "LanguageTag": "en-US",
    "FetchLocal": true,
    "UseDynamicUnits": true,
    "EnableUpdates": true,
    "QueryTag": ""
  }
}
```

| Field | Notes |
|-------|-------|
| `connection` | **REQUIRED** (missing → HTTP 500, no events). Same connection GUID used for `SetConnectionID`. |
| `clientSubscriptionID` | The inner subscription ID (`SUBSCRIPTION_ID`). See "The subscription-id channel" below. |
| `options.EnableUpdates` | Must be `true`. |
| `query` | Identical structure to the one-shot query (descriptor + arguments envelope). |

**Response:** `{ "d": { "ID": "<session-guid>", "Columns": [ ... ] } }`

---

## The subscription-id channel (critical)

There are two different subscription IDs in play, and conflating them is why a naive port of the one-shot code receives no pushes:

| Field | Where | Value | Meaning |
|-------|-------|-------|---------|
| Outer `ClientSubscriptionID` | top-level of each WS frame (`GetEvents`, `NotifySubscription`) | constant `2` | WebSocket command channel. Stays `2` for the whole session. |
| Inner `clientSubscriptionID` | inside `ObserveQuerySessionAsync` body AND inside `NotifySubscription.Parameters` | constant `SUBSCRIPTION_ID` (e.g. `7`) | The session/result channel. The server stamps this value as `Data.ClientSubscriptionID` on every `DMAEvent` for this session — initial pages and live updates. |

**Rules:**

- Pick a fixed `SUBSCRIPTION_ID` and **do not increment it**. Reuse the exact same value in the `ObserveQuerySessionAsync` body and in the `NotifySubscription` page request.
- It must not collide with the IDs used for other commands on the socket. Reserved in the typical flow: `1` = `SetConnectionID`, `2` = `GetEvents`/`NotifySubscription` outer, `3` = `LaunchAutomationScript`. So a `SUBSCRIPTION_ID` of `7` (or any free number ≥ 4) is safe.
- Filter incoming frames on `msg.Data.ClientSubscriptionID === SUBSCRIPTION_ID` so a multi-session socket routes frames correctly.

---

## WebSocket execution sequence

| Step | Direction | Action |
|------|-----------|--------|
| 1 | client→server | `SetConnectionID` (`ClientSubscriptionID: 1`) — bind socket to HTTP session |
| 2 | server→client | `Type: "String"` ack — wait before proceeding |
| 3 | client→server | `GetEvents` (`ClientSubscriptionID: 2`, `queueID`) — subscribe to the queue first |
| 4 | client→HTTP | `ObserveQuerySessionAsync` (`connection`, `queueID`, `clientSubscriptionID: SUBSCRIPTION_ID`, `EnableUpdates: true`) — returns `d.ID` + `d.Columns` |
| 5 | client→server | `NotifySubscription` → `GetNextQuerySessionPage` (outer `2`, inner `SUBSCRIPTION_ID`) — page in initial rows |
| 6 | server→client | `DMAEvent` (`Data.ClientSubscriptionID === SUBSCRIPTION_ID`) — `DMAGenericInterfaceResultPage`; accumulate, check `IsLast` |
| 7 | (repeat 5–6) | if `IsLast: false`, request the next page |
| 8 | server→client | (socket stays open) push frames on every change (see below) |

> Send `GetEvents` only after the `String` ack, and call `ObserveQuerySessionAsync` after sending `GetEvents`. Keep the socket open indefinitely; reconnect transparently on close.

---

## Push frame types

All live frames arrive as `Type: "DMAEvent"` with `Data.ClientSubscriptionID === SUBSCRIPTION_ID`. Branch on `Data.Message.__type` (suffix match):

| `__type` suffix | Meaning | Shape |
|----------------|---------|-------|
| `DMAGenericInterfaceBulkUpdate` | multiple near-simultaneous events batched into one frame for performance | `Message.Events: [ ... ]` — each entry is one of the typed objects below; handle each in order |
| `DMAGenericInterfaceResultPage` | initial / paged full rows | `Message.Rows: [{ Cells:[{Value,DisplayValue}] }]`, `Message.IsLast` |
| `DMAGenericInterfaceUpdatedRowsUpdate` | cell-level deltas to existing rows | `Message.Rows: [{ Key, Cells:[{ ColumnIndex, Cell:{Value,DisplayValue} }] }]` |
| `DMAGenericInterfaceAddedRowsUpdate` | whole rows added | `Message.Rows: [{ Key, Cells:[...] }]` |
| `DMAGenericInterfaceDeletedRowsUpdate` | rows removed | `Message.RemovedKeys: [...]` |
| `DMAGenericInterfaceSessionFetchUpdate` | a notification event — the query can detect that something changed but cannot say what. Can serve as a trigger to fetch the result of the query again ("smart polling") | no row payload — a signal only |

**Key handling:**

- Maintain an ordered key list + a `Map` keyed by the ID column so cell-level updates apply in place and order is stable.
- For full rows, the key is `row.Key` (preferred) or the ID column cell value.
- For `UpdatedRowsUpdate`, each updated cell carries a `ColumnIndex` — map it to the column name via the `Columns` array from the session response.
- Re-emit the mapped row set to the UI on every change.

---

## Production code example

```javascript
const INTERNAL_API = `${location.protocol}//${location.host}/API/v1/Internal.asmx`;
const WS_URL = `${location.protocol === 'https:' ? 'wss:' : 'ws:'}//${location.host}/API/v1/WebSocket.ashx`;

async function internalPost(method, body) {
  const r = await fetch(`${INTERNAL_API}/${method}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
    credentials: 'include',
  });
  const json = await r.json();
  if (!r.ok) throw new Error(json?.Message || r.statusText);
  return json.d;
}

const SUBSCRIPTION_ID = 7;      // fixed inner channel; avoid 1/2/3
const PAGE_SIZE = 500;
const RECONNECT_DELAY_MS = 4000;

const QUERY_OPTIONS = {
  OptimizationType: 0,  // 0 = first page fast, 1 = all pages fast
  TimeZoneID: Intl.DateTimeFormat().resolvedOptions().timeZone,
  LanguageTag: navigator.language || 'en-US',
  FetchLocal: true,
  UseDynamicUnits: true,
  EnableUpdates: true,          // REQUIRED for push
  QueryTag: '',
};

// `query` = your GQI query object. `mapRow(cellObj)` -> UI model.
// handlers = { onData(rows), onError(err) }. Returns an unsubscribe function.
function observeQuery(connection, query, mapRow, { onData, onError } = {}) {
  let stopped = false, ws = null, reconnectTimer = null, errorReported = false;
  const order = [];
  const byKey = new Map();
  let columns = [], idIndex = 0;

  const reportError = (e) => { if (!errorReported && onError) { errorReported = true; onError(e); } };
  const rowKey = (cells) => cells?.[idIndex]?.Value ?? cells?.[idIndex]?.DisplayValue ?? '';
  const cellsToObj = (cells) => {
    const o = {};
    columns.forEach((c, i) => { o[c.Name] = cells?.[i]?.DisplayValue ?? cells?.[i]?.Value ?? ''; });
    return o;
  };
  const emit = () => { if (!stopped && onData) onData(order.map((k) => mapRow(byKey.get(k)))); };

  const upsertFull = (row) => {
    const key = row.Key ?? rowKey(row.Cells || []);
    if (!byKey.has(key)) order.push(key);
    byKey.set(key, cellsToObj(row.Cells || []));
  };
  const applyDelta = (row) => {
    const key = row.Key;
    let o = byKey.get(key);
    if (!o) { o = {}; order.push(key); byKey.set(key, o); }
    for (const uc of row.Cells || []) {
      const col = columns[uc.ColumnIndex];
      if (col) o[col.Name] = uc.Cell?.DisplayValue ?? uc.Cell?.Value ?? '';
    }
  };
  const removeRow = (key) => { if (byKey.delete(key)) { const i = order.indexOf(key); if (i >= 0) order.splice(i, 1); } };

  const scheduleReconnect = () => {
    if (stopped || reconnectTimer) return;
    try { ws && ws.close(); } catch {}
    reconnectTimer = setTimeout(() => { reconnectTimer = null; connect(); }, RECONNECT_DELAY_MS);
  };

  function connect() {
    if (stopped) return;
    order.length = 0; byKey.clear(); columns = []; idIndex = 0;
    ws = new WebSocket(WS_URL);
    const queueID = crypto.getRandomValues(new Uint32Array(1))[0];
    let sessionId = null, opened = false;

    const nextPage = () => ws.send(JSON.stringify({
      ClientSubscriptionID: 2, Method: 'NotifySubscription',
      Parameters: { clientSubscriptionID: SUBSCRIPTION_ID, method: 'GetNextQuerySessionPage', data: { sessionID: sessionId, pageSize: PAGE_SIZE } },
    }));

    ws.addEventListener('open', () => ws.send(JSON.stringify({
      ClientSubscriptionID: 1, Method: 'SetConnectionID', Parameters: { connectionID: connection },
    })));

    ws.addEventListener('message', async (e) => {
      let msg; try { msg = JSON.parse(e.data); } catch { return; }

      if (msg.Type === 'String' && !opened) {
        opened = true;
        try {
          ws.send(JSON.stringify({ ClientSubscriptionID: 2, Method: 'GetEvents', Parameters: { queueID } }));
          const info = await internalPost('ObserveQuerySessionAsync', {
            connection, queueID, clientSubscriptionID: SUBSCRIPTION_ID, query, options: QUERY_OPTIONS,
          });
          if (stopped) { try { ws.close(); } catch {} return; }
          sessionId = info.ID;
          columns = info.Columns || [];
          const f = columns.findIndex((c) => c.Name === 'ID');
          idIndex = f >= 0 ? f : 0;
          nextPage();
        } catch (err) { reportError(err); scheduleReconnect(); }
        return;
      }

      if (msg.Type !== 'DMAEvent' || !sessionId) return;
      if (msg.Data?.ClientSubscriptionID !== SUBSCRIPTION_ID) return;   // route to our session
      const m = msg.Data?.Message; if (!m) return;
      const t = m.__type || '';

      if (t.endsWith('BulkUpdate')) {                                 // full initial state in one frame
        for (const ev of m.Events || []) {
          const et = ev.__type || '';
          if (et.endsWith('AddedRowsUpdate')) for (const r of ev.Rows || []) upsertFull(r);
          else if (et.endsWith('DeletedRowsUpdate'))
            for (const k of ev.RemovedKeys || []) removeRow(k);
          else if (et.endsWith('UpdatedRowsUpdate')) for (const r of ev.Rows || []) applyDelta(r);
        }
        emit(); return;
      }
      if (t.endsWith('UpdatedRowsUpdate')) { for (const r of m.Rows || []) applyDelta(r); emit(); return; }
      if (t.endsWith('AddedRowsUpdate'))   { for (const r of m.Rows || []) upsertFull(r); emit(); return; }
      if (t.endsWith('DeletedRowsUpdate')) {
        for (const k of m.RemovedKeys || []) removeRow(k); emit(); return;
      }
      if (t.endsWith('SessionFetchUpdate')) {                          // notification event (GQI relays ~every 30s) — no row payload
        scheduleReconnect(); return;                                  // recreate the session to re-fetch current data
      }
      if (m.Rows !== undefined && m.IsLast !== undefined) {            // initial pages
        for (const r of m.Rows || []) upsertFull(r);
        if (m.IsLast) emit(); else nextPage();
      }
    });

    ws.addEventListener('error', () => reportError(new Error('WebSocket error during GQI subscription')));
    ws.addEventListener('close', () => { if (!stopped) scheduleReconnect(); });
  }

  connect();
  return function unsubscribe() {
    stopped = true;
    if (reconnectTimer) { clearTimeout(reconnectTimer); reconnectTimer = null; }
    try { ws && ws.close(); } catch {}
  };
}
```

---

## Reliability

- **Keep one socket per subscription.** Do not close it after the initial pages — the push frames arrive on that same open socket.
- **Reconnect transparently** on close/error (re-run the full handshake; rebuild the working set from scratch).
- **Do not re-fetch on a timer.** If you previously used repeated `OpenQuerySessionAsync` calls to keep data fresh, replace that pattern entirely; mixing the two wastes sessions and can mask the real-time path being misconfigured.
- After a user-triggered action (e.g. an Automation Script that changes data), you do **not** need to manually re-query — the subscription pushes the resulting row updates automatically. Optimistic UI state (pending flags) can bridge the brief gap until the push lands.

---

## Troubleshooting: "no updates arrive"

Work down this list — these are the exact failure modes observed:

1. **Using `OpenQuerySessionAsync`.** It never pushes. Switch to `ObserveQuerySessionAsync`.
2. **Missing `connection` in the POST body.** Returns HTTP 500; the session is never created. Add it.
3. **`EnableUpdates: false`.** No push channel. Set it to `true`.
4. **Incrementing the inner `clientSubscriptionID`.** The server pushes on the ID you registered with; keep it constant and reuse it for the page request.
5. **Filtering out the frames.** Updates are tagged with `Data.ClientSubscriptionID === SUBSCRIPTION_ID`, not the outer `2`. Filter on the session ID, not the command ID.
6. **Socket closed after initial load.** Push frames need the socket open; do not close it.
7. **Calling `ObserveInformationMessages`.** Not needed for GQI and it interferes with event delivery. Only `GetEvents` + `ObserveQuerySessionAsync` + `GetNextQuerySessionPage` are required.
8. **Data source genuinely emits no updates.** Support depends on the lowest-supported source/operator in the query: some stream real-time deltas, some only emit notification events (`SessionFetchUpdate`, ~every 30 s), some emit nothing. You cannot know this ahead of time, so ask the user what to expect and let their answer drive the implementation — subscribe when updates are delivered, fall back to periodic re-fetching when they aren't. See [Query update support](https://docs.dataminer.services/dataminer/Functions/Dashboards_and_Low_Code_Apps/GQI/Query_updates.html#query-update-support).
