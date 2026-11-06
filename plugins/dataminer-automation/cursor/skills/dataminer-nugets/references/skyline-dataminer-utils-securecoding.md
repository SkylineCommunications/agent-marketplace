# Skyline.DataMiner.Utils.SecureCoding

Use `Skyline.DataMiner.Utils.SecureCoding` when a connector or Automation project must deserialize untrusted JSON or use another runtime security helper. This runtime package is separate from `Skyline.DataMiner.Utils.SecureCoding.Analyzers`.

## Verified Package

- Package: `Skyline.DataMiner.Utils.SecureCoding`
- Captured version: `2.2.3`
- Package URL: <https://www.nuget.org/packages/Skyline.DataMiner.Utils.SecureCoding/2.2.3>
- Package SHA-256: `0b66bf89f86c1ccca94cff57dd0a70e476c0c23e6a54a9083bed30651252273e`
- Source repository: <https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.SecureCoding>
- Source commit: `b96f484b019eaad342489ba375e99bc4c114476b`
- Target framework in the captured package: `netstandard2.0`

The captured version is a maintenance baseline, not a universal version requirement. Select a package version compatible with the task's target DataMiner and project dependency graph.

## Package References

Add the runtime and analyzer packages to a project that deserializes JSON:

```xml
<PackageReference Include="Skyline.DataMiner.Utils.SecureCoding" Version="2.2.3" />
<PackageReference Include="Skyline.DataMiner.Utils.SecureCoding.Analyzers" Version="2.2.3">
	<PrivateAssets>all</PrivateAssets>
	<IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
</PackageReference>
```

Retain the analyzer package when the template already supplies it; do not add a duplicate reference. Do not replace the runtime package with the analyzer package: analyzers report insecure usage but do not provide `SecureNewtonsoftDeserialization`.

## Secure Newtonsoft Deserialization

Import:

```csharp
using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;
```

Deserialize a simple typed object:

```csharp
DeviceStatus response = SecureNewtonsoftDeserialization.DeserializeObject<DeviceStatus>(rawJson);
if (response == null)
{
	return;
}
```

Deserialize a list:

```csharp
List<DeviceStatus> responses =
	SecureNewtonsoftDeserialization.DeserializeObject<List<DeviceStatus>>(rawJson);
if (responses == null)
{
	responses = new List<DeviceStatus>();
}
```

Deserialize a JSON token model:

```csharp
JObject response = SecureNewtonsoftDeserialization.DeserializeObject<JObject>(rawJson);
if (response == null)
{
	return;
}
```

The basic overload forces `TypeNameHandling.None`. Overloads accepting `JsonSerializerSettings` also reject unsafe `TypeNameHandling` values and clear unsafe binders. Overloads for polymorphic models require an explicit known-types allowlist.

Always check for a `null` result and missing required members before using the object. Catch parsing exceptions at the QAction boundary, log diagnostic details without payload secrets, and leave existing table/state data unchanged when parsing fails.

The [compilable secure JSON example](examples/securecoding-json/DeviceStatusParser.cs) and its [project file](examples/securecoding-json/SecureCodingJsonExample.csproj) exercise the runtime API with both analyzer packages enabled.

## Analyzer Contracts

- `SLC_SC0004`: Do not call `JsonConvert.DeserializeObject` directly. Use `SecureNewtonsoftDeserialization.DeserializeObject`.
- `SLC_SC0005`: A custom `ServerCertificateCustomValidationCallback` must not always return `true`. Accept a certificate only when `SslPolicyErrors.None` or when a separately approved validation policy succeeds.

Do not suppress these warnings merely to make a build pass.

### Analyzer Compiler Compatibility

`CS9057` means the analyzer assembly references a newer Roslyn compiler than the active SDK provides. Suppressing `CS9057` hides the load failure and can leave the build without `SLC_SC0004` or `SLC_SC0005` analysis.

Use a compatible SDK/compiler, or select an analyzer version compatible with the project's approved toolchain and target DataMiner dependency set. The captured analyzer 2.2.3 references Roslyn 4.14 and the repository validation therefore uses .NET SDK 10. Do not report a security-analyzer gate as successful while `CS9057` remains.

## Secret Handling

- Never log passwords, bearer tokens, cookies, API keys, complete Authorization headers, or response bodies that can contain credentials.
- Log a stable endpoint/session label, status code, and sanitized error category instead.
- Do not store real or placeholder secrets in source-controlled `DefaultValue` elements.
- Use password-masked DataMiner parameters or the appropriate credential store for user-provided secrets.
- Keep TLS certificate verification enabled. Any environment-specific exception requires an explicit user requirement, documented risk, and the narrowest possible scope.

## Validation

After adding or changing this package:

```text
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>" --warnaserror
```

The build must contain no unresolved `SLC_SC0004` or `SLC_SC0005` diagnostics.
