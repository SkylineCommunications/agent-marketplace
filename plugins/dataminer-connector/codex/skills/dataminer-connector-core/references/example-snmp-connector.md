# Canonical SNMP Connector Example

This is the **authoritative reference pattern** for a minimal SNMP connector with scalar parameters and one table.
**Always follow this exact structure.** Do NOT invent XML elements not present here.

Schema: https://aka.dataminer.services/protocol
Dev guide: https://aka.dataminer.services/connections-snmp
Validated complete example: [`examples/snmp-protocol.xml`](examples/snmp-protocol.xml)

---

## What This Example Covers

- Protocol metadata (all required tags)
- Scalar read parameter (string)
- Scalar numeric parameter (double with units)
- Read/write parameter pair with `snmpSetAndGet="true"` for automatic SET/readback
- SNMP table with 3 columns (index + 2 data columns)
- Automatically polled SNMP table columns without `;save`; polling refreshes their current values
- Tiered polling: dynamic scalar poll group, static scalar poll group, and table poll group
- 30-second fast timer for dynamic telemetry and table; 1-hour slow timer for static asset/configuration information (both with `initial="true"`)
- After-startup trigger chain for one-time initialization (not polling timer data)

---

## Parameter ID Plan

| ID    | Name                        | Type         | Purpose                                |
|-------|-----------------------------|--------------|----------------------------------------|
| 1     | afterStartup                | dummy        | After-startup initialization trigger   |
| 100   | systemDescription           | read         | sysDescr scalar                        |
| 101   | systemUpTime                | read         | sysUpTime scalar         |
| 102   | systemContact               | read         | sysContact (read side)   |
| 152   | systemContact               | write        | sysContact (write side)  |
| 1000  | devicePowerSources          | array        | Table array parameter    |
| 1001  | devicePowerSourcesIndex     | read         | Table index column       |
| 1002  | devicePowerSourcesName      | read         | Table name column        |
| 1003  | devicePowerSourcesStatus    | read         | Table status column      |

---

## Complete `protocol.xml` Snippets

### Protocol Header and Metadata

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Copyright notice -->
<Protocol xmlns="http://www.skyline.be/protocol">
	<Name>Vendor Device SNMPv2</Name>
	<Description>Vendor Device SNMPv2 DataMiner Driver</Description>
	<Version>1.0.0.1</Version>
	<IntegrationID>DMS-DRV-1234</IntegrationID>
	<Provider>Skyline Communications</Provider>
	<Vendor>Vendor Inc</Vendor>
	<VendorOID>1.3.6.1.4.1.8813.2.1</VendorOID>
	<DeviceOID>1</DeviceOID>
	<ElementType>Switch</ElementType>
	<Type relativeTimers="true">snmpv2</Type>
	<SNMP includepages="true">auto</SNMP>
	<Display defaultPage="General" pageOrder="General;Power Sources;-----;Webinterface#http://[Polling Ip]/" wideColumnPages="" />
	<Compliancies>
		<CassandraReady>true</CassandraReady>
		<MinimumRequiredVersion>10.4.0.0 - 14003</MinimumRequiredVersion>
	</Compliancies>
```

> ⚠️ `VendorOID` must be a Skyline-assigned connector OID matching `1.3.6.1.4.1.8813.2.<number>`.
> `DeviceOID` must be a single integer, not a dotted OID.

---

### Parameter 1 — After-Startup Dummy

```xml
	<Params>
		<Param id="1" trending="false" save="false">
			<Name>afterStartup</Name>
			<Description>After Startup</Description>
			<Information>
				<Subtext>Internal trigger parameter for after-startup initialization. Not displayed.</Subtext>
			</Information>
			<Type>dummy</Type>
			<Display>
				<RTDisplay>false</RTDisplay>
			</Display>
		</Param>
```

---

### Parameter 100 — Scalar String Read (SNMP)

```xml
		<Param id="100" trending="false">
			<Name>systemDescription</Name>
			<Description>System Description</Description>
			<Information>
				<Subtext>A textual description of the entity.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>General</Page>
						<Row>0</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete">1.3.6.1.2.1.1.1.0</OID>
				<Type>octetstring</Type>
			</SNMP>
		</Param>
