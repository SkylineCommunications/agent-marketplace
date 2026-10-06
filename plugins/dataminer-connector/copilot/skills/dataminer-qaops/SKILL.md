---
name: dataminer-qaops
description: 'Foundation skill for QAOps (Quality Assurance and Operations): what QAOps is, when to use it, environment/configuration IDs, token handling, and routing to QAOps test-run and integration-test authoring/migration skills. Use when the user says "test with QAOps", "test on RC", "test on a Main/Feature release DataMiner", "run my regression/integration tests", "write tests and run them on a real system", "add a QAOps Test Package", "make our tests run on QAOps", "migrate to QAOps", "did my tests pass", "will my solution break on the next DataMiner release", "check before release", wants to test Automation scripts, connectors, solutions, or element/service behavior on a real DataMiner, or mentions DaaS, quality gates, or .dmtest packages.'
argument-hint: 'Describe the QAOps task: e.g. "test if my Automation script stops all elements of protocol X", "run my test package on latest RC", "create integration tests for QAOps"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-06
  version: 1.17
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-browser-automation`, `dataminer-qaops-ui-automation`, `dataminer-qaops-ui-configurations`, `dataminer-qaops-ui-test-suites`, `github-actions-core`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-browser-automation`: Optional authenticated UI operations, not required for CLI test execution.
> - `dataminer-qaops-ui-automation`: Optional QAOps administration UI workflow; acquire separately when requested.
> - `dataminer-qaops-ui-configurations`: Optional environment administration workflow, not required to run tests on an existing configuration.
> - `dataminer-qaops-ui-test-suites`: Optional UI suite administration workflow, not required for CLI package runs.
> - `github-actions-core`: Optional CI workflow selection; local package authoring and QAOps CLI runs do not require it.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.17 | 2026-10-06 | Documented support escalation contact support.boost@skyline.be for QAOps infrastructure, provisioning, token, and cluster issues. |
| 1.16 | 2026-09-15 | Added runtime-validation boundaries for specialized Automation contracts; static checks do not substitute for GQI, SRM, API, or Node Recovery host evidence. |
| 1.15 | 2026-08-10 | Added routing for QAOps **UI-only management actions**. The `dataminer-qaops` .NET tool exposes only `test-run` and `test-run-and-wait`; creating/updating configurations, registering self-hosted DataMiner agents, managing test suites and their Catalog test packages, global categories, and agent-driven token creation are all Low-Code App actions → `dataminer-qaops-ui-automation` (+ `dataminer-qaops-ui-configurations`, `dataminer-qaops-ui-test-suites`). |Added QAOps **supplementary files** guidance and `references/supplementary-files.md`: runtime upload with repeatable `--supplementary-file`, archive path rules, target extraction locations, QAOps Bridge 1.1.0+ and fresh-token requirements, cleanup/security behavior, and the mandatory machine-level `QAOPS_SUPPLEMENTARY_FILES` access pattern for PowerShell and C# test code. |
| 1.14 | 2026-06-29 | Added **RDP-accessible configurations**: RC/Feature/Main variants that keep the DaaS alive after the run (1-day RDP access, extendable in the UI) so users can debug on the box — RC `01KVTCM4W105H30RMDABYR5W58`, Feature `01KVTCSWN61EFRCGH183X0D070`, Main `01KVTCV9CR2KY6ZXFFEJFMK5WX`. They never reuse a warm DaaS (fresh spin-up adds up to ~30 min), so **default to the standard RC/Feature/Main IDs** and use RDP variants only when the user asks or accepts the offer; on a failed run, offer to re-run on the matching RDP config (warn about the ~30-min spin-up). |
| 1.13 | 2026-06-26 | **Token creation is now one button.** Reworked "How the user can create a token" around the new green **Create Default AI Token** button on the Tokens page: press it, wait a few seconds, click the generated token to copy it, paste in chat — it is preconfigured with the scopes and usage limit needed for agent QAOps runs, so no manual name/Max Uses/scope selection. The old manual **Create Token** flow (uncheck Unlimited Token Usage, set Max Uses ~10–15, pick `Run_Scoped_*` scopes) is kept only as an advanced/custom fallback. Updated the Preflight token question, security rule 1, the inputs checklist, and the `dataminer-qaops-test-runs` token-failure rows to point at the Default AI Token. |
| 1.12 | 2026-06-25 | Added the **Platform: QAOps DataMiner Systems Run on Windows** section. QAOps provisions **Windows** DataMiner agents for every target (RC/Main/Feature), so Windows-only connector/code behavior (WMI, registry, COM, `.exe` tools, Windows paths) is **valid** and must not be relaxed or warned about as a "Linux mismatch". Verified failure mode: a session wrongly told the user "WMI calls will fail on Linux", asked them to choose how to proceed given a non-existent Linux/Windows mismatch, and weakened the test's success criteria — the connector would have worked on the real Windows QAOps target. "DaaS" is the provisioning model, not the OS. |
| 1.11 | 2026-06-19 | Added "What a Standard Run Needs (No Bridge)" under Canonical IDs: a run needs only the test-suite ID, configuration ID, token, and `.dmtest` package(s); there is **no BridgeId** in the run path (BridgeId is a migration-only credential gate). Prevents inventing a bridge requirement and stalling the user with redundant questions. |
| 1.10 | 2026-06-19 | Added an explicit route for "new solution + test on Feature/Main/RC": run preflight, then scaffold immediately with `dataminer-sdk` before authoring tests (`dataminer-qaops-integration-testing`) and running (`dataminer-qaops-test-runs`). |
| 1.9 | 2026-06-15 | Added routing for migrating an existing MSTest/Playwright test project to QAOps ("add a QAOps Test Package", "make our tests run on QAOps", "migrate to QAOps") to `dataminer-qaops-integration-testing` → `references/migrating-existing-tests.md` (credential gating, InstallScript setup, runtime-prerequisite cascade). |
| 1.8 | 2026-06-12 | Scoped "run only my new tests" requests now route to the PipelineLibrary 1.3.0+ `-TestFilter` mechanism (fast ≈4–5 min iterations) instead of temporary `Ignore` attributes; added the background-shell/short-poll rule for long QAOps runs and the filtered-iterations token note (cheap fast runs still consume a use each). |
| 1.7 | 2026-06-12 | Added the Fresh QAOps Artifact rule: for local/new test changes, bump the Test Package `<Version>`, select the exact versioned `.dmtest`, verify packaged MSTest discovery of new tests before submission, and prefer temporary MSTest `Ignore` attributes over unsupported pipeline/filter edits for scoped runs. |
| 1.6 | 2026-06-11 | Token guidance from a real debugging session: recommend Max Uses ~10 (each fix-verify iteration consumes a run; a debug loop exhausted a small-count token mid-investigation), and treat `invalid_client`/`AADSTS7000215` right after token creation as propagation delay (wait 2–3 min, retry once) before assuming a bad paste. |
| 1.5 | 2026-06-11 | Reworked Preflight into a sequence of small focused questions with embedded how-to bullets (QAOps token steps incl. Max Uses). Catalog key is never collected in chat or via mid-session env vars — routed to the user-secrets file flow in `dataminer-qaops-integration-testing`. Added the mid-session environment-variable warning and the prefer-file-path-over-paste rule. |
| 1.4 | 2026-06-11 | Added the Preflight section (collect all tokens/secrets before development starts, incl. the Catalog `skyline__sdk__dataminertoken`), the phase-change re-routing rule against anchoring on a local DataMiner install, and routed IDms code authoring to `dataminer-idms`. |
| 1.3 | 2026-06-10 | Added phrase families: results follow-up, future-release compatibility, pre-release gate, smoke/e2e, version comparison. Added results-handling and CI/CD quality-gate notes. |
| 1.2 | 2026-06-10 | Added the Request Phrase Routing table and the rule that QAOps-context "run my tests" requests mean a QAOps run, not local dotnet test. |
| 1.1 | 2026-06-10 | Broadened discovery triggers (Automation script/element behavior testing), added end-to-end flow for behavior-test requests, and added the target-selection rule. |
| 1.0 | 2026-06-10 | Initial QAOps foundation skill with routing, IDs, token handling, and operating rules. |

