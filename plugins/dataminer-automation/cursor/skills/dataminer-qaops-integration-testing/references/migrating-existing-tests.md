# Migrating an Existing Test Project to QAOps

Use this reference when the solution **already has** an MSTest(V2)/Playwright integration test project (e.g. `RT_*_Playwright`, a shared `*.Tests.Common` library) that connects to a DataMiner over SLNet and/or drives the web UI with Playwright, and the user wants those tests to run on QAOps **with minimal source changes**.

This is a different task from authoring tests from scratch. Most of the existing test code stays exactly as-is. The work is: (1) gate credentials behind a QAOps check, (2) wire/harvest the existing test assembly into a Test Package, and (3) replicate on the clean DaaS the runtime setup that the solution's own install package normally performs. Steps 1–3 below are ordered by where agents historically got stuck.

> Read this whole file before the first build. The single biggest time sink in a real migration was discovering runtime prerequisites one QAOps run at a time (≈5–55 min + a token use each). Mirroring the solution's own installer up front (Section 3) avoids that.

## 1. Credential Gating (behind a QAOps-bridge check)

Existing test projects load credentials from user-secrets / env vars / `CredentialCache` and connect to a configurable host. On a QAOps bridge the encrypted keys `QAOpsDataMinerUser` / `QAOpsDataMinerPassword` exist and the host is `localhost`. Gate the override so **local behavior is completely untouched** when not on QAOps:

- Detect QAOps by probing the encrypted **`BridgeId`** key. If it is present and non-empty, you are on a QAOps bridge.
- Only then override the credentials with `QAOpsDataMinerUser` / `QAOpsDataMinerPassword` and point the host at `localhost`.
- If `BridgeId` is absent, return early and leave **all** existing credential/host logic exactly as it was.

`Keys` comes from `Skyline.DataMiner.CICD.Tools.WinEncryptedKeys.Lib` (2.1.0). The public API is `TryRetrieveKey(string keyName, out string value)`, `RetrieveKey(string)`, and `SetKey(string, string)` — there is **no** `TryGetValue`. (If a user calls it `Keys.TryGetValue`, they mean `TryRetrieveKey`.)

```csharp
using Skyline.DataMiner.CICD.Tools.WinEncryptedKeys.Lib;

// Call this first in the existing config loader; return early when it returns true.
private bool TryLoadQaOpsBridgeCredentials()
{
    if (!Keys.TryRetrieveKey("BridgeId", out string bridgeId) || string.IsNullOrWhiteSpace(bridgeId))
    {
        return false; // not on QAOps — caller keeps its existing credential/host behavior
    }

    if (!Keys.TryRetrieveKey("QAOpsDataMinerUser", out string user) || string.IsNullOrWhiteSpace(user))
        throw new InvalidOperationException("Could not retrieve the QAOps DataMiner username.");
    if (!Keys.TryRetrieveKey("QAOpsDataMinerPassword", out string p) || string.IsNullOrWhiteSpace(p))
        throw new InvalidOperationException("Could not retrieve the QAOps DataMiner password.");

    UserName = user;
    Password = p;
    BaseUrl  = "localhost"; // SLNet host (see Section 7 for the Playwright web URL)
    return true;
}
```

Add the package via Central Package Management (see the NU1008 gotcha in Section 6).

Expose a single `IsQaOps` flag from this same loader (set it `true` in the `BridgeId` branch). Reuse it for every QAOps-only test divergence (Section 9) so all bridge-specific behavior sits behind one switch.

### Reusing the solution's existing offline/in-memory fallback (and the constructor-guard trap)

Some solutions already have an "am I running on a real DataMiner agent?" branch with an in-memory/offline fallback (e.g. a `LockManager` that keeps locks in memory when `Process.GetCurrentProcess().ProcessName` is not `SLScripting`/`SLAutomation`). On QAOps the test runner *is* such a non-agent process, so that fallback may already do the right thing — forcing it on for QAOps can be a far smaller change than provisioning the real runtime element. Add an internal `UseInMemory…ForCurrentProcess()` switch that the `BridgeId` gate flips.

