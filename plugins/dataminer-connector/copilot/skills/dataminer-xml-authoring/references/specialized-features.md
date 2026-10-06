# Specialized Features

Reference for DVE export rules, EPM/Topology, Tree Controls, Matrix parameters, View Tables, Logger Tables, Multithreaded Timers, Mediation Layer, Chart Components, and XSD Schema.

> **Parent skill**: `dataminer-xml-authoring/SKILL.md` — return there for core authoring rules.

---

## DVE Export Rules

Export rules customize how columns appear in DVE child elements.

```xml
<ExportRules>
  <ExportRule table="2000" tag="Protocol/Params/Param/Description"
    attribute="" value="" regex="^(.*) \(Interfaces\)$" />
  <ExportRule table="2000" tag="Protocol/Params/Param/Display/Positions/Position/Page"
    value="General" />
</ExportRules>
```

- Remove table name suffixes from exported column descriptions using `regex`.
- Override page placement of exported parameters with the `value` attribute.
- Child element name format: `"Mother Protocol Name - Product Name"`.
- A protocol must **not** auto-delete DVE children.

---

## Topology / EPM (Experience and Performance Management)

EPM connectors define chains and fields for hierarchical topology navigation.

```xml
<Topology>
  <Cell name="Network" table="1000" />
  <Cell name="Region" table="2000" />
  <Cell name="Device" table="3000" />
</Topology>

<Chains>
  <Chain name="Network Overview">
    <Field name="Network" options="ShowCPEChilds;details:1000;displayInFilter" pid="1002" />
    <Field name="Region" options="ShowCPEChilds;details:2000;displayInFilter" pid="2002" />
    <Field name="Device" options="ShowCPEChilds;details:3000;displayInFilter" pid="3002" />
  </Chain>
  <SearchChain name="Search">
    <Tabs>
      <Tab tablePid="3000" />
    </Tabs>
  </SearchChain>
</Chains>
```

### Key Concepts
- **Cell**: Maps a topology level to a table.
- **Chain**: Defines a navigation path through cells.
- **Field**: References a column (pid) that links to the next level. `options` controls display behavior.
- **SearchChain**: Enables search functionality across topology tables.
- Tables require `<Relations>` to define the parent-child chain. See `table-relations.md` for path semantics, ordering rules, and options.
- Use `onlyFilteredDirectView` on `<ArrayOptions>` for EPM tables that should only return filtered data.

---

## Tree Control

Tree controls display hierarchical data from related tables.

```xml
<TreeControls>
  <TreeControl parameterId="4" readOnly="false">
    <Hierarchy>
      <Table id="1000" />
      <Table id="2000" parent="1000" />
      <Table id="3000" parent="2000" />
    </Hierarchy>
    <HiddenColumns>
      <ColumnRef pid="2004" />
    </HiddenColumns>
    <ExtraTabs>
      <Tab tablePid="3000">
        <Name>Channels</Name>
      </Tab>
    </ExtraTabs>
  </TreeControl>
</TreeControls>
```

**Requirements:**
- A `<Relation>` must exist for each parent-child pair referenced in the hierarchy. See `table-relations.md` for FK column setup and `includeInAlarms` option.
- The tree control parameter (`parameterId`) must have `RTDisplay=true`.
- The root table must be displayed (`RTDisplay=true`), though it does not need a page position.

---

## Matrix Parameters

Matrix parameters represent crosspoint switching (inputs x outputs).

```xml
<Param id="4000" trending="false">
  <Name>matrix</Name>
  <Description>Matrix</Description>
  <Type>array</Type>
  <ArrayOptions index="0" options="dimensions:64,64">
    <ColumnOption idx="0" pid="4001" type="custom" options="" />
  </ArrayOptions>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions><Position><Page>Matrix</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
  <Measurement>
    <Type>matrix</Type>
    <Discreets matrixLayout="InputLeftOutputTop">
      <Discreet><Display>Input 1</Display><Value>1</Value></Discreet>
    </Discreets>
  </Measurement>
</Param>
```

Reference: https://aka.dataminer.services/ui-components-matrix

---

## View Tables

View tables combine data from multiple tables into a single displayed table.

```xml
<Param id="5000" trending="false">
  <Name>combinedView</Name>
  <Description>Combined View</Description>
  <Type>array</Type>
  <ArrayOptions index="0" options=";view=1000">
    <ColumnOption idx="0" pid="5001" type="retrieved" options=";view=1001" />
    <ColumnOption idx="1" pid="5002" type="retrieved" options=";view=1002" />
    <ColumnOption idx="2" pid="5003" type="retrieved" options=";view=2003" />
  </ArrayOptions>
</Param>
```

