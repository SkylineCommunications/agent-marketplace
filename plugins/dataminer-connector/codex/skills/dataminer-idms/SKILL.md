---
name: dataminer-idms
description: 'Write C# code that reads or manipulates a DataMiner System through the IDms classes (Skyline.DataMiner.Core.DataMinerSystem): finding elements, reading/writing parameters and tables, executing Automation scripts, creating elements, managing views/services/alarms. Use whenever code must interact with a live DataMiner from an Automation script, QAction, or external test/tool — e.g. "write a script that exports data from all elements of connector X", "stop all elements of protocol Y", "read the Performance page of an element". Testing or verifying such code on a real DataMiner is ALWAYS done through QAOps, never a local DataMiner install — see "Related Skills".'
argument-hint: 'Describe the DataMiner manipulation: e.g. "find the first element of connector X and export its parameters", "stop all elements of protocol Y from an Automation script"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-15
  version: 1.7
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-dataapi`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-dataapi`: Alternative dynamic/name-addressed element route, not the fixed-PID IDms contract.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.7 | 2026-09-15 | Added routing notes for IDms use from specialized GQI, SRM, User-Defined API, and Node Recovery work and kept live verification on QAOps. |
| 1.6 | 2026-06-17 | Cheatsheet: documented the `IDmsTable.GetColumn<T>` nullable-type constraint (only `string`/`int?`/`double?`/`DateTime?`; a non-nullable numeric throws `NotSupportedException: Only one of the following types is supported...` — verified, cost a QAOps run) and the `GetRow(primaryKey)` → `object[]` row-read fallback that sidesteps it. Added a Related Skills pointer to `dataminer-dataapi` for name-addressable dynamic elements. |
| 1.5 | 2026-06-17 | Added a top-of-skill **hard rule**: verifying/running IDms code on a real DataMiner ALWAYS goes through QAOps, never a local `C:\Skyline DataMiner` install (no local `dotnet test`, no local DLL references, no local DMA connection). Strengthened the Related Skills pointer to QAOps. |
| 1.4 | 2026-06-12 | Element creation for non-virtual connectors is now **version-dependent**: the serial-connector `IncorrectDataException` gap applies to released packages ≤1.2.0.x; newer versions (branch `AllConnectionTypesForElementCreation`) derive defaults from `protocol.ConnectionInfo` for virtual/SNMP/HTTP/serial/smart-serial/GPIB/WebSocket/SLA, emit expected-vs-provided validation messages, and add `IDmsElement.HasParameter(pid)`. Cheatsheet "Creating Elements" updated with the version split; duplicate-or-fail remains the ≤1.2.0.x strategy. |
| 1.3 | 2026-06-12 | **Corrected the element-creation connection claim**: virtual is NOT sufficient for serial connectors — client-side `IncorrectDataException: Invalid connection type provided at index 0` for virtual/`SerialConnection()`/`SerialConnection(new Tcp())` on Microsoft Platform (cost 4 QAOps runs). Added the duplicate-or-fail fixture strategy, `protocol.ConnectionInfo` diagnostics, the batch-variants-into-one-run rule, the literal-`"Production"` `Protocol.Version` gotcha (+ `ReferencedVersion`), the NU1015 dotnet-add-package rule, and the misleading "TabletPC inking" COM text on `ParameterNotFoundException`. |
| 1.2 | 2026-06-11 | Verify `<Protocol><Name>`/`<Version>` before page extraction (a user-provided protocol.xml turned out to be a different connector); PID maps are version-bound — record the source version and guard element selection with it; never pin IDms package versions to DataMiner versions (NU1102); DaaS-baseline warning on "first element of protocol X" selection. |
| 1.1 | 2026-06-11 | Added the package-before-code rule, verified JSON serialization + SecureCoding facts, the canonical protocol.xml page-extraction script (ask for a file path, never a paste), the virtual-connection element-creation note (cheatsheet), and the NuGet-cache search warning. |
| 1.0 | 2026-06-11 | Initial IDms authoring skill: entry points, package matrix, verified API cheatsheet, docs-first lookup rules, page-parameter guidance, worked examples. |

# IDms: Manipulating a DataMiner System from Code

`IDms` (in `Skyline.DataMiner.Core.DataMinerSystem.Common`) is the high-level object model for a DataMiner System: agents, elements, protocols, parameters, tables, views, services, properties, and Automation scripts. Load this skill whenever a task requires C# code that inspects or changes a live DataMiner.

