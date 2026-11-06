# IDms API Cheatsheet (Verified)

All members below were verified against the official API docs at
`https://docs.dataminer.services/develop/api/types/Skyline.DataMiner.Core.DataMinerSystem.Common.<TypeName>.html`.
Do not use IDms members that are not listed here without first verifying them on that docs site.

## IDms (the DataMiner System)

Properties: `Communication`, `ElementPropertyDefinitions`, `ServicePropertyDefinitions`, `ViewPropertyDefinitions`.

Methods:

| Member | Purpose |
|--------|---------|
| `GetElements()` | All elements in the DMS (`ICollection<IDmsElement>`); filter with LINQ |
| `GetElement(string name)` / `GetElement(DmsElementId id)` | Single element by name or AgentId/ElementId |
| `GetElementReference(DmsElementId)` | Lightweight reference without a server round-trip |
| `ElementExists(string)` / `ElementExists(DmsElementId)` | Existence check |
| `GetAgents()` / `GetAgent(int)` / `AgentExists(int)` / `GetAgentReference(int)` | DataMiner Agents (`IDma`) |
| `GetProtocols()` / `GetProtocol(string name, string version)` / `ProtocolExists(string, string)` | Connectors/protocols (`IDmsProtocol`); version can be `"Production"` |
| `GetScripts()` / `GetScript(string)` / `ScriptExists(string)` | Automation scripts (`IDmsAutomationScript`) |
| `GetViews()` / `GetView(string)` / `GetView(int)` / `ViewExists(...)` / `GetViewReference(int)` / `CreateView(ViewConfiguration)` | Views |
| `GetServices()` / `GetService(string)` / `GetService(DmsServiceId)` / `ServiceExists(...)` | Services |
| `GetAlarmTemplates()` / `GetStandaloneAlarmTemplates()` / `GetAlarmTemplateGroups()` / `GetTrendTemplates()` | Templates |
| `CreateProperty(string, PropertyType, bool, bool, bool)` / `DeleteProperty(int)` / `PropertyExists(string, PropertyType)` | Property definitions |
| `GetDmsInfo()` | DMS configuration info |
| `StartElementStateMonitor(...)` / `StartElementAlarmLevelMonitor(...)` / `StartElementNameMonitor(...)` / `StartServiceStateMonitor(...)` / `StartViewStateMonitor(...)` + matching `Stop*Monitor` | Subscription-based change monitors |

`GetElements()` has **no protocol filter parameter** — filter the result:

```csharp
var elements = dms.GetElements()
    .Where(e => string.Equals(e.Protocol.Name, "Microsoft Platform", StringComparison.OrdinalIgnoreCase))
    .ToList();
```

## IDmsElement

Properties: `AgentId`, `Id`, `DmsElementId`, `Name`, `Description`, `Protocol`, `State`, `Type`, `Host` (the hosting `IDma`), `Views`, `Properties`, `Connections`, `AlarmTemplate`, `TrendTemplate`, `AdvancedSettings`, `DveSettings`, `RedundancySettings`, `ReplicationSettings`, `FunctionSettings`, `SpectrumAnalyzer`.

The `DmsElementId` struct exposes `AgentId`, `ElementId`, and `Value` (the "agentId/elementId" string) — verified; use them for identity logging in tests and diagnostics.

Methods:

| Member | Purpose |
|--------|---------|
| `GetStandaloneParameter<T>(int pid)` | Standalone parameter handle; `T` ∈ `string`, `double?`, `int?`, `DateTime?` |
| `GetTable(int pid)` | Table handle (`IDmsTable`) |
| `Start()` / `Stop()` / `Pause()` / `Restart()` | Element lifecycle (asynchronous — poll afterwards) |
| `IsStartupComplete()` | True once the element finished starting; use in poll-wait loops |
| `Delete()` | Deletes the element and its data |
| `Duplicate(string newName, IDma agent)` | Clone the element |
| `GetAlarmLevel()` / `GetActiveAlarmCount()` / `GetActiveCriticalAlarmCount()` / `GetActiveMajorAlarmCount()` / `GetActiveMinorAlarmCount()` / `GetActiveWarningAlarmCount()` | Alarm info |
| `Exists()` (from `IDmsObject`) / `Update()` (from `IUpdateable`) | Existence check / push pending property changes |
| `StartStateMonitor(...)`, `StartAlarmLevelMonitor(...)`, `StartNameMonitor(...)` + `Stop*Monitor` | Per-element change monitors |

