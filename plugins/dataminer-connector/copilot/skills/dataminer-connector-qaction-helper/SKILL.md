---
name: dataminer-connector-qaction-helper
description: Generate QAction_Helper.cs from protocol.xml using the qaction-helper-generation dotnet global tool. Use when explicitly requested or when an existing consumer depends on generated members changed by protocol.xml.
argument-hint: 'Describe the task: e.g. "regenerate helper after XML changes", "generate QAction_Helper for new connector", "update helper after adding table columns"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-22
  version: 3.2
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 3.2 | 2026-10-22 | Added NEW-connector empty-stub check, public `nuget.org` `Skyline.DataMiner.Files.QActionHelper` fallback when private GitHub Packages returns 401, and exact `QActionHelper` casing/dummy-parameter reference rules. |
| 3.1 | 2026-09-14 | Added a conditional generation gate and preserved intentionally helper-free solutions. |
| 3.0 | 2026-05-19 | Migrated from bundled QActionHelperGenerator.exe to qaction-helper-generation dotnet global tool. |
| 2.0 | 2026-04-01 | Initial release. |

# QAction_Helper.cs Generator

Generates `QAction_Helper/QAction_Helper.cs` from `protocol.xml` using the `qaction-helper-generation` dotnet global tool or the underlying official `Skyline.DataMiner.Files.QActionHelper` NuGet library (`QActionHelper.TryCreateProtocolQActionHelperFromString`).

The generation is 100% deterministic and delegated to the official Skyline generator. **NEVER manually hand-synthesize or edit `QAction_Helper.cs`** — hand-written helper files almost always use wrong constant casing (e.g., PascalCase `Parameter.Apikey` instead of the real DIS all-lowercase `Parameter.apikey`), which passes a local build until Visual Studio DIS regenerates `QAction_Helper.cs` and breaks compilation with `CS0117`.

## Step 1: Decide Whether Generation Is Required

Generate or refresh the helper only when at least one condition holds:

- The user explicitly requested helper generation.
- **NEW connector or newly added parameters with planned QAction consumers**: On a newly scaffolded connector (`dotnet new dataminer-connector-solution`), `QAction_Helper/QAction_Helper.cs` starts as an empty stub (`public static class Parameter { public class Write { } }`). Whenever planned or new QAction code will reference `Parameter.*`, `SLProtocolExt`, `{Table}QActionTable`, or `{Table}QActionRow`, you **must** generate `QAction_Helper.cs` after authoring `protocol.xml` and **before** writing QAction C# code.
- Existing QAction or test source consumes generated `Parameter`, `SLProtocolExt`, `{Table}QActionTable`, `{Table}QActionRow`, or `ConcreteSLProtocolExt` members and an XML change affects their names, IDs, types, or table layout.
- `QAction_Helper/QAction_Helper.cs` on disk was previously hand-synthesized (e.g., missing `[EditorBrowsable(EditorBrowsableState.Never)]` `_<pid>` constants or using PascalCase `public const int` fields inside `Parameter`) — regenerate it immediately so it matches real DIS output.

A `QAction_Helper` project reference by itself does not prove that source consumes generated members. If no existing or planned source consumer exists, or if changed XML does not affect the generated surface, report that no refresh is needed.

If the solution intentionally has no helper project/reference, preserve that architecture. Do not add one merely because `protocol.xml` changed.

## Step 2: Locate Required Paths

1. Locate the connector solution root (folder containing `.sln` or `.slnx`).
2. Input file: `{solution_root}/protocol.xml`
3. Output file: `{solution_root}/QAction_Helper/QAction_Helper.cs`

If generation is required but the helper project/output path is absent, stop and ask whether the user wants to introduce the generated-helper architecture. Do not silently add projects or references.

## Step 3: Run `qaction-helper-generation` CLI (or Install with `--ignore-failed-sources`)

Check whether `qaction-helper-generation` is available globally. If not, attempt to install it with `--ignore-failed-sources` so an unauthenticated private feed does not block installation if a valid source is available:

```powershell
$installed = dotnet tool list --global | Select-String "skyline.dataminer.tools.qactionhelpergenerator"
if (-not $installed) {
    dotnet tool install --global Skyline.DataMiner.Tools.QActionHelperGenerator --ignore-failed-sources
}
```

If `qaction-helper-generation` is available, run it:

```powershell
qaction-helper-generation --input "$protocolPath" --output "$helperOutputPath"
```

Where:
- `$protocolPath` = `{solution_root}/protocol.xml`
- `$helperOutputPath` = `{solution_root}/QAction_Helper/QAction_Helper.cs`

### CLI Exit Codes
- `0`: Success.
- `1`: Generation failed due to protocol XML parse/validation errors. Fix `protocol.xml` and run again.
- `2`: Bad arguments or IO error (missing file, invalid path, etc.). Fix invocation/paths and run again.

## Step 4: Public `nuget.org` Fallback (`Skyline.DataMiner.Files.QActionHelper`)

`Skyline.DataMiner.Tools.QActionHelperGenerator` is hosted on the private GitHub Packages NuGet feed (`https://nuget.pkg.github.com/SkylineCommunications/index.json`). If `qaction-helper-generation` is not installed and `dotnet tool install` fails with `401 (Unauthorized)` or "package not found", **do NOT manually write `QAction_Helper.cs`**.

