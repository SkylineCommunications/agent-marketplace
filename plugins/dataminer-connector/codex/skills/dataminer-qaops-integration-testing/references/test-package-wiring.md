# Wiring and Shipping the DataMiner Test Package

> **Part of the `dataminer-qaops-integration-testing` skill.** Load that `SKILL.md` first for the high-level workflow, the authoring-vs-migrating decision, the System State Preflight, and the Failure-Diagnostics rules. **Verifying anything on a real DataMiner always goes through QAOps** (`dataminer-qaops` -> `dataminer-qaops-test-runs`); never local `dotnet test`, and never a local `C:\Skyline DataMiner` install.

## Reuse or Create a DataMiner Test Package Project

Find projects with:

```xml
<Project Sdk="Skyline.DataMiner.Sdk">
```

and:

```xml
<DataMinerType>TestPackage</DataMinerType>
```

If a suitable Test Package project already exists, reuse it and add the new tests to its harvesting flow.

If none exists, create one from the official Skyline template. Run commands from the folder containing the `.sln` or `.slnx`:

```bash
dotnet new install skyline.dataminer.visualstudiotemplates --add-source https://api.nuget.org/v3/index.json
dotnet new dataminer-test-package-project -o "NameOfTestPackageProject" -auth "MyName" --force
dotnet sln add "NameOfTestPackageProject"
```

If template installation reports that the package already exists, treat that as already installed and continue.

## Catalog Key via User Secrets (Mandatory Flow)

The SDK needs the dataminer.services **organization key** at build time to download `CatalogReferences.xml` items. Handle it **only** through the Test Package project's user-secrets file:

- **Never ask for the key in chat** — it is a long-lived organization credential.
- **Never rely on environment variables set during the session.** The CLI host captured its environment at startup; `setx`/Settings changes made mid-session are invisible to every shell the agent spawns, so a missing `skyline__sdk__dataminertoken` cannot be fixed that way.
- The official template ships **without** a `<UserSecretsId>`, so any secrets file the user creates on their own is not linked to the project. Provision it deterministically, immediately after creating the project:

1. `dotnet user-secrets init --project "<TestPackageProject>.csproj"`
2. Read the `<UserSecretsId>` back and pre-create the secrets file with an empty placeholder so the user only fills in the value. Use this exact snippet — the csproj has **multiple `<PropertyGroup>` elements**, so naive `$xml.Project.PropertyGroup.UserSecretsId` returns an array with empty entries and produces a corrupted path (verified failure: a trailing-space directory and a "You cannot call a method on a null-valued expression" error):

```powershell
$csproj = '<full path to TestPackageProject.csproj>'
[xml]$xml = Get-Content -Path $csproj -Raw
$guid = ($xml.Project.PropertyGroup.UserSecretsId | Where-Object { $_ }) | Select-Object -First 1
$guid = ([string]$guid).Trim()
if (-not $guid) { throw "No UserSecretsId found in $csproj - run 'dotnet user-secrets init' first." }
$dir = Join-Path $env:APPDATA "Microsoft\UserSecrets\$guid"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Set-Content -Path (Join-Path $dir 'secrets.json') -Value '{ "skyline": { "sdk": { "dataminertoken": "" } } }'
if (!(Test-Path (Join-Path $dir 'secrets.json'))) { throw "secrets.json was not created." }
Write-Output (Join-Path $dir 'secrets.json')
```

3. **Verify the file exists** (the snippet above does) *before* asking the user to edit it — pointing the user at a path that was never created costs an extra round-trip.
4. Give the user the exact `secrets.json` path in a focused `ask_user` question and ask them to paste their organization key into the empty value (remind them: not in chat).
5. Verify **key presence only** — never echo the value:

```powershell
dotnet user-secrets list --project "<TestPackageProject>.csproj"   # expect the key skyline:sdk:dataminertoken
```

6. Only then run the full solution build.

This ordering also solves the chicken-and-egg problem from preflight: during `dataminer-qaops` Preflight only *confirm the user has a key*; store it here, once the project exists.

## Add Prerequisite DataMiner Content

When tests require content to exist on the QAOps DataMiner before execution, add that content to the DataMiner Test Package the same way it would be added to a standard DataMiner installation package.

Official package project documentation:

```text
https://docs.dataminer.services/develop/CICD/Skyline%20DataMiner%20Software%20Development%20Kit/skyline_dataminer_sdk_dataminer_package_project.html
```

Common prerequisite cases:

| Needed by the test | Preferred approach |
|--------------------|--------------------|
| Connector, Automation script, or other DataMiner project in the same solution | Let the Test Package include same-solution DataMiner-type projects by default, then verify the generated package content. |
| Element requiring an out-of-solution connector | Search `https://catalog.dataminer.services/`, identify the connector Catalog ID, and add it to `PackageContent/CatalogReferences.xml`. **Requires the Catalog organization key at build time** (see below). |
| Low-Code App or dashboard edited on another DataMiner | Import/export it from that DataMiner into the Test Package, or ask the user to import it manually. |
| Other external DataMiner artifacts | Add them as standard DataMiner package content when supported by the SDK package project model. |

**Catalog references require a build-time token.** The SDK downloads Catalog items during the Test Package build and fails with an error mentioning `skyline:sdk:dataminertoken` / `skyline__sdk__dataminertoken` when the key is missing. Before adding any `CatalogReferences.xml` entry, provision the key through "Catalog Key via User Secrets" above (preflight only confirms the user *has* a key; storage happens once the project exists). Tests that target elements of an out-of-solution connector (e.g. "Microsoft Platform") will fail on the clean QAOps system without this prerequisite.

For Low-Code Apps and dashboards, the agent may need to ask the user for the IP/hostname of the DataMiner where the artifact is being edited and credentials/authentication for access. If credentials are not available or export cannot be automated safely, ask the user to import the Low-Code App or dashboard manually.

Prefer the `Skyline.DataMiner.Core.ArtifactDownloader` NuGet package for automated Low-Code App and dashboard downloads. Use direct web calls only when the library is not available or the task explicitly requires low-level API use.

See `dataminer-qaops-integration-testing/references/test-package-prerequisites.md` for ArtifactDownloader examples, Catalog guidance, and the fallback export API calls.

## Post-Build Harvesting

Prefer a post-build MSBuild target in the MSTestV2 project to copy built test output into the DataMiner Test Package project's harvesting folder. The harvesting script does not know the build configuration well enough to reliably find the correct bin folder later.

Rules:

- Copy the test assembly or executable and all required dependencies.
- **Exclude per-test-run runtime artifacts** (Playwright traces, screenshots, videos, `TestResults`, run logs). These are written *into the output folder while the tests execute* — they are not build outputs — and harvesting them causes intermittent `MSB3021`/`MSB3027` "Unable to copy file … Could not find a part of the path" build failures when a previous or parallel test host has locked or deleted the file between MSBuild's file enumeration and the copy. See "Excluding Runtime Test Artifacts" below.
- Put generated copied content in a folder or file name containing `.generated`.
- Build copy destinations from MSBuild item metadata (e.g. `%(RecursiveDir)`) instead of hardcoded path separators, so the post-build copy stays robust if the project layout changes. (The QAOps DataMiner that ultimately runs the tests is **Windows** — see `dataminer-qaops` "Platform" — so DataMiner paths inside the package are Windows paths.)
- Verify the destination matches what the Test Package project harvests.

Example that copies all build output while preserving subdirectories, excluding runtime trace artifacts and tolerating contended files:

```xml
<Target Name="CopyIntegrationTestOutputToTestPackage" AfterTargets="Build">
  <ItemGroup>
    <!-- Exclude the runtime trace directory. Its name is chosen by the test code -
         see "Excluding Runtime Test Artifacts" below for how to find it (here: playwright-traces). -->
    <IntegrationTestOutput Include="$(OutputPath)**\*.*" Exclude="$(OutputPath)playwright-traces\**" />
  </ItemGroup>
  <Copy
    SourceFiles="@(IntegrationTestOutput)"
    DestinationFiles="@(IntegrationTestOutput->'../NameOfTestPackageProject/TestPackageContent/TestHarvesting/postbuild.generated/$(MSBuildProjectName)/%(RecursiveDir)%(Filename)%(Extension)')"
    SkipUnchangedFiles="true" />
</Target>
```

`SkipUnchangedFiles="true"` makes the copy resilient to files that reappear unchanged across repeated/contended builds; the `Exclude` keeps the run-time trace zips out of the package entirely. For a simpler project, an explicit `SourceFiles` list is acceptable only after verifying all needed dependencies are included.

### Excluding Runtime Test Artifacts (Playwright Traces, etc.)

Harvesting `$(OutputPath)**\*.*` sweeps up **everything** the test process wrote into its output folder at *run* time, not just the build's binaries. The common offender is **Playwright traces**: a `.zip` per (typically failed) test, written under the output directory. Because they appear and disappear between runs and can be held open by a still-running test host, the post-build `Copy` fails intermittently with errors like:

