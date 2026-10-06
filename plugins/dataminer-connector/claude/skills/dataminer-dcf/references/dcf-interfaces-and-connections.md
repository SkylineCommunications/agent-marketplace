# DCF Interfaces and Connections

> **Parent skill**: `dataminer-dcf/SKILL.md`

Core concepts of the DataMiner Connectivity Framework: interface types, connection types, properties, and virtual interfaces.

Reference: https://aka.dataminer.services/advanced-dcf-interfaces-and-connections

---

## Interfaces

An **interface** represents a physical or logical port on an element. Every DCF interface has:

- **ID** — unique within the element
- **Name** — human-readable label
- **Type** — direction of signal flow

### Interface Types

| Type | XML Value | Description |
|------|-----------|-------------|
| Input | `in` | Receives signal from another element or from within the same element |
| Output | `out` | Sends signal to another element or within the same element |
| Inout | `inout` | Bidirectional port, or a virtual grouping interface |

### Fixed vs Dynamic Interfaces

- **Fixed interfaces**: Defined statically in `<ParameterGroups>`. The element always has these interfaces regardless of runtime state. Use for devices with a known, fixed set of ports.
- **Dynamic interfaces**: Linked to a table via `dynamicId`. Each row in the table becomes an interface. Use for devices where the number of ports varies at runtime (e.g. modular chassis, virtual switches).

---

## Connections

A **connection** links two interfaces, representing a signal path.

### Internal Connections

- Flow: **input → output** within the same element
- Represent signal routing through a device (e.g. a signal entering on input port 1 exits on output port 3)
- Created programmatically in QActions or via the DCF Helper class

```
[Element A: Input 1] ──internal──▶ [Element A: Output 3]
```

### External Connections

- Flow: **output → input** across two different elements
- Represent physical cables or logical links between devices
- Can be created by: manager elements, automation scripts, manual configuration, element-to-element logic, Skyline Generic Provisioning, or DataMiner IDP

```
[Element A: Output 1] ──external──▶ [Element B: Input 2]
```

### Connection Direction Rules

❌ Internal connection from output to input:
```
[Output] ──internal──▶ [Input]   // WRONG direction
```

✅ Internal connection from input to output:
```
[Input] ──internal──▶ [Output]   // CORRECT
```

❌ External connection from input to output:
```
[Element A: Input] ──external──▶ [Element B: Output]   // WRONG direction
```

✅ External connection from output to input:
```
[Element A: Output] ──external──▶ [Element B: Input]   // CORRECT
```

---

## Properties

**Properties** are static key-value metadata pairs attached to interfaces or connections. They describe characteristics without affecting connectivity logic.

### Interface Properties

Attached to an interface to describe its characteristics:
- Signal format (e.g. "SDI", "IP", "ASI")
- Bandwidth capacity
- VLAN assignment
- Port number or label

### Connection Properties

Attached to a connection to describe the link:
- Cable type or ID
- Bandwidth utilization
- Signal quality metrics
- Custom metadata

### Property Structure

Each property has:
- **Name** — descriptive label (string)
- **Type** — category or data type (string)
- **Value** — the property value (string)

Properties are queryable via GQI and visible in the DataMiner UI.

---

## Virtual Interfaces

A virtual interface uses `type="inout"` and the special property `[Linked Interface ID]` to reference another interface.

### Purpose

- Group related interfaces under a single logical point
- Inherit the alarm state of the linked interface
- Provide a simplified view for topology visualization

### Behavior

When an `inout` interface has the `[Linked Interface ID]` property:
- Its alarm severity reflects the linked interface's alarm severity
- It acts as a proxy for connectivity visualization
- It does not represent a physical port

---

## Signal Path Visualization

DCF connections are visualized in:

1. **Visio drawings** — Elements with DCF interfaces show connectivity in Visual Overview. External and internal connections are rendered automatically through shape data fields.
2. **Dashboards** — Node-edge graph components display DCF topology. GQI queries can filter and enrich the visualization with interface properties.
3. **DataMiner Cube** — The Connectivity chain in element cards shows all interfaces and their connections.
