# Secure JSON Parsing

Process untrusted JSON responses through `Skyline.DataMiner.Utils.SecureCoding`, not direct Newtonsoft deserialization.

## Required Packages

```xml
<PackageReference Include="Skyline.DataMiner.Utils.SecureCoding" Version="2.2.3" />
<PackageReference Include="Skyline.DataMiner.Utils.SecureCoding.Analyzers" Version="2.2.3">
	<PrivateAssets>all</PrivateAssets>
	<IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
</PackageReference>
```

The captured versions are examples. Select versions compatible with the connector's target DataMiner and existing dependency graph.

The runtime API and analyzer are different packages:

- `Skyline.DataMiner.Utils.SecureCoding` provides `SecureNewtonsoftDeserialization`.
- `Skyline.DataMiner.Utils.SecureCoding.Analyzers` reports insecure patterns such as direct Newtonsoft deserialization (`SLC_SC0004`).

See `dataminer-nugets/references/skyline-dataminer-utils-securecoding.md`.

## Deserialize to a Typed Object

```csharp
using Newtonsoft.Json;

using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

public class DeviceStatus
{
	public string Name { get; set; }

	public bool Online { get; set; }

	public int Temperature { get; set; }
}

public static void Run(SLProtocol protocol)
{
	string rawJson = Convert.ToString(protocol.GetParameter(200));
	DeviceStatus status = SecureNewtonsoftDeserialization.DeserializeObject<DeviceStatus>(rawJson);
	if (status == null)
	{
		protocol.Log($"QA{protocol.QActionID}|Run|The response did not contain a device status.", LogType.Error, LogLevel.NoLogging);
		return;
	}

	protocol.SetParameters(
		new int[] { Parameter.devicename, Parameter.online, Parameter.temperature },
		new object[] { status.Name, status.Online ? 1 : 0, status.Temperature });
}
```

`JsonProperty` remains available for mapping external field names:

```csharp
public class DeviceInfo
{
	[JsonProperty("device_name")]
	public string DeviceName { get; set; }

	[JsonProperty("is_online")]
	public bool IsOnline { get; set; }
}
```

## Deserialize Arrays

```csharp
List<DeviceStatus> devices =
	SecureNewtonsoftDeserialization.DeserializeObject<List<DeviceStatus>>(rawJson);

if (devices == null)
{
	devices = new List<DeviceStatus>();
}
```

## JSON Token Models

When a fixed DTO is not practical, deserialize the token model through the same secure entry point:

```csharp
JObject root = SecureNewtonsoftDeserialization.DeserializeObject<JObject>(rawJson);
JToken channels = root?.SelectToken("data.channels");
if (channels != null)
{
	foreach (JToken channel in channels)
	{
		string id = channel["id"]?.ToString();
		double power = channel["power"]?.Value<double>() ?? 0.0;
	}
}
```

Do not call `JsonConvert.DeserializeObject`, `JObject.Parse`, or `JArray.Parse` as a shortcut around the secure wrapper.

## Custom Settings

The secure wrapper supports `JsonSerializerSettings`, but requires `TypeNameHandling.None` and removes unsafe binders:

```csharp
var settings = new JsonSerializerSettings
{
	NullValueHandling = NullValueHandling.Ignore,
	TypeNameHandling = TypeNameHandling.None,
};

DeviceStatus data =
	SecureNewtonsoftDeserialization.DeserializeObject<DeviceStatus>(rawJson, settings);
if (data == null)
{
	return;
}
```

For a model that genuinely requires polymorphism, use the overload that accepts an explicit known-types allowlist. Never enable unrestricted type resolution.

## Failure Handling

- Validate empty input before parsing.
- Treat a `null` result or missing required property as invalid external data.
- Catch parsing exceptions at the QAction boundary.
- Log the endpoint/session label and a sanitized failure category such as `ex.GetType().Name`; do not log exception text or the raw body when either can expose credentials or sensitive response values.
- Leave existing parameter/table state unchanged when parsing fails unless the connector's requirements define a different failure state.

## Documentation

- SecureCoding package: <https://www.nuget.org/packages/Skyline.DataMiner.Utils.SecureCoding>
- Analyzer rule SLC_SC0004: <https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.SecureCoding/blob/main/docs/Rules/SLC_SC0004.md>

## See Also

- [HTTP Implementation](http-implementation.md) - Processing HTTP responses
- [QActions](../../dataminer-connector-core/references/logic-qactions.md) - QAction fundamentals