```text
MSB3021: Unable to copy file "bin\Debug\net48\playwright-traces\<Class>.<Test>.zip" to
"...\postbuild.generated\<Project>\playwright-traces\<Class>.<Test>.zip".
Could not find a part of the path '...'.
```

The fix is to **exclude that directory from the harvest** and add `SkipUnchangedFiles="true"` to the `Copy` (verified: `SkylineCommunications/SLC-S-MediaOps.Plan` PR #555).

**The trace directory name is chosen by the test code — do NOT assume it is `playwright-traces`.** Identify the real folder before writing the `Exclude`:

1. Open the Playwright base/integration test class and find where tracing is stopped to a file:
   `Context.Tracing.StopAsync(new TracingStopOptions { Path = <path> })`. Read the folder segment in `<path>`. In MediaOps it is `Path.Combine(Directory.GetCurrentDirectory(), "playwright-traces", $"{...}.zip")` → the segment is `playwright-traces` (and traces are written only on failed tests, which is why the build breaks only sometimes).
2. Check for other captured-artifact sinks that land in the output folder and exclude each one's folder too: screenshots (`Page.ScreenshotAsync(new() { Path = … })`), videos (`RecordVideoDir`), and any `Path.Combine(Directory.GetCurrentDirectory()` / `AppContext.BaseDirectory, "<folder>", …)`.
3. Set `Exclude="$(OutputPath)<folder>\**"`. One `Exclude` can list multiple patterns separated by `;`, e.g. `Exclude="$(OutputPath)playwright-traces\**;$(OutputPath)videos\**"`.

Prefer this **exclude-the-known-artifacts** approach over trying to whitelist exactly the binaries the runner needs: a hand-picked "copy only what's needed" list is brittle — it silently drops a transitive dependency and the test then fails on QAOps a run (and a token use) later. Excluding the runtime-artifact directories keeps the full dependency closure intact while removing only the files that cause the copy failures.

**Build order matters** (verified): in a full-solution build, MSBuild may build the Test Package project *before* the MSTest project, so `TestDiscovery.ps1` runs while `postbuild.generated` does not exist yet and the Test Package build fails. Force the ordering with a non-referencing `ProjectReference` in the Test Package `.csproj`:

```xml
<ItemGroup>
  <ProjectReference Include="../MyConnector.integrationtests/MyConnector.integrationtests.csproj" ReferenceOutputAssembly="false" />
</ItemGroup>
```

## TestDiscovery.ps1 (Mandatory — the Template Is a Placeholder)

The official Test Package template ships `TestPackageContent/TestHarvesting/TestDiscovery.ps1` as a **placeholder that packages nothing**. If it is left untouched, the post-build-harvested files are silently **not included** in the `.dmtest`, and the QAOps run fails without an obvious cause. Always replace it so the harvested output is copied into `tests.generated` (the folder the SDK packages):

```powershell
$ErrorActionPreference = 'Stop'

$pathToGeneratedTests = Join-Path $PSScriptRoot 'tests.generated'

if (Test-Path $pathToGeneratedTests) {
    Remove-Item -Recurse -Force $pathToGeneratedTests
}

New-Item -ItemType Directory -Force -Path $pathToGeneratedTests | Out-Null

$pathToPostBuildTests = Join-Path $PSScriptRoot 'postbuild.generated'

if (!(Test-Path $pathToPostBuildTests)) {
    throw "Could not find harvested integration test output at '$pathToPostBuildTests'. Build the integration test project before building the Test Package."
}

Copy-Item -Path (Join-Path $pathToPostBuildTests '*') -Destination $pathToGeneratedTests -Recurse -Force

# Do not clean up the collected files here; the next SDK step packages them.
exit 0
```

The execution pipeline must then load the test assembly from `tests.generated` (not `postbuild.generated`), because only `tests.generated` content ends up inside the package.

## Test Package Execution Pipeline

Update:

```text
NameOfTestPackageProject/TestPackageContent/TestPackagePipeline/2.TestPackageExecution.ps1
```

Use `Skyline.DataMiner.QAOps.PipelineLibrary` and call `Invoke-DotNetTestAndPublishResults` once per copied MSTest assembly or executable.

Keep this pipeline boring: point it at the copied assembly/executable under `tests.generated`. As of PipelineLibrary **1.3.0** the helper supports `-TestFilter` (passed to the runner as `--filter`) and `-PublishNotExecuted $false` (skip publishing ignored-test rows) for scoped development runs — install with `-MinimumVersion 1.3.0` when using them, and restore the unfiltered call before final regression gates. Never invoke the test executable directly with `--filter` instead of the helper: that skips per-test result publishing and the QAOps run becomes invalid evidence.

> **Hard rule — never gate the helper.** A failing test is not a pipeline failure: `Invoke-DotNetTestAndPublishResults` publishes per-test rows (failures included) and returns. Do **not** add any step that can `throw`/`exit` before it — a redundant `dotnet test … ; if ($LASTEXITCODE){ throw }` "diagnostic" throws on every failing run, the helper never publishes, and the run collapses to one detail-less `pipeline_… - Fail` row (then agents waste runs shrinking that message). Extra console diagnostics must be additive (helper first). Full rationale: `references/test-package-pipeline.md` → "Pipeline Integrity — Never Gate the Publishing Helper".

See `dataminer-qaops-integration-testing/references/test-package-pipeline.md` for a complete pattern, the `-TestFilter` rules, and the publishing timing model (quiet executable phase, then one-by-one row publishing — silence is not a hang).

## Fresh Test Package Version Gate

Before any QAOps run that includes newly authored or changed tests, increment the DataMiner Test Package project's `<Version>` property (normally the patch component). The SDK emits versioned artifacts, for example:

```text
QAOpsPackage.1.0.4.dmtest
```

Rules:

- Record the new `<Version>` value and expected artifact filename before building.
- Build and run only the exact `.dmtest` whose filename contains that version. Never select by "latest write time", a broad `*.dmtest` glob, or an older artifact that happens to still be in `bin`.
- If multiple Test Package projects are selected, bump and verify each selected package independently.
- If the repository has an explicit release-versioning policy that blocks bumping, stop and ask; do not silently reuse an old Test Package version for a QAOps verification of new tests.

## Packaged MSTest Discovery Gate

A successful build or upload does not prove the newly written tests are inside the package. For MSTestV2 packages, perform this gate before starting the QAOps run:

1. Extract the exact versioned `.dmtest` that will be sent to QAOps into a temporary folder.
2. Confirm the expected test assembly or executable and dependencies are present under `AppInstallContent\DmTest\TestHarvesting\tests.generated\...`.
3. Run test discovery only (do not execute the integration tests locally) against the extracted assembly/executable and confirm every recorded new test name is listed. **Use a real test-runner discovery command — `dotnet test … --list-tests` does NOT work against a standalone net48 `.dll`** (it expects an MSBuild project/test container and silently lists nothing or errors). For a packaged net48 MSTest **DLL**, discover with VSTest:

   ```powershell
   dotnet vstest "<extracted-test-assembly.dll>" --ListTests
   # or, with the Visual Studio / Microsoft.TestPlatform console:
   # vstest.console.exe "<extracted-test-assembly.dll>" /ListTests
   ```

   For an MSTest **executable** (MSTest 3.x / Microsoft.Testing.Platform output), use its own `--list-tests` mode. Confirm every recorded new test name appears in the runner's output.
4. If any new test is missing, stop. Fix the MSTest attributes, post-build copy target, `TestDiscovery.ps1`, or pipeline assembly path before spending a QAOps run. QAOps results cannot contain assertions for tests that were never packaged or discovered.

> **A byte/UTF-8 name scan is a *freshness* check, never discovery.** Finding `"MyTest"` inside the DLL bytes only proves the name is present in metadata — it does **not** prove the test platform can enumerate and run it (wrong target framework, missing adapter, x86/x64 mismatch, or a broken test container all pass a byte scan but discover/run **zero** tests). A real session accepted a byte scan as discovery, shipped the package, and then got a QAOps run that reported `FINISHED OK` with **no per-test rows** because the runner matched 0 tests. If a genuine runner discovery command cannot be executed in the environment, do not claim the discovery gate passed — and treat any subsequent run that publishes zero per-test rows as a discovery/packaging failure, not a pass (see `dataminer-qaops-test-runs` → `references/result-processing.md`).

This gate must inspect the content extracted from the `.dmtest`, not just the local `bin` folder of the test project.

**Discovery alone cannot prove freshness.** When an iteration only changes test *bodies* (assertions, diagnostics) and no test names, a stale assembly passes discovery — a measured session shipped a stale package this way and wasted a QAOps run. Add both protections:

1. **Build-order `ProjectReference`** in the Test Package `.csproj` so the test project is always rebuilt and re-harvested first (same pattern as the TestDiscovery ordering fix):

   ```xml
   <ProjectReference Include="../MyConnector.integrationtests/MyConnector.integrationtests.csproj" ReferenceOutputAssembly="false" />
   ```

2. **Freshness gate** before submission: `Get-FileHash` the test exe/dll in the project's `bin` and the one extracted from the `.dmtest` — they must match. For changed code without new names, additionally scan the extracted binary for a newly added method name with `[System.Text.Encoding]::UTF8.GetString(bytes).Contains('NewMethodName')` (method names are UTF-8 metadata; string-literal scans are unreliable with interpolated strings).

## Scoped Runs: Use the PipelineLibrary `-TestFilter` (1.3.0+)

When the user wants to run only the newly added tests through QAOps, **filter — do not mass-ignore**:

1. In `2.TestPackageExecution.ps1`, ensure `Install-Module ... -MinimumVersion 1.3.0` and add to the `Invoke-DotNetTestAndPublishResults` call:

   ```powershell
   -TestFilter 'FullyQualifiedName~MyNewTestsClass.Create_' -PublishNotExecuted $false
   ```

   (`'TestCategory=MyFeature'` also works — give new integration tests a `[TestCategory]` for this.)
2. Bump the Test Package `<Version>`, rebuild, and rerun the packaged-discovery gate — the filter lives inside the package, so every filter change needs a fresh `.dmtest`.
3. Iterate on QAOps with the filtered package (measured: ≈4.5 min vs ≈55 min for a 657-test suite).
4. **Before the final full regression gates, restore the unfiltered call** and rebuild yet another fresh version. A filtered run never counts as the full-suite pass.

Name new tests for filterability: a shared class-name or method-name prefix (e.g. `Create_*`) or a feature-specific `[TestCategory]` makes the filter expression trivial and makes per-test rows in QAOps self-explanatory. (Every integration test already carries the baseline `[TestCategory("IntegrationTest")]` — see `references/authoring-test-project.md`; feature categories are additive on top of it for scoping.)

Fallbacks and pitfalls:

- Temporary MSTest `[Ignore]` attributes are the fallback **only** when the installed PipelineLibrary cannot be raised to 1.3.0. Hand-edit the few files involved; never script a bulk insert across the test tree — a scripted attempt rewrote ~100 files with encoding/EOL churn and had to be reverted with `git restore` (verified).
- Never bypass `Invoke-DotNetTestAndPublishResults` by calling the test executable with `--filter` yourself: per-test publishing (`Push-TestCaseResult`) is skipped, QAOps shows only the pipeline-level row, and the run (plus its token use) is wasted.
- MSTest writes ignored tests to TRX as `NotExecuted`; with `-PublishNotExecuted $false` those rows are not published, which also shortens the publish phase.

## Build and Run

After wiring:

1. Increment the Test Package project `<Version>` and record the exact expected `.dmtest` filename.
2. Build the solution. Local validation stops at a clean build — do **not** execute the integration tests locally with `dotnet test`.
3. Confirm the integration test output was copied to `TestPackageContent\TestHarvesting\postbuild.generated\...`.
4. Confirm the DataMiner Test Package project builds and emits the exact versioned `.dmtest` package.
5. **Verify the `.dmtest` contents**: it is a zip — extract it (e.g. `Expand-Archive` after copying to `.zip`) and confirm it contains the Automation scripts/connectors under test and the harvested test assembly with its dependencies under `AppInstallContent\DmTest\TestHarvesting\tests.generated\...`. A missing test assembly means `TestDiscovery.ps1` was not updated.
6. **Verify packaged test discovery**: run discovery/list-tests on the extracted MSTest assembly or executable and confirm every newly added test is discoverable.
7. To run it on QAOps, load `dataminer-qaops-test-runs` and provide that exact versioned `.dmtest` path.

## Expected Benign Build Output

Do not investigate these — they are normal for DataMiner test solutions and have never indicated a real problem:

- `MSB3277` assembly version conflicts (`System.Collections.Immutable`, SLNetTypes/Dev Pack ref assemblies, test-platform DLLs). Benign, but each occurrence dumps ~30 log lines per project per build. Silence them by adding `<MSBuildWarningsAsMessages>MSB3277</MSBuildWarningsAsMessages>` to a `Directory.Build.props`, or simply ignore them.
- `MSTEST0037` analyzer style suggestions in test code.

Keep build logs small: build with `dotnet build "<solution>" --nologo -v:m`, and when a build fails grep the captured output for `error` lines only instead of reading the full log.

