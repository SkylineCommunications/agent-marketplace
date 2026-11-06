# DataMiner Automation C# Rules (Anti-Hallucination)

Concrete rules for writing the C# half of an Automation script. Mirrors the spirit of the connector `dataminer-qaction-rules.md`, but for the **Engine (`IEngine`) API**, not `SLProtocol`.

> **Parent skill**: `dataminer-automation-scripting/SKILL.md`. Engine surface: `dataminer-automation-core/references/engine-api-overview.md`. Version, invocation, and security/state boundaries: `dataminer-automation-core/references/version-compatibility.md`, `invocation-and-entry-points.md`, and `security-permissions-credentials.md`.

---

## Entry point & structure

- **`public class Script` inside a namespace** named after the script. Entry point `public void Run(IEngine engine)`.
  ```csharp
  // ✅ CORRECT
  namespace My_Script_1
  {
      using System;
      using Skyline.DataMiner.Automation;

      public class Script
      {
          public void Run(IEngine engine) { /* ... */ }
      }
  }
  ```
  > Do **not** apply the QAction rule ("class at global scope"). Automation scripts are namespaced; QActions are not.
- **`using` directives go inside the namespace**, `System.*` first, then `Skyline.*`.
- Keep the **`Run` → `RunSafe`** split. Rethrow `ScriptAbortException`, `ScriptForceAbortException`, `ScriptTimeoutException`, and, for IAS, `InteractiveUserDetachedException`. For unexpected `Exception ex`, log `"Run|Unexpected exception: " + ex.ToString()` and call `engine.ExitFail("Runtime operation failed.")`.

## Engine API — real vs invented

- ✅ Verified public in the pinned 10.6.9.1 API: `GetScriptParam(int)`, `GetScriptParam(string)`, `GetMemory(int)`, `GetMemory(string)`, `GenerateInformation(string)`, `Log(string)` plus documented overloads, `ExitSuccess(string)`, `ExitFail(string)`, `ShowUI(UIBuilder)`, `ShowUI(string)`, `ShowUI(string, bool)`, `SendSLNetMessage(DMSMessage)`, `FindElement`, `FindElementByKey`, `FindElementsByProtocol`, `GetDummy`, and `PrepareSubScript`.
- ❌ Verified absent: `GetScriptParamValue<T>`, `SendMessage(DMSMessage)`, parameterless `ShowUI()`, and `FindDataMinerObject(...)`. Raw `SendSLNetMessage` is public but version-fragile; use a typed API when one exists.
- ✅ Real on `Element`: `GetParameter(pid)`, `SetParameter(pid, value)`, `GetParameterByPrimaryKey(pid, key)`, `SetParameterByPrimaryKey(pid, key, value)`, `IsActive`, `ElementName`, `DmaId`, `ElementId`.
- ❌ Do **not** use `SLProtocol`/QAction members here (`protocol.FillArray`, `SLProtocolExt`, `Parameter.xxx` constants, `protocol.CheckTrigger`). Those belong to connectors, not automation scripts.
- ❓ Anything else: confirm in the API reference before using. Never invent.

## Automation threading policy (hard rule)

- The entry point is synchronous `public void Run(IEngine engine)`. Do not use an async entry point or `async void`.
- Do not use `Task.Run`, `Parallel.For`, `Parallel.ForEach`, or manually started threads.
- Keep `IEngine`/`Engine` and every object obtained through it—`Element`, dummy, `ScriptParam`/memory, sub-script, `IDms`, and all related DataMiner objects—on the original `Run` thread.
- An external async-only library call may be consumed synchronously with `GetAwaiter().GetResult()` only when no Engine-derived/DataMiner object is passed, captured, or moved. Retain only plain detached returned data, then continue DataMiner work on `Run`.

## Reflection policy (hard rule)

- ❌ Do **not** use reflection for known API surfaces in Automation scripts: `Type.GetType`, `Assembly.Load`, `GetMethod`, `GetProperty`, `Invoke`, runtime overload scans.
- ✅ Use strongly-typed calls instead, e.g.:
  - `engine.PrepareSubScript(...)`
  - `SubScriptOptions.SelectScriptParam(...)`, `StartScript()`, `HadError`, `GetErrorMessages()`, `GetScriptResult()`
  - `engine.GetUserConnection()` and assistant helper APIs through their typed NuGet reference
- Reflection is only acceptable for truly optional/unknown external integrations, and only with explicit rationale in code comments.

## Input handling

- Script-parameter values often arrive wrapped: `["actual value"]`. Normalize:
  ```csharp
  string raw = engine.GetScriptParam(10).Value.Trim().TrimStart('[', '"').TrimEnd('"', ']');
  ```
- Validate and fail fast:
  ```csharp
  if (String.IsNullOrWhiteSpace(raw)) { engine.ExitFail("Element identifier is required."); return; }
  ```
- Parse with `CultureInfo.InvariantCulture` and `TryParse`; never assume locale.

## Element access

- Always null-check and active-check:
  ```csharp
  var element = engine.FindElement(name);
  if (element == null) { engine.ExitFail("The requested element was not found."); return; }
  if (!element.IsActive) { engine.ExitFail("The requested element is not active."); return; }
  ```
- For tables / many cells, prefer the **DataMinerSystem library** (`engine.GetDms()`, `Skyline.DataMiner.Core.DataMinerSystem.Automation`) over per-row `*ByPrimaryKey` calls inside loops.