**Guard the constructor/lazy-init, not just the method bodies — this cost a wasted scoped run.** A real failure: the fix flipped a flag the lock *methods* checked, but the `LockManager` **constructor** still ran `new SkylineLockManagerConnectorApi(connection, "MOP Lock Manager", …)`, which calls `Dms.GetElement("MOP Lock Manager")` and threw `ElementNotFoundException` before any fallback branch executed. When gating an offline path, instantiate the real client **only** in the not-using-fallback branch (move it out of the constructor or guard it there), or the connector lookup fails before your flag is ever read.

## 2. Put QAOps-only Environment Setup in the Test Package InstallScript — NOT in Test Source

The strongest lesson of the migration: prefer the **Test Package's `InstallScript`** (`<TestPackageProject>.cs`, the `[AutomationEntryPoint(... InstallAppPackage)]` method) for any environment setup the tests need on a clean system. That entry point runs **only** during QAOps package installation, so it is inherently QAOps-only and needs no runtime `if (IsQaOps)` gate. This keeps the shared test assembly free of DataMiner DOM/SLNet setup code (which otherwise complicates local builds and namespace resolution).

```csharp
[AutomationEntryPoint(AutomationEntryPointType.Types.InstallAppPackage)]
public void Install(IEngine engine, AppInstallContext context)
{
    var installer = new AppInstaller(Engine.SLNetRaw, context);
    installer.InstallDefaultContent();

    // QAOps-only environment setup — runs only here, during package install:
    ImportDom(engine, installer.GetSetupContentDirectory()); // import solution DOM modules
    CreateLockManagerElementIfNeeded(engine);                // create runtime element fixtures
}
```

The InstallScript can reference `Skyline.DataMiner.Core.DataMinerSystem.Automation`/`.Common` and `Skyline.DataMiner.Utils.DOM` to do `IDms`/DOM work — but see the dependency-harvesting rule in Section 5.

## 3. The Runtime-Prerequisites Cascade — Mirror the Solution's Own Installer

A fresh DaaS is empty: it has none of the modules, connectors, elements, apps, or demo data the solution normally installs. Each QAOps run fails on the **next** missing piece. Measured order from a real MediaOps migration:

| `Fail:` / install message contains | Missing prerequisite | Fix |
|---|---|---|
| `No settings were found for a module with ID '(slc)standard_data_model'` | SDM (Standard Data Model) registration | Add **Standard Data Model Registration** to `PackageContent/CatalogReferences.xml` (Catalog ID `52173e49-9185-4772-9b60-c186ee365a81`) |
| `ElementNotFoundException: <X> Lock Manager` (or any element the solution creates) | A connector + element the solution's installer creates at install time | Add the connector Catalog item (e.g. Skyline Lock Manager `5b423d7b-b6eb-4d44-ac26-418927b33735`) and create the element in the InstallScript |
| `No settings were found for a module with ID '(slc)<module>'` (e.g. `(slc)resource_studio`) | Solution DOM modules not imported | Import the DOM modules from the package's `SetupContent/DOM` in the InstallScript (Section 4) |
| Playwright `net::ERR_CONNECTION_REFUSED at http://localhost/app/...` | Browser pointed at plain-HTTP localhost | Use `https://localhost` for the browser, `IgnoreHTTPSErrors`, bare `localhost` for SLNet (Section 7) |

**Do not discover these one run at a time.** Up front, open the solution's own DataMiner **Package** project (`<DataMinerType>Package</DataMinerType>`, e.g. `SLC-S-<Name>`/`*Installer.cs`/`SolutionInstaller.cs`) and enumerate every step its install script performs — SDM/Categories checks, connector + element creation, DOM import, Low-Code App install, demo data, theme merge, view creation. Replicate the **same** steps (or include the same Catalog/`SetupContent`) in the Test Package. One read of the installer typically replaces several failed QAOps runs.

`SetupContent` and `PackageContent` (`CatalogReferences.xml`, `LowCodeApps`, `Dashboards`) of the solution package can usually be **copied verbatim** into the Test Package; the SDK packages them by convention without extra `.csproj` items. Avoid copying solution Catalog **app packages** whose install scripts have ordering dependencies on each other if they cause `InstallingDependencies` ordering failures — add only the minimal prerequisites the tests actually need (SDM + the specific connector), not the entire solution app set.

### Prefer installing the real solution package over piecemeal replication (when tests are deep)

