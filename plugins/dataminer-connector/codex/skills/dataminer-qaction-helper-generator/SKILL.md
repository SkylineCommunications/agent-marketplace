---
name: dataminer-qaction-helper-generator
description: Generate QAction_Helper.cs from protocol.xml using the qaction-helper-generation dotnet global tool. Use when explicitly requested or when an existing consumer depends on generated members changed by protocol.xml.
argument-hint: 'Describe the task: e.g. "regenerate helper after XML changes", "generate QAction_Helper for new connector", "update helper after adding table columns"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-14
  version: 3.1
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 3.1 | 2026-09-14 | Added a conditional generation gate and preserved intentionally helper-free solutions. |
| 3.0 | 2026-05-19 | Migrated from bundled QActionHelperGenerator.exe to qaction-helper-generation dotnet global tool. |
| 2.0 | 2026-04-01 | Initial release. |

# QAction_Helper.cs Generator

Generates QAction_Helper/QAction_Helper.cs from protocol.xml by invoking the `qaction-helper-generation` dotnet global tool.

The generation is deterministic and delegated to the CLI tool. Do not manually synthesize helper content from XML rules.

## Step 1: Decide Whether Generation Is Required

Generate or refresh the helper only when at least one condition holds:

- The user explicitly requested helper generation.
- Existing QAction or test source consumes generated `Parameter`, `SLProtocolExt`, `{Table}QActionTable`, `{Table}QActionRow`, or `ConcreteSLProtocolExt` members and an XML change affects their names, IDs, types, or table layout.
- New code deliberately adopts generated typed access in a solution that already follows the helper-based layout.

A `QAction_Helper` project reference by itself does not prove that source consumes generated members. If no source consumer exists, or if changed XML does not affect the generated surface, report that no refresh is needed.

If the solution intentionally has no helper project/reference, preserve that architecture. Do not add one merely because `protocol.xml` changed.

## Step 2: Locate Required Paths

1. Locate the connector solution root (folder containing .sln or .slnx).
2. Input file: {solution_root}/protocol.xml
3. Output file: {solution_root}/QAction_Helper/QAction_Helper.cs

If generation is required but the helper project/output path is absent, stop and ask whether the user wants to introduce the generated-helper architecture. Do not silently add projects or references.

## Step 3: Ensure Tool Is Installed

Check whether `qaction-helper-generation` is available. If not, install it:

```powershell
$installed = dotnet tool list --global | Select-String "skyline.dataminer.tools.qactionhelpergenerator"
if (-not $installed) {
    dotnet tool install --global Skyline.DataMiner.Tools.QActionHelperGenerator
}
```

## Step 4: Run The Tool

PowerShell example:

```powershell
qaction-helper-generation --input "$protocolPath" --output "$helperOutputPath"
```

Where:
- $protocolPath = {solution_root}/protocol.xml
- $helperOutputPath = {solution_root}/QAction_Helper/QAction_Helper.cs

## Step 5: Handle Exit Codes

- 0: Success.
- 1: Generation failed due to protocol XML parse/validation errors. Fix protocol.xml and run again.
- 2: Bad arguments or IO error (missing file, invalid path, etc.). Fix invocation/paths and run again.

## Step 6: Missing Tool Behavior

If the auto-install in Step 2 failed (e.g., no internet, NuGet source unavailable):
1. Fail with a clear message.
2. Instruct the user to install the tool manually: `dotnet tool install --global Skyline.DataMiner.Tools.QActionHelperGenerator`

Do not fall back to manual helper generation logic.

## Step 7: Verify

After generation:

```bash
dotnet build <solution.sln or solution.slnx>
```

When generation was required, the build must succeed before proceeding with code that consumes the refreshed members. A skipped helper refresh is not a failed completion gate when the decision in Step 1 shows that no generated consumer is affected.
