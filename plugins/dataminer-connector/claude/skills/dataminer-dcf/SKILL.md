---
name: dataminer-dcf
description: 'DataMiner Connectivity Framework (DCF) for connector development: physical/logical interfaces, connections, DCF properties, DCF system tables (65049/65050/65051), the DCFHelper class, and best practices for modelling matrices, routers, and patch panels. Use when adding or modifying DCF interfaces, connections, or related QAction code.'
argument-hint: 'Describe the DCF task: e.g. "define dynamic interfaces", "create internal connections in a QAction", "set up DCF for a matrix", "model patch-panel connectivity"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-05-27
  version: 1.1
---

# DataMiner Connectivity Framework (DCF)

DCF standardizes how device connectivity is provisioned and managed within DataMiner. It enables connectors to:

- Define **interfaces** (inputs, outputs, bidirectional ports) on elements
- Establish **connections** between interfaces — both within a single element and across elements
- Attach **properties** (metadata key-value pairs) to interfaces and connections
- Visualize signal paths in **Visio drawings** and **dashboards** (node-edge graphs)

## When a Connector Needs DCF

Use DCF when a device or system has physical or logical ports/interfaces whose connectivity must be tracked, visualized, or queried. Common use cases: switches, routers, matrices, signal-processing chains, any equipment where "what is connected to what" matters.

---

## Core Concepts

### Interface Types

| Type | Direction | Use Case |
|------|-----------|----------|
| `in` | Input only | Receives signal (e.g. decoder input) |
| `out` | Output only | Sends signal (e.g. encoder output) |
| `inout` | Bidirectional / virtual | Bidirectional ports, or virtual grouping interfaces |

### Connection Types

| Type | Direction | Scope |
|------|-----------|-------|
| **Internal** | Input → Output | Within the same element (signal passes through a device) |
| **External** | Output → Input | Between two different elements (cable/link between devices) |

### Properties

Static key-value metadata attached to interfaces or connections. Properties describe characteristics (e.g. bandwidth, VLAN ID, signal format) and are queryable via GQI.

### Virtual Interfaces

An `inout` interface with the special property `[Linked Interface ID]` references another interface, inheriting its alarm state and acting as a logical grouping point.

---

## Quick-Start XML

### Fixed Interfaces

```xml
<ParameterGroups>
  <Group id="1" name="Input 1" type="in" />
  <Group id="2" name="Output 1" type="out" />
  <Group id="3" name="Virtual" type="inout" />
</ParameterGroups>
```

### Dynamic Interfaces (Table-Based)

```xml
<ParameterGroups>
  <Group id="1" name="Input" type="in" dynamicId="1000" dynamicIndex="*" />
</ParameterGroups>
```

- `dynamicId` = table parameter ID providing the interfaces
- `dynamicIndex` = `"*"` for all rows, or a specific key filter
- Interface name = Group name + `" "` + row display key

---

## Hard Rules (Anti-Hallucination)

1. **Never set `volatile="true"`** on tables used for DCF (dynamic interfaces). Volatile tables lose data on restart, breaking DCF state.
2. **Internal connections** flow input → output. **External connections** flow output → input. Never reverse these.
3. **Never remove connections automatically** without explicit logic — accidental removal causes service outages.
4. **Avoid triggering QActions on DCF system table changes** (parameter IDs 65049–65102) — this creates deadlock risk with SLNet.
5. The **NuGet helper package** is `Skyline.DataMiner.Core.ConnectivityFramework.Protocol` — use it for DCF operations instead of raw SLNet calls.

---

## Skill Routing Table

| Task | Load |
|------|------|
| Understand interface/connection types and properties | `references/dcf-interfaces-and-connections.md` |
| Write or edit ParameterGroups XML (fixed, dynamic, matrix) | `references/dcf-xml-definitions.md` |
| Look up DCF system table parameter IDs | `references/dcf-system-tables.md` |
| Write C# QAction code for DCF operations | `references/dcf-api-reference.md` |
| Use the DCF helper NuGet package | `references/dcf-helper-class.md` |
| Review DCF implementation for correctness | `references/dcf-best-practices.md` |
| Write or edit `protocol.xml` structure (non-DCF) | `dataminer-xml-authoring` |
| Write or modify C# QAction code (non-DCF) | `dataminer-qaction` |

---

## Reference Files

Load these on demand — only when relevant to the task.

| File | Contents | Load When |
|------|----------|-----------|
| `dcf-interfaces-and-connections.md` | Interface types, connection types, properties, virtual interfaces | Understanding or explaining DCF concepts |
| `dcf-xml-definitions.md` | ParameterGroups XML, fixed/dynamic/matrix interfaces, alarm linking, attributes | Writing or editing DCF XML in protocol.xml |
| `dcf-system-tables.md` | 4 DCF system tables with all parameter IDs (65049–65102) | Looking up DCF table/column IDs, debugging DCF data |
| `dcf-api-reference.md` | SLProtocol DCF methods, ConnectivityConnection/Interface/Property classes | Writing C# QAction code for DCF operations |
| `dcf-helper-class.md` | NuGet package reference, installation, usage patterns | Setting up or using the DCF helper library |
| `dcf-best-practices.md` | Stability, performance, alarm monitoring, connection management | Reviewing DCF implementations, avoiding pitfalls |

---

## Documentation Links

- [DCF Overview](https://aka.dataminer.services/advanced-dcf)
- [Interfaces and Connections](https://aka.dataminer.services/advanced-dcf-interfaces-and-connections)
- [Defining Interfaces](https://aka.dataminer.services/advanced-dcf-defining-interfaces)
- [DCF and Matrices](https://aka.dataminer.services/advanced-dcf-matrices)
- [DCF Tables](https://aka.dataminer.services/advanced-dcf-tables)
- [DCF Class Library](https://aka.dataminer.services/advanced-dcf-data-miner-class-library)
- [DCF Helper Class](https://aka.dataminer.services/advanced-dcf-helper)
- [DCF Best Practices](https://aka.dataminer.services/advanced-dcf-best-practices)
- [DCF Tutorials](https://aka.dataminer.services/dcf-tutorials)
- [ParameterGroups.Group Schema](https://aka.dataminer.services/protocol-parameter-groups-group)
- [ConnectivityFramework NuGet](https://www.nuget.org/packages/Skyline.DataMiner.Core.ConnectivityFramework.Protocol)
