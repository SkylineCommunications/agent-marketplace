---
name: dataminer-polling-manager
description: Polling Manager implementation pattern for DataMiner connectors. Provides configurable per-data-set polling intervals, enable/disable controls, parent/child dependencies, context menu actions, and response handling. Based on the official Skyline example connector.
argument-hint: 'Describe the polling manager task: e.g. "add a polling manager to my connector", "configure polling data sets for 3 tables", "add parent/child dependency between poll entries"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-06-01
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-01 | Initial release. Full polling manager pattern from SLC-C-Example_Polling-Manager. |

---

# DataMiner Polling Manager

## Overview

A **Polling Manager** provides configurable polling within connectors where data sets need individually adjustable poll intervals, enable/disable control, dependency chains, and status tracking. It is NOT intended for all connectors — only use it when the operator needs runtime-configurable polling per data set.

**Reference implementation**: https://github.com/SkylineCommunications/SLC-C-Example_Polling-Manager (branch `1.0.0.X`)

> **This is a full working example.** When implementing a polling manager, clone the pattern from this repository. Read the full source to understand the architecture before adapting it to the target connector.

## When to Use

- Connector polls multiple independent data sets (tables, scalar groups)
- Each data set needs a **configurable polling interval**
- Operator needs to **enable/disable** individual data sets at runtime
- Data sets have **dependencies** (e.g., "PVST depends on VLAN and Interfaces")
- Data sets have a **mandatory** flag (cannot be disabled)
- Need status tracking: last poll time, success/failure, execution time

## Architecture

The polling manager uses a **singleton pattern** (`PollingManagerContainer`) per element, stored in a `ConcurrentDictionary` keyed by `DataMinerID/ElementID`. It is:

