# JSON Parsing & HTTP Response Patterns

Reference for JSON deserialization, dynamic parsing, HTTP response handling, and DateTime conversion patterns in QActions.

> **Parent skill**: `dataminer-qaction/SKILL.md` — return there for core QAction rules and table fill methods.

---

## JSON Parsing (SecureCoding)

Most HTTP connectors parse untrusted JSON responses. Add `Skyline.DataMiner.Utils.SecureCoding` and use `SecureNewtonsoftDeserialization`; keep `Newtonsoft.Json` only for model attributes and token types. See `dataminer-nugets/references/skyline-dataminer-utils-securecoding.md`.

### Deserialize to Typed Model

```csharp
using Newtonsoft.Json;
using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

string rawJson = Convert.ToString(protocol.GetParameter(Parameter.rawresponse));
var response = SecureNewtonsoftDeserialization.DeserializeObject<DeviceStatusResponse>(rawJson);
if (response == null)
{
    return;
}

protocol.SetParameter(Parameter.devicestatus, response.Status);
```

### Dynamic Parsing with JObject

```csharp
using Newtonsoft.Json.Linq;
using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

string rawJson = Convert.ToString(protocol.GetParameter(Parameter.rawresponse));
JObject json = SecureNewtonsoftDeserialization.DeserializeObject<JObject>(rawJson);
if (json == null)
{
    return;
}

string name = json["device"]?["name"]?.ToString() ?? String.Empty;
JArray items = json["items"] as JArray ?? new JArray();
```

### End-to-End: JSON to Table Fill

```csharp
// Trigger: after HTTP group completes -> read raw response -> fill table
string rawJson = Convert.ToString(protocol.GetParameter(Parameter.rawresponse));
var items = SecureNewtonsoftDeserialization.DeserializeObject<List<DeviceItem>>(rawJson);

if (items == null || items.Count == 0)
{
    protocol.FillArray(Parameter.Itemstable.tablePid, new object[] { Array.Empty<object>() });
    return;
}

object[] keys = new object[items.Count];
object[] names = new object[items.Count];
object[] values = new object[items.Count];

for (int i = 0; i < items.Count; i++)
{
    keys[i] = items[i].Id;
    names[i] = items[i].Name;
    values[i] = items[i].Value;
}

protocol.FillArray(Parameter.Itemstable.tablePid, new object[] { keys, names, values });
```

### Nested JSON with SelectToken

```csharp
JObject root = SecureNewtonsoftDeserialization.DeserializeObject<JObject>(rawJson);
JToken channels = root?.SelectToken("data.channels");
if (channels != null)
{
    foreach (JToken ch in channels)
    {
        string id = ch["id"]?.ToString();
        double power = ch["power"]?.Value<double>() ?? 0.0;
    }
}
```

---

## HTTP Response Parsing Pattern

Standard pattern for HTTP connectors: trigger after poll group -> read raw -> parse -> fill.

**XML side** (coordinate with XML author):
1. HTTP Session stores raw response in a parameter (e.g., pid 100).
2. Trigger fires after group completes.
3. Trigger executes action that runs the QAction.

**QAction side (generated-helper variant):**

```csharp
public static void Run(SLProtocolExt protocol)
{
    try
    {
        // 1. Read raw response
        string rawJson = Convert.ToString(protocol.GetParameter(Parameter.rawresponse));
        if (String.IsNullOrEmpty(rawJson))
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Empty response", LogType.Error, LogLevel.NoLogging);
            return;
        }

        // 2. Check HTTP status code (if stored in a parameter)
        int statusCode = Convert.ToInt32(protocol.GetParameter(Parameter.httpstatuscode));
        if (statusCode != 200)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|HTTP {statusCode}", LogType.Error, LogLevel.NoLogging);
            return;
        }

        // 3. Deserialize
        var data = SecureNewtonsoftDeserialization.DeserializeObject<ApiResponse>(rawJson);
        if (data == null)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Response did not contain the expected object.", LogType.Error, LogLevel.NoLogging);
            return;
        }

        // 4. Populate standalone parameters
        protocolExt.Devicename = data.DeviceName;
        protocolExt.Firmwareversion = data.FirmwareVersion;

        // 5. Fill table (column-oriented)
        if (data.Channels != null && data.Channels.Count > 0)
        {
            object[] keys = new object[data.Channels.Count];
            object[] names = new object[data.Channels.Count];
            // ... build column arrays ...
            protocol.FillArray(Parameter.Channelstable.tablePid, new object[] { keys, names });
        }
    }
    catch (Exception ex)
    {
        protocol.Log($"QA{protocol.QActionID}|Run|Response parsing failed ({ex.GetType().Name}).", LogType.Error, LogLevel.NoLogging);
    }
}
```

---

## DateTime Handling

### Parse ISO 8601

```csharp
DateTime dt = DateTime.ParseExact(
    value,
    "yyyy-MM-ddTHH:mm:ssZ",
    CultureInfo.InvariantCulture,
    DateTimeStyles.AdjustToUniversal);
```

### Unix Epoch Conversion

```csharp
// Seconds since epoch
DateTime dt = DateTimeOffset.FromUnixTimeSeconds(epochSeconds).UtcDateTime;

// Milliseconds since epoch
DateTime dt = DateTimeOffset.FromUnixTimeMilliseconds(epochMs).UtcDateTime;
```

### OA Date for DataMiner Parameters

DataMiner stores date/time parameters as OLE Automation dates (doubles):

```csharp
double oaDate = DateTime.UtcNow.ToOADate();
protocol.SetParameter(Parameter.lastpolledtime, oaDate);
```

### Multiple Format Parsing

```csharp
string[] formats = { "yyyy-MM-ddTHH:mm:ssZ", "yyyy-MM-dd HH:mm:ss", "MM/dd/yyyy" };
if (DateTime.TryParseExact(value, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime result))
{
    protocol.SetParameter(Parameter.timestamp, result.ToOADate());
}
```