# QAOps Foundation

QAOps (Quality Assurance and Operations) is a regression test orchestration platform built on DataMiner. It runs DataMiner test packages on clean DaaS setups, visualizes and stores results, and can be used as a quality gate to block releases or pipeline stages when regressions are detected.

Load this skill whenever the user mentions QAOps, DataMiner regression tests, real DataMiner integration tests, DaaS-based testing, `.dmtest` packages, testing on latest DataMiner Main/RC/Feature releases, or asks to **test the behavior of an Automation script, connector, or solution on a real DataMiner** (e.g. "test if my script stops all elements of protocol X").

## Platform: QAOps DataMiner Systems Run on Windows

QAOps currently provisions **Windows** DataMiner agents for **every** target (RC, Main, and Feature). Treat the system under test as a **Windows** DataMiner — never assume Linux.

- **Windows-only behavior is valid on QAOps.** Connectors and code that rely on WMI (`System.Management`, `Microsoft.Wmi.*`), the Windows registry, COM, `.exe` tooling, Windows file paths (`C:\Skyline DataMiner\...`), or other Windows-only APIs run normally. Do **not** weaken, skip, or mark a test `Inconclusive`, and do **not** warn the user about a "Linux mismatch", just because the connector is Windows-only. Assert the real expected outcome (e.g. a WMI connector reaching the connected/Active state).
- **DaaS ≠ Linux.** "DaaS" is the *provisioning model* (a clean DataMiner is spun up per run), not the operating system. A clean DaaS target is still Windows.
- **Pipeline/setup/InstallScript steps run under Windows PowerShell** on the target, and DataMiner paths in them are Windows paths.
- Environment limitations that *are* real (e.g. serial/smart-serial loopback networking constraints — see `dataminer-qaops-simulators`) are networking limits, not OS limits; do not generalize them into "this is Linux".

