# Execution Flow And Runtime Architecture

Authority scope: this file explains DataMiner runtime behavior. It is not the XML schema reference. For valid XML elements, attributes, enum values, fixed values, ID patterns, and keyrefs, use `dataminer-protocol-xml-reference`.

## Process Roles

DataMiner connector logic runs across several cooperating processes:

| Process | Runtime role |
|---|---|
| `SLDataMiner` | Central process. Starts/stops/configures elements, manages external SETs, and owns the per-element SetParameter thread. |
| `SLProtocol` | Executes protocol logic. Elements are distributed over multiple `SLProtocol` instances. Each element has a main protocol execution thread and timer threads. |
| `SLScripting` | Executes QAction C# code in a separate 32-bit process. |
| `SLElement` | Tracks `RTDisplay=true` parameters, table display keys, alarms, and other externally visible element state. |
| `SLSNMPManager` | Handles SNMP communication. |
| `SLPort` | Handles serial and IP port communication. |
| `SLNet` | Handles client and inter-DMA communication. |
| `SLWatchdog` | Monitors DataMiner processes and detects anomalies. |

## Entry Points

- Each protocol connection creates an entry point.
- An entry point processes one request at a time.
- Requests from any queue type can block each other when they use the same entry point.
- Default behavior links entry points to the main protocol queue.
- Additional queues can be declared through `Threads`; keep extra threads limited because they add system load.

## Core Runtime Loop

```text
Timers and external SETs
  -> group execution queue
  -> group item execution
  -> parameter updates
  -> triggers/actions/QActions
  -> display, alarms, trends, and external consumers
```

Important consequences:

- A group item is finished only after the item and directly linked logic finish.
- Adding a group to the queue is non-blocking.
- Executing trigger/action/QAction logic can be blocking.
- Long trigger/action cascades keep the current entry point busy and delay later work.

## Threading Model

### SetParameter Thread

Each element has a dedicated SetParameter thread in `SLDataMiner`:

- Handles external SETs from UI, automation, Visio, WorkFlow Manager, element connections, and data distribution.
- SETs for the same element are processed sequentially.
- SETs for different elements can run simultaneously.
- SET handling transfers to `SLProtocol` only when the relevant entry point is available.

### Protocol Thread

The main protocol thread in `SLProtocol`:

- Owns the main group execution queue.
- Processes queued groups sequentially.
- Starts after element initialization.
- Removes a group from the queue before executing it.

### Timer Threads

- Every timer definition creates an additional timer thread.
- Timer scheduling and timer-thread execution details are owned by `logic-groups-timers.md`.

### QAction Threads

- QActions execute in `SLScripting`.
- Calls from a QAction back to `SLProtocol` are inter-process communication and should be minimized.
- QActions can run concurrently when multiple protocol threads or queued/async patterns are involved.
- Shared state must be synchronized explicitly.

## Group Execution Queue

The protocol thread owns a priority queue for group execution. Action-specific queue positions are owned by `logic-triggers-actions.md`.

## Startup Sequence

1. DataMiner reads protocol configuration.
2. Parameters, commands, responses, pairs, groups, timers, triggers, actions, QActions, and sessions are initialized.
3. Stored parameter values are loaded.
4. Templates are loaded.
5. Timer threads start.
6. Protocol thread starts.
7. After-startup triggers run before the element is fully operational.
8. The protocol queue starts processing and the element becomes safe for normal interaction.

The after-startup chain can still be used for one-time element initialization (such as executing an
initialization QAction or initializing internal variables). However, do not use after-startup
triggers or actions to poll device data if that same data will be retrieved through a timer. Timers
already start during initialization; use `<Time initial="true">` on the timer when an immediate
first poll is required.

After-startup trigger/action patterns are owned by `logic-triggers-actions.md`.

## Connection Models

DataMiner has a legacy/main connection model and a newer `Connections` model.

Legacy/main model behavior:

- Main connection ID is `0`.
- Additional connection IDs increment by declaration order.
- `Type@advanced` entries and additional port settings order determine additional connection mapping.
- `PortSettings@name` does not determine the connection ID.

Connection targeting behavior:

- Groups and actions default to connection `0`.
- Use explicit group, action, pair, response, or parameter connection targeting for non-main connections.
- Dynamic group connection selection uses a parameter whose value is the zero-based connection index.
- Mixed connection XML is valid only when the connector actually declares the connection families involved.

## Dynamic IP

Dynamic IP behavior is connection-family specific:

- Dynamic IP parameters are read string parameters using documented dynamic IP options.
- `dynamic ip` and `dynamic ip 0` target the main connection.
- `dynamic ip n` targets connection ID `n`.
- Values are generally `IP:PORT`, with connection-specific URL rules.
- HTTP can use HTTPS by specifying `https://` in the element address or dynamic IP value when a non-default HTTPS port is used.
- WebSocket dynamic IP can contain the complete WebSocket URL.
- Smart-serial dynamic IP is client-only and cannot switch server/client mode at runtime.
- For serial and smart-serial dynamic polling, prefer single connection types to avoid shared socket side effects.

## Redundant Polling

- Redundant polling requires exactly two connections of the same family.
- Supported redundant families include two SNMP, two serial, two smart-serial, or two HTTP connections.
- Redundant polling does not switch for SNMP gets from QActions.
- Redundant polling does not switch for groups pinned to a connection.
- For smart-serial redundant polling, a pair normally needs a response to trigger timeout switching unless protocol logic explicitly sets communication state.

## SLElement

`SLElement` owns externally visible element state such as real-time display values, table display identity, and alarms. Parameter-level `RTDisplay` decisions are owned by `logic-parameters.md`.

## Advanced Runtime Features

### DVE

- A DVE corresponds to a row in a parent table.
- Fill DVE primary/display key data before alarm-capable child values so child alarms receive the correct identity.
- Changing generated DVE protocol names or element-prefix behavior can break parent-child relationships.
- DVE timeout behavior is not automatically identical to parent timeout behavior unless explicitly configured.

### DCF

- DCF interface tables should be relatively static and available to `SLElement`.
- Dynamic DCF interface creation is asynchronous.
- Avoid QActions triggered directly by frequent updates on DCF-generating tables, because this can cause deadlocks, stale reads, or heavy alarm recalculation.
- Adding DCF to an existing connector should be disabled by default when performance impact is uncertain.

### Topology, Tree, And Alarm Bubble-Up

- Relations and foreign keys define how tables link for topology and tree-style UI.
- A local element cannot refer to remote table data unless it knows the relevant primary keys and links.
- Alarm aggregation through topology tables depends on relation paths and severity bubble-up direction.

## RTE Prevention

- Keep protocol-thread work short.
- Avoid long trigger/action cascades.
- Avoid sleeping on protocol-critical paths.
- Use queued execution for long work instead of blocking the current entry point.
- Batch QAction calls to `SLProtocol` to reduce inter-process communication.
