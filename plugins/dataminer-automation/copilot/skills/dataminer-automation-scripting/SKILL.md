---
name: dataminer-automation-scripting
description: 'C# Engine (IEngine) development for DataMiner Automation scripts: entry point and namespace convention, abort/timeout exception handling, reading script parameters, resolving elements/services, reading/writing parameters and tables, exit states, logging, performance, and Skyline analyzers. Load for any automation-script C# work.'
argument-hint: 'Describe the C# task: e.g. "read a script parameter and set a value on an element", "loop a table and update cells", "exit fail on invalid input", "call another element parameter"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-18
  version: 1.4
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.4 | 2026-09-16 | Routed version, invocation, and security-sensitive C# decisions to the Automation Core authority references. |
| 1.3 | 2026-09-14 | Added Run-thread safety, canonical diagnostic/error handling, audit-only information events, and verified present/absent Engine APIs. |
| 1.2 | 2026-09-15 | Defined the boundary between normal Engine C# and typed GQI, SRM, User-Defined API, and Node Recovery contracts, and aligned IAS lifecycle, XML interactivity, key-cache, timeout, and natural-success guidance with target versions. |
| 1.1 | 2026-07-13 | Added explicit guidance to avoid reflection for known Automation/Assistant APIs and to use typed sub-script + assistant calls. |
| 1.0 | 2026-06-27 | Initial release. Automation-script counterpart of `dataminer-qaction`. |

You are guided here for the **C# half** of a DataMiner Automation script — the `public class Script` with `Run(IEngine engine)`.

> **Skill authorities**: load `dataminer-automation-core` first. For target versions and compatibility, use `dataminer-automation-core/references/version-compatibility.md`; for invocation, inputs/outputs, locks, table keys, and subscripts, use `dataminer-automation-core/references/invocation-and-entry-points.md`; for identity, permissions, credentials, and secret handling, use `dataminer-automation-core/references/security-permissions-credentials.md`; for the Engine API surface, use `dataminer-automation-core/references/engine-api-overview.md`. Load `dataminer-nugets` before selecting Skyline NuGet packages. For interactive UI, load `dataminer-interactive-automation`. For the XML half (script parameters, dummies, memory), load `dataminer-automation-xml`.

This skill is for ordinary C# Automation logic only. Before applying the `Run(IEngine)` pattern, classify the
contract. Route GQI to `dataminer-gqi-ad-hoc-data-source`, SRM roles/callbacks to `dataminer-srm-automation`,
User-Defined APIs to `dataminer-user-defined-api`, and Node Recovery callbacks to `dataminer-node-recovery`.
Those contracts may use C# and an Automation project, but their entry point, inputs, lifecycle, identity, and
validation are host-defined. Do not add a dummy `Run` method merely to satisfy this skill.

## Workflow

1. **Understand the data flow**: What triggers the script? What are the inputs (script parameters, dummies, memory)? What must it read/write/produce? What are the success and failure conditions?
2. **Use the Script Map or explore**: If the orchestrator provided a Script Map, use it. Otherwise read `<Name>.xml` and `<Name>.cs` to learn the script parameters, dummies, and existing logic.
3. **Write the C# logic** following the canonical structure (`Run` → `RunSafe`), keeping all Automation/DataMiner work on the `Run` thread and using the exact unexpected-exception log/stable-failure wrapper from `dataminer-automation-core/references/runtime-safety-and-errors.md`.
4. **Keep XML and C# in sync**: every `engine.GetScriptParam(id)` must match a `<ScriptParameter id="...">` in the XML.
5. **Add NuGet packages** only from the Skyline catalog (`dataminer-nugets`) — e.g. `Skyline.DataMiner.Core.DataMinerSystem.Automation` for typed/bulk access. For IAS, pin `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit`; use C# namespace `Skyline.DataMiner.Utils.InteractiveAutomationScript`.
6. **Build & fix analyzers**: validate DMSScript XML with `dataminer-automation-xml/scripts/validate-dmsscript-xml.ps1` and run `dotnet build`. Resolve all Skyline analyzer findings (`SLC*`) and StyleCop (`SA*`) before reporting back. There is **no** standalone vendor DIS/CICD automation validator CLI.

## Version-gated IAS decisions

Choose the target DataMiner and IAS Toolkit versions before writing interactive code. The controller methods below are distinct from the required `Script.Run(IEngine)` entry point.