Known failure mode this prevents (verified in a real session): the agent stated "The QAOps DataMiner targets run on Linux DaaS … the WMI calls will fail on Linux", asked the user to choose how to proceed given a non-existent Linux/Windows mismatch, and relaxed the test to accept `Unauthorized`/`Unavailable` as the expected outcome. On the real Windows QAOps target the connector would have connected — the test should have asserted that.

## Skill Routing

| Task | Load Skill(s) |
|------|---------------|
| Run existing integration/regression tests through QAOps | `dataminer-qaops` + `dataminer-qaops-test-runs` |
| Create or wire real DataMiner integration tests for QAOps | `dataminer-qaops` + `dataminer-qaops-integration-testing` |
| Migrate an EXISTING MSTest/Playwright test project to QAOps (add a Test Package, gate credentials, run on a bridge) | `dataminer-qaops` + `dataminer-qaops-integration-testing` → `references/migrating-existing-tests.md` |
| Test Automation script / element / service behavior on a real DataMiner | `dataminer-qaops` + `dataminer-qaops-integration-testing`, then `dataminer-qaops-test-runs` |
| Create or update a DataMiner Test Package project | `dataminer-qaops-integration-testing` + `dataminer-sdk` |
| Write the IDms code that the script or test uses to manipulate DataMiner | `dataminer-idms` |
| Write SLProtocolMock-only QAction unit tests | `dataminer-unit-testing` |
| Build or scaffold with official Skyline templates/tools | `dataminer-sdk` |
| Open a QAOps Low-Code App in a browser to look at it or screenshot it (not a test run) | `dataminer-browser-automation` |
| Create/update a QAOps **configuration**, register a self-hosted DataMiner agent or cluster, manage global categories | `dataminer-qaops-ui-automation` + `dataminer-qaops-ui-configurations` |
| Create/update a QAOps **test suite**, add/remove/reorder its Catalog **test packages** | `dataminer-qaops-ui-automation` + `dataminer-qaops-ui-test-suites` |
| Have the **agent** create a QAOps token in the UI (instead of asking the user) | `dataminer-qaops-ui-automation` |

Do not confuse QAOps integration tests with SLProtocolMock unit tests. QAOps integration tests run against a real localhost DataMiner in a provisioned environment. SLProtocolMock tests run locally without a live DataMiner. Automation scripts and element behavior **cannot** be tested with SLProtocolMock.

### Specialized Automation runtime boundary

QAOps can host a compatible DataMiner environment, but it does not automatically provide a dedicated harness for every
Automation-related feature. Keep evidence separated:

| Contract | QAOps/runtime evidence |
|---|---|
| GQI ad hoc data source | A compatible GQI DxM query smoke test can verify discovery, arguments, columns, pages, keys, and updates. A build or unit test alone cannot. Do not claim this is available unless the target environment exposes GQI. |
| SRM | PLS Tester or configured SRM booking/service-profile/orchestration fixtures. Do not substitute a generic script run for SRM timing or role behavior. |
| User-Defined API | Authenticated HTTPS request against the configured endpoint/definition/token, including negative method/route/status cases. Keep tokens in the QAOps secret flow and never in the repository or logs. |
| Node Recovery | Controlled multi-Agent outage/maintenance/leader scenario. No dedicated harness, retry guarantee, ordering guarantee, or enum mapping is implied by this skill. |

If the required fixture or target is unavailable, report the host-level check as skipped/unverified and retain static
contract evidence without creating a success-shaped fallback.

## Request Phrase Routing

Common user phrasings and what they mean:

| User says (or similar) | Interpretation | Route |
|------------------------|----------------|-------|
| "Test with QAOps" | Run the solution's test packages on QAOps | `dataminer-qaops-test-runs`; ask for the target if not given |
| "Test on RC" / "test on a Main release DataMiner" / "test on Feature" | Run test packages on that QAOps target | `dataminer-qaops-test-runs` with the matching configuration ID |
| "Run my regression tests" / "run my integration tests" | Execute the existing `.dmtest` test packages on QAOps | `dataminer-qaops-test-runs` |
| "Write tests and run them on a real system" | Author integration tests, then execute them on QAOps | `dataminer-qaops-integration-testing`, then `dataminer-qaops-test-runs` |
| "Create/add a new solution and test it on Feature/Main/RC" | New-solution QAOps flow | `dataminer-sdk` (scaffold first), then `dataminer-qaops-integration-testing`, then `dataminer-qaops-test-runs` |
| "Add a QAOps Test Package" / "make our existing tests run on QAOps" / "migrate our integration/Playwright tests to QAOps" | Migrate an existing test project: gate credentials, wire/harvest into a Test Package, replicate runtime setup, run on a bridge | `dataminer-qaops-integration-testing` → `references/migrating-existing-tests.md`, then `dataminer-qaops-test-runs` |
| "Test if my script/connector/solution does X" | Author (or update) a behavior test, then run it | `dataminer-qaops-integration-testing`, then `dataminer-qaops-test-runs` |
| "Will my solution still work on the next DataMiner release?" / "will the new DataMiner break my solution?" | Run existing test packages against RC (the upcoming release) | `dataminer-qaops-test-runs` with the RC configuration |
| "Check my solution before we release" / "run a sanity/smoke check" / "run the end-to-end tests" | Run all relevant test packages as a quality gate | `dataminer-qaops-test-runs`; run all packages unless scoped |
| "Does it work on both Main and RC?" / "test on multiple DataMiner versions" | One run per target configuration | `dataminer-qaops-test-runs`, repeated per target, compare result files |
| "Did my tests pass?" / "what were the results?" / "did the run finish?" | Inspect an earlier run's outcome | Read the `-rf` result JSON from the earlier run in this session; if none exists, point the user to the QAOps UI using the run's `-tags` value |
| "Verify my fix didn't break anything" / "make sure nothing regressed" | Regression run of all test packages | `dataminer-qaops-test-runs`, all packages on the user's target |
| "Show me / screenshot the QAOps app page" / "what does the app look like now" | Look at a live QAOps Low-Code App in a browser — **not** a test run | `dataminer-browser-automation` |
| "Create/update a QAOps configuration" / "add our DataMiner agent to QAOps" / "add a test package to the suite" / "make me a test suite" | A UI-only management action — the .NET tool only runs suites | `dataminer-qaops-ui-automation`, then `dataminer-qaops-ui-configurations` or `dataminer-qaops-ui-test-suites` |

**"Run my tests" in a QAOps/DataMiner-testing context means running the test packages on a QAOps DataMiner — not `dotnet test` on the local machine.** Local `dotnet test` cannot reach a real DataMiner and would fail or give meaningless results for integration tests. Only run unit-test projects locally; `.dmtest` integration tests run through QAOps.