- `options=";view=1000"` on `<ArrayOptions>`: root source table.
- `options=";view=colPid"` on `<ColumnOption>`: source column from the root or a linked table.
- **No alarm monitoring or trending** on view tables — configure on base tables instead.
- Linked tables must have `<Relations>` defined. See `table-relations.md`.

---

## Logger Tables

Logger tables store data directly in the database, bypassing SLProtocol memory.

```xml
<Param id="6000" trending="false">
  <Name>eventLog</Name>
  <Description>Event Log</Description>
  <Type>array</Type>
  <ArrayOptions index="0" options=";database">
    <ColumnOption idx="0" pid="6001" type="retrieved" options="" />
    <ColumnOption idx="1" pid="6002" type="retrieved" options="" />
  </ArrayOptions>
  <Display><RTDisplay>true</RTDisplay></Display>
  <Database>
    <CQLOptions>
      <Clustering>1</Clustering>
    </CQLOptions>
  </Database>
</Param>
```

- `options=";database"` activates logger table mode. Optional: `";database:1000"` to cache 1000 rows in memory (default: 500).
- `RTDisplay` should be `true` (logger tables are used with view tables / SLNet filters).
- **No trending or alarming** on logger tables — data cannot be retrieved via SLProtocol methods.
- Use view tables or SLNet filters to display logger table data.

Reference: https://aka.dataminer.services/advanced-logger-tables

---

## Multithreaded Timers

Multithreaded timers poll each row of a table independently using a thread pool.

```xml
<Timer id="2" options="ip:2000,1;each:60000;threadpool:20">
  <Name>Multithreaded Polling</Name>
  <Time>1000</Time>
  <Interval>0</Interval>
  <Content>
    <Group>100</Group>
  </Content>
</Timer>
```

### Required Options

| Option | Description |
|--------|-------------|
| `ip:tableId,colIdx` | Table and column index containing the key (IP or PK) for each thread |
| `each:ms` | Execution interval per row (milliseconds) |
| `threadpool:size` | Number of threads in the pool |

### Optional Options

| Option | Description |
|--------|-------------|
| `qactionBefore:qid` | QAction to run before each row poll |
| `qactionAfter:qid` | QAction to run after each row poll |
| `ping` | Ping the IP before polling |
| `pollingRate:maxPerSec,maxTotal` | Rate limit polling |
| `ignoreIf:colIdx,value` | Skip rows where column matches value |

### Thread Safety

- Thread synchronization is required when multiple threads access shared data.
- Use `lock` for critical sections in QActions triggered by multithreaded timers.
- Set timer time to **1000 ms** (recommended) or multiples up to 5000 ms.
- The group must be a `poll` type group.

Reference: https://aka.dataminer.services/advanced-multithreaded-timers

---

## Mediation Layer (Base Protocols)

Base protocols provide a standardized view across functionally similar devices from different vendors.

- A base protocol defines **common parameters** (e.g., carrier frequency) linked to device-specific parameters.
- Users switch between device-specific and standardized views in DataMiner Cube (element card menu → Mediation Layer).
- Useful for vendor-agnostic automation scripts.

Reference: https://aka.dataminer.services/advanced-data-miner-mediation-layer

---

## Chart Components

Display charts inline on protocol pages:

```xml
<Param id="500" trending="false">
  <Name>signalChart</Name>
  <Description>Signal Chart</Description>
  <Type>read</Type>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions><Position><Page>Signal</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
  <Measurement>
    <Type>chart</Type>
  </Measurement>
</Param>
```

Reference: https://aka.dataminer.services/ui-components-chart

---

## XSD Schema Reference

Two resources are available for validating XML element and attribute values:

1. **Online schema documentation (preferred)** — Full XSD with explanations for every element and attribute:
   https://aka.dataminer.services/protocol

2. **Local protocol.xsd** — Raw XSD file in the NuGet cache:
   `C:\Users\Robbie.SKYLINE2\.nuget\packages\skyline.dataminer.xmlschemas.protocol\1.1.5\content\Skyline\XSD\protocol.xsd`
   ~1.2 MB / 16,000 lines. Search for `xs:element name="ElementName"` for specific elements.

**When to consult**: After writing XML, verify that enumerated values (e.g., `<Type>` values for Params, Groups, Actions) are valid. The online documentation is easier to navigate; the local XSD is useful for edge cases.
