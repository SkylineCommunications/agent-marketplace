---
name: dataminer-srm-automation
description: 'Route and review DataMiner SRM Automation scripts by lifecycle role: PLS, LSO, DTR, custom/contributing/created-booking actions, Booking Manager UI, utilities, typed callbacks, configuration, and staged runtime validation.'
argument-hint: 'Describe the SRM surface: e.g. "create a profile-load script", "configure an LSO/DTR", "add a Booking Manager action", or "review an SRM callback".'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-15
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-15 | Initial release covering SRM role routing, version matching, configuration boundaries, and staged validation. |

# DataMiner SRM Automation

Load `dataminer-automation-core` first, then classify the SRM role before
writing code. SRM selects and configures several Automation-script surfaces;
the role is not proof of a unique typed Automation entry point. Use
`references/srm-role-matrix.md` as the role authority.

## Route first

Record all of the following in the plan:

- SRM role or typed callback;
- whether the script is non-interactive, Booking Manager UI/custom action, a
  PLS Tester script, or a silent utility;
- installed SRM framework and target DataMiner version;
- service definition/profile/Booking Manager configuration that selects it;
- inputs, allowed mutations, lifecycle timing, identity, and runtime evidence.

Cover all seven core roles: Profile-Load Script (PLS), Lifecycle Service
Orchestration (LSO), Regular Data Transfer Rules (DTR), Service Profile DTR,
Custom Event, Contributing Conversion, and Created Booking. Also cover Booking
Start Failure, Booking Manager UI/custom actions, SRM utility/silent/test
scripts, and the PLS Tester.

## Package, template, and version rules

- SRM 2.0.1 introduced `Skyline.DataMiner.Core.SRM`; older scripts can use
  `Skyline.DataMiner.Library.Solutions.SRM`. Match the Dev Pack to the
  installed SRM framework; do not blindly upgrade an existing script.
- Named official templates include `SRM_DefaultEmptyLSO`,
  `SRM_ProfileLoadScriptTemplate`, `SRM_DataTransferRulesTemplate`,
  `SRM_ServiceProfileDataTransferTemplate`, `SRM_BookingStartFailureTemplate`,
  and `SRM_ProfileLoadScriptTesterScriptExample`. Discover/copy a
  version-matched template; never synthesize a role signature from its name.
- Use `PackageReference`, one compatible version per assembly. Observed SRM
  package metadata targets .NET Framework 4.6.2 and matching Automation/JSON
  packages; verify the selected package graph. Keep Dev Pack assemblies out of
  the deliverable.
- There is no confirmed SRM-specific SDK template in the plan. Use the
  generic official Automation project only after the selected Dev Pack,
  template/example, and exact types compile.

## Authoring boundaries

- PLS must validate the `FunctionDve` dummy and treat SRM-supplied `Info` and
  `ProfileInstance` parameters as framework-owned payloads. Use documented SRM
  helpers; do not manually parse or mutate an assumed payload shape. Throw on
  configuration failure so SRM can fail the booking state.
- LSO must model the configured service-definition Actions and the documented
  `Action` values (`ServiceState`, `Event`, and `PreviousServiceState`), call
  profile/resource helpers as appropriate, and force-save only the final
  booking update.
- Regular DTR and Service Profile DTR are non-interactive. Respect their
  trigger frequency, in-memory transfer semantics, configuration precedence,
  ordering, and restrictions on booking/resource mutation.
- Custom events, contributing conversion, Created Booking, and Booking Start
  Failure have role-specific configuration and timing. Do not infer a callback
  signature from a role name.
- Booking Manager UI/custom actions are UI-driven callbacks, not lifecycle
  hooks. Utility/silent scripts and PLS Tester scripts are separate categories.
- Do not promise exactly-once execution: booking events are asynchronous by
  default, may run concurrently, and use `HasRun` to prevent retriggering.
  Booking updates can restart a booking without replaying already-run events.

## Typed callbacks

The plan separately documents these typed callback shapes. Detect them only
when the selected Dev Pack exposes the exact types:

- `SRMServiceInfoStateChanges`: `void(IEngine, SRMServiceState oldState, SRMServiceState newState)`
- `OnSrmQuarantineTrigger`: `void(IEngine, List<ReservationInstanceID> reservations)`
- `OnSrmStartActionsFailure`: `void(IEngine, List<StartActionsFailureErrorData> errorData)`
- `OnSrmBookingsUpdatedByReference`: `void(IEngine, ValueType profileInstanceId, List<Guid> impactedBookings)`

These callbacks are not evidence that the caller is a PLS, LSO, or DTR.
Validate the exact delegate/attribute in the target Dev Pack before generation.

## Configuration and identity

Validate the selecting surface, not just C#:

- service-definition Actions and LSO script/action names;
- regular DTR JSON and Service Profile DTR definition/instance properties,
  including instance-over-definition precedence;
- custom-event timing, ordering, visibility, default-enabled state, and
  documented placeholders such as `[RESERVATIONGUID]`;
- contributing configuration (`Script:Name||Parameter=Value`) and the
  documented `[RESERVATIONID]`/`[RESOURCEID]` placeholders in a
  version-matched SRM;
- Created Booking action JSON and `[RESERVATIONID]`;
- Booking Manager selectors, custom buttons, selected booking GUID, and
  Booking Manager element dummy;
- hosting Agent and its offline/interrupted-booking consequences.

Do not assume generic Dev Pack build documentation defines Automation-script
publication/import. Treat deployment and configuration as separate evidence.

## Validation boundary

1. Build with the selected Dev Pack, package graph, and Skyline analyzers.
2. Unit-test pure mapping/decision logic only.
3. Use the SRM PLS Tester for PLS behavior.
4. Use an approved SRM environment or QAOps package for LSO, DTR, custom,
   contributing, created-booking, failure, UI, and utility behavior. Fixtures
   must include the required service definitions, profiles, resources, bookings,
   events, and permissions.
5. Stage runtime/evaluation coverage when those fixtures are unavailable.
   Missing runtime evidence is a limitation, not a reason to invent a
   signature or claim orchestration proof.

Capability gates include Service Profile DTR, `GetUnmappedFunction`, PLS
Tester, PLS return values, resource-wizard input models, and the SRM 2.x LSO
concurrency limit. Resolve their exact availability from the target release;
do not supply unverified numeric gates.

## Forbidden assumptions

- No unique typed signature for every SRM role is established by the plan.
- Do not invent missing signatures for Regular DTR, Service Profile DTR,
  Custom Event, Contributing Conversion, Created Booking, or Booking Start
  Failure.
- Do not treat the generic `Run(IEngine)` path, a role name, or a template name
  as proof of a role contract without version-matched evidence.
- Do not convert a unit test or build into booking-orchestration evidence.

## References

- [SRM role matrix](references/srm-role-matrix.md)
- [SRM scripting roles](https://aka.dataminer.services/srm-scripting)
- [SRM scripting Dev Pack](https://aka.dataminer.services/SrmFramework-HowTo-DevPack)
- [Profile-Load Scripts and PLS Tester](https://aka.dataminer.services/creating-profile-load-scripts)
- [Creating LSO scripts](https://aka.dataminer.services/service-orch-creating-lso-scripts)
- [Adding DTR](https://aka.dataminer.services/service-orch-adding-dtr)
- [SRM Automation API reference](https://aka.dataminer.services/skyline-data-miner-automation)
- [Core SRM package](https://www.nuget.org/packages/Skyline.DataMiner.Core.SRM)
