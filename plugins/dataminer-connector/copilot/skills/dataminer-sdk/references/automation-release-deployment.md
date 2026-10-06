# Automation Release and Deployment

Use this reference after an Automation project builds and its tests pass. Release, Catalog publication, deployment, and runtime verification are separate gates.

## Release shape

1. Confirm the SDK project is `DataMinerType=AutomationScript` or the intended Automation library/package type.
2. Record the selected Dev Pack, analyzer versions, target DataMiner minimum version, semantic version, and `VersionComment`.
3. Run `dotnet build` with Skyline analyzers and produce the official `.dmapp` through SDK publish/packaging. Never handcraft the archive.
4. Validate `CatalogInformation/README.md` and `manifest.yml` with `dataminer-catalog-hygiene`. Keep the stable Catalog ID unchanged across versions; do not invent an ID or owner.
5. Inspect the package contents and record the source commit, artifact name/version, and SHA-256.

## Publication, deployment, and verification

| Gate | Official route | Evidence |
|---|---|---|
| Package | `dotnet publish`/SDK package output or the official DataMiner packager | Fresh `.dmapp`, contents, version, source identity, hash |
| Catalog publication | Official CatalogUpload route | Explicit Catalog target, upload result, artifact identity, metadata result |
| Deployment | Official DataMinerDeploy/Catalog/QAOps route | Target environment, deployed version/hash, permissions, rollback |
| Runtime verification | `dataminer-qaops-integration-testing` or the approved live route | Exact deployed artifact, host/invocation, selected tests, logs, result |

An upload is not a deployment, and a deployment is not runtime verification. Treat failed or partial gates as visible failures; do not report success-shaped completion from a command that only built or uploaded an artifact.

## Automation-specific checks

- SDK C# `Exe` linkage remains exactly `[Project:<intended-project-name>]`.
- DMSScript is validated against the pinned Automation XSD.
- Credentials, permissions, host, timeout, IAS interactivity, and post-deploy test route are recorded in the release plan.
- Rollback identifies the previous immutable artifact and the target-specific restoration command; never overwrite a release artifact in place.
