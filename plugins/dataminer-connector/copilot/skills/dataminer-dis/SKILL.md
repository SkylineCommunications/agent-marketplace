---
name: dataminer-dis
description: 'DataMiner Integration Studio (DIS) code-relevant workflow guidance for Visual Studio: XML editor, snippets, parameter generation, validator auto-fixes, comparer/Major Change Checker, table/version editors, and code-navigation aids. Use when the user is working in Visual Studio with DIS available. DIS is highly advised but not mandatory.'
argument-hint: 'Describe the DIS-related workflow or connector task: e.g. "use DIS validator", "run major change checker", "generate params from MIB", "edit VersionHistory in DIS"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 1.2
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-automation-scripting`, `dataminer-automation-xml`, `dataminer-interactive-automation`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-automation-scripting`: DIS Automation workflow only; connector-only tasks do not use this branch.
> - `dataminer-automation-xml`: DIS Automation schema workflow only; not required for connector authoring.
> - `dataminer-interactive-automation`: DIS interactive Automation workflow only.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.2 | 2026-09-16 | Added Automation XML/C# DIS Inject, import, attach, execute, and restore workflow guidance. |
| 1.1 | 2026-09-14 | Made DIS QAction helper generation conditional on affected generated-member consumers. |
| 1.0 | 2026-05-14 | Initial release. Code-relevant DIS guidance only. |

# DataMiner Integration Studio (DIS)

This skill covers DIS features that materially affect connector source code, Automation XML/C# source, generated source, validation, comparison, and code-aware inspection.

It does **not** cover packaging, Catalog publication, deployment, or general DMA operations outside the codebase itself. `references/automation-workflows.md` covers the code-relevant Automation import/debug route; it is not a substitute for QAOps or release/deployment verification.

Load `dataminer-sdk` alongside this skill for official CLI, package, and tool version decisions. Load `dataminer-protocol-xml-reference` for XML schema authority. Load `dataminer-validation` for validator semantics and suppression syntax.

---

## Usage Policy

- DIS use is **highly advised** when the user is working in Microsoft Visual Studio and DIS is available.
- DIS is **not mandatory**. Do not force DIS when the task is trivial, headless, CI-driven, or better served by official CLI tooling.
- DIS connector workflows are not Automation workflows: do not route Automation XML, SDK project, or IAS work through connector-only Protocol XML, Table Editor, or QAction assumptions.
- Prefer the official Skyline CLI tools for automation, repeatability, and non-interactive execution.
- Prefer DIS when interactive authoring, validation review, auto-fix inspection, MIB-assisted generation, or Major Change Checker review adds clear value.

---

## When To Load This Skill

Load this skill when one or more of these are true:

- The user is working in Visual Studio with DIS installed.
- The task involves `protocol.xml` authoring where schema-aware editing, snippets, or tag shortcut menus help.
- The task benefits from DIS Validator auto-fix review, suppression review, or issue navigation.
- The task involves comparing a changed connector against a previous version to assess major changes.
- The task involves parameter generation from MIB, XML, JSON, WSDL, or Ember+ sources.
- The task involves table-heavy authoring where the Table Editor, Grid View, or Version Editor can reduce manual XML edits.
- The task is investigative or review-focused and DIS Tree, Diagram, Grid View, MIB Browser, or Parameter Update Locations can expose code relationships faster.
- The task involves importing or debugging an Automation script with DIS Inject.

Do not load this skill for purely headless CLI workflows unless the user specifically wants DIS-aware guidance.

---

## Code-Relevant DIS Features

