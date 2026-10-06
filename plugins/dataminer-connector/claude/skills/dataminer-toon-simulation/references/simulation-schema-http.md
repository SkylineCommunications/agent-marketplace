# HTTP Simulation Schema

Defines the `.toon` simulation file structure for HTTP connectors. Every HTTP session and connection in the connector's `protocol.xml` must be represented, with response bodies informed by C# deserialization classes when available.

## Schema Structure

```
meta:                                    ← Required metadata
  connector: <name>
  version: <version>
  type: http
  generated: <ISO timestamp>
http:                                    ← HTTP simulation data
  sessions[N]:                           ← All HTTP sessions
    - id: <session id>
      name: <session name>
      connections[N]:                    ← Connections within session
        - id: <connection id>
          request:
            verb: <GET|POST|PUT|DELETE|PATCH>
            url: <request URL path>
          response:
            statusCode: 200
            contentType: application/json
            body: <JSON response as quoted string>
```

## Field Definitions

### meta (Required)

| Field | Type | Description |
|-------|------|-------------|
| `connector` | string | Protocol name from `<Protocol><Name>` |
| `version` | string | Protocol version from `<Protocol><Version>` |
| `type` | string | Always `http` for HTTP-only connectors |
| `generated` | string | ISO 8601 timestamp (quoted) |

### http.sessions (List Array)

Each item represents one `<Session>` from the `<HTTP>` block.

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Session ID from `<Session id="...">` |
| `name` | string | Session name from `<Session name="...">` |
| `connections` | list array | Connections within this session |

### connections (List Array)

Each item represents one `<Connection>` within a session.

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Connection ID from `<Connection id="...">` |
| `request` | object | Request definition |
| `response` | object | Simulated response |

### request Object

| Field | Type | Description |
|-------|------|-------------|
| `verb` | string | HTTP method: `GET`, `POST`, `PUT`, `DELETE`, `PATCH` |
| `url` | string | Request URL path from `<Request url="...">` (quoted if contains `:` or special chars) |

### response Object

| Field | Type | Description |
|-------|------|-------------|
| `statusCode` | number | HTTP status code (always `200` for simulation) |
| `contentType` | string | MIME type (typically `application/json`) |
| `body` | string | Complete JSON response body as a **single-line quoted string** |

## Response Body Encoding

Since TOON does not have multi-line string literals, JSON response bodies are stored as single-line quoted strings:

```toon
body: "{\"status\":\"online\",\"uptime\":86400}"
```

Rules for the body value:
- Always quoted (contains `{`, `:`, `"`, etc.)
- Internal double quotes escaped as `\"`
- No literal newlines — JSON must be on one line
- Must be syntactically valid JSON

## Extraction Rules

### Step 1: Find All HTTP Sessions

Locate the `<HTTP>` block in protocol.xml:

```xml
<HTTP>
  <Session id="1" name="Get Device Status">
    <Connection id="1">
      <Request verb="GET" url="/api/v1/status" />
      <Response statusCode="100">
        <Content pid="200" />
      </Response>
    </Connection>
  </Session>
  <Session id="2" name="Get Interfaces">
    <Connection id="1">
      <Request verb="GET" url="/api/v1/interfaces" />
      <Response statusCode="100">
        <Content pid="300" />
      </Response>
    </Connection>
  </Session>
</HTTP>
```

### Step 2: Extract Request Details

For each `<Connection>`:
- `verb` from `<Request verb="...">`
- `url` from `<Request url="...">`
- If URL contains parameter references (e.g., `url="/api/v1/device/{pid:50}"`), keep as-is with the parameter reference notation

### Step 3: Identify Response Content PIDs

The `<Response><Content pid="...">` tells you which parameter receives the raw response. Cross-reference this PID:

- **Single param (no table parsing)** → response is a JSON object or scalar
- **Param triggers QAction that fills a table** → response is a JSON array of objects
- **Multiple Content PIDs** → response contains multiple pieces of data

### Step 4: Inspect C# Deserialization Classes

**This step produces the most accurate response bodies.** Search QAction C# files for:

1. **Current SecureCoding pattern**:
   ```csharp
   SecureNewtonsoftDeserialization.DeserializeObject<DeviceStatus>(responseBody)
   SecureNewtonsoftDeserialization.DeserializeObject<List<InterfaceInfo>>(responseBody)
   ```

2. **Legacy direct Newtonsoft patterns**:
   ```csharp
   JsonConvert.DeserializeObject<DeviceStatus>(responseBody)
   JsonConvert.DeserializeObject<List<InterfaceInfo>>(responseBody)
   ```

   Treat these only as signatures to recognize while inspecting existing code. Do not generate direct `JsonConvert.DeserializeObject` calls.

3. **System.Text.Json patterns**:
   ```csharp
   JsonSerializer.Deserialize<DeviceStatus>(responseBody)
   ```

