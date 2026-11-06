# Plan Templates & Script Map

Reference for implementation plan formats (FEATURE/NEW, BUGFIX, INVESTIGATION, REVIEW) and the Script Map structure for DataMiner Automation scripts.

> **Parent skill**: `dataminer-automation-orchestrator/SKILL.md` — return there for phase workflow and constraints.
> **XML contract owner**: `dataminer-automation-xml` and its closed-world reference own all DMSScript structure. These templates record decisions and evidence; they do not redefine the schema.

---

## Confirmed Planning Decisions

These decisions apply to every Automation plan:

1. **Target compatibility is task-specific.** Record the target DataMiner core version, web version when a web/IAS host is involved, Automation Dev Pack version, and IAS Toolkit version when used. Derive values from an existing SDK project when possible. If a required target cannot be inferred, ask the user instead of selecting the latest package.
2. **Greenfield/new authoring is always SDK-first.** New scripts use the official SDK project template, require exact `[Project:<intended-project-name>]` linkage, and never create inline source. Existing legacy Cube-inline scripts remain supported for review and read-only investigation. Only when the user explicitly targets maintenance, a bugfix, or a feature on that existing artifact may a plan preserve and edit its selected C# `Exe` `<Value>`. Do not silently migrate it or add a project marker unless migration is approved; this exception is not permission for generic greenfield inline authoring.
3. **Natural successful return is valid.** Do not require `ExitSuccess` on every successful path. Use it only when the caller or user needs an explicit success message/result. Failures still use `ExitFail`; `ScriptAbortException`, `ScriptForceAbortException`, `ScriptTimeoutException`, and `InteractiveUserDetachedException` are re-thrown.
4. **Headless IAS is explicit-only.** Route to `dataminer-headless-ias` only when the user explicitly requests the WebSocket-based headless flow. Label it non-authoritative and do not substitute it for supported Cube, web, or low-code IAS hosts.
5. **Automation is Run-thread-only.** Plan a synchronous `Run(IEngine)` and do not use async entry points, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, manually started threads, or cross-thread use of `IEngine`/`Engine` or anything obtained through it. An external async-only call may be synchronously consumed only with detached plain inputs/results; all DataMiner work resumes on `Run`.
6. **Errors, audit events, and APIs follow the canonical contract.** Rethrow abort/force-abort/timeout and IAS detach; for unexpected `Exception ex`, log `"Run|Unexpected exception: " + ex.ToString()` and call `ExitFail("Runtime operation failed.")`. Keep `ExitFail` stable/non-secret. Use `GenerateInformation` only for meaningful material lifecycle/CRUD/operator audit events and `Log` sparingly. Verify every Engine member for the selected package.
7. **DMSScript uses one pinned closed-world contract in every project mode.** Validate against the XSD owned by `dataminer-automation-xml`; inventory every descendant `@id` in one document-wide pool and record the next available ID; verify exact intended SDK project links when applicable; require equality between XML parameter IDs and numeric `engine.GetScriptParam(int)` IDs in the intended C# source in both directions. Name-based calls are listed separately and do not establish numeric parity. For explicitly maintained inline mode, the selected C# `Exe` `<Value>` is the intended source and any existing build mirror must match it. The same lifecycle/interactivity and runtime rules apply.
8. **Route ownership is explicit.** The orchestrator owns Script Maps, plans, sequencing, retries, and final status; the scaffolder owns new project creation; the author owns `DMSScript` plus intended C# source; the test writer owns tests; the reviewer and investigator are read-only.
9. **No sideways handoffs.** Specialists return a result to the orchestrator. The orchestrator alone starts the next specialist, retries a failed gate (maximum three attempts), or stops with a blocker.

### IAS lifecycle selection

Pin/select the IAS Toolkit version first and record one initial-dialog API. These are controller members, not the `Script.Run(IEngine)` entry point.

| IAS Toolkit version | Plan decision |
|---|---|
| `<= 9.0.1` | Use `controller.Run(initialDialog)` to start the loop; reserve `ShowDialog` for switching or queuing a subsequent dialog. |
| `9.0.2` through `9.0.11` | Use preferred `controller.ShowDialog(initialDialog)`; controller `Run` is obsolete. |
| `>= 10.0.1` | Use `controller.ShowDialog(initialDialog)`; controller `Run` is no longer public. |

