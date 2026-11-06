# Automation Test Routing

Choose the test route from the behavior under test. A green compile or unit test does not prove behavior that only exists in a DataMiner host.

| Test goal | Route | Minimum evidence |
|---|---|---|
| Parsing, validation, mapping, decision logic | Unit tests with plain application-owned inputs | Deterministic test results and edge-case assertions |
| Engine orchestration, exit states, element lookup boundaries | Unit tests with Moq `IEngine` and application-owned seams | Assert stable outcome, side effect, and expected `ScriptAbortException` |
| XML/project/link/analyzer contract | Local XSD/build/analyzer fixture | Pinned XSD result, `dotnet build`, Skyline analyzer result |
| Script/element/DOM/table behavior on a real DataMiner | QAOps integration test | `.dmtest` identity, fixture/preflight, exact filter, per-test result, logs, cleanup |
| IAS dialog behavior in Cube or web/low-code | Host-specific QAOps/live route | Host/version, parameters/dummies, start/abort/detach behavior, UI result, timeout |
| Post-deployment regression | QAOps test package against the deployed immutable artifact | Artifact hash/version, target, package discovery, selected tests, result and rollback evidence |

## Routing rules

- Do not replace a live-system requirement with `SLProtocolMock` or a unit test.
- Do not use a QAOps run for pure parsing or validation logic that can be tested locally.
- Unit tests must not construct SDK-owned `ScriptParam`; use plain strings and application-owned input seams.
- QAOps tests must use the mandatory system-state preflight, fixture identity, version checks, non-locking log reads, and diagnostic assertion messages from `dataminer-qaops-integration-testing`.
- UI tests name the host. Cube attachment, web/low-code IAS components, and explicitly requested headless runs are different contracts.
- Run unit, build/XSD, QAOps integration, UI, and post-deploy regression gates separately; a pass in one route does not satisfy another route.
