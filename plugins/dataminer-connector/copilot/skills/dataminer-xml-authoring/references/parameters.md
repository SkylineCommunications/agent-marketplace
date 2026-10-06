# Parameters — Full Reference

Full XML templates, attribute tables, valid children, schema verification, position uniqueness, and Read/Write pair details for `<Param>` elements.

## Full Param XML Example (SNMP scalar read)

```xml
<Param id="100" trending="false" save="true">
  <Name>systemDescription</Name>
  <Description>System Description</Description>
  <Information>
    <Subtext>Textual description of the device.</Subtext>
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
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.1.0</OID>
  </SNMP>
  <!-- SuppressValidator 2.5.1 String parameter — discrete alarm thresholds not applicable -->
  <Alarm>
    <Monitored>true</Monitored>
  </Alarm>
  <!-- /SuppressValidator 2.5.1 -->
</Param>
```

## `<SNMP><OID type="...">` Valid Values

> **`<OID type="...">` valid values**: `complete`, `auto`, `composed`, `wildcard`. These specify **how the OID path is expressed — not the SNMP data type or SNMP operation**.
> **NEVER** use SNMP data type names (`octetstring`, `timeticks`, `integer`, `gauge`, `counter`, `ipaddress`, etc.), SNMP operation names (`Get`, `GetNext`, `GetBulk`), **OR parameter direction names (`read`, `write`)** as the `type` attribute of `<OID>` — all of these cause an **XSD ERROR**. SNMP data types belong in a **separate `<SNMP><Type>` child element**. For SNMP table parameters, the polling operation is controlled by the table's group configuration, not by the OID `type` attribute. The read/write direction of a parameter is expressed by `<Param id="N" type="read">` and `<Param id="N" type="write">` — **never** by `<OID type="read">` or `<OID type="write">`: ❌ `<OID type="read">`, `<OID type="write">` → ✅ `<OID type="complete">1.3.6.1.2.1.1.4.0</OID>` on both read and write params.

```xml
<SNMP>
  <Enabled>true</Enabled>
  <OID type="complete">1.3.6.1.2.1.1.3.0</OID>
  <Type>timeticks</Type>
</SNMP>

<SNMP>
  <OID type="octetstring">1.3.6.1.2.1.1.1.0</OID>
  <OID type="timeticks">1.3.6.1.2.1.1.3.0</OID>
</SNMP>
```

## `<Param>` Attributes

```xml
<Param id="100" trending="true" save="false">
```

| Attribute | Values | Default | Notes |
|-----------|--------|---------|-------|
| `id` | integer | required | Unique across protocol |
| `trending` | `true` / `false` | `true` | **Attribute, NOT a child tag.** Controls whether trending is supported. |
| `save` | `true` / `false` | `false` | Persist value across element restarts |
| `export` | `true` / `false` / table id | — | DVE export |
| `duplicateAs` | integer | — | Duplicate parameter to another ID |
| `level` | integer | — | Security level |
| `options` | string | — | Semicolon-separated flags |

## Valid `<Param>` Child Elements

Only these elements are valid direct children of `<Param>`. **Any other tag placed directly inside `<Param>` is invalid XML and will cause validator errors.** When in doubt, consult the schema documentation at https://aka.dataminer.services/protocol-params-param.

| Element | Element | Element | Element |
|---------|---------|---------|---------|
| `Alarm` | `ArrayOptions` | `CRC` | `CrossDriverOptions` |
| `Dashboard` | `Database` | `Dependencies` | `Description` |
| `Display` | `HyperLinks` | `Icon` | `Information` |
| `Interprete` | `Length` | `Matrix` | `Measurement` |
| `Mediation` | `Message` | `Name` | `Replication` |
| `SNMP` | `Type` | | |

> **CRITICAL — Common Invalid Tags Inside `<Param>`**:
>
> - ❌ `<Param><Subtext>` — `Subtext` is NOT a child of `Param`. Use `<Param><Information><Subtext>`.
> - ❌ `<Param><Includes>` — `Includes` is NOT a child of `Param`. Use `<Param><Information><Includes>`.
> - ❌ `<Param><Text>` — `Text` is NOT a child of `Param`. Use `<Param><Information><Text>`.
> - ❌ `<Param><Trending>true</Trending>` — `Trending` is NOT a child element of `Param`. Use the **attribute**: `<Param trending="true">`.
> - ❌ `<Param><Units>` — `Units` is NOT a child of `Param`. Measurement units go in `<Param><Display><Units>` or `<Param><Interprete><Exceptions><Exception><Display><Units>>`.
>
> Note: `<Display><Trending>` *does* exist but defines the **averaging formula** for trend data (advanced use), not whether trending is enabled.