Piecemeal replication (SDM → connector → DOM → DevPacks → Categories → ResourceStudio setup → Scheduling setup → …) works for shallow tests but becomes a long, fragile cascade for tests that exercise the **full** solution UI (job creation, parameter linking, config defaults). Each new layer is another QAOps run, and some layers are **actively harmful** (verified: deploying the solution's MediaOps DevPacks — alpha-versioned — into `ProtocolScripts\DllImport\SolutionLibraries` from the Test Package InstallScript did **not** fix the dependent script's `Errors in CSharp script code` and **regressed** the one Playwright test that had been passing — a version conflict with the runtime). Lessons:

- **Do not push DevPacks / alpha solution libraries into `SolutionLibraries` piecemeal.** DevPacks are normally installed/version-managed by the solution's own package and Catalog dependencies (e.g. the `Categories` package installs the Categories DevPack). Re-uploading them from a Test Package risks version conflicts that break working API calls.
- When tests need the solution **fully bootstrapped** (not just one connector + DOM), the robust path is to **install the solution's own deployment package as a prerequisite** so the real `SolutionInstaller`/`RegressionTestInstaller` runs and configures everything correctly — rather than re-implementing that installer step-by-step. Add the solution package (or its existing regression package) via `CatalogReferences.xml`, confirming the Catalog key's organization owns it (Section 8).
- Validate scope expansion the same way you debug the cascade: a **scoped single-test** run first, then the **full** suite. A green install + one full end-to-end test proves the framework; getting *every* deep UI test green is a separate, larger effort that depends on full-environment bootstrap, not on the QAOps wiring.

### Bundle the solution's own deployment package (.dmapp) and deploy it — the validated full-bootstrap path

When the tests need the solution **fully bootstrapped** (deep UI: job creation, parameter linking, config defaults), the clean, validated approach is to install the solution's own deployment package (`.dmapp`, built from a same-solution `<DataMinerType>Package</DataMinerType>` project) so its real installer runs every step. This **replaced** a piecemeal InstallScript and flipped the suite from mostly-failing-on-missing-prerequisites to mostly-passing (verified: the most complex job/node/config test went from Fail to Ok once the real solution was deployed).

**You cannot include a Package project inside a TestPackage directly:**

- Via `PackageContent/ProjectReferences.xml`: the SDK errors `Including a package project inside another package project is not supported`.
- Via a plain csproj `<ProjectReference>` (even `ReferenceOutputAssembly="false"`): the install-script assembler errors `Missing 'libraryName' param on exe N (project '<Pkg>')`. **Root cause** (verified in SDK source `AutomationScriptBuilder.FindExeFromOtherScript`): the DataMiner SDK reinterprets every `<ProjectReference>` as a DataMiner script/library reference and tries to wire the referenced project's script `<Exe>` — a Package's install-script exe has no `libraryName` (only Automation Script **Library** projects do), so it throws. It is not a plain .NET build reference.

**Clean pattern (each project owns what it knows):**

1. In the **source package project** (the one that builds the `.dmapp`), add a post-build target that copies its own `.dmapp` into the Test Package's `TestPackageContent/Dependencies/`. The source project knows its own output reliably (`$(OutDir)DataMinerBuild\*.dmapp`), avoiding fragile cross-project bin-path globbing. Gate it on the Test Package existing:

   ```xml
   <Target Name="CopyDmappToTestPackage" AfterTargets="DmappCreation"
           Condition="Exists('$(MSBuildThisFileDirectory)..\MyTests.QAOps\MyTests.QAOps.csproj')">
     <ItemGroup><_Dmapp Include="$(OutDir)DataMinerBuild\*.dmapp" /></ItemGroup>
     <MakeDir Directories="$(MSBuildThisFileDirectory)..\MyTests.QAOps\TestPackageContent\Dependencies" />
     <Copy SourceFiles="@(_Dmapp)" DestinationFolder="$(MSBuildThisFileDirectory)..\MyTests.QAOps\TestPackageContent\Dependencies" SkipUnchangedFiles="true" />
   </Target>
   ```

