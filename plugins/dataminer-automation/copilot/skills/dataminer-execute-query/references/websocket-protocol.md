# DataMiner WebSocket Protocol — GQI Reference

For generic WebSocket connection setup (URL, `SetConnectionID`, keep-alive, message structure, `ClientSubscriptionID` management), see the **dataminer-api** skill (`references/websocket-setup.md`).

This reference covers GQI-specific WebSocket messages used by `CreateAIGeneratedQuery` and `OpenQuerySessionAsync`.

Three scopes are in play; do not conflate them:

| Scope | Cardinality | Lifetime |
|-------|-------------|----------|
| WebSocket | one per app | entire app lifetime |
| `GetEvents` queue (`queueID`) | one, shared by all GQI sessions | entire app lifetime |
| GQI session (inner `clientSubscriptionID`) | one per query session | until the consumer no longer needs its pages or updates |

---

## Queue-based event subscription

`GetEvents` creates the server-side queue and subscribes to it. Send it **before** the HTTP call (`OpenQuerySessionAsync` / `CreateAIGeneratedQuery`):

```json
{ "ClientSubscriptionID": <N>, "Method": "GetEvents", "Parameters": { "queueID": <same-queueID-as-HTTP-call> } }
```

The server then delivers results as `DMAEvent` messages on that queue. Make the HTTP call only after `GetEvents` is sent.

---

## Requesting GQI row pages

Once you have a session ID from `OpenQuerySessionAsync`, request pages via WebSocket (not HTTP):

```json
{
  "ClientSubscriptionID": <N>,
  "Method": "NotifySubscription",
  "Parameters": {
    "clientSubscriptionID": <N>,
    "method": "GetNextQuerySessionPage",
    "data": { "sessionID": "<session-id>", "pageSize": 50 }
  }
}
```

The server responds with a `DMAEvent`:

```json
{
  "Type": "DMAEvent",
  "Data": {
    "Message": {
      "Rows": [
        { "Cells": [{ "Value": "raw-value", "DisplayValue": "display-string" }] }
      ],
      "IsLast": false
    }
  }
}
```

- Use `DisplayValue` for rendering — it resolves discreet values to human-readable strings
- `IsLast: false` → send another `GetNextQuerySessionPage`
- `IsLast: true` → initial pagination complete. Non-live sessions close automatically; keep live sessions open while updates are needed.

---

## Correlating pages when multiple queries run in parallel

The single shared socket can carry **several query sessions at once**. Give each concurrent query a distinct, fixed inner `clientSubscriptionID` (used in both its `OpenQuerySessionAsync` body and `GetNextQuerySessionPage` frames). The server stamps that value onto every `DMAEvent` for the session as `Data.ClientSubscriptionID` — filter on it to keep streams separate:

```json
{ "Type": "DMAEvent", "Data": { "ClientSubscriptionID": 7, "Message": { "Rows": [ ... ], "IsLast": false } } }
```

Keep the single `queueID` and single WebSocket — only the inner `clientSubscriptionID` distinguishes parallel sessions. Close unfinished or live sessions individually with `CloseQuerySession`, keeping the shared socket open. See the **execute-query** skill ("Running multiple queries in parallel" and "Closing query sessions and cleanup").

---