If the solution has no Test Package projects yet, a "run my tests" request cannot be fulfilled directly — offer to create the integration tests and Test Package first (`dataminer-qaops-integration-testing`).

For "new solution" requests, do not delay with local project archaeology: after preflight, scaffold with official templates immediately via `dataminer-sdk`, then continue the QAOps flow.

## End-to-End Flow for Behavior-Test Requests

When the user asks to verify behavior on a real DataMiner (e.g. "test if my Automation script correctly stops all elements of the Microsoft Platform protocol"), the full flow is:

1. Load `dataminer-qaops-integration-testing`. Write or update an MSTestV2 integration test that arranges the needed DataMiner state, executes the behavior (e.g. runs the script via `IDms`), and asserts the outcome (e.g. element states).
2. Ensure prerequisites are in the Test Package: same-solution Automation scripts and connectors are included by default; out-of-solution connectors (e.g. Microsoft Platform) are added from the Catalog.
3. Wire the test into a DataMiner Test Package project.
4. Bump the Test Package project `<Version>`, build the package, select the exact `<Project>.<Version>.dmtest`, and verify the extracted package contains/discovers the newly added MSTestV2 test names before any QAOps submission.
5. Load `dataminer-qaops-test-runs`. Run that exact `.dmtest` with `dataminer-qaops test-run-and-wait` on the requested DataMiner target and process the results.

Authoring the test locally is **not** the end of the task — the test only proves the behavior once it has run on a QAOps DataMiner and the results have been processed.

## Preflight: Collect Everything Before Development Starts

For any request that ends in "and verify/test it on a real DataMiner", determine **up front** — before writing code — which credentials and inputs the whole flow will need. Do not start a multi-hour development flow and only discover a missing token at the final verification or packaging step.

Ask for the inputs as a **short sequence of focused `ask_user` questions** — one item per question, each with a 2–4 bullet "how to get it" explanation inside the question text. Do **not** bundle everything into one combined mega-question: users need per-item guidance, and large pasted answers (e.g. a whole `protocol.xml`) become unmanageable.

Question sequence (skip items the flow does not need):

1. **DataMiner target** — multiple choice: RC / Main / Feature. Never pick silently.
2. **QAOps token** — embed the creation steps from "How the user can create a token" below as bullets in the question itself. The quickest path is the green **Create Default AI Token** button at the top of the Tokens page (preconfigured scopes + usage): press it, wait a few seconds, click the generated token to copy it, and paste it in chat. Pasting *this* token in chat is acceptable — it is short-lived and designed for that.
3. **Catalog organization key availability** (only when out-of-solution Catalog content is needed) — ask only whether the user **has** (or can create) an Organization Key on `https://admin.dataminer.services` (organization settings → keys, Catalog download permission). Tell them explicitly **not to paste the key in chat**: it will be placed in the Test Package project's user-secrets file later, once that project exists. Follow `dataminer-qaops-integration-testing` → "Catalog Key via User Secrets" for the storage step.
4. **Domain inputs** (page/parameter definitions, DMA hosts, …) — when a local file such as `protocol.xml` is needed, ask for the **file path**, not a paste. Pastes can run to hundreds of KB and slow the whole session down.
5. **Supplementary runtime files** (only when the test needs external files that should not be embedded in the `.dmtest`) — collect their local file paths and pass them with `--supplementary-file`. Do not ask the user to paste file contents.

Checklist of what the flow may need:

| Will the flow...? | Then you need | How to get it |
|-------------------|---------------|---------------|
| Run a `.dmtest` on QAOps (always, for real-system verification) | A QAOps token | User clicks **Create Default AI Token** on the QAOps Tokens page (see Token Handling below) |
| Need an out-of-solution connector or other Catalog item on the test DataMiner (e.g. the test targets elements of a connector like "Microsoft Platform" that is not in the solution) | DataMiner Catalog **organization download key**, stored as the `skyline:sdk:dataminertoken` user secret of the Test Package project | User creates an Organization Key on `https://admin.dataminer.services` (organization settings → keys) with Catalog download permission, then pastes it into the pre-provisioned `secrets.json` — never into chat |
| Export a Low-Code App or dashboard from another DataMiner | That DMA's host + credentials | Ask the user |
| Need runtime files on every QAOps agent without embedding them in the `.dmtest` | Local paths to the supplementary files | Pass each path with `--supplementary-file`; consumers read machine-level `QAOPS_SUPPLEMENTARY_FILES` |
| Target a specific DataMiner version (RC/Main/Feature) | The user's target choice | Ask, never pick silently |

