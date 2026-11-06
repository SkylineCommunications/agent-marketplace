---
name: dataminer-automation-core
description: Foundation skill for all DataMiner Automation script tasks. Explains what an Automation script is, how it executes at runtime through the Engine (IEngine) API, the difference between non-interactive and interactive (IAS) scripts, and routes to the right specialist skill for any task. Load this skill first — always.
argument-hint: 'Describe the task or question: e.g. "set a parameter on an element", "build an interactive dashboard script", "schedule a cleanup script", "read a table from a script"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-18
  version: 1.6
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.6 | 2026-09-16 | Added version-compatibility, invocation/entry-point, and security/permissions/credentials authorities with explicit lock, table-key, output, and subscript boundaries. |
| 1.5 | 2026-09-14 | Added the single-thread runtime contract, canonical safe error wrapper, audit-only information-event rules, and pinned Engine API evidence. |
| 1.4 | 2026-09-14 | Added version-gated IAS lifecycle and interactivity decisions, made key-cache and timeout controls conditional, and clarified natural successful completion. |
| 1.3 | 2026-09-15 | Added the boundary between normal `Run(IEngine)` scripts and GQI, SRM, User-Defined API, and Node Recovery contracts, plus a versioned documentation and package source map for reproducible maintenance and target-specific source selection, and corrected the IAS Toolkit package identifier. |
| 1.2 | 2026-08-13 | Made SDK scaffolding mandatory before specialist implementation when creating a new Automation solution. |
| 1.1 | 2026-07-13 | Added hard rule to avoid reflection for known Automation API members and prefer typed calls. |
| 1.0 | 2026-06-27 | Initial release. Automation-script counterpart of `dataminer-connector-core`. |

---

# DataMiner Automation Core

## What is DataMiner?

DataMiner is a **network management and monitoring platform** by Skyline Communications. Besides monitoring devices through **connectors**, it provides an **Automation engine** (`SLAutomation`) that runs C# **Automation scripts** for workflows, provisioning, orchestration, and interactive operator tooling.

DataMiner runs as cooperating Windows services (`SLDataMiner`, `SLProtocol`, `SLScripting`, `SLAutomation`, `SLNet`, …). Automation script C# is compiled and executed by the scripting/automation runtime.

---

## What is an Automation Script?

An Automation script is an **XML definition + C# code** that DataMiner executes on demand or on a trigger. It is **not** a connector and does **not** use `SLProtocol`/QActions.

- **Script definition** — a `DMSScript` XML file (`xmlns="http://www.skyline.be/automation"`) holding the name, type, **script parameters**, **memory files**, **dummies** (element placeholders), options, and one or more `<Exe>` C# blocks (in the SDK these reference the compiled project via `[Project:Name]`).
- **C# logic** — a `public class Script` with entry point **`public void Run(IEngine engine)`** in the **`Skyline.DataMiner.Automation`** namespace. All interaction with DataMiner goes through the **`IEngine`** object.

> A modern SDK automation project (`dataminer-automation-project`) scaffolds three co-located files named after the script: `<Name>.cs`, `<Name>.csproj`, `<Name>.xml`.

### Specialized Automation boundary

Not every DataMiner feature that is authored or deployed through the Automation ecosystem is a normal
`Run(IEngine)` script. Classify the contract before applying the runtime flow above:

| Contract | Core shape | Route to |
|---|---|---|
| GQI ad hoc data source | Compiled `IGQIDataSource` library with columns and explicit pages | `dataminer-gqi-ad-hoc-data-source` |
| SRM | Role/configuration-driven script or a version-matched typed callback | `dataminer-srm-automation` |
| User-Defined API | `OnApiTrigger` with `ApiTriggerInput`/`ApiTriggerOutput` (legacy `Run` is a separate compatibility shape) | `dataminer-user-defined-api` |
| Node Recovery | `OnNodeRecoveryLocalStateChange` or `OnNodeRecoveryGlobalStateChange` callback | `dataminer-node-recovery` |

These contracts may still use a `DMSScript` definition or an Automation package, but they do not inherit the normal
script-parameter/exit/UI assumptions. Record the host/trigger, identity/configuration, target version, and validation
surface separately. If the evidence is only a name or a prose description, verify it against the official template,
package, or configuration rather than guessing.

### Script types

