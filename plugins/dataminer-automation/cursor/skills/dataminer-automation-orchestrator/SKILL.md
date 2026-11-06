---
name: dataminer-automation-orchestrator
description: 'Orchestrator reference material for DataMiner Automation script development: Script Map format, plan templates (FEATURE/BUGFIX/INVESTIGATION/REVIEW), skill-routing table, and SDK/NuGet planning rules. Loaded by the dataminer-automation-orchestrator agent for planning and delegation.'
argument-hint: 'Describe the automation task: e.g. "create a script that sets a parameter", "add an interactive confirmation step", "investigate why the scheduled script fails", "review my automation script"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-27
  version: 1.6
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.6 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 1.5 | 2026-09-14 | Added explicit project-mode planning for SDK work and approved maintenance of existing Cube-inline sources without silent migration. |
| 1.4 | 2026-09-14 | Added the pinned DMSScript contract decision: XSD validity, document-wide descendant IDs, exact project links, and bidirectional numeric parameter parity. |
| 1.3 | 2026-09-18 | Added mandatory Run-thread, canonical error/privacy, audit/logging, and verified Engine API planning decisions. |
| 1.2 | 2026-09-18 | Added mandatory target, IAS lifecycle/interactivity, key-cache, timeout, and completion decisions to Automation plans, routed package-backed Automation solution wiring, install hooks, Catalog metadata, and package/deployment status boundaries to `dataminer-sdk/references/package-project-reference.md` as the shared authority, and corrected the IAS Toolkit NuGet package identifier in planning guidance. |
| 1.1 | 2026-09-15 | Added specialized contract routing and plan requirements for GQI, SRM, User-Defined API, and Node Recovery work. |
| 1.0 | 2026-06-27 | Initial release. |

> **Paired agent**: `dataminer-automation-orchestrator` — owns the Phase 1-6 workflow, persona, classify table, and subagent delegation. This skill owns the Script Map, plan templates, and skill routing. Keep shared concepts (phase names, classify categories) in sync.

- Automation dev guide: https://docs.dataminer.services/develop/devguide/Automation/index.html
- DMSScript XML schema: https://docs.dataminer.services/develop/schemadoc/SchemaAutomationScript.html
- C# API: https://docs.dataminer.services/develop/api/types/Skyline.DataMiner.Automation.html
- IAS Toolkit: https://docs.dataminer.services/develop/devguide/Automation/Howto/Getting_Started_with_the_IAS_Toolkit.html

Load `dataminer-automation-core` first for shared concepts and constraints. For specialized work, load exactly the
feature skill selected by the contract matrix: `dataminer-gqi-ad-hoc-data-source`,
`dataminer-srm-automation`, `dataminer-user-defined-api`, or `dataminer-node-recovery`. Load `dataminer-sdk`
whenever the plan touches project setup, build, packaging, publish, or official Skyline tool selection. Load
`dataminer-nugets` whenever the plan touches NuGet package selection or package-specific API usage. Load
`dataminer-dis` when the user works in Visual Studio with DIS available.
For a package-backed Automation solution, also load
`dataminer-sdk/references/package-project-reference.md`; that file is the
single authority for package-project wiring, install hooks, Catalog metadata,
and package/deployment status boundaries.
For any DMSScript analysis or change, also load `dataminer-automation-xml` and treat it as the single owner of the
pinned closed-world XML contract; planning guidance must reference it rather than duplicate schema grammar.

## Reference Files

| Topic | Reference File |
|-------|---------------|
| Script Map template, plan formats (FEATURE/BUGFIX/INVESTIGATION/REVIEW), lightweight mode | `references/plan-templates.md` |
| Specialized contract detection, routing, version/configuration fields, and validation boundaries | `references/specialized-contract-matrix.md` |

---

## SDK-First Planning Rule

REVIEW and INVESTIGATION are report-only. Apply
`dataminer-manifest/references/read-only-assessment.md` before diagnostics or coordination;
skip implementation/repair gates and require separate approval before fixing findings.

