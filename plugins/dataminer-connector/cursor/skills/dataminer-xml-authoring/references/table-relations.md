# Table Relations and Foreign Keys

Reference for defining parent-child relationships between tables using `<Relations>`, configuring foreign key columns, and enabling alarm bubble-up. Relations are required for tree controls, EPM topology navigation, and view tables.

> **Parent skill**: `dataminer-xml-authoring/SKILL.md` — return there for core authoring rules.
> **Schema authority**: `dataminer-protocol-xml-reference/references/protocol-advanced-features.md` — exact tag/attribute/enum definitions for `<Relations>`.

---

## Relation Basics

`<Relations>` is an optional direct child of `<Protocol>`. It contains zero or more `<Relation>` elements, each defining a foreign key chain between tables.

```xml
<Relations>
	<Relation path="1000;2000" name="NetworkToRegion" />
	<Relation path="1000;2000;3000" name="NetworkToRegionToDevice" />
</Relations>
```

Every relation requires a matching foreign key column in each child table (see **Foreign Key Columns** below).

---

## Path Semantics

The `path` attribute is a semicolon-separated list of table parameter IDs (type `TypeSemicolonSeparatedNumbers`). It reads **parent → child**: the leftmost PID is the top-level parent, the rightmost PID is the leaf child.

```
path="1000;2000;3000"
         │     │     │
         │     │     └── 3000: leaf child — has FK column pointing to 2000
         │     └── 2000: intermediate — has FK column pointing to 1000
         └── 1000: root parent
```

**Rules:**
- Minimum 2 PIDs per path.
- Every PID must reference an existing `<Param type="array">` with `<RTDisplay>true</RTDisplay>`.
- Each adjacent pair of tables in the path must have a corresponding FK column in the child table (validator 13.2.5 `MissingForeignKeyForRelation`).

---

## Relation Ordering (EPM)

When a table can be skipped in the topology (i.e., both a direct and an indirect path exist between two tables), **always specify the shortest relation first, then the longer relation(s)**.

```xml
<Relations>
	<Relation path="2800;2300" />
	<Relation path="2800;2900;2300" />
</Relations>

<Relations>
	<Relation path="2800;2900;2300" />
	<Relation path="2800;2300" />
</Relations>
```

When the EPM element passes a key, it matches against defined relations in order. If the longer path is listed first, the system may incorrectly attempt to traverse through the intermediate table even when a direct link exists.

---

## Relation Attributes and Options

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `path` | TypeSemicolonSeparatedNumbers | Yes | Semicolon-separated table PIDs forming the parent→child chain |
| `name` | string | No | Descriptive name for the relation (must be unique across all relations) |
| `options` | string | No | Comma-separated option tokens (see below) |

### `includeInAlarms` — Alarm Bubble-Up

Enables alarm severity propagation along the relation chain for tree controls. Each relation using this option **must have a unique topology name**.

```xml
<Relation path="100;200" options="includeInAlarms:topology1" />
<Relation path="100;300" options="includeInAlarms:topology2" />

<Relation path="100;200;300;400;500" options="includeInAlarms:topology:rightTopLevel" />
```

When `includeInAlarms` is active, alarm severities from child table rows propagate upward to their parent rows in the tree control display.

### `chain` — EPM Chain Label

Names a chain relationship path for EPM topology navigation.

```xml
<Relation path="6000;21000;21200;21400;22200" options="chain:VoD HW view" />
```

The label is used to associate this relation with a specific EPM chain view.

---

## Foreign Key Columns

The child table must contain a column holding the parent table's primary key value. This column is the foreign key and is typically hidden from the user.

```xml
<ArrayOptions index="0">
	<NamingFormat>,2002</NamingFormat>
	<ColumnOption idx="0" pid="2001" type="snmp" options="" />
	<ColumnOption idx="1" pid="2002" type="snmp" options="" />
	<ColumnOption idx="2" pid="2003" type="snmp" options="" />
	<ColumnOption idx="3" pid="2004" type="retrieved" options=";foreignkey=1000" />
</ArrayOptions>
```

**FK column param pattern:**

