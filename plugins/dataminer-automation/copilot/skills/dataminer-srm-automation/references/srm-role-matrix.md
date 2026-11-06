# SRM role matrix

> Parent skill: `dataminer-srm-automation/SKILL.md`.

Use the matrix to classify an SRM request before authoring. A row marked
**signature not confirmed** must be implemented only from a version-matched
official template/example or inspected `SLSRMLibrary.dll`/SRM API types. A role
name is never a license to invent a method signature.

## Core roles

| Role | Runs/purpose | Inputs and outputs | Configuration and constraints | Signature status / validation |
|------|--------------|--------------------|------------------------------|-------------------------------|
| Profile-Load Script (PLS) | Applies profile instances/values to a virtual-function resource when a booking enters a state; LSO or Resource Automation can call it. | SRM supplies `Info` and `ProfileInstance`; validate the `FunctionDve` dummy. Use the documented SRM helpers; throw on configuration failure. | `SRM_ProfileLoadScriptTemplate`; linked protocol-function DVE; PLS Tester. Do not manually parse framework payloads. | Do not infer a typed entry point from the role. Build plus PLS Tester. |
| Lifecycle Service Orchestration (LSO) | Orchestrates service-state transitions such as Start, Stop, and Standby; invokes PLSs sequentially or in parallel. | Role-specific SRM context and configured booking/service data; model the `Action` values `ServiceState`, `Event`, and `PreviousServiceState`. | `SRM_LSOTemplate`; service-definition Actions tab; pre-roll/post-roll; only the final booking update should force-save. | Do not infer a typed entry point. Build plus configured booking workflow. |
| Regular DTR | Transfers/derives data during booking creation when profile/resource/parameter selections change. | Role-specific configured booking/profile data; non-interactive transfer result. | `SRM_DataTransferRulesTemplate`; service-definition `Data Transfer Rules Configuration`; cannot modify the booking itself or configure resources; repeated runs can slow creation. | Signature not confirmed. Build plus applicable Booking Wizard, Service Profile Wizard, or custom-frontend path. |
| Service Profile DTR | Transfers values in memory during service-profile booking creation, including across nodes or main/contributing bookings. | In-memory values; not an immediate persisted booking update. | `SRM_ServiceProfileDataTransferTemplate`; instance configuration takes precedence over definition configuration; multiple scripts run top-down; use `GetUnmappedFunction` only when version-supported and required. | Signature not confirmed. Build plus precedence/order and final-save workflow. |
| Custom Event | Executes configured actions for additional booking orchestration events. | Booking information such as a reference and configured event metadata. | Booking Manager Config > Events; relative time/reference/before-after/order/visibility/default-enabled; cannot change booking timing/resources; documented minimum one-second separation from standard events; placeholders include `[RESERVATIONGUID]`. | Signature not confirmed. Build plus configured event runtime test. |
| Contributing Conversion | Runs after conversion to a contributing resource, commonly to enrich capacities, capabilities, or properties. | Configured reservation/resource context. | Service-definition `Contributing Configuration.Script`; documented syntax `Script:Name||Parameter=Value`; version-matched `[RESERVATIONID]`/`[RESOURCEID]`; `ApplyProfileScript` is a node property hook, not a separate lifecycle role. | Signature not confirmed. Build plus contributing-resource workflow. |
| Created Booking | Runs after booking creation completes to finalize custom configuration, such as hidden-resource assignment. | Script parameters and configured reservation context; dummies are not supported by the cited documentation. | Service-definition-node `Created Booking Action`; JSON `Script`; `[RESERVATIONID]`; failure can return booking to `Partial`. Timing differs in documentation (after creation vs immediately before `Confirmed`) and must be tested. | Signature not confirmed. Build plus configured creation workflow; do not normalize timing without evidence. |

## Auxiliary surfaces