```

> Key rules:
> - `<RawType>other</RawType>` + `<Type>string</Type>` for all string SNMP parameters.
> - Always include `<Information><Subtext>` with a meaningful operator-facing description. Do not include technical protocol details like the SNMP OID (which belongs in `<SNMP><OID>`).
> - Add an `<Alarm>` block only when the parameter must support alarming. This string parameter is not alarmable, so it omits the block.
> - Always specify `<SNMP><Type>` on every parameter. SNMP type values are all lowercase (e.g. `octetstring`, `timeticks`, `integer32`) as defined in the [EnumSNMPType schema](https://aka.dataminer.services/enum-snmp-type). It is **strongly recommended** on write parameters and good practice on read parameters.

---

### Parameter 101 — Scalar Numeric Read with Units

```xml
		<Param id="101" trending="true">
			<Name>systemUpTime</Name>
			<Description>System Up Time</Description>
			<Information>
				<Subtext>The time since the network management portion of the system was last re-initialized.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>numeric text</RawType>
				<Type>double</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Units>s</Units>
				<!-- SuppressValidator 2.11.1 No meaningful range for uptime counter -->
				<Range />
				<!-- /SuppressValidator 2.11.1 -->
				<Positions>
					<Position>
						<Page>General</Page>
						<Row>1</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type options="time">number</Type>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete">1.3.6.1.2.1.1.3.0</OID>
				<Type>timeticks</Type>
			</SNMP>
		</Param>
```

> Key rules:
> - `trending="true"` on numeric parameters you want to trend.
> - `<RawType>numeric text</RawType>` + `<Type>double</Type>` for numeric SNMP parameters.
> - Always add `<Units>` for parameters with a physical unit (s, %, dBm, Mbps, etc.).
> - Always add `<Range>` (or suppress 2.11.1) for displayed numeric parameters.

---

### Parameters 102 / 152 — Read/Write Pair (SNMP)

```xml
		<Param id="102" trending="false">
			<Name>systemContact</Name>
			<Description>System Contact</Description>
			<Information>
				<Subtext>The textual identification of the contact person for this managed node.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>General</Page>
						<Row>2</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete">1.3.6.1.2.1.1.4.0</OID>
				<Type>octetstring</Type>
			</SNMP>
		</Param>
		<Param id="152" trending="false" snmpSetAndGet="true">
			<Name>systemContact</Name>
			<Description>System Contact</Description>
			<Information>
				<Subtext>The textual identification of the contact person for this managed node.</Subtext>
			</Information>
			<Type>write</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>General</Page>
						<Row>2</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete">1.3.6.1.2.1.1.4.0</OID>
				<Type>octetstring</Type>
			</SNMP>
		</Param>
```

> Key rules:
> - Write ID = read ID + 50 (preferred offset). Must be ≤ read ID + 100.
> - Write parameter appears **immediately after** its read parameter in the XML.
> - Read and write share the same `<Name>` and `<Description>`.
> - Write parameters do NOT need an `<Alarm>` block.
> - Always specify `<SNMP><Type>` on write parameters — this is **strongly recommended** by the schema. SNMP type values are all lowercase (e.g. `octetstring`, `integer32`, `timeticks`) as defined in the [EnumSNMPType schema](https://aka.dataminer.services/enum-snmp-type).

---

### Parameters 1000–1003 — SNMP Table

```xml
		<Param id="1000" trending="false">
			<Name>devicePowerSources</Name>
			<Description>Device Power Sources</Description>
			<Information>
				<Subtext>Table listing all power source entries on the device.</Subtext>
			</Information>
			<Type>array</Type>
			<ArrayOptions index="0">
				<NamingFormat>,1002</NamingFormat>
				<ColumnOption idx="0" pid="1001" type="snmp" options="" />
				<ColumnOption idx="1" pid="1002" type="snmp" options="" />
				<ColumnOption idx="2" pid="1003" type="snmp" options=";disableHeaderSum;disableHeatmap;disableHistogram" />
			</ArrayOptions>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>Power Sources</Page>
						<Row>0</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type options="tab=columns:1001|0-1002|1-1003|2,lines:25,width:100-180-120,sort:STRING-STRING-INT,filter:true">table</Type>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete" options="multipleGetBulk">1.3.6.1.4.1.9999.1.1</OID>
			</SNMP>
		</Param>
		<Param id="1001" trending="false">
			<Name>devicePowerSourcesIndex</Name>
			<Description>Index</Description>
			<Information>
				<Subtext>Unique index of this power source entry.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
			<SNMP>
				<OID>1.3.6.1.4.1.9999.1.1.1.1</OID>
			</SNMP>
		</Param>
		<Param id="1002" trending="false">
			<Name>devicePowerSourcesName</Name>
			<Description>Name</Description>
			<Information>
				<Subtext>Human-readable name of this power source.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete">1.3.6.1.4.1.9999.1.1.1.2</OID>
				<Type>octetstring</Type>
			</SNMP>
		</Param>
		<Param id="1003" trending="false">
			<Name>devicePowerSourcesStatus</Name>
			<Description>Status</Description>
			<Information>
				<Subtext>Operational status of this power source. 1 = Online, 2 = Offline, 3 = Fault.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>numeric text</RawType>
				<Type>double</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
			</Display>
			<Alarm>
				<Monitored>true</Monitored>
				<Normal>1</Normal>
				<CH>3</CH>
				<MaH>2</MaH>
			</Alarm>
			<Measurement>
				<Type>discreet</Type>
				<Discreets>
					<Discreet>
						<Display>Online</Display>
						<Value>1</Value>
					</Discreet>
					<Discreet>
						<Display>Offline</Display>
						<Value>2</Value>
					</Discreet>
					<Discreet>
						<Display>Fault</Display>
						<Value>3</Value>
					</Discreet>
				</Discreets>
			</Measurement>
			<SNMP>
				<Enabled>true</Enabled>
				<OID type="complete">1.3.6.1.4.1.9999.1.1.1.3</OID>
				<Type>integer32</Type>
			</SNMP>
		</Param>
	</Params>
