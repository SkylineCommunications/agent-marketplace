---
name: dataminer-sdk
description: 'Skyline DataMiner SDK and official toolchain authority: SDK-style projects, official templates, validator cadence, Packager/CatalogUpload/DataMinerDeploy, Dev Packs, PackageReference, and troubleshooting. Use for project setup, validation, build, packaging, publishing, deployment, or whenever an official Skyline tool may replace manual work.'
argument-hint: 'Describe the SDK or tooling task: e.g. "install DataMiner templates", "which Skyline tool should I use", "validate connector often", "package and publish with the SDK"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-18
  version: 2.2
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-automation-core`, `dataminer-automation-scripting`, `dataminer-automation-xml`, `dataminer-dxm-release-notes`, `dataminer-gqi-ad-hoc-data-source`, `dataminer-user-defined-api`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-automation-core`: Automation-specific route; consumers authoring scripts include their own Automation authorities.
> - `dataminer-automation-scripting`: Automation-specific route, not required for connector-only SDK tooling.
> - `dataminer-automation-xml`: Automation-specific schema route; consumers authoring scripts include this authority.
> - `dataminer-dxm-release-notes`: Only required for a separate DxM/DcM release-note workflow, which is not distributed in these plugins.
> - `dataminer-gqi-ad-hoc-data-source`: Specialized GQI authoring route; not needed by other SDK project types.
> - `dataminer-user-defined-api`: Specialized API authoring route; not needed by other SDK project types.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.2 | 2026-09-18 | Added explicit lifecycle-stage ownership and evidence separation for package creation, Catalog publication, deployment, and live verification. |
| 2.1 | 2026-09-18 | Documented helper-based and helper-free QAction layouts and made helper refresh conditional, while preserving package-backed solution wiring and specialized template routing. |
| 1.8 | 2026-07-02 | Corrected `connector-template-reference.md`: the current official template generates `.sln` by default (verified live), not `.slnx` as previously documented. Generalized validator/compare command examples to `.sln`/`.slnx` — confirmed via live test that `dataminer-validator` CLI 3.2.0 and `dotnet build` both work identically against either format. |
| 1.7 | 2026-06-30 | Absorbed `dataminer-scaffolding` and `dataminer-automation-scaffolding` as reference files under this skill. This skill is now the single authority for all template scaffolding. |
| 1.6 | 2026-06-19 | Added a zero-delay "new solution" checklist: when the user asks for a new DataMiner solution, scaffold with official templates immediately (no archaeology/manual scaffolding first), then wire QAOps integration-test/test-package projects. |
| 1.5 | 2026-06-17 | Added a pointer to the new `dataminer-dmprotocol-packaging` skill for the detailed `.dmprotocol` workflow on **classic (non-SDK) connector solutions** — local tool-manifest install, MSBuild wiring, the trailing-backslash `--output` gotcha, verification, and deploy. SDK-style connectors still package via `dotnet publish`. |
| 1.4 | 2026-06-12 | Troubleshooting: package builds failing in `CreateDataMinerPackages`-style targets on fresh checkouts need `dotnet tool restore` (local tool manifest `.config/dotnet-tools.json`; verified — a baseline build failed until the packager tool was restored). |
| 1.3 | 2026-06-10 | Added the `Skyline.DataMiner.qaops` CLI to the ecosystem and commands-by-job tables with routing to the QAOps skills. |
| 1.2 | 2026-05-24 | Replaced duplicated validator CLI subcommand block and troubleshooting with pointers to `dataminer-validation` (sole authoritative CLI reference). |
| 1.1 | 2026-05-14 | Added DIS routing, validator command version-awareness, and current compare guidance. |
| 1.0 | 2026-05-14 | Initial release. |

# Skyline DataMiner SDK and Official Tooling

This skill is the authority for official Skyline SDK, template, CLI, and Dev Pack usage.

Load it whenever a task involves project creation, validation, build, packaging, publishing, deployment, dependency selection, or tool installation.