### Interactivity selection

Explicit `<Interactivity>` is supported from DataMiner 10.5.9/10.6.0. On earlier targets the plan must omit the unsupported element and note that legacy automatic detection applies.

| Choice | UX decision on a supported target |
|---|---|
| `Never` | No UI. |
| `Optional` | UI only when needed. |
| `Always` | Always UI; preferred for operator-facing low-code IAS. |
| `Auto` | Legacy string-detection compatibility only, not a universal default. |

### Automation task routes

REVIEW and INVESTIGATION skip implementation and repair gates, even when diagnostics fail.
Use `dataminer-manifest/references/read-only-assessment.md` for disposable diagnostic copies
and external-only coordination writes. Approval of an assessment plan does not authorize fixes.

| Task class | Required map/evidence | Primary route | Final gate |
|---|---|---|---|
| NEW | Requirements, target versions, Script Map skeleton, project identity | Scaffolder → Author → Tests (if applicable) | Pinned-XSD validation + SDK build/analyzers |
| FEATURE / BUGFIX | Complete Script Map and intended source/mirror | Author → Tests (if applicable) | Pinned-XSD validation + applicable build/analyzers |
| INVESTIGATION | Read-only Script Map and evidence | Investigator | Evidence-backed diagnosis; no mutation |
| REVIEW | Full source, project, runtime, and target map | Reviewer | Review findings; no mutation |
| TESTING | Production/test project graph and seam/global-state boundary | Test writer | Exact test project build/run |
| LIVE-TEST | Target, permissions, artifact identity, and rollback boundary | QAOps/live-test route | Target result and rollback evidence |
| RELEASE / DEPLOYMENT / OPERATIONS | Artifact identity, environment, permissions, and rollback/diagnostic plan | Orchestrator + SDK/QAOps/tool-specific route | Immutable artifact, release/deployment/operations evidence |

### Runtime-control decisions

- Record whether a concrete operation can change a table-key mapping and make the cached mapping stale. Use `NoKeyCaching` only for that risk and document it; otherwise omit the flag.
- The default Automation code-block timeout is 10 minutes. Omit `engine.Timeout` when that is adequate. Any override needs a documented, bounded operation or UX requirement; never plan a generic generous or multi-hour timeout.

---

## Script Map Template

Build this map by reading the `DMSScript` XML **and** the intended C# source completely before proposing any changes. This prevents cross-kind descendant-ID collisions, dummy/memory mismatches, incorrect project links or inline-source selection, and XML↔C# drift.

**How to build:**
1. Read `<Name>.xml` (the `DMSScript`) completely and validate it against the XSD pinned by `dataminer-automation-xml`; do not infer a root-child order.
2. Read the intended C# source completely: linked SDK `.cs` files (and every helper/dialog class), or the selected C# `Exe` `<Value>` for a legacy inline artifact plus any existing build mirror.
3. Inventory every descendant `@id` across `Protocol`, `File`, `ScriptParameter`, `Exe`, and any other descendant carrying `@id`; reject cross-kind duplicates, treat any scaffolded `<Exe id="1">` as provisional (move `<Exe id>` to `max + 1` whenever `id="1"` is used by a parameter, dummy, or memory file), and calculate the next available **document-wide ID**.
4. List script parameters (`ScriptParameter@id`, required schema fields, description) and all numeric `engine.GetScriptParam(int)` calls in the intended C# source. Compare the two ID sets in both directions; list name-based calls separately because they do not prove numeric parity. In inline mode, verify that any existing build mirror matches the selected `<Value>` before using it as evidence.
5. List dummies and memory files with their IDs, references, and usage.
6. List every `Exe`, its ID/type, and its value. For SDK actions, verify `[Project:<intended-project-name>]` exactly. For inline C#, identify the selected `Exe` `<Value>` as read-only review/investigation input or as explicitly user-targeted maintenance/bugfix/feature source; record migration/project-marker approval and build-mirror equality separately. Classify other legacy actions without treating them as C# source.
7. Identify script type from target-supported `Interactivity` / IAS usage, plus invocation context and host (manual, scheduled, correlation, API, DOM, Cube, web, low-code IAS component, or explicitly requested headless flow).
8. Identify project mode and package/tool versions: new SDK, existing SDK, explicitly maintained legacy Cube-inline, or legacy Cube-inline in read-only review/investigation. New mode is always SDK; maintained inline mode is allowed only for an existing artifact explicitly targeted by the user and does not imply migration.
9. Map threading/worker constructs, every Engine-derived object flow, external async-only call boundaries, exception/failure privacy, information events/logging, target API calls, and completion behavior.
10. Record schema, ID, project-link, and numeric-parity evidence explicitly rather than reducing them to a generic XML check.

