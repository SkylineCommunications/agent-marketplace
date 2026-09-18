# DataMiner API Session Handling

> **KEY FACTS (verified against a live DataMiner system)**
> - `DMAConnection` is **SameSite=Strict but NOT HttpOnly** — JavaScript can read it via `document.cookie`.
> - The cookie value is the connection GUID directly. No extra API call is needed to obtain it.
> - `ConnectAppAndInfo` with empty credentials does **not** return a GUID — it requires real credentials. Do not call it on behalf of end users; use the cookie instead.
> - Sign-out must go through `/auth/logout` — do **not** clear `DMAConnection` from JavaScript. `/auth/logout` triggers a clean logout on the WebAPI and clears all session cookies server-side.
> - Iframe: if the app is embedded in an `<iframe>`, the `DMAConnection` cookie may be unreadable — treat a missing cookie the same as an invalid session (do not crash). Use `window.top.location.replace(...)` for auth redirects so the top-level page navigates rather than just the iframe. If `window.top` is inaccessible (cross-origin iframe), do not redirect at all.

Apps must be opened through `/auth/?url=%2Fpublic%2F{BuildFolderName}%2Findex.html`. After sign-in, DataMiner sets the `DMAConnection` cookie and redirects to the app.

---

## Entry URL

```
{PROTOCOL}://{DOMAIN}/auth/?url=%2Fpublic%2F{BuildFolderName}%2Findex.html
```

- The `url` query parameter value is URL-encoded — `%2F` represents `/`.
- At runtime, always build the redirect with `encodeURIComponent(location.pathname + location.search)` instead of hand-encoding.
- Opening `/public/{BuildFolderName}/index.html` directly (without `/auth/`) has no session — detect this (absent/empty cookie) and redirect.

---

## Cookies set by DataMiner after sign-in

| Cookie | HttpOnly | SameSite | Notes |
|--------|----------|----------|-------|
| `DMAConnection` | No | Strict | Connection GUID — **readable from JS** |
| `DMAUser` | No | Strict | JSON-encoded user info (URL-encoded) |

---

## Endpoints

### IsConnectionAlive — Verify the session

Call once on app load to confirm the GUID from the cookie is still valid.

**Request:**

```json
POST /API/v1/Json.asmx/IsConnectionAlive
Content-Type: application/json

{
  "connection": "<connection GUID from DMAConnection cookie>"
}
```

- If the response is `200 OK` → session is valid, proceed to render the app.
- If the call returns 401, 403, or 500 with type `NoConnectionWebApiException` → cookie is stale or GUID is invalid, redirect to `/auth/`.
- Do **not** call this more than once per page load — one check is sufficient. Session keep-alive is handled by WebSocket Ping (see `references/websocket-setup.md`).

---

## Session lifecycle

### Entry

1. User opens `/auth/?url=%2Fpublic%2F{BuildFolderName}%2Findex.html`.
2. DataMiner authenticates the user, sets the `DMAConnection` (and other) cookies, and redirects to the app.
3. The app loads with the cookie already in place.

### Bootstrap on load

```js
function getConnectionFromCookie() {
  const match = document.cookie.match(/(?:^|;\s*)DMAConnection=([^;]+)/);
  return match ? decodeURIComponent(match[1]) : null;
}

async function bootstrapSession(appName) {
  const connection = getConnectionFromCookie();
  if (!connection) {
    redirectToAuth();
    return null;
  }
  // Verify the GUID is still valid
  const ok = await jsonPost('IsConnectionAlive', { connection });
  if (ok === null) {   // null means 401/403 — jsonPost already redirected
    return null;
  }
  return connection;
}
```

**Loop-breaker**: If the app redirects to `/auth/` and the user signs in but the cookie still yields no valid GUID (should not normally happen), prevent an infinite loop with a sessionStorage flag:

```js
async function bootstrapSession(appName) {
  const connection = getConnectionFromCookie();
  if (connection) {
    const ok = await jsonPost('IsConnectionAlive', { connection });
    if (ok !== null) {
      sessionStorage.removeItem('dm_auth_attempted');
      return connection;
    }
  }
  // No valid session
  if (!sessionStorage.getItem('dm_auth_attempted')) {
    sessionStorage.setItem('dm_auth_attempted', '1');
    redirectToAuth();
  }
  return null;  // caller should render an error/sign-in state
}
```

### Session lost (any 401/403 during app use)

```js
function redirectToAuth() {
  const target = location.pathname + location.search;
  location.replace('/auth/?url=' + encodeURIComponent(target));
}
```

### Sign-out

Always redirect to `/auth/logout` — this triggers a clean logout on the WebAPI and clears all session cookies server-side. Pass the current app URL as the `url` parameter so the user lands back on the app after re-login:

```js
function signOut() {
  sessionStorage.removeItem('dm_auth_attempted');
  const target = location.pathname + location.search;
  location.replace('/auth/logout?url=' + encodeURIComponent(target));
}
```

---

## Full code reference

```javascript
const JSON_API = `${window.location.protocol}//${window.location.host}/API/v1/Json.asmx`;

async function jsonPost(method, body) {
  const r = await fetch(`${JSON_API}/${method}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'same-origin',
    body: JSON.stringify(body)
  });
  if (r.status === 401 || r.status === 403) {
    redirectToAuth();
    return null;
  }
  const json = await r.json();
  if (r.status === 500 && json?.ExceptionType?.includes('NoConnectionWebApiException')) {
    redirectToAuth();
    return null;
  }
  return json.d;
}

function redirectToAuth() {
  const target = location.pathname + location.search;
  location.replace('/auth/?url=' + encodeURIComponent(target));
}

function getConnectionFromCookie() {
  const match = document.cookie.match(/(?:^|;\s*)DMAConnection=([^;]+)/);
  return match ? decodeURIComponent(match[1]) : null;
}

async function bootstrapSession(appName) {
  const connection = getConnectionFromCookie();
  if (connection) {
    const ok = await jsonPost('IsConnectionAlive', { connection });
    if (ok !== null) {
      sessionStorage.removeItem('dm_auth_attempted');
      return connection;
    }
  }
  if (!sessionStorage.getItem('dm_auth_attempted')) {
    sessionStorage.setItem('dm_auth_attempted', '1');
    redirectToAuth();
  }
  return null;
}

function signOut() {
  sessionStorage.removeItem('dm_auth_attempted');
  const target = location.pathname + location.search;
  location.replace('/auth/logout?url=' + encodeURIComponent(target));
}
```

---

## Global authorization guard

Centralize authorization state so any `401`/`403` response immediately stops protected API calls and sends the user back to `/auth/`:

```text
API call → if response is 401 or 403 → set isAuthorized=false → redirectToAuth() → stop further protected API calls
```

Do not render an in-app login form as a fallback — sign-in always happens on DataMiner's `/auth/` page.

---

## WebSocket authentication

The in-memory connection GUID from `bootstrapSession` is also used to bind the WebSocket session via `SetConnectionID`. See `references/websocket-setup.md` for the full WebSocket setup.
