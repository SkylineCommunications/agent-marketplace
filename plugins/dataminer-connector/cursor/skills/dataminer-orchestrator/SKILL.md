---
name: dataminer-orchestrator
description: 'Orchestrator reference material for DataMiner connector development: plan templates, Connector Map format, skill routing table, and NuGet package guidance. Loaded by the dataminer-connector-orchestrator for planning and delegation.'
argument-hint: 'Describe the connector task: e.g. "create SNMP connector for Vendor X", "add HTTP polling group to existing connector", "fix validator error 2.5.1", "investigate why table is not populating", "review my connector", "generate help documentation"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-05
  version: 2.8
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.8 | 2026-10-05 | Added discrete parameter planning rules with numeric backend for alarming and trending pre-known values. |
| 2.7 | 2026-10-02 | Added task-routes reference covering lifecycle route ownership, task-specific delegation, and final gates; archived historical orchestrator changelog. |
| 2.6 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 2.5 | 2026-09-15 | Added connector task classes, artifact ownership, Connector Map route coverage, bounded retries, and task-specific final gates. |
| 2.4 | 2026-09-14 | Aligned planning with conditional QAction helper generation and helper-free projects. |
| 2.3 | 2026-09-11 | Replaced the removed connector guide URL with the current getting-started page. |
| 2.2 | 2026-05-14 | Added `dataminer-dis` routing and major-change compare planning guidance. |
| 2.1 | 2026-05-14 | Added `dataminer-sdk` routing and SDK-first planning rules. |
| 2.0 | 2026-04-13 | Removed duplicated Phase 1-6 workflow (now owned exclusively by the paired agent). Skill now focuses on reference routing, NuGet guidance, and constraints. |
| 1.2 | 2026-03-28 | Initial release. |

> **Paired agent**: `dataminer-connector-orchestrator` — owns the Phase 1-6 workflow, persona, classify table, and subagent delegation. This skill owns plan templates, skill routing, and NuGet guidance. Keep shared concepts (phase names, classify categories) in sync.

- Schema reference: https://docs.dataminer.services/develop/schemadoc/SchemaProtocol.html
- Dev guide: https://docs.dataminer.services/develop/devguide/Connector/Getting_started_with_data_source_integrations.html
- Coding guidelines: https://docs.dataminer.services/develop/codingguidelines/CodingGuidelines.html
- Advanced functionality: https://docs.dataminer.services/develop/devguide/Connector/AdvancedFunctionality.html
- UI Components: https://docs.dataminer.services/develop/devguide/Connector/UIComponents.html

Load the `dataminer-connector-core` skill for shared naming conventions and constraints. Load `dataminer-sdk` whenever the plan touches project setup, validation, build, packaging, publish, deployment, or official Skyline package/tool selection. Load `dataminer-nugets` whenever the plan touches NuGet package selection or package-specific API usage. Load `dataminer-dis` when the user is working in Visual Studio with DIS available and code-relevant DIS features would materially improve the workflow.

## Reference Files

| Topic | Reference File |
|-------|---------------|
| Connector Map template, plan formats (FEATURE/BUGFIX/INVESTIGATION/REVIEW/DOCUMENTATION), lightweight mode | `dataminer-orchestrator/references/plan-templates.md` |
| Task routes, lifecycle route ownership, delegation rules, and task-specific final gates | `dataminer-orchestrator/references/task-routes.md` |
| Archived orchestrator changelog (v1.1–v2.9) | `dataminer-orchestrator/references/CHANGELOG.md` |

---

## NuGet Package Selection

Before proposing changes in the plan, load `dataminer-nugets` and consult `dataminer-connector-core/references/nuget-packages.md` to identify utility packages that should be used. **ALWAYS prefer official Skyline utility packages over custom implementations** for: rate calculations, SNMP helpers, type conversions, table context menus, trap parsing, table cleanup, protocol wrappers, InterApp calls, and interface utilization. List selected packages in the plan so the user can review them before implementation.

## SDK-First Planning Rule

- Every implementation plan must name the official Skyline SDK, template, CLI, Dev Pack, or NuGet packages that will be used.
- If a manual approach is proposed, the plan must explain why the official Skyline tool could not be used.
- Plans that touch `protocol.xml` must schedule validation during the work, not only at the end.
- Plans that may change shipped connector behavior must state whether compare/Major Change Checker review is required and whether it will be done through DIS Comparer or the official compare CLI.

