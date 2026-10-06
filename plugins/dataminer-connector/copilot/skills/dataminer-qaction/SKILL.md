---
name: dataminer-qaction
description: 'QAction (C#) development for DataMiner connectors: writing QActions, SLProtocol API, table fill methods (FillArray, FillArrayNoDelete, FillArrayWithColumn, SetRow, AddRow, DeleteRow), Clear/Leave sentinels, exception handling, multi-threading, performance optimization, logging, and code organization patterns. Use when writing or modifying C# QAction code.'
argument-hint: 'Describe the QAction task: e.g. "parse JSON response into table", "write QAction for SNMP trap processing"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-27
  version: 2.2
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.2 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 2.1 | 2026-09-14 | Distinguished built-in SLProtocol APIs, Protocol.Extension methods, and generated typed helpers; made helper use conditional. |
| 2.0 | 2026-09-11 | Replaced direct Newtonsoft deserialization examples with the SecureCoding runtime API, added secret-safe logging/certificate rules, and corrected CS9057 handling so analyzers remain active. |
| 1.9 | 2026-09-11 | Corrected moved OpenConfig and Ember+ documentation URLs in the advanced patterns reference. |
| 1.8 | 2026-08-12 | Added "When to load this skill" trigger section. Added Known Toolchain Warning: Sdk.targets PowerShell API fallback. |
| 1.7 | 2026-07-02 | Added "Defensive Programming — Where It Helps vs. Where It's Noise" subsection: guard external/untrusted data, but don't add redundant null/length checks around SLProtocol methods with a guaranteed contract (e.g. `GetColumns`, `GetKeys`, `GetParameters`). |
| 1.6 | 2026-06-24 | Expanded "Do NOT hardcode parameter IDs" hard rule to explicitly cover response body and status code params. Added two new hard rules: no Hungarian notation variable names (SA1305) and no trailing blank lines at end of `.cs` files (SA1518). |
| 1.5 | 2026-05-08 | Added Hard Rules (anti-hallucination) section. Added `example-json-table.md` canonical example reference. |
| 1.4 | 2026-04-17 | Added canonical QAction .csproj template with explicit NEVER `<Nullable>enable</Nullable>` rule (CS8630 error on net48/C# 7.3). |
| 1.3 | 2026-04-16 | Added CS9057 known toolchain warning section with Directory.Build.props fix. |
| 1.2 | 2026-03-28 | Initial release. |

# DataMiner QAction (C#) Development

Covers writing and modifying QActions — the C# code blocks in DataMiner connectors. Load `dataminer-connector-core` alongside for naming conventions and code style.

> **Paired agent**: `dataminer-qaction-writer` — owns workflow, NuGet steps, and the conditional helper decision. This skill owns SLProtocol API reference, code patterns, and examples. Keep shared concepts (table fill methods, logging patterns) in sync.

## When to Load This Skill

Load this skill (and invoke `dataminer-qaction-writer`) whenever **any** of the following conditions apply:

- You are writing or modifying a `QAction_*.cs` file or the `<QActions>` section of `protocol.xml`.
- The build output contains **any warning or error** lines from `Sdk.targets`, a `QAction_*.csproj`, or `QAction_Helper.csproj` — regardless of project type (connector, TestPackage, Automation solution).
- A build check reports WARN or FAIL findings mentioning `.csproj` files in a connector or related workspace.
- You are reviewing, generating, or regenerating `QAction_Helper.cs`.
- You are adding NuGet packages to a QAction project.

> **Do not skip this skill because the build warning originates in a `.TestPackage` or `.sln`-level project.** SDK-level warnings (e.g., from `Sdk.targets`) still indicate a toolchain configuration issue that must be reviewed against the Known Toolchain Warnings below.

## Reference Files

For deep-dive details on specific topics, load these references when needed:

| Topic | Reference File |
|-------|---------------|
| JSON parsing, HTTP response handling, DateTime conversion | `dataminer-qaction/references/parsing-patterns.md` |
| Inter-element communication, context menus, multithreaded timers, InterApp, DSI | `dataminer-qaction/references/advanced-patterns.md` |
| Rate calculations (Custom/SNMP, standalone/table) | `dataminer-qaction/references/rate-calculations.md` + `dataminer-nugets` package references |
| NuGet package APIs (`Dev.Protocol`, InterApp, Protocol.Extension, Rates) | `dataminer-nugets` |
| **Canonical QAction examples: JSON→table, bulk get/set, FillArrayWithColumn, precompile** | `dataminer-qaction/references/example-json-table.md` |
| QAction C# validator rules (44 checks, 118 error messages) for reviewing/writing QActions | `dataminer-qaction/references/dataminer-qaction-rules.md` |
| Raw NotifyProtocol / NotifyDataMinerQueued calls (NT types 127, 128, 193, 194, 220, 221, 321) | `dataminer-qaction/references/raw-notify-calls.md` |

---

## Hard Rules (Anti-Hallucination)

Read the [QAction guard rails](references/dataminer-qaction.instructions.md) when
working on QAction code. The publisher includes this authoritative source as a skill reference
and, for Copilot, a native rule. Automatic rule application depends on the client/version;
always follow this skill even when no instruction is automatically attached.

> **Do NOT invent or misclassify SLProtocol methods.** `FillArray`, `FillArrayNoDelete`, `FillArrayWithColumn`, `SetRow`, `AddRow`, `DeleteRow`, and `CheckTrigger` are built-in `SLProtocol` members. `GetColumns` and `SetColumns` require `Skyline.DataMiner.Utils.Protocol.Extension`. Generated `SLProtocolExt` is only for connector-specific typed properties/table wrappers.

> **Do NOT place `public class QAction` inside a namespace.** Silently never fires.

> **Do NOT use `e.Message` in catch blocks.** Always `e.ToString()`.

> **Do NOT call protocol methods inside loops.** Use bulk `GetParameters`/`SetParameters`.

> **Do NOT scatter parameter IDs as magic numbers.** Use `Parameter.xxx` constants when the project consumes a current generated helper. In an intentionally helper-free project, declare descriptive local constants and use the base `SLProtocol` API.

> **Do NOT use Hungarian notation** for variable names. Use descriptive full names: ❌ `swVersion`, `strName`, `intCount` → ✅ `softwareVersion`, `name`, `count`.

> **Do NOT leave blank lines at the end of a `.cs` file.** The last line must be the closing `}` of the class — no trailing newlines after it (SA1518).

> **Do NOT deserialize untrusted JSON through `JsonConvert.DeserializeObject`.** Add `Skyline.DataMiner.Utils.SecureCoding` and use `SecureNewtonsoftDeserialization.DeserializeObject`; keep the analyzer package enabled.

> **Do NOT log secrets or bypass TLS validation.** Redact credentials and payloads that may contain them. A certificate callback must not always return `true`.

> **Always load `example-json-table.md`** when writing a table-filling or parsing QAction.

---

## Utility Package Rule

**Before writing custom logic**, load `dataminer-nugets` and check `dataminer-connector-core/references/nuget-packages.md` for an existing Skyline utility package. Using official packages is **mandatory** when available. Key scenarios:

- **SNMP rate/bitrate/throughput calculations** → `Skyline.DataMiner.Utils.Rates.Protocol` (NEVER write manual delta/rate math)
- **Custom/non-SNMP rate calculations** → `Skyline.DataMiner.Utils.Rates.Common`
- **Interface utilization** → `Skyline.DataMiner.Utils.Interfaces`
- **SNMP counter delta tracking** → `Skyline.DataMiner.Utils.SNMP`
- **SNMP trap parsing** → `Skyline.DataMiner.Utils.SNMP.Traps.Protocol`
- **Table context menus** → `Skyline.DataMiner.Utils.Table.ContextMenu`
- **Safe type conversions** → `Skyline.DataMiner.Utils.SafeConverters`
- **Untrusted JSON deserialization** → `Skyline.DataMiner.Utils.SecureCoding`

---

## QAction Structure

```xml
<QActions>
  <QAction id="1" name="ParseResponse" encoding="csharp" triggers="100">
    <![CDATA[
using System;
using Skyline.DataMiner.Scripting;

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            string rawValue = Convert.ToString(protocol.GetParameter(100));
            protocol.SetParameter(101, rawValue.Length);
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Error: {ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
    ]]>
  </QAction>
</QActions>
```

> **CRITICAL — No Namespace on the Entry Point Class**
>
> `public static class QAction` with the `Run` method **must never be placed inside a namespace**.
> DataMiner's scripting engine searches for this class at the **global scope**. Wrapping it in a namespace causes the QAction to **silently never fire** — no error, no log entry.
>
> ❌ Wrong (QAction never fires):
> ```csharp
> namespace MyConnector
> {
>     public class QAction          // BROKEN — not at global scope
>     {
>         public static void Run(SLProtocol protocol) { ... }
>     }
> }
> ```
>
> ✅ Correct:
> ```csharp
> using System;
> using Skyline.DataMiner.Scripting;
>
> public class QAction              // global scope — no namespace wrapper
> {
>     public static void Run(SLProtocol protocol) { ... }
> }
> ```

### QAction Key Attributes
| Attribute | Description |
|-----------|-------------|
| `id` | Unique QAction ID |
| `name` | Display name — must be **meaningful and contain a verb** |
| `encoding` | Always `csharp` for modern connectors |
| `triggers` | Comma-separated parameter IDs that trigger this QAction |
| `inputParameters` | Parameters passed as input (comma-separated IDs) |
| `dllImport` | External DLLs to import |

### Stub / AfterStartup QAction

When a QAction has no implementation yet (e.g. an AfterStartup QAction reserved for future initialization), use `// TODO: Implement.` as a placeholder inside the `try` body. **NEVER leave blank lines inside braces** — this triggers SA1505/SA1508 build warnings.

```csharp
using System;

using Skyline.DataMiner.Scripting;

/// <summary>
/// DataMiner QAction Class: After Startup.
/// </summary>
public static class QAction
{
    /// <summary>
    /// The QAction entry point.
    /// </summary>
    /// <param name="protocol">Link with SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        try
        {
            // TODO: Implement.
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

### Known Toolchain Warning: CS9057

`warning CS9057: The analyzer assembly references version 'X' of the compiler, which is newer than the currently running version 'Y'` means that analyzer cannot load reliably under the active compiler. Hiding the warning can leave the build without its SLC/StyleCop/SXA checks.

**Do not add `CS9057` to `NoWarn`.** Use a compatible .NET SDK/Roslyn compiler, or select an analyzer version compatible with the task's approved toolchain and target DataMiner dependency set. Rebuild and confirm `CS9057` is absent before treating the analyzer gate as successful.

### Known Toolchain Warning: Sdk.targets PowerShell API Fallback

`warning : Could not execute with PowerShell API, falling back to Shell with less runtime details...` emitted by `Sdk.targets` is an **environment-specific** warning that appears when the DataMiner SDK build targets cannot use the PowerShell API (e.g., in CI environments or machines where the PowerShell execution policy or host API is restricted). The build still succeeds; only the runtime detail level of the SDK's internal tool invocation is reduced.

This warning does **not** indicate a defect in the connector code, QAction code, or generated helpers. It is safe to ignore.

**When this warning appears**: it will show up for every project in the solution that uses the DataMiner SDK (including `.TestPackage` projects). Seeing it twice for the same `.csproj` is normal — the SDK targets run multiple tool steps per project.

**No code change is required.** If the warning must be suppressed in CI evaluation output, configure the build system to filter SDK-level informational warnings from the warning count. Do **not** attempt to suppress it via `<NoWarn>` — it is not a C# compiler diagnostic code.


### GitHub Packages Authentication Warnings

Warnings such as `NuGet.targets(198,5): warning : Your request could not be authenticated by the GitHub Packages service.` or `Project.csproj : warning Undefined: Your request could not be authenticated by the GitHub Packages service.` are **not** safe-to-ignore SDK fallback warnings and do **not** indicate a connector-code defect.

Inspect the configured NuGet package source and the CI authentication token's GitHub Packages package-read permissions. Ensure the source URL is correct and that the token is available to the restore/build step with permission to read the required packages. Do **not** suppress these warnings with `<NoWarn>`; fix the package-source authentication instead.

### Registering a QAction in protocol.xml

Every new QAction needs a matching `<QAction>` XML entry. In an orchestrated run, the assigned
XML owner adds it; the QAction writer returns missing or changed registrations as requests to
the orchestrator, never edits `protocol.xml`, and pauses affected work until XML and conditional
helper gates have run again.

```xml
<QAction id="N" name="VerbNoun" encoding="csharp" triggers="paramId">
```

And create the corresponding `QAction_N/` project in the solution:
- `QAction_N.cs` — the C# code
- `QAction_N.csproj` — SDK-style project referencing the selected `Skyline.DataMiner.Dev.Protocol`.

After creating the project files, add the project to the **`QActions` solution folder** (not the root):

- **`.slnx`** (new format): add `<Project Path="QAction_N/QAction_N.csproj" />` inside the existing `<Folder Name="/QActions/">` element.
- **`.sln`** (classic format): run `dotnet sln add --solution-folder QActions QAction_N/QAction_N.csproj`.

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net48</TargetFramework>
    <GenerateDocumentationFile>True</GenerateDocumentationFile>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Skyline.DataMiner.Dev.Protocol" Version="..." />
  </ItemGroup>
</Project>
```

The official connector template includes a `QAction_Helper` project and `ProjectReference` by default. Preserve that reference when this QAction consumes generated `Parameter`, `SLProtocolExt`, `{Table}QActionTable`, or `{Table}QActionRow` members. If the solution is intentionally helper-free, omit the project reference, use descriptive local constants, and compile against `Skyline.DataMiner.Dev.Protocol`; see the [compilable helper-free example](references/examples/helper-free-qaction/QAction.cs).

> ⚠️ **NEVER** add `<Nullable>enable</Nullable>` (or any `<Nullable>` element) to a QAction `.csproj`. The DataMiner SDK targets `net48`, which defaults to **C# 7.3** — nullable reference types require C# 8.0+. Adding `<Nullable>enable</Nullable>` causes **error CS8630** on every affected QAction project, blocking compilation entirely. If NuGet packages are required, add an `<ItemGroup><PackageReference …/>` block — do not modify the `<PropertyGroup>` settings shown above.

---

## SLProtocol API Reference

### Important Methods
| Method | Owner | Description |
|--------|-------|-------------|
| `protocol.GetParameter(id)` | `SLProtocol` | Get a parameter value |
| `protocol.SetParameter(id, value)` | `SLProtocol` | Set a parameter value |
| `protocol.GetParameters(ids[])` | `SLProtocol` | Get multiple parameters at once |
| `protocol.SetParameters(ids[], values[])` | `SLProtocol` | Set multiple parameters at once |
| `protocol.FillArray(tablePid, columns)` | `SLProtocol` | Replace full table — **column-oriented** by default |
| `protocol.FillArrayNoDelete(tablePid, columns)` | `SLProtocol` | Upsert rows — **column-oriented** format |
| `protocol.FillArrayWithColumn(tablePid, columnPid, keys, values)` | `SLProtocol` | Update specific cells in one column |
| `protocol.SetRow(tablePid, primaryKey, rowData)` | `SLProtocol` | Update one existing row (use string-key overload) |
| `protocol.AddRow(tablePid, rowData)` | `SLProtocol` | Add a row when the primary key is absent |
| `protocol.DeleteRow(tablePid, key)` | `SLProtocol` | Remove row(s) — accepts `string` or `string[]` |
| `protocol.GetRow(tablePid, primaryKey)` | `SLProtocol` | Get all cell values in a row as `object[]` |
| `protocol.GetKeys(tablePid)` | `SLProtocol` | Get all primary keys as `string[]` |
| `protocol.Exists(tablePid, primaryKey)` | `SLProtocol` | Check if row exists |
| `protocol.GetColumns(tablePid, indexes)` | `Protocol.Extension` package | Read several table columns by 0-based index |
| `protocol.SetColumns(data)` | `Protocol.Extension` package | Set several table columns in one call |
| `protocol.Log(message, type, level)` | `SLProtocol` | Write to DataMiner logging |
| `protocol.NotifyProtocol(type, value1, value2)` | `SLProtocol` | Notify protocol engine |
| `protocol.CheckTrigger(triggerId)` | `SLProtocol` | Fire a trigger programmatically (use to re-poll a group) |

The public member links and generated-wrapper boundaries are centralized in `dataminer-connector-core/references/logic-qactions.md#api-surface-ownership`.

### Methods That Do NOT Exist on SLProtocol

These are common mistakes — these methods do NOT exist on `SLProtocol`:

| Wrong Call | Correct Alternative |
|-----------|-------------------|
| `protocol.ExecuteGroup(groupId)` | `protocol.CheckTrigger(triggerId)` — define a Trigger in protocol.xml that starts the group, then call CheckTrigger |
| `protocol.RunGroup(groupId)` | `protocol.CheckTrigger(triggerId)` |
| `protocol.PollGroup(groupId)` | `protocol.CheckTrigger(triggerId)` |

> To programmatically trigger a poll group from a QAction, define a `<Trigger>` in protocol.xml that starts the group, then call `protocol.CheckTrigger(triggerId)` from C#.

> **Raw NotifyProtocol / NotifyDataMinerQueued calls**: For exact parameter shapes of specific numeric call types (127, 128, 193, 194, 220, 221, 321), load `dataminer-qaction/references/raw-notify-calls.md`. Prefer wrapper methods when available.

---

## Table Fill Methods

All table methods operate on **retrieved** columns only; `custom`-type columns between retrieved columns are skipped automatically. None support `autoincrement`.

### Choosing the Right Method

| Goal | Method |
|------|--------|
| Replace full table — column-oriented (preferred bulk) | `FillArray(tablePid, object[] columns)` |
| Replace full table — row-oriented | `FillArray(tablePid, List<object[]> rows, NotifyProtocol.SaveOption.Full)` |
| Upsert rows, keep unlisted — column-oriented | `FillArrayNoDelete(tablePid, object[] columns)` |
| Upsert rows, keep unlisted — row-oriented | `FillArray(tablePid, List<object[]> rows, NotifyProtocol.SaveOption.Partial)` |
| Update specific cells in one column | `FillArrayWithColumn(tablePid, columnPid, keys[], values[])` |
| Update one existing row | `SetRow(tablePid, string primaryKey, object[] rowData)` |
| Add a row only when its key is absent | `AddRow(tablePid, object[] rowData)` |
| Remove row(s) | `DeleteRow(tablePid, string key)` / `DeleteRow(tablePid, string[] keys)` |

### Column-Oriented Format (Default)

Most overloads of `FillArray` and **all** overloads of `FillArrayNoDelete` accept **column-oriented** data: an `object[]` where each element is an `object[]` of all values for that column. Column order must match `idx` sequence in `<ArrayOptions>`.

```csharp
// 3-column table (pid 1000): Index (1001), Name (1002), Value (1003)
object[] columnIndex = new object[] { "1", "2" };
object[] columnName  = new object[] { "Alpha", "Beta" };
object[] columnValue = new object[] { 10.0, 20.0 };

// REPLACES the entire table
protocol.FillArray(1000, new object[] { columnIndex, columnName, columnValue });

// UPSERT — existing rows NOT in data are kept
protocol.FillArrayNoDelete(1000, new object[] { columnIndex, columnName, columnValue });
```

### Row-Oriented Format (SaveOption Overloads Only)

The `FillArray` overloads with `NotifyProtocol.SaveOption` accept **row-oriented** data: a `List<object[]>` where each element is a complete row.

- `SaveOption.Full` — rows not in list are **deleted**.
- `SaveOption.Partial` — rows not in list are **kept** (upsert).

```csharp
var rows = new List<object[]>
{
    new object[] { "1", "Alpha", 10.0 },
    new object[] { "2", "Beta",  20.0 },
};

// Full replace
protocol.FillArray(1000, rows, NotifyProtocol.SaveOption.Full);

// Upsert
protocol.FillArray(1000, rows, NotifyProtocol.SaveOption.Partial);
```

### FillArrayWithColumn (Single Column Update)

```csharp
protocol.FillArrayWithColumn(
    1000,
    1002,
    new object[] { "1", "2" },
    new object[] { "AlphaNew", "BetaNew" });
```

### Single-Row Operations

```csharp
// Update existing row
protocol.SetRow(1000, "1", new object[] { "1", "AlphaNew", 99.0 });

// Add new row
protocol.AddRow(1000, new object[] { "3", "Gamma", 30.0 });

// Remove one row
protocol.DeleteRow(1000, "1");

// Remove multiple rows (preferred over looping)
protocol.DeleteRow(1000, new string[] { "1", "2" });
```

### Clear and Leave Sentinels (DataMiner 10.4.2+)

Pass `useClearAndLeave: true` to enable sentinel handling:

- `protocol.Clear` — clears the cell.
- `protocol.Leave` — preserves the existing cell value.
- `null` — always clears, regardless of flag.

```csharp
var rows = new List<object[]>
{
    new object[] { "1", protocol.Leave, 99.0 }, // keep Name, update Value
};
protocol.FillArray(1000, rows, NotifyProtocol.SaveOption.Partial, null, true);
```

---

## Error Handling & Robustness

- **Every QAction entry point** must have a try/catch. Unhandled exceptions cause memory leaks in SLScripting.
- Use `e.ToString()` for logging, **not** `e.Message` (preserves stack trace).
- Use `finally` for resource cleanup. Use `using` statements for `IDisposable`.
- **Verify the format** of all QAction input variables before use.
- Use `CultureInfo.InvariantCulture` for parsing numbers and dates. E.g., `Double.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out result)`.

### Defensive Programming — Where It Helps vs. Where It's Noise

Be defensive at **trust boundaries** — anywhere data enters the QAction from *outside* DataMiner's own guaranteed contracts: device/API responses, JSON/XML parsing, user-entered parameter values, external file/DB reads. Do **not** add redundant guards around `SLProtocol` methods whose contract already guarantees a safe return value — that only adds noise and dead branches that never execute.

**Always guard (external/untrusted data):**
- HTTP/device responses before parsing (`response?.Devices == null`, `JObject` fields that may be absent).
- Values from `SecureNewtonsoftDeserialization` — deserialization can return `null` or a partially populated object.
- Results of `TryParse`/`Parse` on device/user strings — check `TryParse`'s bool return, don't assume success.
- Division operations where the divisor comes from a device/table value (avoid `DivideByZeroException`).
- Array/list indexing when the index or collection size comes from external data.

**Do NOT guard (DataMiner APIs with a guaranteed contract):**
- `protocol.GetColumns(...)` from `Skyline.DataMiner.Utils.Protocol.Extension` returns the requested column collection. Validate its documented shape once; do not add repeated `columns == null` checks downstream.
- Generated `{Table}QActionTable` enumeration and properties follow the generated helper/base-class contract; do not confuse those wrappers with `GetColumns`.
- `protocol.GetRow(...)` — returns an object array. For a missing key, the current API returns an array containing null cell references and logs the failed lookup; use `Exists` first when row presence changes control flow.
- `protocol.GetKeys(...)` — always returns a non-null `string[]` (empty array when the table has no rows).
- `protocol.GetParameters(ids[])` — always returns an `object[]` the same length as `ids[]`.

**Rule of thumb**: if the SLProtocol/DataMiner API documentation or generated helper guarantees a shape (non-null, fixed length), trust it and check it **once** where it's documented — don't sprinkle redundant `== null` / `.Length == 0` checks on every subsequent line "just in case". Reserve defensive checks for data whose shape DataMiner does not control: device payloads, parsed JSON/XML, and user input.

---

## Performance

- **Minimize SLScripting ↔ SLProtocol interactions**. Use bulk methods:
  - `GetParameters` / `SetParameters` (multiple standalone params)
  - `GetColumns` / `SetColumns` through the documented `Skyline.DataMiner.Utils.Protocol.Extension` package when its wrappers are intentionally selected
  - generated `{Table}QActionTable` wrappers through `SLProtocolExt` when the existing helper is current and typed table access improves the code
  - `FillArray` / `FillArrayNoDelete` (full table updates)
- Avoid calling protocol methods **inside loops**.
- Avoid `ClearAllKeys()` — prefer selective row removal or `FillArray`.
- **Large table limits**: `GetColumns` < 120K cells per call, sets < 20K cells per call, < 1000 rows per `FillArray`.
- **No action may run longer than 15 minutes** (generates RTE). Half-open RTE at 7.5 min.
- `Thread.Sleep` ≥ 15 ms and a multiple of 15 ms. Use exceptionally with justification.
- Prefer `&&` over `&`, `||` over `|`. Put most-likely-to-fail first in AND chains.
- **LINQ** preferred for readability. Call `ToList()`/`ToArray()` when enumerating multiple times.
- `StringBuilder` for significant concatenation; `String.Join` for lists to strings.
- Choose **collections by O() characteristics** (e.g., `Dictionary` for O(1) lookup). Set initial capacity when known. `AddRange` over multiple `Add`. `List<T>` over `ArrayList`.

---

## Multi-Threading

- Verify parallel execution is **actually faster** before using it.
- **Threads that outlive their QAction** are dangerous: no RTE notice, hard to debug, crash SLScripting on unhandled exceptions.
- Provide **locks for critical sections**, especially get-modify-set on shared data.

---

## Logging & Debugging

- Log messages must include the **QAction ID and method name**: `$"QA{protocol.QActionID}|MethodName|..."`.
- Use **preprocessor directives** (`#if DEBUG`) for debug-level logging.
- Only log when required — excessive logging impacts performance.
- Never log passwords, tokens, API keys, cookies, complete Authorization headers, or raw payloads that may contain credentials.

---

## Code Organization

### Entry-Point Rule

The `public static class QAction` entry point must always be at **global scope** — never inside a namespace. All other supporting types (helpers, parsers, data models) should be organized in namespaces below the entry-point class in the same file, or extracted to the precompile QAction.

### Local Helper Classes

For QAction-local helpers that are not shared with other QActions, define them **below** the entry-point class in the same `.cs` file, inside a namespace:

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Scripting;

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            string raw = Convert.ToString(protocol.GetParameter(Parameter.rawresponse));
            var parser = new StatusParsing.StatusParser();
            List<StatusParsing.DeviceStatus> statuses = parser.Parse(raw);
            // ... fill table ...
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Error: {ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}

namespace StatusParsing
{
    using Newtonsoft.Json;
    using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

    internal class DeviceStatus
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }
    }

    internal class StatusParser
    {
        public List<DeviceStatus> Parse(string json)
        {
            return SecureNewtonsoftDeserialization.DeserializeObject<List<DeviceStatus>>(json)
                   ?? new List<DeviceStatus>();
        }
    }
}
```

### Precompile QAction (QAction 1) — Shared Code

All code used by **two or more QActions** must live in **QAction 1** with `options="precompile"`. It is compiled first; other QActions import it via `dllImport="QAction_1.dll"`.

QAction 1 contains **only** namespaced classes — no entry-point `Run` method is needed.

**XML:**
```xml
<QAction id="1"   name="Precompile"    encoding="csharp" options="precompile" />
<QAction id="100" name="ParseDevices"  encoding="csharp" triggers="100" dllImport="QAction_1.dll" />
```

**QAction_1/QAction_1.cs** — data models and shared helpers:
```csharp
using System.Collections.Generic;
using Newtonsoft.Json;
using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

