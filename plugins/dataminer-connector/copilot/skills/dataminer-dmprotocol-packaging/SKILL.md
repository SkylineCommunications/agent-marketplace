---
name: dataminer-dmprotocol-packaging
description: Create a .dmprotocol connector package from a classic (DIS-style) connector solution using the official Skyline.DataMiner.CICD.Tools.Packager CLI (dataminer-package-create dmprotocol). Use whenever you need a deployable/installable connector artifact and the project is NOT an SDK-style connector — e.g. harvesting a legacy protocol.xml + QAction_*.csproj solution into a .dmprotocol for deployment, CI, or inclusion in a DataMiner Test Package. Covers local vs global tool install, the exact CLI arguments, version override, MSBuild wiring, the trailing-backslash output gotcha, package verification, and deploying the artifact. Independent of QAOps.
argument-hint: 'Describe the packaging need: e.g. "package this classic connector into a .dmprotocol", "harvest the connector for a Test Package", "build a deployable connector artifact in CI"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 1.4
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.4 | 2026-09-16 | Added explicit package handoff evidence and separated package creation from Catalog publication, deployment, and QAOps verification. |
| 1.3 | 2026-09-14 | Recognized valid classic connector solutions that intentionally omit QAction_Helper. |
| 1.2 | 2026-08-20 | Updated new-connector scaffolding guidance to the consolidated `dataminer-sdk` skill and its `dataminer-connector-solution` template. |
| 1.1 | 2026-06-25 | Completed the **Deploying the Artifact** command: `dataminer-package-deploy from-artifact --path-to-artifact "<file>"` alone **fails with exit code 1** — the required `--dm-server-location`, `--dm-user`, and `--dm-password` arguments were previously hidden behind a `...` placeholder and a session's `1.TestPackageSetup.ps1` deploy step failed because of it. The command now shows the mandatory args and points at the QAOps `WinEncryptedKeys` credential snippet. |
| 1.0 | 2026-06-17 | Initial standalone skill: creating a `.dmprotocol` from a classic connector solution with `Skyline.DataMiner.CICD.Tools.Packager` (`dataminer-package-create dmprotocol`), local/global tool install, version override, MSBuild target wiring, the verified trailing-backslash `--output` gotcha, package verification, and deployment. Extracted from a QAOps connector-harvesting session so any session can package a `.dmprotocol` in a few tokens. |

# Creating a `.dmprotocol` Connector Package

A `.dmprotocol` is the installable/deployable package for a single DataMiner connector (protocol): it bundles the `protocol.xml` together with the compiled QAction assemblies and other package items. Use this skill to produce one from a **classic (DIS-style) connector solution** — a repo whose root holds a `protocol.xml` and one or more `QAction_*.csproj` projects, optionally with a generated `QAction_Helper`, not an SDK-style project.

> **SDK-first rule (load `dataminer-sdk` for the full policy).** Never handcraft a `.dmprotocol` by zipping files. Always use the official `Skyline.DataMiner.CICD.Tools.Packager` CLI shown here. It is the only supported way to build the package outside Visual Studio/DIS.

## Decision: Do You Even Need This Tool?

| Connector project shape | How to produce the `.dmprotocol` |
|-------------------------|-----------------------------------|
| **SDK-style connector** (`<Project Sdk="Skyline.DataMiner.Sdk">`, `<DataMinerType>` is a protocol type) | `dotnet publish` / `dotnet build` already produces the package. Use **`dataminer-sdk`**, not this tool. |
| **Classic / legacy connector** (root `protocol.xml` + `QAction_*.csproj`, DIS layout, no `Skyline.DataMiner.Sdk`) | Use `Skyline.DataMiner.CICD.Tools.Packager` as described below. There is no `dotnet publish` package output for this layout. |
| Inside a **DataMiner Test Package** for QAOps | The SDK Test Package auto-includes *SDK-style* same-solution DataMiner projects, but **NOT** a classic connector. Harvest it with this tool and add the `.dmprotocol` as package content — see `dataminer-qaops-integration-testing`. |

## The Tool

Package: `Skyline.DataMiner.CICD.Tools.Packager` — exposes the command **`dataminer-package-create`**.

```text
dataminer-package-create dmprotocol [<directory>] [options]

Arguments:
  <directory>   Directory containing the package items (the connector solution root that holds protocol.xml).

Options:
  -vo, --version-override <VERSION>   Override the version written into the protocol package.
  -o,  --output <OUTPUT_DIRECTORY>    (REQUIRED) Directory where the .dmprotocol is written.
  -n,  --name <OUTPUT_NAME>           Name of the output package file.
```

The tool compiles the connector's QActions and assembles the `protocol.xml` + assemblies into the `.dmprotocol`. `<directory>` is the **solution root** — the folder that contains `protocol.xml` (and the `QAction_*` projects), not a `bin` folder.

## Installing the Tool

Prefer a **repo-local tool manifest** so the version is pinned and CI/other machines restore it deterministically. Run from the repo root:

```bash
dotnet new tool-manifest          # only if .config/dotnet-tools.json does not exist yet
dotnet tool install Skyline.DataMiner.CICD.Tools.Packager
```

This creates/updates `.config/dotnet-tools.json`. Restore and run with:

```bash
dotnet tool restore
dotnet tool run dataminer-package-create dmprotocol "<connector-root>" --output "<out-dir>" --name "MyConnector"
```

Global install is also fine for one-off local use (the command is then on `PATH` directly):

```bash
dotnet tool install -g Skyline.DataMiner.CICD.Tools.Packager
dataminer-package-create dmprotocol "<connector-root>" --output "<out-dir>" --name "MyConnector"
```