Specialized Automation contracts may use `IDms`, but the contract still owns the entry point and lifecycle:
GQI data sources must not inherit `Run(IEngine)` assumptions, SRM scripts must respect the configured booking/service
context, User-Defined API scripts must keep request/response handling separate from session-authenticated consumers,
and Node Recovery scripts must account for local/global Agent scope. Use this skill for the DMS operation only; load the
feature skill for the host contract.

**Do not research IDms via GitHub code search or by probing local DLLs.** Everything commonly needed is in this skill and the bundled cheatsheet; for anything beyond that, use the official API docs (see "Looking Up APIs" below). This avoids GitHub rate limits and wasted exploration time.

> **Testing IDms code on a real DataMiner = QAOps. Always. Never a local DataMiner.**
> When the task says to **test / run / verify** this code "on a real DataMiner system" (or similar), the verification phase **always** runs through QAOps — stop and load `dataminer-qaops`, then `dataminer-qaops-integration-testing` → `dataminer-qaops-test-runs`. A local DataMiner install (`C:\Skyline DataMiner`) that happens to be on the machine is **NOT** the test target: do not point tests at a local DMA or start/connect to one, do not reference or reflection-load DLLs from `C:\Skyline DataMiner\Files`, and do not run the integration tests with local `dotnet test` (it cannot reach a real DataMiner — "failing locally" is expected, not a bug to fix). Authoring the code locally is not the end of the task; the behavior is only proven once it has run on a QAOps DataMiner. A local-source NuGet feed (a folder like `D:\localNuget`) is fine for packages and is unrelated to where tests run.

## Getting an IDms Instance

The entry point depends on where the code runs. Pick the matching NuGet package — each provides a `GetDms()` extension method:

| Code runs in | Package | Entry point |
|--------------|---------|-------------|
| Automation script | `Skyline.DataMiner.Core.DataMinerSystem.Automation` | `IDms dms = engine.GetDms();` |
| QAction (connector) | `Skyline.DataMiner.Core.DataMinerSystem.Protocol` | `IDms dms = protocol.GetDms();` |
| External tool / QAOps integration test (SLNet connection) | `Skyline.DataMiner.Core.DataMinerSystem.Common` | `IDms dms = connection.GetDms();` |

```csharp
// Automation script
using Skyline.DataMiner.Automation;
using Skyline.DataMiner.Core.DataMinerSystem.Automation;
using Skyline.DataMiner.Core.DataMinerSystem.Common;

public void Run(IEngine engine)
{
    IDms dms = engine.GetDms();
    // ...
}
```

Package facts (verified — do not rediscover these):

- **Add the matching package to the project *before* writing IDms code** (e.g. `dotnet add package Skyline.DataMiner.Core.DataMinerSystem.Automation` for Automation scripts). Writing the code first guarantees a failed build (`CS0234` on `Skyline.DataMiner.Core`). Always add via `dotnet add package` — hand-writing `<PackageReference>` entries without a `Version` attribute fails restore with `NU1015` (verified).
- **Never pin IDms package versions to a DataMiner version.** The `Skyline.DataMiner.Core.DataMinerSystem.*` packages use their own versioning scheme (1.x); `dotnet add package ... --version 10.4.0.24` fails with `NU1102`. Add without `--version` (latest) unless the repository pins one.
- `Skyline.DataMiner.Net` is **not** a standalone NuGet package. Never run `dotnet add package Skyline.DataMiner.Net`. The `Skyline.DataMiner.Net` namespace types (`Connection`, `ConnectionSettings`, ...) come from the DataMiner Dev Pack file packages such as `Skyline.DataMiner.Files.SLNetTypes`, or transitively from `Skyline.DataMiner.Dev.*` packages.
- Never reference DLLs from a local `C:\Skyline DataMiner\Files` installation in a project — it causes assembly-identity conflicts with the NuGet ref assemblies and is not portable.

## Verified API Cheatsheet

All members below are verified against the official API docs. The full per-type cheatsheet with signatures is in `dataminer-idms/references/idms-cheatsheet.md` — load it before writing non-trivial IDms code.