| IAS Toolkit version | Initial-dialog API |
|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` starts the loop; `ShowDialog` only switches or queues a subsequent dialog. |
| `9.0.2` through `9.0.11` | Prefer `controller.ShowDialog(initialDialog)`; controller `Run` is obsolete. |
| `>= 10.0.1` | Use `controller.ShowDialog(initialDialog)`; controller `Run` is no longer public. |

Explicit DMSScript interactivity is supported from DataMiner 10.5.9/10.6.0. Use `Never` for no UI, `Optional` for UI only when needed, `Always` for always-UI workflows and preferably operator-facing low-code IAS, and `Auto` only for legacy string-detection compatibility. On earlier targets, omit the unsupported `<Interactivity>` element and rely on legacy automatic detection.

| Runtime control | C# decision |
|---|---|
| `RunTimeFlags.NoKeyCaching` | It disables only table key-mapping caching. Set it only when a documented operation can change a table-key mapping and make the cache stale; otherwise omit it. |
| `engine.Timeout` | The code-block default is 10 minutes. Override only for a documented, bounded operation or UX requirement; omit when the default is adequate and never use a generic generous or multi-hour value. |
| Completion | Natural return is valid success. Use `ExitSuccess` only when an explicit success message/result is required; keep `ExitFail` for failures and re-throw abort/detach exceptions. |

## Constraints

- **Entry point and errors**: use synchronous `public void Run(IEngine engine)` inside `public class Script`. Rethrow `ScriptAbortException`, `ScriptForceAbortException`, `ScriptTimeoutException`, and, for IAS, `InteractiveUserDetachedException`. For unexpected `Exception ex`, call exactly `engine.Log("Run|Unexpected exception: " + ex.ToString());` and then `engine.ExitFail("Runtime operation failed.");`. Never expose exception detail, credentials, tokens, raw payloads, or sensitive inputs through `ExitFail`.
- **Namespace convention**: the class lives **inside a namespace** (named after the script). `using` directives go **inside** the namespace, `System` usings first. (This is the opposite of a QAction, where `public class QAction` is at global scope — do not copy QAction rules.)
- **Run-thread only**: do not use an async Automation entry point, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, or manually started threads. Never move `IEngine`/`Engine` or anything obtained through it (`Element`, dummy, `ScriptParam`/memory, sub-script, `IDms`, and related DataMiner objects) off the original `Run` thread. An external async-only call may be blocked with `GetAwaiter().GetResult()` only with detached non-DataMiner inputs/outputs; resume Engine work on `Run`.
- **Never invent `IEngine`/`Element` members.** Verify against the API reference or `engine-api-overview.md`. Pinned evidence marks `GetScriptParamValue<T>`, `SendMessage(DMSMessage)`, parameterless `ShowUI()`, and `FindDataMinerObject(...)` absent. `SendSLNetMessage(DMSMessage)` is public but version-fragile; prefer typed APIs.
- **Do not use reflection for known APIs.** Avoid `Type.GetType`, `Assembly.Load`, `GetMethod`, `GetProperty`, and runtime signature probing for known Engine/sub-script/assistant members. Prefer compile-time typed calls (`engine.PrepareSubScript`, `SubScriptOptions.*`, `engine.GetUserConnection`, `ChatHelper.*`).

- **Use supported JSON serialization.** Do not use `System.Web.Script.Serialization.JavaScriptSerializer`. Use `Newtonsoft.Json` or `System.Text.Json`, deserializing into a typed DTO rather than a loosely-typed bag.
- **Validate every input.** Script-parameter values often arrive wrapped as `["value"]` — trim `[`, `]`, `"`. Fail fast with a concise stable `engine.ExitFail`; do not echo possibly sensitive raw values unnecessarily.

- **Validate what you produced, not just that you finished.** When a script emits a collection, verify cardinality and keys against the source and fail with a stable message when they disagree. Never publish counts or missing keys through `GenerateInformation`. If non-sensitive diagnostic cardinalities are genuinely needed, log them sparingly with `engine.Log`; do not log sensitive keys or routine result output.
- **Resolve elements robustly** and null-check: `engine.FindElement(name)` vs `engine.FindElementByKey("DmaId/ElementId")`; check `element != null` and `element.IsActive`.
- **Prefer bulk/typed access** via `IDms` (`engine.GetDms()`, `Skyline.DataMiner.Core.DataMinerSystem.Automation`) for table-heavy work — avoid per-row `Get/SetParameterByPrimaryKey` calls inside large loops.
- **Exit states**: a natural return is valid successful completion. Use `engine.ExitSuccess(...)` only for an explicitly required success message/result and `engine.ExitFail(...)` for failures. Never swallow the resulting `ScriptAbortException`.
- **Audit and diagnostics**: use `engine.GenerateInformation(...)` only for a meaningful end-user audit event (material lifecycle/CRUD/operator action), never tracing, progress, routine output, counts/missing keys, per-item loops, exception details, or secrets. Use `engine.Log(...)` sparingly for non-sensitive diagnostics with a `MethodName|` prefix.
- **Target framework `net48`** (C# 7.3). Do **not** add `<Nullable>enable</Nullable>`. Use `CultureInfo.InvariantCulture` for all number/date parsing.
- **Specialized boundary**: do not reference `Skyline.DataMiner.Automation` from a Core GQI data-source library; do
  not treat an API request as a script parameter; do not assume SRM role payloads or Node Recovery enum values
  without the selected version-matched package/template. Static compilation and mocks do not prove host behavior.
- **Interactive scripts**: follow the pinned Toolkit lifecycle and target-gated XML interactivity decisions above; add `RunTimeFlags.NoKeyCaching` only when a documented stale table-key or key-mapping cache risk exists, and add an `engine.Timeout` override only for a bounded requirement, not as generic IAS setup. Handle `InteractiveUserDetachedException` and prefer the IAS Toolkit (`dataminer-interactive-automation`).

## Reference Files

| File | Contents | Load When |
|------|----------|-----------|
| `references/dataminer-automation-rules.md` | Anti-hallucination rules, real-vs-invented Engine members, common mistakes | Before writing or reviewing script C# |
| `references/example-scripts.md` | Pattern library: read script params, resolve element, get/set param, table via `IDms`, exit states, sub-script | Implementing a specific pattern |
