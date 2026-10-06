# HTTP Implementation

Detailed implementation of HTTP requests and responses in DataMiner connectors.

## Request Definition

### Basic Structure

```xml
<Request verb="GET" url="/api/data">
    <Headers>
        <Header key="Accept">application/json</Header>
    </Headers>
</Request>
```

### Request Attributes

| Attribute | Required | Description |
|-----------|----------|-------------|
| `verb` | Yes | HTTP method: GET, POST, PUT, PATCH, DELETE, etc. |
| `url` | Yes* | Request path (can include query string) |
| `pid` | No | Parameter ID containing URL (alternative to `url`) |

*Either `url` or `pid` required.

### URL Construction & Base Path Concatenation

DataMiner automatically constructs the full request URL by concatenating:

```
http://<Element IP Address>:<Port>/<url attribute value>
```

You only define the **path** portion (optionally including query string and fragment). The scheme, host, and port come from the element connection settings configured in the element wizard.

**Key rules:**
- The `url` attribute value is the path segment only (e.g. `/api/v1/status` or `v1/status`)
- When using `pid`, the referenced parameter value does **not** need a leading slash (`/`)
- If **both** `url` and `pid` are specified on the same `<Request>`, the `pid` attribute is **ignored** — only `url` is used. Always specify only one.
- The `url` attribute can include a query string (e.g. `url="/api/data?format=json"`)
- The parameter referenced by `pid` must be of type `string`

### URL Options

**Static URL:**
```xml
<Request verb="GET" url="/api/v1/status" />
```

**Dynamic URL from parameter:**
```xml
<Request verb="GET" pid="100" />
<!-- Parameter 100 contains: "api/v1/status" (no leading slash needed) -->
```

**Absolute URL (use sparingly):**
```xml
<Request verb="GET" url="http://other-server.com/api/data" />
```

**Warning**: Absolute URLs to different hosts cause element timeout if that host is unavailable. Use only when there is no other option.

## HTTP Methods (Verbs)

| Verb | Use Case |
|------|----------|
| `GET` | Retrieve data |
| `POST` | Create resource, submit data |
| `PUT` | Replace resource |
| `PATCH` | Partial update |
| `DELETE` | Remove resource |

## Request Headers

### Static Header Value

```xml
<Headers>
    <Header key="Content-Type">application/json</Header>
    <Header key="Accept">application/json</Header>
</Headers>
```

### Dynamic Header from Parameter

```xml
<Headers>
    <Header key="Authorization" pid="50" />
</Headers>
<!-- Parameter 50 contains: "Bearer eyJ..." -->
```

`Header@key` is required. For a documented vendor-specific header, retain the key and use a justified `SuppressValidator 8.3.1` comment if the validator does not recognize it. Never use a keyless `<Header pid="..."/>`, and never put `"HeaderName: value"` into the referenced parameter.

Credential parameters must be password-masked, must not contain source-controlled secret defaults, and must never be written to logs.

### Common Headers

| Header | Purpose | Example |
|--------|---------|---------|
| `Content-Type` | Request body format | `application/json` |
| `Accept` | Expected response format | `application/json` |
| `Authorization` | Authentication | `Bearer token123` |
| `Accept-Encoding` | Compression support | `gzip,deflate` |
| `SOAPAction` | SOAP operation | `getAllEquipment` |

## Request Body

Two options: `<Data>` or `<Parameters>`. **Do not use both** - only `<Parameters>` will be sent.

### Using Data Tag

For raw body content (JSON, XML, etc.):

```xml
<Request verb="POST" url="/api/data">
    <Headers>
        <Header key="Content-Type">application/json</Header>
    </Headers>
    <Data pid="101" />
</Request>
```

Parameter 101 contains the JSON body:
```json
{"name": "Device1", "status": "active"}
```

**Behavior by verb:**
- **GET**: Data appended to URL (query string)
- **POST/PUT/PATCH**: Data placed in request body

### Using Parameters Tag

For form-encoded data:

```xml
<Request verb="POST" url="/api/login">
    <Headers>
        <Header key="Content-Type">application/x-www-form-urlencoded</Header>
    </Headers>
    <Parameters>
        <Parameter key="username" pid="40" />
        <Parameter key="password" pid="42" />
    </Parameters>
</Request>
```

**Result (POST):**
```
username=admin&password=YOUR_PASSWORD_HERE
```

**Result (GET):**
```
/api/login?username=admin&password=YOUR_PASSWORD_HERE
```

### Static Parameter Values