| Type | Use When | Key traits |
|------|----------|-----------|
| **Automation (non-interactive)** | Background/triggered logic: set parameters, provision, clean up, orchestrate | `Script.Run(IEngine)` does the work and may return naturally on success; use `ExitSuccess` only for an explicit success result and `ExitFail` for failures. |
| **Interactive Automation Script (IAS)** | Operator-facing UI (wizards, dashboards, forms) | Uses a verified `engine.ShowUI(...)` overload or the **IAS Toolkit** (`InteractiveController`, `Dialog`, widgets). Pin the target versions before choosing the controller lifecycle API and XML interactivity mode. |

### How a script is triggered

From a Visio shape, a correlation rule, the Scheduler, the Alarm Console shortcut menu, a redundancy-group switchover, another script/connector, a low-code app, or manually from Cube. (See docs links below.)

---

## How an Automation Script executes (runtime flow)

```
Trigger (UI / scheduler / correlation / Visio / connector / app)
   │
   ▼
SLAutomation loads the DMSScript definition
   │
   ▼
public void Run(IEngine engine)        ◀── synchronous entry point; all DataMiner work stays on this thread
   │   ├── read inputs: engine.GetScriptParam(id).Value, dummies, memory
   │   ├── act:        engine.FindElement(...), engine.GetDummy(...), element.SetParameter(...)
   │   ├── (IAS only): use the version-selected InteractiveController initial-dialog API
   │   └── finish:     return naturally, or use ExitSuccess for an explicit result; ExitFail for failure
   ▼
Script ends. Long-running/abort/timeout surface as ScriptAbortException / ScriptForceAbortException / ScriptTimeoutException.
```

### Key concepts

| Concept | What It Does |
|---------|-------------|
| **IEngine** | The script's gateway to DataMiner — find elements/services, read/set parameters, get script params, log, show UI, exit. |
| **Script parameter** | Typed input declared as `<ScriptParameter>` in the XML, read with `engine.GetScriptParam(id)`. |
| **Dummy** | A placeholder for an element the script acts on, declared in the XML and resolved at runtime. |
| **Memory file** | A named lookup/keyed store referenced by the script. |
| **Exit state** | A normal return is successful. `engine.ExitSuccess` is only for an explicit success message/result; `engine.ExitFail` reports failure. Both `Exit*` calls raise `ScriptAbortException` (expected). |
| **IAS** | Interactive layer: verified `engine.ShowUI(...)` overloads at low level, or the **IAS Toolkit** high level (`InteractiveController` + `Dialog` + widgets). |

### Required IAS and runtime decisions

Select the task-specific target DataMiner core/web versions, Automation Dev Pack, and IAS Toolkit version before authoring. Do not give an unqualified `Run / ShowDialog` choice. Use SDK projects for new work; retain legacy Cube-inline support for review and investigation. Use headless IAS only when explicitly requested, and label that flow non-authoritative.