---

## SDK-First Rule

- **ALWAYS use official Skyline SDK/templates/tools/NuGets when they can do the job.**
- **NEVER manually scaffold** a connector, package, or automation solution when an official `dotnet new` template exists.
- **NEVER manually copy DataMiner assemblies** or depend on local DataMiner install folders when a Dev Pack or Skyline NuGet exists.
- **NEVER handcraft `.dmapp` or `.dmprotocol` packages**, Catalog uploads, or deployments when an official Skyline CLI tool exists for that job.
- **NEVER rely on manual XML inspection alone.** Run validators and build gates repeatedly during development.
- **Project-local helper tools are supplemental only.** They may provide faster feedback, but they never replace official Skyline SDK/tool validation.

## Zero-Delay "New Solution" Checklist (Run First)

When the request explicitly says **"create/add a new solution/project"**, do this immediately before inspecting legacy folders:

1. Install/refresh the official templates. Use the **internal** package for DxM/DcM, BPA, .NET tool, and NuGet package solutions:

```bash
dotnet new install Skyline.DataMiner.VisualStudioTemplates --add-source https://api.nuget.org/v3/index.json
dotnet new install Skyline.DataMiner.VisualStudioTemplates.Internal --add-source https://api.nuget.org/v3/index.json
```

2. Scaffold with official templates (never manual folder/file creation), then create the solution and add every project so it is buildable from the start:

```bash
# Connector or automation
dotnet new sln -n "<SolutionName>"
dotnet new dataminer-automation-project -n "<AutomationProjectName>" -o "<AutomationProjectName>" -auth "<Author>"
dotnet new dataminer-test-package-project -n "<TestPackageProjectName>" -o "<TestPackageProjectName>" -auth "<Author>"
dotnet sln "<SolutionName>.sln" add "<AutomationProjectName>" "<TestPackageProjectName>"

# DataMiner Extension Module (DxM) / core Module (DcM)
dotnet new dataminer-dxm-solution -n "<SolutionName>" --dxm-name "<DxMName>" --description "<Description>" --license-type <MIT|Skyline>
```

3. For QAOps verification, add an MSTest integration project (`dotnet new mstest`), add it to the solution, and wire it to the Test Package flow (`dataminer-qaops-integration-testing`). For a data-producing project, this is not complete until the tests assert the **semantic result contract** — the rows, keys and values the consumer actually receives — and not merely that the package built and the script exited successfully. A run that packages cleanly and reports success while emitting incomplete or wrongly-keyed data is a product failure, and only a contract assertion will catch it.

4. Only after scaffolding, inspect older local projects for conventions you want to mirror.

Hard rule: **"new solution" means scaffold first, compare second**. Do not delay scaffolding with repository archaeology.

> [!IMPORTANT]
> A **DataMiner Extension Module (DxM)** or **core Module (DcM)** is **not** a connector. DxMs/DcMs are scaffolded with the `dataminer-dxm-solution` template from `Skyline.DataMiner.VisualStudioTemplates.Internal`. They do **not** contain `protocol.xml`, QActions, or `QAction_Helper.cs`. If a generic automation override mentions "XML authoring, QAction_Helper generation, QAction writing, and validation" but the user explicitly asks for a **DxM/DcM**, follow the DxM template and ignore the connector-specific steps. Do not fall back to `dataminer-connector-solution` just because the DxM template was not installed yet — install `Skyline.DataMiner.VisualStudioTemplates.Internal` first.

### Manual fallback policy

Manual work is allowed only when one of these is true:

1. No official Skyline SDK/tool/package exists for the job.
2. The official Skyline tool was explicitly checked and could not be installed or executed.

If a manual fallback is used, report the reason and use the narrowest possible workaround.

---

## What Is In The SDK Ecosystem

