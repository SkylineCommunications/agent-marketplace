# Automation Invocation and Entry Points

Use this reference to map how a script is invoked before choosing its inputs, outputs, permissions, timeout, and test route. The C# entry point is always `public void Run(IEngine engine)`; the invocation context determines how the script is launched and what the operator or caller can observe.

## Invocation map

| Invocation context | Required analysis | Verification boundary |
|---|---|---|
| Manual/Cube or operator UI | Interactive versus non-interactive behavior, user-visible messages, IAS host, and permissions | Run in the supported host or a QAOps target; do not infer UI behavior from a build |
| Scheduler, trigger, correlation, Visio, or connector call | Trigger inputs, execution identity, timeout, natural completion, and failure propagation | Verify the trigger/caller contract and the target runtime |
| Low-code app or web workflow | Input/output contract, UI interactivity mode, permissions, and web-supported APIs | Test the supported web/low-code host; do not assume Cube-only behavior |
| Another Automation script | Subscript parameters, dummy/memory ownership, synchronous completion, and failure propagation | Verify `PrepareSubScript` and the exact target overload/API |
| Legacy Cube-inline script | Selected `Exe` `<Value>` is the source; preserve it for explicit maintenance only | Check XML/C# parity and do not silently migrate to `[Project:...]` |
| SDK-mode script | XML `Exe` action links to the intended project; source is the project C# | Build the solution, validate XML, and verify the project link |

## Inputs and outputs

- Script parameters are declared in `DMSScript` and are string-valued in the pinned schema. Read them with a verified `engine.GetScriptParam(...)` overload, validate/normalize locally, and never echo sensitive values.
- Dummies are XML-declared element placeholders. Resolve them through the target-version Engine API, check for missing/inactive elements, and keep the objects on the `Run` thread.
- Memory files are XML-declared state. Decide whether each is volatile or persistent from the workflow, clear/update it intentionally, and never use memory as a secret store.
- A normal return is successful completion. Use `ExitSuccess` only when the caller needs an explicit result; use a concise stable `ExitFail` message for failure.
- If the script produces rows, keys, or other collections, validate semantic cardinality and key/value consistency before reporting success. Do not mistake "the script exited" for a valid result.

## API boundaries

Verified core members include `GetScriptParam`, `GetMemory`, element lookup, `GetDummy`, `GetDms`, `GenerateInformation`, `Log`, `ExitFail`, `ExitSuccess`, `PrepareSubScript`, and selected `ShowUI` overloads. `GetScriptParamValue<T>`, `SendMessage(DMSMessage)`, parameterless `ShowUI()`, and `FindDataMinerObject(...)` are not part of the pinned public surface. Confirm any unlisted member against the selected package; do not use reflection to probe known APIs.

For table-heavy work, prefer the selected `Skyline.DataMiner.Core.DataMinerSystem.Automation` API and bulk operations. Avoid per-row calls in large loops. `IDms` and every object reached through it remain Engine-derived and must stay on the original `Run` thread.

## Thread, timeout, lock, and subscript rules

- Keep `IEngine`/`Engine`, elements, dummies, parameters, memory, subscript objects, and `IDms` objects on the original `Run` thread.
- Do not use async entry points, `async void`, `Task.Run`, parallel loops, or manually started threads. Only synchronously consume an external async-only API when its inputs and outputs are detached plain data.
- Treat the 10-minute code-block timeout as the default. An override needs a bounded operation/UX rationale and target evidence.
- Use `NoKeyCaching` only when the script can change table keys during its own operation and a stale mapping is a demonstrated risk.
- Subscripts need an explicit input/output/failure contract and target-version API verification. Do not pass Engine-derived objects through external worker tasks or callbacks.

Official sources:

- [Script runners](https://aka.dataminer.services/script-runners)
- [Adding C# code to an Automation script](https://aka.dataminer.services/adding-c-sharp-code-to-an-automation-script)
- [Engine API](https://aka.dataminer.services/skyline-data-miner-automation-i-engine)
- [DataMinerSystem Automation API](https://aka.dataminer.services/skyline-data-miner-core-data-miner-syst-85f222fb)
