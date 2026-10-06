---
name: dataminer-qaops-integration-testing
description: Create or wire MSTestV2 integration tests that run on QAOps DataMiner, OR migrate an existing MSTest/Playwright integration test project onto QAOps (add a Test Package, gate credentials, run on a bridge). Use when testing Automation scripts, connectors, element/service behavior, or any solution change against a live DataMiner, or when asked to "add a QAOps Test Package" / "make our tests run on QAOps" / "migrate to QAOps". Covers project naming, IDms localhost setup, executing Automation scripts, asserting element state, system-state preflight, fixture isolation, supplementary runtime files, protocol-version assertions, non-locking log reading, WinEncryptedKeys credentials and the BridgeId bridge gate, Test Package InstallScript setup, harvesting a classic connector into a .dmprotocol, the runtime-prerequisite cascade (SDM/connector/DOM) and mirroring the solution installer, Playwright HTTPS host, CPM template gotchas, .dmtest discovery, scoped runs via PipelineLibrary -TestFilter, and device simulators.
argument-hint: 'Describe what to integration-test or migrate: e.g. "test if my Automation script stops all elements of protocol X", "add a QAOps Test Package for our Playwright tests", "migrate our integration tests to QAOps"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-18
  version: 2.15
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-api`, `dataminer-automation-unit-testing`, `dataminer-dataapi`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-api`: Optional frontend/Playwright authentication branch; ordinary MSTest integration tests do not use it.
> - `dataminer-automation-unit-testing`: Separate mocked Automation test workflow, not a dependency of live integration tests.
> - `dataminer-dataapi`: Alternative dynamic-element fixture, not required by standard fixed-PID fixtures.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.15 | 2026-09-18 | Added specialized Automation fixture boundaries and explicit connector lifecycle handoff, artifact ownership, and final evidence gates for build, package, QAOps execution, publication, deployment, and verification. |
| 2.14 | 2026-09-15 | Added specialized Automation fixture boundaries for GQI, SRM, User-Defined API, and Node Recovery runtime checks. |
| 2.13 | 2026-08-07 | Added authoring guidance for supplementary runtime files: choose them instead of embedding large/per-run inputs in `.dmtest`, access them from PowerShell or C# through machine-level `QAOPS_SUPPLEMENTARY_FILES`, keep the path optional and diagnostics-rich, and route to `dataminer-qaops/references/supplementary-files.md`. |
| 2.12 | 2026-06-26 | **Mandatory `[TestCategory("IntegrationTest")]` on every MSTest connector integration test.** Added the rule to `references/authoring-test-project.md` (Test Identity Checklist + Writing-Tests rules) and the main "Authoring the Test Project and Tests" section: apply it at the test **class** so all `[TestMethod]`s inherit it (MSTest aggregates class- and method-level categories); it lets QAOps/CI select integration tests with `--filter TestCategory=IntegrationTest` and lets a local unit-test run **exclude** them (`TestCategory!=IntegrationTest`) so real-DataMiner tests don't run/fail outside QAOps; feature-specific categories are additive. Updated the example snippets to model it (`references/example-automation-script-test.md`, `references/system-state-preflight.md`) and clarified the scoped-run naming note in `references/test-package-wiring.md`. |
| 2.11 | 2026-06-26 | Added "Excluding Runtime Test Artifacts (Playwright Traces, etc.)" to `references/test-package-wiring.md`: a `$(OutputPath)**\*.*` post-build harvest sweeps up per-test-run artifacts (Playwright trace `.zip`s, screenshots, videos) that are locked/removed between MSBuild's enumeration and copy, breaking the build with intermittent `MSB3021`/`MSB3027` "Unable to copy file … Could not find a part of the path". Fix = `Exclude="$(OutputPath)<trace-folder>\**"` + `SkipUnchangedFiles="true"` (verified: SLC-S-MediaOps.Plan PR #555). **The trace folder name is chosen by the test code (e.g. the `Context.Tracing.StopAsync(... Path = Path.Combine(Directory.GetCurrentDirectory(), "playwright-traces", …))` segment) — read it from source, never assume `playwright-traces`.** Prefer excluding known runtime-artifact dirs over whitelisting "only what the runner needs" (a hand-picked list silently drops a dependency and fails on QAOps a run later). Cross-referenced from `references/migrating-existing-tests.md` Section 7 + Migration Checklist. |
| 2.10 | 2026-06-25 | **QAOps targets run on Windows, not Linux** — added a "Target OS is Windows" note to "Authoring the Test Project and Tests": assert the real outcome for Windows-only code (WMI/registry/COM/`.exe`/Windows paths); never relax an assertion, mark `Inconclusive`, or warn about a "Linux mismatch" because code is Windows-only (`Inconclusive` is only for *detected* environment limits). Fixed `references/test-package-prerequisites.md`: the classic `.dmprotocol` deploy in `1.TestPackageSetup.ps1` now shows the **full** `dataminer-package-deploy from-artifact … --dm-server-location 'localhost' --dm-user $u --dm-password $p --deploy-timeout-in-seconds 3600` command with the `WinEncryptedKeys` credential retrieval (the previous "gated by WinEncryptedKeys" prose omitted the args and a session's setup step failed with exit code 1 / `dataminer-package-deploy returned exit code 1`). Hardened the Packaged MSTest Discovery Gate in `references/test-package-wiring.md`: `dotnet test --list-tests` does **not** work on a standalone net48 `.dll` — use `dotnet vstest "<dll>" --ListTests` / `vstest.console.exe "<dll>" /ListTests`; a UTF-8/byte name scan is a **freshness** check only, never a substitute for runner discovery (a session accepted a byte scan as discovery and later got an OK run with zero test rows). Dropped the misleading "make MSBuild paths also work on Linux" line. |
| 2.9 | 2026-06-19 | Added a "First 60 Seconds" section: for "new solution + test on QAOps" requests, scaffold missing projects with official templates immediately (`dataminer-sdk`) before exploring existing folders; then continue with test authoring/wiring/run flow. |
| 2.8 | 2026-06-17 | Added the **classic-connector harvesting** rule (verified on a manager-connector session): the Test Package auto-includes only *SDK-style* same-solution projects, so a legacy `protocol.xml` + `QAction_*.csproj` connector must be harvested into a `.dmprotocol` (`dataminer-package-create dmprotocol`, new `dataminer-dmprotocol-packaging` skill) and deployed from `1.TestPackageSetup.ps1` — detailed in `references/test-package-prerequisites.md`. Added the **DataAPI name-based fixture** alternative (new `dataminer-dataapi` skill) for name-addressable dynamic elements, and a pointer to the `IDmsTable.GetColumn<T>` nullable-type gotcha now in `dataminer-idms`. |
| 2.7 | 2026-06-17 | **Split the oversized SKILL.md (~50 KB) into a slim router (~25 KB) + two new references.** Phase-1 detail (project naming, MSTest project creation, `.csproj`/MSTest-metapackage settings, identity checklist, real-DataMiner setup, Writing-Tests rules) moved to `references/authoring-test-project.md`; Phase-2 detail (Test Package reuse/create, Catalog-key user-secrets, prerequisites, harvesting, `TestDiscovery.ps1`, execution pipeline + gates, scoped runs, build-and-run, benign output) moved to `references/test-package-wiring.md`. SKILL.md keeps the workflow, authoring-vs-migrating decision, System State Preflight, and Failure-Diagnostics rules; both references carry a redirect header back to the master skills (real-system verification always routes through QAOps). |
| 2.6 | 2026-06-17 | **Pipeline-integrity hard rule (verified — a session burned ~6 QAOps runs on this):** never place a step that can `throw`/`exit` before `Invoke-DotNetTestAndPublishResults`. A redundant `dotnet test … ; if ($LASTEXITCODE){ throw }` "diagnostic" gate throws on every failing test, so the helper never publishes per-test rows and the run collapses to one detail-less `pipeline_… - Fail` row; the agent then wasted further runs shrinking that message. A failing test is **not** a pipeline failure. Added "Pipeline Integrity — Never Gate the Publishing Helper" to `references/test-package-pipeline.md`, a hard-rule callout in "Test Package Execution Pipeline", a no-per-test-row triage bullet in "Failure Diagnostics", and corrected `references/dms-test-setup.md` so the `dotnet test` diagnostic is **additive/non-throwing, after** the helper (the old wording led an agent to gate the helper). |
| 2.5 | 2026-06-17 | **net48 binding-redirect fix (verified — cost ~5 QAOps runs):** classic VSTest integration test projects must keep the single `MSTest` metapackage; splitting it into `MSTest.TestAdapter`/`MSTest.TestFramework` drops `Microsoft.NET.Test.Sdk`, so no `<TestProject>.dll.config` binding redirects are generated and `WinEncryptedKeys.Lib`'s `ProtectedData 9.0.0.0` ref fails to bind (`FileLoadException` 0x80131040 in `AssemblyInitialize`). Also hardened `references/dms-test-setup.md`: cleanup must never throw over the real init failure (the masking bug hid the above for 3 runs), `Console.WriteLine` tracing does not reach `LOG_LINES`, and a no-per-test-row `CompletedWithFailures` means `AssemblyInitialize` threw. |
| 2.4 | 2026-06-16 | Added the **lightest** migration path to `migrating-existing-tests.md` (Section 3): when the solution's deployment package is Catalog-published and the org key resolves it, just CatalogReference it + `000`/`001`-ordered SDM/Categories — installs during `InstallingDependencies`, no bundle/pipeline-deploy/InstallScript (verified green on RC **and** Feature). New traps each costing a run: install order = embedded-`.dmapp` **alphabetical filename order** (numeric `<Name>` prefixes); public `manifest.yml` IDs are CI-overwritten placeholders (`Version could not be resolved`/`404`) → find the real ID via `gh variable list … CATALOGIDENTIFIER*`; the SDK prints `Successfully created package` even when a Catalog download fails (grep `error :` — stale `.dmtest`). Added the offline-fallback-reuse + **constructor-guard trap** (gate the real-client instantiation, not just method bodies — a `LockManager` ctor `Dms.GetElement` threw before the flag was read), the `global.json` SDK-version coupling gotcha (don't downgrade; `AppPackageInstaller 4.0.0 not compatible with AppPackageCreator 3.1.1.0`), the non-default NuGet cache note, the Categories Catalog ID, and new Section 9 (Inconclusive-vs-Fail for missing seeded data / optional connectors, QAOps-gated). Mirrored the Catalog/order/stale-package facts into `test-package-prerequisites.md`. |
| 2.3 | 2026-06-15 | Added the **validated** full-bootstrap pattern to `migrating-existing-tests.md` (Section 3): bundle the solution's own deployment `.dmapp` (built from a same-solution Package project) into `TestPackageContent/Dependencies` via the **source project's** post-build copy + an `<MSBuild>`-task build trigger in the Test Package (a `<ProjectReference>` to a Package fails — the SDK reinterprets it as a script reference: `Missing 'libraryName' param on exe`), then deploy it from `1.TestPackageSetup.ps1` with `dataminer-package-deploy from-artifact` + `WinEncryptedKeys` creds; order external Catalog prerequisites with `000`/`001` displayName prefixes (SDM before Categories); strip the piecemeal InstallScript. Verified on QAOps Feature: deploying the real solution flipped the most complex job/node/config test from Fail to Ok and turned the remaining failures into test-level timing/selector issues rather than missing-prerequisite errors. |
| 2.2 | 2026-06-15 | Added the "prefer installing the real solution package over piecemeal replication" guidance to `migrating-existing-tests.md`, from a verified full-suite run: piecemeal installer-replication is a long fragile cascade for deep UI tests and can be **actively harmful** — deploying the solution's alpha MediaOps DevPacks into `SolutionLibraries` from the Test Package InstallScript did not fix the dependent script's `Errors in CSharp script code` and **regressed** the one previously-passing Playwright test (runtime version conflict). For fully-bootstrapped tests, install the solution's own deployment/regression package as a prerequisite so the real installer runs. |
| 2.1 | 2026-06-15 | Added the "Authoring New Tests vs Migrating Existing Tests" decision and the `migrating-existing-tests.md` reference, capturing a full real migration: `BridgeId` credential gate (WinEncryptedKeys `TryRetrieveKey`, not `TryGetValue`), putting QAOps-only environment setup in the Test Package **InstallScript** instead of gating shared test source, the **runtime-prerequisite cascade** (SDM `(slc)standard_data_model` → connector/Lock-Manager element → solution DOM modules → Playwright HTTPS) and the mirror-the-solution-installer rule, never calling solution Automation scripts as install subscripts, install-dependency harvesting verification (`Scripts\InstallDependencies` vs `Install.xml` refs; remove un-harvestable dev/ref packages), Playwright `https://localhost` + `IgnoreHTTPSErrors` vs bare-`localhost` SLNet host, and template gotchas in CPM repos (NU1008 inline versions, `ProjectReferences.xml` package-in-package). Added the SDM Registration Catalog ID and runtime cascade to `test-package-prerequisites.md`. |
| 2.0 | 2026-06-15 | Added "Device Simulators for Real Data-Flow Tests" section: routes to `dataminer-qaops-simulators` skill for SNMP/QADeviceSimulator, in-test TcpDeviceSimulator, packaged WebSocket exe, and baseline-controlled data-flow design. Updated Reference Files table to include the new simulator skill. Updated description. |
| 1.9 | 2026-06-12 | Discovery-gate hardening from a measured failure: test-name discovery cannot detect stale packages when only test bodies changed — require a build-order `ProjectReference` (`ReferenceOutputAssembly=false`) from the Test Package to the test project plus a freshness gate (bin-vs-extracted exe hash compare; UTF8 scan for a new method name). Added device-simulator lessons: smart-serial loopback polling = SERVER mode (connect TO the element); QAOps DaaS exchanges no serial/smart-serial loopback TCP data at all (HTTP/SNMP loopback work) — design such data-flow tests baseline-controlled (compare against a known-good fixture element; Inconclusive when the baseline fails too, Fail only when the baseline works and the new element does not). |
| 1.8 | 2026-06-12 | PipelineLibrary **1.3.0** ships `-TestFilter`/`-PublishNotExecuted`: scoped runs now filter instead of mass-ignoring (measured 657-test suite: ≈55 min → ≈4.5 min). Replaced the "prefer Ignore attributes" scoped-run section accordingly; temp ignores are the pre-1.3.0 fallback only (hand-edit — a scripted bulk insert once rewrote ~100 files). Documented the publishing timing model (quiet exe phase ≈33 min incl. AssemblyInitialize, then one-by-one row publishing ≈20 min — silence ≠ hang), the never-bypass-the-helper rule (direct exe `--filter` publishes no assertion rows), filter-friendly test naming (shared prefix/`TestCategory`), one-behavior-per-test splitting for readable QAOps rows, the flaky-test permanent-Ignore policy, MSTest v4 gotchas (`Assert.ThrowsExactly`, `ElementState` alias), and corrected the per-run cost figure. |
| 1.7 | 2026-06-12 | Added the mandatory Fresh Test Package Version Gate, the Packaged MSTest Discovery Gate (new tests must be discoverable inside the exact versioned `.dmtest` before QAOps), and the scoped-run rule: prefer temporary MSTest `Ignore` attributes over unsupported TestPackagePipeline/filter edits; if skipped outcomes need special handling, fix the shared pipeline module rather than individual package scripts. |
| 1.6 | 2026-06-12 | Added the mandatory **Empty-System Contract** (tests must pass on systems WITHOUT pre-installed content: create-or-duplicate fixtures, never require baseline elements — a shipped test that hard-required the DaaS Microsoft Platform baseline triggered this), the serial-connector fixture fallback (`Duplicate`) with the `IncorrectDataException` creation gap, the batch-variants-into-one-run debugging rule, the Test Package→test-project build-order `ProjectReference` (TestDiscovery.ps1 otherwise fails in solution builds), the NU1015 dotnet-add-package rule, and the CS0165 fix in the `FindConcerningEntries` reference snippet. |
| 1.5 | 2026-06-11 | Added the mandatory System State Preflight (QAOps DaaS is NOT empty — e.g. a Microsoft Platform element/connector is always pre-installed; snapshot elements + protocol versions, isolate fixtures by identity, classify benign vs interfering artifacts, assert versions for version-bound test data), the diagnostics-are-the-feedback-channel rule (assertion messages must carry system state + non-locking log excerpts), the no-concerning-log-errors assertion, the new `system-state-preflight.md` reference, and a robust user-secrets snippet (the previous one corrupted the path when the csproj has multiple PropertyGroups). |
| 1.4 | 2026-06-11 | Added the mandatory "Catalog Key via User Secrets" flow (init + pre-provisioned secrets.json at project-creation time; never in chat, never via mid-session env vars), the Expected Benign Build Output section (MSB3277/MSTEST0037, low-noise build command), and the MSTest template retargeting note (net48/x86). |
| 1.3 | 2026-06-11 | Added the mandatory TestDiscovery.ps1 step (template is a placeholder; harvested files are otherwise not packaged), the verified SLNetTypes package fix for `Connection`/`ConnectionSettings`, Catalog-prerequisite token preflight, `.dmtest` content verification, the never-run-locally rule, and routing to `dataminer-idms` for IDms code. |
| 1.2 | 2026-06-10 | Added Automation-script test triggers to the description and a verified worked example (run script, assert element state, create test elements, poll-wait pattern). |
| 1.1 | 2026-06-10 | Added DataMiner Test Package prerequisite content guidance for Catalog items, same-solution projects, Low-Code Apps, dashboards, ArtifactDownloader, and export web calls. |
| 1.0 | 2026-06-10 | Initial real DataMiner integration-test authoring workflow for QAOps. |