> On a fresh checkout, package builds that invoke the local tool fail until `dotnet tool restore` has run (`.config/dotnet-tools.json` is present but the tool is not yet downloaded). Always restore first.

## ⚠️ The Trailing-Backslash `--output` Gotcha (verified)

When you pass a **quoted path that ends in a backslash**, the shell/CLI treats `\"` as an escaped quote, swallows the closing quote, and the parser then reports `--output` as missing or misreads the next argument. This bites hardest in MSBuild where `..\` is a natural value.

- **Bad:** `... dmprotocol "..\" --output "out\"` → CLI acts as if `--output` was not supplied.
- **Good:** keep directory values **without a trailing backslash** inside the quotes — use `..` not `..\`, and `out` / `$(SomeDir)` that does not end in `\`.

This single gotcha caused a packaging build to fail with a "missing required `--output`" style error even though the option was present.

## Wiring It Into an MSBuild Build (e.g. a Test Package or CI project)

Generate the `.dmprotocol` as a pre-build step and drop it where the consuming project expects it. Note `ConnectorRoot` is `..` (no trailing backslash) and every path is quoted with `&quot;`:

```xml
<Target Name="CreateConnectorProtocolPackage" BeforeTargets="Build">
  <PropertyGroup>
    <!-- No trailing backslash — see the gotcha above. -->
    <ConnectorRoot>$(MSBuildThisFileDirectory)..</ConnectorRoot>
    <GeneratedConnectorDirectory>$(MSBuildThisFileDirectory)SomeContent\connector.generated</GeneratedConnectorDirectory>
  </PropertyGroup>

  <MakeDir Directories="$(GeneratedConnectorDirectory)" />

  <!-- Remove any stale package so only the fresh one remains. -->
  <ItemGroup>
    <_ExistingConnectorPackage Include="$(GeneratedConnectorDirectory)\*.dmprotocol" />
  </ItemGroup>
  <Delete Files="@(_ExistingConnectorPackage)" />

  <Exec Command="dotnet tool restore" WorkingDirectory="$(ConnectorRoot)" />
  <Exec Command="dotnet tool run dataminer-package-create dmprotocol &quot;$(ConnectorRoot)&quot; --output &quot;$(GeneratedConnectorDirectory)&quot; --name &quot;MyConnector&quot;" WorkingDirectory="$(ConnectorRoot)" />
</Target>
```

Pass `--version-override "$(SomeVersion)"` when the package version must be controlled by the build instead of the `protocol.xml` `<Version>`.

## Verifying the Output

1. Confirm exactly one expected `.dmprotocol` exists in the output directory (delete stale ones first, as above, so you never pick up an old artifact).
2. A `.dmprotocol` is a zip archive. To verify contents, copy it to `*.zip` and extract:

```powershell
Copy-Item 'MyConnector.dmprotocol' 'MyConnector.dmprotocol.zip' -Force
Expand-Archive 'MyConnector.dmprotocol.zip' -DestinationPath '.\inspect' -Force
Get-ChildItem -Recurse '.\inspect' | Select-Object FullName
```

   Expect the `protocol.xml` and the compiled QAction assemblies inside. A missing assembly usually means the QAction projects did not build — check the packager's build output for compiler errors.

## Package Handoff Gate

Packaging is a build artifact stage, not publication or deployment. Before handing the `.dmprotocol` to QAOps, Catalog, or deployment:

1. Record the source solution/commit, connector name, protocol version, packager version, output filename, and SHA-256 hash.
2. Confirm the artifact is fresh and exactly one expected package was produced; do not reuse a stale file from a previous build.
3. Inspect the archive for `protocol.xml` and every expected compiled QAction assembly. Keep the inspection result with the artifact record.
4. State the next route explicitly: Test Package content, Catalog upload, or direct deployment. Each route has its own credentials, target, and final result.

Do not report "published", "deployed", or "verified on QAOps" from a successful packager exit code alone.

## Deploying the Artifact

To install the generated `.dmprotocol` on a DataMiner, use the official deploy CLI (`Skyline.DataMiner.CICD.Tools.DataMinerDeploy`, command `dataminer-package-deploy`), not manual file copying. The CLI **requires the target DataMiner location and credentials** — `from-artifact --path-to-artifact "<file>"` on its own **fails with exit code 1**:

```bash
dataminer-package-deploy from-artifact --path-to-artifact "<path>\MyConnector.dmprotocol" --dm-server-location "localhost" --dm-user "<user>" --dm-password "<password>" --deploy-timeout-in-seconds 3600
```

`--dm-server-location` (e.g. `localhost`), `--dm-user`, and `--dm-password` are mandatory; omitting them is a common, easily-missed mistake that surfaces only at deploy time. In a QAOps Test Package this deploy step belongs in `TestPackageContent/TestPackagePipeline/1.TestPackageSetup.ps1`, where the user/password come from the `WinEncryptedKeys` keys `QAOpsDataMinerUser`/`QAOpsDataMinerPassword` — see `dataminer-qaops-integration-testing` → `references/test-package-prerequisites.md` for the exact setup-script snippet.

## Related Skills

| Task | Skill |
|------|-------|
| Official SDK/tool authority, full Packager/CatalogUpload/DataMinerDeploy command set, SDK-style `dotnet publish` packaging | `dataminer-sdk` |
| Harvest a classic connector into a Test Package and run it on QAOps | `dataminer-qaops-integration-testing` → `dataminer-qaops-test-runs` |
| Create a new connector solution from the official template | `dataminer-sdk` (`dataminer-connector-solution`) |
