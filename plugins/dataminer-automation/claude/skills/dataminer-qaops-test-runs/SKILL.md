---
name: dataminer-qaops-test-runs
description: Run DataMiner integration or regression test packages through QAOps using dataminer-qaops test-run-and-wait. Use when the user says "test with QAOps", "test on RC", "test on a Main/Feature release DataMiner", "run my regression tests", "run my integration tests", or wants existing tests executed on a real system. Covers TestPackage project discovery, fresh versioned .dmtest artifact selection, packaged MSTest discovery checks, scoped -TestFilter runs, supplementary runtime files, QAOps tool install/update, RC/Main/Feature configuration IDs, token handling, long-running waits and timing expectations, result files, tags, and result processing.
argument-hint: 'Describe the test target: e.g. "run my regression tests on RC", "test the solution on a Main release DataMiner", "run all .dmtest packages on Feature"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-08-07
  version: 1.18
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.18 | 2026-08-07 | Added supplementary-file run support: repeatable `--supplementary-file`, file/path semantics, no-rebuild behavior for file-only changes, fresh-token and QAOps Bridge 1.1.0+ requirements, and routing to `dataminer-qaops/references/supplementary-files.md` for PowerShell/C# machine-level `QAOPS_SUPPLEMENTARY_FILES` access. |
| 1.17 | 2026-06-29 | Added the RDP-accessible configuration IDs (RC `01KVTCM4W105H30RMDABYR5W58`, Main `01KVTCV9CR2KY6ZXFFEJFMK5WX`, Feature `01KVTCSWN61EFRCGH183X0D070`) that keep the DaaS alive for on-server debugging (1-day RDP access). Default to the standard warm-DaaS targets; RDP variants always spin up a fresh DaaS (~30 min longer), so use only on request or via the on-failure offer. Added a workflow step to offer an RDP re-run when a failure's cause is unclear. Rules in `dataminer-qaops` → "RDP-Accessible Configurations". |
| 1.16 | 2026-06-26 | Token-creation simplified: the token-availability step and the two token-failure troubleshooting rows now point at the new **Create Default AI Token** button (preconfigured scopes + usage) instead of the manual "create a token with `Run_Scoped_*` scopes / Max Uses ~10" flow. Full procedure in `dataminer-qaops` → "How the user can create a token". |
| 1.15 | 2026-06-25 | Result-processing hardening from a real session. (1) An overall `OK`/`FINISHED OK` run with **no per-test rows** (and no `pipeline_2.TestPackageExecution` row) is **invalid evidence, not a pass** — the runner matched/ran 0 tests or the helper was bypassed, usually a packaging/discovery defect; fix discovery + resubmit. (2) Packaged-discovery must use a **real runner** (`dotnet vstest "<dll>" --ListTests`), not `dotnet test --list-tests` (fails on a standalone net48 DLL) and not a byte-scan (freshness only). (3) When the user must read something from the QAOps UI, give the exact `BUILD_URL` deep link from the result JSON — never a generic app URL + "find the run by tag" (a session ended with the user replying "I cannot find the run"); custom `Push-TestCaseResult` Message text often lives only in the UI, not in `LOG_LINES`. |
| 1.14 | 2026-06-17 | Hardened the no-per-test-row / pipeline-level-only troubleshooting rows: a `CompletedWithFailures` with no per-test row can mean the pipeline **gated/bypassed** `Invoke-DotNetTestAndPublishResults` — a `throw`/`exit` (e.g. a redundant `dotnet test … ; if ($LASTEXITCODE){ throw }` "diagnostic") placed before the helper throws on every failing test, so no per-test rows publish and the run collapses to one detail-less `pipeline_… - Fail` row. Fix: helper first and un-gated; a failing test is not a pipeline failure; extra diagnostics must be additive. See `dataminer-qaops-integration-testing/references/test-package-pipeline.md` → "Pipeline Integrity". |
| 1.13 | 2026-06-17 | Added troubleshooting for the `AssemblyInitialize` `FileLoadException` on `System.Security.Cryptography.ProtectedData 9.0.0.0` (0x80131040) at `Keys.TryRetrieveKey`: the net48 test project is missing `Microsoft.NET.Test.Sdk` (use the single `MSTest` metapackage so the `.dll.config` binding redirects are generated). Noted that a no-per-test-row `CompletedWithFailures` usually means `AssemblyInitialize` threw and a throwing cleanup path can mask it. |
| 1.12 | 2026-06-16 | Added troubleshooting rows from a migration session: build prints `Successfully created package` despite `error : Failed to download catalog item` (stale `.dmtest` — grep and treat as failure); Catalog `Version could not be resolved`/`404` from a public `manifest.yml` placeholder ID (find the real ID via `gh variable list … CATALOGIDENTIFIER*`); `AppPackageInstaller 4.0.0 is not compatible with AppPackageCreator 3.1.1.0` (don't downgrade `global.json` SDK); and `This solution requires SDM/Categories … deploy … first` even though referenced (embedded `.dmapp`s install in alphabetical filename order — numeric `<Name>` prefixes). All route to `migrating-existing-tests.md` Section 3. |
| 1.11 | 2026-06-15 | Added troubleshooting for the `Missing 'libraryName' param on exe` build error (a `<ProjectReference>` to a Package project in a TestPackage — use an `<MSBuild>` task + post-build `.dmapp` copy instead) and noted that a same-solution deployment package can be built locally and bundled as a `.dmapp` to avoid Catalog-org restrictions. Routes to `migrating-existing-tests.md` Section 3. |
| 1.10 | 2026-06-15 | Added troubleshooting rows for the runtime-prerequisite cascade on a clean DaaS (`InstallingDependencies` failing on `(slc)standard_data_model` / `ElementNotFoundException` / `(slc)<module>` → mirror the solution's own installer), InstallScript dependency-harvesting failures (`CS0006` / subscript "Errors in CSharp script code"), the Playwright `http://localhost` `ERR_CONNECTION_REFUSED` fix (HTTPS browser URL vs bare-host SLNet), and Catalog organization-scope download failures. All route to the new `migrating-existing-tests.md`. |
| 1.9 | 2026-06-12 | Scoped runs now use PipelineLibrary **1.3.0** `-TestFilter`/`-PublishNotExecuted` (≈4.5 min vs ≈55 min full-suite, measured) instead of temp `Ignore` attributes; never invoke the packaged exe with `--filter` directly (publishes no per-test rows). Corrected the `-rf` JSON contract: `LOG_LINES` DOES carry per-test rows (`TestName - Ok/NotExecuted/Fail`) — grep it for new-test names and require explicit `Ok` rows. Documented the timing model (silence ≈33 min after `STATUS RunningTests`, then gradual row publishing — not a hang) and the short-poll wait pattern (async shell, ≤30 s reads, `-rf` file-existence probe; never one long blocking wait). |
| 1.8 | 2026-06-12 | Added Fresh Artifact rules for local changes: bump Test Package `<Version>`, select the exact `<Project>.<Version>.dmtest`, verify extracted package contents and MSTest discovery for newly added tests before QAOps, and validate result evidence contains the expected new tests when per-test rows are available. Added scoped-run guidance to prefer temporary MSTest `Ignore` attributes over unsupported TestPackagePipeline/filter edits. |
| 1.7 | 2026-06-12 | New troubleshooting rows from a measured session: `IncorrectDataException "Invalid connection type provided at index 0"` (IDms `ElementConfiguration` cannot build connections for serial connectors — duplicate-or-fail strategy, batch variants into ONE run instead of one guess per run, which cost 4 runs) and `ParameterNotFoundException` with the misleading "TabletPC inking error code" COM text (PID missing on that protocol version; `Protocol.Version` may be literal `"Production"`). |
| 1.6 | 2026-06-11 | Documented the per-test console output contract (`TestName - Fail: <assertion message + stack>` is the only per-test diagnostic that reaches the session — design tests so assertion messages carry system state), token-use accounting (every submission consumes a use; failed runs included), and new troubleshooting rows: `invalid_client`/`AADSTS7000215` propagation, "maximum usage" token exhaustion, and `CompletedWithFailures` without explanatory test detail (improve test diagnostics instead of guess-fixing). |
| 1.5 | 2026-06-11 | Help probe is now once-per-session (after install/update). Documented the run-level-only `-rf` JSON shape for the canonical suite (per-test TRX details live in the QAOps UI). |
| 1.4 | 2026-06-11 | Added `AuthorizationPermissionMismatch` upload troubleshooting (storage-permission propagation; wait and retry once). |
| 1.3 | 2026-06-10 | Added full CLI options reference (hotfix, storage account, overrides, timeout, log level), `QAOPS_TOKEN` env var guidance, override mutual-exclusivity rules, multi-target comparison runs, and a troubleshooting table. |
| 1.2 | 2026-06-10 | Added natural-language trigger phrases ("test with QAOps", "test on RC/Main/Feature", "run my regression/integration tests") to the description. |
| 1.1 | 2026-06-10 | Added the ask-when-unspecified rule for the DataMiner target. |
| 1.0 | 2026-06-10 | Initial QAOps test run workflow for discovering, building, running, waiting, and processing `.dmtest` packages. |

# QAOps Test Runs

Use this skill to run integration or regression tests on a real QAOps-provisioned DataMiner system. Load `dataminer-qaops` first for QAOps background, token rules, and canonical IDs.

Requests like "run my regression tests", "run my integration tests", or "test with QAOps" mean executing the solution's `.dmtest` test packages through QAOps — not running `dotnet test` locally.

QAOps runs commonly take 10 minutes or more. Use long-running command handling and do not stop just because there is no immediate final result.

## Canonical IDs

Always use this test suite:

```text
01KTRNHRHWQJ9SMESYJAFP8SE9
```

Configuration IDs — **default to the standard (fast, warm-DaaS) targets**:

| Target | Configuration ID |
|--------|------------------|
| Latest RC | `01KTRNMVWEZX5EAW3GRDB744G4` |
| Latest Main | `01KTRNTY3WW3JANCQ7WPWBEAVM` |
| Latest Feature | `01KTRNSARVCH5DG50QM0RW7GYA` |

RDP-accessible variants keep the DaaS alive after the run (1-day RDP access) for on-server debugging, but spin up a fresh DaaS each time (~30 min longer) — use only on request or after offering on failure:

| Target + RDP access | Configuration ID |
|---------------------|------------------|
| RC + RDP | `01KVTCM4W105H30RMDABYR5W58` |
| Main + RDP | `01KVTCV9CR2KY6ZXFFEJFMK5WX` |
| Feature + RDP | `01KVTCSWN61EFRCGH183X0D070` |

See `dataminer-qaops` → "RDP-Accessible Configurations" for the default/offer rules.

## End-to-End Workflow

1. Identify the requested target: RC, Main, or Feature. **If the user did not specify a target, ask which one to use** — do not silently pick one. Default to the standard config; only use an RDP-accessible config when the user wants to RDP in and debug (it adds ~30 min for a fresh DaaS — see Canonical IDs).
2. Ensure a QAOps token is available in the current session. If not, ask the user to create one via the **Create Default AI Token** button on the Tokens page (see `dataminer-qaops` → "QAOps Token Handling").
3. Ensure the QAOps .NET tool is installed and up to date.
4. Locate the solution root containing `.sln` or `.slnx`.
5. Find DataMiner Test Package projects.
6. Decide whether to run all packages or a relevant subset.
7. Determine whether the run needs supplementary runtime files. Validate each local file path and add one `--supplementary-file` option per file. See `dataminer-qaops/references/supplementary-files.md`.
8. When running local changes or newly authored tests, apply the Fresh Artifact Gate: bump the selected Test Package project `<Version>`, build it, select the exact `.dmtest` whose filename contains that new version, and verify extracted package contents plus MSTest discovery for the expected new test names. A change to only a supplementary file does not require a package rebuild.
9. For unchanged existing regression packages, build the selected test package projects so `.dmtest` artifacts are generated and locate the artifacts in the project bin output.
10. Run `dataminer-qaops test-run-and-wait` with quoted package paths, any quoted supplementary-file paths, quoted token, unique tags, and a JSON result filepath.
11. Wait for completion, stream meaningful progress, then parse the result file before reporting the final outcome.
12. On failure where the cause is unclear, offer to re-run on the matching **RDP-accessible** configuration (warn: fresh DaaS, ~30 min longer; RDP open 1 day) so the user can debug on the server — see `dataminer-qaops` → "RDP-Accessible Configurations".
13. If this run was meant to validate newly added tests, confirm the QAOps evidence is compatible with those tests having run: per-test rows/output should include the expected new test names when available; otherwise the pre-run packaged-discovery gate is the minimum required evidence.

## Install or Update the QAOps Tool

The tool is published on NuGet. Always include the NuGet source explicitly.

Check whether it is installed:

```bash
dotnet tool list --global
```

Install when missing:

```bash
dotnet tool install Skyline.DataMiner.qaops --global --add-source https://api.nuget.org/v3/index.json
```

Update when present:

```bash
dotnet tool update skyline.dataminer.qaops --global --add-source https://api.nuget.org/v3/index.json
```

Then call the tool with:

```bash
dataminer-qaops
```

## Find Test Package Projects

Search `.csproj` files for both:

```xml
<Project Sdk="Skyline.DataMiner.Sdk">
```

and:

```xml
<DataMinerType>TestPackage</DataMinerType>
```

When compiled, each such project creates a `.dmtest` package in its bin output folder.

If multiple Test Package projects exist:

- Run all when the user asks to test the whole solution.
- Run only the relevant subset when the user asks to test a specific feature, package, or change and the mapping is clear from changed files/project names.
- Ask the user when the relevant subset cannot be deduced safely.

## Build and Locate `.dmtest` Files

Build the selected project(s) using the solution or direct project path:

```bash
dotnet build "<path-to-solution-or-test-package-project>"
```

Then locate generated `.dmtest` files below the selected project bin folders. Do not invent package paths; verify the actual files exist before running QAOps.

### Fresh Artifact Gate for local changes

When testing code or test changes from the current worktree, stale `.dmtest` files are the most common false-positive/false-negative source. Do this before every QAOps submission that should include new tests or changed test code:

1. Read the selected Test Package project `<Version>` property, increment it (normally patch), and record the new value.
2. Build the selected Test Package project or solution.
3. Select only the artifact named like `<TestPackageProject>.<Version>.dmtest`. Never pick a package by "latest modified" alone and never submit older artifacts left in `bin`.
4. Extract that exact `.dmtest` to a temporary folder and verify it contains the harvested test assembly/executable under `AppInstallContent\DmTest\TestHarvesting\tests.generated\...`.
5. For newly added or changed MSTestV2 tests, run discovery/list-tests on the extracted assembly/executable without executing the integration tests, and verify every expected new test class/method name is listed. Use a **real runner** command — for a net48 MSTest DLL, `dotnet vstest "<dll>" --ListTests` (or `vstest.console.exe "<dll>" /ListTests`); `dotnet test --list-tests` does not work on a standalone net48 DLL. A UTF-8/byte scan of the DLL proves only *freshness*, never discovery (see `dataminer-qaops-integration-testing` → `references/test-package-wiring.md`).

If any expected new test is absent, do not submit to QAOps. Fix the MSTest attributes, post-build copy, `TestDiscovery.ps1`, package version/artifact selection, or TestPackageExecution assembly path first.

### Running only the new tests

If the user wants a scoped QAOps run for only newly added tests:

- Use the PipelineLibrary **1.3.0+** `-TestFilter` parameter in the package's `2.TestPackageExecution.ps1` (e.g. `-TestFilter 'FullyQualifiedName~MyNewTestsClass.Create_' -PublishNotExecuted $false`, with `Install-Module ... -MinimumVersion 1.3.0`). See `dataminer-qaops-integration-testing` → "Scoped Runs". Measured: a filtered run completes in ≈4.5 min vs ≈55 min for a 657-test full suite.
- The filter lives inside the package script, so every filter change requires a fresh bumped-version `.dmtest` and the Fresh Artifact Gate again.
- Never invoke the packaged test executable directly with `--filter` instead of the helper — per-test results are then not published and the run is wasted.
- Restore the unfiltered call (and rebuild a fresh version) before a final full regression run. Temporary MSTest `[Ignore]` attributes are the fallback only for pre-1.3.0 module versions; hand-edit, never bulk-script them.

## Command Rules

Required options:

| Option | Rule |
|--------|------|
| `-t` / `--testsuite-id` | Always `01KTRNHRHWQJ9SMESYJAFP8SE9` |
| `-c` / `--configuration-id` | Use the target-specific configuration ID |
| `--token` | Always provide and double-quote the session token (or use the `QAOPS_TOKEN` environment variable) |
| `--test-packages` | Provide one option per selected `.dmtest`; always double-quote full paths |
| `--supplementary-file` | Optional and repeatable; provide one quoted path per runtime file |
| `-rf` / `--result-filepath` | Always write a JSON result file for later processing |
| `-tags` | Unique human-readable value under 100 characters |

### Full options reference

`test-run-and-wait` supports these additional options (probe `dataminer-qaops test-run-and-wait --help` **once per session**, right after installing or updating the tool, and reuse that knowledge for subsequent runs):

| Option | Purpose |
|--------|---------|
| `-whi, --hotfix-id <id>` | Apply a previously uploaded hotfix to the test DataMiner |
| `-san, --storage-account-name <name>` | Override the storage account (default: `saqaops`) |
| `-tags <tags>` | Semicolon-separated list of tags; each stays human-readable |
| `--token <token>` | QAOps token; alternatively set the `QAOPS_TOKEN` environment variable |
| `--supplementary-file <FilePath>` / `--supplementary-files <FilePath>` | Upload runtime files that QAOps extracts on every agent |
| `--override-test-packages <TestPackageIdentifier> <FilePath>` | Overwrite specific packages configured in the test suite |
| `--override-test-package-versions <TestPackageIdentifier> <Version>` | Override the configured version of specific packages |
| `-tim, --timeout-in-seconds <seconds>` | Maximum wait time (default: `7200`) |
| `--minimum-log-level <Debug\|Error\|Fatal\|Information\|Verbose\|Warning>` | Output verbosity (default: `Information`) |

### Package selection modes (mutually exclusive)

| Mode | Use when |
|------|----------|
| `--test-packages "<path>"` | Run locally built `.dmtest` files instead of the suite's configured packages — the normal mode for testing local changes. Mutually exclusive with both override options. |
| `--override-test-packages <id> "<path>"` | Keep the suite's configured package set but replace specific packages with local builds. Takes priority over version overrides. |
| `--override-test-package-versions <id> <version>` | Keep the suite's packages but pin specific configured versions. |

Do not combine `--test-packages` with either override option — the tool rejects it.

### Supplementary runtime files

Use supplementary files for inputs that should be supplied per run rather than embedded in the
`.dmtest`. The option accepts any file type and may be repeated. Relative paths preserve folder
structure; absolute paths are stored by file name only. The CLI rejects missing files and archive-path
collisions.

Consumers on the QAOps target must read the machine-level `QAOPS_SUPPLEMENTARY_FILES` variable at
runtime. Test Package pipeline scripts also receive a copy under
`$PathToTestPackageContent\SupplementaryFiles`. Full PowerShell and C# examples, lifecycle, security,
Bridge 1.1.0+, and token-permission rules are in
`dataminer-qaops/references/supplementary-files.md`.

### Token via environment variable

For CI/CD pipelines, prefer `QAOPS_TOKEN` from a pipeline secret over `--token` on the command line so the token does not appear in logs or process listings. In interactive sessions, `--token "<token>"` is fine; never echo or persist the value.

### Timeout

The default `-tim` is 7200 seconds (2 hours). Raise it when running many packages in one invocation; tell the user when a run risks exceeding it. A timeout does not necessarily mean the tests failed — check the QAOps UI using the result JSON's `BUILD_URL` deep link (and the `-tags` value as a fallback); see `references/result-processing.md` → "Pointing the User to the QAOps UI".

Use a tag that helps humans find the run in the UI. Include the user or task, target, and package/solution name where possible. Keep it short, for example:

```text
UserJanTestMyConnectorRC1
```

Do not include secrets in tags.

## Command Templates

### Latest Feature

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNSARVCH5DG50QM0RW7GYA --token "<QAOPS_TOKEN>" --test-packages "<full-path-to-package.dmtest>" -rf "<full-path-to-results.json>" -tags "<unique-tag-under-100-chars>"
```

### Latest RC

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNMVWEZX5EAW3GRDB744G4 --token "<QAOPS_TOKEN>" --test-packages "<full-path-to-package-1.dmtest>" --test-packages "<full-path-to-package-2.dmtest>" -rf "<full-path-to-results.json>" -tags "<unique-tag-under-100-chars>"
```

### Latest Main

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNTY3WW3JANCQ7WPWBEAVM --token "<QAOPS_TOKEN>" --test-packages "<full-path-to-package.dmtest>" -rf "<full-path-to-results.json>" -tags "<unique-tag-under-100-chars>"
```

### With supplementary files

```powershell
dataminer-qaops test-run-and-wait `
  -t 01KTRNHRHWQJ9SMESYJAFP8SE9 `
  -c 01KTRNMVWEZX5EAW3GRDB744G4 `
  --token "<QAOPS_TOKEN>" `
  --test-packages "<full-path-to-package.dmtest>" `
  --supplementary-file "<full-path-to-configuration.json>" `
  --supplementary-file "<full-path-to-input-package.dmupgrade>" `
  -rf "<full-path-to-results.json>" `
  -tags "<unique-tag-under-100-chars>"
```

## Long-Running Wait Behavior

`test-run-and-wait` blocks and emits progress updates. The default timeout is 7200 seconds.

Expected timing (measured on a 657-test MSTestV2 package): ≈10 min provisioning/install statuses, then ≈33 min of **silence** while the test executable runs (TRX is only written at exit), then ≈20 min of gradual per-test row publishing. Filtered runs (`-TestFilter`) complete in ≈4–5 min total. Long silence after `STATUS RunningTests` is normal — do not restart or assume a hang.

Agent behavior:

- **Run the command in an async/background shell and keep waits short.** Do not block in a single long `read_powershell` wait (e.g. 300 s) — long blocking waits prevent user messages from being handled while the run executes. Poll with short reads (≤30 s) at increasing intervals, or simply rely on the shell-completion notification.
- The `-rf` result JSON is written only at completion — checking for that file's existence is a cheap, reliable completion probe (more robust than re-reading large accumulated console output, which can repeat a truncated head late in a run).
- Between polls, do other useful work or end the turn so the user can interact.
- Share meaningful progress updates with the user when the command outputs run-state changes.
- Do not declare success from command submission alone. Wait for final completion and inspect the result file.
- If Unauthorized occurs shortly after token creation, wait a few minutes and retry once. If Unauthorized persists or the token is older, ask for a new token.

## Result Processing

Always read the `-rf` result file after completion. The JSON schema may evolve; inspect the actual file instead of assuming fixed property names.

For the canonical test suite the `-rf` JSON contains run-level fields (`STATUS`, `STATUS_MESSAGE`, `LOG_LINES`, `BUILD_URL`, suite/configuration IDs, timestamp). **`LOG_LINES` includes one row per published test** (verified): `TestName - Ok`, `TestName - NotExecuted: <ignore reason>`, or `TestName - Fail: <assertion message + stack>` — provided the package pipeline publishes per-test results through `Invoke-DotNetTestAndPublishResults`/`Push-TestCaseResult`. Exit code 0 plus `FINISHED OK` in `LOG_LINES` means the run passed. Use `LOG_LINES` to confirm expected new test names actually executed; the QAOps UI (`BUILD_URL`, or search by `-tags`) holds the full TRX details.

### Per-test diagnostics: streamed lines and LOG_LINES

During the wait, the CLI streams the same per-test rows that land in `LOG_LINES`; for failures the row is `TestName - Fail: <full assertion message + stack trace>`. These rows are the **only per-test diagnostics that reach the session** — the QAOps UI (`BUILD_URL`) requires interactive browser authentication the agent does not have (fetching it returns a login redirect). Consequences:

- Capture and read the streamed `Fail:` lines carefully — the assertion message is the root-cause report.
- When a failure message does not explain the cause, do **not** guess-fix and rerun: each iteration costs a run and a token use (≈4–5 min filtered, ≈55 min full-suite on a large package). Improve the test's assertion messages first (system-state snapshot, log excerpts — see `dataminer-qaops-integration-testing` → "Failure Diagnostics Are the Feedback Channel"), then rerun once with real evidence.
- A run can print `FINISHED FAIL [CompletedWithFailures]` with little or no per-test detail (e.g. very early failures); treat that as "tests need richer diagnostics", not as license to speculate.
- **When a run is meant to validate newly added tests, grep `LOG_LINES` for the new test names** and require an explicit `- Ok` row per test. A run whose `LOG_LINES` contains only old test names or only a pipeline-level row means the package was stale or publishing was bypassed — the run proves nothing about the new tests (verified failure mode: several early runs silently used a stale `.dmtest`).

Minimum final report:

- QAOps target: RC, Main, or Feature.
- Test package paths that were run.
- Result file path.
- Overall outcome as represented by the command/result JSON.
- Failed test names, error messages, or links/IDs if present in the JSON.
- If parsing is impossible, report the command exit status and preserve the result file path for manual inspection.

For more guidance, load `dataminer-qaops-test-runs/references/result-processing.md`.

## Examples

### User asks: "Can you test my changes on a Feature DataMiner?"

1. Load `dataminer-qaops`.
2. Ask for a QAOps token if one is not available in the current session.
3. Install/update the QAOps tool.
4. Find Test Package projects.
5. Because this tests local changes, run the Fresh Artifact Gate: bump the Test Package `<Version>`, build, select the exact versioned `.dmtest`, and verify packaged discovery for any new tests.
6. If one package is found, run it on Feature:

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNSARVCH5DG50QM0RW7GYA --token "<QAOPS_TOKEN>" --test-packages "<PathToMyTestPackage.dmtest>" -rf "<PathToTestResults.json>" -tags "UserNameTestMyTestPackageFeature1"
```

### User asks: "Can you test my solution on an RC DataMiner?"

If multiple Test Package projects are relevant, include each package:

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNMVWEZX5EAW3GRDB744G4 --token "<QAOPS_TOKEN>" --test-packages "<PathToMyTestPackage1.dmtest>" --test-packages "<PathToMyTestPackage2.dmtest>" -rf "<PathToTestResults.json>" -tags "UserNameTestSolutionRC1"
```

### User asks: "Can you test my latest changes on the latest Main release?"

If only one Test Package project is relevant to the latest changes, first run the Fresh Artifact Gate for that package, then run only that exact versioned package on Main:

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNTY3WW3JANCQ7WPWBEAVM --token "<QAOPS_TOKEN>" --test-packages "<PathToRelevantPackage.dmtest>" -rf "<PathToTestResults.json>" -tags "UserNameTestSolutionMain1"
```

### User asks: "Does my solution work on both Main and RC?"

Run once per target with distinct result files and tags, then compare the two result JSONs:

```bash
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNTY3WW3JANCQ7WPWBEAVM --token "<QAOPS_TOKEN>" --test-packages "<PathToPackage.dmtest>" -rf "<PathToResultsMain.json>" -tags "UserNameCompatCheckMain1"
dataminer-qaops test-run-and-wait -t 01KTRNHRHWQJ9SMESYJAFP8SE9 -c 01KTRNMVWEZX5EAW3GRDB744G4 --token "<QAOPS_TOKEN>" --test-packages "<PathToPackage.dmtest>" -rf "<PathToResultsRC.json>" -tags "UserNameCompatCheckRC1"
```

Report results per target. Note that the token's usage count must cover both runs.

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| `Unauthorized` right after the user created the token | Token propagation delay | Wait a few minutes, retry once; inform the user |
| `invalid_client` / `AADSTS7000215` ("Invalid client secret provided") right after token creation | Token propagation delay (looks like a bad paste but usually is not) | Wait 2–3 minutes, retry once; only ask for a new token if it persists |
| `Token does not exist, is expired or has reached maximum usage` | Token usage exhausted/expired — every submission consumes a use, and debugging loops burn through them | Ask the user to create a new **Default AI Token** (Tokens page); warn proactively as usage approaches the limit |
| `AuthorizationPermissionMismatch` while uploading the `.dmtest` to storage | Token/permission propagation delay on the volatile storage container | Wait a few minutes and retry once with a new `-tags` value; if it persists, ask for a new token |
| Authorization failure while uploading supplementary files | The token predates supplementary-file permissions or permission propagation is incomplete | Create a new Default AI Token; if it was just created, wait 2–3 minutes and retry once |
| Run is refused because target servers do not support supplementary files | One or more target servers run QAOps Bridge older than 1.1.0 | Upgrade the named QAOps Bridges before retrying; never run without files the tests require |
| C# or PowerShell cannot see `QAOPS_SUPPLEMENTARY_FILES` through the normal process environment | The test host/process cached its environment before the Bridge set the variable | Query the machine target explicitly with `EnvironmentVariableTarget.Machine`; see `dataminer-qaops/references/supplementary-files.md` |
| `Unauthorized` with an older token | Token expired, usage count exhausted, or wrong scopes | Ask the user to create a new **Default AI Token** (preconfigured with the required `Run_Scoped_*` scopes) |
| `FINISHED FAIL [CompletedWithFailures]` with absent or unexplanatory per-test detail | Test assertion messages carry no diagnostics; OR `AssemblyInitialize` threw and the cleanup path masked it (next row); OR the pipeline **gated/bypassed** `Invoke-DotNetTestAndPublishResults` (a `throw`/`exit` — e.g. a redundant `dotnet test … ; if ($LASTEXITCODE){ throw }` — placed before the helper); OR a transient infra/tool-side publish race dropped the rows from the streamed output and `-rf` JSON while they DID reach the QAOps UI | First confirm the pipeline reaches the helper **un-gated** (`dataminer-qaops-integration-testing/references/test-package-pipeline.md` → "Pipeline Integrity"); a failing test is not a pipeline failure. Then do not guess-fix — enrich the failing test's assertion messages (system snapshot, log tail), rebuild, rerun once. No per-test row at all ⇒ suspect a gated helper or `AssemblyInitialize`, not the test body. **If the user reports the QAOps UI DOES show per-test errors your streamed/`-rf` output lacked, trust them: the diagnostics exist and the transport dropped them — do NOT refactor the harness (AssemblyInitialize, harvest paths) chasing visibility you already have.** |
| Per-test `Fail: ... AssemblyInitialize threw ... System.IO.FileLoadException: Could not load file or assembly 'System.Security.Cryptography.ProtectedData, Version=9.0.0.0 ... manifest definition does not match' (0x80131040)` at `Keys.TryRetrieveKey` | The net48 test project is **missing `Microsoft.NET.Test.Sdk`**, so no `<TestProject>.dll.config` binding redirects were generated; `WinEncryptedKeys.Lib`'s `ProtectedData 9.0.0.0` reference can't bind to the shipped `9.0.0.6` DLL (verified — cost ~5 QAOps runs, the error was masked for the first 3 by a throwing cleanup path) | Add the **single `MSTest` metapackage** (it pulls `Microsoft.NET.Test.Sdk`); never hand-split it into `MSTest.TestAdapter`/`MSTest.TestFramework`. Verify `bin\<config>\net48\<TestProject>.dll.config` exists with a `System.Security.Cryptography.ProtectedData` `bindingRedirect`. Ensure `DmsTestSetup` cleanup never throws over the real failure (`dataminer-qaops-integration-testing/references/dms-test-setup.md`) |
| Test fails on parameter reads / unexpected element behavior right after install | The logic bound to a **pre-existing DaaS baseline element** (e.g. Microsoft Platform ships pre-installed) instead of the test fixture; protocol versions differ | Apply the System State Preflight from `dataminer-qaops-integration-testing/references/system-state-preflight.md`: snapshot elements + versions, target fixtures by identity, assert versions |
| Arrange fails with `IncorrectDataException: Invalid connection type provided at index 0` (from `ElementConfiguration`) | Core.DataMinerSystem package ≤1.2.0.x cannot build connections for serial/multi-connection connectors (e.g. Microsoft Platform); newer versions derive defaults from the protocol | Upgrade the consumed library version when possible; on old versions apply the duplicate-or-fail fixture strategy (`dataminer-idms` cheatsheet → "Creating Elements"); if more variants must be probed, batch them all into ONE run with per-variant diagnostics |
| `ParameterNotFoundException` whose inner COM message reads "TabletPC inking error code. RtpEnabled called multiple times" | Misleading HRESULT text for 0x80040239 (object not found): the PID simply does not exist on that element's protocol version | Trust the outer exception; check the element's `Protocol.Version` (may be the literal `"Production"` — resolve via `IDmsProtocol.ReferencedVersion`) against the PID map's source version |
| `FINISHED FAIL [Failed]` during `InstallingDependencies` with `No settings were found for a module with ID '(slc)standard_data_model'` / `ElementNotFoundException` / `No settings were found for a module with ID '(slc)<module>'` | Clean DaaS lacks runtime prerequisites the solution's own installer provisions (SDM, connector elements, DOM modules) — found one run at a time | Stop the per-run cascade: read the solution's own `Package` install script, enumerate every setup step, and replicate it in the Test Package InstallScript / `CatalogReferences.xml` / `SetupContent`. See `dataminer-qaops-integration-testing/references/migrating-existing-tests.md` (runtime-prerequisite cascade) |
| `FINISHED FAIL [Failed]` during `InstallingDependencies` with `CS0006 Could not find file '...Xxx.dll'` or `Run subscript '...' failed: Errors in CSharp script code` | InstallScript references an assembly the SDK did not harvest into `Scripts\InstallDependencies`, or it calls a solution Automation script as a subscript that won't compile at install time | Verify `Scripts\InstallDependencies` covers every `Skyline*` ref in `Scripts\Install.xml`; remove un-harvestable dev/ref-only package references; inline the setup logic instead of calling solution scripts as subscripts (`migrating-existing-tests.md` Sections 4–5) |
| Playwright `net::ERR_CONNECTION_REFUSED at http://localhost/app/...` | Browser pointed at plain-HTTP localhost on QAOps | Use `https://localhost` for the browser base URL + `IgnoreHTTPSErrors`; keep SLNet on the bare `localhost` host (`migrating-existing-tests.md` Section 7) |
| Build/Catalog download fails with a permission/authorization error on a specific Catalog item | The Catalog key is scoped to a different organization than the one that owns the item (e.g. internal MediaOps packages on a "Development" org) | Name the exact failing item; ask the user to switch the Catalog key to the owning organization — do not retry-churn. Note: a same-solution deployment package can instead be built locally and bundled as a `.dmapp` (see `migrating-existing-tests.md` Section 3), avoiding the Catalog org entirely. |
| Build prints `Successfully created package '….dmtest'` **and** `error : Failed to download catalog item …` | A `CatalogReferences.xml` item failed to resolve/download but the SDK still emits a stale/incomplete `.dmtest` | Treat the build as failed. Grep build output for `error :` / `Failed to download catalog item`; fix the reference before submitting. Never pick the artifact by existence/timestamp alone |
| Catalog build error `Version could not be resolved` or `404 … Catalog … was not found` for a referenced item | The ID came from a solution repo's public `CatalogInformation/manifest.yml`, which CI overwrites with an internal org-specific ID before publishing | Find the real published ID via `gh variable list --repo <org>/<repo> --json name,value` (`CATALOGIDENTIFIER*`); reference that. The internal package may need a key for a different org (`migrating-existing-tests.md` Sections 3, 8) |
| Package build fails: `Skyline.DataMiner.Core.AppPackageInstaller version 4.0.0.0 is not compatible with … AppPackageCreator version 3.1.1.0` | `global.json`'s `Skyline.DataMiner.Sdk` was downgraded below what the Test Package template needs | Restore the SDK version the template set in `global.json` (e.g. 2.5.2); treat the template's `global.json` bump as part of the migration, not a change to revert (`migrating-existing-tests.md` Section 6) |
| `InstallingDependencies` fails with `This solution requires SDM/Categories to function. … deploy the '…' package before … this package` although that prerequisite IS in `CatalogReferences.xml` | Embedded `.dmapp` dependencies install in **alphabetical filename order**; the prerequisite is referenced but installs after the package that needs it | Prefix the prerequisite `<Name>` with `000`/`001`/… so SDM installs before Categories before the solution; verify by extracting the `.dmtest` and listing `AppInstallContent\AppPackages\*.dmapp` sorted by name (`migrating-existing-tests.md` Section 3) |
| Test Package build fails with `Missing 'libraryName' param on exe N (project '<Pkg>')` | A `<ProjectReference>` to a DataMiner **Package** project was added to the Test Package; the SDK reinterprets ProjectReferences as DataMiner script/library references and a Package's install-script exe has no `libraryName` | Remove the ProjectReference. To build a same-solution package first, trigger it with an `<MSBuild>` task (`BeforeTargets="DmappCreation"`) and bundle its `.dmapp` via the source project's post-build copy (`migrating-existing-tests.md` Section 3) |
| `dataminer-qaops` not recognized | Tool not installed or PATH not refreshed | Install/update with `--add-source https://api.nuget.org/v3/index.json`; open a fresh shell if needed |
| Command options don't match this skill | Different tool version installed | Probe `dataminer-qaops test-run-and-wait --help` and adapt; update the tool |
| No `.dmtest` found after build | Wrong project type or build failed | Verify `<DataMinerType>TestPackage</DataMinerType>` and `Skyline.DataMiner.Sdk`; rebuild and read build output |
| QAOps results do not contain the new test names | Stale `.dmtest`, unchanged Test Package version, harvested assembly missing, MSTest attributes missing, or pipeline points at the wrong assembly | Treat the run as invalid for the new tests. Bump `<Version>`, build, select the exact versioned artifact, extract it, and run packaged MSTest discovery before resubmitting |
| Run shows only a pipeline-level row (e.g. `pipeline_… - Fail: Exception during Test Package execution …`), zero per-test assertion rows | The pipeline never reached `Invoke-DotNetTestAndPublishResults` for the tests: it invoked the test exe directly with `--filter`, **or** a step threw/exited before the helper (e.g. a redundant `dotnet test … ; if ($LASTEXITCODE){ throw }` "diagnostic" gate — a failing test makes it throw every run) | Run the helper as the first/only execution step; never `throw`/`exit` before it (a failing test is not a pipeline failure). Make any extra console diagnostics additive (helper first, then a separate non-throwing `dotnet test`). Scoped runs: use the helper's `-TestFilter`, not direct exe invocation |
| Long silence after `STATUS RunningTests` | Normal: the test executable runs to completion before any TRX parsing/publishing (≈33 min for a 657-test suite), then rows publish one by one | Wait; poll the `-rf` file for existence; use `-TestFilter` to shrink dev iterations to ≈4–5 min |
| Mutual-exclusivity error | `--test-packages` combined with an override option | Use exactly one package selection mode |
| Wait timed out (`-tim` reached) | Run still in progress or stuck | Check the QAOps UI using the `-tags` value; raise `-tim` on retry; do not assume failure |
| Run finished but result file missing | `-rf` path invalid or not writable | Re-check the path; quote it; use an existing writable directory |
