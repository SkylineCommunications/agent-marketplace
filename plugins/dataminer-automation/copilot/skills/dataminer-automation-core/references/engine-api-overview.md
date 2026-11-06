# Engine (IEngine) API Overview

Organized surface of `IEngine`, the Automation script gateway to DataMiner. This is a practical map, not the full API. Verify target-specific behavior against the official reference: https://aka.dataminer.services/skyline-data-miner-automation

> **Parent skill**: `dataminer-automation-core/SKILL.md`. Runtime contract: `runtime-safety-and-errors.md`. C# rules and patterns: `dataminer-automation-scripting`.
> **Pinned evidence**: the present/absent facts below were verified from `Skyline.DataMiner.Dev.Automation` 10.6.9.1 and `Skyline.DataMiner.Files.SLManagedAutomation` 10.6.9.1. Choose the version compatible with the task target rather than treating this evidence version as a default.

---

## Runtime boundary

The Automation entry point is synchronous `public void Run(IEngine engine)`. Keep `IEngine`/`Engine` and everything obtained through it—including `Element`, dummy, `ScriptParam`/memory, sub-script, and `IDms` objects—on the original `Run` thread. Automation scripts must not use async entry points, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, or manually started threads. An external async-only API may be consumed with `GetAwaiter().GetResult()` only when it receives no Engine-derived/DataMiner object and returns plain detached data; continue all DataMiner work on the `Run` thread.

## 1. Reading inputs

| Verified member | Notes |
|---|---|
| `engine.GetScriptParam(int id)` | Returns the declared `ScriptParam`; `.Value` is the raw string. Normalize and validate it without echoing possibly sensitive input in failures. |
| `engine.GetScriptParam(string name)` | Resolves a script parameter by declared name. |
| `engine.GetMemory(int id)` | Resolves declared script memory by ID. |
| `engine.GetMemory(string name)` | Resolves declared script memory by name. |

`GetScriptParamValue<T>` is **absent** from the pinned public API. Do not use it. Script parameters and memory are declared in the `DMSScript` XML; every C# lookup must match that definition.

## 2. Finding elements

| Verified member | Notes |
|---|---|
| `engine.FindElement(string name)` | Resolves an element by name; handle a missing result. |
| `engine.FindElementByKey(string key)` | Resolves the `"DataMinerID/ElementID"` key; handle a missing result. |
| `engine.FindElementsByProtocol(...)` | Resolves elements for a protocol using the target-version overload. |
| `engine.GetDummy(...)` | Resolves a dummy declared in the XML using the target-version overload. |

Always check a resolved `Element` for `null` and `IsActive` before acting. An `Element` or dummy is Engine-derived and must stay on the `Run` thread.

## 3. Reading and writing element parameters

| Member | Notes |
|---|---|
| `element.GetParameter(int pid)` | Read a standalone parameter. |
| `element.SetParameter(int pid, object value)` | Write a standalone parameter. |
| `element.GetParameterByPrimaryKey(int pid, string key)` | Read a table cell by row key. |
| `element.SetParameterByPrimaryKey(int pid, string key, object value)` | Write a table cell by row key. |
| `element.ElementName`, `element.DmaId`, `element.ElementId`, `element.IsActive` | Identity/state used by established patterns. |

For richer typed and bulk element/table access, the DataMinerSystem Automation library exposes `IDms` through `engine.GetDms()`. Verify its API against the selected version. `IDms` and all objects reached through it remain subject to the same `Run`-thread rule.

## 4. Audit events and diagnostic logging

| Verified member | Use |
|---|---|
| `engine.GenerateInformation(string message)` | Only a meaningful end-user audit event: a material lifecycle/CRUD change or operator action. Never trace/debug/progress chatter, routine output, counts/missing keys, per-item loops, exception details, or secrets. |
| `engine.Log(string message)` | Sparse, non-sensitive trace or diagnostic detail. Prefix with `MethodName|`. Additional documented `Log` overloads are also public; prefer the simple string form unless the target contract requires another overload. |