```xml
<Param id="2004" trending="false">
	<Name>RegionNetworkKey</Name>
	<Description>Network Key (Region)</Description>
	<Information>
		<Subtext>Foreign key linking this region row to its parent network.</Subtext>
	</Information>
	<Type>read</Type>
	<Interprete>
		<RawType>numeric text</RawType>
		<Type>string</Type>
		<LengthType>next param</LengthType>
	</Interprete>
	<Display>
		<RTDisplay>true</RTDisplay>
	</Display>
	<Measurement>
		<Type>string</Type>
	</Measurement>
</Param>
```

### FK Column Constraints

- **`type="retrieved"`** on the `<ColumnOption>` — FK columns are populated by QAction logic or set commands, not polled via SNMP.
- **`options=";foreignkey=<parentTablePid>"`** — the value after `foreignkey=` is the **parent table's parameter ID** (e.g., `1000`), not a column PID.
- **Do NOT place `foreignkey` on the index column** (the column matching `<ArrayOptions index="...">`).
- **Do NOT target a volatile table** with `foreignkey` — volatile tables do not persist primary keys after restart.
- **Remove child rows before parent rows** when cleaning up data — deleting a parent while child rows still reference it causes orphaned FK references.
- **Every FK column must have a corresponding `<Relation>`** — a `foreignkey` option without a matching relation path triggers validator finding 2.38.4 (`ForeignKeyMissingRelation`).
- **Every adjacent pair in a relation path must have an FK column** — a relation path without a matching `foreignkey` column triggers validator finding 13.2.5.
- Use **`numeric text`** for `<Interprete><RawType>` on FK columns — string-type keys may cause lookup problems at runtime.

---

## Relations for Tree Controls

Tree controls display hierarchical data from related tables. A `<Relation>` must exist for each parent-child pair referenced in the `<TreeControl><Hierarchy>`.

```xml
<Relations>
	<Relation path="1000;2000" options="includeInAlarms:treeTopology1" />
	<Relation path="1000;2000;3000" options="includeInAlarms:treeTopology2" />
</Relations>

<TreeControls>
	<TreeControl parameterId="4" readOnly="false">
		<Hierarchy>
			<Table id="1000" />
			<Table id="2000" parent="1000" />
			<Table id="3000" parent="2000" />
		</Hierarchy>
		<HiddenColumns>
			  <ColumnRef pid="2004" />
			  <ColumnRef pid="3004" />
		</HiddenColumns>
	</TreeControl>
</TreeControls>
```

- FK columns should be listed in `<HiddenColumns>` — they are internal linkage columns not meaningful to the user.
- The tree control parameter (`parameterId`) must have `RTDisplay=true`.

> **Full Tree Control reference**: `dataminer-xml-authoring/references/specialized-features.md` — hierarchy structure, ExtraTabs, and display requirements.

---

## Relations for EPM / Topology

EPM connectors use `<Chains>` and `<Topology>` to define hierarchical navigation. Every table referenced by chain fields must be connected via `<Relations>`.

```xml
<Relations>
	<Relation path="1000;2000" />
	<Relation path="1000;2000;3000" />
</Relations>

<Topology>
	<Cell name="Network" table="1000" />
	<Cell name="Region" table="2000" />
	<Cell name="Device" table="3000" />
</Topology>
```

- When tables can be skipped in the topology, follow the **shortest-path-first ordering rule** (see above).
- Use the `chain:label` option to associate relations with specific EPM chain views.

> **Full EPM reference**: `dataminer-xml-authoring/references/specialized-features.md` — Chains, Fields, SearchChain, and Cell configuration.

---

## Relations for View Tables

View tables that pull columns from multiple source tables require `<Relations>` between those source tables.

```xml
<Relations>
	<Relation path="1000;2000" />
</Relations>

<ArrayOptions index="0" options=";view=1000">
	<ColumnOption idx="0" pid="5001" type="retrieved" options=";view=1001" />
	<ColumnOption idx="1" pid="5002" type="retrieved" options=";view=2003" />
</ArrayOptions>
```

Without a defined relation between the source tables, DataMiner cannot resolve the cross-table column references.

> **Full View Table reference**: `dataminer-xml-authoring/references/specialized-features.md` — view table syntax and constraints.

---

## Worked Example: Three-Level Hierarchy

A complete example with three tables (Network → Region → Device), relations, FK columns, and a tree control.

