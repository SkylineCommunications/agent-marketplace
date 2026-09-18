---
name: dataminer-data-discovery
description: Perform AI-assisted data discovery against a live DataMiner system using the CreateAIGeneratedQuery endpoint. Use when the user asks to discover data, query DataMiner with natural language, run data discovery on goals, items, products, releases, or any DataMiner entity.
argument-hint: Natural language prompt, e.g. 'show me all goals' or 'list roadmap items by status'
license: LicenseRef-Skyline-Agent-Marketplace
user-invocable: true
---

# Data Discovery Skill

> **Note:** NL2GQI (`CreateAIGeneratedQuery`) requires the **DataMiner Assistant DxM** (v1.0.0+) to be installed and running. If it is missing, the HTTP call returns `{"d":null}` but no query arrives over the WebSocket (you get a `WebSocketError` `DMAEvent` and the discovery times out). Install it first: https://docs.dataminer.services/dataminer/Functions/DataMiner_Assistant/Assistant_DxM.html

GQI is for data that is **NOT** available through the standard DataMiner Web API endpoints. Use GQI for DOM instances, ad hoc data sources, and custom queries. Do **NOT** use GQI for elements, alarms, views, or services — those are available through the **dataminer-api** skill.

The full flow is two steps:

1. **Discover**: As an agent step, authenticate to DataMiner and run a Node.js script that calls `CreateAIGeneratedQuery` (NL2GQI) directly. The agent captures the discovered query object from the script output — no user action needed.
2. **Build**: Hardcode the discovered query into the production app and execute it using `OpenQuerySessionAsync`. See the **dataminer-execute-query** skill for the full production execution flow.

Official references:
- GQI: https://docs.dataminer.services/dataminer/Functions/Dashboards_and_Low_Code_Apps/GQI/About_GQI.html
- NL2GQI: https://docs.dataminer.services/dataminer/Functions/DataMiner_Assistant/NL2GQI.html

---

## WebSocket protocol (discovery)

NL2GQI data delivery happens over a WebSocket connection.

- For WebSocket connection setup (URL, `SetConnectionID`, keep-alive, `ClientSubscriptionID` management) see the **dataminer-api** skill (`references/websocket-setup.md`)
- The `connection` string comes from `ConnectAppAndInfo` (see the **dataminer-api** skill)
- Use relative URL format for HTTP calls: `../../API/v1/{endpoint}`

See the **dataminer-execute-query** skill (`references/websocket-protocol.md`) for GQI-specific message formats (queue events and row data pages).

**Subscribe to queue events (used after `CreateAIGeneratedQuery`):**

After calling `CreateAIGeneratedQuery`, subscribe via WebSocket:

| Step | Direction | Message |
|------|-----------|---------|
| 1 | client→server | `{"ClientSubscriptionID":<N>,"Method":"GetEvents","Parameters":{"queueID":<same-queueID-as-HTTP-call>}}` |
| 2 | server→client | `DMAEvent` messages — the server delivers results as events on the subscribed queue |

---

## Step 1 — Discover the query (fully agent-orchestrated)

The agent executes the entire discovery process. The user provides their DataMiner host and credentials once; the agent handles everything else.

**Agent procedure:**

