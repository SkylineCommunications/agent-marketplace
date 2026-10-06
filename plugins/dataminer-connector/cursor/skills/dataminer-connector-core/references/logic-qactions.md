# QActions Logic

Authority scope: this file explains QAction runtime behavior and C# execution constraints. It is not the XML schema reference. For valid `QAction` XML attributes, enum values, and schema structure, use `dataminer-protocol-xml-reference`.

## QAction Role

QActions are C# logic blocks for behavior that cannot be implemented cleanly with parameters, groups, triggers, actions, or conditions.

Common use cases:

- Parsing JSON or complex payloads.
- Calculating derived values.
- Coordinating table updates.
- Performing API-dependent logic.
- Processing trap/all-binding data.
- Setting historical values.

Do not create QActions for simple if-checks, direct copies, increments, or queueing patterns that XML logic can express.

## Execution Process

- QActions run in `SLScripting`, a separate 32-bit process.
- Calls from a QAction to `SLProtocol` cross process boundaries.
- Minimize `SLProtocol` calls and batch reads/writes where possible.
- Long-running QActions block related protocol logic unless explicitly queued/asynchronous.
- Unhandled exceptions can have severe process impact; entry points should catch and log exceptions.

## Triggering

A QAction executes when any trigger parameter raises a change event. Parameter change-event rules are owned by `logic-parameters.md`.

## Entry Points

- The default entry point is a public `Run` method on a public `QAction` class in the global namespace.
- The default entry point receives `SLProtocol` unless an extended protocol API is intentionally used.
- Static entry points create a fresh method execution per trigger.
- Instance entry points create one class instance per element; the instance persists until SLScripting restart or element stop/restart/removal.
- Multiple entry points can map trigger parameters to specific methods.
- Entry point methods must be public methods of public classes.

`public static class QAction` must stay in the global namespace. Placing the entry point in a namespace prevents DataMiner's scripting engine from finding it.

## API Surface Ownership

Do not use `SLProtocol`, generated helper types, and package extension methods interchangeably.

| Surface | Owner | What it provides |
|---------|-------|------------------|
| `SLProtocol` | `SLManagedScripting.dll`, referenced through `Skyline.DataMiner.Dev.Protocol` | Core parameter, table, trigger, and logging APIs. |
| `Parameter`, `SLProtocolExt`, `{Table}QActionTable`, `{Table}QActionRow` | Generated `QAction_Helper` project | Connector-specific constants, named scalar properties, table properties, and typed row/table wrappers. |
| `GetColumns`, `SetColumns`, `GetColumn`, `SetCell`, `DeleteRows`, dictionary `SetParameters` | `Skyline.DataMiner.Utils.Protocol.Extension` | Optional package extension methods on `SLProtocol`; add the package and namespace explicitly. |

The following table operations are direct `SLProtocol` members in the current pinned Dev Pack and public API:

- [`FillArray`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-3c9b855b)
- [`FillArrayNoDelete`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-14a2b9b0)
- [`FillArrayWithColumn`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-718806b5)
- [`SetRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-set-row)
- [`AddRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-add-row)
- [`DeleteRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-4534d4e6)
- [`GetRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-get-row)
- [`GetKeys`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-ec1c4fd9)
- [`Exists`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-exists)
- [`CheckTrigger`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-2517552a)

Call those methods directly on `SLProtocol`. The generated `SLProtocolExt` interface inherits them. When using generated helper properties or tables, change the QAction entry point parameter directly to `SLProtocolExt protocol` (no casting inside the method). In legacy DataMiner versions before 10.1.1, several table methods were exposed as `NotifyProtocol` extension methods; verify the selected target and Dev Pack instead of applying current assumptions to an older target.