```
## Script Map
- **Name**: [from <Name>]
- **Type**: Automation | Interactive (IAS) | Specialized Automation
- **Contract / Domain**: Normal `Run` | GQI ad hoc source | SRM role/callback | UDAPI `OnApiTrigger` | Node Recovery local/global
- **Host / Trigger**: [subsystem that instantiates or invokes the contract]
- **Target Runtime / Version**: [DataMiner/CU, GQI API track, SRM framework/Dev Pack, endpoint/DxM]
- **Identity / Configuration**: [script/library/class, route/token/definition, SRM configuration, Node Recovery setting]
- **Interactivity**: [from <Interactivity>; IAS toolkit used? InteractiveController/Dialog]
- **Interactivity Choice**: [Never | Optional | Always | Auto on DataMiner 10.5.9/10.6.0+; omitted with legacy auto-detection on earlier targets; UX rationale]
- **Project Model**: SDK project | legacy Cube-inline
- **Project Mode**: new SDK project | existing SDK project | explicitly maintained legacy Cube-inline | legacy Cube-inline (read-only review/investigation)
- **Intended C# Source**: [linked SDK project/source files | selected C# Exe ID and `<Value>`; existing build mirror path and exact-match status or none]
- **Invocation / Host**: [trigger and execution host]
- **Compatibility**:
  | Axis | Selected value | Evidence / source |
  |------|----------------|-------------------|
  | DataMiner core | [version/range] | [project, XML, or user requirement] |
  | DataMiner web | [version/range or not applicable] | [host requirement] |
  | Automation Dev Pack | [package version or not applicable for a legacy inline script] | [project or target-compatible selection] |
  | IAS Toolkit | [package version or not applicable] | [project or target-compatible selection] |
- **IAS initial-dialog API**: [not applicable | Run(initialDialog) | ShowDialog(initialDialog); selected from the pinned Toolkit lifecycle]
- **Stale table-key mapping risk**: [none → omit NoKeyCaching | concrete risk and why the mapping can become stale → use flag]
- **Timeout decision**: [10-minute default adequate → omit override | bounded override plus operation/UX rationale]
- **Completion decision**: [natural successful return | explicit ExitSuccess message/result required]
- **Run-thread decision**: [synchronous Run; prohibited constructs found/absent; every Engine-derived/DataMiner object remains on Run]
- **External async-only calls**: [none | call, detached inputs/plain result, synchronous GetAwaiter().GetResult consumption]
- **Error/privacy decision**: [four runtime/detach rethrows where applicable; exact unexpected log + stable ExitFail; expected failures do not echo sensitive raw input]
- **Audit/logging decision**: [meaningful GenerateInformation events, if any; sparse non-sensitive Log diagnostics; prohibited chatter/counts/missing keys absent]
- **Engine API evidence**: [selected package evidence; absent members/raw SLNet risks found]
- **DMSScript schema**: [valid/invalid against the XSD pinned by dataminer-automation-xml; evidence]
- **Author / Folder**: [from <Author> / <Folder>]
- **Descendant ID Inventory** (include every row/kind, using `none` where absent):
  | XML path / kind | IDs or `none` | XSD ID type | Purpose / references |
  |-----------------|---------------|-------------|----------------------|
  | Protocols/Protocol | [IDs or none] | positiveInteger | [dummy declarations/references] |
  | Memory/File | [IDs or none] | positiveInteger | [memory declarations/references] |
  | Parameters/ScriptParameter | [IDs or none] | unsignedInt | [input declarations/numeric reads] |
  | Script/Exe | [IDs or none] | positiveInteger | [action/project link] |
  | Any other descendant carrying @id | [IDs or none] | [declared type] | [purpose/references] |
- **Next Available Document-Wide ID**: [X, calculated across every descendant @id]
- **Script Parameters / Numeric Parity**:
  | XML ID | Type | Description | Numeric engine.GetScriptParam(int) use | Parity / notes |
  |--------|------|-------------|----------------------------------------|----------------|
  | 10 | string | Element Identifier | engine.GetScriptParam(10).Value | matched; wrapper trimmed |
- **Name-based GetScriptParam calls**: [none | calls listed separately; these do not establish numeric ID parity]
- **Dummies**: [id, expected protocol/element, references, used for]
- **Memory files**: [id, volatility, name/purpose, references]
- **Exe blocks / C# source**: [id, action type, exact [Project:intended-name] and matching SDK project | selected inline C# `<Value>` and read-only/explicit-maintenance status; migration/project-marker approval; build-mirror exact-match status]
- **Referenced elements / services / protocols**: [names, parameter IDs touched]
- **Projects / build mirror**: [<Name>.csproj; helper/library projects; test project | existing inline build mirror and exact-match status | none]
- **NuGet packages**: [IAS Toolkit, DataMinerSystem.Automation, Dev Pack, …]
- **Next Available Script-Parameter ID**: [X]
- **Specialized inputs/outputs/lifecycle**: [typed inputs, outputs, paging, role payloads, HTTP or state semantics]
- **Concurrency / ordering assumptions**: [documented guarantees only; list unknowns explicitly]
- **Validation boundary**: [build/static checks plus compatible host-level test, or why unavailable]
- **Open verification gates**: [signatures, version-gated members, enum values, operational provisioning]
```

