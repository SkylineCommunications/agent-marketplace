# DataMiner Test Package Prerequisites

Use this reference when a QAOps integration test requires DataMiner content to be present before the tests run, such as a connector, Automation script, Low-Code App, dashboard, or another package artifact.

DataMiner Test Packages can include prerequisite content similarly to standard DataMiner installation package projects. Consult the official SDK package project documentation before changing package project structure:

```text
https://docs.dataminer.services/develop/CICD/Skyline%20DataMiner%20Software%20Development%20Kit/skyline_dataminer_sdk_dataminer_package_project.html
```

## Default Same-Solution Content

By default, a DataMiner Test Package behaves similarly to a DataMiner package project and includes Automation scripts and other DataMiner-type projects in the same solution.

Agent procedure:

1. Identify the DataMiner projects in the solution.
2. Confirm which projects are automatically included by the Test Package build.
3. Build the Test Package project.
4. Inspect the generated package output to verify the required content is present.
5. Only add explicit package content when the default inclusion does not cover the prerequisite.

## Classic (Legacy) Connector Solutions Are NOT Auto-Included

The default same-solution inclusion only covers **SDK-style** DataMiner projects (`<Project Sdk="Skyline.DataMiner.Sdk">`). A **classic / legacy connector solution** — a repo whose root is a `protocol.xml` with `QAction_*.csproj` projects (the DIS layout) — is **not** picked up by the Test Package build. If the connector under test lives in such a solution, its element will not exist on the QAOps DataMiner and every test that creates/reads it fails.

Harvest the connector into a `.dmprotocol` yourself and add it as package content. Full tool detail (install, CLI, MSBuild wiring, the trailing-backslash `--output` gotcha, verification) is in **`dataminer-dmprotocol-packaging`**. The Test-Package-specific wiring:

1. **Generate the `.dmprotocol`** with `Skyline.DataMiner.CICD.Tools.Packager` (`dataminer-package-create dmprotocol`) as a pre-build step of the Test Package project, writing it into a `*.generated` dependency folder (e.g. `TestPackageContent/Dependencies/connector.generated/`). Prefer a repo-local tool manifest (`.config/dotnet-tools.json`) + `dotnet tool restore` so CI is deterministic.
2. **Deploy it before the tests run** from `TestPackageContent/TestPackagePipeline/1.TestPackageSetup.ps1` with the DataMinerDeploy CLI. The deploy command **requires the target DataMiner location and credentials** — `dataminer-package-deploy from-artifact --path-to-artifact "<...>.dmprotocol"` **alone fails with exit code 1** (`dataminer-package-deploy returned exit code 1`). Pass `--dm-server-location 'localhost'` plus the `WinEncryptedKeys` credentials the QAOps runner provides:

   ```powershell
   # Retrieve the QAOps DataMiner credentials (present on the QAOps runner).
   $u = (& WinEncryptedKeys --name 'QAOpsDataMinerUser'     2>&1 | ? { ([string]$_).Trim() } | Select-Object -Last 1).Trim()
   $p = (& WinEncryptedKeys --name 'QAOpsDataMinerPassword' 2>&1 | ? { ([string]$_).Trim() } | Select-Object -Last 1).Trim()

   $dmprotocol = Get-ChildItem -Path (Join-Path $PathToTestPackageContent 'Dependencies\connector.generated') -Filter '*.dmprotocol' | Select-Object -First 1
   if (-not $dmprotocol) { throw "No .dmprotocol harvested — the Test Package build did not produce the connector package." }

   & dataminer-package-deploy from-artifact --path-to-artifact $dmprotocol.FullName --dm-server-location 'localhost' --dm-user $u --dm-password $p --deploy-timeout-in-seconds 3600
   if ($LASTEXITCODE -ne 0) { throw "dataminer-package-deploy returned exit code $LASTEXITCODE while deploying '$($dmprotocol.Name)'." }
   ```

   (The same `WinEncryptedKeys` `QAOpsDataMinerUser`/`QAOpsDataMinerPassword` credentials are used everywhere the setup script needs to reach the localhost DataMiner — see `references/migrating-existing-tests.md`.)
3. **Verify** the `.dmprotocol` is actually inside the built `.dmtest` (under `AppInstallContent\DmTest\Dependencies\...`) — extract and check, the same way you verify the harvested test assembly.

This is the only way the classic connector reaches the clean DaaS. SDK-style connectors in the same solution do not need this — they install via the default same-solution inclusion.

## Name-Based Fixture Elements via DataAPI (narrow alternative)

When a test needs a *name-addressable, dynamic* element (not a real fixed-PID connector), the DataMiner **DataAPI** feature can create one by HTTP PUT to `http://localhost:34567/api/data/parameters` — no `protocol.xml` and no Catalog connector required. This fits **only** when the logic under test resolves the remote element's parameters/columns **by name** (e.g. a manager that links `<id>_Runs` / `<id>_Data_<n>` tables by name). For ordinary fixed-PID connectors it does not apply — install the `.dmprotocol` and use IDms instead. See **`dataminer-dataapi`** for the body shape, async materialization, and the fixed-PID caveat; confirm the DataAPI feature is present on the target DaaS before depending on it.