## Schema Verification Rule

**Before writing any XML element or attribute**, verify it is valid for its parent:
1. Check the valid children list above (for `<Param>`) or the schema docs for other elements.
2. For enumerated values (e.g. `<Type>` values, alarm tag names), verify the value is in the schema's allowed list.
3. URL pattern for schema docs: `https://docs.dataminer.services/develop/schemadoc/Protocol/{dot.separated.path}.html` — e.g., for `<Param><Information>`, use `Protocol.Params.Param.Information.html`.

## Position Uniqueness Rule

**Each Page + Row + Column combination must be used by at most ONE parameter.** Two unrelated parameters must never share the same position — this causes undefined rendering behavior.

The **only exception** is a **read/write parameter pair**: the read and write params MUST share identical `<Positions>` so DataMiner renders them as a single combined control (see below).

## Naming Convention: Before/After Examples

### Before/After: System-Info Scalars (PIDs 100–102)

```xml
<Param id="100" trending="false" save="true">
  <Name>SystemName</Name>
  <Description>System Name</Description>
  ...
</Param>
<Param id="101" trending="false" save="true">
  <Name>SystemDescription</Name>
  <Description>System Description</Description>
  ...
</Param>
<Param id="102" trending="false" save="true">
  <Name>SystemUptime</Name>
  <Description>System Uptime</Description>
  ...
</Param>

<Param id="100" trending="false" save="true">
  <Name>systemName</Name>
  <Description>System Name</Description>
  ...
</Param>
<Param id="101" trending="false" save="true">
  <Name>systemDescription</Name>
  <Description>System Description</Description>
  ...
</Param>
<Param id="102" trending="false" save="true">
  <Name>systemUptime</Name>
  <Description>System Uptime</Description>
  ...
</Param>
```

### Before/After: HTTP Response Params (PIDs 99–100, 199–200)

```xml
<Param id="99" trending="false">
  <Name>SystemInfoStatusCode</Name>
  <Description>System Info Status Code</Description>
  <Type>read</Type>
  ...
</Param>
<Param id="100" trending="false">
  <Name>SystemInfoResponse</Name>
  <Description>System Info Response</Description>
  <Type>read</Type>
  ...
</Param>

<Param id="99" trending="false">
  <Name>systemInfoStatusCode</Name>
  <Description>System Info Status Code</Description>
  <Type>read</Type>
  ...
</Param>
<Param id="100" trending="false">
  <Name>systemInfoResponse</Name>
  <Description>System Info Response</Description>
  <Type>read</Type>
  ...
</Param>
```

## Read/Write Parameter Pairs — Full XML Example

```xml
<Param id="100" trending="false" save="true">
  <Name>systemName</Name>
  <Description>System Name</Description>
  <Information>
    <Subtext>The configured name of this device as reported by the system.</Subtext>
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
      <Position><Page>General</Page><Row>0</Row><Column>0</Column></Position>
    </Positions>
  </Display>
</Param>

<Param id="150" trending="false">
  <Name>systemName</Name>
  <Description>System Name</Description>
  <Information>
    <Subtext>The configured name of this device as reported by the system.</Subtext>
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
      <Position><Page>General</Page><Row>0</Row><Column>0</Column></Position>
    </Positions>
  </Display>
</Param>
```

## Read/Write Pair Pre-Completion Checklist

After writing any read/write pair, verify both parameters before proceeding:

| Check | Rule | Example pass | Example fail |
|-------|------|-------------|-------------|
| **`<Information><Subtext>` present on BOTH** | **EVERY param needs it — no exceptions** | `<Information><Subtext>The configured name...</Subtext></Information>` | `<Param>` with no `<Information>` child |
| `<Name>` identical | **Exact character-for-character match** — different names = separate UI controls, not a combo | Both `systemName` | Read `systemName`, write `systemNameWrite` ❌ |
| `<Description>` identical | **Exact match** — never append "(Write)" or any suffix | Both `System Name` | Read `System Name`, write `System Name (Write)` ❌ |
| `<Positions>` identical | Same page, row, column on both | Both `General / Row 0 / Col 0` | Read `Row 0`, write `Row 1` |
| Write param: no `trending`/`save` | Only on read param | `<Param id="150" trending="false">` | `<Param id="150" trending="true" save="true">` |
| **Write ID = read ID + 50 (or + 100, max)** | **NEVER use `read ID + 1000` or any offset > 100** | All writes at read ID + 50 | read 103 → write 1103 (offset 1000 — breaks adjacency) |
| XML adjacency | Write param immediately follows its read param | `<Param id="100">` then `<Param id="150">` | Write param separated by unrelated params |