| Goal | API |
|------|-----|
| All elements in the DMS | `dms.GetElements()` → `ICollection<IDmsElement>` |
| Element by name / by ID | `dms.GetElement(name)` / `dms.GetElement(new DmsElementId(agentId, elementId))` |
| Filter elements by connector | `dms.GetElements().Where(e => e.Protocol.Name == "Microsoft Platform")` |
| Element state | `element.State` (`ElementState.Active`, `Paused`, `Stopped`, `Error`, ...) |
| Start / stop / pause element | `element.Start()` / `element.Stop()` / `element.Pause()` |
| Read standalone parameter | `element.GetStandaloneParameter<double?>(pid).GetValue()` (also `string`, `int?`, `DateTime?`) |
| Write standalone parameter | `element.GetStandaloneParameter<double?>(pid).SetValue(value)` |
| Read display value | `parameter.GetDisplayValue()` |
| Table access | `element.GetTable(tablePid)` → `IDmsTable`; rows via `table.GetRows()`, `table.GetRow(key)`, cells via `table.GetColumn<T>(columnPid)` |
| Protocol info | `dms.GetProtocol(name, version)`, `dms.ProtocolExists(name, version)`, `element.Protocol.Name` / `.Version` |
| Execute Automation script | `dms.GetScript(name).Execute(...)` with `DmsAutomationScriptRunOptions` |
| Create an element | `agent.CreateElement(new ElementConfiguration(dms, name, protocol))` (agent from `dms.GetAgents().First()`) — on packages ≤1.2.0.x only virtual-connection connectors work (serial throws); newer versions derive defaults for all supported connection families, see cheatsheet "Creating Elements" |
| Delete an element | `element.Delete()` |
| Agents | `dms.GetAgents()` / `dms.GetAgent(id)` |
| Views | `dms.GetViews()`, `dms.GetView(name)`, `dms.CreateView(new ViewConfiguration(...))` |
| Services | `dms.GetServices()`, `dms.GetService(name)` |
| Element/view properties | `element.Properties["PropName"].Value` |
| Existence checks | `dms.ElementExists(...)`, `dms.ViewExists(...)`, `dms.ServiceExists(...)`, `dms.ProtocolExists(...)` |

Rules:

- **Do not invent IDms members.** If it is not in the cheatsheet, verify it in the official docs first.
- DataMiner operations are **asynchronous**: after `Start()`, `Stop()`, `CreateElement(...)`, or a script execution, poll the expected state with a timeout instead of asserting immediately.
- **Element creation for non-virtual connectors is version-dependent**: packages ≤1.2.0.x throw client-side `IncorrectDataException: Invalid connection type provided at index 0` for serial (and most non-virtual) connectors regardless of connection variant (verified on Microsoft Platform); versions after 1.2.0.x derive valid defaults from `protocol.ConnectionInfo` for all supported families. Check the consumed package version; on old versions use the duplicate-or-fail fixture strategy in the cheatsheet's "Creating Elements" and batch any live-system experiments into a single QAOps run.
- `element.Protocol.Version` may be the literal `"Production"`; resolve it via `dms.GetProtocol(name, "Production").ReferencedVersion` before numeric prefix guards.
- Parameter reads return raw values; use `GetDisplayValue()` when the human-readable form (with units/exceptions) is needed.
- Cache `dms.GetElements()` results when filtering multiple times; it is a DMS-wide call.
- Fall back to raw SLNet messages only when IDms genuinely does not expose the functionality.

## Reading "a Page" of an Element

A frequent request is "get all data from the *X* page of element(s)". **IDms has no API that returns parameters grouped by Display page.** Page composition is defined in the connector's `protocol.xml` (`Display` elements / page attributes). Handle it as follows:

1. Ask the user for the **file path** to the `protocol.xml` (never a paste — pasted connectors run to hundreds of KB and bloat the session). If only the parameter list of the page is available, use that. Do not guess PIDs.
2. **Verify the file is the right connector before extracting**: check `<Protocol><Name>` matches the requested connector and record `<Protocol><Version>` (e.g. `grep` for `<Name>` and `<Version>` near the top). A user-provided file once turned out to be a completely different connector with no such page — extraction "succeeding" with zero rows or wrong rows wastes a round-trip. If the name does not match, ask again.
3. Extract the PIDs positioned on the page with the canonical script below and code a fixed PID→name map. Exclude `pagebutton` controls — they are navigation, not data.
4. **The PID map is version-bound.** PIDs and page composition change between connector versions, and live systems can host multiple versions (QAOps DaaS systems always carry a pre-installed Microsoft Platform in an uncontrolled version). Keep the source `<Version>` next to the map, and make element-selection code filter or validate `element.Protocol.Version` against that range — reading an unsupported element throws deep inside `GetValue()` (a `ParameterNotFound`-style failure surfacing as an exception from `SendGetParameterMessage`). Prefer producing a JSON/result entry that names the unsupported element + version over crashing.
5. Read each PID via `GetStandaloneParameter<T>(pid)` (or `GetTable` for table parameters on the page) and aggregate the results.

Canonical extraction script (verified — handles the real structure; do not improvise):