`ElementState` enum includes `Active`, `Paused`, `Stopped`, `Error` (and more — check the enum docs page if needed).

## IDmsStandaloneParameter\<T>

```csharp
var param = element.GetStandaloneParameter<double?>(350);
double? raw = param.GetValue();          // raw value
string display = param.GetDisplayValue(); // human-readable, with units/exceptions
element.GetStandaloneParameter<double?>(pid).SetValue(12.5); // write
```

For reads where the type is unknown or mixed, `GetStandaloneParameter<string>(pid).GetValue()` is a safe export format.

## IDmsTable

Properties: `Element`, `Id`, `IsPartial`.

| Member | Purpose |
|--------|---------|
| `GetRows()` | All rows as `object[][]` |
| `GetRow(string primaryKey)` / `RowExists(string)` | Single row |
| `GetPrimaryKeys()` / `GetDisplayKeys()` / `GetPrimaryKey(displayKey)` / `GetDisplayKey(primaryKey)` | Key handling |
| `GetColumn<T>(int columnPid)` | Column handle for cell-level reads; `T` ∈ `string`, `int?`, `double?`, `DateTime?` (same constraint as standalone params — see note) |
| `QueryData(IEnumerable<IColumnFilter>)` | Server-side filtered row retrieval — prefer over `GetRows()` for large tables |
| `AddRow(object[])` / `SetRow(string, object[])` / `DeleteRow(string)` / `DeleteRows(IEnumerable<string>)` | Mutations |
| `StartValueMonitor(...)` / `StopValueMonitor(...)` | Table change monitors |

> **`GetColumn<T>` accepts only `string`, `int?`, `double?`, `DateTime?` (verified — cost a QAOps run).** A non-nullable numeric type throws `System.NotSupportedException: Only one of the following types is supported: string, int?, double? or DateTime?`. Use the **nullable** form for numeric/date columns (`GetColumn<int?>(pid)`, `GetColumn<double?>(pid)`) and handle `null` (a row may have no value yet). A robust alternative that sidesteps the column-type constraint entirely is to read the whole row and index the cell: `object[] row = table.GetRow(primaryKey); var status = Convert.ToInt32(row[columnIndex]);` — `GetRow` returns `object[]` so any cell type is fine; just map the column index from the protocol's `ArrayOptions`/`ColumnOption` order.

## Executing Automation Scripts

```csharp
IDmsAutomationScript script = dms.GetScript("MyScriptName");
script.Execute(null, null, new DmsAutomationScriptRunOptions());
```

Pass parameter/dummy dictionaries instead of `null` when the script declares them. Script execution is asynchronous from the caller's perspective — verify outcomes (files, element state, parameter values) with a poll-wait loop, not immediately.

## Creating Elements