If the user cannot provide an item (e.g. no Catalog key), say immediately which part of the verification will be blocked instead of discovering it at build time.

**Mid-session environment variables never work.** The CLI host process captured its environment at startup; variables the user sets while the session is running (via `setx`, Windows Settings, or a profile) are invisible to every shell the agent spawns. Never advise exposing `skyline__sdk__dataminertoken` as an environment variable during a session — use the user-secrets file flow instead, and verify with `dotnet user-secrets list` (key presence only, never echo values). The SDK fails Test Package builds containing `CatalogReferences.xml` entries with an error mentioning `skyline:sdk:dataminertoken` / `skyline__sdk__dataminertoken` when the key is absent.

This warning does **not** apply to `QAOPS_SUPPLEMENTARY_FILES`: QAOps Bridge creates that variable on
the target machine for the active run. PowerShell and C# consumers must query it at runtime with
`EnvironmentVariableTarget.Machine`; see `references/supplementary-files.md`.

## Phase Change = Re-Route (Do Not Anchor on a Local DataMiner)

Tasks like "write X and test it on a real DataMiner" have two phases with **different execution paths**:

1. **Authoring** — write the script/connector/test code locally. A locally installed DataMiner (`C:\Skyline DataMiner`) is irrelevant here beyond being a coincidental artifact on the machine.
2. **Verification** — prove the behavior on a real system. This phase **always** goes through QAOps (`dataminer-qaops-integration-testing` → `dataminer-qaops-test-runs`).

When the task transitions from authoring to verification, **stop and re-read this skill's routing** before acting. Known failure mode to avoid: discovering a local DataMiner installation and then sinking time into making local `dotnet test` connect to it (SLNet DLL references, reflection-loading `C:\Skyline DataMiner\Files` assemblies, IPC channel registration, local authentication). None of that is the supported path and it does not satisfy "verify on a real system".

Hard rules:

- Never run QAOps-style integration tests with local `dotnet test` as the verification step. They are designed to run inside the QAOps-provisioned environment where credentials (`QAOpsDataMinerUser`/`QAOpsDataMinerPassword`) exist. Locally they fail with authentication errors — that is expected, not a bug to fix.
- Never add references to DLLs from a local `C:\Skyline DataMiner` installation, and never reflection-load them to work around package gaps.
- A successful local **build** of the test project plus a green **QAOps run** is the definition of done; a local test run is neither required nor meaningful.

## QAOps Access Paths

Skyline Communications users can access QAOps through:

- QAOps low-code apps for common operations.
- The `dataminer-qaops` .NET global tool for command-line workflows.
- Visual Studio / SDK-style DataMiner Test Package projects that build `.dmtest` packages.

The production token page is:

```text
https://qaops-skyline.on.dataminer.services/app/8f36715b-d50d-4463-9d2d-c38170929ee4/Tokens
```

## Canonical IDs

Always use this QAOps Test Suite ID:

| Purpose | ID |
|---------|----|
| Test Suite | `01KTRNHRHWQJ9SMESYJAFP8SE9` |

Choose the configuration ID from the requested DataMiner target. **Default to the standard configurations below** — they reuse warm DaaS systems and start quickly:

| Requested target | Configuration ID |
|------------------|------------------|
| Latest DataMiner Release Candidate (RC) | `01KTRNMVWEZX5EAW3GRDB744G4` |
| Latest DataMiner Main release | `01KTRNTY3WW3JANCQ7WPWBEAVM` |
| Latest DataMiner Feature release | `01KTRNSARVCH5DG50QM0RW7GYA` |

If the user says "latest main release", use the Main configuration ID. If examples or prior notes conflict, prefer the explicit table above.

**If the user did not specify a DataMiner target (RC, Main, or Feature), ask which one to use before running.** Do not silently pick one.

### RDP-Accessible Configurations (DaaS Kept Alive for Debugging)