| Component | Purpose | Use It For |
|-----------|---------|------------|
| `Skyline.DataMiner.Sdk` | MSBuild SDK for DataMiner SDK-style projects | Building and publishing DataMiner package-style projects with normal `dotnet build` and `dotnet publish` |
| `Skyline.DataMiner.VisualStudioTemplates` | Official `dotnet new` templates | Creating connector solutions and SDK-style projects |
| `Skyline.DataMiner.VisualStudioTemplates.Internal` | Internal `dotnet new` templates (DxM/DcM, BPA, .NET tool, NuGet package solutions) | Creating DataMiner Extension Modules, internal tools, and package solutions |
| `Skyline.DataMiner.Sdk.Download` | SDK downloader tool | Recovering a missing SDK when Visual Studio or NuGet resolution fails |
| `DataMiner Integration Studio` | Official Visual Studio extension | Code-aware authoring, validation review, compare/MCC, MIB-assisted generation, and version editing when working interactively in Visual Studio |
| `Skyline.DataMiner.CICD.Tools.Validator` | Official connector validator | Frequent validation during development and final connector validation |
| `Skyline.DataMiner.CICD.Tools.Packager` | Official packaging CLI | Creating `.dmprotocol` and `.dmapp` artifacts |
| `Skyline.DataMiner.CICD.Tools.CatalogUpload` | Official Catalog upload CLI | Volatile uploads, registered uploads, and Catalog metadata updates |
| `Skyline.DataMiner.CICD.Tools.DataMinerDeploy` | Official deployment CLI | Deploying from Catalog, volatile upload, or local artifact |
| `Skyline.DataMiner.qaops` | QAOps regression test CLI | Running `.dmtest` test packages on real QAOps DaaS DataMiner systems (load `dataminer-qaops` + `dataminer-qaops-test-runs`) |
| `Skyline.DataMiner.Dev.Protocol` | Connector Dev Pack | Compiling connector QActions against DataMiner APIs without manual DLL references |
| `Skyline.DataMiner.Dev.Automation` | Automation Dev Pack | Compiling automation scripts against DataMiner APIs |
| `Skyline.DataMiner.CICD.CSharpAnalysis.Analyzer` | Skyline Roslyn analyzers | C# quality and reliability diagnostics |
| `Skyline.DataMiner.Utils.SecureCoding.Analyzers` | Secure coding analyzers | Security-focused C# diagnostics |

---

## Official Templates And Project Types

### Template Reference Files

| Template | Reference File | Load When |
|----------|---------------|-----------|
| Connector solution (`dataminer-connector-solution`) | `references/connector-template-reference.md` | Scaffolding a new connector — parameters, connection types, OID conventions, solution structure, post-scaffold setup |
| Automation script (`dataminer-automation-project`, `dataminer-automation-library-project`) | `references/automation-template-reference.md` | Scaffolding a new automation script — parameters, solution structure, sln creation, Catalog metadata, packaging |
| Package-backed Automation solution (`dataminer-package-project` + Automation project) | `references/package-project-reference.md` | Wiring sibling projects, package install hooks, Catalog metadata, package inspection, and deployment boundaries |
| DxM/DcM solution (`dataminer-dxm-solution`) | `references/dxm-template-reference.md` | Scaffolding a new DataMiner Extension Module or core Module — parameters, solution structure, installer, release-note config |
| Automation release/deployment | `references/automation-release-deployment.md` | Separating package creation, Catalog publication, deployment, rollback, and runtime verification |

### Official templates

Install the official template package:

```bash
dotnet new install Skyline.DataMiner.VisualStudioTemplates
```

The DxM/DcM, BPA, .NET tool, and NuGet package solution templates live in the **internal** template package. Install it when you need them:

```bash
dotnet new install Skyline.DataMiner.VisualStudioTemplates.Internal
```

Supported template short names:

| Project Type | Template Short Name | Template Package |
|--------------|---------------------|------------------|
| Connector solution | `dataminer-connector-solution` | `Skyline.DataMiner.VisualStudioTemplates` |
| Automation script project | `dataminer-automation-project` | `Skyline.DataMiner.VisualStudioTemplates` |
| Automation script library project | `dataminer-automation-library-project` | `Skyline.DataMiner.VisualStudioTemplates` |
| User-defined API project | `dataminer-user-defined-api-project` | `Skyline.DataMiner.VisualStudioTemplates` |
| GQI ad hoc data source project | `dataminer-gqi-ad-hoc-data-source-project` | `Skyline.DataMiner.VisualStudioTemplates` |
| Package project | `dataminer-package-project` | `Skyline.DataMiner.VisualStudioTemplates` |
| Test package project | `dataminer-test-package-project` | `Skyline.DataMiner.VisualStudioTemplates` |
| DxM/DcM solution | `dataminer-dxm-solution` | `Skyline.DataMiner.VisualStudioTemplates.Internal` |
| BPA solution | `dataminer-bpa-solution` | `Skyline.DataMiner.VisualStudioTemplates.Internal` |
| .NET tool project | `dataminer-dotnettool-project` | `Skyline.DataMiner.VisualStudioTemplates.Internal` |
| .NET tool solution | `dataminer-dotnettool-solution` | `Skyline.DataMiner.VisualStudioTemplates.Internal` |
| NuGet package project | `dataminer-nuget-project` | `Skyline.DataMiner.VisualStudioTemplates.Internal` |
| NuGet package solution | `dataminer-nuget-solution` | `Skyline.DataMiner.VisualStudioTemplates.Internal` |

### SDK-style project types

The Skyline DataMiner SDK currently supports these SDK-style project types:

- DataMiner Package Project
- DataMiner Ad Hoc Data Source Project
- DataMiner Automation Script Library Project
- DataMiner Automation Script Project
- DataMiner Test Package Project
- DataMiner User-Defined API Project

Automation projects use `Skyline.DataMiner.Dev.Automation`; connector projects use `Skyline.DataMiner.Dev.Protocol`. Do not copy connector-only `protocol.xml`, QAction, or `QAction_Helper` assumptions into Automation manifests or plans.

### Specialized Automation projects

Use the official specialized template when it exists; do not start with `dataminer-automation-project` and retrofit a
normal `Run(IEngine)` shape:

```bash
dotnet new dataminer-gqi-ad-hoc-data-source-project -n "<SourceName>" -o "<SourceName>"
dotnet new dataminer-user-defined-api-project -n "<ApiName>" -o "<ApiName>"
```

Immediately inspect the generated `.csproj`, XML, class/interface, and package versions. The observed GQI template
shape may lag the current Core GQI documentation or resemble the legacy API, so verify/adapt it against the selected
`Skyline.DataMiner.Core.GQI.Extensions` contract and record the result. The first release does not target the legacy
`Skyline.DataMiner.Analytics.GenericInterface`/`SLAnalyticsTypes` track.

No dedicated public SRM or Node Recovery scaffolder is assumed. For those contracts, use the version-matched SRM
Dev Pack/package and official role/configuration examples. If a complete template is not available, use the narrowest
documented project shape and record the missing signature/configuration as a verification gate; never invent a
callback or enum.

For all specialized projects, record `DataMinerType`, target framework, minimum DataMiner version, package/Dev Pack
versions, class/library identity, and deployment configuration. Build is necessary but does not prove host behavior.

### Connector rule

For new connectors, use the official connector template:

```bash
dotnet new dataminer-connector-solution --help
```

Do not create the connector solution structure by hand.

---

## Mandatory Validation Cadence

Use validators early and often. Do not wait until the end of the task.

| Development Stage | Required Validation Behavior |
|-------------------|------------------------------|
| After scaffolding a new connector | Run `dotnet build` on the solution immediately |
| After any `protocol.xml` edit | Run the fastest available XML gate immediately; do not continue editing blindly |
| After a meaningful XML milestone | Run the official `dataminer-validator validate protocol-solution` |
| After regenerating `QAction_Helper.cs` | Run `dotnet build` to ensure the helper and projects still compile |
| After any QAction or `.csproj` change | Run build and analyzer checks immediately |
| Before reporting completion | Run the official `dataminer-validator` again and require zero unresolved remarks |

