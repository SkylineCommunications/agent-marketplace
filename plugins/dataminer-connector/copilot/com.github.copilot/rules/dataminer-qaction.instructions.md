---
description: "Guard rails for DataMiner connector QAction C# code. Prevents hallucinated SLProtocol methods, namespace errors, and common C# anti-patterns."
applyTo: "**/QAction_*.cs"
version: "1.5"
updated: "2026-09-14"
---

# DataMiner QAction C# — Guard Rails

> For comprehensive QAction patterns, load the `dataminer-qaction` skill and `dataminer-qaction/references/example-json-table.md`.

## Entry Point Rules

- **`public class QAction` MUST be at global scope — NEVER inside a namespace.** DataMiner's scripting engine searches for this class at the top level. A namespaced class silently never fires — no error, no log.
  ```csharp
  // ❌ WRONG — QAction never fires
  namespace MyConnector { public class QAction { public static void Run(SLProtocol protocol) {} } }

  // ✅ CORRECT (helper-free)
  public class QAction { public static void Run(SLProtocol protocol) {} }

  // ✅ CORRECT (with QAction_Helper: use SLProtocolExt directly — no casting)
  public class QAction { public static void Run(SLProtocolExt protocol) {} }
  ```
- **Every `Run` entry point MUST have a `try/catch(Exception ex)` wrapper** — unhandled exceptions cause memory leaks in SLScripting.
- **ALWAYS log the full exception with `ex.ToString()` — NEVER `ex.Message`** — `ex.Message` loses the stack trace.
- **Log format**: `$"QA{protocol.QActionID}|MethodName|message"` — always include the QAction ID and method name.

## SLProtocol API Rules

- **NEVER call `protocol.GetParameter()` or `protocol.SetParameter()` in a loop.** Each call is inter-process communication (IPC). Use `protocol.GetParameters(uint[] ids)` and `protocol.SetParameters(int[] ids, object[] values)` for bulk operations.
- **NEVER scatter parameter IDs as magic numbers.** When the project references a current `QAction_Helper`, use its `Parameter.xxx` constants. In an intentionally helper-free project, declare descriptive local constants once and use those.
  ```csharp
  // ❌ WRONG
  protocol.GetParameter(1003);

  // ✅ CORRECT with generated helper
  protocol.GetParameter(Parameter.devicesStatus);

  // ✅ CORRECT without generated helper
  const int DevicesStatusPid = 1003;
  protocol.GetParameter(DevicesStatusPid);
  ```
- **`FillArray`, `FillArrayNoDelete`, `FillArrayWithColumn`, `SetRow`, `AddRow`, and `DeleteRow` are built-in `SLProtocol` members.** Call them directly; no `SLProtocolExt` cast or generated helper is required:
  ```csharp
  protocol.FillArray(DevicesTablePid, tableRows, NotifyProtocol.SaveOption.Full);
  ```
- **`GetColumns` and `SetColumns` come from `Skyline.DataMiner.Utils.Protocol.Extension`.** Add that package and import its namespace before calling them on `SLProtocol`. They are not generated `SLProtocolExt` members.
- **When using generated helper properties/tables, use `SLProtocolExt` directly as the entrypoint parameter type (`public static void Run(SLProtocolExt protocol)`) — never cast `protocol as SLProtocolExt` or `(SLProtocolExt)protocol`.** For helper-free projects (no `QAction_Helper`), use `public static void Run(SLProtocol protocol)`.
- **`protocol.ExecuteGroup()` does NOT exist.** Use `protocol.CheckTrigger(triggerId)` to fire a trigger that executes a group.
- **`protocol.FillTable()` does NOT exist.** Use `protocol.FillArray(...)`.
- **`protocol.ClearTable()` does NOT exist.** Use `FillArray` with an empty list, or selective `DeleteRow`.
- **`protocol.UpdateRow()` does NOT exist.** Use `SetRow` on `SLProtocol`.

## Table Fill Method Selection

| Use Case | Method |
|----------|--------|
| Replace entire table (full current state known) | `FillArray` |
| Add/update rows without deleting absent rows | `FillArrayNoDelete` |
| Update one column without touching others | `FillArrayWithColumn` |
| Update an existing row by primary key | `SetRow` |
| Add a row when its primary key is absent | `AddRow` |

- **`FillArray` large table limits**: < 1000 rows per call, < 20 000 cells per set call.
- **`GetColumns` large table limits**: < 120 000 cells per call.

## Defensive Programming Rules