4. **Target class definitions** — find the class and extract its structure:
   ```csharp
   public class DeviceStatus
   {
       [JsonProperty("status")]
       public string Status { get; set; }

       [JsonProperty("uptime_seconds")]
       public long UptimeSeconds { get; set; }

       [JsonProperty("firmware")]
       public string Firmware { get; set; }

       [JsonProperty("interfaces")]
       public List<InterfaceInfo> Interfaces { get; set; }
   }

   public class InterfaceInfo
   {
       [JsonProperty("id")]
       public int Id { get; set; }

       [JsonProperty("name")]
       public string Name { get; set; }

       [JsonProperty("speed_mbps")]
       public int SpeedMbps { get; set; }

       [JsonProperty("status")]
       public string Status { get; set; }
   }
   ```

### Step 5: Map C# Class to JSON Body

| C# Type | JSON Value | Example |
|---------|-----------|---------|
| `string` | Realistic string based on property name | `"eth0"`, `"online"` |
| `int`, `long` | Realistic number based on property name | `86400`, `1000` |
| `bool` | `true` or `false` | `true` |
| `double`, `float`, `decimal` | Decimal number | `99.5` |
| `List<T>`, `T[]` | Array with 3 items of type T | `[{...},{...},{...}]` |
| Nested class | Nested object with all properties | `{"id":1,"name":"..."}` |
| `DateTime` | ISO string | `"2026-07-08T12:00:00Z"` |

### Step 6: Determine JSON Key Names

Priority order for JSON property names:
1. `[JsonProperty("name")]` attribute value (exact API field name)
2. `[JsonPropertyName("name")]` attribute value (System.Text.Json)
3. C# property name in camelCase (if no attribute)

### Step 7: When No C# Class is Found

If no deserialization class can be identified for a response:
1. Look at the parameter names that receive parsed values from this response
2. Use those names as JSON keys
3. Generate values using the data generation heuristics

## Complete Example

Given a connector with two HTTP sessions and these C# classes:

```csharp
public class DeviceInfo
{
    [JsonProperty("hostname")]
    public string Hostname { get; set; }

    [JsonProperty("model")]
    public string Model { get; set; }

    [JsonProperty("uptime")]
    public long Uptime { get; set; }

    [JsonProperty("cpu_usage")]
    public double CpuUsage { get; set; }
}

public class PortEntry
{
    [JsonProperty("port_id")]
    public int PortId { get; set; }

    [JsonProperty("label")]
    public string Label { get; set; }

    [JsonProperty("speed")]
    public long Speed { get; set; }

    [JsonProperty("admin_state")]
    public string AdminState { get; set; }
}
```

Generated simulation file:

```toon
meta:
  connector: Acme - Media Gateway 2000
  version: 1.0.0.2
  type: http
  generated: "2026-07-08T12:00:00Z"
http:
  sessions[2]:
    - id: 1
      name: Get Device Info
      connections[1]:
        - id: 1
          request:
            verb: GET
            url: /api/v1/device
          response:
            statusCode: 200
            contentType: application/json
            body: "{\"hostname\":\"gateway-01\",\"model\":\"MG-2000\",\"uptime\":86400,\"cpu_usage\":23.5}"
    - id: 2
      name: Get Ports
      connections[1]:
        - id: 1
          request:
            verb: GET
            url: /api/v1/ports
          response:
            statusCode: 200
            contentType: application/json
            body: "[{\"port_id\":1,\"label\":\"Port 1\",\"speed\":10000000000,\"admin_state\":\"enabled\"},{\"port_id\":2,\"label\":\"Port 2\",\"speed\":10000000000,\"admin_state\":\"enabled\"},{\"port_id\":3,\"label\":\"Port 3\",\"speed\":1000000000,\"admin_state\":\"disabled\"}]"
```

## Multiple Connections Per Session

When a session has multiple connections (e.g., pagination or multi-step auth):

```toon
http:
  sessions[1]:
    - id: 1
      name: Get Paginated Data
      connections[2]:
        - id: 1
          request:
            verb: GET
            url: /api/v1/items?page=1
          response:
            statusCode: 200
            contentType: application/json
            body: "{\"items\":[{\"id\":1,\"name\":\"Item 1\"},{\"id\":2,\"name\":\"Item 2\"}],\"total\":4,\"page\":1}"
        - id: 2
          request:
            verb: GET
            url: /api/v1/items?page=2
          response:
            statusCode: 200
            contentType: application/json
            body: "{\"items\":[{\"id\":3,\"name\":\"Item 3\"},{\"id\":4,\"name\":\"Item 4\"}],\"total\":4,\"page\":2}"
```

## Validation Checklist

Before completing output, verify:

- [ ] `meta.type` is `http`
- [ ] Every `<Session>` from protocol.xml `<HTTP>` block is represented
- [ ] Every `<Connection>` within each session is represented
- [ ] `sessions[N]` count matches actual session list items
- [ ] `connections[N]` count matches actual connection list items per session
- [ ] All `verb` and `url` values come directly from protocol.xml (never invented)
- [ ] All `body` values are valid JSON (parseable)
- [ ] All `body` values are properly quoted with internal `\"` escaping
- [ ] Response body structure matches discovered C# class (when found)
- [ ] Response body structure has realistic values matching property names/types
- [ ] `generated` timestamp is quoted
- [ ] No trailing spaces on any line
