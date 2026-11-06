---
description: "Guard rails for DataMiner connector QAction C# code. Enforces .NET Framework 4.8 (net48), C# 7.3, zero-error compilation, multi-file QAction_1 project structure, and prevents hallucinated SLProtocol methods, namespace errors, and common C# anti-patterns."
applyTo: "**/QAction_*/**/*.cs,**/QAction_*.cs"
version: "1.8"
updated: "2026-10-23"
---

# DataMiner QAction C# — Guard Rails

> For comprehensive QAction patterns, load the `dataminer-qaction` skill and `dataminer-qaction/references/example-json-table.md`.
> **Scope**: These guard rails apply to all C# source files in `QAction_<id>/` projects (including nested folder/class files under `QAction_1/` and `QAction_N/`). Do not manually edit auto-generated `QAction_Helper/QAction_Helper.cs`, and use `dataminer-unit-testing` for `QAction_Tests/` unit test projects.

## Target Framework, Language Version & Compilation Gate (CRITICAL)

- **For DataMiner connector QActions, ALWAYS target `.NET Framework 4.8` (`<TargetFramework>net48</TargetFramework>`) and `C# 7.3` (`<LangVersion>7.3</LangVersion>`).**
- **NEVER set `<LangVersion>` higher than `7.3` (such as `8.0`, `9.0`, `10.0`, `latest`, or `preview`) or change `<TargetFramework>` away from `net48` in `QAction_*.csproj` or `Directory.Build.props`.** DataMiner's `SLScripting` runtime and the CICD Validator (`[Critical][3.4.1] CompilationFailure`, `[Warning][3.4.3] NoCSharpCodeAnalysisPerformed`) compile QActions using C# 7.3 on .NET Framework 4.8.
- **NEVER use C# 8.0, C# 9.0, or newer language features in QActions** (causes compiler error `CS8370`):
  - ❌ Target-typed `new(...)` (`List<string> items = new();`) → ✅ `var items = new List<string>();` or `List<string> items = new List<string>();`
  - ❌ File-scoped namespaces (`namespace MyConnector.Common;`) → ✅ Block-scoped `namespace MyConnector.Common { ... }`
  - ❌ `record` types or `init` accessors (`public string Id { get; init; }`) → ✅ Standard `class` with `{ get; set; }`
  - ❌ Switch expressions (`status switch { "OK" => 1, _ => 0 }`) → ✅ Traditional `switch (status)` statement
  - ❌ C# 9 pattern combinators (`is not null`, `is > 0 and < 10`) → ✅ `!= null`, `> 0 && < 10`
  - ❌ `using var` declarations without braces → ✅ `using (var stream = ...)` block
  - ❌ Null-coalescing assignment (`list ??= new List<string>();`) → ✅ `if (list == null) { list = new List<string>(); }`
  - ❌ Nullable reference types (`string?`, `<Nullable>enable</Nullable>`, `#nullable enable`, null-forgiving `!.`) → ✅ Standard C# 7.3 reference types without `<Nullable>`
  - ❌ Index/range operators (`items[^1]`, `items[1..3]`), static local functions (`static void Helper()`), or default interface methods