- **Initialized** in the After Startup QAction
- **Checked every timer tick** (typically 1s) to poll due entries
- **Driven by XML triggers/actions** for group execution and response processing

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│  XML Layer (protocol.xml)                               │
├─────────────────────────────────────────────────────────┤
│  Timer (1s) → Group 990 → Action → QAction 990         │
│  Polling Manager Table (PID 1000) on Element Settings   │
│  Context Menu button (PID 997)                          │
│  Write params: Interval (1054), AdminStatus (1056),     │
│                Poll button (1057)                        │
│  Per-data-set: Poll Group → Trigger (after) → Action →  │
│                Process param → QAction 61000            │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  C# Layer (QAction_1 precompiled library)               │
├─────────────────────────────────────────────────────────┤
│  GenericAPI/                                            │
│    PollingManagerContainer.cs  - Singleton per element  │
│    PollingManager.cs           - Core logic             │
│    Pollable/                                           │
│      IPollable.cs              - Interface              │
│      PollableBase.cs           - Base class             │
│      GenericPoll.cs            - Default implementation │
│      PollingManagerConfigurationBase.cs - Abstract cfg  │
│    Handlers/                                           │
│      ResponseHandler.cs        - Response processing   │
│    Enums/                                              │
│      AdminState, PollStatus, Column, etc.              │
│  CustomCode/                                           │
│    Configuration/                                      │
│      PollEntry.cs              - Enum of data sets     │
│      PollingManagerConfiguration.cs - Concrete config  │
│    PollEntrys/                                         │
│      Custom PollableBase subclasses per data set       │
│    ResponseHandlers/                                   │
│      Per-data-set response processing                  │
│    ClearParameters/                                    │
│      Per-data-set parameter clearing on disable        │
└─────────────────────────────────────────────────────────┘
```

### QAction Responsibilities

| QAction | Trigger | Purpose |
|---------|---------|---------|
| QAction 1 | precompile | Shared library containing all PollingManager classes |
| QAction 2 | After Startup (param 2) | `PollingManagerContainer.InitiateManagerAfterStartup(protocol)` |
| QAction 990 | Timer tick (param 990) | `PollingManagerContainer.GetManager(protocol).CheckForUpdate()` |
| QAction 997 | Context menu (param 997) | `PollingManagerContainer.GetManager(protocol).HandleContextMenu(contextMenu)` |
| QAction 1050 | Row sets (params 1054, 1056, 1057) | `GetManager(protocol).HandleRowUpdate(rowKey, column, value)` — `row="true"` |
| QAction 61000 | Response params (61001, 61002, ...) | `GetManager(protocol).ProcessResponse(triggerId)` |

---

## XML Structure

### Polling Manager Table (PID 1000)

| Column | PID | Name | Type | Description |
|--------|-----|------|------|-------------|
| 0 (PK) | 1001 | Name | string | Data set name (key) |
| 1 | 1002 | ID | double | Numeric ID (auto-assigned) |
| 2 | 1003 | Description | string | Human-readable description |
| 3 | 1004 | Interval | double (time) | Custom poll interval (seconds) |
| 4 | 1005 | Suggested Interval | double (time) | Default/recommended interval |
| 5 | 1006 | Admin Status | discreet (toggle) | Enabled(1)/Disabled(0) with row coloring |
| 6 | 1057 | Poll | button | Manual poll trigger |
| 7 | 1008 | Last Polled Time | datetime | When entry was fully processed |
| 8 | 1009 | Last Poll Status | discreet + alarm | Failed(0)/Succeeded(1) |
| 9 | 1010 | Last Poll Status Info | string | Error details |
| 10 | 1011 | Last Poll Execution Time | datetime | When poll was initiated |

### Key XML Elements

- **Table** on `Element Settings` page, with `NamingFormat` `,1002` (display key = ID column)
- **Write params**: 1054 (Interval), 1056 (Admin Status toggle), 1057 (Poll button)
- **Context Menu** (PID 997): Enable, Enable (Forced), Disable, Disable (Forced), Poll, Enable All, Disable All, Poll All, Reset to Default — with `table:selection` and `separator` options
- **Dummy param** 990: trigger target for the timer-driven process loop
- **Timer** (1s, `fixedTimer="true"`): contains Group 990

### Per-Data-Set Polling Flow

For each pollable data set that uses trigger-based polling:

1. **Group** (e.g., 60001): Empty `<Content>` or with session/pair — the actual poll group
2. **Trigger** (e.g., 60001): Fires Action to execute the poll group (`execute one`)
3. **After-group Trigger** (e.g., 61001): `<On id="60001">group</On> <Time>after</Time>` → fires response action
4. **Action** (e.g., 61001): `<On id="61001">parameter</On> <Type>run actions</Type>` — triggers QAction 61000
5. **Process parameter** (e.g., 61001): `read` param that triggers QAction 61000

The `CheckTrigger` call from `PollableBase.InitiatePoll()` kicks off this chain.

---

## Implementation Steps

When adding a polling manager to a connector:

### 1. XML Changes

1. Add the Polling Manager table (PID 1000) with all columns
2. Add write parameters (1054, 1056, 1057) and context menu (997)
3. Add dummy param 990 and its group/action
4. Add a 1-second `fixedTimer` containing group 990
5. For each data set: add a poll group, trigger chain, and process parameter
6. Add `Element Settings` page to `pageOrder`
7. Wire the After Startup trigger to activate the timer

### 2. C# Changes

1. Copy the `GenericAPI` folder as-is (this is the reusable framework)
2. Create `CustomCode/Configuration/PollEntry.cs` — enum of your data sets
3. Create `CustomCode/Configuration/PollingManagerConfiguration.cs`:
   - Define rows with `GenericPoll` or custom subclasses
   - Configure dependencies, relations, response handlers, clear-parameter rules
4. Create custom `PollableBase` subclasses for data sets that need custom `Poll()` or `PrePollConfiguration()` logic
5. Create response handlers for trigger-based data sets
6. Create clear-parameter configurations per data set
7. Wire QActions: After Startup (init), 990 (process), 997 (context menu), 1050 (sets), 61000 (responses)

### 3. Key Patterns

**Singleton per element** — `ConcurrentDictionary<string, PollingManager>` keyed by `"{DataMinerID}/{ElementID}"`. The container class is `static` and lives in QAction 1 (precompiled).

**Trigger-based polling** — For data sets that poll external data via groups: set `TriggerId` to the trigger ID. `InitiatePoll()` calls `Protocol.CheckTrigger(TriggerId)` which starts the XML trigger chain. The response arrives asynchronously and is processed by the response QAction.

**In-code polling** — For data sets that process data entirely in C#: leave `TriggerId = 0` and implement `Poll()`. Returns `PollableType.ProcessInCode`.

**Parent/Child dependencies** — Use `AddChildren(params IPollable[])`. Disabling a parent shows a warning listing enabled children. Enabling a child with disabled parents shows a warning. Force Enable/Disable overrides dependency checks.

**Mandatory rows** — Set `Mandatory = true`. Cannot be disabled (shows info message).

**Dependencies on parameter values** — Use `AddDependency(paramId, new Dependency(expectedValue, shouldEqual, message))`. If dependency not satisfied, poll is skipped and message shown in Status Info.

**Clear parameters on disable** — Use `AddParameters(singleParams, tableParams)` via `ClearParametersConfiguration`. When disabled, linked params are reset and tables cleared.

---

## Reference Files

| File | Contents |
|------|----------|
| `references/polling-manager-example.md` | Detailed code examples from the official example connector |

---

## Constraints

- The Polling Manager table should be on the `Element Settings` page.
- Use a 1-second `fixedTimer` with `initial="false"` for the process loop.
- The GenericAPI code is **reusable as-is** — only customize `CustomCode/`.
- Always include `precompile` option on QAction 1 (shared library).
- Context menu QAction needs `object contextMenu` as second parameter.
- Row-set QAction (1050) needs `row="true"` attribute on `<QAction>`.
- Response QAction triggers should list all process parameter IDs separated by `;`.
- The connector type is typically `virtual` (polling manager manages its own timing via `CheckTrigger`), but can also be used alongside `snmpv2`, `http`, etc. with appropriate connection types.
