# DCF XML Definitions

> **Parent skill**: `dataminer-dcf/SKILL.md`

Complete XML configuration reference for defining DCF interfaces in `protocol.xml` using the `<ParameterGroups>` element.

Reference: https://aka.dataminer.services/advanced-dcf-defining-interfaces

---

## ParameterGroups Element

All DCF interfaces are defined within `<ParameterGroups>` at the protocol root level:

```xml
<Protocol>
  ...
  <ParameterGroups>
    <Group id="1" name="Input 1" type="in" />
    <Group id="2" name="Output 1" type="out" />
  </ParameterGroups>
  ...
</Protocol>
```

### Group Attributes

| Attribute | Required | Description |
|-----------|----------|-------------|
| `id` | Yes | Unique ID (range: 1–99,999) |
| `name` | Yes | Interface display name |
| `type` | Yes | `"in"`, `"out"`, or `"inout"` |
| `dynamicId` | No | Table parameter ID for dynamic interfaces |
| `dynamicIndex` | No | Row filter for dynamic interfaces (`"*"` = all rows) |
| `dynamicUsePK` | No | `"true"` to use primary key instead of display key in naming |
| `calculateAlarmState` | No | `"false"` to disable alarm state calculation (default: true) |
| `isInternal` | No | `"true"` to hide from external visibility |

Schema reference: https://aka.dataminer.services/protocol-parameter-groups-group

---

## Fixed Interfaces

Static interfaces that always exist on the element. Use for devices with a known, fixed port count.

```xml
<ParameterGroups>
  <Group id="1" name="SDI Input 1" type="in" />
  <Group id="2" name="SDI Input 2" type="in" />
  <Group id="10" name="IP Output 1" type="out" />
  <Group id="11" name="IP Output 2" type="out" />
  <Group id="100" name="Management" type="inout" />
</ParameterGroups>
```

### Rules

- IDs must be unique within the protocol and in range 1–99,999
- Names should be descriptive and match the physical port labels
- Use `in`/`out` for unidirectional ports; `inout` for bidirectional or virtual ports

---

## Dynamic Interfaces (Table-Based)

Interfaces generated from table rows. One interface per row. Use for devices where ports are discovered at runtime.

```xml
<ParameterGroups>
  <Group id="1" name="Input" type="in" dynamicId="1000" dynamicIndex="*" />
  <Group id="2" name="Output" type="out" dynamicId="2000" dynamicIndex="*" />
</ParameterGroups>
```

### How Dynamic Naming Works

The interface name is composed as: **Group name + " " + row display key**

Example: If Group name = `"Input"` and a table row has display key `"Port 3"`, the interface name is `"Input Port 3"`.

### dynamicId

References the **table parameter ID** whose rows become interfaces.

```xml
<!-- Table 1000 has rows for each input port -->
<Group id="1" name="Input" type="in" dynamicId="1000" dynamicIndex="*" />
```

### dynamicIndex

Filters which rows become interfaces:
- `"*"` — all rows in the table
- `"specific_key"` — only the row matching this primary key

### dynamicUsePK

By default, the display key is appended to the interface name. Set `dynamicUsePK="true"` to use the primary key instead.

```xml
<Group id="1" name="Input" type="in" dynamicId="1000" dynamicIndex="*" dynamicUsePK="true" />
```

### Table Requirements for Dynamic Interfaces

❌ Table with `volatile="true"` used for DCF:
```xml
<Param id="1000" trending="false">
  <ArrayOptions index="0" options=";volatile" />  <!-- WRONG: volatile loses DCF state on restart -->
</Param>
```

✅ Table without volatile for DCF:
```xml
<Param id="1000" trending="false">
  <ArrayOptions index="0" />  <!-- CORRECT: persisted table preserves DCF state -->
</Param>
```

---

## Matrix Interfaces

Matrices (crosspoint switches) integrate with DCF via `dynamicId` referencing the matrix parameter.

### Single Group Approach

One `inout` group for the entire matrix:

```xml
<ParameterGroups>
  <Group id="1" name="Matrix" type="inout" dynamicId="4000" />
</ParameterGroups>
```

All inputs and outputs share the same interface group. Simple but less control over naming.

### Dual Group Approach

Separate groups for inputs and outputs, using `dynamicIndex` to filter:

```xml
<ParameterGroups>
  <Group id="1" name="Matrix Input" type="in" dynamicId="4000" dynamicIndex="*,0" />
  <Group id="2" name="Matrix Output" type="out" dynamicId="4000" dynamicIndex="0,*" />
</ParameterGroups>
```

- `dynamicIndex="*,0"` — filter: all inputs (x=all, y=0 means inputs)
- `dynamicIndex="0,*"` — filter: all outputs (x=0, y=all means outputs)

The dual approach allows different naming for inputs vs outputs.

Reference: https://aka.dataminer.services/advanced-dcf-matrices

---

## Interface Alarm Linking

Associate parameter alarms with an interface so the interface alarm state reflects the worst alarm severity of its linked parameters.

```xml
<ParameterGroups>
  <Group id="1" name="Input 1" type="in">
    <Params>
      <Param id="101" />
      <Param id="102" />
    </Params>
  </Group>
</ParameterGroups>
```

- The interface alarm severity = **highest** alarm severity among all `<Param>` entries
- Link parameters that represent the health or status of the port (e.g. signal quality, error rate, link state)
- Parameters must have alarm monitoring configured (`<Alarm>` definitions) for this to take effect

### Disabling Alarm State Calculation

For high-frequency tables or interfaces where alarm state calculation is too expensive:

```xml
<Group id="1" name="Input" type="in" dynamicId="1000" dynamicIndex="*" calculateAlarmState="false" />
```

---

## Internal Interfaces

Hide an interface from external connectivity views:

```xml
<Group id="1" name="Internal Bus" type="inout" isInternal="true" />
```

Internal interfaces:
- Are not visible to other elements for external connection creation
- Can still participate in internal connections within the element
- Useful for modeling internal signal paths that should not be exposed

---

## Complete Example

A connector for a device with 4 fixed inputs, dynamic outputs from a table, and a management port:

```xml
<ParameterGroups>
  <!-- Fixed input interfaces -->
  <Group id="1" name="SDI In 1" type="in">
    <Params>
      <Param id="101" />  <!-- Signal Status parameter -->
    </Params>
  </Group>
  <Group id="2" name="SDI In 2" type="in">
    <Params>
      <Param id="102" />
    </Params>
  </Group>
  <Group id="3" name="SDI In 3" type="in">
    <Params>
      <Param id="103" />
    </Params>
  </Group>
  <Group id="4" name="SDI In 4" type="in">
    <Params>
      <Param id="104" />
    </Params>
  </Group>

  <!-- Dynamic output interfaces from Outputs Table (PID 2000) -->
  <Group id="10" name="IP Output" type="out" dynamicId="2000" dynamicIndex="*" />

  <!-- Management port (bidirectional, hidden from external DCF) -->
  <Group id="100" name="Management" type="inout" isInternal="true" />
</ParameterGroups>
```