```csharp
IDma agent = dms.GetAgents().First();

// Pick the protocol VERSION deliberately. For version-bound work (PID maps, page layouts) do NOT
// use "Production": on shared/QAOps DaaS systems "Production" resolves to the pre-existing baseline's
// version (verified: Microsoft Platform 7.0.0.1-Prerelease004), NOT the version your Test Package's
// CatalogReferences installed (e.g. 1.1.3.20). Both coexist; create from the SPECIFIC version you
// need and assert it is installed first: dms.GetProtocols().Any(p => p.Version == "1.1.3.20").
IDmsProtocol protocol = dms.GetProtocol("Microsoft Platform", "1.1.3.20");
var config = new ElementConfiguration(dms, "My Test Element", protocol);
DmsElementId newId = agent.CreateElement(config);

// Poll until ready. CAUTION (verified): for a short window after CreateElement, dms.GetElement(newId)
// THROWS ElementNotFoundException (Skyline.DataMiner.Core.DataMinerSystem.Common) — the ID is assigned
// before the element is retrievable. Catch it INSIDE the poll loop and treat it as "not ready yet";
// never let the first GetElement escape:
IDmsElement element = null;
WaitFor(() =>
{
    try
    {
        IDmsElement e = dms.GetElement(newId);
        element = e;
        return e.State == ElementState.Active && e.IsStartupComplete();
    }
    catch (ElementNotFoundException) { return false; } // transient right after creation
}, TimeSpan.FromMinutes(3));
```

The protocol (connector) must already be installed on the DataMiner. On clean test systems (QAOps), add out-of-solution connectors as Catalog prerequisites in the Test Package — see `dataminer-qaops-integration-testing`.

Connection facts (re-verified 2026-06-12 — an earlier "virtual is always sufficient" claim here was **wrong** and cost 4 QAOps runs):

- **Released packages up to and including 1.2.0.x**: `ElementConfiguration(dms, name, protocol)` hard-codes a virtual connection that only works for virtual-connection connectors. For **serial** connectors (verified on Microsoft Platform 1.1.3.20, `<Type>serial</Type>`) the constructor throws **client-side** `IncorrectDataException: Invalid connection type provided at index 0` for **every** variant (default virtual, `new[] { new SerialConnection() }`, `new[] { new SerialConnection(new Tcp()) }`) — element creation for such connectors is not achievable on those versions.
- **Fixed in newer versions** (branch `AllConnectionTypesForElementCreation`, releases after 1.2.0.x): the plain constructor derives valid default connections from `protocol.ConnectionInfo` for all supported families (virtual, SNMPv1/v2/v3, HTTP, serial(+single), smart-serial(+single), GPIB, WebSocket, SLA), validation messages name expected-vs-provided types per index, and `IDmsElement.HasParameter(pid)` exists. Service/OPC/Grabber/AutoGenerated remain unsupported with explanatory errors. Check the package version before assuming either behavior.
- Before building connections, inspect what the protocol declares via `protocol.ConnectionInfo` (verified `IDmsProtocol` member) and, when elements of the protocol exist, log their `element.Connections` entries (`connection.GetType().FullName` + `Id`) — include both in any creation-failure diagnostics.
- **Fixture strategy that works on empty AND pre-populated systems** (required on ≤1.2.0.x for non-virtual connectors):
  1. Try `ElementConfiguration` (on fixed versions this covers all supported families).
  2. On `IncorrectDataException`: if an element of the protocol already exists, create the fixture with `existing.Duplicate(uniqueName, agent)` — the server copies a valid connection setup, and the duplicate is test-owned (delete it in cleanup).
  3. If the system is empty and creation fails, fail fast with the diagnostics above and name the library version + gap. Never debug this one-guess-per-QAOps-run; the exception is thrown in the constructor, so batch **all** remaining variants (try/catch each, report all) into a single run.

## Poll-Wait Pattern (Mandatory for Asynchronous Operations)

```csharp
static bool WaitFor(Func<bool> condition, TimeSpan timeout)
{
    var stopwatch = Stopwatch.StartNew();
    while (stopwatch.Elapsed < timeout)
    {
        if (condition()) return true;
        Thread.Sleep(2000);
    }

    return false;
}

// usage
element.Stop();
bool stopped = WaitFor(() => dms.GetElement(element.DmsElementId).State == ElementState.Stopped, TimeSpan.FromMinutes(2));
```

## Worked Example: Export Page Data of the First Element of a Connector to JSON