---

## Plan Format: FEATURE / NEW

```
## Implementation Plan

### Task: [description]
### Classification: NEW | FEATURE
### Script Type: Automation | Interactive (IAS) | Specialized Automation
### Contract / Host: [exact contract/domain] / [host or trigger]
### Target Runtime: [DataMiner/CU and package/template/API versions]
### Identity & Configuration: [all names, routes, definitions, settings, or external provisioning]

For specialized Automation, include the exact entry point/interface or role, documented input/output semantics,
lifecycle/concurrency behavior, version gates, and explicit open verification items. Do not replace an unavailable
signature with an invented one.
### Project Model: SDK project | legacy Cube-inline (existing review/investigation only)
### Project Mode: new SDK project (required for NEW) | existing SDK project | explicitly maintained legacy Cube-inline (FEATURE only when the user targeted that existing artifact)
### Intended C# Source: [linked SDK project/source files | selected C# Exe ID and `<Value>`; existing build mirror and exact-match status or none]
### Invocation / Host: [manual, scheduled, API, DOM, Cube, web, low-code IAS, explicitly requested headless]

### Target Compatibility
| Axis | Selected value | Evidence / source |
|------|----------------|-------------------|
| DataMiner core | [version/range] | [project, XML, or user requirement] |
| DataMiner web | [version/range or not applicable] | [host requirement] |
| Automation Dev Pack | [package version or not applicable for a legacy inline script] | [project or target-compatible selection] |
| IAS Toolkit | [package version or not applicable] | [project or target-compatible selection] |

### DMSScript Contract Decisions
| Decision | Selection / evidence |
|---|---|
| Pinned-XSD validation | [schema path/pin; current validity; planned revalidation] |
| Descendant ID pool | [complete current inventory; next available document-wide ID; every proposed Protocol/File/ScriptParameter/Exe/other @id] |
| C# action source | [each SDK Exe ID → exact [Project:intended-project-name] → project file | maintained inline Exe ID → selected `<Value>`, no unapproved migration/project marker, build-mirror exact-match status] |
| Numeric parameter parity | [XML ScriptParameter ID set == numeric engine.GetScriptParam(int) set in the intended C# source in both directions; name-based calls separate] |

### IAS / Runtime Decisions
| Decision | Selection | Rationale |
|---|---|---|
| Initial-dialog API | [not applicable | Run(initialDialog) | ShowDialog(initialDialog)] | [pinned Toolkit lifecycle] |
| DMSScript Interactivity | [Never | Optional | Always | Auto | omit for pre-10.5.9/10.6.0] | [UX and target support] |
| Table key cache | [omit NoKeyCaching | use it] | [no stale risk | concrete way a table-key mapping can become stale] |
| Timeout | [10-minute default; omit override | bounded override] | [operation/UX requirement] |
| Successful completion | [natural return | ExitSuccess] | [explicit result/message requirement, if any] |
| Run thread | [synchronous; prohibited worker constructs absent] | [all Engine-derived/DataMiner access remains on Run] |
| External async-only call | [none | synchronous wait with detached plain data] | [no Engine-derived capture/input/result] |
| Unexpected error | [exact Log + stable ExitFail contract] | [runtime/detach rethrows and non-secret user failure] |
| Audit and diagnostics | [meaningful GenerateInformation events or none; sparse Log] | [no trace/progress/count/missing-key/per-item/exception/secret information events] |
| Engine API | [members verified for selected package] | [absent APIs excluded; typed API preferred over raw SLNet] |

### Proposed Descendant ID Allocations
| XML path / kind | ID | Purpose |
|-----------------|----|---------|

**Next available document-wide ID after the proposal:** [X]

### Proposed Script Parameters
| ID | Type | Description | Source / Default | Numeric GetScriptParam(int) use |
|----|------|-------------|------------------|---------------------------------|

### Dummies / Memory (if needed)
| Kind | Name/ID | Purpose |
|------|---------|---------|

### Engine logic (normal Automation only)
- Inputs read (which script params / dummies / memory)
- Elements/services resolved (FindElement / FindElementByKey / GetDms)
- Actions performed (GetParameter / SetParameter / table ops; raw `SendSLNetMessage` only when no typed API exists and its target contract is verified)
- Run-thread object flow and any external async-only call reduced synchronously to detached plain data
- Canonical runtime/detach rethrows, exact unexpected-exception log/stable failure, and non-sensitive expected failures
- Meaningful end-user audit events (if any) versus sparse diagnostic logs
- Completion behavior (natural successful return or an intentional ExitSuccess message; stable ExitFail conditions)

### Interactive UI (IAS only)
- Dialogs and widgets (load `dataminer-interactive-automation`)
- Pinned Toolkit package/version and selected initial-dialog API
- Navigation / button flow
- Supported host and web version
- Target-supported Interactivity value and UX rationale, or legacy omission
- Concrete stale table-key mapping risk decision and 10-minute-default timeout decision
- Headless WebSocket flow only when explicitly requested; label non-authoritative
- IAS callbacks remain subject to the same Run-thread ban; wire-protocol `AsyncCalls` does not authorize script worker threads

### Specialized contract
- Entry point/interface/role and whether normal `Run` is required, optional, or prohibited
- Inputs, outputs, paging/HTTP/state semantics, lifecycle and concurrency
- Identity/configuration required by the host
- Forbidden dependencies or behaviors for this contract
- Host-level validation available (GQI query, PLS Tester/SRM booking, HTTPS API request, or multi-node recovery)

### NuGet Packages
| Package | Purpose |
|---------|---------|
> Interactive UI ⇒ NuGet package `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit`; C# namespace `Skyline.DataMiner.Utils.InteractiveAutomationScript`.
> Bulk/typed element & table access ⇒ `Skyline.DataMiner.Core.DataMinerSystem.Automation`.
> Unit tests ⇒ test framework + `IEngine` mock (load `dataminer-automation-unit-testing`).

### Execution Order
1. Scaffold the new SDK solution, locate the existing SDK solution, or locate the explicitly maintained inline artifact
   without migrating it (load `dataminer-sdk` for SDK work; load the package-project reference when applicable).
2. DMSScript XML — apply the closed-world contract, allocate every descendant ID from the document-wide pool, and set
   exact SDK project links or preserve the selected inline C# `Exe` `<Value>` without an unapproved marker
   (load `dataminer-automation-xml`).
3. Intended C# Engine source (load `dataminer-automation-scripting`); for maintained inline mode, edit the selected
   `<Value>` and keep any existing build mirror identical.
4. Interactive UI, if any (load `dataminer-interactive-automation`).
5. Specialized contract implementation, where applicable (load the selected feature skill).
6. Pure logic/unit tests where meaningful (load `dataminer-automation-unit-testing`).
7. Validate DMSScript against the pinned XSD, then run build + analyzers for the SDK solution or existing matching
   inline build mirror: `dotnet build`. Run deterministic static validators and approved host-level validation only
   when available; report when maintained inline code has no supported local compilation path and do not create a
   marker/mirror solely for validation.
```