Instead, invoke the official `Skyline.DataMiner.Files.QActionHelper` package from public `nuget.org` (`https://www.nuget.org`), which is the exact library that both `qaction-helper-generation` and Visual Studio DIS call (`QActionHelper.TryCreateProtocolQActionHelperFromString`):

```powershell
$protocolPath = "{solution_root}\protocol.xml"
$helperOutputPath = "{solution_root}\QAction_Helper\QAction_Helper.cs"

$pkgDir = Join-Path $env:USERPROFILE ".nuget\packages\skyline.dataminer.files.qactionhelper\10.6.10.1"
$dllPath = Join-Path $pkgDir "lib\net462\QActionHelper.dll"
if (-not (Test-Path $dllPath)) {
    New-Item -ItemType Directory -Force -Path $pkgDir | Out-Null
    $nupkg = Join-Path $pkgDir "qactionhelper.zip"
    Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Skyline.DataMiner.Files.QActionHelper/10.6.10.1" -OutFile $nupkg
    Expand-Archive -Path $nupkg -DestinationPath $pkgDir -Force
    Remove-Item $nupkg -Force
}

Add-Type -Path $dllPath
[string]$xml = [System.IO.File]::ReadAllText($protocolPath, [System.Text.Encoding]::UTF8)
[string]$sourceCode = ""
[System.Collections.Generic.IList[Skyline.DataMiner.Scripting.XMLParseError]]$errors = $null

if (-not [Skyline.DataMiner.Scripting.QActionHelper]::TryCreateProtocolQActionHelperFromString($xml, [ref]$sourceCode, [ref]$errors)) {
    foreach ($err in $errors) {
        Write-Error "Line $($err.Line): $($err.Description)"
    }
    exit 1
}

$header = "// <auto-generated>This is auto-generated code by DIS. Do not modify.</auto-generated>`r`n"
[System.IO.File]::WriteAllText($helperOutputPath, $header + $sourceCode, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Generated: $helperOutputPath"
```

## Step 5: Verify Build and Inspect Generated Constants

After generation:

```bash
dotnet build <solution.sln or solution.slnx>
```

When generation was required, the build must succeed before proceeding with code that consumes the refreshed members. Always read `QAction_Helper/QAction_Helper.cs` to verify the exact generated constant and property names before writing QAction C# code.

## Reference: Exact `QActionHelper` Identifier & Casing Rules

`Skyline.DataMiner.Files.QActionHelper` (`Utils.ConvertStringToCaseType`) splits a parameter's `<Name>` **only on spaces, hyphens (`-`), and dots (`.`)** — **never** on camelCase word boundaries. Because connector XML authoring normalizes `<Param><Name>` to a single camelCase word without spaces (e.g., `<Name>apiKey</Name>`, `<Name>statusCodeCurrentWeather</Name>`), the entire `<Name>` is treated as **Word 0**:

| Target in `QAction_Helper.cs` | Casing Rule Applied by `QActionHelper.dll` | Example for `<Name>apiKey</Name>` (PID 110 read / 160 write) | Common Wrong Guess (Breaks Compilation) |
|---|---|---|---|
| `Parameter.<name>` (standalone read) | **All lowercase** (plus `[EditorBrowsable(Never)]` `<name>_<pid>`) | `Parameter.apikey`, `Parameter.apikey_110` | ❌ `Parameter.Apikey`, ❌ `Parameter.apiKey` |
| `Parameter.Write.<name>` (standalone write) | **All lowercase** (plus `[EditorBrowsable(Never)]` `<name>_<pid>`) | `Parameter.Write.apikey`, `Parameter.Write.apikey_160` | ❌ `Parameter.Write.Apikey`, ❌ `Parameter.Write.apiKey` |
| `<Type>dummy</Type>` parameters (e.g., `afterStartup`) | **NOT emitted in `Parameter` at all** (only on `SLProtocolExt` as `Afterstartup_dummy`) | Use a local constant: `const int AfterStartupPid = 1;` | ❌ `Parameter.Afterstartup`, ❌ `Parameter.afterstartup` |
| `Parameter.<Tablename>` (table class) | **First letter uppercase, rest lowercase** | `<Name>channelsTable</Name>` → `Parameter.Channelstable` | ❌ `Parameter.ChannelsTable` |
| Fixed table constants | Exact camelCase | `Parameter.Channelstable.tablePid`, `indexColumn`, `indexColumnPid` | ❌ `Parameter.Channelstable.TablePid` |
| `Parameter.<Tablename>.Pid.<col>` & `.Idx.<col>` | **All lowercase** | `Parameter.Channelstable.Pid.channelname` (`_1002`) | ❌ `Parameter.Channelstable.Pid.channelName` |
| `SLProtocolExt` / `WriteParameters` scalar property | **First letter uppercase, rest lowercase** | `protocol.Apikey`, `protocol.Write.Apikey` | ❌ `protocol.ApiKey` |
| `SLProtocolExt` table property | **All lowercase** | `protocol.channelstable` | ❌ `protocol.ChannelsTable` |