1. Ask the user for their DataMiner host URL (e.g. `http://my-dma` or `https://my-dma`) and their DataMiner username and password
2. Authenticate via `ConnectAppAndInfo` using PowerShell — capture the connection GUID from `d.Connection`.

   **Exact request body** (all fields are required; `host` must be present as an empty string):

   ```powershell
   $body = @{
     host             = ""          # obsolete but must be present
     login            = "<username>"
     password         = "<password>"
     clientAppName    = "CopilotDiscovery"
     clientAppVersion = "1.0"
     clientComputerName = "copilot" # marked optional in docs but DataMiner rejects the call without it
   } | ConvertTo-Json

   $resp = Invoke-RestMethod `
     -Uri "<host>/API/v1/Json.asmx/ConnectAppAndInfo" `
     -Method POST -Body $body -ContentType "application/json" `
     -SkipCertificateCheck   # omit if the host uses a trusted cert

   $connection = $resp.d.Connection
   ```
   
3. Write a temporary Node.js discovery script to a temp file (see example below)
4. In the temp directory, run `npm install ws --save` to ensure the WebSocket package is available
5. Run the script with `node` via the powershell tool, passing host, connection, and prompt as arguments
6. Parse the JSON query object printed by the script
7. Delete the temp files
8. Proceed directly to Step 2 — hardcode the query into the production app

**NL2GQI HTTP call (used in the agent-run Node.js script only):**

```json
POST /API/v1/Internal.asmx/CreateAIGeneratedQuery
{
  "queueID": <number>,
  "clientSubscriptionID": <number>,
  "connection": "<connection-string>",
  "prompt": "Give me all roadmap items\n"
}
```

The HTTP response `d` is `null` — the generated query arrives via **WebSocket**. Generate `queueID` and `clientSubscriptionID` as incrementing integers at runtime.

### Full sequence of operations (agent-run Node.js script)

1. Connect WebSocket and authenticate (`SetConnectionID`) — wait for confirmation before proceeding
2. Register the WebSocket message listener for the query discovery event
3. Call `CreateAIGeneratedQuery` via HTTP — enqueue the NL2GQI request
4. Send `GetEvents` via WebSocket with the same `queueID` — subscribe to queue events
5. Receive `DMAEvent` via WebSocket — `Data.Message` is the generated query object

Once the query is discovered in step 5, proceed to the **dataminer-execute-query** skill to open a session and fetch rows (steps 6–9 of the full flow: `OpenQuerySessionAsync` → `GetEvents` → `GetNextQuerySessionPage` → accumulate rows).

> **Race condition warning:** The WebSocket message listener must be registered BEFORE calling `CreateAIGeneratedQuery`, but `GetEvents` must be sent AFTER the HTTP call returns (the server-side queue doesn't exist until the HTTP call creates it).

### NL2GQI result format

The discovered query arrives as a WebSocket message:

```json
{
  "Type": "DMAEvent",
  "Data": {
    "ClientSubscriptionID": 1,
    "Message": {
      "__type": "Skyline.DataMiner.Web.Common.v1.DMAGenericInterfaceQuery",
      "ID": "Object manager",
      "Options": [ ... ],
      "Child": { ... },
      "Version": 65536,
      "Name": "All roadmap items",
      "NodeKey": "dbd1d9b7-..."
    }
  }
}
```

`Data.Message` is the **complete query object** — feed it directly into `OpenQuerySessionAsync` (see the **dataminer-execute-query** skill).

The agent runs the script, reads the printed query JSON from stdout, and proceeds directly to building the production app using the **dataminer-execute-query** skill. No user action is needed after providing host and credentials.

---

## Step 2 — Build the production app

Once the agent has the discovered query object from the Node.js script output:

- Extract the `query` object and hardcode it in the production code
- Use the **dataminer-execute-query** skill to implement `OpenQuerySessionAsync` execution and row fetching in the production app

**Production constraints:**

- Production apps always use hardcoded query objects with `OpenQuerySessionAsync`
- `CreateAIGeneratedQuery` is only for agent-generated dev-time discovery scripts — never include it in the production app
- NL2GQI requires the DataMiner Assistant DxM (v1.0.0+) and may not be enabled on all systems — see the note at the top of this skill
- NL2GQI does not support column manipulations, custom operators, or data sources requiring parameter selection (e.g. "Get parameter table by ID")

---

## Agent-executed Node.js discovery script

Write this script to a temp file (e.g. `_discover.js`), run `npm install ws --save` in the same temp directory, then execute with `node _discover.js <host> <connection> "<prompt>"`. The discovered query object is printed to stdout as a single JSON line. Delete the temp files after reading the output.

```javascript
// _discover.js — run by the agent, never shipped in the app
const WebSocket = require('ws');
const https = require('https');
const http = require('http');

const [,, host, connection, prompt] = process.argv;
if (!host || !connection || !prompt) {
  console.error('Usage: node _discover.js <host> <connection> "<prompt>"');
  process.exit(1);
}

const baseUrl = host.replace(/\/$/, '');
const isHttps = baseUrl.startsWith('https://');
const agent = isHttps ? new https.Agent({ rejectUnauthorized: false }) : undefined;

function httpPost(path, body) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(body);
    const mod = isHttps ? https : http;
    const url = new URL(baseUrl + path);
    const req = mod.request({ hostname: url.hostname, port: url.port || (isHttps ? 443 : 80), path: url.pathname, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }, ...(agent ? { agent } : {}) }, res => {
      let data = '';
      res.on('data', d => data += d);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch (e) { reject(e); } });
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

(async () => {
  let subID = 1;
  const nlQueueID = crypto.getRandomValues(new Uint32Array(1))[0];
  const wsUrl = baseUrl.replace(/^https?/, isHttps ? 'wss' : 'ws') + '/API/v1/WebSocket.ashx';
  const ws = new WebSocket(wsUrl, { rejectUnauthorized: false });

  const timeout = setTimeout(() => { ws.terminate(); console.error('Timeout: no query received within 60 seconds'); process.exit(1); }, 60_000);

  ws.on('open', () => {
    ws.send(JSON.stringify({ ClientSubscriptionID: subID++, Method: 'SetConnectionID', Parameters: { connectionID: connection } }));
  });

  ws.on('message', async raw => {
    const msg = JSON.parse(raw);
    if (msg.Type === 'String') {
      await httpPost('/API/v1/Internal.asmx/CreateAIGeneratedQuery', {
        connection, queueID: nlQueueID, clientSubscriptionID: subID++, prompt
      });
      ws.send(JSON.stringify({ ClientSubscriptionID: subID++, Method: 'GetEvents', Parameters: { queueID: nlQueueID } }));
    }
    if (msg.Type === 'DMAEvent' && msg.Data?.Message?.__type?.includes('DMAGenericInterfaceQuery')) {
      clearTimeout(timeout);
      ws.close();
      process.stdout.write(JSON.stringify(msg.Data.Message) + '\n');
      process.exit(0);
    }
  });

  ws.on('error', err => { clearTimeout(timeout); console.error('WebSocket error:', err.message); process.exit(1); });
})();
```

**PowerShell commands to run the script:**

Authenticate first using the pattern from the **dataminer-api** skill (rule 3) to obtain `$connection`, then:

```powershell
# 1. Create temp folder, install ws, write script, run it
New-Item -ItemType Directory -Force -Path '_dm_discover' | Out-Null
Set-Location '_dm_discover'
npm install ws --save --silent
# (write _discover.js here)
$query = node _discover.js '<host>' $connection 'YOUR PROMPT HERE'

# 2. Parse the query and clean up
$queryObj = $query | ConvertFrom-Json
Set-Location ..
Remove-Item -Recurse -Force '_dm_discover'

# 3. Proceed to hardcode $queryObj into the production app using the dataminer-execute-query skill
```