Do not log credentials, tokens, raw payloads, or sensitive inputs.

## 5. Completion and canonical error handling

| Completion | Effect |
|---|---|
| Natural return from `Script.Run(IEngine)` | Valid successful completion and preferred when no explicit result is required. |
| `engine.ExitSuccess(string message)` | Explicit success message/result only; raises expected `ScriptAbortException`. |
| `engine.ExitFail(string message)` | Concise, stable, non-secret failure; raises expected `ScriptAbortException`. |

Rethrow `ScriptAbortException`, `ScriptForceAbortException`, `ScriptTimeoutException`, and, for IAS, `InteractiveUserDetachedException`. Handle an unexpected exception exactly as follows:

```csharp
catch (Exception ex)
{
    engine.Log("Run|Unexpected exception: " + ex.ToString());
    engine.ExitFail("Runtime operation failed.");
}
```

Never expose exception text/message/stack, credentials, tokens, raw payloads, or sensitive inputs through `ExitFail`. See `runtime-safety-and-errors.md` for the complete wrapper.

## 6. Interactive Automation scripts

Use NuGet package `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` with C# namespace `Skyline.DataMiner.Utils.InteractiveAutomationScript`. Pin the Toolkit version before choosing the controller API.

### Initial-dialog lifecycle

| IAS Toolkit version | Initial-dialog call | Contract |
|---|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` | Starts the loop; `ShowDialog` only queues or switches a subsequent dialog. |
| `9.0.2` through `9.0.11` | `controller.ShowDialog(initialDialog)` | Preferred; controller `Run` is obsolete (`CS0618`). |
| `>= 10.0.1` | `controller.ShowDialog(initialDialog)` | Controller `Run` has no public definition. |

These controller lifecycle methods are not the Automation entry point; the script still exposes synchronous `Script.Run(IEngine)`.

### DMSScript interactivity

Explicit `<Interactivity>` is supported from DataMiner 10.5.9/10.6.0. On earlier targets, omit the unsupported element and rely on legacy automatic detection.

| Value | Behavior |
|---|---|
| `Never` | No UI. |
| `Optional` | UI only when needed. |
| `Always` | Always UI; preferred for operator-facing low-code IAS. |
| `Auto` | Legacy string-detection compatibility, not a universal default. |

### UI and runtime controls

| Verified member/default | Decision |
|---|---|
| `engine.ShowUI(UIBuilder)` | Verified low-level builder overload. Use only on the `Run` thread. |
| `engine.ShowUI(string)` | Verified string overload; verify the target contract before use. |
| `engine.ShowUI(string, bool)` | Verified string/Boolean overload; verify the target contract before use. |
| `engine.SetFlag(RunTimeFlags.NoKeyCaching)` | Disables only table key-mapping caching. Use only for a documented stale-mapping risk. |
| `engine.Timeout` (`TimeSpan`) | Code blocks default to 10 minutes. Override only for a documented bounded operation/UX need; never prescribe a generic long timeout. |

A parameterless `ShowUI()` is **absent**. Prefer the IAS Toolkit for non-trivial UIs.

## 7. Advanced

| Verified member | Notes |
|---|---|
| `engine.PrepareSubScript(...)` | Prepares another Automation script using the target-version overload. Keep the returned Engine-derived object on the `Run` thread. |
| `engine.SendSLNetMessage(DMSMessage message)` | Public raw SLNet access, but version-fragile. Prefer a typed API whenever one exists and verify the exact target message contract when unavoidable. |

`SendMessage(DMSMessage)` and `FindDataMinerObject(...)` are **absent**. Use verified element APIs or `engine.GetDms()` instead. Anything not listed here must be confirmed against the selected package/API reference. Call known members directly; do not use reflection or runtime probing.