### Validator command

For full CLI reference (current vs. legacy subcommand shape, options, JSON output, severity, suppression), see `dataminer-validation` → "Running the Validator". Always probe `dataminer-validator --help` before assuming the installed command shape.

### Compare command

For existing connector changes with possible shipped impact, use the official compare/Major Change Checker flow:

```bash
dataminer-validator compare protocol-solution --solution-path "<path>.sln" --output-directory "<dir>" --catalog-id "<guid>" --catalog-api-key "<key>"
```

(`--solution-path` also accepts `.slnx` — both formats are supported identically by the validator CLI.)

If the user is working in Visual Studio with DIS available, load `dataminer-dis`. DIS Comparer is highly advised for interactive comparison work, but it is not mandatory.

### Important validation rule

The official Skyline validator is the only authoritative validation tool. Use `dotnet build --warnaserror` for build-quality gates between development phases, but it is not a substitute for the official validator.

---

## Package And Assembly Rules

- Use **PackageReference** only. `packages.config` is not supported.
- Prefer Skyline Dev Packs and Skyline NuGets before custom or manual assembly handling.
- Add dependencies with `dotnet add package` or `<PackageReference>`, not by copying DLLs manually.
- Do not manually place assemblies into `C:\Skyline DataMiner\ProtocolScripts\DllImport`. Install the connector through a `.dmprotocol` or `.dmapp` package so DataMiner tracks and synchronizes the assemblies.
- For connector projects, prefer `Skyline.DataMiner.Dev.Protocol` over manual references to DataMiner assemblies.
- For automation projects, prefer `Skyline.DataMiner.Dev.Automation` over manual references to DataMiner assemblies.
- Before writing custom helper logic, consult `dataminer-connector-core/references/nuget-packages.md` for an official Skyline utility package.

---

## SDK Project Properties That Matter

For SDK-style package projects, these properties are especially important:

| Property | Purpose |
|----------|---------|
| `DataMinerType` | Declares the supported DataMiner project type |
| `GenerateDataMinerPackage` | Enables generation of the DataMiner package artifacts |
| `MinimumRequiredDmVersion` | Sets the minimum supported DataMiner version |
| `Version` | Package version |
| `VersionComment` | Catalog version description |
| `CatalogPublishKeyName` | Key name used for Catalog publishing |
| `CatalogDefaultDownloadKeyName` | Key name used for Catalog reference downloads |

If a task touches SDK-style package publishing or Catalog references, prefer configuring these properties instead of inventing custom build scripts.

---

## Official Commands By Job

| Need | Command |
|------|---------|
| Install official templates | `dotnet new install Skyline.DataMiner.VisualStudioTemplates` |
| Show template options | `dotnet new dataminer-connector-solution --help` |
| Build an SDK-style project | `dotnet build` |
| Publish an SDK-style package project | `dotnet publish -p:Version="..." -p:VersionComment="..."` |
| Validate a connector solution | `dataminer-validator validate protocol-solution --solution-path "<path>.sln or .slnx" --output-directory "<dir>" -of JSON` |
| Compare a connector to previous version | `dataminer-validator compare protocol-solution --solution-path "<path>.sln or .slnx" --output-directory "<dir>" --catalog-id "<guid>" --catalog-api-key "<key>"` |
| Create `.dmprotocol` package | `dataminer-package-create dmprotocol "<connector-dir>" --output "<output-dir>"` (classic connector solutions — detailed workflow + gotchas in `dataminer-dmprotocol-packaging`) |
| Create `.dmapp` package | `dataminer-package-create dmapp "<dir>" --type <automation|dashboard|protocolvisio|visio> --output "<output-dir>"` |
| Upload artifact to Catalog | `dataminer-catalog-upload --path-to-artifact "<artifact>"` |
| Deploy from Catalog | `dataminer-package-deploy from-catalog ...` |
| Deploy from volatile artifact | `dataminer-package-deploy from-volatile ...` |
| Run `.dmtest` test packages on a real QAOps DataMiner | `dataminer-qaops test-run-and-wait ...` (load `dataminer-qaops-test-runs` for the full reference) |

