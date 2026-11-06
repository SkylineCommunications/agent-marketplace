# GQI API and version matrix

> Parent skill: `dataminer-gqi-ad-hoc-data-source/SKILL.md`.

This matrix is a planning and review aid. Record the exact DataMiner
release/CU/build and Core package version used for an implementation. The
baseline is the **current/latest documented baseline at implementation time**.
The committed plan does not provide numeric gates for every GQI capability, so
unknown values must remain verification items.

## First-release API and project baseline

| Concern | First-release rule | Evidence/verification |
|---------|--------------------|-----------------------|
| API track | Modern Core GQI only: `Skyline.DataMiner.Core.GQI.Extensions`. | Confirm the package and symbols in the selected template/probe. |
| Legacy track | `Skyline.DataMiner.Analytics.GenericInterface` / `SLAnalyticsTypes` is out of scope for first-release authoring. | Existing legacy code needs an explicit migration/compatibility decision. |
| Template | `dataminer-gqi-ad-hoc-data-source-project`. | Verify the current SDK template output before editing. |
| Project type | `DataMinerType=AdHocDataSource` was observed in the probe. | Check the generated `.csproj`/project metadata. |
| Target framework | `net48` was observed in the probe. | Confirm the current template and target environment. |
| Library XML | `preCompile=true`; `libraryName` must not contain dots. | Inspect the generated library XML and preserve its contract. |
| Identity | Automation script name + library name + class name. | Treat any component rename as a consumer/deployment compatibility change. |
| Dependency bitness | GQI extension dependencies must be 64-bit compatible. | Check transitive dependencies before deployment. |

## Contract surface

| Capability | Documented shape | Gate handling |
|------------|------------------|---------------|
| Source minimum | `IGQIDataSource`, `GetColumns()`, `GetNextPage(...)`. | Use the exact Core package signatures; do not copy legacy signatures. |
| Input arguments | `IGQIInputArguments`. | Optional; add only when the source declares arguments and the selected version supports it. |
| Initialization | `IGQIOnInit`. | Optional; keep initialization cheap. |
| Fetch preparation | `IGQIOnPrepareFetch`. | Optional; use only for a documented preparation requirement. |
| Updates | `IGQIUpdateable`. | Record the target-version gate and prove delivery with a query smoke test. |
| Optimization | `IGQIOptimizableDataSource`. | Record the target-version gate before authoring. |
| Constructor/services | Constructor injection/services. | Record the target-version gate and verify package/template output. |
| Static columns | Static-column support. | Record the target-version gate; otherwise use the supported column contract. |
| Disposal | `IDisposable`. | Version-gated; do not add it solely as a cleanup habit. |
| Session access | GQI session access. | Version-gated; verify the current API before using it. |
| Row metadata | Row metadata support. | Version-gated; distinguish it from deterministic row keys. |
| Destruction | `IGQIOnDestroy`. | Optional; verify the lifecycle contract and avoid assuming one instance. |

Numeric gates for the capability rows above are intentionally not filled in
here. Resolve them from the current official GQI API documentation and the
selected Core package. A plan or generated source must say “verify” rather
than invent a DataMiner version.

## Migration and compatibility gates

Before adapting a legacy source:

1. Identify its script, library, and class identity and the queries that consume
   it.
2. Decide whether the deployment preserves that identity or intentionally
   publishes a new source.
3. Select a Core package/version compatible with the current/latest documented
   baseline and inspect the generated template.
4. Re-check every optional lifecycle interface; legacy presence is not proof of
   Core compatibility.
5. Run static checks and a compatible DMA query smoke test before declaring the
   migration complete.

## Official sources

- [GQI extension API tracks](https://aka.dataminer.services/GQI-extension-API)
- [Creating an ad hoc data source](https://aka.dataminer.services/ad-hoc-creation)
- [Ad hoc data-source lifecycle](https://aka.dataminer.services/ad-hoc-life-cycle)
- [GQI extension libraries and dependencies](https://aka.dataminer.services/gqi-extensions-libraries)
- [GQI extension architecture](https://aka.dataminer.services/gqi-extensions-architecture)
- [Core GQI Extensions package](https://www.nuget.org/packages/Skyline.DataMiner.Core.GQI.Extensions)
