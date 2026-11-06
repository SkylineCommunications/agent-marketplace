# Test Package Execution Pipeline Pattern

Use this pattern in:

```text
NameOfTestPackageProject/TestPackageContent/TestPackagePipeline/2.TestPackageExecution.ps1
```

It runs copied MSTestV2 integration tests and publishes results back to QAOps.

> Prerequisite: `TestDiscovery.ps1` must copy `postbuild.generated` into `tests.generated` (see the SKILL's "TestDiscovery.ps1" section). Only `tests.generated` content is packaged into the `.dmtest`, so the pipeline must load assemblies from there.

```powershell
#Install Skyline.DataMiner.QAOps.PipelineLibrary (1.3.0+ adds -TestFilter and -PublishNotExecuted)
Install-Module Skyline.DataMiner.QAOps.PipelineLibrary -Repository PSGallery -Force -Scope CurrentUser -MinimumVersion 1.3.0
Import-Module Skyline.DataMiner.QAOps.PipelineLibrary -Force

# Track script start time.
$scriptStart = Get-Date

$pathToTestHarvesting = Join-Path $PathToTestPackageContent 'TestHarvesting'
$pathToGeneratedTests = Join-Path $pathToTestHarvesting 'tests.generated'
$testAssemblyPath = Join-Path $pathToGeneratedTests 'ThisTestProject1/ThisTestProject1.dll'
$testCaseName = 'pipeline_1.ExecuteIntegrationTests'

try {
    Write-Host 'Running Test Package tests: ThisTestProject1 Tests...' -ForegroundColor Cyan

    # Scoped development runs (PipelineLibrary >= 1.3.0): append
    #   -TestFilter 'FullyQualifiedName~MyNewTestsClass.Create_' -PublishNotExecuted $false
    # Restore this call to the unfiltered form below before the final full regression gates.
    Invoke-DotNetTestAndPublishResults `
        -PathToTestPackageContent $PathToTestPackageContent `
        -TestDllPath $testAssemblyPath `
        -ResultsFileName 'testresults.trx'

    try {
        Push-TestCaseResult `
            -Outcome 'OK' `
            -Name $testCaseName `
            -Duration ((Get-Date) - $scriptStart) `
            -Message 'Test Package execution finished.' `
            -TestAspect Execution
    }
    catch {
        Write-Host "Skipped Push for OK on $testCaseName"
    }
}
catch {
    try {
        Push-TestCaseResult `
            -Outcome 'Fail' `
            -Name $testCaseName `
            -Duration ((Get-Date) - $scriptStart) `
            -Message "Exception during Test Package execution: $($_.Exception.Message)" `
            -TestAspect Execution
    }
    catch {
        Write-Host "Skipped Push for Fail on $testCaseName"
    }

    exit 1
}
```

## Pipeline Integrity — Never Gate the Publishing Helper (Hard Rules)

`Invoke-DotNetTestAndPublishResults` is the **only** thing that publishes a per-test row (`TestName - Ok/Fail: <assertion message + stack>`) to QAOps, and that per-test assertion message is the sole diagnostic channel that reaches the session. Protect it:

- **A failing test is NOT a pipeline failure.** The helper runs the tests, writes the TRX, publishes one row per test *including failures*, then returns normally. The surrounding `try/catch`/`exit 1` is for **infrastructure** errors only (module install, missing harvested assembly) — never for ordinary test failures. Do not translate a failed test into a pipeline `throw`/`exit` yourself.
- **Never put a step that can `throw` or `exit` BEFORE the helper.** In particular, do **not** add a "diagnostic" `dotnet test … ; if ($LASTEXITCODE -ne 0) { throw }` ahead of `Invoke-DotNetTestAndPublishResults`. A failing integration test makes `dotnet test` return exit code 1, so that gate throws on **every** failing run and the helper never executes — no per-test rows are published and the run collapses to a single `pipeline_… - Fail: Exception during Test Package execution …` with zero test detail. (Verified failure mode: this masked the real cause across many QAOps runs, and the agent then wasted more runs shrinking the useless pipeline message instead of removing the gate.)
- **`CompletedWithFailures` with no per-test row is itself the signal** — no per-test result was produced/published: `AssemblyInitialize` threw, the test host crashed before writing a TRX, the helper was bypassed, or (the trap above) a step threw before the helper ran. Confirm the helper is reached and **un-gated** first; never "fix" a no-row run by adding a throwing diagnostic.
- **Extra console diagnostics must be ADDITIVE, never a gate.** If you truly need the raw `dotnet test` console (e.g. an `AssemblyInitialize` stack trace), run the helper **first** so per-test rows still publish, then run a *separate, non-throwing* `dotnet test … --logger "console;verbosity=detailed"`, capture its output to a file, and publish a **short truncated tail** as its own `Push-TestCaseResult` row. A raw `dotnet test`'s stdout does not reliably reach `LOG_LINES`, and an oversized/multi-line `Push-TestCaseResult -Message` fails to publish (another no-row run) — keep any published message small.
- **Do not burn QAOps runs tuning a diagnostic message.** If a `Push-TestCaseResult` message will not surface, it is malformed (too large/multi-line) — fix it by reasoning locally, not by resubmitting. The durable fix is richer **assertion messages inside the test** (system snapshot + `SLAutomation.txt` tail — see `system-state-preflight.md`), which the un-gated helper publishes automatically.

## Adaptation Rules

- Run one `Invoke-DotNetTestAndPublishResults` call per copied MSTestV2 test assembly or executable.
- Use a unique TRX file name per test project when invoking multiple test projects.
- `$testAssemblyPath` may point to an older MSTest `.dll` or a newer MSTest executable.
- Always resolve test assemblies from `tests.generated`, never from `postbuild.generated` — the latter exists only at build time on the developer machine.
- Keep the copied test path aligned with the post-build copy target in the MSTestV2 project.
- Keep `Push-TestCaseResult` around the execution so QAOps shows a clear pipeline-level OK/Fail result.
- Exit with a non-zero code on failures so QAOps marks the run as failed.
- Keep this script focused on locating the packaged assembly/executable and invoking the shared helper. Do not invent custom test-execution plumbing here. A failing test is not a pipeline failure — never add a step that can `throw`/`exit` (e.g. a redundant `dotnet test` "diagnostic") before `Invoke-DotNetTestAndPublishResults` (see "Pipeline Integrity" above).

## Scoped Runs with `-TestFilter` (PipelineLibrary 1.3.0+)

`Invoke-DotNetTestAndPublishResults` 1.3.0+ supports two extra parameters (verified):

| Parameter | Effect |
|-----------|--------|
| `-TestFilter '<expression>'` | Passed as `--filter` to the MSTest executable / `dotnet test`. Examples: `'FullyQualifiedName~MyNewTestsClass.Create_'`, `'TestCategory=MyFeature'`. |
| `-PublishNotExecuted $false` | Skip publishing `NotExecuted` TRX rows (ignored tests) to QAOps. Default `$true`. |

Rules:

- **Scoped development runs use `-TestFilter`** — this is the preferred mechanism, replacing temporary `[Ignore]` attributes. Measured effect: a 657-test package dropped from ≈55 min to ≈4.5 min per QAOps run.
- Pin the module with `-MinimumVersion 1.3.0` on the `Install-Module` line whenever the new parameters are used; older module versions silently lack them.
- **Never bypass the helper by invoking the test executable directly with `--filter`** — direct invocation skips `Push-TestCaseResult`, so QAOps shows only the pipeline-level row and zero per-test assertions. Such runs are invalid evidence and still consume a token use (verified failure mode).
- Each filter change still requires a fresh versioned `.dmtest` (the filter lives inside the package script) — rerun the Fresh Test Package Version Gate.
- **Restore the unfiltered call and rebuild before the final full regression gates.** A filtered run never counts as the full-suite pass.
- Temporary `[Ignore]` attributes remain the fallback only for pre-1.3.0 module versions. If used, hand-edit the few files involved — a scripted bulk insert once rewrote ~100 files (encoding/EOL churn) and required a full `git restore`.

## Publishing Model (Why Runs Look "Quiet")

The helper runs the executable to completion first (TRX written at exit), then parses the TRX and pushes results to QAOps **one row at a time**. Measured on a 657-test package: ≈33 min of silence while the executable runs (including `AssemblyInitialize` protocol/fixture installs), then ≈20 min of gradual per-row publishing. Silence is not a hang. `-TestFilter` shrinks both phases; `-PublishNotExecuted $false` removes the rows for ignored tests from the publish phase.
