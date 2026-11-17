# HTTP Fundamentals

Overview of HTTP communication in DataMiner connectors.

## HTTP in DataMiner

DataMiner supports HTTP communication via connections of type `http`. The **SLPort** process handles all HTTP communication using the Windows HTTP Services (WINHTTP) API.

### Connection Lifecycle

```
Session Start
    │
    ├── Connection created to data source
    │
    ├── Request 1 sent/received
    ├── Request 2 sent/received
    ├── ... (all connections in session)
    │
    └── Connection closed after last request
```

- Connection created **before** each Session
- Connection closed **after** the last request in the Session
- Multiple elements polling same URL = separate connections each
- Two HTTP interfaces to same URL on one element = two connections

## Protocol Structure

HTTP communication follows this pattern:

```
Timer → Group → Session → Connection → Request/Response
```

```xml
<Protocol>
    <Type>http</Type>
    
    <HTTP>
        <Session id="1" name="GetData">
            <Connection id="1">
                <Request verb="GET" url="/api/data" />
                <Response statusCode="100">
                    <Content pid="200" />
                </Response>
            </Connection>
        </Session>
    </HTTP>
    
    <Groups>
        <Group id="1">
            <Type>poll</Type>
            <Content>
                <Session>1</Session>
            </Content>
        </Group>
    </Groups>
    
    <Timers>
        <Timer id="1">
            <Time initial="true">30000</Time>
            <Interval>75</Interval>
            <Content>
                <Group>1</Group>
            </Content>
        </Timer>
    </Timers>
</Protocol>
```

## Rate Limiting, Request Pacing, and Load Control

When interacting with a high-load HTTP API or an endpoint with strict rate limits, calls can fail if DataMiner sends requests too rapidly in a burst:

- **Each HTTP call corresponds to a Session**: Every `<Session>` executes one or more HTTP requests.
- **`<Interval>` paces requests between Groups**: In `<Timers><Timer>`, the `<Interval>` tag specifies the delay in milliseconds between consecutive groups (default 75 ms).
- **When reducing polling is not an option**: If operational requirements prohibit reducing the polling frequency (i.e., `<Time>` cannot be increased), the most accurate action to solve call failures caused by a high number of HTTP calls is to **review the protocol and increase the `Timer.Interval` value**. This inserts a larger delay between consecutive group executions, spreading requests across the polling cycle and eliminating burst-related overload without reducing the polling rate or dropping any sessions.
- **Why reducing the number of groups is WRONG**: Reducing the number of groups while keeping the same number of sessions does not reduce the number of HTTP calls (the same sessions still execute). Furthermore, because `Timer.Interval` is applied between groups, reducing groups removes inter-group pacing delays and causes sessions in the same group to fire in immediate succession with zero delay, worsening the request burst.
- **No automatic load balancing**: DataMiner does not have a built-in automatic load balancing mechanism for external HTTP APIs; request pacing must be designed via `Timer.Interval` and group structure.

## Session Structure

A Session contains one or more Connections, each with a Request and Response.

```xml
<Session id="1" name="API Request" loginMethod="credentials" userName="40" password="42">
    <Connection id="1" name="Get Status">
        <Request verb="GET" url="/api/status">
            <Headers>
                <Header key="Accept">application/json</Header>
            </Headers>
        </Request>
        <Response statusCode="100">
            <Content pid="200" />
        </Response>
    </Connection>
</Session>
```

### Session Attributes

| Attribute | Description |
| --- | --- |
| `id` | Unique session identifier |
| `name` | Descriptive name |
| `loginMethod` | `credentials` for Basic auth |
| `userName` | Parameter ID containing username |
| `password` | Parameter ID containing password |
| `proxyServer` | Parameter ID containing proxy address |

## Authentication

### Basic Authentication

Specify credentials via `loginMethod="credentials"`:

```xml
<Session id="1" loginMethod="credentials" userName="40" password="42">
```

- Parameters 40 and 42 contain username/password
- DataMiner tries Basic Authentication first (pre-authentication)
- If 401 returned, uses scheme from response header
- Parameter 42 must be password-masked and neither credential may have a source-controlled secret default.
- Never log credential values or a complete Authorization header.

### Bearer Token

Use a Header for Bearer tokens:

```xml
<Request verb="GET" url="/api/data">
    <Headers>
        <Header key="Authorization" pid="50" />
    </Headers>
</Request>
```

Parameter 50 contains: `Bearer eyJhbGciOiJIUzI1NiIs...`

The authorization parameter must be non-displayed or password-masked as appropriate for its source. Never log or persist the token unless the target's lifecycle explicitly requires approved persistence.

## Status Code Handling

The received HTTP status code of each request influences the state of the element receiving such responses. In DataMiner, status codes are handled as follows:

| Status Code | Category | Contributes to Element Timeout? | Behavior in DataMiner |
|-------------|----------|---------------------------------|-----------------------|
| **1XX** | Informational | **No** | Normal / informational processing; does not cause timeout. |
| **2XX** | Success | **No** | Normal processing; does not cause timeout. |
| **3XX** | Redirection | **No (not always)** | Automatically redirects if `Location` header is present (e.g. 301, 303, 307). Does not always contribute to timeout (only times out if no `Location` header is returned or custom redirection fails). |
| **4XX** | Client Errors | **Yes (Always)** | Element goes into timeout (e.g. 400 Bad Request, 401 Unauthorized, 404 Not Found). |
| **5XX** | Server Errors | **Yes (Always)** | Element goes into timeout (e.g. 500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable). |
| **6XX** | System Errors | **Yes (Always)** | Element goes into timeout. In DataMiner, system-level / WINHTTP communication and transport failures (e.g. connection failures, socket errors, SSL/TLS handshake failures) are categorized as **6XX System Errors**. |