```xml
<Parameters>
    <Parameter key="format">json</Parameter>
    <Parameter key="version">2</Parameter>
</Parameters>
```

## URL Encoding

**Important**: DataMiner does NOT automatically encode data.

For `application/x-www-form-urlencoded` or query strings, you MUST ensure proper URL encoding to avoid misinterpretation of reserved characters (`&`, `=`, `?`, etc.).

Use QAction to encode before setting parameter:
```csharp
string encoded = Uri.EscapeDataString(rawValue);
protocol.SetParameter(101, encoded);
```

## Response Definition

### Basic Structure

```xml
<Response statusCode="100">
    <Headers>
        <Header key="Content-Type" pid="102" />
    </Headers>
    <Content pid="200" />
</Response>
```

### Response Attributes

| Attribute | Description |
|-----------|-------------|
| `statusCode` | Parameter ID to store status line (e.g., "HTTP/1.1 200 OK") |

### Capturing Response Parts

**Status Line:**
```xml
<Response statusCode="100">
<!-- Parameter 100 receives: "HTTP/1.1 200 OK" -->
```

**Response Headers:**
```xml
<Headers>
    <Header key="Content-Type" pid="101" />
    <Header key="X-Custom-Header" pid="102" />
</Headers>
```

**Response Body:**
```xml
<Content pid="200" />
<!-- Parameter 200 receives the full response body -->
```

## Multiple Connections per Session

A session can contain multiple sequential requests:

```xml
<Session id="1" name="Multi-step API">
    <Connection id="1" name="Authenticate">
        <Request verb="POST" url="/api/login">
            <Data pid="10" />
        </Request>
        <Response statusCode="100">
            <Content pid="200" />
        </Response>
    </Connection>
    <Connection id="2" name="Get Data">
        <Request verb="GET" url="/api/data">
            <Headers>
                <Header key="Authorization" pid="50" />
            </Headers>
        </Request>
        <Response statusCode="101">
            <Content pid="201" />
        </Response>
    </Connection>
</Session>
```

Connections execute sequentially within the same session (same TCP connection).

## Integration with Groups

### Polling Group

```xml
<Group id="1">
    <Name>Poll API</Name>
    <Type>poll</Type>
    <Content>
        <Session>1</Session>
    </Content>
</Group>
```

### With Timer

```xml
<Timer id="1">
    <Name>API Polling [30s]</Name>
    <Time initial="true">30000</Time>
    <Content>
        <Group>1</Group>
    </Content>
</Timer>
```

### Triggered by Button

```xml
<Trigger id="1">
    <On id="100">parameter</On>
    <Time>change</Time>
    <Type>action</Type>
    <Content>
        <Id>1</Id>
    </Content>
</Trigger>

<Action id="1">
    <On id="1">group</On>
    <Type>execute next</Type>
</Action>
```

## Processing Response with QAction

```xml
<Param id="200">
    <Name>API Response</Name>
    <Type>read</Type>
    <Interprete>
        <RawType>other</RawType>
        <Type>string</Type>
        <LengthType>next param</LengthType>
    </Interprete>
</Param>

<QAction id="200" triggers="200">
<![CDATA[
using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

public static void Run(SLProtocol protocol)
{
    string json = Convert.ToString(protocol.GetParameter(200));
    var data = SecureNewtonsoftDeserialization.DeserializeObject<MyResponse>(json);
    if (data == null)
    {
        return;
    }

    // Process data...
}
]]>
</QAction>
```

Add the `Skyline.DataMiner.Utils.SecureCoding` runtime package and retain `Skyline.DataMiner.Utils.SecureCoding.Analyzers`. Direct `JsonConvert.DeserializeObject` calls trigger `SLC_SC0004`.

## Custom Redirect Handling

Disable auto-redirect:

```xml
<Type communicationOptions="customRedirect">http</Type>
```

Then handle redirect in QAction:
```csharp
string statusLine = Convert.ToString(protocol.GetParameter(100));
if (statusLine.Contains("301") || statusLine.Contains("302"))
{
    string location = Convert.ToString(protocol.GetParameter(101)); // Location header
    protocol.SetParameter(Parameters.dynamicUrl, location);
    protocol.CheckTrigger(TriggerIds.executeRedirect);
}
```

## See Also

- [HTTP Fundamentals](http-fundamentals.md) - Session structure and authentication
- [HTTP Configuration](http-configuration.md) - Dynamic IP and HTTPS
- [HTTP Examples](http-examples.md) - Complete implementation examples