- **HARD COMPILATION GATE — Only fully compiling code (`dotnet build` passing with 0 errors) may ever be returned to the user or committed/pushed to a PR.** Always run `dotnet build` after any QAction edit and resolve every compilation error before finishing.

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
  // ❌ WRONG — magic number
  protocol.GetParameter(1003);

  // ❌ WRONG — PascalCase or camelCase on Parameter constants (causes CS0117 once DIS generates QAction_Helper.cs)
  protocol.GetParameter(Parameter.DevicesStatus);
  protocol.GetParameter(Parameter.devicesStatus);

  // ✅ CORRECT with generated helper (Parameter and Parameter.Write constants are ALL LOWERCASE)
  protocol.GetParameter(Parameter.devicesstatus);
  protocol.GetParameter(Parameter.Write.devicesstatus);

  // ✅ CORRECT without generated helper (or for <Type>dummy</Type> trigger IDs, which are never in Parameter)
  const int DevicesStatusPid = 1003;
  protocol.GetParameter(DevicesStatusPid);
  ```
- **NEVER manually write or hand-synthesize `QAction_Helper/QAction_Helper.cs`.** Always generate it from `protocol.xml` using `dataminer-qaction-helper-generator` (`qaction-helper-generation` or `Skyline.DataMiner.Files.QActionHelper`) and read the actual generated `QAction_Helper.cs` before referencing `Parameter.*` constants. Note:
  - Standalone read/write constants in `Parameter.<name>` and `Parameter.Write.<name>` are **100% lowercase** (e.g. `<Name>apiKey</Name>` → `Parameter.apikey`, `Parameter.Write.apikey`).
  - Table class names in `Parameter.<Tablename>` have **only the first letter capitalized and the rest lowercase** (e.g. `<Name>channelsTable</Name>` → `Parameter.Channelstable`), its fixed table PID field is `tablePid` (camelCase `t`, never `TablePid`), and `Pid`/`Idx` column constants are **100% lowercase** (`Parameter.Channelstable.Pid.channelname`).
  - `<Type>dummy</Type>` parameters (such as `afterStartup`) are **never** emitted into `public static class Parameter` — declare a descriptive `const int` for dummy trigger IDs instead of `Parameter.Afterstartup` or `Parameter.afterstartup`.
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
- **`public class QAction` entry point**: `using` directives at file top, before the class. No enclosing namespace. Keep `QAction_N/QAction_N.cs` as a thin orchestrator focused on the entry point.
- **All other classes/helpers**: `using` directives **inside** the `namespace` declaration (`System` usings first). When multiple `.cs` files exist in a QAction project, `ProtocolBuilder.CombineProjectFiles` concatenates them; top-level `using` statements outside a `namespace` in secondary files cause compiler error `CS1529` (`[Critical][3.4.1] CompilationFailure`) and StyleCop `SA1200`.
- **Allman bracing**: opening brace on its own line. Never omit optional braces.
- **QAction 1 (`precompile`) project structure — avoid one giant `.cs` file**:
  - Place code shared across multiple QActions (and reusable domain models/DTOs, parsers, table builders, API helpers, managers, and enums) in **QAction 1 (`options="precompile"`)** — never duplicated across individual QActions.
  - **Code in `QAction_1` (or any complex `QAction_N` project) does NOT have to stay in `QAction_1.cs`.** Organize `QAction_1/` into logical folders, sub-namespaces, and separate `.cs` files (one primary public type per file, e.g., `QAction_1/Models/DeviceItem.cs`, `QAction_1/Parsers/DeviceItemParser.cs`, `QAction_1/Helpers/TableHelper.cs`). SDK-style `QAction_*.csproj` and the DataMiner CICD assembler/validator automatically compile and combine all `**/*.cs` files in the project directory.
  - **Never declare a global `public class QAction` entry point in `QAction_1`** (`precompile` has no triggers; a global `QAction` class causes `CS0436` type conflicts when referenced by `QAction_N`). Replace or remove the scaffolded `MyClass` placeholder stub in `QAction_1/QAction_1.cs` when adding real structured class files.
  - When `QAction_N` consumes types from `QAction_1`, add `<ProjectReference Include="..\QAction_1\QAction_1.csproj" />` to `QAction_N/QAction_N.csproj` (keeping NuGet `PackageReference` versions identical across QAction projects to prevent `[Major][3.38.1] UnconsolidatedPackageReference`) and set `dllImport="[ProtocolName].[ProtocolVersion].QAction.1.dll"` on `<QAction id="N">` in `protocol.xml`.

## Canonical Pattern Reference

Load `dataminer-qaction/references/example-json-table.md` for complete working examples of:
- JSON response → FillArray table (Pattern 1)
- Bulk GetParameters / SetParameters (Pattern 2)
- FillArrayWithColumn single-column update (Pattern 3)
- SetRow/AddRow single-row selection (Pattern 4)
- QAction 1 precompile shared helpers (Pattern 5)