> **Key Rule**: The **3 HTTP status code classes that always contribute to an Element Timeout** are **4XX (Client Errors)**, **5XX (Server Errors)**, and **6XX (System Errors)**. `1XX` and `2XX` never cause timeout, while `3XX` auto-redirects when a `Location` header is present and therefore does not always contribute to timeout.

### Redirect Handling

- 301, 303, 307: Auto-redirect using Location header
- 300 (Multiple Choices): Element timeout (no Location)
- Disable auto-redirect: Use `customRedirect` communication option

```xml
<Type communicationOptions="customRedirect">http</Type>
```

With `customRedirect`, the protocol handles redirection logic.

## Retry Mechanism

Retries triggered for:
- `WINHTTP_ERROR_TIMEOUT` - Request timed out
- `ERROR_WINHTTP_CANNOT_CONNECT` - Cannot connect to server

Retry count configured in element connection settings.

## Ping Group (Timeout Recovery)

When an HTTP response returns a 4xx, 5xx, or 6xx status code, the element goes into **timeout**. DataMiner automatically attempts to recover from timeout using the **ping group** — a special group with ID `-1`.

### Definition

```xml
<Group id="-1">
    <Name>Ping</Name>
    <Description>Ping</Description>
    <Type>poll</Type>
    <Content>
        <Session>-1</Session>
    </Content>
</Group>
```

With a corresponding lightweight session:

```xml
<Session id="-1" name="Ping">
    <Connection id="1">
        <Request verb="GET" url="/" />
        <Response statusCode="98">
            <Content pid="99" />
        </Response>
    </Connection>
</Session>
```

### Rules

- Group ID **must be `-1`** — this is the convention DataMiner uses for automatic timeout recovery
- The session should target an endpoint that replies successfully **independent of element configuration** (e.g. health check, root path, or version endpoint)
- If the ping group gets a successful response, the element exits timeout state
- Best practice: use a lightweight GET request that always returns 2xx when the server is reachable
- Parameters for ping status code / content should be non-displayed (`<RTDisplay>false</RTDisplay>`)
- All HTTP response parameters (status code, response body, parsed values) MUST use `<Type>read</Type>` — **NEVER** `<Type>dummy</Type>`. Use `<RTDisplay>false</RTDisplay>` for non-displayed intermediates. `dummy` is reserved for trigger-only params (e.g. AfterStartup) that carry no data.

## Element Wizard Connection Testing (ping="true")

In DataMiner Cube, operators creating or updating an element can test communication with a specified IP address before finalizing element creation using the **Test connection** button:

- **How to enable**: Define a polling group with the attribute `ping="true"` in the protocol XML:
  ```xml
  <Group id="10" ping="true">
      <Name>Test Connection</Name>
      <Description>Test Connection</Description>
      <Type>poll</Type>
      <Content>
          <Session>10</Session>
      </Content>
  </Group>
  ```
- **How it works**: When the user enters an IP address and clicks "Test connection" in the Element Wizard, DataMiner executes the designated `ping="true"` group against that IP address. If the request succeeds (receives a valid response without timing out), DataMiner reports "Connection successful". If it times out or fails, an error is reported.
- **Requirement**: If no group has the `ping="true"` attribute defined, the "Test connection" button in the wizard is disabled.
- **Distinct from Timeout Recovery (`id="-1"`)**:
  - `Group ping="true"`: Used **before/during element creation or update** in the wizard to test candidate IP addresses.
  - `Group id="-1"`: Used **after element creation** when a running element enters timeout (slow-poll recovery mode).

## Process Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ SLProtocol  │────▶│   SLPort    │────▶│   WINHTTP   │
│  (Group)    │     │  (Queue)    │     │  (HTTP)     │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Data Source │
                    │  (Server)   │
                    └─────────────┘
```

1. Group containing Session added to protocol queue
2. Session passed to SLPort
3. SLPort queues request (per IP:port combination)
4. WINHTTP executes HTTP request
5. Response returned to SLPort → SLProtocol
6. Response content stored in parameter
7. QAction processes response (if configured)

### Important Notes

- Entry point blocked during request processing
- Multiple elements to same IP:port share SLPort queue
- Long requests block other requests to same destination
- QAction triggered by response must complete before group finishes

## Reusing Sessions Across Queued Groups & Parameter Resolution

A common pattern in DataMiner protocols is having multiple groups placed in the protocol execution queue one right after each other to send out different HTTP requests that use the same `<Session>` definition (e.g. iterating over a collection of IDs, endpoints, or payloads where dynamic parameters such as `<Request pid="...">` or `<Data pid="...">` are used):

- **Request Composition Behavior**: It is **FALSE** that all generated HTTP sessions will be identical or that only the last values that were set on the session parameters will be used to compose the requests.
- Each HTTP request is composed for its respective group execution. DataMiner does not retroactively overwrite earlier queued or executing requests with only the last parameter values set in element memory.
- Therefore, multiple groups in the queue referencing the same session can successfully dispatch distinct, non-identical HTTP requests across the execution sequence.

## Logging

Enable HTTP communication logging:
- Set information logging to level 3

## See Also

- [HTTP Implementation](http-implementation.md) - Request/response details
- [HTTP Configuration](http-configuration.md) - Element and dynamic settings
- [Protocol Schema: HTTP](../../dataminer-connector-protocol-xml/references/protocol-http.md)