---

## Skill Reference

| Activity | Skill to Load |
|----------|---------------|
| Naming conventions, IDs, C# code style | `dataminer-connector-core` |
| Official Skyline SDK/templates/CLI tools, Dev Packs, packaging/publish/deploy flow | `dataminer-sdk` |
| Code-relevant DIS workflows in Visual Studio (validator, comparer/MCC, MIB generation, version editor) | `dataminer-dis` |
| Protocol XML structure and editing | `dataminer-xml-authoring` |
| QAction_Helper.cs generation from protocol.xml | `dataminer-qaction-helper-generator` |
| C# QAction development | `dataminer-qaction` |
| Manipulating the DataMiner System from code (elements, parameters, scripts via IDms) | `dataminer-idms` |
| Skyline NuGet package selection and package-specific API usage | `dataminer-nugets` |
| New connector scaffolding | `dataminer-sdk` (load `references/connector-template-reference.md`) |
| Unit tests with SLProtocolMock | `dataminer-unit-testing` |
| Validator CLI and result interpretation | `dataminer-validation` |
| Inline validation gates (XSD, build quality) | `dataminer-validation-gates` |
| Connector help/documentation pages | `dataminer-connector-help` |
| Polling Manager implementation (configurable per-data-set polling) | `dataminer-polling-manager` |
| Build manifest (shared agent state) | `dataminer-manifest` |
| Structured agent logging | `dataminer-logging` |

## Connector Route Matrix

| Task class | Required analysis | Primary route | Final gate |
|---|---|---|---|
| NEW / FEATURE / BUGFIX | Full Connector Map and target/toolchain decision | XML author → conditional helper → QAction writer → tests | Build + official validator; compare when shipped behavior may change |
| INVESTIGATION / REVIEW | Full read-only Connector Map and source/evidence inventory | Investigator or reviewer | Evidence-backed report; no mutation |
| TESTING | Connector Map plus production/test project graph and seam boundary | Test writer | Exact test build/run; validator if production files changed |
| PACKAGING | Solution/project shape and package inputs | SDK or classic packager reference | Official package command + content/identity verification |
| RELEASE | Version, branch, catalog, compare, and release metadata | SDK/DIS/validator route | Build + validator + compare/release evidence |
| DEPLOYMENT | Immutable artifact identity and target environment | Catalog/package/QAOps deployment route | Artifact hash, target result, rollback evidence |
| MIGRATION | Source/target project and compatibility map | Orchestrator + SDK/package/migration references | Source/target build, validator/compare, compatibility and rollback decision |

The connector orchestrator owns the sequence and retries. Specialists do not hand off to another specialist directly. Allow at most three attempts per gate with the exact finding; after the third failure, stop and report the blocker. For detailed lifecycle stage separation, task-type-specific delegation rules, and required evidence per task class, see [references/task-routes.md](references/task-routes.md).

XML ownership, including QAction registration and late C# change requests, follows
`references/plan-templates.md`. No timeout or poll count authorizes a concurrent writer.
REVIEW/INVESTIGATION bypass implementation repair gates and apply
`dataminer-manifest/references/read-only-assessment.md`.

---

## Constraints

- **NEVER skip the planning phase.** Every task gets a plan before implementation.
- **NEVER implement before building the Connector Map** (for existing connectors).
- **NEVER propose parameter/group/timer IDs without checking existing IDs** in the Connector Map.
- **ALWAYS prefer official Skyline SDK/templates/validator/packager/deploy tools over manual workflows.** If a manual fallback is required, state why.
- **ALWAYS validate** after implementation. Do not consider a task complete without validation.
- **XML changes before QAction changes.** Always. Refresh `QAction_Helper` only when existing code consumes generated members affected by the XML change, or when the user explicitly requests it. Preserve helper-free solutions.
- **Investigation tasks are read-only** until the user approves a fix.
- For XML topics not covered by loaded specialist skills (DCF, mediation, EPM, matrix, tree controls), load `dataminer-protocol-xml-reference` and the relevant bundled references. If the needed schema detail is not documented there, stop and request a reference expansion instead of reading raw `.xsd` files or guessing.
