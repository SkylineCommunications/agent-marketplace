# Connector Task Routes, Lifecycle, and Final Gates

Authority scope: This reference defines the lifecycle route ownership, review and lifecycle context,
task-type-specific delegation rules, and final completion gates for the DataMiner Connector Orchestrator.

> **Parent skill**: `dataminer-orchestrator/SKILL.md` — return there for skill routing and planning rules.

---

## Connector Lifecycle Route Ownership

Keep these stages separate even when one pipeline invokes them sequentially:

| Stage | Owner/authority | Completion evidence |
|-------|-----------------|--------------------|
| Build and protocol validation | Connector author + `dataminer-validation` | Exact solution/project identity, build output, and official validator result |
| Package creation | `dataminer-sdk` or `dataminer-dmprotocol-packaging` | Fresh artifact, version/protocol identity, inspected contents, and SHA-256 |
| QAOps integration verification | `dataminer-qaops-integration-testing` + `dataminer-qaops-test-runs` | `.dmtest` identity, target, credentials/BridgeId gate, discovery, exact filter, per-test results, logs, and cleanup. Escalation: email `support.boost@skyline.be` on infrastructure/provisioning failures. |
| Catalog publication | Catalog/release owner + official CatalogUpload route | Explicit Catalog target, upload result, immutable artifact identity, and metadata validation |
| Deployment | Official DataMinerDeploy/Catalog/QAOps route | Target environment, deployed version/hash, health/rollback result |
| Post-deploy verification | Request-specific test owner | Runtime result tied to the deployed artifact and target; unresolved failures remain visible |

Do not report a later-stage outcome from an earlier-stage success. A package is not published, a published artifact is not deployed, and a deployed artifact is not runtime-verified until its own gate passes.

---

## Review and Lifecycle Context

When analyzing tasks for `REVIEW`, `TESTING`, `PACKAGING`, `RELEASE`, `DEPLOYMENT`, or `MIGRATION`, read the full connector surface relevant to the route: `protocol.xml`, all affected QAction `.cs` files, solution/project structure, package/tool manifests, and existing release/deployment metadata. Read-only routes must not mutate files.

Before planning, establish the review context:

- **Review profile**: `normal` by default, or explicit `first-release`.
- **Connector lifecycle**: draft, shipped maintenance, first Catalog release, or another explicit lifecycle.
- **Checklist file**: external path or attachment for the supplied OneNote checklist; never search the repository for a raw checklist copy.
- **Connection type**: from the connector plus caller confirmation where conditional rules depend on it.
- **Feature flags**: tables, writes, QActions, traps, DVE, DCF, Spectrum Analyzer, Matrix, topology, HTTP sessions, tests, and simulation.
- **Evidence supplied**: vendor documentation/MIB/API, simulation, QAOps/device target, Catalog/DCP records, human UI evidence, approvals, and test results.
- **Required human sign-offs**: named owners and any known exceptions or waivers.

Do not infer `first-release` from version, branch, NEW classification, scaffold state, or "pre-release" wording. If a first-release request lacks lifecycle or evidence context, carry the gap into the plan as `UNVERIFIED`/`BLOCKED`; do not silently default it or claim release readiness.

For **REVIEW** plans:
- Include the complete review context: profile, lifecycle, external checklist path, connection type, feature flags, supplied/missing evidence, human sign-offs, and the expected developer feedback format (`normal` remains the default).
- A `first-release` plan must state that the normal baseline runs first, the first-release matrix is loaded only after explicit opt-in, existing findings are not duplicated, and unresolved external/runtime evidence prevents a `READY` release verdict.
- See `dataminer-orchestrator/references/plan-templates.md#plan-format-review` for the complete Review Plan template.

---

## Task-Type-Specific Delegation

When delegating in Phase 4 (Implement), apply the route specific to the classified task type:

- **NEW**: Delegate to **dataminer-scaffolder** first, then follow Phase 4 delegation steps 1-8 if initial parameters were planned. Note that multipleGet on groups cannot be used for groups with table parameters in it, and the after-startup chain can still be used for one-time initialization (such as executing an initialization QAction), but must not be used to poll data that will be retrieved through a timer.
- **INVESTIGATION**: Delegate to **dataminer-investigator** for deep analysis. Present findings. If a fix is identified, ask user if they want to transition to BUGFIX workflow.
- **REVIEW**: Delegate to **dataminer-reviewer** with the complete approved Review Plan and all review-context fields. Incorporate validator results, row-level developer feedback, and separate AI code-review/release-readiness verdicts.
- **DOCUMENTATION**: Delegate to **dataminer-help-writer**. Pass the Connector Map so it knows the connector structure. Verify front matter, exact path/filename, conditional sections, TOC placement, topic UIDs, and links before completion.
- **TESTING**: Build the Connector Map and test/project map first; delegate only to `dataminer-test-writer`, then build and run the exact test project, followed by the official validator when production connector files were touched.
- **PACKAGING**: Do not delegate XML/C# authoring unless the package gate identifies a source defect. Use `dataminer-sdk` for SDK-style output or `dataminer-dmprotocol-packaging` for classic solutions, then verify package contents and build.
- **RELEASE**: Resolve version/branch/catalog inputs, run build, official validator, and compare/Major Change review when shipped behavior can change; use `dataminer-sdk` and `dataminer-dis` where applicable.
- **DEPLOYMENT**: Treat the connector/package as immutable input. Validate artifact identity and target environment first, then use the approved Catalog/package/QAOps deployment skill; do not re-author source as part of deployment. Contact `support.boost@skyline.be` if QAOps deployment or target provisioning fails.
- **MIGRATION**: Record source and target project/toolchain/package shapes in the Connector Map, preserve behavior through build/validator/compare gates, and require an explicit rollback or compatibility decision before release.

---

## Final Gate by Task Class

Run the task's required final gate after all workers finish:

| Class | Required final evidence |
|---|---|
| NEW / FEATURE / BUGFIX | `dotnet build --warnaserror` plus official validator; compare/Major Change review when shipped behavior may change |
| TESTING | Exact test project build and test result; official validator if production connector files changed |
| REVIEW / INVESTIGATION | Read-only findings with evidence; no mutation or success-shaped claim |
| DOCUMENTATION | Required page output plus front matter, exact path/filename, conditional-section, TOC/topic UID, and link validation |
| PACKAGING | Successful official package command, package-content inspection, and source/build identity |
| RELEASE | Build, official validator, version/release metadata, and compare/Major Change evidence when applicable |
| DEPLOYMENT | Immutable artifact hash/identity, target/environment confirmation, deployment result, and rollback evidence |
| MIGRATION | Source/target build, validator/compare result, compatibility decision, and rollback/migration evidence |
