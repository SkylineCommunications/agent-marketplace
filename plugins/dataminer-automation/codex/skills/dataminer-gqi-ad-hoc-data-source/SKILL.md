---
name: dataminer-gqi-ad-hoc-data-source
description: 'Author and review DataMiner GQI ad hoc data-source libraries: modern Core GQI contracts, library identity/XML, lifecycle and paging, version gates, and query-level validation.'
argument-hint: 'Describe the GQI source: e.g. "create an ad hoc source with arguments and paging", "migrate a legacy source to Core GQI", or "debug why a source is not discovered".'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-15
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-15 | Initial release for modern Core GQI ad hoc data-source authoring and review. |

# DataMiner GQI ad hoc data sources

Load `dataminer-automation-core` first, then use this skill when the source is a
compiled GQI ad hoc data source consumed by a GQI query in Dashboards or Low-Code
Apps. This is a library contract, not a normal `Run(IEngine)` Automation script.
Use `dataminer-sdk` for scaffolding and the QAOps skills for an approved
DataMiner-hosted test.

## Route and first-release baseline

1. Classify the contract as **GQI ad hoc** before authoring. Do not route it
   through the normal Automation exit-state checklist.
2. Record the target DataMiner release/CU/build. The baseline is the
   **current/latest documented baseline at implementation time**; do not
   silently target an older observed template.
3. The first release supports **modern Core GQI only**:
   `Skyline.DataMiner.Core.GQI.Extensions`. The legacy
   `Skyline.DataMiner.Analytics.GenericInterface` / `SLAnalyticsTypes` track is
   explicitly out of scope for first-release authoring. A legacy-to-Core
   migration is a compatibility and deployment decision, not an automatic
   rewrite.
4. For a new project, use the official template short name
   `dataminer-gqi-ad-hoc-data-source-project`, create a solution, and build the
   generated project before editing it. The observed project shape is
   `DataMinerType=AdHocDataSource` and `net48`; verify the current template
   output and package references before relying on either.

## Contract and identity

| Area | Rule |
|------|------|
| Required source | Implement `IGQIDataSource` with `GetColumns()` and `GetNextPage(...)` using the exact signatures exposed by the selected Core package. |
| Results | Return the Core GQI column/page types (`GQIColumn[]` and `GQIPage` in the documented contract) and stable row keys. |
| Optional behavior | Add `IGQIInputArguments`, `IGQIOnInit`, `IGQIOnPrepareFetch`, `IGQIUpdateable`, `IGQIOptimizableDataSource`, `IGQIOnDestroy`, or `IDisposable` only for a stated requirement and only when the selected version supports it. |
| Discovery identity | The consumer-facing identity is the combination of Automation script name, library name, and class name. Treat any rename as a query/deployment compatibility change. |
| Library XML | Use the GQI library XML shape from the official template, including `preCompile=true` and a dot-free `libraryName`. Do not substitute a normal `DMSScript` XML definition. |

## Authoring rules

- Keep `GetColumns()` cheap and deterministic. Do not perform slow retrieval
  during `OnInit`; put work in the lifecycle phase that owns that operation.
- Treat `GetNextPage` as lazy and repeatable: it may be called while
  `HasNextPage` is true. Keep explicit paging state, stop at the requested
  page boundary, and make row keys deterministic across pages and executions.
- Validate input arguments before using them. Define the behavior for an empty
  result and for an invalid or unsupported argument.
- Lifecycle instances can be created for argument discovery, column
  resolution, and query execution. Do not assume one instance or one call
  sequence.
- Update callbacks and lifecycle methods may run concurrently. Protect shared
  state with an appropriate synchronization design; do not assume callbacks are
  serialized.
- Do not reference `Skyline.DataMiner.Automation` from GQI extension code.
  Keep dependencies 64-bit compatible and use only packages verified for the
  selected API track.
- Do not call normal Automation `ExitSuccess`/`ExitFail` for a GQI page return.
  A separately hosted helper may have its own Automation contract, but that
  does not change the source contract.

## Configuration, deployment, and version gates

The source is discovered by the GQI runtime only after the script/library/class
identity, library XML, package, and deployment target agree. Preserve the
identity in plans and review rename impact on existing queries. Record the
selected Core package version and DataMiner baseline.

The Core documentation has capability gates for updates, optimizer support,
constructor injection/services, static columns, `IDisposable`, session access,
and row metadata. The plan does not provide safe numeric gates for these
features. Resolve each gate from the current official documentation and the
selected package/template probe; if it is unresolved, leave the feature out or
mark it as a limitation rather than guessing.

## Validation boundary

1. **Static:** build the solution with the selected package and Skyline
   analyzers; check the project type, Core package, library XML, interface
   shape, no `Skyline.DataMiner.Automation` reference, deterministic keys, and
   paging state.
2. **Host/query:** on a compatible DMA, run a GQI query and verify source
   discovery, display name, arguments, columns, multiple pages, row keys,
   update behavior when applicable, and useful logs.
3. There is no official standalone GQI unit-test host in the plan. Unit tests
   can cover pure paging/mapping logic, but a local build does not prove GQI
   discovery or query execution. Report missing DMA/QAOps access as a visible
   limitation.

## Forbidden assumptions

- Do not generate the legacy `SLAnalyticsTypes` shape while claiming Core GQI.
- Do not copy a legacy signature into a modern source without verifying the
  selected package.
- Do not treat script/library/class renames as cosmetic.
- Do not claim build success proves discovery, query paging, or update delivery.
- Do not invent version numbers for the capability gates listed above.

## References

- [API and version matrix](references/gqi-api-and-version-matrix.md)
- [Lifecycle and validation](references/gqi-lifecycle-and-validation.md)
- [Creating an ad hoc data source](https://aka.dataminer.services/ad-hoc-creation)
- [Ad hoc data-source lifecycle](https://aka.dataminer.services/ad-hoc-life-cycle)
- [GQI extension API tracks](https://aka.dataminer.services/GQI-extension-API)
- [GQI extension best practices](https://aka.dataminer.services/gqi-extensions-best-practices)
- [GQI extension libraries and dependencies](https://aka.dataminer.services/gqi-extensions-libraries)
- [GQI runtime architecture](https://aka.dataminer.services/gqi-extensions-architecture)
- [Core GQI Extensions package](https://www.nuget.org/packages/Skyline.DataMiner.Core.GQI.Extensions)