2. In the **Test Package project**, force the source package to build first with an `<MSBuild>` task (NOT a ProjectReference) in a target `BeforeTargets="DmappCreation"`, so the copy lands before the `.dmtest` is packaged:

   ```xml
   <Target Name="BuildSolutionPackageDependency" BeforeTargets="DmappCreation">
     <MSBuild Projects="$(MSBuildThisFileDirectory)..\MySolution\MySolution.csproj" Targets="Build" Properties="Configuration=$(Configuration)" />
     <ItemGroup><_Bundled Include="$(MSBuildThisFileDirectory)TestPackageContent\Dependencies\MySolution.*.dmapp" /></ItemGroup>
     <Error Condition="'@(_Bundled)' == ''" Text="Solution .dmapp was not copied into TestPackageContent/Dependencies." />
   </Target>
   ```

   The SDK packages `TestPackageContent/Dependencies/` into the `.dmtest` at `AppInstallContent\DmTest\Dependencies\`, reachable from pipeline scripts via `$PathToTestPackageContent\Dependencies`. gitignore the build-copied `.dmapp`.

3. **Deploy the bundled `.dmapp` from the pipeline setup step**, before the test-execution step. Use the existing template `1.TestPackageSetup.ps1` slot — do **not** add a second `1.*` script (the QAOps Bridge sorts by leading number; two `1.` scripts collide). Deploy with the `dataminer-package-deploy` global tool (`Skyline.DataMiner.CICD.Tools.DataMinerDeploy`), reading the QAOps DataMiner credentials with the `WinEncryptedKeys` CLI (`WinEncryptedKeys --name <key>` outputs the value when `--value` is omitted):

   ```powershell
   dotnet tool update Skyline.DataMiner.CICD.Tools.DataMinerDeploy --global --add-source https://api.nuget.org/v3/index.json
   dotnet tool update Skyline.DataMiner.CICD.Tools.WinEncryptedKeys --global --add-source https://api.nuget.org/v3/index.json
   $env:PATH += ";$(Join-Path $env:USERPROFILE '.dotnet\tools')"
   $dmapp = Get-ChildItem (Join-Path $PathToTestPackageContent 'Dependencies') -Filter 'MySolution.*.dmapp' | Select-Object -First 1
   $u = (& WinEncryptedKeys --name 'QAOpsDataMinerUser'     2>&1 | ? { ([string]$_).Trim() } | Select-Object -Last 1).Trim()
   $p = (& WinEncryptedKeys --name 'QAOpsDataMinerPassword' 2>&1 | ? { ([string]$_).Trim() } | Select-Object -Last 1).Trim()
   & dataminer-package-deploy from-artifact --path-to-artifact $dmapp.FullName --dm-server-location 'localhost' --dm-user $u --dm-password $p --deploy-timeout-in-seconds 3600
   if ($LASTEXITCODE -ne 0) { throw "Deploy failed ($LASTEXITCODE)." }
   ```

4. **External Catalog prerequisites the solution itself requires** (e.g. Standard Data Model Registration, Categories) go in `PackageContent/CatalogReferences.xml` so they install during the `.dmtest`'s `InstallingDependencies` phase (before the pipeline deploys the solution). **Control their order with numeric `displayName` prefixes** (`000`, `001`, …) — verified mechanism: SDM (`000`) must install before Categories (`001`, which requires SDM 2.0.0+). The full chain becomes: InstallingDependencies installs `000`→`001` → `1.TestPackageSetup.ps1` deploys the solution `.dmapp` (its `SolutionInstaller` then does DOM, elements, DevPacks, ResourceStudio/Scheduling setup, RegisterSolution, …) → `2.*` runs the tests.

5. **Strip the piecemeal InstallScript** once the real solution package is deployed — it does DOM import, element creation, DevPacks, app setup itself. This also shrinks the InstallScript's harvested dependency surface (removing the `Scripts\InstallDependencies` `CS0006` risk class entirely).

6. **Result interpretation:** deploying the real solution flips failures from *missing-prerequisite* (`Errors in CSharp script code`, missing DOM modules/elements, UI flows never reached) to *test-level* issues (loader-wait timing assertions, specific element selectors) that reach deep UI states. The latter are test-stabilization concerns for the solution team, **not** QAOps-migration defects — the migration is done once install + deploy are green and tests execute against the fully bootstrapped system.

### Lightest path: CatalogReference the published solution package directly

If the solution's deployment package is **itself published to the Catalog** (and the build-time org key resolves it), you usually do **not** need to build, bundle, and pipeline-deploy a `.dmapp` at all. Add the solution package and its own prerequisites to `PackageContent/CatalogReferences.xml`; they install during the `.dmtest`'s **InstallingDependencies** phase before the tests run — no `1.TestPackageSetup.ps1` deploy step, no custom InstallScript, no `Dependencies/` bundling. Verified green end-to-end on RC **and** Feature for a Dev-Pack-style solution whose tests do DOM CRUD through the solution API:

```xml
<CatalogReferences ...>
  <CatalogReference id="52173e49-9185-4772-9b60-c186ee365a81">
    <Name>000 Standard Data Model Registration</Name><Selection><Range>2</Range></Selection>
  </CatalogReference>
  <CatalogReference id="c9666f3a-be26-42fd-83f2-6ee7fab4f11e">
    <Name>001 Categories</Name><Selection><Range>1</Range></Selection>
  </CatalogReference>
  <CatalogReference id="<solution-internal-id>">
    <Name>My Solution (internal)</Name><Selection><Range>0.1.0</Range></Selection>
  </CatalogReference>