namespace MyConnector.Common
{
    /// <summary>Represents a single device item from the API response.</summary>
    public class DeviceItem
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("value")]
        public double Value { get; set; }
    }

    /// <summary>Parses raw JSON into a list of <see cref="DeviceItem"/> objects.</summary>
    public static class DeviceItemParser
    {
        public static List<DeviceItem> Parse(string json)
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return new List<DeviceItem>();
            }

            return SecureNewtonsoftDeserialization.DeserializeObject<List<DeviceItem>>(json)
                   ?? new List<DeviceItem>();
        }
    }
}
```

**QAction_100/QAction_100.cs** — entry point delegates to shared helpers:
```csharp
using System;
using Skyline.DataMiner.Scripting;
using MyConnector.Common;   // imported from QAction_1.dll

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            string raw = Convert.ToString(protocol.GetParameter(Parameter.rawresponse));
            var items = DeviceItemParser.Parse(raw);

            if (items.Count == 0)
            {
                return;
            }

            var keys   = new object[items.Count];
            var names  = new object[items.Count];
            var values = new object[items.Count];

            for (int i = 0; i < items.Count; i++)
            {
                keys[i]   = items[i].Id;
                names[i]  = items[i].Name;
                values[i] = items[i].Value;
            }

            protocol.FillArray(Parameter.Devicestable.tablePid, new object[] { keys, names, values });
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Error: {ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

### C# OOP Best Practices

- Use **POCOs** for data transfer — properties, not public fields.
- Decorate JSON-mapped properties with `[JsonProperty]` so the model is independent of the API's field names.
- Parser and builder classes each have **one responsibility** (Single Responsibility Principle).
- Avoid mutable static state. Use static fields only for thread-safe singletons (rate helpers, locks).
- Use `readonly` on fields set only in constructors.
- Prefer **constructor injection** in helper classes to make them unit-testable without a protocol mock.
- Prefer interfaces (`IResponseParser`) when multiple implementations may exist — allows mocking in tests.
- Add `<summary>` XML documentation on all public types and methods.

### Unit Testing

Write unit tests for **every public method** in the precompile QAction, and for non-trivial `Run` logic in individual QActions.

Coverage targets:
- Parser methods: valid input, null/empty input, malformed JSON, partial data.
- Table-fill logic: correct row count, correct column values, empty-list edge case.
- `Run` method: tested via `SLProtocolMock` to verify parameter reads and table writes.

Load `dataminer-unit-testing` for full testing patterns, `SLProtocolMock` usage, and `IAsserter` fluent assertions.

### RTDisplay

Set `<RTDisplay>true</RTDisplay>` only when necessary. If a parameter is accessed externally but not displayed, add a comment explaining why and set `onAppLevel="true"`.

---

## QAction_Helper

The `qaction-helper-generation` tool generates connector-specific conveniences from `protocol.xml`. The official connector template includes this project by default, but generation is not a universal completion gate.

Refresh the helper only when one of these applies:

- The user explicitly requested generated helper output.
- Existing source consumes `Parameter`, `SLProtocolExt`, `{Table}QActionTable`, or `{Table}QActionRow` members and the XML change affects those members.
- New code deliberately adopts generated typed access and the project already follows the helper-based layout.

Do not add a helper project to an intentionally helper-free solution merely because `protocol.xml` changed. Do not edit generated helper code manually.

### What gets generated

- **`Parameter` static class** — `public const int` fields for standalone read parameters, all lowercase (e.g. `Parameter.deviceid`). The `name_pid` suffixed variants (e.g. `Parameter.deviceid_100`) are marked `[EditorBrowsable(Never)]` — use the un-suffixed form.
  - Write parameter constants are in nested `Parameter.Write.xxx`.
  - Table nested class `Parameter.{Tablename}` with `tablePid`, `indexColumn`, `indexColumnPid`, and sub-classes `Pid` (column PIDs) and `Idx` (column indices)
- **`SLProtocolExt : SLProtocol` interface** — connector-specific scalar properties (including generated read/dummy accessors), a `Write` property for write accessors, and a `{tablename}` property of type `{Tablename}QActionTable` for each table
- **`ConcreteSLProtocolExt`** — generated implementation primarily useful with typed unit-test mocks
- **`{Tablename}QActionTable`** — implements `IEnumerable<{Tablename}QActionRow>`, directly enumerable with `foreach`
- **`{Tablename}QActionRow`** — typed `System.Object` properties per column; implicit conversion to/from `object[]`

These generated members are documented by [`Parameter`](https://aka.dataminer.services/skyline-data-miner-scripting-parameter), [`SLProtocolExt`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-ext), [`QActionTable`](https://aka.dataminer.services/skyline-data-miner-scripting-q-action-table), and [`QActionTableRow`](https://aka.dataminer.services/skyline-data-miner-scripting-q-action-table-row).

### Usage Examples

```csharp
// When the QAction references QAction_Helper, change the entry point directly to take SLProtocolExt:
public static void Run(SLProtocolExt protocol)
{
    try
    {
        // 1. Typed scalar read/write (PascalCase, no magic numbers)
        string deviceId = Convert.ToString(protocol.Deviceid);
        protocol.Firmwareversion = "2.1.0";

        // 2. Parameter constants in raw protocol calls (lowercase un-suffixed form)
        object value = protocol.GetParameter(Parameter.deviceid);
        protocol.SetParameter(Parameter.firmwareversion, "2.1.0");
        protocol.SetParameter(Parameter.Write.channelname, "My Channel"); // write param

        // 3. Table PID and column PIDs via Parameter.{Tablename}
        protocol.FillArray(Parameter.Channelstable.tablePid, columns);

        protocol.FillArrayWithColumn(
            Parameter.Channelstable.tablePid,
            Parameter.Channelstable.Pid.channelname,  // column PID
            keys,
            values);

        int nameIdx = Parameter.Channelstable.Idx.channelname; // column array index (= 1)

        // 4. Generated table wrappers are bound to one table PID.
        foreach (ChannelstableQActionRow row in protocol.channelstable)
        {
            string key   = Convert.ToString(row.Channelindex);
            string name  = Convert.ToString(row.Channelname);
            double power = Convert.ToDouble(row.Channelactivepower);
        }

        // 5. Building a typed row and writing it
        var newRow = new ChannelstableQActionRow
        {
            Channelindex = "1",
            Channelname  = "CH1",
            Channeloutput = 1,
        };
        protocol.channelstable.SetRow(newRow, createRow: true);
    }
    catch (Exception ex)
    {
        protocol.Log($"QA{protocol.QActionID}|Run|{ex}", LogType.Error, LogLevel.NoLogging);
    }
}
```

**Rules:**
- When a current helper is referenced, use `SLProtocolExt protocol` as the entrypoint parameter type directly (`public static void Run(SLProtocolExt protocol)`) — do NOT cast `(SLProtocolExt)protocol` or `as SLProtocolExt`.
- In a helper-free project, use `public static void Run(SLProtocol protocol)` and declare descriptive local constants to call the base `SLProtocol` APIs directly.
- Prefer `protocol.PropertyName` over `protocol.GetParameter(id)` for scalar reads/writes when the typed `SLProtocolExt` interface is available.
- Prefer `{Tablename}QActionRow` and `{Tablename}QActionTable` only when the project already consumes generated typed wrappers.
- `GetColumns` and `SetColumns` are not generated helper members; they require `Skyline.DataMiner.Utils.Protocol.Extension`.

---

## Protocol Communication Rules

- **Do not wait until protocol timeout** — handle timeouts proactively.
- Handle **invalid serial responses** gracefully.
- Communication must **match the vendor's documented API**.
- After a **set**, always verify by re-reading the value.
- **NEVER write a QAction that contains only a simple if-check** — use XML `<Condition>` elements on groups, timers, or triggers instead. QActions add C# compilation overhead and are harder to trace than XML conditions. See `dataminer-xml-authoring` skill for condition syntax.
- Use QActions **only when no other protocol constructs** (conditions, triggers, actions) can achieve the behavior.

---

## JSON Parsing & HTTP Response Handling

Use `Skyline.DataMiner.Utils.SecureCoding` for JSON deserialization (typed models or JObject/JArray). Standard HTTP pattern: trigger after poll group -> read raw response -> deserialize -> fill parameters/tables. DataMiner stores dates as OLE Automation doubles (`DateTime.ToOADate()`).

> **Full reference**: `dataminer-qaction/references/parsing-patterns.md` — typed deserialization, JObject/SelectToken, JSON-to-table fill, HTTP response pattern, DateTime handling (ISO 8601, Unix epoch, OA date, multi-format).

---

## Advanced Patterns

Inter-element communication (`GetParameterByData`/`SetParameterByData`/SLNet), custom table context menus, multithreaded timer QActions with thread safety, InterApp cross-element messaging, DSI middleware (OpenConfig/Ember+), and common NuGet packages.

> **Full reference**: `dataminer-qaction/references/advanced-patterns.md` — complete code examples, XML definitions, NuGet package table, and `SecureCoding.Analyzers` configuration.

---

## Rate Calculations

Rate calculations convert incrementing counters into per-second rates. Use `Skyline.DataMiner.Utils.Rates.Common` for custom/non-SNMP DateTime or TimeSpan-based counters, and `Skyline.DataMiner.Utils.Rates.Protocol` for SNMP counters that use `SnmpDeltaHelper` with timeout/restart handling.

> **Before implementing rate calculations**, read `dataminer-qaction/references/rate-calculations.md` for helper classes, code patterns (Custom/SNMP, standalone/table), and key behaviours. For XML parameter structure and wiring, see `dataminer-xml-authoring/references/rate-calculation-xml.md`.

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| `protocol.ExecuteGroup(groupId)` — **does not exist** | Use `protocol.CheckTrigger(triggerId)` to fire a trigger that runs the group via an action chain |
| QAction class inside a namespace | `public class QAction` must be at **global scope** — no namespace wrapper (DataMiner silently never fires a namespaced entry point) |
| Simple if-check in a QAction | Use an XML `<Condition>` element on the group, timer, or trigger instead |
| Calling protocol methods inside a loop | Collect all values into arrays first, then call `SetParameters`/`FillArray` once outside the loop |
| Scattered numeric parameter IDs (e.g., `protocol.SetParameter(1001, ...)`) | Use current generated `Parameter.xxx` constants, or descriptive local constants in an intentionally helper-free project |
| `e.Message` in exception logging | Use `e.ToString()` — `e.Message` loses the stack trace |
| `new CultureInfo("en-US")` for number parsing | Use `CultureInfo.InvariantCulture` |
| Writing manual rate/delta calculations | Use `Skyline.DataMiner.Utils.Rates.Common` for custom/non-SNMP counters or `Skyline.DataMiner.Utils.Rates.Protocol` for SNMP counters |
| Blank line immediately after `{` (SA1505) or before `}` (SA1508) | **NEVER** add blank lines inside brace blocks, including empty `try` bodies. For stub/not-yet-implemented bodies use `// TODO: Implement.` as the sole placeholder line. See the **Stub / AfterStartup QAction** example above. |
| Trailing whitespace (SA1028) | **NEVER** leave trailing whitespace (spaces or tabs after the last visible character on any line). Ensure every line ends cleanly at the last code/comment character. |
| Calling methods on the wrong API surface | Call built-in table APIs on `SLProtocol`; when using generated properties/table wrappers, change the entry point parameter directly to `SLProtocolExt` (no casting); add/import `Skyline.DataMiner.Utils.Protocol.Extension` for `GetColumns`/`SetColumns`. |