| Surface | Boundary | Validation |
|---------|----------|------------|
| Booking Start Failure | Generic Automation script selected in Booking Manager Config > General when function activation or booking-start actions fail. The booking can remain `Confirmed` while SRM becomes `Failed`. Exact role signature is not published in the plan. | `SRM_BookingStartFailureTemplate` plus an approved failure workflow. |
| Booking Manager UI/custom action | UI callbacks for create/edit/duplicate booking, reservation actions, service-profile booking, quarantine, and up to five custom buttons. Selected booking GUID and Booking Manager element dummy may be supplied for custom buttons. | Version-matched installed SRM solution templates/signatures plus a UI-driven test. Do not treat this as a silent lifecycle hook. |
| SRM utility/silent/test script | Includes documented helpers such as `SRM_ApplyProfileToResource`, `SRM_ResourceManagement`, `SRM_BookResourcesQuickly`, resource scheduling helpers, and silent Booking Manager API calls. | Classify interactive wizard, silent operation, and PLS Tester use separately. Do not infer JSON/input models from a script name; verify `SLSRMLibrary.dll` or `Skyline.DataMiner.Core.SRM.Model`. |
| PLS Tester | Test surface for profile-load scripts, including the documented tester example. | Build plus PLS Tester; it does not prove other SRM roles. |

## Separately documented typed callbacks

These are distinct from the role table. Verify that the selected Dev Pack
exposes the exact delegate/attribute before using them.

| Entry point | Verified shape from the plan | Boundary |
|-------------|------------------------------|----------|
| `SRMServiceInfoStateChanges` | `void(IEngine, SRMServiceState oldState, SRMServiceState newState)` | Typed callback; do not classify it as LSO/PLS by name. |
| `OnSrmQuarantineTrigger` | `void(IEngine, List<ReservationInstanceID> reservations)` | Typed callback; run a trigger-specific integration test. |
| `OnSrmStartActionsFailure` | `void(IEngine, List<StartActionsFailureErrorData> errorData)` | Typed callback; handle the documented failure-data type only. |
| `OnSrmBookingsUpdatedByReference` | `void(IEngine, ValueType profileInstanceId, List<Guid> impactedBookings)` | Typed callback; do not infer a DTR role. |

## Lifecycle and state notes

- Keep core booking states (`Pending`, `Confirmed`, `Ongoing`, `Ended`,
  `Interrupted`, `Canceled`) separate from SRM lifecycle states such as
  `Partial`, `Pre-roll`, `Service Active`, `Post-roll`, `Completed`, `Failed`,
  `On-Hold`, and `Quarantined`.
- Record the hosting Agent. If it is offline, the booking can become
  `Interrupted` when it returns and remaining events are not automatically
  replayed.
- Booking events are asynchronous by default, may run concurrently, and use
  `HasRun` to prevent retriggering. Updates can restart a booking without
  replaying already-run events.
- Resolve capability gates such as Service Profile DTR, `GetUnmappedFunction`,
  PLS Tester, PLS return values, resource-wizard input models, and the SRM 2.x
  LSO concurrency limit against the selected release.

## Package and verification notes

SRM 2.0.1 introduced `Skyline.DataMiner.Core.SRM`; older scripts may use
`Skyline.DataMiner.Library.Solutions.SRM`. Named templates are evidence of
available examples, not universal signatures. Use the matching Dev Pack and
inspect the generated references before code generation.

Generic unit tests cover pure mapping/decision logic only. PLS uses the PLS
Tester. All other orchestration/UI/utility claims require an approved SRM
environment or QAOps fixtures containing the relevant definitions, resources,
profiles, bookings, event configuration, and permissions.

## Official sources

- [SRM scripting roles](https://aka.dataminer.services/srm-scripting)
- [SRM scripting Dev Pack](https://aka.dataminer.services/SrmFramework-HowTo-DevPack)
- [Profile-Load Scripts and PLS Tester](https://aka.dataminer.services/creating-profile-load-scripts)
- [Creating LSO scripts](https://aka.dataminer.services/service-orch-creating-lso-scripts)
- [Adding DTR](https://aka.dataminer.services/service-orch-adding-dtr)
- [LSO API and service-state actions](https://aka.dataminer.services/service-orchestration-lso-script)
- [Regular and Service Profile DTR](https://aka.dataminer.services/service-orchestration-dtr)
- [Custom events](https://aka.dataminer.services/service-orchestration-custom-events)
- [Booking Manager custom scripts/actions](https://aka.dataminer.services/srm-custom-scripts)
- [SRM lifecycle and Created Booking](https://aka.dataminer.services/service-orchestration-life-cycle-states)
- [SRM Automation API](https://aka.dataminer.services/skyline-data-miner-automation)