```xml
<Relations>
	<Relation path="1000;2000" name="NetworkToRegion" options="includeInAlarms:hierarchy1" />
	<Relation path="1000;2000;3000" name="NetworkToRegionToDevice" options="includeInAlarms:hierarchy2" />
</Relations>

<Param id="1000" trending="false">
	<Name>Network</Name>
	<Description>Network</Description>
	<Information><Subtext>Network-level topology table.</Subtext></Information>
	<Type>array</Type>
	<ArrayOptions index="0">
		<NamingFormat>,1002</NamingFormat>
		<ColumnOption idx="0" pid="1001" type="retrieved" options="" />
		<ColumnOption idx="1" pid="1002" type="retrieved" options="" />
	</ArrayOptions>
	<Display>
		<RTDisplay>true</RTDisplay>
		<Positions><Position><Page>Topology</Page><Row>0</Row><Column>0</Column></Position></Positions>
	</Display>
	<Measurement>
		<Type options="tab=columns:1001|0-1002|1,lines:25,width:100-200,sort:STRING-STRING,filter:true">table</Type>
	</Measurement>
</Param>

<Param id="2000" trending="false">
	<Name>Region</Name>
	<Description>Region</Description>
	<Information><Subtext>Region-level topology table.</Subtext></Information>
	<Type>array</Type>
	<ArrayOptions index="0">
		<NamingFormat>,2002</NamingFormat>
		<ColumnOption idx="0" pid="2001" type="retrieved" options="" />
		<ColumnOption idx="1" pid="2002" type="retrieved" options="" />
		<ColumnOption idx="2" pid="2003" type="retrieved" options=";foreignkey=1000" />
	</ArrayOptions>
	<Display>
		<RTDisplay>true</RTDisplay>
		<Positions><Position><Page>Topology</Page><Row>1</Row><Column>0</Column></Position></Positions>
	</Display>
	<Measurement>
		<Type options="tab=columns:2001|0-2002|1-2003|2,lines:25,width:100-200-150,sort:STRING-STRING-STRING,filter:true">table</Type>
	</Measurement>
</Param>
<Param id="2003" trending="false">
	<Name>RegionNetworkKey</Name>
	<Description>Network Key (Region)</Description>
	<Information><Subtext>Foreign key linking this region to its parent network.</Subtext></Information>
	<Type>read</Type>
	<Interprete>
		<RawType>numeric text</RawType>
		<Type>string</Type>
		<LengthType>next param</LengthType>
	</Interprete>
	<Display><RTDisplay>true</RTDisplay></Display>
	<Measurement><Type>string</Type></Measurement>
</Param>

<Param id="3000" trending="false">
	<Name>Device</Name>
	<Description>Device</Description>
	<Information><Subtext>Device-level topology table.</Subtext></Information>
	<Type>array</Type>
	<ArrayOptions index="0">
		<NamingFormat>,3002</NamingFormat>
		<ColumnOption idx="0" pid="3001" type="retrieved" options="" />
		<ColumnOption idx="1" pid="3002" type="retrieved" options="" />
		<ColumnOption idx="2" pid="3003" type="retrieved" options=";foreignkey=2000" />
	</ArrayOptions>
	<Display>
		<RTDisplay>true</RTDisplay>
		<Positions><Position><Page>Topology</Page><Row>2</Row><Column>0</Column></Position></Positions>
	</Display>
	<Measurement>
		<Type options="tab=columns:3001|0-3002|1-3003|2,lines:25,width:100-200-150,sort:STRING-STRING-STRING,filter:true">table</Type>
	</Measurement>
</Param>
<Param id="3003" trending="false">
	<Name>DeviceRegionKey</Name>
	<Description>Region Key (Device)</Description>
	<Information><Subtext>Foreign key linking this device to its parent region.</Subtext></Information>
	<Type>read</Type>
	<Interprete>
		<RawType>numeric text</RawType>
		<Type>string</Type>
		<LengthType>next param</LengthType>
	</Interprete>
	<Display><RTDisplay>true</RTDisplay></Display>
	<Measurement><Type>string</Type></Measurement>
</Param>

<TreeControls>
	<TreeControl parameterId="4" readOnly="true">
		<Hierarchy>
			<Table id="1000" />
			<Table id="2000" parent="1000" />
			<Table id="3000" parent="2000" />
		</Hierarchy>
		<HiddenColumns>
			<ColumnRef pid="2003" />
			<ColumnRef pid="3003" />
		</HiddenColumns>
	</TreeControl>
</TreeControls>
```

Reference: https://aka.dataminer.services/ui-components-table-relations