</CatalogReferences>
```

Mechanics that make this work, and the traps that each cost a QAOps run:

- **Install order = embedded-`.dmapp` filename order.** The runtime AppInstaller (`InstallDefaultContent` → `InstallAppPackages`) installs the embedded dependency `.dmapp`s in **alphabetical filename order**, and the SDK derives each embedded filename from the `<Name>`. Prefix prerequisites with `000`/`001`/… so SDM installs before Categories before the solution. The solution installer aborts with an explicit message when a prereq is missing (`This solution requires SDM to function. … deploy the 'Standard Data Model Registration' package` then, next run, `… requires Categories …`). Seed the **known chain up front** (SDM → Categories → solution) instead of discovering it one failed install at a time — verify the order in the built package: extract it and list `AppInstallContent\AppPackages\*.dmapp` sorted by name.
- **Public manifest IDs are often unpublished placeholders.** The `id:` in a solution repo's `CatalogInformation/manifest.yml` may be a placeholder that CI **overwrites** before publishing (`sed -i "s/^id: .*/id: ${{ vars.CATALOGIDENTIFIER_INTERNALPACKAGE }}/"`). Referencing it fails the build with `Version could not be resolved` or `404 … Catalog … was not found`. Find the **real** published ID via `gh variable list --repo <org>/<repo> --json name,value` and look for `CATALOGIDENTIFIER*` (e.g. `CATALOGIDENTIFIER_INTERNALPACKAGE` → the internal solution package). The internal package may live in a different org than your key — see Section 8.
- **A `.dmtest` is emitted even when a Catalog download fails.** When an item can't be resolved/downloaded the SDK logs `error : Failed to download catalog item …` but still prints `Successfully created package '….dmtest'` and leaves a **stale/incomplete** file. Never trust the success line or pick the artifact by existence/timestamp — grep the build output for `error :` / `Failed to download catalog item` and treat any as a hard failure before submitting.

Use the heavier bundle-and-deploy path (above) only when the solution package is **not** Catalog-published in a reachable org, or when its installer must run a step that won't complete during `InstallingDependencies`.

## 4. Replicate Setup — Do Not Call Solution Automation Scripts as Subscripts

Tempting shortcut: from the InstallScript, `engine.PrepareSubScript("DOM ImportExport").StartScript()` to reuse the solution's own DOM importer. This **fails on QAOps** with `Run subscript '...' failed: Errors in CSharp script code`, because that Automation script's assembly references are not all resolvable while the package is installing. Instead **inline** the minimal logic directly into the InstallScript so it compiles against the Test Package's own references. For DOM import that means, per module folder under `SetupContent/DOM`:

1. `new ModuleSettingsHelper(engine.SendSLNetMessages)` → create/update the `ModuleSettings` from the module `.json`.
2. `new DomHelper(engine.SendSLNetMessages, moduleId)` → create/update `SectionDefinitions`, then `DomBehaviorDefinitions` (parent-before-child ordered), then `DomDefinitions`, each via `Read(<Exposer>.Equal(id)).FirstOrDefault()` then `Create`/`Update`.

Keep the generic-helper surface small: explicit per-type import methods avoid the `ICrudHelperComponent<T>` / `IGuidDMAObjectRef` namespace-resolution friction that generic `AddOrUpdate<T,TId>` helpers hit.

## 5. InstallScript Dependency Harvesting — Verify Before Every QAOps Run

The SDK compiles the InstallScript on the QAOps DMA, so every assembly the generated `Scripts\Install.xml` references **must** exist in `Scripts\InstallDependencies\` inside the `.dmtest`. Failure signature during `InstallingDependencies`: `CS0006 Could not find file '...Xxx.dll'`.

- Only reference NuGet assemblies the SDK actually harvests. Dev/ref-only packages (e.g. `Skyline.DataMiner.Dev.Utils.SDM.Abstractions`) produce an `Install.xml` ref but are **not** copied into `InstallDependencies`. If the InstallScript does not truly need such a package, **remove the reference** — manual `<Content>`/`<Reference>`/copy-target workarounds did not get the SDK to harvest it.
- Verify before submitting (extract the exact versioned `.dmtest`):

```powershell
$deps = Get-ChildItem "$extract\Scripts\InstallDependencies" -Filter *.dll | ForEach-Object Name
$refs = Select-String "$extract\Scripts\Install.xml" -Pattern '<Param type="ref">([^<]+)</Param>' |
        ForEach-Object { $_.Matches[0].Groups[1].Value }
