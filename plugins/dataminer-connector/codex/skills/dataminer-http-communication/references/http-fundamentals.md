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
            <Content>
                <Group>1</Group>
            </Content>
        </Timer>
    </Timers>
</Protocol>
```

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

DataMiner behavior based on HTTP status code:

| Status | Category | Behavior |
| --- | --- | --- |
| 2xx | Success | Normal processing |
| 3xx | Redirect | Auto-redirect if Location header present |
| 4xx | Client Error | Element goes into timeout |
| 5xx | Server Error | Element goes into timeout |

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

When an HTTP response returns a 4xx or 5xx status code, the element goes into **timeout**. DataMiner automatically attempts to recover from timeout using the **ping group** — a special group with ID `-1`.

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

## Logging

Enable HTTP communication logging:
- Set information logging to level 3

## See Also

- [HTTP Implementation](http-implementation.md) - Request/response details
- [HTTP Configuration](http-configuration.md) - Element and dynamic settings
- [Protocol Schema: HTTP](../../dataminer-protocol-xml-reference/references/protocol-http.md)
