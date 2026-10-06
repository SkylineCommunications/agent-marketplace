# HTTP Examples

Complete implementation examples and internal flow explanation.

## Example: GET with Basic Authentication

Retrieve XML data with Basic Auth credentials:

```xml
<Session id="1" name="Get ASI Inputs" loginMethod="credentials" userName="40" password="42">
    <Connection id="1">
        <Request verb="GET" url="/txp_get_tree?path=/data/elements/asiinput_coll/">
            <Headers>
                <Header key="Accept">text/xml</Header>
            </Headers>
        </Request>
        <Response statusCode="601">
            <Content pid="801" />
        </Response>
    </Connection>
</Session>
```

**Parameters:**
- 40: Username
- 42: Password
- 601: Receives status line (e.g., "HTTP/1.1 200 OK")
- 801: Receives XML response body

Parameters 40 and 42 are user-provided credential parameters. Parameter 42 must use password masking. Neither parameter may contain a source-controlled secret default, and their values must never be logged.

## Example: POST with JSON Body (Data Tag)

SOAP request with custom headers:

```xml
<Session id="101" name="getAllEquipment">
    <Connection id="1" name="getAllEquipment">
        <Request verb="POST" url="/EquipmentInventoryRetrieval">
            <Headers>
                <Header key="Content-Type">text/xml;charset=UTF-8</Header>
                <Header key="SOAPAction">getAllEquipment</Header>
                <Header key="Accept-Encoding">gzip,deflate</Header>
            </Headers>
            <Data pid="101" />
        </Request>
        <Response statusCode="201">
            <Content pid="301" />
        </Response>
    </Connection>
</Session>
```

**Parameters:**
- 101: Contains SOAP XML request body
- 201: Receives status line
- 301: Receives SOAP XML response

## Example: POST with Form Parameters

Form-encoded login request:

```xml
<Session id="101" name="postExample">
    <Connection id="1" name="postExampleConnection">
        <Request verb="POST" url="API/v0/Soap.asmx/Connect">
            <Parameters>
                <Parameter key="Connection" pid="3" />
                <Parameter key="Login" pid="40" />
                <Parameter key="Password" pid="42" />
            </Parameters>
            <Headers>
                <Header key="Content-Type">application/x-www-form-urlencoded</Header>
            </Headers>
        </Request>
        <Response statusCode="201">
            <Content pid="301" />
        </Response>
    </Connection>
</Session>
```

**Resulting request body:**
```
Connection=value3&Login=admin&Password=YOUR_PASSWORD_HERE
```

The rendered request body above is illustrative only. Never store or publish real credentials in examples, defaults, URLs, logs, or test fixtures.

## Internal Flow: Button Click to Response

Understanding how HTTP requests flow through DataMiner processes.

### Protocol Structure

```
Parameter (button) → Trigger (change) → Action (execute) → Group (session)
```

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        SLProtocol Process                        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │ SetParameter │───▶│ Main Entry   │───▶│ Main Queue   │       │
│  │    Thread    │    │    Point     │    │ (Groups)     │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│                             │                    │               │
│                             │ (blocked during    │               │
│                             │  processing)       ▼               │
│                             │           ┌──────────────┐        │
│                             │           │   Session    │        │
│                             │           │   Content    │        │
│                             │           └──────────────┘        │
└─────────────────────────────┼───────────────────┼───────────────┘
                              │                   │
                              │                   ▼
                    ┌─────────────────────────────────────────────┐
                    │                 SLPort Process               │
                    │  ┌──────────────────────────────────────┐   │
                    │  │   Request Queue (per IP:port)         │   │
                    │  └──────────────────────────────────────┘   │
                    │                      │                       │
                    │                      ▼                       │
                    │  ┌──────────────────────────────────────┐   │
                    │  │              WINHTTP                  │   │
                    │  └──────────────────────────────────────┘   │
                    └──────────────────────┼──────────────────────┘
                                           │
                                           ▼
                                   ┌──────────────┐
                                   │ Data Source  │
                                   │   (Server)   │
                                   └──────────────┘
```

### Step-by-Step Flow

1. **Button Click**
   - User clicks button (write parameter)
   - SET added to SetParameter thread queue
   - Triggers change on write parameter
   - Main entry point locked

2. **Group Added to Queue**
   - Trigger fires Action
   - Action adds Group to main queue
   - Entry point released (group just added, not executed)

3. **Group Execution**
   - Group ready to execute
   - Main entry point locked again
   - Session content passed to SLPort

4. **SLPort Processing**
   - Request added to IP:port queue
   - Multiple elements to same IP:port share this queue
   - WINHTTP executes request

5. **Response Handling**
   - Response received from server
   - Content stored in response parameter
   - QAction triggered (if configured)
   - QAction must complete before:
     - Group removed from main queue
     - Request removed from SLPort queue
     - Entry point released

### Key Implications

- **Blocking**: Entry point blocked during request = no other interactions via that entry point
- **Shared Queue**: Long requests to IP:port block all elements polling same destination
- **QAction Timing**: Response QAction runs before group completes

## HTTPS And Certificate Validation

- Keep TLS certificate verification enabled by default.
- Prefer a trusted certificate over `SkipCertificateVerification`.
- Do not configure `SkipCertificateVerification/DefaultValue` as `true` for generic development convenience.
- Custom C# certificate callbacks must validate `SslPolicyErrors` and must never always return `true` (`SLC_SC0005`).
- Any target-specific bypass requires explicit approval, documented risk, and the narrowest possible scope.

## Parallel Processing with Threads

Enable parallel queues for different connections:

```xml
<Threads>
    <Thread connection="0" />   <!-- Queue via MAIN EntryPoint -->
    <Thread connection="1" />   <!-- Queue via 2nd EntryPoint -->
    <Thread connection="1001" /> <!-- Extra Queue via MAIN EntryPoint -->
</Threads>
```

This allows:
- Connection 0 requests processed independently from Connection 1
- Connection 1001 creates additional queue through main entry point
- True parallel processing of HTTP requests

## See Also

- [HTTP Fundamentals](http-fundamentals.md) - Session and connection concepts
- [HTTP Implementation](http-implementation.md) - Request/response details
- [Execution Flow](../../dataminer-connector-core/references/logic-execution-flow.md) - General execution flow