---

## Recommended Development Workflow

### New connector

1. Verify template availability.
2. Use `dataminer-connector-solution`.
3. Build immediately.
4. Edit `protocol.xml`.
5. Validate XML frequently.
6. Refresh `QAction_Helper.cs` only when existing source consumes generated members affected by the XML change.
7. Run the official validator before and after substantive QAction work.

### Existing connector feature or bug fix

1. Keep the solution buildable throughout the work.
2. After each meaningful XML change, validate instead of batching many schema edits together.
3. Prefer official Skyline packages, Dev Packs, and analyzers over manual workarounds.
4. Use the official validator again before final handoff.
5. For changes that may impact shipped behavior, compare against the previous version using the official compare flow. DIS Comparer is highly advised when the user is in Visual Studio.

### Packaging, publishing, and deployment

1. Prefer SDK-style `dotnet publish` when the project type supports it.
2. Otherwise use the official Packager, CatalogUpload, and DataMinerDeploy tools.
3. Do not replace these with zip scripts, ad hoc HTTP calls, or manual file copying.
4. Treat package creation, Catalog upload, deployment, and QAOps verification as separate gates. Record the artifact version/hash, target, command result, and rollback/verification evidence for each stage.
5. A successful upload is not deployment, and a successful deployment is not runtime verification. Route the next stage only after the previous stage's result and immutable artifact identity are recorded.

---

## Troubleshooting

### Build fails in a `CreateDataMinerPackages`/packaging target (`dotnet tool run ...` exits 1)

The repository uses a **local tool manifest** (`.config/dotnet-tools.json` at the repo root) for the packager (e.g. `skyline.dataminer.cicd.tools.packager`). A fresh checkout/machine has the manifest but not the tools — SDK package builds then fail inside the packaging target even though the code is fine. Fix:

```bash
dotnet tool restore
```

Run it from the repo root before the first build on any machine; check for a tool manifest whenever a DataMiner package build fails in a tool-invoking target (verified failure mode).

### Missing DataMiner templates

```bash
dotnet new uninstall
dotnet new install Skyline.DataMiner.VisualStudioTemplates
```

### .NET SDK not found

```bash
winget install Microsoft.DotNet.SDK.10
```

### Validator CLI command shape does not match the docs

See `dataminer-validation` → "Running the Validator" for legacy-vs-current subcommand handling. To upgrade an old install: `dotnet tool update -g Skyline.DataMiner.CICD.Tools.Validator`. With DIS available, DIS Validator/Comparer remain valid interactive fallbacks.

### SDK cannot be resolved from Visual Studio or NuGet restore

1. Verify `nuget.org` is configured:

```bash
dotnet nuget list source
```

2. If needed, add it:

```bash
dotnet nuget add source https://api.nuget.org/v3/index.json -n "nuget.org"
```

3. If the SDK still cannot be resolved, use the official downloader:

```bash
dotnet tool install --global Skyline.DataMiner.Sdk.Download
dataminer-sdk-download
```

### Catalog publishing appears to succeed but nothing shows up

- Verify `GenerateDataMinerPackage` is enabled for the SDK-style project.
- Verify the correct organization is selected in the Catalog.
- Verify `Version` and `VersionComment` are set as needed.

---

## Decision Rule

When deciding between an official Skyline tool and a manual approach, choose the official tool unless you can prove it does not exist or cannot be used.

That rule applies to:

- project scaffolding
- validation
- package creation
- Catalog upload
- deployment
- assembly references
- Dev Pack selection
- helper/utility package selection
