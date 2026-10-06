# Automation Template Reference

Complete reference for scaffolding new DataMiner Automation script solutions with the official `dataminer-automation-project` and `dataminer-automation-library-project` templates.

> **Parent**: `dataminer-sdk/SKILL.md` — SDK-first rule, validation cadence, packaging, troubleshooting.
> **Companion**: load `dataminer-automation-core` for scripting conventions and XML structure.

This reference covers normal Automation projects. For GQI ad hoc data sources and User-Defined APIs, use the
specialized templates below and load the matching feature skill. SRM and Node Recovery do not have a complete public
standalone scaffolder in this reference; verify the version-matched package/template/configuration before authoring.
For a package-backed solution that embeds an Automation project, use
`references/package-project-reference.md` for sibling-project wiring, the
package install hook, Catalog metadata, and package/deployment boundaries.

---

## Templates

| Template short name | Use For |
|---------------------|---------|
| `dataminer-automation-project` | A runnable automation script (`<Name>.cs` + `.csproj` + `.xml`). |
| `dataminer-automation-library-project` | A shared C# library referenced by automation scripts. |
| `dataminer-gqi-ad-hoc-data-source-project` | A compiled GQI ad hoc data source library; load `dataminer-gqi-ad-hoc-data-source`. |
| `dataminer-user-defined-api-project` | A User-Defined API script project; load `dataminer-user-defined-api`. |

---

## Template Parameters — `dataminer-automation-project`

| Option | Meaning |
|--------|---------|
| `-n, --name <name>` | Script/solution name. |
| `-o, --output <dir>` | Output directory. |
| `-auth, --param:author <author>` | Author string written into the files. |
| `-cdp, --create-dataminer-package` | `bool` (default `false`) — let this project generate a stand-alone `.dmapp` / publish to the Catalog. For multi-artifact packages, leave false and use a separate Package Project instead. |
| `-I, --IncludeGitHubWorkflow <Build\|Complete\|Demo\|None>` | Add a GitHub workflow: `Demo` (build/test/publish), `Build` (build/test), `Complete` (Skyline Quality Gate), or `None`. |

---

## Scaffold Commands

### Install / verify the templates

```bash
dotnet new list dataminer-automation-project           # verify installed
dotnet new install Skyline.DataMiner.VisualStudioTemplates   # install if missing
```

### Create a runnable automation script

```bash
# Step 1: Scaffold from template
dotnet new dataminer-automation-project \
  -n "My-Script" \
  -o "My-Script" \
  --param:author "ABC, Skyline"

# The template may emit warnings about 'Failed to evaluate bind symbol'
# when running outside Visual Studio. These are non-fatal - ignore stderr.

# Step 2: Create solution file (mandatory)
# The template skips this step outside VS, so always create it explicitly:
cd My-Script
dotnet new sln -n "My-Script" --format sln --force
dotnet sln "My-Script.sln" add "My-Script.csproj"

# Step 3: Verify build
dotnet build "My-Script.sln"
```

Add `--create-dataminer-package` to make the project emit a stand-alone `.dmapp`, and/or `-I Complete` to add the Skyline Quality-Gate GitHub workflow.

### Create a shared automation library

```bash
dotnet new dataminer-automation-library-project -n "My-Script.Library" -o "My-Script.Library"
```

Reference it from the script project with a normal `<ProjectReference>`.

### Create a GQI ad hoc data source

```bash
dotnet new dataminer-gqi-ad-hoc-data-source-project \
  -n "My-Gqi-Source" \
  -o "My-Gqi-Source"
```

Inspect the generated project before editing it. The source must compile against the selected Core GQI package and
implement the current `IGQIDataSource` contract, not the normal `Run(IEngine)` contract. The currently observed
template can resemble a legacy GQI shape; if it does, verify the installed template/package against the current
documentation and adapt deliberately. Do not silently target `SLAnalyticsTypes` in the Core GQI first release.

### Create a User-Defined API project

```bash
dotnet new dataminer-user-defined-api-project \
  -n "My-Api" \
  -o "My-Api"
```

Inspect the generated entry point and package versions, then implement the version-supported
`AutomationEntryPointType.Types.OnApiTrigger` contract. Keep API definitions, routes, tokens, endpoint/DxM settings,
and secrets in the documented operational configuration; do not invent a repository manifest or commit token values.