# QAOps Integration Test Authoring

Use this skill when the user asks to create integration tests that run on a real DataMiner system through QAOps, or when development work needs end-to-end verification against a live DataMiner instead of SLProtocolMock unit tests.

Load `dataminer-qaops` first for QAOps background (including the **Preflight** token checklist — collect the QAOps token and, when out-of-solution Catalog content is needed, the Catalog organization key *before* starting development) and `dataminer-sdk` before creating or modifying SDK-style DataMiner Test Package projects. For writing the IDms code inside the tests or the script under test, load `dataminer-idms`.

## First 60 Seconds (for "new solution + test on QAOps" requests)

When the user asks to **add a new solution/project** and validate it on QAOps:

1. Run QAOps preflight (target + QAOps token; Catalog-key availability only when needed).
2. Load `dataminer-sdk` and scaffold missing projects immediately with official templates (`dataminer-automation-project`, `dataminer-test-package-project`; MSTest via `dotnet new mstest`).
3. Add the new projects to the solution.
4. Then proceed with this skill's authoring/wiring flow.

Do not spend early cycles browsing old local projects before scaffolding. For new-solution requests, **scaffold first, then align conventions**.

## When to Use This Instead of Unit Tests

Use QAOps integration tests when the test must verify behavior against a real DataMiner runtime, for example:

- Automation script behavior: scripts that start/stop/manipulate elements, services, views, or parameters.
- SLNet or `IDms` interactions.
- Element, service, alarm, view, or automation behavior that cannot be represented by `SLProtocolMock`.
- End-to-end workflows that require a clean DaaS DataMiner.
- Regression tests intended to run as QAOps `.dmtest` packages.

Use `dataminer-unit-testing` instead when the target is isolated QAction logic that can be tested with `SLProtocolMock`.

> Requests phrased like *"test if my Automation script correctly does X to the elements of protocol Y"* are QAOps integration tests — they require a live DataMiner. Do not attempt them with SLProtocolMock.

### Specialized Automation fixtures

When the system under test is GQI, SRM, a User-Defined API, or Node Recovery, keep the test package and the
contract-specific host fixture separate from ordinary script execution:

- **GQI**: require a target with the compatible GQI DxM enabled. Exercise source discovery, argument/column resolution,
  multiple pages, deterministic keys, and updates only when the selected source implements them. Do not call a GQI
  source through `Run(IEngine)`.
- **SRM**: seed the service/profile/resource definitions and role configuration required by the selected SRM version.
  Use PLS Tester for PLS or the documented booking/service-profile/orchestration path for other roles. Do not invent a
  callback payload or use a generic Automation run as proof of booking timing.