---

## Plan Format: BUGFIX

```
## Fix Plan

### Symptoms: [what's broken — error event, wrong result, exception, timeout]
### Root Cause: [from Script Map + code reading — bad input handling, null element, wrong PID, exit logic]
### Project Mode: existing SDK project | explicitly maintained legacy Cube-inline (only when the user targeted that existing artifact)
### Intended C# Source: [linked SDK source | selected C# Exe ID and `<Value>`; existing build mirror and exact-match status or none]
### Target Compatibility: [core/web/Dev Pack/IAS Toolkit versions]
### DMSScript Contract Decisions: [pinned-XSD validity; complete descendant-ID inventory/next document-wide ID; exact intended SDK project links when applicable; selected inline source/no unapproved migration or marker when applicable; XML parameter ID set versus numeric GetScriptParam(int) set both ways in the intended source; name-based calls separate]
### IAS Decisions (if applicable): [selected initial-dialog API; Interactivity value or legacy omission; stale table-key mapping risk/NoKeyCaching decision; 10-minute default or bounded timeout override]
### Runtime/Error/Audit/API Decisions: [Run-thread and external-call boundary; four rethrows; exact Log + stable ExitFail; audit-only GenerateInformation; verified Engine members]
### Fix: [specific XML and/or C# changes]
### Files affected: [<Name>.xml and linked SDK source/helpers | <Name>.xml selected C# Exe `<Value>` and any existing matching build mirror]
### New NuGet Dependencies (if applicable)
| Package | Purpose |
|---------|---------|
### Execution Order: [apply XML skill contract; allocate all IDs; preserve exact SDK links or the selected inline source without unapproved migration/marker; update numeric XML/C# parity together; pinned-XSD validate; build the SDK solution or matching existing inline mirror, or report no supported local compilation path]
```