- Every implementation plan must record project mode. Greenfield/new work uses the official SDK project template and exact `[Project:<intended-project-name>]` linkage; existing SDK work keeps its verified link. Only an explicitly user-targeted maintenance/bugfix/feature on an existing legacy Cube-inline artifact may preserve and edit inline source, without silently migrating it or adding a project marker.
- SDK-mode plans name the official Skyline SDK, template, Dev Pack, and NuGet packages used (for example, `dataminer-automation-project`, `Skyline.DataMiner.Dev.Automation`, and the IAS Toolkit package). A legacy-inline maintenance plan instead identifies the selected C# `Exe` `<Value>` as source and records whether an existing build mirror matches it; this is not a generic manual fallback or permission for greenfield inline authoring.
- If another manual approach is proposed, the plan must explain why the official Skyline tool could not be used.
- **There is no standalone vendor DIS/CICD Automation validator CLI.** Plans schema-validate DMSScript XML and verify document-wide `@id` uniqueness against the XSD pinned by `dataminer-automation-xml` using `dataminer-automation-xml/scripts/validate-dmsscript-xml.ps1`, then run `dotnet build` (with Skyline analyzers `SLC*`) for an SDK solution or existing matching inline build mirror and optionally DIS. Do not invent a marker/mirror for validation or schedule a `dataminer-validator` automation run; report when maintained inline code has no supported local compilation path.
- Plans that change a shipped/published script must state whether a Catalog version bump (`Version` / `VersionComment` in the `.csproj`) is required.

## Specialized contract routing

Do not classify a task only as Automation versus IAS. Record these independent dimensions:

| Dimension | Required values/examples |
|---|---|
| Contract | Normal `Run`, IAS, GQI ad hoc source, SRM role, SRM typed callback, UDAPI `OnApiTrigger`, Node Recovery local/global |
| Host/trigger | Manual, Scheduler, Correlation, Visio, GQI, SRM, UserDefinableApiEndpoint, Node Recovery, or another verified host |
| Interaction | Non-interactive, operator-interactive, or explicitly prohibited for the contract |
| Runtime | DataMiner/CU/build, GQI API track, SRM Dev Pack, endpoint/DxM compatibility |
| Identity/configuration | Script/library/class identity, route/token/endpoint, SRM configuration, Node Recovery settings |
| Validation | Build/static contract checks plus the matching host-level test when available |

The four feature skills own platform facts. This skill owns routing and plan completeness. Existing specialist agents
remain reusable; do not create a duplicate feature-agent hierarchy unless a concrete evaluation failure proves one is
needed.

## Required Automation/IAS Decision Record

Every implementation or review plan records the target DataMiner core version, web version when applicable, Automation Dev Pack, IAS Toolkit version when applicable, project model, and invocation host. New work is SDK-first. Legacy Cube-inline scripts remain supported for review and investigation. Headless IAS is considered only when explicitly requested and must be labeled non-authoritative.

For IAS, select the Toolkit version before recording exactly one initial-dialog API:

| IAS Toolkit version | Selected initial-dialog API |
|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` starts the loop; `ShowDialog` only switches or queues a subsequent dialog. |
| `9.0.2` through `9.0.11` | `controller.ShowDialog(initialDialog)` is preferred; controller `Run` is obsolete. |
| `>= 10.0.1` | `controller.ShowDialog(initialDialog)`; controller `Run` is no longer public. |

Do not confuse these controller members with the required script entry point `Script.Run(IEngine)`.

For DataMiner 10.5.9/10.6.0 or later, record the UX-based XML choice: `Never` for no UI, `Optional` for UI only when needed, `Always` for always-UI workflows and preferably operator-facing low-code IAS, or `Auto` only for legacy string-detection compatibility. For earlier targets, record that the unsupported `<Interactivity>` element will be omitted and legacy automatic detection applies.

| Decision | What the plan must record |
|---|---|
| Table key cache | Whether a concrete operation can change a table-key mapping and make the cached mapping stale. Use `NoKeyCaching` only for that documented risk; otherwise explicitly omit it. |
| Timeout | Whether the default 10-minute code-block timeout meets the operation/UX requirement. Omit `engine.Timeout` when it does; otherwise document a bounded override and its rationale. Never propose a generic generous or multi-hour timeout. |
| Completion | Natural successful return or a deliberately required `ExitSuccess` message/result. Keep `ExitFail` for failures and re-throw abort/detach exceptions. |

## NuGet Package Selection

Before proposing changes, load `dataminer-nugets`. **Prefer official Skyline packages over custom implementations.** Most relevant for automation:
- **`Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkitToolkit`** — the IAS Toolkit NuGet package package (any non-trivial interactive UI); its C# namespace is `Skyline.DataMiner.Utils.InteractiveAutomationScript`.
- **`Skyline.DataMiner.Core.DataMinerSystem.Automation`** — strongly-typed element/table access (`IDms`).
List and pin target-compatible package versions in the plan so the user can review them before implementation; never select a version merely because it is latest.

## Required Automation/IAS Decision Record

Every implementation or review plan records the target DataMiner core version, web version when applicable, Automation Dev Pack, IAS Toolkit version when applicable, project mode, invocation host, and intended C# source. It also records pinned-XSD validity, the full document-wide descendant-ID inventory and next ID, exact intended SDK project links when applicable, bidirectional numeric parameter parity with name-based calls separate, the synchronous Run-thread boundary, any detached external async-only call, canonical error/privacy behavior, meaningful audit events versus sparse diagnostics, and target-verified Engine APIs. Greenfield/new work is always SDK-first and never creates inline source. Legacy Cube-inline scripts remain supported for review and read-only investigation; only explicitly user-targeted maintenance/bugfix/feature work may preserve and edit the selected C# `Exe` `<Value>`, without silent migration or a new project marker. Any existing inline build mirror must match that source. The XML/C# parity, document-wide ID, pinned-XSD, lifecycle/interactivity, and runtime decisions apply in every mode. Headless IAS is considered only when explicitly requested and must be labeled non-authoritative.

For IAS, select the Toolkit version before recording exactly one initial-dialog API:

| IAS Toolkit version | Selected initial-dialog API |
|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` starts the loop; `ShowDialog` only switches or queues a subsequent dialog. |
| `9.0.2` through `9.0.11` | `controller.ShowDialog(initialDialog)` is preferred; controller `Run` is obsolete. |
| `>= 10.0.1` | `controller.ShowDialog(initialDialog)`; controller `Run` is no longer public. |

Do not confuse these controller members with the required script entry point `Script.Run(IEngine)`.

For DataMiner 10.5.9/10.6.0 or later, record the UX-based XML choice: `Never` for no UI, `Optional` for UI only when needed, `Always` for always-UI workflows and preferably operator-facing low-code IAS, or `Auto` only for legacy string-detection compatibility. For earlier targets, record that the unsupported `<Interactivity>` element will be omitted and legacy automatic detection applies.

| Decision | What the plan must record |
|---|---|
| DMSScript contract | Validation against the XSD pinned by `dataminer-automation-xml`; every descendant `@id` in one document-wide inventory plus the next available ID; exact `[Project:<intended-project-name>]` links for SDK actions; the selected C# `Exe` `<Value>` and matching existing build mirror for maintained inline mode; exact equality between XML parameter IDs and numeric `engine.GetScriptParam(int)` IDs in the intended source in both directions. Name-based calls are listed separately. |
| Table key cache | Whether a concrete operation can change a table-key mapping and make the cached mapping stale. Use `NoKeyCaching` only for that documented risk; otherwise explicitly omit it. |
| Timeout | Whether the default 10-minute code-block timeout meets the operation/UX requirement. Omit `engine.Timeout` when it does; otherwise document a bounded override and its rationale. Never propose a generic generous or multi-hour timeout. |
| Completion | Natural successful return or a deliberately required `ExitSuccess` message/result. Keep `ExitFail` for failures and re-throw abort/detach exceptions. |
| Thread boundary | Synchronous `Run`; the plan must not allow an async entry point, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, a manual thread, or a cross-thread Engine-derived/DataMiner object. External async-only calls are synchronously reduced to detached plain data. |
| Error/privacy | Rethrow abort/force-abort/timeout/IAS-detach. Unexpected `Exception ex` logs `"Run|Unexpected exception: " + ex.ToString()` and calls `ExitFail("Runtime operation failed.")`; never expose diagnostics or sensitive data through `ExitFail`. |
| Audit/logging | `GenerateInformation` only for meaningful material lifecycle/CRUD/operator audit events; never tracing/progress, routine output, counts/missing keys, per-item loops, exceptions, or secrets. Keep `Log` sparse and non-sensitive. |
| API evidence | Verify members for the selected package. Reject `GetScriptParamValue<T>`, `SendMessage(DMSMessage)`, parameterless `ShowUI()`, and `FindDataMinerObject(...)`. Raw `SendSLNetMessage(DMSMessage)` is version-fragile and secondary to typed APIs. |