```csharp
IDms dms = engine.GetDms();

const string SupportedVersionPrefix = "1.1.3."; // version of the protocol.xml the PID map came from

// "First element of the connector" MUST be version-aware: live systems (QAOps DaaS always
// ships a pre-installed Microsoft Platform element in an uncontrolled version range) may host
// elements whose PIDs do not match the map — reading those throws inside GetValue().
// CAUTION: element.Protocol.Version is the literal string "Production" for elements running
// the production-flagged protocol (verified) — a StartsWith("1.1.3.") guard silently excludes
// them, so FirstOrDefault() returns null on systems hosting only baseline elements. Resolve
// the concrete version via dms.GetProtocol(name, "Production").ReferencedVersion, or skip
// hard filtering and degrade per field (catch ParameterNotFoundException per PID and export
// IsAvailable=false + reason) so the export works on any hosted version.
IDmsElement element = dms.GetElements()
    .Where(e => string.Equals(e.Protocol.Name, "Microsoft Platform", StringComparison.OrdinalIgnoreCase))
    .Where(e => e.Protocol.Version.StartsWith(SupportedVersionPrefix, StringComparison.Ordinal))
    .OrderByDescending(e => e.State == ElementState.Active) // prefer active
    .ThenBy(e => e.AgentId)
    .ThenBy(e => e.Id)
    .FirstOrDefault();

if (element == null)
{
    engine.ExitFail("No Microsoft Platform element found in supported version range '" + SupportedVersionPrefix + "*'.");
    return;
}

// PID->name map taken from the connector's protocol.xml (page composition is not exposed via IDms)
var fields = new (int Pid, string Name)[] { (350, "Total Processor Load"), (1017, "Total Handles") /* ... */ };

var values = new Dictionary<string, string>();
foreach (var (pid, name) in fields)
{
    values[name] = element.GetStandaloneParameter<string>(pid).GetValue();
}

string folder = SecurePath.CreateSecurePath(@"C:\Skyline DataMiner\Documents");
Directory.CreateDirectory(folder);
string json = JsonConvert.SerializeObject(values, Formatting.Indented);
File.WriteAllText(SecurePath.ConstructSecurePath(folder, "export.json"), json);
```

Notes (verified — do not rediscover):

- `C:\Skyline DataMiner\Documents` is the DataMiner Documents folder on the agent running the script.
- **PID maps are version-bound and live systems are not clean**: an unguarded "first element of protocol X" once bound to the pre-existing DaaS baseline element (different version, different PIDs) and failed with an opaque exception from `SendGetParameterMessage`/`GetValue()`. Validate `element.Protocol.Version` against the protocol.xml version the map came from, or read each PID in a try/catch and report unsupported fields in the output instead of crashing.
- **`element.Protocol.Version` can be the literal `"Production"`** (verified): production-flagged elements never match numeric prefix guards. Resolve the concrete version with `dms.GetProtocol(name, "Production").ReferencedVersion` (verified `IDmsProtocol` member: "the version this production protocol is based on") before comparing.
- **Misleading COM text on missing PIDs** (verified): reading a PID that does not exist on the element's version throws `ParameterNotFoundException` wrapping a `DataMinerCOMException` whose message is a red-herring HRESULT mapping ("TabletPC inking error code. RtpEnabled called multiple times", 0x80040239 = object/file not found). Trust the outer `ParameterNotFoundException`; catching it per field is the supported availability probe (there is no `HasParameter`-style API).
- JSON: use **Newtonsoft.Json** (`JsonConvert`), available transitively via the `Skyline.DataMiner.Dev.*` packages. `System.Web.Script.Serialization` is **not** referenced in Automation projects and fails the build.
- Secure paths: the SecureCoding **analyzers** flag raw `Path.Combine`/`File.WriteAllText` (SLC_SC0001/SC0002). Add the runtime package `Skyline.DataMiner.Utils.SecureCoding` (separate from the `.Analyzers` package the templates already include) and use `using Skyline.DataMiner.Utils.SecureCoding.SecureIO;` with `SecurePath.CreateSecurePath(basePath)` / `SecurePath.ConstructSecurePath(basePath, fileName)`.
