---
name: dataminer-execute-query
description: Execute GQI queries in a DataMiner frontend application using OpenQuerySessionAsync over WebSocket. Use when building production apps that need to fetch GQI data (DOM instances, ad hoc data sources, custom queries) from DataMiner using a known query object, or when the user provides a query object directly.
license: LicenseRef-Skyline-Agent-Marketplace
user-invocable: true
metadata:
  updated: 2026-10-01
  version: 1.1
---

# DataMiner Execute Query Skill

GQI is for data that is **NOT** available through the standard DataMiner Web API endpoints. Use GQI for DOM instances, ad hoc data sources, and custom queries. Do **NOT** use GQI for elements, alarms, views, or services — those are available through the **dataminer-api** skill.

This skill covers executing a **known** GQI query in a production app. A query object can come from two sources:
- **Discovered** via natural language using the **dataminer-data-discovery** skill (NL2GQI)
- **Provided directly** by the user as a query object

Official references:
- GQI: https://aka.dataminer.services/about-gqi

For **real-time (push) updates** — subscribing to live row changes via `ObserveQuerySessionAsync` instead of repeated one-shot fetches — see `references/realtime-updates.md`.

---

## Overview

GQI query execution happens in three phases:

1. **Open a session** — HTTP POST to `OpenQuerySessionAsync` with the hardcoded query object. Returns a session ID and column metadata.
2. **Fetch pages** — Request row data pages via WebSocket using `GetNextQuerySessionPage` until `IsLast: true`.
3. **Close the session** — Non-live sessions close automatically after the last page; close unfinished or live sessions with `CloseQuerySession` (see [Closing query sessions and cleanup](#closing-query-sessions-and-cleanup)).

All queries share the app's single WebSocket and one `GetEvents` queue for the app's entire lifetime; each session is identified by its own inner `clientSubscriptionID` (see `references/websocket-protocol.md`). Closing a session is an HTTP call, not a socket close. For WebSocket connection setup (URL, `SetConnectionID`, keep-alive, `ClientSubscriptionID` management), see the **dataminer-api** skill (`references/websocket-setup.md`). The `connection` string comes from the session bootstrap call described in the **dataminer-api** skill.

See `references/websocket-protocol.md` for GQI-specific message formats (queue events and row data pages).

---

## OpenQuerySessionAsync HTTP call

```json
POST ../../API/v1/Internal.asmx/OpenQuerySessionAsync
{
  "queueID": <number>,
  "clientSubscriptionID": <number>,
  "connection": "<connection-string>",
  "query": { <hardcoded query object> },
  "options": {
    "OptimizationType": 1,
    "TimeZoneID": "Europe/Brussels",
    "LanguageTag": "en-US",
    "FetchLocal": true,
    "UseDynamicUnits": true,
    "EnableUpdates": false,
    "QueryTag": "MyApp/Resources"
  }
}
```

**`options` field reference:**

| Field | Type | Description |
|-------|------|-------------|
| `OptimizationType` | int | `0` = optimize to return the first page of results quickly. `1` = optimize to return all pages as fast as possible. |
| `TimeZoneID` | string | IANA timezone string used to format date/time values (e.g. `"Europe/Brussels"`). Use `Intl.DateTimeFormat().resolvedOptions().timeZone` for the user's local timezone. |
| `LanguageTag` | string | BCP 47 language tag for localized display values (e.g. `"en-US"`). Use `navigator.language` for the user's browser language. |
| `FetchLocal` | bool | `true` = data is fetched on the DMA itself (required for most use cases). |
| `UseDynamicUnits` | bool | `true` = units adapt to the magnitude of the value (e.g. KB → MB → GB). |
| `EnableUpdates` | bool | `false` = one-shot fetch. `true` = live updates pushed via WebSocket as data changes. Use `false` for most production apps. |
| `QueryTag` | string | Always set a stable, non-empty identifier for the app and logical query, e.g. `"MyApp/Resources"`. Reuse it across refreshes and reconnects so sessions can be traced. Do not include credentials or personal data. |

---

## Response formats

### OpenQuerySessionAsync response

```json
{
  "__type": "Skyline.DataMiner.Web.Common.v1.DMAGenericInterfaceSessionInfo",
  "ID": "<session-guid>",
  "Columns": [
    { "Name": "Column Name", "ClientType": "string", "ServerType": "string", "ID": "column-id", "Discreets": [], "IsDiscreet": false }
  ],
  "ColumnLinks": [ ... ]
}
```

- `d.ID` = session ID (needed for `GetNextQuerySessionPage`)
- `d.Columns` = column metadata (names, types, discreet values)

### Row data format

```json
{
  "Type": "DMAEvent",
  "Data": {
    "Message": {
      "Rows": [
        { "Cells": [{ "Value": "actual-value", "DisplayValue": "display-string" }] }
      ],
      "IsLast": true
    }
  }
}
```

- Use `DisplayValue` for rendering — it resolves discreet values to their display strings
- Use `Value` for programmatic logic (comparisons, passing back to the API) — it holds the raw value
- `IsLast: false` means more pages are available — send another `GetNextQuerySessionPage`

---

## WebSocket execution sequence

| Step | Direction | Action |
|------|-----------|--------|
| 1 | client→server | `SetConnectionID` — bind WebSocket to HTTP session |
| 2 | server→client | `Type: "String"` confirmation — wait before proceeding |
| 3 | client→server | `GetEvents` with `queueID` — creates the server-side queue; subscribe to it |
| 4 | client→HTTP | `OpenQuerySessionAsync` — returns `d.ID` (session ID) and `d.Columns` |
| 5 | client→server | `GetNextQuerySessionPage` — request first page of rows |
| 6 | server→client | `DMAEvent` with `Message.Rows` — accumulate; check `Message.IsLast` |
| 7 | (repeat 5–6) | if `IsLast: false`, send another `GetNextQuerySessionPage` |
| 8 | server | Automatically closes the non-live session after `IsLast: true` |

> `GetEvents` (step 3) is what creates the server-side queue — always send it before calling `OpenQuerySessionAsync`. Generate one `queueID` per app session and reuse it across all queries on the same connection. It must fit a signed 32-bit integer; mask a random `Uint32` with `0x7fffffff` as in the example.

---

## Production code example

The Web API automatically closes this one-shot session after the final page. Apply the cleanup rules below when adding cancellation, lazy loading, or error handling.

```javascript
const INTERNAL_API = `${window.location.protocol}//${window.location.host}/API/v1/Internal.asmx`;

async function internalPost(method, body) {
  const r = await fetch(`${INTERNAL_API}/${method}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
  const json = await r.json();
  if (!r.ok) throw new Error(json?.Message || r.statusText);
  return json.d;
}

// Hardcoded query object — discovered by the agent's Node.js script (see dataminer-data-discovery skill)
const QUERY = { /* discovered query object goes here */ };

// One queue ID per app session — reused for every query on this connection
const QUEUE_ID = crypto.getRandomValues(new Uint32Array(1))[0] & 0x7fffffff;

async function fetchData(connection) {
  let subID = 1;
  const subscriptionID = 7;

  return new Promise((resolve, reject) => {
    const proto = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const ws = new WebSocket(`${proto}//${window.location.host}/API/v1/WebSocket.ashx`);

    let sessionId = null;
    let columns = [];
    const rows = [];

    ws.addEventListener('open', () => {
      ws.send(JSON.stringify({ ClientSubscriptionID: subID++, Method: 'SetConnectionID', Parameters: { connectionID: connection } }));
    });

    ws.addEventListener('message', async e => {
      const msg = JSON.parse(e.data);
      if (msg.Type === 'String') {
        // GetEvents creates the server-side queue — send it before OpenQuerySessionAsync
        ws.send(JSON.stringify({ ClientSubscriptionID: subID++, Method: 'GetEvents', Parameters: { queueID: QUEUE_ID } }));
        const sessionInfo = await internalPost('OpenQuerySessionAsync', {
          connection,
          queueID: QUEUE_ID,
          clientSubscriptionID: subscriptionID,
          query: QUERY,
          options: {
            OptimizationType: 1,
            TimeZoneID: Intl.DateTimeFormat().resolvedOptions().timeZone,
            LanguageTag: navigator.language,
            FetchLocal: true,
            UseDynamicUnits: true,
            EnableUpdates: false,
            QueryTag: 'MyApp/QueryName' // short identifier for tracing; update to match your app/query
          }
        });
        sessionId = sessionInfo.ID;
        columns = sessionInfo.Columns;
        ws.send(JSON.stringify({
          ClientSubscriptionID: 2,
          Method: 'NotifySubscription',
          Parameters: { clientSubscriptionID: subscriptionID, method: 'GetNextQuerySessionPage', data: { sessionID: sessionId, pageSize: 50 } }
        }));
      }
      if (msg.Type === 'DMAEvent' && msg.Data?.Message?.Rows && sessionId) {
        rows.push(...msg.Data.Message.Rows);
        if (msg.Data.Message.IsLast) {
          ws.close();
          resolve(rows.map(row =>
            Object.fromEntries(columns.map((col, i) => [col.Name, row.Cells[i]?.DisplayValue]))
          ));
        } else {
          ws.send(JSON.stringify({
            ClientSubscriptionID: 2,
            Method: 'NotifySubscription',
            Parameters: { clientSubscriptionID: subscriptionID, method: 'GetNextQuerySessionPage', data: { sessionID: sessionId, pageSize: 50 } }
          }));
        }
      }
    });

    ws.addEventListener('error', reject);
  });
}
```

---

## Running multiple queries in parallel

Run **independent** queries concurrently over the single shared WebSocket: open every session up front by issuing their `OpenQuerySessionAsync` calls without awaiting one before starting the next. Keep the one WebSocket and one `queueID`; give each in-flight query a **distinct fixed inner `clientSubscriptionID`** (reused in its `OpenQuerySessionAsync` body and `GetNextQuerySessionPage` frames), then route each `DMAEvent` by `msg.Data.ClientSubscriptionID`. Give each logical query its own meaningful `QueryTag`. Completed non-live sessions close automatically. Close unfinished or live sessions individually; keep the shared WebSocket open for other queries.

**Exception:** chain sequentially only when a query needs another's result (e.g. B filters on IDs from A); keep the rest parallel. See `references/realtime-updates.md` ("The subscription-id channel") for the routing details.

---

## Closing query sessions and cleanup

Assign cleanup to the function or component that owns each opened GQI session. Call `CloseQuerySession` for unfinished queries or live subscriptions when the consumer stops needing them. Keep previously fetched rows displayed after closure.

| Situation | Required behavior |
|-----------|-------------------|
| `IsLast: true`, updates disabled | The Web API closes the session automatically. |
| `IsLast: true`, updates enabled | Keep the session open while the consumer needs live updates. |
| Lazy loading paused, more pages still needed | Keep the session open for subsequent page requests. |
| Manual/automatic refresh, filters change, or query replacement | Close the active unfinished or live session before opening its replacement. |
| Consumer unmounts, navigates away, or cancels | Close its unfinished or live session. |
| Error after opening or connection replacement | Close any still-open session before retrying; report cleanup failures. |
| Opening completes after cancellation or replacement | Close the returned session immediately. |

Use the same authenticated connection that opened the session:

```text
POST /API/v1/Internal.asmx/CloseQuerySession
```

```json
{
  "connection": "<connection-string>",
  "sessionID": "<session-guid>"
}
```

Implement cleanup once and await it before replacing the query.

Verify automatic final-page closure, refresh during paging, live unsubscribe, query errors, cancellation during opening, and repeated refreshes. Verify that other queries on the shared WebSocket keep working after one session closes.