## Identity, credentials, locks, and outputs

- Record the actual invocation identity and required Automation/element permissions; do not assume the author or scheduler account is the runtime identity.
- From DataMiner 10.7.0/10.6.10 onward, use the target-verified `engine.GetCredential(...)` flow for Credentials Library entries. Handle `null` and never log or persist retrieved secrets.
- Never put credentials or raw sensitive payloads in script parameters, memory, outputs, information events, manifests, or test artifacts.
- Keep locks bounded and release them on every exit path. Avoid holding locks across UI waits, network calls, long polling, or subscript execution.
- Use `NoKeyCaching` only for a demonstrated stale table-key mapping risk. Validate output keys/cardinality/values before success; a natural return alone does not prove a valid result.
- Treat `PrepareSubScript` and its options/result members as target-version APIs. Define subscript inputs, outputs, failure propagation, and cleanup before calling it.

## Exit states

- Returning naturally from `Script.Run(IEngine)` is valid successful completion.
- Use `engine.ExitSuccess(...)` only when an explicit success message/result is required. Use `engine.ExitFail(...)` for failures.
- `Exit*` raises `ScriptAbortException` — **expected**. Re-throw it, along with force-abort, timeout, and interactive-detach exceptions.
- Do not force `ExitSuccess` from a terminal IAS event when natural return is sufficient.

## IAS version and runtime decisions

Use NuGet package `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` and C# namespace `Skyline.DataMiner.Utils.InteractiveAutomationScript`. Pin the Toolkit version before choosing its controller lifecycle; these controller calls are unrelated to the `Script.Run(IEngine)` entry point.

| IAS Toolkit version | Initial-dialog call |
|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` starts the loop; `ShowDialog` switches or queues only a subsequent dialog. |
| `9.0.2` through `9.0.11` | Prefer `controller.ShowDialog(initialDialog)`; controller `Run` is obsolete. |
| `>= 10.0.1` | Use `controller.ShowDialog(initialDialog)`; controller `Run` is no longer public. |

Explicit `<Interactivity>` is supported from DataMiner 10.5.9/10.6.0: use `Never` for no UI, `Optional` for UI only when needed, `Always` for always UI and preferably operator-facing low-code IAS, and `Auto` only for legacy string-detection compatibility. Earlier targets omit the unsupported element and use legacy automatic detection.

| Control | Rule |
|---|---|
| `RunTimeFlags.NoKeyCaching` | Disables only table key-mapping caching. Use it only if a documented operation can change a table-key mapping and make its cached mapping stale; otherwise omit it. |
| `engine.Timeout` | The default code-block timeout is 10 minutes. Override only for a documented, bounded operation or UX requirement; omit the override when the default is adequate. Never use a generic generous or multi-hour timeout. |

## Audit events, diagnostics, and failures

- Use `engine.GenerateInformation("Method|material action")` only for a meaningful end-user audit event: a material lifecycle/CRUD change or operator action.
- Never use information events for tracing, debugging/progress, routine output, counts/missing keys, per-row/item loops, exception details, or secrets.
- Use `engine.Log("Method|detail")` sparingly for non-sensitive trace/diagnostic detail.
- Unexpected exceptions use exactly:
  ```csharp
  catch (Exception ex)
  {
      engine.Log("Run|Unexpected exception: " + ex.ToString());
      engine.ExitFail("Runtime operation failed.");
  }
  ```
- Never expose exception text/message/stack, credentials, tokens, raw payloads, or sensitive inputs through `ExitFail`. Keep logs free of secrets and raw sensitive data.

## Project / build

- `net48`, C# 7.3. **No** `<Nullable>enable</Nullable>`.
- Build with `dotnet build`; resolve **all** Skyline analyzer (`SLC*`) and StyleCop (`SA*`) findings.
- Validate DMSScript XML against the pinned XSD and document-wide `@id` uniqueness rule with `dataminer-automation-xml/scripts/validate-dmsscript-xml.ps1` (`dotnet build` does not validate DMSScript XML; there is no vendor DIS/CICD automation validator CLI).

## Common mistakes to avoid

- Treating the script like a QAction (global class, `SLProtocol`, `Parameter.` constants). ❌
- Forgetting to rethrow runtime/detach exceptions, or exposing `ex.Message`/`ex.ToString()` through `ExitFail`. ❌
- Using async entry points, `async void`, `Task.Run`, parallel loops, manual threads, or any cross-thread Engine-derived object. ❌
- Forcing `ExitSuccess` when a natural successful return is sufficient. ❌
- Adding `NoKeyCaching` without a documented stale table-key mapping risk, or extending the 10-minute timeout without a bounded operation/UX requirement. ❌
- Reading a script parameter that has no `<ScriptParameter>` in the XML (or ID mismatch). ❌
- Leaving `<Exe id="1">` unchanged after adding `<ScriptParameter id="1">`, `<Protocol id="1">`, or `<File id="1">` (every descendant `@id` across the entire DMSScript document shares one document-wide namespace; move `<Exe id>` to `max + 1`, see `dataminer-automation-xml`). ❌
- Per-row table writes inside a large loop instead of `IDms` bulk access. ❌
- Adding `<Nullable>enable</Nullable>` (CS8630 on net48). ❌