---

## Skill Reference

| Activity | Skill to Load |
|----------|---------------|
| Automation concepts, runtime, Engine API overview, routing | `dataminer-automation-core` |
| Official Skyline SDK/templates/Dev Packs/packaging/deploy | `dataminer-sdk` |
| Code-relevant DIS workflows in Visual Studio | `dataminer-dis` |
| New automation solution scaffolding | `dataminer-sdk` (load `references/automation-template-reference.md`) |
| `DMSScript` XML authoring (params, memory, dummies, options, Exe) | `dataminer-automation-xml` |
| C# Engine (`IEngine`) logic | `dataminer-automation-scripting` |
| Interactive UI (IAS Toolkit, widgets, dialogs) | `dataminer-interactive-automation` |
| Skyline NuGet package selection and package APIs | `dataminer-nugets` |
| Unit tests with an `IEngine` mock | `dataminer-automation-unit-testing` |
| GQI compiled ad hoc data source | `dataminer-gqi-ad-hoc-data-source` |
| SRM roles, orchestration, profile/lifecycle callbacks | `dataminer-srm-automation` |
| User-Defined API authoring and endpoint contracts | `dataminer-user-defined-api` |
| Node Recovery local/global state-change callbacks | `dataminer-node-recovery` |
| Approved Skyline example/starter repositories | `dataminer-github-example-finder` |
| Shared multi-agent run state / structured logging | `dataminer-manifest` / `dataminer-logging` |
| Package-backed Automation solution lifecycle | `dataminer-sdk/references/package-project-reference.md` |

---

## Constraints

- **NEVER skip the planning phase.** Every task gets a plan before implementation.
- **NEVER implement before building the Script Map** (for existing scripts).
- **NEVER propose any descendant XML `@id` without checking the complete document-wide ID inventory** in the Script Map and recording the next available document-wide ID; treat scaffolded `<Exe id="1">` as provisional and place `<Exe id>` at `max(all used descendant @id values) + 1` when `id="1"` is assigned to a parameter, dummy, or memory file.
- **ALWAYS use official Skyline SDK/templates/Dev Pack/packaging tools for greenfield/new work and SDK-mode maintenance.** Explicit maintenance of an existing legacy Cube-inline artifact is not permission for generic manual authoring and must not trigger an unapproved migration or project marker. State why for any other manual fallback.
- **ALWAYS validate** changed DMSScript XML against the pinned XSD and document-wide `@id` uniqueness rule using `dataminer-automation-xml/scripts/validate-dmsscript-xml.ps1`, then run the applicable code-quality gate: `dotnet build` (+ Skyline analyzers) for an SDK solution or existing matching inline build mirror. Do not invent a `dataminer-validator` CLI mode, create a marker/mirror solely for validation, or conceal an unavailable inline compilation path.
- **ALWAYS verify the Automation runtime contract** in `dataminer-automation-core/references/runtime-safety-and-errors.md`: Run-thread-only access, canonical safe errors, audit-only information events, sparse non-sensitive logs, and selected-version public APIs.
- **Author the XML definition and intended C# source together**. For intended numeric binding, XML `ScriptParameter@id` values and numeric `engine.GetScriptParam(int)` IDs must be exact sets in both directions; name-based calls do not establish numeric parity. Every SDK C# action must retain the exact intended `[Project:<name>]` link. In explicitly maintained legacy inline mode, the selected C# `Exe` `<Value>` is source and any existing build mirror must match it.
- **Investigation tasks are read-only** until the user approves a fix. Greenfield/new implementation remains SDK-first and never creates inline source. Existing Cube-inline scripts are valid review/investigation inputs and may be preserved and edited only when the user explicitly targets maintenance/bugfix/feature work on that artifact; do not migrate it or add a project marker without approval.
- For interactive scripts, prefer the **IAS Toolkit** over low-level `engine.ShowUI(UIBuilder)`; load `dataminer-interactive-automation`, pin its version, and apply its version-specific lifecycle rather than offering an ambiguous API choice.
- For API members not covered by the loaded specialist skills, verify against the selected `Skyline.DataMiner.Automation` package/API reference; do not invent members or use reflection. Public raw SLNet messaging remains version-fragile and is not a substitute for a typed API.