```powershell
$xmlPath = '<path-to-protocol.xml>'; $page = 'Performance'
[xml]$xml = Get-Content -Path $xmlPath -Raw
$rows = foreach ($param in $xml.Protocol.Params.Param) {
    $positions = @($param.Display.Positions.Position)
    $hit = @($positions | Where-Object { [string]$_.Page -eq $page })
    if (-not $hit) { continue }
    $measurement = if ($param.Measurement.Type.'#text') { $param.Measurement.Type.'#text' } else { [string]$param.Measurement.Type }
    [pscustomobject]@{
        Pid = [int]$param.id; Name = [string]$param.Name
        Row = [int]$hit[0].Row; Column = [int]$hit[0].Column
        PageButton = ($measurement -eq 'pagebutton')
    }
}
$rows | Sort-Object Column, Row | Format-Table -AutoSize
```

Pitfalls this script avoids (each cost a failed attempt when improvised):

- The page name lives at `Display/Positions/Position/Page` — **not** `Display/Page`.
- `pagebutton` is in `Measurement/Type`, which may parse as a string or as a node with `#text`.
- PowerShell `` `t `` only expands inside **double-quoted** strings; in single quotes it stays literal.
- Sort by the typed `[int]` properties, not by re-parsing formatted strings.

## Looking Up APIs

Use the official DataMiner docs site directly — **never GitHub code search** (rate limits, noise):

- Type index: `https://aka.dataminer.services/skyline-data-miner-core-data-miner-system-common`
- Per-type pages follow the pattern: `https://docs.dataminer.services/develop/api/types/Skyline.DataMiner.Core.DataMinerSystem.Common.<TypeName>.html` (e.g. `...Common.IDms.html`, `...Common.IDmsElement.html`, `...Common.IDmsTable.html`)

Fetch only the specific type pages needed; the cheatsheet reference should already cover most tasks.

Never `grep`/`glob` across the entire NuGet cache to find an API (it times out on real machines). Locate the exact package folder first via `obj\project.assets.json` → `packagesPath` (the cache root may not be `%USERPROFILE%\.nuget\packages`), then search only `<cache>\<package>\<version>\` — the `lib\<tfm>\*.xml` doc file next to the assembly answers most signature questions.

## Worked Example: Export Data from All Elements of a Connector

```csharp
IDms dms = engine.GetDms();

const string SupportedVersionPrefix = "1.1.3."; // version of the protocol.xml the PID map came from

var elements = dms.GetElements()
    .Where(e => string.Equals(e.Protocol.Name, "MyConnector", StringComparison.OrdinalIgnoreCase))
    .OrderBy(e => e.AgentId)
    .ThenBy(e => e.Id)
    .ToList();

var export = new List<Dictionary<string, object>>();
foreach (IDmsElement element in elements)
{
    var data = new Dictionary<string, object>
    {
        ["Element"] = element.Name,
        ["ProtocolVersion"] = element.Protocol.Version,
        ["State"] = element.State.ToString(),
    };

    // Version guard: live systems can host elements of other version ranges with different
    // PIDs (QAOps DaaS always ships a pre-installed Microsoft Platform element). Report them
    // in the output instead of crashing inside GetValue().
    if (!element.Protocol.Version.StartsWith(SupportedVersionPrefix, StringComparison.Ordinal))
    {
        data["Unsupported"] = $"Protocol version outside supported range '{SupportedVersionPrefix}*'; fields skipped.";
        export.Add(data);
        continue;
    }

    foreach (var field in pageFields) // fixed PID->name map from protocol.xml
    {
        data[field.Name] = element.GetStandaloneParameter<string>(field.Pid).GetValue();
    }

    export.Add(data);
}
```

For a fuller example (including a deterministic "first element" pick, table reads, and JSON output) see `dataminer-idms/references/idms-cheatsheet.md`.

## Related Skills

| Task | Skill |
|------|-------|
| **Verify/run the script on a real DataMiner — always QAOps, never a local DataMiner** | `dataminer-qaops` → `dataminer-qaops-integration-testing` → `dataminer-qaops-test-runs` |
| SDK-style Automation project setup, build, packaging | `dataminer-sdk` |
| GQI/SRM/User-Defined API/Node Recovery contract behavior | Load the matching feature skill before adding IDms calls |
| Choosing DataMiner NuGet packages | `dataminer-nugets` |
| QAction (connector-side) development | `dataminer-qaction` |
| Push data into a **name-addressable dynamic** element without a static protocol.xml (and when NOT to — fixed-PID caveat) | `dataminer-dataapi` |