```

> Key rules:
> - Table array param `<Measurement>` must use `<Type>table</Type>` — NEVER `discreet` or `number`.
> - Column `<Name>` = camelCase `tableNameColumnName` format. Add a parenthetical table suffix to `<Description>` only when another table uses the same description.
> - Index column `idx="0"` must always be a **string** parameter: `<RawType>other</RawType>`, `<Type>string</Type>`, `<Measurement><Type>string</Type>`. NEVER use `numeric text` / `double` / `number` for an index column.
> - Index column `idx="0"` must NOT have `foreignkey` in its options.
> - NEVER set `displayColumn` — use `options=";naming=/columnPid"` in `<ArrayOptions>` instead.
> - Add `disableHeaderSum;disableHeatmap;disableHistogram` on numeric alarm columns unless specifically needed.
> - Alarm abbreviations: `CH` = Critical High, `MaH` = Major High, `MiH` = Minor High, `WaH` = Warning High, `Normal`, `WaL`, `MiL`, `MaL`, `CL`. NEVER use the full names.

---

### Groups

```xml
	<Groups>
		<Group id="1">
			<Name>PollDynamicScalars</Name>
			<Description>Poll Dynamic Scalars</Description>
			<Type>poll</Type>
			<Content>
				<Param>101</Param>
			</Content>
		</Group>
		<Group id="2">
			<Name>PollStaticScalars</Name>
			<Description>Poll Static Scalars</Description>
			<Type>poll</Type>
			<Content multipleGet="true">
				<Param>100</Param>
				<Param>102</Param>
			</Content>
		</Group>
		<Group id="3">
			<Name>PollPowerSourcesTable</Name>
			<Description>Poll Power Sources Table</Description>
			<Type>poll</Type>
			<Content>
				<Param>1000</Param>
			</Content>
		</Group>
		<Group id="10">
			<Name>After Startup</Name>
			<Description>After Startup initialization group</Description>
			<Type>poll action</Type>
			<Content>
				<Action>2</Action>
			</Content>
		</Group>
	</Groups>
```

> Key rules:
> - SNMP scalar groups use `<Param>` children with the parameter IDs.
> - Count direct `<Param>` references in each group: keep each to 10 or fewer. If one polling cadence has 11 scalars, split it into groups of 10 and 1; only the multi-parameter group uses `multipleGet`. Decide this per group rather than copying the attribute.
> - SNMP table groups use `<Param>` with the table array parameter ID.
> - **multipleGet on groups CANNOT be used for groups with table parameters in it.** Never set `multipleGet="true"` on a table polling group. Table retrieval methods are configured on the table parameter's `<SNMP><OID options="...">` tag (e.g. `options="multipleGetBulk"`), not on the group.
> - Group IDs are a separate namespace from parameter IDs.
> - The first group in `<Groups>` must be a poll group (`Group id="1"`), which DataMiner uses as the ping group. Initialization groups like `Group id="10"` must come after the poll group.

---

### Timers

```xml
	<Timers>
		<Timer id="1">
			<Name>FastTimer</Name>
			<Time initial="true">30000</Time>
			<Interval>75</Interval>
			<Content>
				<Group>1</Group>
				<Group>3</Group>
			</Content>
		</Timer>
		<Timer id="2">
			<Name>SlowTimer</Name>
			<Time initial="true">3600000</Time>
			<Interval>75</Interval>
			<Content>
				<Group>2</Group>
			</Content>
		</Timer>
	</Timers>
```

> Key rules:
> - `<Time>` is milliseconds (30000 = 30 seconds; 3600000 = 1 hour).
> - `<Interval>` is the delay in milliseconds between groups added to the queue (75ms is standard).
> - Tiered polling: Fast timer (30s) polls dynamic telemetry (`Group 1`) and active tables (`Group 3`). Slow timer (1h, `initial="true"`) polls static asset/configuration scalars (`Group 2`).
> - NEVER put the same group in multiple timers.

---

### PortSettings

Configure connection defaults and disable non-applicable settings for SNMP:

```xml
	<PortSettings name="SNMP Connection">
		<BusAddress>
			<Disabled>true</Disabled>
		</BusAddress>
		<IPport>
			<DefaultValue>161</DefaultValue>
		</IPport>
		<PortTypeSerial>
			<Disabled>true</Disabled>
		</PortTypeSerial>
	</PortSettings>