### SRM and Node Recovery

There is no assumed public standalone template here. Use the version-matched SRM Dev Pack/framework or Node Recovery
configuration and examples as the authority. A generic Automation project is only a fallback after the specialized
shape has been verified. Do not invent SRM role callback signatures or Node Recovery enum values.

---

## Scaffolded Solution Structure

```
<Solution>.slnx
global.json
Directory.Build.props
Internal/Code Analysis/{qaction-debug.ruleset, qaction-release.ruleset, stylecop.json}
.github/workflows/<workflow>.yml            # if a workflow was selected
<Name>/
  ├─ <Name>.cs                              # public class Script : Run(IEngine)
  ├─ <Name>.csproj                          # Sdk="Skyline.DataMiner.Sdk"
  ├─ <Name>.xml                             # DMSScript definition
  ├─ GettingStarted.md
  └─ CatalogInformation/{README.md, manifest.yml}
```

The three main files share the script name: `<Name>.cs`, `<Name>.csproj`, `<Name>.xml`.

---

## SDK-style csproj

```xml
<Project Sdk="Skyline.DataMiner.Sdk">
	<PropertyGroup>
		<TargetFramework>net48</TargetFramework>
		<GenerateDocumentationFile>true</GenerateDocumentationFile>
	</PropertyGroup>
	<PropertyGroup>
		<DataMinerType>AutomationScript</DataMinerType>
		<GenerateDataMinerPackage>False</GenerateDataMinerPackage>
		<MinimumRequiredDmVersion>10.4.0.0 - 14003</MinimumRequiredDmVersion>
		<Version>1.0.0</Version>
		<VersionComment>Initial Version</VersionComment>
	</PropertyGroup>
	<ItemGroup>
		<PackageReference Include="Skyline.DataMiner.CICD.CSharpAnalysis.Analyzer" Version="2.1.2">
			<IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
		</PackageReference>
		<PackageReference Include="Skyline.DataMiner.Dev.Automation" Version="10.4.0.24" />
		<PackageReference Include="Skyline.DataMiner.Utils.SecureCoding.Analyzers" Version="2.2.3">
			<IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
		</PackageReference>
	</ItemGroup>
</Project>
```

- `DataMinerType=AutomationScript`, target `net48`, Dev Pack `Skyline.DataMiner.Dev.Automation`, Skyline analyzers included.
- Set `GenerateDataMinerPackage=True` (or scaffold with `-cdp`) when the project should produce a `.dmapp`.
- Specialized templates may use a different `DataMinerType`, package, or identity. Copy the generated values only
  after checking the feature contract and selected runtime baseline.

---

## Catalog Metadata — `CatalogInformation/manifest.yml`

```yaml
type: Automation
id: 83b3eb7d-2cc4-4dd5-8223-35fc126ab6b4    # stable GUID for the Catalog item

title: Set Parameter

source_code_url: https://github.com/SkylineCommunications/SLC-AS-SetParameter

owners:
  - name: Jan Staelens
  - name: Michiel Oda

# Optional. Max 5 tags, <=50 chars each, no newlines, no leading/trailing spaces.
tags:
  - GQI-Supported
```

- `type: Automation` and a stable `id` GUID identify the Catalog item — do not change the `id` across versions.
- `CatalogInformation/README.md` is the Catalog description page.
- Version/changelog live in the `.csproj` (`Version`, `VersionComment`), not in the manifest.

---

## Packaging

Use the official Packager (see parent `dataminer-sdk` skill) rather than zipping by hand:

```bash
dataminer-package-create dmapp "<solution-or-project-dir>" --type automation --output "<output-dir>"
```

Or enable `GenerateDataMinerPackage=True` / scaffold with `--create-dataminer-package` and use `dotnet publish`.

---

## Constraints

- **Prefer the official template** over manual setup (SDK-first rule — see parent skill).
- There is **no** automation validator CLI — quality gate is `dotnet build` + Skyline analyzers (+ optional DIS).
- Solution file is `.slnx` (XML solution format). `global.json` pins the SDK; `Directory.Build.props` and `Internal/Code Analysis/*` carry shared build + analyzer settings.