- **Guard external/untrusted data**: device/API responses, JSON/XML deserialization results, user-entered parameter values. These can be `null`, malformed, or missing fields.
- **Do NOT add redundant guards around SLProtocol methods with a guaranteed contract** — this is dead code that never executes:
  - `protocol.GetColumns(...)` from `Skyline.DataMiner.Utils.Protocol.Extension` returns an `object[]`; validate its documented contract once rather than adding repeated defensive checks.
  - `protocol.GetKeys(...)` always returns a non-null `string[]`.
  - `protocol.GetParameters(ids[])` always returns an `object[]` the same length as `ids[]`.
  - `protocol.GetRow(...)` returns an object array; for a missing key, the current API returns an array containing null cell references and logs the failed lookup. Use `Exists` first when row presence changes control flow.

## Parsing and Conversion Rules

- **ALWAYS use `CultureInfo.InvariantCulture` for all number and date parsing.** Device responses may come from systems with different locale settings.
  ```csharp
  double.Parse(value, CultureInfo.InvariantCulture);   // ✅
  double.Parse(value);                                  // ❌ — locale-dependent
  ```
- Use `String.Empty` instead of `""`. Use `Convert.ToString()` / `Convert.ToDouble()` for safe parameter value conversions.

## NuGet Package Rules

- **NEVER write manual rate/delta/bitrate calculations.** Use `Skyline.DataMiner.Utils.Rates.Protocol`.
- **NEVER write manual SNMP trap parsing.** Use `Skyline.DataMiner.Utils.SNMP.Traps.Protocol`.
- **NEVER write manual safe type conversion.** Use `Skyline.DataMiner.Utils.SafeConverters`.
- **NEVER invent NuGet packages.** Only use packages listed in `dataminer-connector-core/references/nuget-packages.md`.

- **GitHub Packages/NuGet authentication warnings require valid CI package credentials and `packages: read` scope.** Restore credentials/scope; do not classify these warnings as the documented `Sdk.targets` PowerShell fallback or suppress them as compiler diagnostics.
- **NEVER add `<Nullable>enable</Nullable>` to a QAction `.csproj`.** The target is `net48` (C# 7.3) — this causes error CS8630.
- **NEVER call `JsonConvert.DeserializeObject` directly (SLC_SC0004).** Always use `SecureNewtonsoftDeserialization.DeserializeObject` from the `Skyline.DataMiner.Utils.SecureCoding` NuGet package. Add the package reference to the QAction `.csproj` whenever JSON deserialization is used.
  ```csharp
  // ❌ WRONG — triggers SLC_SC0004 build warning
  JObject obj = JsonConvert.DeserializeObject<JObject>(rawJson);
  JArray arr = JsonConvert.DeserializeObject<JArray>(rawJson);

  // ✅ CORRECT
  using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

  JObject obj = SecureNewtonsoftDeserialization.DeserializeObject<JObject>(rawJson);
  JArray arr = SecureNewtonsoftDeserialization.DeserializeObject<JArray>(rawJson);
  ```
- **NEVER log secrets or credential-bearing payloads.** Do not log passwords, tokens, API keys, cookies, complete Authorization headers, or raw request/response bodies that can contain them.
- **NEVER accept every TLS certificate.** A custom `ServerCertificateCustomValidationCallback` must validate `SslPolicyErrors`; returning `true` unconditionally triggers SLC_SC0005.

## Code Style Rules (StyleCop — SA* must be zero)

- **Indentation MUST use 4 spaces** (standard .NET convention) — never tabs in C# files.
- **No blank line immediately after `{` or before `}` (SA1505/SA1508).** For empty stub bodies, use `// TODO: Implement.` — never leave blank lines inside braces.
- **No blank lines at the end of a file (SA1518).** The last line of every `.cs` file must be the closing `}` with no trailing blank lines after it.
- **NEVER use Hungarian notation prefixes on variable names (SA1305).** Name variables by semantic role, never by type. Rename: `swVersion` → `softwareVersion`, `strName` → `name`, `bEnabled` → `isEnabled`, `nCount` → `count`, `objResult` → `result`.
- **`public class QAction` entry point**: `using` directives at file top, before the class. No enclosing namespace.
- **All other classes/helpers**: `using` directives inside the namespace declaration. `System` usings first.
- **Allman bracing**: opening brace on its own line. Never omit optional braces.
- Reusable code goes in **QAction 1 with `precompile` option** — not duplicated across individual QActions.

## Canonical Pattern Reference

Load `dataminer-qaction/references/example-json-table.md` for complete working examples of:
- JSON response → FillArray table (Pattern 1)
- Bulk GetParameters / SetParameters (Pattern 2)
- FillArrayWithColumn single-column update (Pattern 3)
- SetRow/AddRow single-row selection (Pattern 4)
- QAction 1 precompile shared helpers (Pattern 5)
