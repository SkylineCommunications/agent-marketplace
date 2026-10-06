---
name: project-type-identification
description: Discovers and classifies every project in a repository that contains Skyline.DataMiner.SDK projects and/or DataMiner app frontends (ad hoc data source, data transformer, user-defined API, automation script, connector, NuGet project, shared project, test project, DataMiner app, and more) by combining source code patterns, manifest.yml, and .csproj/package.json metadata. Accepts an optional scope that keeps the expensive source-scanning pass limited to the projects a caller cares about. Use whenever an agent needs a typed project inventory before doing per-type work such as documentation, review, or validation.
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-15
  version: 1.6
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-api`, `dataminer-create-new-app`, `source-code-readme-writing`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-api`: Example frontend classification signal; classification does not execute the frontend integration workflow.
> - `dataminer-create-new-app`: Example frontend classification signal; classification does not scaffold applications.
> - `source-code-readme-writing`: Example consumer of the inventory, not a dependency of classification or Catalog auditing.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.6 | 2026-09-15 | Added verified Node Recovery and SRM source indicators while preserving unresolved-signature reporting. |

# Project Type Identification

Produces a typed inventory of every project in a repository that contains `Skyline.DataMiner.SDK` projects, DataMiner app frontends, or both. Consumed by any skill or agent that needs to know what kind of project it is looking at before doing per-type work (documentation, review, validation, etc.) — for example the `source-code-readme-writing` skill.

## When to Use This Skill

- Before generating or reviewing documentation for a repository holding DataMiner SDK projects or DataMiner apps.
- Before applying per-project-type rules (review checklists, validators, scaffolds) that depend on knowing the project's type.
- Whenever a repository contains multiple Visual Studio projects and their types are not already known.

## Optional Scope

A caller may supply a **scope**: the subset of the repository it cares about, down to a single project. It can be expressed however the caller finds natural — project names, a folder, a set of changed files, a pull request, and so on.

A scope splits the work into two passes so a large repository stays affordable:

| Pass | Covers | Work involved |
|---|---|---|
| **Discovery** — [Identify Projects](#identify-projects), plus Sources [B](#source-b--manifestyml-type-field) and [C](#source-c--csproj-dataminertype-property) | The whole repository, always | Cheap: locating project files and reading their own metadata (the `Sdk` attribute, `<DataMinerType>`, `CatalogInformation/manifest.yml`) |
| **Classification** — [Source A](#source-a--source-code-patterns) and [Reconciliation](#reconciliation) | In-scope projects only | Expensive: opening and scanning source files |

Discovery stays repository-wide because callers depend on repository-wide facts — how many projects exist, whether any SDK project or DataMiner app is present at all, how many projects carry a Catalog item. Those come from file metadata, not from reading code, so covering everything costs little. Only the source-scanning pass follows the scope.

- A project is in scope when the scope names it, contains it, or points at a file it owns. Referenced files belonging to no project are ignored.
- With no scope supplied, every project is in scope and both passes cover the whole repository.
- An out-of-scope project keeps whatever type Source B or C yielded from its metadata. When neither yielded a result, report its type as **Unclassified (out of scope)** — never guess a type from a folder name.
- **DataMiner app is the one exception**: Source A is its only classifier, so its two cheap signals (a `package.json` with no `.csproj`/`.shproj` sibling, and a frontend build config pointing at a DataMiner web path) are checked during discovery for every project. Skip the corroborating signals for out-of-scope apps.
- If the scope matches no project at all, report it as **unresolved** rather than silently returning an empty in-scope set.

## Identify Projects

Read the repository root to identify all folders that contain a project. A folder is considered a **Visual Studio project** if it contains a `.csproj` or `.shproj` file. Among Visual Studio projects, give special attention to **DataMiner SDK projects**: these use `<Project Sdk="Skyline.DataMiner.Sdk">` and have a `<DataMinerType>Package</DataMinerType>` property group. These projects represent deployable DataMiner packages.

Also treat as a project any folder that contains a `package.json` **without** a `.csproj`/`.shproj` sibling — these are non-.NET, JavaScript/TypeScript-based projects (see **DataMiner app** under "Source A" below) and should be included in the inventory alongside Visual Studio projects.

## Detect Project Types

Project types can be determined from three independent sources. Sources B and C are metadata-only and run for every project during discovery; Source A scans source files and runs for in-scope projects only (see [Optional Scope](#optional-scope)). For an in-scope project, check **all three**; if the sources disagree, include a warning in the output noting the conflict so a human can resolve it.

### Source A — Source code patterns

Inspect the source files in the project directory for code-level indicators:

| Code Pattern | Project Type |
|---|---|
| C# file (`.cs`) containing `[AutomationEntryPoint(AutomationEntryPointType.Types.InstallAppPackage)]` | Package |
| C# file (`.cs`) implementing `IGQIDataSource` | Ad hoc data source |
| C# file (`.cs`) implementing `IGQIRowOperator` and/or `IGQIColumnOperator` | Data transformer |
| C# file (`.cs`) containing `[AutomationEntryPoint(AutomationEntryPointType.Types.OnApiTrigger)]` | User-defined API |
| C# file (`.cs`) containing `AutomationEntryPointType.Types.OnNodeRecoveryLocalStateChange` or `OnNodeRecoveryGlobalStateChange` | Node Recovery script |
| C# file (`.cs`) containing verified SRM Dev Pack types/role markers from the selected package/template | SRM automation script |
| DMSScript XML file containing both `<Param type="preCompile">` and `<Param type="libraryName">` | Automation shared library |
| DMSScript XML file with `<Folder>` tag value equal to `bot` or starting with `bot/` | ChatOps operator |
| DMSScript XML file AND C# file containing any of: `engine.ShowUI(`, `engine.RunClientProgram(`, `engine.ShowProgress(`, `engine.FindInteractiveClient(`, `engine.IsInteractive` | Interactive automation script |
| DMSScript XML file | Automation script |
| Protocol XML file (root element `<Protocol>`) | Connector |
| `.csproj` with `<Project Sdk="Microsoft.NET.Sdk">` and an `<AssemblyName>` property | NuGet project |
| `.shproj` file present | Shared project |
| `.csproj` with `<DataMinerType>TestPackage</DataMinerType>` | QAOPS test package |
| `.csproj` referencing test frameworks (MSTest, NUnit, xUnit) or folder/name containing `Test`/`Spec` | Test project |
| `package.json` (no `.csproj`/`.shproj`) AND a Vite/frontend build config (`vite.config.js`/`.ts`) whose `base`/`outDir` targets a `Webpages/public/...`, `/public/...`, or `CompanionFiles/...Webpages...` path | DataMiner app |

Apply rules in the order listed above; use the **first** match.

For **Package** detection: the `[AutomationEntryPoint(AutomationEntryPointType.Types.InstallAppPackage)]` attribute is sufficient on its own — no other signal is required. Source B (`manifest.yml` `type`) may refine the generic **Package** label into a specific solution type (e.g., `Standard Solution`, `Custom Solution`, `Product Solution`); if there is no manifest, the project stays labelled **Package**. Commonly present alongside it, though not required: `<Project Sdk="Skyline.DataMiner.Sdk">` with `<DataMinerType>Package</DataMinerType>` and `<GenerateDataMinerPackage>True</GenerateDataMinerPackage>`, a `CatalogInformation/manifest.yml`, a `PackageContent` folder (`CatalogReferences.xml`, `ProjectReferences.xml`, and subfolders such as `CompanionFiles`, `Dashboards`, `LowCodeApps`), a `SetupContent` folder (DOM definitions, themes, config files consumed at install time), and a `GettingStarted.md`.

For **DMSScript XML** detection: a file is a DMSScript XML file if its root element is `<DMSScript>`.

For **specialized Automation** detection, source-code indicators take precedence over the generic DMSScript rule.
`IGQIDataSource` is a compiled GQI source, not a normal Automation script. `OnApiTrigger` is a User-Defined API.
Node Recovery entry-point names must be verified against the selected Dev Pack; do not infer enum values from a
numeric literal. SRM has several configuration-driven roles and incomplete public signature coverage, so classify it
as SRM only when a selected version-matched package/template/configuration gives an explicit indicator; otherwise
report the project as Automation and include the unresolved evidence.

For **Protocol XML** detection: a file is a Protocol XML file if its root element is `<Protocol>`.

For **DataMiner app** detection specifically, corroborate with these additional signals (not all required, but each strengthens confidence):

- No backend/server code — the app is a purely client-side React (or other framework) SPA.
- No in-app login/authentication UI — session bootstrap relies on DataMiner's own `/auth/` sign-in page (see the `dataminer-api` skill's cookie/auth-guard conventions).
- Data access goes through DataMiner GQI queries (e.g., `OpenQuerySessionAsync`) rather than direct SOAP/DOM calls.
- The build output folder is copied into a DataMiner `Webpages\Public` (or equivalent `CompanionFiles`) location, matching the deployment model in the `dataminer-create-new-app` skill.
- These apps are commonly produced with the `dataminer-app-builder` agent, though no explicit provenance marker is written into the generated code — classification must rely on the structural signals above, not on a tag or comment.

### Source B — `manifest.yml` type field

Look for a `manifest.yml` in the project's `CatalogInformation/` folder. If present, read the `type` field.

If no manifest file exists or the `type` field is absent, this source yields no result. **DataMiner app** projects typically have no `CatalogInformation/manifest.yml`, so this source normally yields no result for them.

### Source C — `.csproj` DataMinerType property

Inspect the `.csproj` file for a `<DataMinerType>` element in a `<PropertyGroup>`. If the `.csproj` has no `<DataMinerType>` element, this source yields no result. **DataMiner app** projects have no `.csproj` at all, so this source always yields no result for them — Source A is the only source that can classify a DataMiner app.

For specialized projects, also record relevant `PackageReference` entries and `MinimumRequiredDmVersion`. A
`DataMinerType` value is evidence, not permission to invent a contract; reconcile it with the source/template and
selected package.

### Reconciliation

Use the source order **A → B → C** to determine the final project type. Give preference to the result from the earliest source that yields a result. Exception: when Source A yields the generic **Package**, Source B's more specific solution type should be preferred (e.g., `Standard Solution`, `Custom Solution`) if a `manifest.yml` `type` is present.

## Output

The output of this skill is a **project inventory**: a list of all identified projects, each annotated with:

| Field | Description |
|-------|-------------|
| **Project Name** | The folder name containing the project |
| **Project Path** | Relative path from repository root to the project folder |
| **Project File** | Name of the `.csproj` or `.shproj` file, or `package.json` for a DataMiner app |
| **Project Type** | The resolved type from the reconciliation step, or **Unclassified (out of scope)** when only metadata was available and it yielded nothing |
| **Type Sources** | Which sources (A, B, C) contributed a result, and any conflicts |
| **Is SDK Project** | Whether this is a DataMiner SDK project (always **No** for a DataMiner app — it is a static frontend, not a `Skyline.DataMiner.Sdk` package) |
| **In Scope** | Whether the project falls within the caller's scope (always **Yes** when no scope was supplied) — see [Optional Scope](#optional-scope) |

## Gotchas

- **Always check all three sources**, even after Source A matches — a Source B/C disagreement is a signal worth surfacing to a human, not something to silently discard. This applies to in-scope projects; out-of-scope projects only ever have B and C available.
- **Two kinds of project are in scope, and the sources that apply differ per kind.** `Skyline.DataMiner.SDK` projects are classified by all three sources; before relying on Source B/C, confirm the repository really holds SDK projects (e.g., a `.sln` referencing `Skyline.DataMiner.Sdk` projects). A **DataMiner app** is not an SDK project, so it never has a `CatalogInformation/manifest.yml` or a `.csproj` — Source A is its only classifier, and that absence is expected, not a conflict.
- A single repository can legitimately contain both kinds side by side, so an inventory mixing SDK projects and DataMiner apps is normal — do not discard either kind because the other is present.
- **A top-level installer Package project commonly triggers a companion DataMiner app build**, e.g., a `<Target Name="BuildWebApp" BeforeTargets="BeforeBuild">` running `npm ci`/`npm run build` against a sibling `-App` folder, whose output lands in `PackageContent/CompanionFiles/.../Webpages/public/...`. Treat the Package project and the DataMiner app as two separate inventory entries, linked by that build dependency — do not merge them into one.