QAOps also offers RC/Feature/Main variants that **do not remove the DaaS when the run finishes**, so the user can **RDP into the server and debug the failure directly**. RDP access lasts **1 day** unless manually extended in the QAOps UI.

| Requested target | RDP-accessible Configuration ID |
|------------------|---------------------------------|
| RC + RDP access | `01KVTCM4W105H30RMDABYR5W58` |
| Feature + RDP access | `01KVTCSWN61EFRCGH183X0D070` |
| Main + RDP access | `01KVTCV9CR2KY6ZXFFEJFMK5WX` |

These configurations **never** reuse a ready DaaS — a fresh one is spun up at request time, adding **up to ~30 minutes** before tests run. **Never pick them by default.** Use them only when the user explicitly asks for RDP access, or offered the option (below) and accepted; always warn about the ~30-minute spin-up first.

**On a failed run, offer RDP debugging.** When a run fails and the cause is not clear from the assertion messages/logs, ask the user (via `ask_user`) whether to re-run the same package on the matching RDP-accessible configuration so they can RDP in and debug on the box. Explain it spins up a fresh DaaS so it takes up to ~30 minutes longer, and RDP access stays open for 1 day (extendable in the QAOps UI).

### What a Standard Run Needs (No Bridge)

A standard QAOps test run requires only four things: the **Test Suite ID** (`-t`), the target **Configuration ID** (`-c`, RC/Main/Feature from the table above), a **QAOps token** (`--token`), and one or more built **`.dmtest`** package(s) (`--test-packages`) — plus `-tags` and `-rf` for traceability. That is the complete input set for `dataminer-qaops test-run-and-wait`.

There is **no "BridgeId"** and no bridge involved in *running* a test package. Do **not** ask the user for a BridgeId, environment name, or bridge in order to run — everything needed is the suite ID, the configuration ID, the token, and the package. `BridgeId` is an unrelated **credential-gating** detail that appears **only** when *migrating an existing* MSTest/Playwright test project onto QAOps (see `dataminer-qaops-integration-testing` → `references/migrating-existing-tests.md`); it is never a parameter of a run.

Supplementary files are an optional fifth runtime input. Use repeatable `--supplementary-file` options
when tests need external files without embedding them in the `.dmtest`. The Bridge extracts them on
every agent; consumers use machine-level `QAOPS_SUPPLEMENTARY_FILES`. Full rules and PowerShell/C#
examples: `references/supplementary-files.md`.

## QAOps Token Handling

QAOps commands require a short-lived token. If no QAOps token has already been provided in the current session, ask the user for one before running QAOps.

Security rules:

1. Ask the user for a token created via the **Create Default AI Token** button (short-lived and preconfigured with the right scopes and usage limit; see "How the user can create a token").
2. Do not store the token in repository files, plan files, logs, examples, or persistent memory.
3. Do not echo the token back to the user.
4. Always pass the token as `--token "<token>"` with double quotes.
5. If the first call shortly after token creation fails with `Unauthorized` **or** `invalid_client` / `AADSTS7000215` ("Invalid client secret provided"), assume token propagation delay: wait 2–3 minutes and retry once before suspecting a bad paste or asking for a new token.
6. If the token was created a while ago and Unauthorized persists, treat it as expired, usage-exhausted, or incorrectly scoped and ask for a new token.
7. Track usage: every `test-run-and-wait` submission consumes one use (failed runs included). When a debugging loop approaches the token's usage limit, tell the user before the token runs out so they can generate a fresh Default AI Token.

### How the user can create a token

Getting a token is now a couple of clicks. Include these steps **as a bullet list inside the `ask_user` question** that requests the token — do not assume the user knows the procedure. Tell the user to:

1. Go to `https://qaops-skyline.on.dataminer.services/app/8f36715b-d50d-4463-9d2d-c38170929ee4/Tokens`.
2. At the top of the page, click the green **Create Default AI Token** button (next to **Create Token**).
3. Wait a few seconds for the token to be generated.
4. Click the generated token — this copies it to the clipboard.
5. Paste the token into chat.

The **Default AI Token** is preconfigured with the scopes and usage limit needed for agent-driven QAOps test runs, so the user does **not** need to name it, uncheck Unlimited Token Usage, set a Max Uses count, or pick scopes manually. Pasting this token in chat is acceptable — it is short-lived and designed for that.

