# Specialized Automation contract matrix

Use this matrix with the Automation Script Map. It prevents the host that launches a script from being mistaken for
the code contract that the script must implement.

## Classification

| Contract | Strong indicators | Route first to | Do not assume |
|---|---|---|---|
| Normal Automation | `Run(IEngine)`, ordinary `DMSScript` XML, Scheduler/Correlation/Visio/Alarm Console execution | `dataminer-automation-core` | That every script has a typed callback or UI |
| IAS | IAS Toolkit types, interactive automation configuration, operator UI | `dataminer-interactive-automation` | That `Run` can be replaced by an arbitrary UI entry point |
| GQI ad hoc data source | `IGQIDataSource`, GQI source template, `DataMinerType=AdHocDataSource` | `dataminer-gqi-ad-hoc-data-source` | That it is a normal `Run(IEngine)` script or can reference `Skyline.DataMiner.Automation` |
| SRM role/callback | SRM Dev Pack, SRM configuration, role-specific script template or callback | `dataminer-srm-automation` | A callback signature not present in the selected version-matched template/package |
| User-Defined API | `OnApiTrigger`, `ApiTriggerInput`/`ApiTriggerOutput`, API definition | `dataminer-user-defined-api` | That a route, token, or definition belongs in source control |
| Node Recovery local | `OnNodeRecoveryLocalStateChange`, local state-change input/output | `dataminer-node-recovery` | That one physical outage produces one callback |
| Node Recovery global | `OnNodeRecoveryGlobalStateChange`, global state-change input/output | `dataminer-node-recovery` | That every Agent runs the callback or that a leader exists without a strict majority |

If only a name or prose description matches, mark the classification as provisional and verify it against the
official template, package, or configuration before authoring code.

## Required plan fields

Every specialized plan must record:

1. **Contract**: exact entry point, interface, attribute, or role and whether normal `Run` is required, optional, or
   prohibited.
2. **Host/trigger**: the DataMiner subsystem that instantiates or invokes the code.
3. **Inputs and outputs**: the documented types and semantic meaning, including paging, HTTP, role, or state details.
4. **Lifecycle/concurrency**: discovery/initialization/update/destruction, booking phases, request concurrency, or
   leader/state transitions that affect shared state.
5. **Identity/configuration**: script name, compiled library/class, API route/token/definition, SRM configuration, or
   Node Recovery setting that must match the host.
6. **Version gates**: target DataMiner/CU, GQI API track, SRM Dev Pack/framework, endpoint/DxM, and any version-gated
   members.
7. **Validation boundary**: static checks and build first; then only the compatible host-level test that is available.
   A mock or static check must not be reported as runtime proof.
8. **Open verification**: every undocumented signature, enum, retry/order behavior, or operational provisioning step
   that still needs confirmation.

## Routing rules

- Load `dataminer-automation-core` for shared Automation terminology, then the one feature skill for the selected
  contract. Keep the feature skill authoritative for platform facts.
- Load `dataminer-sdk` and `dataminer-nugets` before selecting a template, Dev Pack, or package.
- Reuse the existing scaffolder, author, reviewer, investigator, and test-writer agents. Tell each specialist which
  contract skill to load and which normal-Automation assumptions are disabled.
- A specialized project may still contain a `DMSScript` XML file. Its XML shape and deployment identity must be
  validated from the specialized template rather than copied from a normal Automation script.
- For SRM, use the role-specific template/package as the signature authority. If public documentation is incomplete,
  preserve an opaque framework-owned payload and record the gap instead of guessing.
- For User-Defined APIs, keep definitions, tokens, endpoint/DxM settings, and secrets outside the repository unless a
  documented repository manifest explicitly exists.
- For Node Recovery, keep local and global scripts separate and do not hard-code enum numbers or infer retry,
  ordering, duplicate suppression, or maintenance behavior beyond the selected documentation/package.

## Validation map

| Contract | Static/build gate | Host-level gate when available |
|---|---|---|
| GQI | Compile against the selected Core GQI package; inspect interface, columns, deterministic keys, paging, and forbidden Automation dependency | Compatible GQI query smoke test |
| SRM | Build with version-matched SRM package; verify role identity/configuration and exact template signature | PLS Tester for PLS; configured booking/service-profile/orchestration scenario for other roles |
| User-Defined API | Compile typed trigger; verify route/method/body/status/header logic and no secret material | HTTPS request test against a configured endpoint/token |
| Node Recovery | Compile local/global typed callbacks; verify state handling and no hard-coded enum assumptions | Approved multi-Agent outage, maintenance, and leader scenario |