```

> Key rules:
> - `<BusAddress><Disabled>true</Disabled></BusAddress>`: Bus address is not used for SNMP; disabling it prevents operator confusion in the DataMiner Cube element creation wizard.
> - `<IPport><DefaultValue>161</DefaultValue></IPport>`: Standard SNMP UDP port.
> - `<PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>`: Disables invalid serial COM port selection for SNMP connections.

---

### Triggers and Actions (After-Startup Chain)

The after-startup chain can still be used whenever **one-time element initialization** is needed (such as executing an initialization group or triggering an After Startup QAction like `QAction 2`):

```xml
	<Triggers>
		<Trigger id="1">
			<Name>After Startup</Name>
			<On>protocol</On>
			<Time>after startup</Time>
			<Type>action</Type>
			<Content>
				<Id>1</Id>
			</Content>
		</Trigger>
	</Triggers>
	<Actions>
		<Action id="1">
			<Name>After Startup Group</Name>
			<On id="10">group</On>
			<Type>execute</Type>
		</Action>
		<Action id="2">
			<Name>After Startup QAction</Name>
			<On id="1">parameter</On>
			<Type>run actions</Type>
		</Action>
	</Actions>
```

> **After-Startup vs. Timer Polling Pattern**:
> - The after-startup chain/sequence can still be used whenever one-time initialization is needed (e.g. running an initialization QAction, resetting state, or running an initialization action group).
> - However, **never use the after-startup trigger to poll data at the start of an element if that same data will be retrieved through a timer**.
> - Routine polling groups (like `Group 1` and `Group 2`) belong exclusively on their timer (`PollTimer`). If an immediate first poll is desired on element startup, configure `<Time initial="true">` on the timer itself — do not re-enqueue those timer groups from an after-startup trigger.

---

## Complete Execution Flow for This Connector

```
Element starts
  → After Startup trigger fires → Action 1 queues Group 10 (init group)
  → Group 10 runs Action 2 → triggers QAction 2 for one-time initialization
  → PollTimer starts and queues Group 1 (scalars) and Group 2 (table)
  → Timer repeats every 30s → adds groups 1 and 2 to queue
  → Group 1 polls params 100, 101, 102 via SNMP Get
  → Group 2 polls table 1000 via SNMP GetBulk
  → SNMP responses fill parameter values
  → UI displays values to operator
```

---

## Common Mistakes to Avoid

| Wrong | Correct |
|-------|---------|
| `<OID>1.3.6.1.2.1.1.1.0</OID>` (no type) | `<OID type="complete">1.3.6.1.2.1.1.1.0</OID>` |
| `<Type>OctetString</Type>` (PascalCase) | `<Type>octetstring</Type>` (lowercase per [EnumSNMPType schema](https://aka.dataminer.services/enum-snmp-type)) |
| `<Type>TimeTicks</Type>` (PascalCase) | `<Type>timeticks</Type>` (lowercase per schema) |
| Write parameter with no SET/readback behavior | Put `snmpSetAndGet="true"` on the supplied scalar write parameter |
| Write param with no `<SNMP><Type>` | Always specify `<SNMP><Type>` on write params (strongly recommended) |
| `<Alarm><CriticalHigh>...</CriticalHigh>` | `<Alarm><CH>...</CH>` |
| `displayColumn="1001"` on ArrayOptions | `options=";naming=/1001"` on ArrayOptions |
| `<DeviceOID>1.3.6.1.4.1.9999.1</DeviceOID>` | `<DeviceOID>1</DeviceOID>` (single integer) |
| Write ID = read ID + 5000 | Write ID = read ID + 50 (max +100) |
| Table column `<Name>Index</Name>` | `<Name>devicePowerSourcesIndex</Name>` (tableNameColumnName) |
| Duplicate `Status` descriptions in multiple tables without context | Disambiguate only the duplicates, e.g. `Status (Device Power Sources)` |
| `<Measurement><Type>discreet</Type>` on table array | `<Measurement><Type>table</Type>` on table array |
| Index column with `<RawType>numeric text</RawType>` / `<Type>double</Type>` | Index column must be `<RawType>other</RawType>` / `<Type>string</Type>` / `<Measurement><Type>string</Type>` |
| Setting `multipleGet="true"` on a table group | `multipleGet` can only be used on groups with 2+ scalar parameters; NEVER on groups containing table parameters |
| Scalar read param ID 2000 | Scalar read param ID stays in 100–999 range |