$refs | Where-Object { $_ -like 'Skyline*' -and $_ -notin $deps }   # MUST be empty
```

- **Freshness for InstallScript code changes:** the install code is embedded as **`Scripts\Install.xml`** inside the package (not a compiled DLL). To prove a package is fresh after editing the InstallScript, scan `Scripts\Install.xml` for a newly added method name — not a `.dll`.

## 6. Test Package Template Gotchas in Existing CPM Solutions

- **NU1008 — Central Package Management.** The `dataminer-test-package-project` template emits inline `Version="..."` on its `<PackageReference>`s. In a CPM repo this fails with *"PackageReference items cannot define a value for Version."* Move each version into `Directory.Packages.props` as a `<PackageVersion>` and strip the inline `Version` attributes from the Test Package `.csproj`.
- **"Including a package project inside another package project is not supported."** The template's `PackageContent/ProjectReferences.xml` default-includes `..\*\*.csproj`, which sweeps in the solution's other `<DataMinerType>Package</DataMinerType>` projects. Add explicit `<ProjectReference Exclude="..\OtherPackage\OtherPackage.csproj" />` lines for every Package/TestPackage project in the solution (including the Test Package itself).
- **Do not downgrade `global.json`'s SDK version after creating the template project.** `dotnet new dataminer-test-package-project` may bump `global.json`'s `Skyline.DataMiner.Sdk` (e.g. to 2.5.2) and the template references `Skyline.DataMiner.Core.AppPackageInstaller` 4.0.0. Reverting `global.json` to an older SDK breaks packaging with `Skyline.DataMiner.Core.AppPackageInstaller version 4.0.0.0 is not compatible with currently used Skyline.DataMiner.Core.AppPackageCreator version 3.1.1.0`. Keep the SDK version the template set (treat the `global.json` bump as part of the migration, not an unrelated change to revert).
- **The global packages folder isn't always `~/.nuget/packages`.** On VS machines NuGet may resolve from a shared cache (e.g. `c:\pfpr`, `C:\Program Files (x86)\Microsoft Visual Studio\Shared\NuGetPackages`). To inspect a package's XML docs/DLLs, read the real path from the project's `obj/project.assets.json` → `packageFolders` rather than assuming the user-profile cache.

## 7. Playwright-on-QAOps Specifics

Web UI tests need the DataMiner web app over **HTTPS**, even though SLNet uses the bare host:

- Browser base URL / `BrowserNewContextOptions.BaseURL` / `page.GotoAsync(...)` target: `https://localhost`.
- SLNet `ConnectionSettings.GetConnection(...)`: bare `localhost` (no scheme). Keep the SLNet host and the browser URL as **separate** config values.
- Set `IgnoreHTTPSErrors = true` on the browser context when on the QAOps bridge (self-signed cert).
- Getting this wrong shows as `net::ERR_CONNECTION_REFUSED at http://localhost/app/...`.
- **Exclude Playwright trace artifacts from the post-build harvest.** Playwright writes a per-failed-test trace `.zip` into the test output folder, so a `$(OutputPath)**\*.*` harvest sweeps them into the package and the build fails intermittently with `MSB3021`/`MSB3027` "Unable to copy file … Could not find a part of the path" (the zips are locked/removed between enumeration and copy). Add `Exclude="$(OutputPath)<trace-folder>\**"` and `SkipUnchangedFiles="true"` to the copy target — the trace folder name is chosen by the test code (e.g. the `Context.Tracing.StopAsync(... Path = Path.Combine(Directory.GetCurrentDirectory(), "playwright-traces", …))` segment), so read it from the source rather than assuming. Full how-to: main SKILL → `references/test-package-wiring.md` → "Excluding Runtime Test Artifacts" (verified: PR #555).

## 8. Catalog Organization Scope

The build-time Catalog organization key is scoped to one organization. If a needed item lives in a **different** org than the key (e.g. internal MediaOps packages on "Skyline Communications Development" vs a key for "Skyline Communications"), the Catalog download fails with a permission/authorization error. Do not guess or churn — name the exact failing Catalog item and ask the user to switch the key to the organization that owns it. When the item is an internal solution package, find its real published ID via `gh variable list --repo <org>/<repo>` (`CATALOGIDENTIFIER*`) rather than the public `manifest.yml` placeholder (Section 3, lightest-path).

## 9. Clean-System Test Tactics: Inconclusive vs Fail (QAOps-gated)

Even with the solution installed, a freshly-bootstrapped DaaS has **no seeded business data** and **no out-of-solution connectors**. Existing tests that assume either fail on QAOps only. Branch these on the same `IsQaOps` flag the credential gate sets (Section 1) and prefer `Assert.Inconclusive` over `Assert.Fail`, so an environment gap that is not a regression doesn't red the suite. Leave the non-QAOps path exactly as it was:

- **Read-first-of-collection tests.** `Api.Workflows.Read().First()` / `RecurringJobs.Read().First()` throw `InvalidOperationException: Sequence contains no elements` on a clean system. Change to `.FirstOrDefault()` and, when null **and** `IsQaOps`, `Assert.Inconclusive("No <X> exists on the QAOps system after install.")`.
- **External-connector-dependent tests.** Tests needing a connector the solution doesn't install (e.g. `Generic Camera`) typically already `Assert.Fail("connector not available")`; on QAOps make that branch `Assert.Inconclusive` instead. Add the connector as a Catalog prerequisite only when verifying that behavior is actually in scope.

This converts the "almost green" full run (e.g. 534 OK / 7 fail on missing seed + optional connector) into a clean pass without weakening local coverage. `Assert.Inconclusive` rows show as `NotExecuted` in QAOps and do not fail the run.

## Migration Checklist

1. Identify the existing integration test project(s) and the shared test/connection setup they use.
2. Gate credentials behind the `BridgeId` check (Section 1); local behavior unchanged; expose one `IsQaOps` flag.
3. Create/reuse the Test Package; fix CPM + `ProjectReferences.xml` + `global.json`-SDK template gotchas (Section 6).
4. Decide the prerequisite path: **lightest** = CatalogReference the published solution package + `000`/`001`-ordered SDM/Categories (Section 3, lightest-path); **heavier** = bundle + pipeline-deploy the solution `.dmapp` (Section 3); or piecemeal InstallScript replication for shallow tests.
5. For the heavier/piecemeal paths, read the solution's own Package install script and replicate every step, inlined (Sections 2, 4).
6. Harvest the test assembly (post-build copy + `TestDiscovery.ps1` + pipeline), per the main SKILL; for Playwright projects, **exclude the runtime trace directory** from the post-build copy (Section 7) so trace zips don't break the build with `MSB3021`.
7. Build; **grep build output for `error :` / `Failed to download catalog item`** (a `.dmtest` is emitted even on Catalog-download failure); verify `.dmtest` contents, embedded-`.dmapp` install order, packaged test discovery, and (heavy path) install-dependency completeness (Section 5).
8. Gate clean-system gaps as `Assert.Inconclusive` on QAOps (Section 9).
9. Iterate on QAOps with a `-TestFilter` scoped run (one fast test) until install + that test go green, then restore the unfiltered pipeline and rebuild a fresh full version. Long runs in a background shell can be lost if the session ends — record the exact `<Version>` + `-tags` so a new session can re-submit the same artifact.