> **Fallback — manual token (advanced/custom only).** If the Default AI Token button is unavailable or the user needs custom scopes/usage, they can instead click **Create Token**, give it a name, uncheck **Unlimited Token Usage**, set a Max Uses count (~10, or ~15 for a test-development session — every submission consumes a use, including stopped/failed runs), select the `Run_Scoped_RC` / `Run_Scoped_Feature` / `Run_Scoped_Main` scopes, and generate. Prefer the Default AI Token for normal use.

## Operating Rules

- QAOps runs can take 10 minutes or more. Do not treat long runtime as failure.
- Prefer `dataminer-qaops test-run-and-wait` for command-line execution because it blocks until completion and can write a result JSON file.
- Always use a unique human-readable `-tags` value under 100 characters so people can find the run in the QAOps UI.
- Always use `-rf "<result-file>.json"` when running tests so results can be parsed later in the session.
- Write result files to a temporary or build-output location and do **not** commit them to the repository.
- Remember the `-tags` value and result file path for the rest of the session — follow-up questions like "did my tests pass?" are answered from them.
- Always quote token values and file paths.
- When supplementary runtime files are needed, pass each with `--supplementary-file`; never embed secrets. Read them through machine-level `QAOPS_SUPPLEMENTARY_FILES` in code that may run on any agent.
- Do not assume all test packages should run. Run all packages only when the user asks for the full solution or when all discovered packages are relevant. If the relevant subset cannot be deduced, ask.
- For local changes or newly authored tests, never submit a stale or ambiguous package. Increment the Test Package `<Version>`, build, select the exact versioned `.dmtest`, extract it, and verify the expected new MSTestV2 test names are discoverable from the packaged assembly/executable.
- For "run only my new tests" requests, use the PipelineLibrary 1.3.0+ `-TestFilter` parameter on `Invoke-DotNetTestAndPublishResults` in the package pipeline (see `dataminer-qaops-integration-testing` → "Scoped Runs") — filtered runs are fast (≈4–5 min vs ≈55 min full-suite, measured) and publish the executed tests by name. Restore the unfiltered pipeline before the final full regression run. Temporary MSTest `Ignore` attributes are only the fallback when the module cannot be 1.3.0+.
- QAOps runs are long: launch them in background shells and poll briefly instead of blocking in one long wait, so user input stays responsive (details: `dataminer-qaops-test-runs` → "Long-Running Wait Behavior").

### Target intuition

- **RC** = the upcoming DataMiner release. Use it for "will the next release break my solution?" compatibility checks.
- **Main** = the latest released version. Use it for "does my change work on current production-grade DataMiner?" checks.
- **Feature** = the newest feature build. Use it for early validation against in-development DataMiner functionality.

### CI/CD quality gates

QAOps results can gate releases: a failing run can block a pipeline. When the user wants automated gating (e.g. in GitHub Actions), run `dataminer-qaops test-run-and-wait` in the pipeline, fail the job on a non-zero exit code or failed results in the `-rf` JSON, and provide the token via the `QAOPS_TOKEN` environment variable from a pipeline secret — never hardcode it. For Skyline workflow authoring conventions, load `github-actions-core`.

### Support and escalation

If an issue occurs with QAOps infrastructure, provisioning, token authentication, cluster communication, or DaaS availability, contact **`support.boost@skyline.be`**.

## Reference Skills

| Topic | Skill |
|-------|-------|
| Supplementary file upload, extraction, lifecycle, and PowerShell/C# access | `dataminer-qaops/references/supplementary-files.md` |
| Running `.dmtest` packages and processing QAOps results | `dataminer-qaops-test-runs` |
| Creating MSTestV2 real DataMiner integration tests and Test Package wiring | `dataminer-qaops-integration-testing` |
| Official Skyline templates and SDK-style project behavior | `dataminer-sdk` |
| Opening a live DataMiner/QAOps app in a browser and capturing screenshots (saved sign-in, image conventions) | `dataminer-browser-automation` |
| Performing QAOps management actions in the UI (configurations, self-hosted agents, test suites, test packages, tokens) | `dataminer-qaops-ui-automation` |