[`GetColumns`](https://aka.dataminer.services/skyline-data-miner-utils-protocol-exten-9611364a) and [`SetColumns`](https://aka.dataminer.services/skyline-data-miner-utils-protocol-exten-76840d10) are package extension methods. They are invoked on an `SLProtocol` instance only after referencing `Skyline.DataMiner.Utils.Protocol.Extension` and importing its namespace.

Generated helper types are optional conveniences:

- [`Parameter`](https://aka.dataminer.services/skyline-data-miner-scripting-parameter) centralizes generated parameter, table, column PID, and column index constants.
- [`SLProtocolExt`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-ext) adds connector-specific scalar and table properties.
- [`QActionTable`](https://aka.dataminer.services/skyline-data-miner-scripting-q-action-table) binds table operations to one table ID.
- [`QActionTableRow`](https://aka.dataminer.services/skyline-data-miner-scripting-q-action-table-row) supplies typed generated row subclasses and object-array conversion.

When the existing solution consumes those generated members and `protocol.xml` changes their names, IDs, types, or table layout, refresh the helper with the approved generator and build. When the solution is intentionally helper-free, keep IDs in descriptive local constants and use `SLProtocol` directly. Do not add helper generation as a completion gate merely because XML changed.

## Input Parameters And Reads

`inputParameters` values are captured at QAction start time.

- Use `inputParameters` when the QAction needs a consistent snapshot at start.
- Use table input parameters only when the QAction needs the whole table.
- `SLProtocol.GetParameter` and related APIs read current values at call time.
- Batch reads with multi-parameter APIs when possible.

## Writes And Blocking

`SetParameter` can synchronously trigger logic before the QAction continues.

- If the set triggers direct actions/triggers/QActions, the call blocks until they complete.
- If the set only queues a group, the call returns after queue insertion.
- `CheckTrigger` follows the same blocking rule.

Design with this distinction in mind. Do not assume a queued group has already executed after `SetParameter` or `CheckTrigger` returns.

## Row Context

Row context is used for row-triggered table QActions and timer row patterns.

Available row context includes:

- Row index.
- Primary key.
- Previous row values.
- New row values.

Use row context only when the triggering/polling pattern supports it and row-specific behavior is required.

## Compilation And DLLs

- C# QActions compile to DLLs.
- The official connector template currently includes a generated helper project and QAction project reference by default.
- That helper reference is required only when source code consumes generated `Parameter`, `SLProtocolExt`, table, or row types. A helper-free QAction project can compile against `Skyline.DataMiner.Dev.Protocol` alone.
- Without precompile behavior, compilation happens on first trigger.
- Shared/no-trigger QActions should be precompiled.
- Referenced generic QActions must be precompiled and defined earlier when another precompiled QAction depends on them.
- Use protocol name/version placeholders in DLL imports to avoid version churn.
- Edited QAction DLLs require an element restart to load new versions.
- Edited third-party DLLs require a DataMiner restart.
- QActions compile with C# up to 7.3 and run against the .NET Framework available to DataMiner.

Reusable code should live in a shared precompiled QAction rather than being duplicated in individual QActions.

## Queued And Concurrent QActions

Queued QActions execute asynchronously.

- They can allow other QActions or protocol logic to run before they finish.
- Use only when necessary.
- Synchronize shared state.
- Avoid static fields for element-specific state because the same protocol version can run for multiple elements.
- Persist state across element restarts in saved parameters, not member fields.

## Tables From QActions

- Batch table updates where possible.
- Avoid clearing entire tables when selective row removal or fill-array behavior is sufficient.
- For DCF-generating tables, avoid frequent updates and direct table-change QActions because interface creation is asynchronous and can cause deadlocks or stale reads.
- Fill display-key and identity columns before alarm-capable or trended values.

## History Sets From QActions

- History sets can only be performed from QActions.
- History-set ordering and timeout side effects are owned by `logic-parameters.md`.

## WebSocket Data In QActions

- WebSocket outgoing frames default to binary unless the command specifies text frame behavior.
- In Unicode protocols, WebSocket UTF-8 response bytes stored in string parameters may need binary QAction input and manual decoding.
- Do not assume plain string input preserves raw WebSocket UTF-8 bytes.

## Logging And Exceptions

- Log enough context to identify the QAction and operation.
- Use full exception text, including stack trace, when logging exceptions.
- Avoid logging only exception messages.
- Keep entry point wrappers concise and fail-safe.

## Automation And External Work

- Starting automation scripts from QActions is possible but should be deliberate.
- File and external process work can block or destabilize protocol execution; use it only when required and handle errors explicitly.
- Third-party DLLs cannot be unloaded once loaded; updating them requires DataMiner restart.

## Performance Rules

- Minimize IPC calls.
- Batch parameter reads and writes.
- Keep QActions focused.
- Avoid long-running work on critical paths.
- Prefer official utility packages over custom implementations for rates, SNMP helpers, safe conversion, table context menus, and testing support.
