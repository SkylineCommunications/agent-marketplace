# QAOps Supplementary Files

Use supplementary files for runtime inputs that should travel with a QAOps run but should not be
embedded in the `.dmtest`, such as large packages, configuration files, scripts, or simulator data.

## Add Files to a Run

Pass each file with `--supplementary-file` (`--supplementary-files` is an alias):

```powershell
dataminer-qaops test-run-and-wait `
  -t 01KTRNHRHWQJ9SMESYJAFP8SE9 `
  -c 01KTRNMVWEZX5EAW3GRDB744G4 `
  --token "<QAOPS_TOKEN>" `
  --test-packages "C:\build\MyTests.1.2.3.dmtest" `
  --supplementary-file ".\configuration.json" `
  --supplementary-file ".\Scripts\PrepareEnvironment.ps1" `
  -rf "C:\temp\qaops-results.json" `
  -tags "MyTestsRCWithInputs1"
```

The option accepts any file type. The CLI validates that each file exists, creates one temporary ZIP,
uploads it, and removes the local ZIP after upload. Relative paths keep their folder structure in the
archive; absolute paths are stored by file name only. Paths that would produce duplicate archive
entries are rejected.

Supplementary files are runtime inputs, not Test Package content. A change to only a supplementary
file does not require a Test Package version bump or rebuild. Changes to test code or package pipeline
scripts still require the Fresh Artifact Gate.

The upload uses the same QAOps token as the test-run request. A token created before supplementary
files were introduced may not have permission on the `supplementaryfiles` container; create a new
Default AI Token if upload returns an authorization error.

## Locations on the QAOps Target

QAOps Bridge extracts the same archive on every agent:

| Location | Scope | Use |
|----------|-------|-----|
| `<PathToTestPackageContent>\SupplementaryFiles` | Pipeline agent only | Test Package PowerShell pipeline scripts |
| Path stored in machine-level `QAOPS_SUPPLEMENTARY_FILES` | Every cluster agent | MSTest code, Automation scripts, and any process that may run on another agent |

Do not hardcode `%ProgramData%\Skyline Communications\DataMiner QAOpsBridge\SupplementaryFiles\current`.
The Bridge normally uses that directory, but falls back to a `run-<ulid>` sibling when files from a
previous run remain locked. The environment variable always points at the active directory.

### PowerShell

Read the machine target explicitly because long-running processes cache their process environment:

```powershell
$supplementaryFilesPath = [Environment]::GetEnvironmentVariable(
    'QAOPS_SUPPLEMENTARY_FILES',
    [EnvironmentVariableTarget]::Machine)

if ([String]::IsNullOrWhiteSpace($supplementaryFilesPath) -or
    -not (Test-Path -LiteralPath $supplementaryFilesPath -PathType Container)) {
    throw 'This test requires QAOps supplementary files, but none are available for the current run.'
}

$configurationPath = Join-Path $supplementaryFilesPath 'configuration.json'
```

For a Test Package pipeline script that only runs on the package-execution agent, the package-local
copy is also available:

```powershell
$configurationPath = Join-Path $PathToTestPackageContent 'SupplementaryFiles\configuration.json'
```

Prefer `QAOPS_SUPPLEMENTARY_FILES` when the consumer can run outside that pipeline process or on
another cluster agent.

### C# Test Code

Read the machine-scoped value explicitly; do not use the one-argument overload or rely on
`Environment.GetEnvironmentVariable("QAOPS_SUPPLEMENTARY_FILES")`:

```csharp
string? supplementaryFilesPath = Environment.GetEnvironmentVariable(
    "QAOPS_SUPPLEMENTARY_FILES",
    EnvironmentVariableTarget.Machine);

if (String.IsNullOrWhiteSpace(supplementaryFilesPath) || !Directory.Exists(supplementaryFilesPath))
{
    Assert.Fail("This test requires QAOps supplementary files, but none are available for the current run.");
}

string configurationPath = Path.Combine(supplementaryFilesPath, "configuration.json");
Assert.IsTrue(File.Exists(configurationPath), $"Supplementary file not found: {configurationPath}");
```

This is different from trying to set a local environment variable after the Copilot/CLI session
started. `QAOPS_SUPPLEMENTARY_FILES` is created by QAOps Bridge on the target machine for the active
run, so PowerShell and C# consumers must query the machine-level value at runtime.

## Lifecycle, Compatibility, and Security

- The directory and environment variable are optional and absent when the run has no supplementary
  files. Code that requires them must fail with a clear diagnostic rather than dereference a missing
  path.
- The Bridge clears the directory before a run and removes it and the environment variable after the
  run. Locked leftovers produce a warning and are retried during later cleanup; they do not fail the
  completed run.
- If the run declares supplementary files but the uploaded archive can no longer be resolved, QAOps
  fails the run instead of executing tests without required inputs.
- Every target server requires QAOps Bridge 1.1.0 or newer. QAOps refuses the run and identifies
  servers that need an upgrade rather than allowing an older Bridge to ignore the archive.
- Every local user and every process started by the test run can read these files. Never use
  supplementary files to transport secrets.
