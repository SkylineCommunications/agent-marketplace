# DxM/DcM solution template reference

Template short name: `dataminer-dxm-solution`  
Package: `Skyline.DataMiner.VisualStudioTemplates.Internal`

## When to use

Use this template when the user asks for a new **DataMiner Extension Module (DxM)** or **DataMiner core Module (DcM)**. Do not use the connector solution template for a DxM/DcM.

## Install

```bash
dotnet new install Skyline.DataMiner.VisualStudioTemplates.Internal
```

## Scaffold

```bash
dotnet new dataminer-dxm-solution -n "<SolutionName>" --dxm-name "<DxMName>" --description "<Description>" --license-type <MIT|Skyline>
```

- `--dxm-name`: PascalCase module name. DataMiner will prefix it automatically; do not add an `SL` prefix.
- `--description`: Short description of the module.
- `--license-type`: `MIT` or `Skyline`.

## Generated structure

```text
<SolutionName>/
  SolutionName.sln
  dxm-id-file.json
  <DxMName>.Api/
  <DxMName>.Service/
  <DxMName>.Installer.CA/
  <DxMName>.Installer/
  DataMinerReleaseNotes.config.json   # create if missing
```

## After scaffolding

1. Run `dotnet build` to verify the solution compiles.
2. Ensure `DataMinerReleaseNotes.config.json` exists in the solution root. For a standalone DxM, set `deliveryVehicle` to `StandaloneDxM`.
3. Proceed to create or update the release note using the `dataminer-dxm-release-notes` skill.

## Important

A DxM/DcM does **not** contain `protocol.xml`, QActions, or `QAction_Helper.cs`. If a generic automation override mentions XML/QAction steps but the user explicitly asked for a DxM, ignore those steps and use this template.
