# GQI lifecycle and validation

> Parent skill: `dataminer-gqi-ad-hoc-data-source/SKILL.md`.

## Contract flow

An ad hoc source is a compiled library discovered by GQI. The runtime can
create instances for argument discovery, column resolution, and query
execution. Therefore, do not rely on a single constructor/instance or on one
fixed callback order.

The minimum source contract is:

| Stage | Contract responsibility |
|-------|-------------------------|
| Discovery/columns | Implement `IGQIDataSource`; return the documented Core GQI column collection from `GetColumns()`. |
| Arguments | Add `IGQIInputArguments` only when arguments are part of the source contract; validate values before use. |
| Initialization | Use `IGQIOnInit` only for inexpensive setup. Slow retrieval does not belong here. |
| Preparation | Use `IGQIOnPrepareFetch` only when the selected API/version supports and requires preparation. |
| Fetch | Implement `GetNextPage(...)`; return the documented `GQIPage` shape and explicit continuation state. |
| Updates | Use `IGQIUpdateable` only when update delivery is required and version-verified. Protect shared state. |
| Cleanup | Use `IGQIOnDestroy`/`IDisposable` only when the selected contract supports them and cleanup is needed. |

The plan names `GetNextPageInputArgs`, `GQIColumn[]`, and `GQIPage`; use the
exact Core package signatures rather than reproducing a signature from a
different API track.

## Paging and row semantics

- `GetNextPage` is lazy and can be called repeatedly while `HasNextPage` is
  true. Keep a clear cursor/page state and terminate deterministically.
- Keys must be deterministic across pages and repeated query executions.
- Do not derive identity from a non-key attribute that can collapse distinct
  entities. Validate the expected and emitted cardinality in pure logic where
  possible.
- Define empty-result, invalid-argument, source-error, and end-of-data
  behavior. Do not use normal Automation exit calls as a substitute for a
  `GQIPage` result.
- If updates are supported, define how a changed row maps to its stable key
  and how disposal/termination stops callbacks.

## Concurrency and dependency boundaries

Lifecycle and update callbacks may be concurrent. Synchronize mutable shared
state, make cancellation/cleanup decisions explicit, and avoid holding locks
while doing slow external work.

Do not reference `Skyline.DataMiner.Automation` from the extension library.
Use 64-bit-compatible dependencies and the verified Core GQI package. A helper
that separately runs as an Automation script has a different host contract and
must be reviewed separately.

## Validation matrix

| Level | Proves | Does not prove |
|-------|--------|---------------|
| Pure unit tests | Argument validation, cursor/page calculations, mapping, stable-key and cardinality logic. | GQI discovery, host lifecycle, or query execution. |
| Build/analyzers | Core package resolves; interface/lifecycle shape compiles; project/XML metadata is present. | That the runtime discovers the library or delivers rows. |
| Static contract review | Identity, `preCompile`, dot-free `libraryName`, no legacy track, 64-bit dependency intent, and no normal exit misuse. | Runtime configuration, deployed identity, or live query output. |
| DMA query smoke test | Source discovery, display name, arguments, columns, multiple pages, row keys, applicable updates, and logs. | Behavior on an incompatible version or an undeployed library. |

There is no official standalone GQI unit-test host identified in the plan.
Runtime evidence therefore requires a compatible DMA/approved QAOps target.
If it is unavailable, report the limitation; do not weaken the static checks or
call a local build end-to-end proof.

## Validation checklist

- [ ] Target DataMiner release/CU/build and Core package version are recorded.
- [ ] The current template output was inspected before code generation.
- [ ] Script, library, and class identity are stable or the rename is explicitly planned.
- [ ] `IGQIDataSource` and exact Core signatures compile.
- [ ] Optional interfaces have a stated requirement and a verified version gate.
- [ ] Columns and row keys are deterministic.
- [ ] Multiple pages and end-of-data behavior are tested.
- [ ] Concurrent update/lifecycle state is synchronized when applicable.
- [ ] A DMA query smoke test is recorded, or its absence is visible as a limitation.