## Runtime Prerequisites: Mirror the Solution's Own Installer

A clean DaaS DataMiner has **only** what the Test Package installs — none of the SDM registration, connectors, elements, DOM modules, Low-Code Apps, or demo data the solution normally provisions. Tests (or the product code they exercise) fail on the first missing runtime prerequisite, then the next, one QAOps run at a time. Each speculative run costs ≈5–55 min plus a token use.

**Discover the full set up front by reading the solution's own DataMiner `Package` project** (`<DataMinerType>Package</DataMinerType>`, e.g. `SLC-S-<Name>`/`*Installer.cs`/`SolutionInstaller.cs`). Its install script enumerates every setup step the product needs — SDM/Categories checks, connector + element creation, DOM import from `SetupContent/DOM`, Low-Code App install, demo data, theme merge, view creation. Replicate the same steps (or include the same `CatalogReferences.xml` + `SetupContent`) in the Test Package, and run that setup from the Test Package **InstallScript** (it runs only during QAOps install — no runtime gate needed).

Common cascade (measured order in a real migration):

| Install/`Fail:` message contains | Missing prerequisite | Fix |
|---|---|---|
| `No settings were found for a module with ID '(slc)standard_data_model'` | SDM registration | Add **Standard Data Model Registration** (`52173e49-9185-4772-9b60-c186ee365a81`) to `CatalogReferences.xml` |
| `ElementNotFoundException: <X> Lock Manager` (or any element the solution creates) | Connector + element the installer creates | Add the connector Catalog item (e.g. Skyline Lock Manager `5b423d7b-...`) and create the element in the InstallScript |
| `No settings were found for a module with ID '(slc)<module>'` | Solution DOM modules not imported | Import them from the package's `SetupContent/DOM` in the InstallScript (inline the logic — do **not** call the solution's `DOM ImportExport` script as a subscript; it fails to compile at install time) |

Add only the minimal prerequisites the tests actually need (SDM + the specific connector), not the entire solution app set — copying solution Catalog app packages whose install scripts depend on each other can fail during `InstallingDependencies` ordering. The InstallScript's referenced assemblies must all be harvested into `Scripts\InstallDependencies` (verify before submitting). Full migration detail: `references/migrating-existing-tests.md`.

### Install order, internal IDs, and the silent stale-package trap

Three Catalog facts each cost a wasted QAOps run/build in a real migration (details in `references/migrating-existing-tests.md` Section 3, lightest-path):

- **Install order = embedded-`.dmapp` filename order.** The runtime AppInstaller installs the package's embedded dependency `.dmapp`s in **alphabetical filename order**, and the SDK names each from the `<Name>` in `CatalogReferences.xml`. When one prerequisite requires another (SDM before Categories; both before the solution package, whose installer aborts with `This solution requires SDM/Categories to function. … deploy the '…' package`), prefix the `<Name>` with `000`/`001`/… to force the order. Verify by extracting the `.dmtest` and listing `AppInstallContent\AppPackages\*.dmapp` sorted by name.
- **Public manifest IDs may be CI-overwritten placeholders.** A solution repo's `CatalogInformation/manifest.yml` `id:` can be a placeholder the CI workflow replaces before publishing; referencing it fails with `Version could not be resolved` or `404 … Catalog … was not found`. Get the real published ID with `gh variable list --repo <org>/<repo> --json name,value` (`CATALOGIDENTIFIER*`). The internal package may belong to a different org than your build key (see `migrating-existing-tests.md` Section 8).
- **A `.dmtest` is emitted even when a Catalog download fails.** The SDK logs `error : Failed to download catalog item …` but still prints `Successfully created package '….dmtest'`, leaving a stale/incomplete file. Grep the build output for `error :` / `Failed to download catalog item` and treat any as a hard failure — never select the artifact by existence/timestamp alone.

## Catalog Items

If a test requires an element using a connector that is outside the current solution, add the connector from the DataMiner Catalog.

**Build-time token required.** Resolving `CatalogReferences.xml` entries during the Test Package build requires a DataMiner Catalog **organization key** stored as the `skyline:sdk:dataminertoken` user secret of the Test Package project. Without it the build fails with an error naming that key. Provision it through the user-secrets file flow in the `dataminer-qaops-integration-testing` SKILL ("Catalog Key via User Secrets") **before** adding the Catalog reference. Never ask for the key in chat, and never rely on environment variables set during the session — the running CLI cannot see them.

### Finding the Catalog ID

`https://catalog.dataminer.services` is a JavaScript SPA — fetching a page directly returns an empty HTML shell with no data. Instead, web-search `site:catalog.dataminer.services "<item name>"` and take the GUID from the result URL (`https://catalog.dataminer.services/details/<catalog-id>`).

Known IDs (verified — reuse instead of searching):