---

## Plan Format: INVESTIGATION

```
## Investigation Plan

### Symptoms: [what the user reported]
### Hypothesis: [initial theory from Script Map analysis]
### Project Mode: new/existing SDK project | legacy Cube-inline (read-only investigation; no edits or migration)
### Intended C# Source: [linked SDK source | selected C# Exe ID and `<Value>`; existing build mirror and exact-match status or none]
### Target Compatibility: [core/web/Dev Pack/IAS Toolkit versions]
### DMSScript Contract Evidence: [read-only pinned-XSD result; every descendant @id/next document-wide ID; exact SDK project link or selected legacy inline source; two-way numeric parameter parity in that source with name-based calls separate]
### IAS Decision Evidence (if applicable): [initial-dialog API; Interactivity value or legacy omission; stale table-key mapping risk; 10-minute default or bounded timeout override]
### Runtime/Error/Audit/API Evidence: [worker/thread/object-flow trace; external async-only calls; exception privacy; information events/logs; selected-version API status]
### Diagnostic Steps:
1. [read-only schema validation; check all descendant @id values for document-wide collisions; verify intended project link/legacy classification; compare XML IDs with numeric engine.GetScriptParam(int) in both directions and list name-based calls separately]
2. [check element resolution + IsActive]
3. [check synchronous Run, prohibited worker constructs, and cross-thread Engine-derived object flow]
4. [check runtime/detach rethrows, exact unexpected log/stable ExitFail, failure privacy, and natural completion]
5. [check audit-only GenerateInformation, sparse non-sensitive Log, and target-verified APIs]
6. [applicable SDK or existing matching inline-mirror build + analyzer output; report an unavailable inline compilation path; if needed, use the Automation XML skill's schema-valid debug representation without modifying files]
### Execution Trace: [Run → inputs → element resolution → action → exit, with the break point highlighted]
```

Investigation plans do NOT include implementation — only diagnosis. Changes require separate user approval.

---

## Plan Format: REVIEW