> **Single read-only parameters** must also satisfy the first row above — `<Information><Subtext>` is required on **every** parameter, paired or not. **After generating any batch of parameters, you MUST scan each one for `<Information><Subtext>` before proceeding. Emitting a parameter without `<Information><Subtext>` is ALWAYS a bug — there are no exceptions, including SNMP table index columns, write params, dummy params, and AfterStartup params.**
>
> **MANDATORY FINAL GATE — before marking any connector task complete**: Count every `<Param>` block in `protocol.xml`. Every single one — including write params, table columns, and low-ID scalars — must contain `<Information><Subtext>`. If even one is missing, add it before proceeding. Low-numbered params (PID 1–10) are the most commonly forgotten.
>
> **Also verify ascending PID order**: Scan the `<Params>` section from top to bottom. Each `<Param id="N">` must have `N` greater than the previous param's ID, with the only exception being a write param immediately following its read. Dummy/internal params with low PIDs (e.g. AfterStartup at PID 2) are especially prone to being placed out of order.

## Ascending ID Order Rule

> **NEVER write XML elements in conceptual/logical order and then leave them unordered. Low-numbered internal parameters (e.g. AfterStartup at PID 2) MUST physically appear before any higher-numbered parameter in the XML — even if you author them last.**
>
> **Invalid ordering:**
> ```xml
> <Param id="10"></Param>
> <Param id="13"></Param>
> <Param id="2"></Param>
> ```
>
> **Correct ordering:**
> ```xml
> <Param id="2"></Param>
> <Param id="10"></Param>
> <Param id="13"></Param>
> ```

> **Forbidden offset anti-patterns**: Write parameter ID = read ID + **50** (preferred) or **+100** (maximum). The offset must never exceed 100. Three patterns are always forbidden: "50000 + read ID", "1000 + read ID" (writes grouped in 1000+), and "large-offset table column write" (reads in 2000s, writes in 10000+). All three break ascending-ID adjacency.

## Discrete Parameters with Numeric Backend

When creating parameters that represent pre-known values (enumerations, operational states, modes, statuses, or boolean conditions):
- **Measurement Type**: Use `<Measurement><Type>discreet</Type>` (for 3+ states) or `<Measurement><Type>togglebutton</Type>` (for 2-state booleans).
- **Backend Type**: `<Interprete><Type>double</Type></Interprete>` with `<RawType>numeric text</RawType>` (or `other` if converted in a QAction).
- **Discreets Definition**: Add `<Discreets>` under `<Measurement>`, with each `<Discreet>` containing:
  - `<Value>`: Numeric integer value (`1`, `2`, `3`, etc.).
  - `<Display>`: Human-readable, Title Case label seen by operators in Cube and Web UI.
- **Alarming & Trending**:
  - The numeric backend value allows DataMiner to monitor alarms using `<Alarm><Monitored>true</Monitored>` and standard thresholds (e.g. `<Normal>`, `<WaH>`, `<MaH>`, `<CH>`).
  - The numeric backend value allows DataMiner to trend historical state changes (`trending="true"`).
- **Never use strings for known enums**: Storing pre-known states as raw strings prevents proper numeric alarm templates and restricts trending.

```xml
<Param id="103" trending="true">
	<Name>operationalState</Name>
	<Description>Operational State</Description>
	<Information>
		<Subtext>Operational state of the device.</Subtext>
	</Information>
	<Type>read</Type>
	<Interprete>
		<RawType>numeric text</RawType>
		<Type>double</Type>
		<LengthType>next param</LengthType>
	</Interprete>
	<Display>
		<RTDisplay>true</RTDisplay>
		<Positions>
			<Position>
				<Page>General</Page>
				<Row>3</Row>
				<Column>0</Column>
			</Position>
		</Positions>
	</Display>
	<Alarm>
		<Monitored>true</Monitored>
		<Normal>1</Normal>
		<WaH>2</WaH>
		<CH>3</CH>
	</Alarm>
	<Measurement>
		<Type>discreet</Type>
		<Discreets>
			<Discreet>
				<Display>Online</Display>
				<Value>1</Value>
			</Discreet>
			<Discreet>
				<Display>Standby</Display>
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
		<OID type="complete">1.3.6.1.4.1.8813.2.1.3.0</OID>
		<Type>integer</Type>
	</SNMP>
</Param>
```
