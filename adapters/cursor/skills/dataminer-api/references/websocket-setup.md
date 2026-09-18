# DataMiner WebSocket Connection Setup

> **STRICT RULE: Only ever create ONE WebSocket connection per session.** Do not open multiple WebSocket connections. All subscriptions and messages must share the single connection established at session start.

The DataMiner WebSocket endpoint is used for all async/event-driven communication. The `connection` string is the GUID read from the `DMAConnection` cookie — see `references/authentication.md` for the full session bootstrap pattern.

- **URL:** `ws(s)://<host>/API/v1/WebSocket.ashx`
- All messages are JSON strings

---

## Message structure

All client→server messages:

```json
{
  "ClientSubscriptionID": <integer>,
  "Method": "<method-name>",
  "Parameters": { ... }
}
```

All server→client messages:

```json
{
  "Type": "<message-type>",
  "Data": { ... }
}
```

---

## Connection lifecycle

### 1. On connect — server sends WebSocketChannelInfo automatically

```json
{
  "Type": "WebSocketChannelInfo",
  "Data": {
    "Version": "...",
    "Connections": [...],
    "ID": "<channel-id>"
  }
}
```

No client action needed; this is informational.

### 2. SetConnectionID — bind WebSocket to your HTTP session

Read the connection GUID from the non-HttpOnly `DMAConnection` cookie (see `references/authentication.md`). Keep it in memory after bootstrap and pass it here.

Send immediately after the socket opens:

```json
{ "ClientSubscriptionID": 1, "Method": "SetConnectionID", "Parameters": { "connectionID": "<connection-string>" } }
```

**Wait for the confirmation before proceeding.** The server echoes back a `Type: "String"` message containing the connection ID.

### 3. Keep-alive — Ping/Pong

Send every **30 seconds** to keep the connection alive (This also resets the server-side session timer, so no separate HTTP keep-alive call is needed.):

```json
{ "ClientSubscriptionID": 0, "Method": "Ping", "Parameters": {} }
```

Server responds with `Type: "Pong"`.

---

## ClientSubscriptionID management

- Start at `1` and increment by `1` for every message sent in a session
- `0` is reserved for Ping
- The server echoes `ClientSubscriptionID` back in responses so you can correlate requests to responses
- Keep a single session-level counter shared across all WebSocket messages