| IAS Toolkit version | Initial-dialog API | Meaning |
|---|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` | Starts the interactive loop. `ShowDialog` only queues or switches to a subsequent dialog. |
| `9.0.2` through `9.0.11` | `controller.ShowDialog(initialDialog)` | Preferred initial-dialog API; controller `Run` is obsolete and produces `CS0618`. |
| `>= 10.0.1` | `controller.ShowDialog(initialDialog)` | Controller `Run` is no longer public. |

These are `InteractiveController` members. They are unrelated to the required Automation entry point `Script.Run(IEngine)`, which remains the script entry point.

Explicit `<Interactivity>` values are supported from DataMiner feature release 10.5.9 and main release 10.6.0:

| Value | Use |
|---|---|
| `Never` | The script has no UI. |
| `Optional` | The script shows UI only when the workflow needs it. |
| `Always` | The script always shows UI; prefer this for operator-facing low-code IAS. |
| `Auto` | Legacy string-detection compatibility only; it is not the universal default. |

For earlier DataMiner versions, omit `<Interactivity>` because the element is unsupported; legacy automatic detection applies.

| Runtime decision | Rule |
|---|---|
| `RunTimeFlags.NoKeyCaching` | This disables only table key-mapping caching. Use it only when a documented workflow can make a table-key mapping stale while the script runs; otherwise omit it. |
| `engine.Timeout` | A code block has a 10-minute default timeout. Override it only for a documented, bounded operation or UX requirement; omit it when 10 minutes is adequate, and never apply a generic generous or multi-hour timeout. |
| Successful completion | Let the entry point return naturally unless the caller or operator explicitly needs a success message/result; only then use `ExitSuccess`. Do not force `ExitSuccess` from terminal IAS events. |

### Runtime thread and error contract (must be respected)

Automation script entry points are synchronous. Do not use an async entry point, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, or manually started threads. `IEngine`/`Engine` and everything obtained through it—including `Element`, dummies, `ScriptParam`/memory, sub-script, and `IDms` objects—must remain on the original `Run` thread. External async-only library calls may be consumed synchronously with `GetAwaiter().GetResult()` only when they receive no Engine-derived/DataMiner object and return plain detached data; continue all DataMiner work on the `Run` thread.

`Script.Run(IEngine)` must rethrow `ScriptAbortException`, `ScriptForceAbortException`, `ScriptTimeoutException`, and, for IAS, `InteractiveUserDetachedException`. The final unexpected-exception handler is:

```csharp
catch (Exception ex)
{
    engine.Log("Run|Unexpected exception: " + ex.ToString());
    engine.ExitFail("Runtime operation failed.");
}
```

Full unexpected diagnostics belong only in `Log`; `ExitFail` must be concise, stable, and non-secret. Never expose exception text/message/stack, credentials, tokens, raw payloads, or sensitive inputs through `ExitFail`. Natural return remains valid success. Load `references/runtime-safety-and-errors.md` for the complete contract and audit-event rules.

---

## Hard Rules (Anti-Hallucination)

> **Do NOT invent Engine/IEngine API members.** Pinned 10.6.9.1 evidence confirms `GetScriptParam(int)`, `GetScriptParam(string)`, `GetMemory(int)`, `GetMemory(string)`, `GenerateInformation(string)`, `Log(string)` plus documented overloads, `ExitFail(string)`, `ExitSuccess(string)`, `ShowUI(UIBuilder)`, `ShowUI(string)`, `ShowUI(string, bool)`, `SendSLNetMessage(DMSMessage)`, `FindElement`, `FindElementByKey`, `FindElementsByProtocol`, `GetDummy`, and `PrepareSubScript`. It confirms that `GetScriptParamValue<T>`, `SendMessage(DMSMessage)`, parameterless `ShowUI()`, and `FindDataMinerObject(...)` are absent. Raw `SendSLNetMessage` is public but version-fragile; prefer a typed API. Verify any other member against the selected target package.

> **Do NOT use reflection to call known Automation members.** Avoid runtime probing (`GetMethod`, `GetProperty`, `Type.GetType`, `Assembly.Load`) for known Engine/sub-script APIs. Prefer compile-time typed calls.

> **Respect the namespace convention.** The Automation `public class Script` lives **inside a namespace** (named after the script) — unlike a QAction's global-scope `public class QAction`. Do not copy QAction rules blindly.

> **Do NOT invent NuGet packages or XML elements.** Use the `DMSScript` schema (`dataminer-automation-xml`) and the package catalog (`dataminer-nugets`). For interactive UI use the official IAS Toolkit package (`Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit`); its C# namespace is `Skyline.DataMiner.Utils.InteractiveAutomationScript`.

> **Do NOT guess element names, parameter IDs, table layouts, or service structure.** State what is missing and ask.

> **There is no vendor DIS/CICD Automation validator CLI.** Quality = `dataminer-automation-xml/scripts/validate-dmsscript-xml.ps1` (pinned-XSD + document-wide `@id` uniqueness) + `dotnet build` + Skyline analyzers (`SLC*`) + (optionally) DIS. Do not invent a `dataminer-validator` automation mode, and never rely on `dotnet build` alone to catch DMSScript XML or `@id` errors.

> **Specialized contracts need specialized validation.** Build/static checks do not prove GQI discovery or paging,
> SRM booking behavior, an HTTP route, or Node Recovery cluster semantics. Use the compatible host-level surface when
> it is available and explicitly label runtime checks that cannot be run.

> **Prefer canonical examples over invention.** Load `references/example-automation-script.md` and the example files in the specialist skills, and follow them exactly.

> **New project means SDK scaffold first.** Before writing XML or C# for a new Automation project, load `dataminer-sdk` and use the official `dataminer-automation-project` template. A standalone generated project is valid; create a `.sln` when the task requests a solution or contains multiple projects.

---

## Skill Routing Table

Use this table to decide which skill(s) to load for a task.

| Task | Load Skill(s) |
|------|---------------|
| Plan and delegate a multi-step automation task | `dataminer-automation-orchestrator` |
| Create a new automation script solution from scratch | `dataminer-sdk` (load `references/automation-template-reference.md`) |
| Write or edit the `DMSScript` XML (params, memory, dummies, options, Exe) | `dataminer-automation-xml` |
| Write or modify the C# Engine (`IEngine`) logic | `dataminer-automation-scripting` |
| Build an interactive UI (wizards, forms, dashboards) | `dataminer-interactive-automation` |
| Implement a GQI ad hoc data source | `dataminer-gqi-ad-hoc-data-source` |
| Implement an SRM role, orchestration, profile/lifecycle, or callback script | `dataminer-srm-automation` |
| Implement a User-Defined API endpoint | `dataminer-user-defined-api` |
| Implement a Node Recovery state-change script | `dataminer-node-recovery` |
| Write unit tests for an automation script | `dataminer-automation-unit-testing` |
| Official Skyline SDK/templates/Dev Pack/packaging/deploy | `dataminer-sdk` |
| Find the right Skyline NuGet package or package API | `dataminer-nugets` |
| Choose target versions and compatibility behavior | `references/version-compatibility.md` |
| Map invocation context, inputs, outputs, locks, table keys, or subscripts | `references/invocation-and-entry-points.md` |
| Review identity, permissions, Credentials Library, secret flow, or cleanup | `references/security-permissions-credentials.md` |
| Code-relevant DIS workflows in Visual Studio (validation, compare) | `dataminer-dis` |
| Find an approved Skyline example/starter repository | `dataminer-github-example-finder` |
| Shared multi-agent run state / structured logging | `dataminer-manifest` / `dataminer-logging` |

---

## Reference Files

Load on demand — only when relevant.

| File | Contents | Load When |
|------|----------|-----------|
| `references/documentation-source-map.md` | Pinned documentation revision, schema/template/package hashes, topic ownership, and known source conflicts | Maintaining Automation skills or verifying source drift |
| `references/engine-api-overview.md` | Verified `IEngine`/`Engine` surface, including present/absent APIs, inputs, access, logging, exit, and UI | Before writing or reviewing script C# |
| `references/version-compatibility.md` | Target-version intake and version-gated API, IAS, XML, credentials, timeout, and key-cache behavior | Before authoring or changing a target-sensitive script |
| `references/invocation-and-entry-points.md` | Invocation contexts, input/output contracts, thread boundary, timeouts, table keys, locks, and subscripts | Planning or reviewing execution flow |
| `references/security-permissions-credentials.md` | Runtime identity, permissions, Credentials Library, secret handling, lock boundaries, and cleanup | Any security-sensitive or state-mutating script |
| `references/authority-boundaries.md` | Sole owner for Automation XML, API, runtime, security, IAS, testing, DIS, and lifecycle concerns | Maintaining agents or resolving a rule conflict |
| `references/runtime-safety-and-errors.md` | Canonical Run-thread, external async-call, exception, safe failure, information-event, and diagnostic-log contract | Any authoring, review, investigation, or orchestration task |
| `references/example-automation-script.md` | Complete canonical non-interactive script (read script params → find element → set parameter → exit) | Any non-interactive scripting task — follow this pattern |

---

## Source Provenance

Use `references/documentation-source-map.md` when maintaining this skill or any Automation specialist reference. It records immutable source revisions and package checksums while preserving the per-task target-version policy. A newer observed package is a drift signal, not an automatic implementation target.

---

## Documentation Links

| Topic | URL |
|-------|-----|
| Automation dev guide | https://aka.dataminer.services/automation |
| Getting started | https://aka.dataminer.services/getting-started-with-automation-script-7b92f7cf |
| DMSScript XML schema | https://aka.dataminer.services/schema-automation-script |
| C# API — Skyline.DataMiner.Automation | https://aka.dataminer.services/skyline-data-miner-automation |
| DataMinerSystem library (Automation) | https://aka.dataminer.services/skyline-data-miner-core-data-miner-syst-85f222fb |
| Automation script actions | https://aka.dataminer.services/automation-actions |
| UIBlockType overview | https://aka.dataminer.services/ui-block-types-overview |
| Best practices | https://aka.dataminer.services/automation-best-practices-information-events |
| Getting started with the IAS Toolkit | https://aka.dataminer.services/1068hoHHP |
| Make scripts debug-ready (How-to) | https://aka.dataminer.services/how-to-make-your-automation-scripts-debug-ready |
| Script variables | https://aka.dataminer.services/script-variables |
| Script runners | https://aka.dataminer.services/script-runners |
| Credentials in Automation scripts | https://aka.dataminer.services/Automation-credentials |
| Automation permissions | https://aka.dataminer.services/data-miner-user-permissions |
| Coding guidelines | https://aka.dataminer.services/coding-guidelines |