| Feature | Use It For | Guidance |
|---------|------------|----------|
| **XML Editor** | Schema-aware `protocol.xml` editing | Highly advised for non-trivial XML work. Use IntelliSense, on-the-fly schema validation, virtual comments, linked-item navigation, tag shortcut menus, snippets, `Generate Parameters`, `Generate Write Parameters`, `Edit C#`, `Table Editor`, and `Compare`. |
| **DIS Validator** | Interactive validation review | Highly advised during iterative Visual Studio work. Use it to inspect severity, certainty, fix impact, auto-fix availability, suppression/postponement actions, and direct navigation to findings. |
| **DIS Comparer** | Protocol comparison and Major Change Checker review | Primary DIS workflow for comparing a changed connector against a prior version. Review both the **Major Change** and **Validator** tabs before finalizing shipped-impact changes. |
| **Version Editor** | `Protocol.Version` and `VersionHistory` editing | Highly advised when updating release metadata, references, branch/system/major/minor version nodes, or documenting major changes. |
| **Table Editor** | Table and column authoring | Useful for table-heavy connectors. It can manage displayed columns, foreign keys, widths, alarming/trending toggles, and table options faster than raw XML. Validate afterwards. |
| **DIS Grid View** | Bulk parameter property review | Useful for auditing descriptions, display settings, positions, discreets, and parameter-wide consistency across many rows. |
| **DIS MIB Browser** | SNMP-driven authoring | Highly advised for SNMP connectors. Use it to build `Param` tags from MIB data and to compare MIB OIDs against the current protocol XML. |
| **Edit C# / C# Editor** | QAction project editing | Useful when jumping from XML-defined QActions into the corresponding C# project, using C# snippets, and navigating back to the XML location. |
| **DIS Tree / Diagram / Parameter Update Locations** | Code-aware inspection | Use for dependency tracing, trigger/action/group flow inspection, locating parameter update sites, and understanding how XML/QAction logic connects. These are review and investigation aids, not authoritative schema sources. |
| **Protocol > Generate QAction Helper Code** | Helper regeneration | Use when existing source consumes generated members affected by a `protocol.xml` change, or when explicitly requested. Still confirm with build and validator passes afterward. |
| **Automation import / DIS Inject** | Automation XML/C# debugging | Load `references/automation-workflows.md`; map Exe IDs, projects, parameters, and dummies before attaching to `SLAutomation`. |

---

## Recommended Workflows

## Automation XML/C# Debugging

Use `references/automation-workflows.md` for the import, project-link, parameter/dummy mapping, attach, execute, detach, and restore sequence. DIS Inject is a controlled diagnostic route; it does not replace the pinned XSD/build/analyzer gate or QAOps live verification.

## `protocol.xml` Authoring In Visual Studio

1. Use the DIS XML Editor instead of raw text editing when the change is non-trivial.
2. Use snippets, tag shortcut menus, linked-item navigation, and virtual comments to avoid schema and reference mistakes.
3. For import-style tasks, use `Generate Parameters` or the MIB Browser rather than hand-authoring large repeated XML blocks.
4. Run DIS Validator during the edit loop to inspect findings and available auto-fixes.
5. Regenerate helper code only if the XML change affects generated members consumed by QActions or tests.
6. Re-run the official CLI validator before completion.

## Existing Connector Changes With Possible Shipped Impact

1. DIS Comparer is **highly advised**.
2. Compare the current protocol with the previous release.
3. Review the **Major Change** tab for breaking changes.
4. Review the **Validator** tab for behavioral/quality differences between versions.
5. If DIS is not being used, run the official compare CLI when available.

## Table-Heavy SNMP Work

1. Use DIS MIB Browser or `Generate Parameters` to seed table parameters.
2. Use Table Editor or Grid View to adjust displayed columns, foreign keys, widths, alarming, and trending.
3. Validate the resulting XML and inspect NamingFormat, PK, display key, and column ordering afterward.

## Version History Maintenance

1. Use Version Editor when updating `Protocol.Version` and `VersionHistory`.
2. Record fixes, changes, and new features in the correct minor version node.
3. For major-change-sensitive work, ensure the version history reflects the approved impact documentation.

---

## Major Change Checker Guidance

The Major Change Checker is one of the most valuable DIS features for existing connector work.