```
## Review Plan

### Scope: [full script / specific area]
### Project Mode: new/existing SDK project | legacy Cube-inline (read-only review)
### Intended C# Source: [linked SDK source | selected C# Exe ID and `<Value>`; existing build mirror and exact-match status or none]
### Target Compatibility: [core/web/Dev Pack/IAS Toolkit versions]
### IAS Decision Review (if applicable): [initial-dialog API; Interactivity value or legacy omission; stale table-key mapping risk; 10-minute default or bounded timeout override]
### Runtime/Error/Audit/API Review: [Run-thread/object flow; external async-only calls; exception/failure privacy; information-event/log purpose; selected-version API evidence]
### Checklist:
- [ ] Entry point: Run(IEngine) with the abort/timeout exceptions re-thrown
- [ ] Specialized contract is classified separately from host/trigger; normal `Run` assumptions are not applied to GQI, SRM, UDAPI, or Node Recovery
- [ ] Specialized signature, package/template version, identity/configuration, and version gates are verified
- [ ] Specialized runtime behavior is not claimed from static checks or mocks; the correct host-level validation is named
- [ ] DMSScript validates against the XSD pinned by `dataminer-automation-xml`; no root ordering is invented
- [ ] Every descendant `@id` is unique in one document-wide pool; the next available document-wide ID is recorded
- [ ] Every SDK C# action has the exact intended `[Project:<name>]` link; existing inline code is explicitly classified as a read-only review input, its selected C# `Exe` `<Value>` is treated as source, and any existing build mirror matches it exactly
- [ ] XML script-parameter IDs equal numeric `engine.GetScriptParam(int)` IDs in both directions; name-based calls are separate and do not count as numeric parity
- [ ] Entry point: synchronous `Run(IEngine)`; abort/force-abort/timeout and IAS-detach exceptions rethrown
- [ ] The script must not have an async entry point, `async void`, `Task.Run`, parallel loop, manual thread, or cross-thread Engine-derived/DataMiner object
- [ ] External async-only calls are consumed synchronously and exchange only detached plain data
- [ ] Unexpected exception uses exact `engine.Log("Run|Unexpected exception: " + ex.ToString());` then `engine.ExitFail("Runtime operation failed.");`
- [ ] Namespace convention (class in a namespace, usings inside, System first)
- [ ] Input validation on every script parameter; concise stable ExitFail messages with no exception detail, secret, raw payload, sensitive input, or unnecessary raw lookup value
- [ ] Element resolution null-checked and IsActive-checked
- [ ] No invented IEngine/Element members; absent GetScriptParamValue<T>, SendMessage(DMSMessage), and parameterless ShowUI() excluded; raw SendSLNetMessage justified and target-verified
- [ ] Bulk/typed access (IDms) instead of per-row calls in loops where appropriate
- [ ] Completion behavior correct: natural success allowed; ExitSuccess only for an intentional message/result; ExitFail for failures; abort/detach exceptions re-thrown
- [ ] Interactive: exact Toolkit package/version and C# namespace recorded; initial-dialog API matches the version-specific lifecycle
- [ ] Interactivity: UX choice is `Never`, `Optional`, `Always`, or compatibility-only `Auto` on DataMiner 10.5.9/10.6.0+; the element is omitted on earlier targets
- [ ] `NoKeyCaching` is absent unless a documented operation can change a table-key mapping and make its cached mapping stale
- [ ] The default 10-minute timeout is retained unless a documented, bounded operation/UX requirement justifies an `engine.Timeout` override
- [ ] Headless IAS is used only when explicitly requested and is labeled non-authoritative
- [ ] GenerateInformation only for meaningful lifecycle/CRUD/operator audit events; no tracing/progress, routine output, counts/missing keys, per-item loops, exception details, or secrets; Log sparse and non-sensitive
- [ ] Pinned-XSD validation is clean; the applicable SDK or existing matching inline-mirror build is clean with Skyline analyzers (SLC*) — zero warnings, or an unavailable inline compilation path is reported explicitly
- [ ] Catalog metadata (manifest.yml / Version / VersionComment) if published
- [ ] Unit test coverage for core logic
```

---

## Lightweight Mode

For trivial single-element tasks (e.g., "add one script parameter", "rename a variable"), a brief 3-line plan is sufficient. Full tables are not needed for simple changes. A lightweight plan must still record project mode, intended C# source and inline-mirror status, pinned-XSD validity, every descendant ID plus the next available document-wide ID, exact intended SDK project linkage when applicable, bidirectional numeric parameter parity in the intended source (with name-based calls separate), the Run-thread/external-call boundary, canonical error/privacy behavior, audit/logging intent, and selected-version API evidence. A maintained-inline plan must also record explicit user targeting and no unapproved migration/project marker. A lightweight IAS plan also records target versions, initial-dialog API, Interactivity choice or legacy omission, stale-key risk, timeout, and detach decisions.