| Catalog item | Catalog ID |
|--------------|------------|
| Microsoft Platform (connector) | `4abcf220-c001-4ffd-bab8-559dee47088f` |
| Standard Data Model Registration | `52173e49-9185-4772-9b60-c186ee365a81` |
| Categories | `c9666f3a-be26-42fd-83f2-6ee7fab4f11e` |
| Skyline Lock Manager (connector) | `5b423d7b-b6eb-4d44-ac26-418927b33735` |

Procedure:

1. Confirm the `skyline:sdk:dataminertoken` user secret is present (`dotnet user-secrets list --project ...` — check key presence only, never echo the value).
2. Find the Catalog ID (known-IDs table above, otherwise the `site:` web search).
3. Identify the required version (e.g. from the protocol.xml the user supplied, or ask).
4. Add the Catalog item to `PackageContent/CatalogReferences.xml` of the Test Package.
5. Build the package and verify the connector is present inside the generated `.dmtest`.

Do not guess Catalog IDs. If the correct item cannot be determined from the catalog search and repository context, ask the user to confirm the Catalog item.

## Low-Code Apps and Dashboards

Low-Code Apps and dashboards can be imported from another DataMiner system, typically the DataMiner where the user is editing them.

Agent procedure:

1. Ask the user for the DataMiner IP/hostname if it is not known.
2. Ask for authentication details or an already-valid connection flow if needed.
3. Prefer `Skyline.DataMiner.Core.ArtifactDownloader` for the export.
4. Save the downloaded artifact as package content.
5. If automated access is not possible, ask the user to import the Low-Code App or dashboard manually.

Do not store user credentials in source code, package content, logs, or memory.

## Preferred Library: Skyline.DataMiner.Core.ArtifactDownloader

`Skyline.DataMiner.Core.ArtifactDownloader` is a .NET library for downloading Low-Code Apps and dashboards from DataMiner systems. It can return raw bytes or save artifacts as `.zip` files.

Install:

```bash
dotnet add package Skyline.DataMiner.Core.ArtifactDownloader
```

Create a DataMiner downloader:

```csharp
using System.Net.Http;
using Skyline.ArtifactDownloader;
using Skyline.DataMiner.Net;

var slnetConnection = ConnectionSettings.GetConnection("your-dataminer-host");
var httpClient = new HttpClient();

var dataMinerService = Downloader.FromDataMiner(slnetConnection, httpClient);
```

Download a Low-Code App:

```csharp
using Skyline.ArtifactDownloader.Identifiers;

var appId = new LowCodeAppIdentifier("AppName", "1.0.0");
string savePath = @"C:\Downloads";

string filePath = await dataMinerService.DownloadLowCodeAppAsync(appId, savePath);
Console.WriteLine($"Low-Code App downloaded to: {filePath}");
```

Download a dashboard:

```csharp
using Skyline.ArtifactDownloader.Identifiers;

var dashboardId = new DashboardIdentifier("DashboardName", "2.1.0");
string dashboardPath = @"C:\Downloads";

string filePath = await dataMinerService.DownloadDashboardAsync(dashboardId, dashboardPath);
Console.WriteLine($"Dashboard downloaded to: {filePath}");
```

Relevant APIs:

```csharp
Task<byte[]> DownloadLowCodeAppAsync(LowCodeAppIdentifier id);
Task<string> DownloadLowCodeAppAsync(LowCodeAppIdentifier id, string directoryPath);
Task<byte[]> DownloadDashboardAsync(DashboardIdentifier id);
Task<string> DownloadDashboardAsync(DashboardIdentifier id, string directoryPath);
```

Expected exceptions include `DataMinerException`, `ArtifactDownloadException`, `ArgumentNullException`, and `ArgumentException`. Do not swallow these exceptions silently; surface them so the user can fix connection, identifier, or permission issues.

## Fallback Web Calls

Use direct web calls only when `Skyline.DataMiner.Core.ArtifactDownloader` cannot be used or when low-level API control is required. Authenticate to DataMiner first and use the returned `connection` value. For authentication flow details, load `dataminer-api`.

### Export a Low-Code App

POST:

```text
https://<dma-host>/API/v1/Internal.asmx/ExportApplication
```

Body:

```json
{
  "connection": "<connectionID>",
  "applicationID": "<applicationID>",
  "options": {
    "version": 0
  }
}
```

The response returns a token. Download the package with:

```text
https://<dma-host>/API/v1/GetSecureFile.aspx?token=<token>
```

`version: 0` means the latest public version.

### Export Dashboards

POST:

```text
https://<dma-host>/API/v1/Dashboards.asmx/ExportDashboards
```

Body:

```json
{
  "connection": "<connectionID>",
  "dashboards": [
    { "Folder": "", "Name": "My dashboard" },
    { "Folder": "Folder\\SubFolder", "Name": "My other dashboard" }
  ],
  "options": {}
}
```

The response returns a token. Download the package with:

```text
https://<dma-host>/API/v1/GetSecureFile.aspx?token=<token>
```

## Manual Import Fallback

If the agent cannot access the source DataMiner, cannot authenticate, or cannot confidently identify the requested Low-Code App/dashboard, ask the user to import the artifact manually into the Test Package. Continue only after the user confirms the artifact is available in the repository/package content.