- Use it when changing shipped protocol name, parameter IDs, parameter removal, discreet displays/values, table primary keys, display keys, column order, logger-table state, partial-table state, DVE export names, `Type@options`, or minimum required DataMiner version.
- Use it before reporting completion on any change that may break upgrades or downstream consumers.
- If DIS is available, **DIS Comparer is highly advised** for this review.

### CLI Relationship

Current `Skyline.DataMiner.CICD.Tools.Validator` releases also support compare in the shell:

```bash
dataminer-validator compare protocol-solution --solution-path "<path>.sln" --output-directory "<dir>" --catalog-id "<guid>" --catalog-api-key "<key>"
```

You can also provide a previous protocol XML path instead of downloading from Catalog:

```bash
dataminer-validator compare protocol-solution --solution-path "<path>.sln" --output-directory "<dir>" --previous-protocol-xml-path "<path-to-previous-protocol.xml>"
```

If the installed CLI does **not** expose `compare`, use DIS Comparer or update the validator tool.

---

## Validator Tool Version Awareness

Do not assume the shell `dataminer-validator` version matches the installed DIS extension version.

- DIS in Visual Studio can be current while the global `dataminer-validator` executable on `PATH` is old.
- Current CLI documentation uses hierarchical subcommands such as `validate protocol-solution` and `compare protocol-solution`.
- Older CLI installs may only expose `validate-protocol-solution` and may not expose compare at all.

Check the installed shell command with:

```bash
dataminer-validator --help
```

If the help shows only `validate-protocol-solution`, that shell tool is a legacy version. In that case:

- use DIS Validator for Visual Studio review,
- use DIS Comparer for MCC work, or
- update the validator CLI if headless compare is required.

---

## DIS Is Recommended, Not Required

Use DIS when it makes the task safer or faster.

Skip DIS when:

- the task is a trivial one-line edit,
- the workflow is headless or CI-only,
- the user is not in Visual Studio,
- or the official CLI already covers the task better.

The correct rule is not "always use DIS".

The correct rule is: **use DIS whenever its code-aware Visual Studio features materially improve the work**.

---

## Documentation Links

| Topic | URL |
|-------|-----|
| DIS overview | https://aka.dataminer.services/about-dis |
| DIS features | https://aka.dataminer.services/features |
| XML Editor | https://aka.dataminer.services/xml-editor |
| C# Editor | https://aka.dataminer.services/c-editor |
| Table Editor | https://aka.dataminer.services/table-editor |
| Version Editor | https://aka.dataminer.services/version-editor |
| DIS Validator | https://aka.dataminer.services/dis-validator-tool-window |
| DIS Comparer | https://aka.dataminer.services/dis-comparer-tool-window |
| DIS MIB Browser | https://aka.dataminer.services/dis-mib-browser-tool-window |
| DIS Tree View | https://aka.dataminer.services/dis-tree-view-tool-window |
| DIS Grid View | https://aka.dataminer.services/dis-grid-view-tool-window |
| DIS Diagram | https://aka.dataminer.services/dis-diagram-tool-window |
| DIS Parameter Update Locations | https://aka.dataminer.services/dis-parameter-update-locations |
| DIS menu | https://aka.dataminer.services/dis-menu |
| Validator docs | https://aka.dataminer.services/validator-checks |
| Validator CLI package | https://www.nuget.org/packages/Skyline.DataMiner.CICD.Tools.Validator |
| Impact of protocol version changes | https://aka.dataminer.services/impact-of-protocol-version-changes |
| Change protocol name impact | https://aka.dataminer.services/change-protocol-name |
| Change parameter ID impact | https://aka.dataminer.services/change-parameter-id |
| Remove parameter impact | https://aka.dataminer.services/remove-parameter |
| Change primary key impact | https://aka.dataminer.services/change-primary-key |
| Change minimum required DataMiner version impact | https://aka.dataminer.services/change-minimum-required-dma-version |
