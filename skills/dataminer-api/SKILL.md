---
name: dataminer-api
description: If you need to use DataMiner Web Services endpoints use this skill. Use for authentication via ConnectAppAndInfo, strict endpoint validation against DataMiner docs, GetSecurityInfo access checks, global authorization guard patterns, and WebSocket connection setup.
argument-hint: Use for DataMiner-only API integrations with strict endpoint verification
license: MIT
user-invocable: true
metadata:
  updated: 2026-05-27
  version: 1.0
---

# DataMiner API Skill

When building frontend apps that interact with DataMiner API endpoints, you should ALWAYS follow these rules:

1. Only use documented endpoints
2. Validate every endpoint against official docs before use
3. Rely on the DataMiner `/auth/` session cookie; bootstrap the connection GUID for WebSocket use
4. Perform a mandatory access check before rendering protected UI
5. Implement a global authorization guard
6. Set up WebSocket connections using the standard protocol

Make sure you don't skip any of these rules and follow them to ensure correct and secure DataMiner API integration.

---

1. Only use documented endpoints

- Use only documented DataMiner endpoints
- Never implement undocumented or assumed endpoints
- Verify exact path, method, and payload format per endpoint
- If you don't find the data the user wants, be honest about that
- For DOM instances, ad hoc data sources, or custom queries — use the **dataminer-data-discovery** skill instead; those are not available through this API

Official references:

- WS v0: https://docs.dataminer.services/develop/webservices/WS_v0/WS_Methods_v0/WS_Methods_v0.html
- WS v1: https://docs.dataminer.services/develop/webservices/WS_v1/WS_Methods_v1/WS_Methods_v1_overview.html

---

2. Validate every endpoint against official docs before use

- Confirm the endpoint exists in the official docs before adding it
- Verify the request structure exactly matches what the docs specify
- IMPORTANT: Verify the response field names exactly match the docs — fetch the endpoint's doc page to confirm property names before writing code that references them
- Check whether a connection string is required for the endpoint
- The `DMAConnection` cookie is **not** HttpOnly — read the GUID from `document.cookie` on app load (see rule 3). For same-origin API calls the browser also sends it automatically.
- Where an endpoint requires an explicit `connection` parameter, use the in-memory GUID obtained from the session bootstrap (see rule 3)
- Use relative URL format: `/API/v1/Json.asmx/{Method}`
- Centralize auth error handling for `401`, `403`, and `500` (`NoConnectionWebApiException` only) — redirect to `/auth/?url=<current-path>`

---

3. Rely on the DataMiner `/auth/` session cookie; bootstrap the connection GUID for WebSocket use

Frontend apps do NOT collect credentials. End users sign in through DataMiner's built-in page at `/auth/?url=%2Fpublic%2F{BuildFolderName}%2Findex.html`. After sign-in, DataMiner sets the `DMAConnection` cookie and redirects to the app.

Key facts about `DMAConnection`:
- It is **SameSite=Strict but NOT HttpOnly** — JavaScript can read it via `document.cookie`
- The cookie value is the connection GUID directly
- The browser also sends it automatically on same-origin requests

See `references/authentication.md` for the full session reference: entry URL, bootstrap on load, sign-out flow, code examples, and the global authorization guard pattern.

Key rules:
- The app must be reached via `/auth/?url=...` (URL-encoded path). Opening `/public/{BuildFolderName}/index.html` directly has no session.
- On app load, read the GUID from `document.cookie` and verify it with `IsConnectionAlive`. If the cookie is absent or verification fails, redirect to `/auth/?url=` + `encodeURIComponent(location.pathname + location.search)`.
- Keep the verified GUID in memory (React state/context) — it is needed for WebSocket `SetConnectionID` and for endpoints that require an explicit `connection` parameter.
- Iframe deployment: the app may be embedded in an `<iframe>`. Handle missing cookies gracefully (do not crash) and avoid infinite redirect loops. See `references/authentication.md` for details.
- Sign-out for custom apps: redirect to `/auth/logout?url=<current-path>` — this triggers a clean logout on the WebAPI and clears all session cookies server-side.

---

4. Perform a mandatory access check before rendering protected UI

Before rendering protected UI, verify the session GUID with `IsConnectionAlive` — see `references/authentication.md` for the full request format and handling.

- Read the GUID from the `DMAConnection` cookie on app load
- Call `IsConnectionAlive` once to confirm the GUID is valid before rendering
- If the call fails, the cookie is absent, or the GUID is empty, redirect to `/auth/?url=<current-path>`
- Do not call `IsConnectionAlive` again after a successful bootstrap — one check is sufficient
- Render a loading state while the session check is in progress — if the `DMAConnection` cookie is absent before `IsConnectionAlive` returns, redirect to `/auth/?url=<current-path>` immediately without waiting for the call to complete

---

5. Implement a global authorization guard

Implement a centralized guard in app state (context/store):

```text
API call -> if response is 401/403 -> set isAuthorized=false -> redirect to /auth/?url=<current-path> -> stop further protected API calls
API call -> if response is 500 AND exception type is NoConnectionWebApiException -> set isAuthorized=false -> redirect to /auth/?url=<current-path> -> stop further protected API calls
```

- A `500` response may indicate a server-side error unrelated to the session — only treat it as an auth failure when the error type is `NoConnectionWebApiException`; other 500 errors should be surfaced as application errors
- Build the redirect with `encodeURIComponent(location.pathname + location.search)`; never hand-write `%2F` in code
- Do NOT render an in-app login form as a fallback — sign-in always happens on DataMiner's `/auth/` page
- If the app suddenly shows a blank page, the `DMAConnection` cookie has likely expired. Redirect to `/auth/?url=<current-path>` to get a fresh session.

---

6. Set up WebSocket connections using the standard protocol

When the app needs async/event-driven communication with DataMiner (e.g. GQI data delivery), use the WebSocket endpoint.

- See `references/websocket-setup.md` for the full connection setup: URL, message format, `SetConnectionID` flow, keep-alive (Ping/Pong), and `ClientSubscriptionID` management
- The `connection` string used in `SetConnectionID` is the GUID obtained from the session bootstrap call in rule 3