- **User-Defined API**: provision the definition, route, endpoint/DxM, and short-lived token through the approved
  operational flow. Send HTTPS requests and assert status/body/headers and negative method/route cases. Never package
  or log the token.
- **Node Recovery**: use at least the number of Agents required by the documented global consensus behavior and record
  local/global scope, maintenance state, leader, and state transition. Treat retry/order/duplicate behavior as
  unknown unless the target documentation/test proves it.

If a target cannot supply the fixture, package, token, or multi-node topology, mark the runtime evidence unavailable;
do not weaken the test to a generic build or script-exit assertion.

## Authoring New Tests vs Migrating Existing Tests

Decide which task this is **before** following the workflow below — they diverge significantly:

- **Authoring new tests** (this SKILL's default): the solution has no real-DataMiner tests yet. Create an MSTestV2 project, wire `DmsTestSetup`, write tests with the System State Preflight. Continue with "High-Level Workflow".
- **Migrating an existing test project** (e.g. "add a QAOps Test Package", "make our Playwright/integration tests run on QAOps", "migrate to QAOps"): the solution already has an MSTest/Playwright project with its own connection setup. Most test code stays as-is; the work is credential gating, Test Package wiring/harvesting, and replicating the runtime setup the solution's own install package performs on a clean DaaS. **Load `references/migrating-existing-tests.md` first** — it front-loads the exact gotchas (BridgeId credential gate, InstallScript-based setup, the runtime-prerequisite cascade, install-dependency harvesting, Playwright HTTPS-vs-SLNet host, template CPM/`ProjectReferences.xml` errors) that otherwise cost many fix-verify QAOps runs.

## High-Level Workflow

1. Locate the solution root containing `.sln` or `.slnx`.
2. Locate existing test projects and DataMiner Test Package projects.
3. Create or update an MSTestV2 integration test project.
4. Add real DataMiner connection setup through `IDms`.
5. Add integration tests — every test starts with the **System State Preflight** (snapshot, fixture isolation, interference classification, version assertions; see below) and asserts with diagnostics-rich messages.
6. Record the newly added or changed MSTest class/method names; these names are the acceptance criteria for the later packaged-discovery gate.
7. Reuse or create a DataMiner Test Package project.
8. Provision the Catalog key user-secrets file when `CatalogReferences.xml` entries will be needed (see `references/test-package-wiring.md` → "Catalog Key via User Secrets" — do this immediately after the project exists, not at first build failure).
9. Add prerequisite package content required on the QAOps DataMiner. **If the connector under test is a classic `protocol.xml` + `QAction_*` solution, it is NOT auto-included — harvest it into a `.dmprotocol` and deploy it from the InstallScript** (see `references/test-package-prerequisites.md` → "Classic (Legacy) Connector Solutions Are NOT Auto-Included" and the `dataminer-dmprotocol-packaging` skill).
10. If tests need large or per-run external inputs that should not be embedded in the `.dmtest`, design them as supplementary files and resolve them through machine-level `QAOPS_SUPPLEMENTARY_FILES` (see below).
11. Add post-build copy targets so built test output is harvested by the Test Package project.
12. Replace the placeholder `TestPackageContent/TestHarvesting/TestDiscovery.ps1` so harvested output is actually packaged (see `references/test-package-wiring.md` → "TestDiscovery.ps1" — without this the `.dmtest` will not contain the tests).
13. Update `TestPackageContent/TestPackagePipeline/2.TestPackageExecution.ps1` to run the copied tests through `Invoke-DotNetTestAndPublishResults`.
14. Increment the Test Package project `<Version>` and record the exact expected artifact name (`<TestPackageProject>.<Version>.dmtest`).
15. Build the solution, verify the exact versioned `.dmtest` contents and test discovery, and then run that exact package through `dataminer-qaops-test-runs` when requested.

## Authoring the Test Project and Tests

Project naming, creating the MSTestV2 project, the **mandatory `.csproj`/MSTest-metapackage settings** (net48/x86, single `MSTest` metapackage, binding redirects), the test-identity checklist, the real-DataMiner `IDms` connection setup, and the Writing-Tests rules (including MSTest v4 gotchas) live in **`references/authoring-test-project.md`** -- load it for any test-authoring work. **Every MSTest integration test must be tagged `[TestCategory("IntegrationTest")]`** — apply it at the test class so all methods inherit it (Test Identity Checklist in that reference). Every test still begins with the System State Preflight below.

> **Target OS is Windows.** QAOps provisions a **Windows** DataMiner for every target (RC/Main/Feature) — see `dataminer-qaops` → "Platform: QAOps DataMiner Systems Run on Windows". Assert the **real** expected outcome even when the connector/script depends on Windows-only APIs (WMI, registry, COM, `.exe` tools, Windows paths); those work on QAOps. Do **not** pre-emptively relax an assertion, mark a test `Inconclusive`, or warn the user about a "Linux mismatch" because the code is Windows-only. (`Assert.Inconclusive` is reserved for genuine, *detected* environment limits such as simulator-elevation or serial-loopback networking — never for an assumed Linux target.)

## Supplementary Runtime Files

Use supplementary files when a test needs inputs that are too large, too volatile, or too
environment-specific to embed in the `.dmtest`. Pass them at run submission with repeatable
`--supplementary-file` options.

C# test code and Automation scripts must resolve the directory from machine-level
`QAOPS_SUPPLEMENTARY_FILES`:

```csharp
string? supplementaryFilesPath = Environment.GetEnvironmentVariable(
    "QAOPS_SUPPLEMENTARY_FILES",
    EnvironmentVariableTarget.Machine);

if (String.IsNullOrWhiteSpace(supplementaryFilesPath) || !Directory.Exists(supplementaryFilesPath))
{
    Assert.Fail("This test requires QAOps supplementary files, but none are available for the current run.");
}
```

PowerShell must likewise query the machine target explicitly:

```powershell
$supplementaryFilesPath = [Environment]::GetEnvironmentVariable(
    'QAOPS_SUPPLEMENTARY_FILES',
    [EnvironmentVariableTarget]::Machine)
```

Do not use the process-scoped overload/`$env:QAOPS_SUPPLEMENTARY_FILES`: long-running test hosts and
Automation processes may have cached their environment before the Bridge published the value. Test
Package pipeline scripts may alternatively use
`$PathToTestPackageContent\SupplementaryFiles` on the pipeline agent.

The variable is optional when no files were submitted. A test that requires a file must fail with a
clear message naming the missing path/file. Never put secrets in supplementary files. Full upload,
path-preservation, lifecycle, multi-agent, token, and Bridge-version rules:
`dataminer-qaops/references/supplementary-files.md`.

## Connector Lifecycle Handoff and Completion Gates

QAOps is the live-system verification stage, not a replacement for source validation, packaging, Catalog publication, or deployment approval. Keep the stages and owners explicit:

| Stage | Primary owner | Required handoff evidence |
|-------|---------------|----------------------------|
| Build and protocol validation | Connector author/validator | Solution/project identity, build output, official validator result |
| Package creation | `dataminer-sdk` for SDK-style output; `dataminer-dmprotocol-packaging` for classic connectors | One fresh artifact, version/protocol identity, inspected contents, and artifact hash |
| Test Package wiring | QAOps integration-test owner | `.dmtest` identity, prerequisites, `TestDiscovery.ps1` result, credentials/BridgeId gate, and install order |
| Live execution | QAOps test-run owner | Target DaaS/environment, exact filter, per-test results, runtime logs, and fixture cleanup |
| Catalog publication | Release owner / Catalog route | Explicit Catalog target, publication result, immutable artifact identity, and metadata validation |
| Deployment and post-deploy verification | Deployment owner | Target environment, deployed version/hash, health/rollback result, and post-deploy test evidence |

Do not silently publish or deploy from a QAOps test. Do not treat a successful package build as publication or deployment. A lifecycle handoff is complete only when the receiving stage can identify the exact artifact, target, credentials boundary, expected result, and rollback/cleanup action.

For classic connectors, harvest the `.dmprotocol` with the official packager before putting it in a Test Package; for SDK-style connectors, use the SDK package output. Keep package creation, Catalog upload, DataMiner deployment, and QAOps execution as separate gates even when one pipeline invokes them sequentially.

## System State Preflight (Mandatory First Step of Every Test)

**QAOps DaaS systems are not empty.** The DaaS baseline ships with pre-installed content — verified: a **Microsoft Platform element and connector are always present**, usually in a different version range than the Catalog version a Test Package installs. A test (or the logic it tests) that selects "the first/any element of protocol X" can silently bind to baseline content instead of the test's own fixture. This exact failure mode once cost eight QAOps runs to diagnose; the preflight catches it in run one.

**Empty-System Contract (equally mandatory).** The inverse also holds: a Test Package must run green on **any** target — including an empty DataMiner where only the package's own prerequisites exist. Today's DaaS baseline content is an environment detail, not a dependency:

- Never make existence of pre-existing elements a test precondition (no `Assert` that "at least one element of protocol X exists", no script-under-test contract that relies on it).
- Arrange implements **both** branches: *nothing present* → create the fixture (for serial connectors where `ElementConfiguration` throws, `Duplicate` an existing element when one exists; on a truly empty system fail fast naming the IDms creation gap — see `dataminer-idms` cheatsheet "Creating Elements"); *baseline present* → still create/duplicate a test-owned fixture and apply the Interference Policy.
- "Utilise existing artifacts" only via the mirror/duplicate patterns — never by adopting an uncontrolled baseline element as the fixture.

Every integration test starts by validating the system it is about to run on:

1. **Snapshot** all elements of the target protocol(s): name, `DmsElementId`, `Protocol.Version`, `State`. Write the snapshot to the test output (`Console.WriteLine` → TRX) and keep the string to embed in every assertion message.
2. **Isolate the fixture**: always create a uniquely named test element and act/assert on it **by identity** (`DmsElementId`), never by "first element of protocol X". Never skip creation because elements already exist — that adopts unknown baseline content as the fixture.
3. **Classify pre-existing artifacts** instead of failing on existence:
   - *Benign* (the logic under test targets the fixture by identity) → allow, ignore beyond logging.
   - *Interfering* (the logic under test selects elements globally, or the test data is version-bound) → mirror the artifact into expectations (reproduce the selection logic and validate what it will pick) or fail fast in Arrange with the snapshot in the message.
4. **Assert protocol versions** when test data (PID maps, page layouts) derives from a specific `protocol.xml`: assert the target element's `Protocol.Version` is in the supported range *before* Act, naming both versions on failure.
5. **Assert no concerning log errors** after Act: scan `SLAutomation.txt` (non-locking read) for error entries within the Act time window that mention the test's subjects (script name, fixture names); unrelated errors must not fail the test.

> Canonical helpers and full skeleton: `dataminer-qaops-integration-testing/references/system-state-preflight.md` — snapshot/describe helpers, mirror-selection pattern, version assertions, non-locking `DmLogs` reader, and the no-concerning-errors assertion. Load it before writing any test.

## Failure Diagnostics Are the Feedback Channel

The QAOps console output prints, per failed test, only `TestName - Fail: <assertion message + stack trace>`; the `-rf` JSON is run-level only, and the QAOps UI needs interactive authentication the agent does not have. **The assertion message is therefore the only diagnostic channel that reaches the session.** Design for it from the first run:

- Embed the system-state snapshot string in every assertion message.
- On outcome failures after running a script, append a plain tail of `SLAutomation.txt` (e.g. last 60 lines) read with the non-locking pattern from `system-state-preflight.md`. Keyword-anchored log windows truncated the real exception in practice — use a plain tail.
- Never react to an unexplained failure by changing product/test logic on a guess: each fix-verify cycle costs a full QAOps run and a token use. Run duration scales with what executes — measured: ≈4.5 min for a filtered run, ≈55 min for a 657-test full suite (≈33 min quiet executable phase + ≈20 min row publishing). If the failure message does not name the cause, the next run's purpose is **better diagnostics**, not a speculative fix.
- When a hypothesis can only be tested on the live system (e.g. which connection type element creation accepts), **batch every candidate variant into one run** — try/catch each variant and report all outcomes in one assertion message. One-variant-per-run debugging burned 4 runs in a measured session on a client-side constructor exception that one batched run would have settled.
- **A `CompletedWithFailures` run with *no* per-test row means the harness failed, not a test** — `AssemblyInitialize` threw, the host crashed before writing a TRX, or the pipeline gated/bypassed `Invoke-DotNetTestAndPublishResults`. Fix the harness (see `references/test-package-wiring.md` → "Test Package Execution Pipeline" and `references/test-package-pipeline.md` → "Pipeline Integrity"); never add a throwing `dotnet test` before the helper, and do not spend QAOps runs reformatting a pipeline-level message — enrich the test's own assertion messages instead.

## Wiring and Shipping the Test Package

Reusing or creating the Test Package project, the **Catalog-key user-secrets flow**, prerequisite content, post-build harvesting, the mandatory `TestDiscovery.ps1`, the **Test Package execution pipeline (including the "never gate the publishing helper" hard rule)**, the Fresh-Version and Packaged-Discovery gates, scoped `-TestFilter` runs, build-and-run, and benign build output live in **`references/test-package-wiring.md`** -- load it once test code exists and you need to package and run on QAOps.

## Device Simulators for Real Data-Flow Tests

"Element reached Active" is a necessary but insufficient gate when testing connector communication. If the test also needs to prove the connector can poll or receive data, load **`dataminer-qaops-simulators`** and follow its guidance. A one-line summary of the QAOps DaaS loopback limitations:

| Protocol family | In-process `TcpDeviceSimulator` | `SnmpSimulatorSession` | Packaged WebSocket exe |
|-----------------|---------------------------------|------------------------|------------------------|
| Serial (IP) | ❌ Loopback TCP does not work on DaaS — baseline-controlled design required | — | — |
| Smart-serial (IP, server mode) | ❌ Element listens; `TryPushToElement` required but still fails on DaaS | — | — |
| HTTP | ✅ Use `StartHttpResponder(body)` | — | — |
| SNMP | — | ✅ QADeviceSimulator (needs elevation → `Assert.Inconclusive` fallback) | — |
| WebSocket | — | — | ✅ Packaged `net48` `TcpListener` exe; use full `ws://host:port/path` URL |

Simulate SNMP using files from `S:\Public\Simulations` (or equivalent share) as a starting point for simulation XMLs when available.

## Reference Files

| Topic | Reference File |
|-------|---------------|
| **Supplementary runtime files: CLI upload, target paths, PowerShell/C# machine-level environment access, lifecycle, compatibility, and security** | `dataminer-qaops/references/supplementary-files.md` |
| **Authoring the test project + test code: naming, MSTest project, `.csproj`/MSTest-metapackage settings, identity checklist, real-DataMiner `IDms` setup, Writing-Tests rules** | `dataminer-qaops-integration-testing/references/authoring-test-project.md` |
| **Wiring & shipping the Test Package: reuse/create, Catalog-key user-secrets, prerequisites, harvesting, `TestDiscovery.ps1`, execution pipeline (+ never-gate-the-helper), version/discovery gates, scoped runs, build-and-run** | `dataminer-qaops-integration-testing/references/test-package-wiring.md` |
| `DmsTestSetup` assembly initialize/cleanup template | `dataminer-qaops-integration-testing/references/dms-test-setup.md` |
| **System state preflight, fixture isolation, interference policy, version assertions, non-locking log reading + log-error assertions** | `dataminer-qaops-integration-testing/references/system-state-preflight.md` |
| **Automation test-goal routing: unit vs build/XSD vs QAOps integration vs IAS host vs post-deploy regression** | `dataminer-automation-unit-testing/references/integration-testing-routing.md` |
| Worked example: run Automation script, assert element state, poll-wait, fixture-element creation | `dataminer-qaops-integration-testing/references/example-automation-script-test.md` |
| DataMiner Test Package prerequisites, Catalog IDs, Low-Code App/dashboard exports, runtime-prerequisite cascade, **classic-connector `.dmprotocol` harvesting**, **DataAPI name-based fixtures** | `dataminer-qaops-integration-testing/references/test-package-prerequisites.md` |
| **Migrating an EXISTING MSTest/Playwright test project to QAOps: credential gating, InstallScript setup, runtime-prerequisite cascade, install-dependency harvesting, Playwright HTTPS, template CPM gotchas** | `dataminer-qaops-integration-testing/references/migrating-existing-tests.md` |
| Test Package execution PowerShell pattern | `dataminer-qaops-integration-testing/references/test-package-pipeline.md` |
| **SNMP/TCP/WebSocket device simulators, QAOps DaaS loopback facts, baseline-controlled data-flow design** | `dataminer-qaops-simulators` (separate skill + references/) |
| **Package a classic connector into a `.dmprotocol` (tool install, CLI, MSBuild wiring, trailing-backslash gotcha, deploy)** | `dataminer-dmprotocol-packaging` (separate skill) |
| **Create name-addressable dynamic fixture elements via the DataAPI HTTP feature (and when NOT to — fixed-PID caveat)** | `dataminer-dataapi` (separate skill) |
| **Read/write installed elements by PID, create fixture elements, poll-wait, `GetColumn<T>` nullable-type gotcha** | `dataminer-idms` (separate skill) |
