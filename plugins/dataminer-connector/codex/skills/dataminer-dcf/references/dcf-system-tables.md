# DCF System Tables

> **Parent skill**: `dataminer-dcf/SKILL.md`

DataMiner maintains four system tables for DCF data. These tables are automatically populated by the platform — connectors read from them but should not write to them directly (use the DCF API or Helper class instead).

Reference: https://aka.dataminer.services/advanced-dcf-tables

**All parameter IDs in range 65049–65102 are reserved for DCF system tables. Never define custom parameters in this range.**

---

## 1. Interfaces Table (PID 65049)

Stores all DCF interfaces defined on the element.

| Column PID | Name | Description |
|------------|------|-------------|
| 65050 | Interface ID | Unique interface identifier |
| 65051 | Interface Name | Display name (from ParameterGroups Group name, plus display key for dynamic) |
| 65093 | Interface Custom Name | User-defined custom name (overrides default name in UI) |
| 65052 | Interface Type | `"in"`, `"out"`, or `"inout"` |
| 65053 | Interface Alarm State | Current alarm severity of the interface |
| 65095 | Interface Dynamic Link | For dynamic interfaces: reference to the source table row |

---

## 2. Interface Properties Table (PID 65054)

Stores properties (metadata) attached to interfaces.

| Column PID | Name | Description |
|------------|------|-------------|
| 65082 | Property ID | Unique property identifier |
| 65055 | Property Name | Property name/key |
| 65056 | Property Type | Property type/category |
| 65057 | Property Value | Property value |
| 65059 | Property Link | Reference to the parent interface |

---

## 3. Connections Table (PID 65060)

Stores all DCF connections (both internal and external).

| Column PID | Name | Description |
|------------|------|-------------|
| 65061 | Connection ID | Unique connection identifier |
| 65096 | Connection Name | Display name of the connection |
| 65062 | Source Interface | Interface ID of the source (input for internal, output for external) |
| 65089 | Destination DataMiner/Element | DMA ID / Element ID of the destination element (for external connections) |
| 65064 | Destination Interface | Interface ID of the destination (output for internal, input for external) |
| 65101 | Connections Filter | Optional filter value for connection categorization |

---

## 4. Connection Properties Table (PID 65068)

Stores properties (metadata) attached to connections.

| Column PID | Name | Description |
|------------|------|-------------|
| 65083 | Property ID | Unique property identifier |
| 65069 | Property Name | Property name/key |
| 65070 | Property Type | Property type/category |
| 65071 | Property Value | Property value |
| 65073 | Property Link | Reference to the parent connection |

---

## Important Notes

- **RTDisplay**: DCF system tables require `RTDisplay` to be enabled for the columns to be visible in the UI.
- **Read-only**: These tables are managed by the DataMiner platform. Use the DCF API (`ConnectivityConnection`, `ConnectivityInterface` classes) or the DCF Helper NuGet package to create, update, or delete interfaces and connections programmatically.
- **Do not trigger QActions on these tables**: Setting up triggers on DCF system table parameter changes (65049–65102) creates deadlock risk with SLNet. If you need to react to DCF changes, use a custom intermediary table.
- **Reserved range**: Parameter IDs 65049–65102 are reserved. See the [Reserved Parameter IDs](https://aka.dataminer.services/reserved-i-ds-element-control-protocol) reference for the complete list.
