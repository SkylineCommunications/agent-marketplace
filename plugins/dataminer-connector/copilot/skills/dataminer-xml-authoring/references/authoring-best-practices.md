# Authoring Best Practices

Logical authoring guidance for DataMiner connector XML: alarming and monitoring decisions, unit and range choices, UI conventions, MIB enum conversion, measurement type selection, and table relations.

> **Parent skill**: `dataminer-xml-authoring/SKILL.md` — return there for core authoring rules.
> XSD structure for the elements discussed here is in `protocol-params.md` and `protocol-core.md`.

---

## Alarm Threshold Guidelines

### Parameter Alarming Eligibility: Valid vs. Excluded Parameters

**Valid Parameters — MUST have `<Alarm><Monitored>true</Monitored>`:**
All operational health, state, and telemetry parameters that are displayed (`<RTDisplay>true</RTDisplay>`) are valid for alarming and **MUST** have `<Alarm><Monitored>true</Monitored>`. Leaving operational telemetry unmonitored defeats the monitoring purpose of the connector. Valid parameters include:
- **Operational telemetry & metrics**: voltages (`V`), currents (`A`), power / real power / apparent power (`W`, `VA`), frequencies (`Hz`), battery charge level / capacity (`%`), remaining run time, temperatures (`°C`), fan speeds (`RPM`), RSSI / signal levels (`dBm`), utilization (`%`).
- **State & health indicators**: operational status (e.g. 1=Up, 2=Down; Online/Offline/Fault), link states, error counters/rates, packet loss, warning/alarm status indicators.
- Configure `<Alarm><Monitored>true</Monitored>` with appropriate default thresholds (e.g. `<Normal>`, `<WaH>`, `<MaH>`, `<CH>`, `<WaL>`, `<MiL>`, `<MaL>`, `<CL>`), or an explicit, justified `SuppressValidator 2.5.1` when nominal values depend on installation/grid context or lack industry-standard defaults.

**Excluded / Invalid Parameters — MUST NOT have `<Alarm><Monitored>true</Monitored>`:**
- **Write parameters** (`<Type>write</Type>`): used for control/setting values to the device, never alarmable.
- **Internal / dummy parameters** (`<Type>dummy</Type>`, AfterStartup, internal triggers): never alarmable.
- **Structural table array parameters** (`<Param type="array">`): table containers cannot be alarmed.
- **Table primary keys** (`idx="0"` / PK index column): unique row identifier indices are not operational telemetry.
- **Display key columns** (`type="displaykey"`): row naming/label strings are not alarmable.
- **Static asset / identity data**: serial numbers, model, manufacturer, system description, MAC addresses, firmware versions.
- **Hidden / intermediate parameters** (`<RTDisplay>false</RTDisplay>`): validator rule 2.24.6 prohibits alarm monitoring on parameters with `RTDisplay=false`.
- **Columns in volatile tables**: DataMiner validator rule 2.78.5 prohibits alarm monitoring on volatile tables.

When an alarmable parameter has `<Monitored>true</Monitored>`, evaluate whether reasonable default thresholds can be determined:

- **Discrete parameters** (type `discreet`, integer): add default alarm thresholds in the `<Alarm>` block mapping the "bad" discreet value(s) to alarm severity. Example for a link-state param (1=Up, 2=Down): set `Down` as a critical or major alarm. If no single value is clearly bad, suppress 2.5.1:
  ```xml
  <Alarm>
    <Monitored>true</Monitored>
    <CH>2</CH>
    <Normal>1</Normal>
  </Alarm>
  ```
  If the semantics are ambiguous (e.g., a status enum where no value is categorically "bad"), suppress validator remark 2.5.1:
  ```xml
  <!-- SuppressValidator 2.5.1 Discrete parameter — default alarm thresholds not determinable without device context -->
  <Alarm>
    <Monitored>true</Monitored>
  </Alarm>
  <!-- /SuppressValidator 2.5.1 -->
  ```
- **Percentage parameters** (0–100%): `<WaH>90</WaH><MaH>95</MaH><CH>99</CH>` — optionally add low thresholds where applicable (e.g., disk free space, signal quality).
- **Temperature** (Celsius): `<WaH>70</WaH><MaH>80</MaH><CH>90</CH>`
- **Error rates / loss rates**: `<WaH>1</WaH><MaH>5</MaH><CH>10</CH>`
- **Signal levels** (dBm): thresholds depend on technology — set based on device spec.
- **Parameters with well-understood semantics**: provide thresholds aligned with industry norms or vendor documentation.
- **No determinable thresholds**: if the parameter must support alarming but no reasonable defaults exist (generic counters, IDs, sequence numbers, uptime ticks, device-specific values without industry norms), suppress validator remark 2.5.1:
  ```xml
  <!-- SuppressValidator 2.5.1 No meaningful default alarm thresholds for this parameter -->
  <Alarm>
    <Monitored>true</Monitored>
  </Alarm>
  <!-- /SuppressValidator 2.5.1 -->
  ```
- **Operational health & state parameters**: Key operational indicators (e.g., battery charge level/capacity %, remaining battery run time, input/output voltages, power, line frequency, interface link states, error rates, temperature) MUST have `<Alarm><Monitored>true</Monitored>` configured with appropriate default thresholds (or an explicit, justified `SuppressValidator 2.5.1` when nominal values vary by deployment/grid such as 50Hz vs 60Hz).
- **Alarmable string parameters**: numeric thresholds do not apply. Suppress 2.5.1 only when the string parameter has an explicit alarming requirement:
  ```xml
  <!-- SuppressValidator 2.5.1 String parameter — discrete alarm thresholds not applicable -->
  <Alarm>
    <Monitored>true</Monitored>
  </Alarm>
  <!-- /SuppressValidator 2.5.1 -->
  ```

**Never invent arbitrary thresholds** — wrong defaults cause false alarms in production.

For a parameter that is excluded from alarming (static info, write, dummy, hidden), omit `<Alarm>` entirely. If an Alarm block is intentionally retained without monitoring, explicitly put `Monitored` first with `<Monitored>false</Monitored>`.

---

## Units Decision (2.9.7)

For **every** `<Measurement><Type>number</Type></Measurement>` parameter, do exactly one of:

- **Add units** via `<Display><Units>` when a recognized physical/engineering unit applies: `%`, `dBm`, `dB`, `bps`, `Kbps`, `Mbps`, `Gbps`, `Bps`, `KBps`, `MBps`, `ms`, `s`, `MHz`, `GHz`, `GB`, `MB`, `KB`, `W`, `°C`, `V`, `A`, `Packets`, `Octets`. **Packet/frame counters** (Rx Packets, Tx Packets, Rx Frames, Tx Frames) use `Packets`. **Byte/octet counters** use `Octets`. **Bit-rate params** use `bps`/`Kbps`/etc.
- **Suppress 2.9.7** when the number is dimensionless (index, count, ID, sequence number, ratio, priority, hop count, retry count, slot number, error code, VLAN ID, port number, uptime ticks, session count, or any plain counter/identifier not tied to a measurement unit):
  ```xml
  <!-- SuppressValidator 2.9.7 Dimensionless number parameter, no unit applicable -->
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <!-- /SuppressValidator 2.9.7 -->
  ```

Enable trending when the parameter's historical values are useful. For a trended string parameter, use `<Display><Trending><Type>last</Type></Trending></Display>` because aggregation by average is not meaningful for text.

---

## Range Decision (2.11.1)

For **every** displayed `number` parameter (`<RTDisplay>true</RTDisplay>`), do exactly one of:

- **Add a range** via `<Display><Range>` when bounds are determinable:
  - Percentage (0–100): `<Range><Low>0</Low><High>100</High></Range>`
  - Known-bounded values: VLAN ID 1–4094, TTL 0–255, signal level per spec, etc.
- **Suppress 2.11.1** when no meaningful bound exists (generic counters, timestamps, uptime ticks, cumulative byte counts, cumulative packet counts, free-form numeric IDs). Packet counter and octet counter columns are the most common case — they have no meaningful upper bound:
  ```xml
  <!-- SuppressValidator 2.11.1 Cumulative counter — no meaningful upper bound -->
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <!-- /SuppressValidator 2.11.1 -->
  ```

**Never invent arbitrary ranges** — a wrong range silently drops valid data.

---

## Trending Configuration

### Enabling Trending (`trending` Attribute on `<Param>`)

The `trending` attribute on `<Param>` controls **whether** a parameter is trended at all. Apply these rules for **every** parameter:

- **Set `trending="true"`** (default behaviour when omitted, but **always declare it explicitly**) on every **numeric (`double`/`number`) parameter** that is displayed (`RTDisplay=true`) and not an index or foreign key column. This includes scalar gauges, rates, counters, signal levels, temperature, etc.
- **Set `trending="false"`** for:
  - Index columns and foreign key columns in tables.
  - Write parameters.
  - Internal/helper parameters not visible on a page.
  - Discreet/enum parameters where trending has no analytical value (e.g., a simple Admin State).

For string parameters where history is useful, set `trending="true"` and use aggregation type `last`. Disable trending where historical text values have no operational value.

```xml
<!-- ✅ Correct — numeric param with trending enabled -->
<Param id="200" trending="true">
  <Name>cpuUtilization</Name>
  <Description>CPU Utilization</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Units>%</Units>
    <Range><Low>0</Low><High>100</High></Range>
    <Positions>
      <Position><Page>General</Page><Row>1</Row><Column>0</Column></Position>
    </Positions>
  </Display>
  <Alarm><Monitored>true</Monitored><WaH>90</WaH><MaH>95</MaH><CH>99</CH></Alarm>
  <Measurement><Type>number</Type></Measurement>
</Param>

<!-- ✅ Correct — string param with trending disabled -->
<Param id="100" trending="false">
  <Name>systemDescription</Name>
  <Description>System Description</Description>
  <Type>read</Type>
  ...
</Param>

<!-- ✅ Correct — index column with trending disabled -->
<Param id="1001" trending="false">
  <Name>interfacesIndex</Name>
  ...
</Param>
```

### Trending Aggregation Formula (`<Display><Trending>`)

`<Display><Trending>` is **not** for enabling/disabling trending — it defines how average trending data is calculated:

```xml
<Display>
  <RTDisplay>true</RTDisplay>
  <Trending>
    <Type>average</Type>
  </Trending>
</Display>
```

Valid `<Type>` values: `average` (default), `last`, `max`, `min`, `sum`. Only add if you need non-default aggregation.

---

## Parameter Display & Page Layout

Displaying a parameter on a page involves two levels of configuration: the **protocol-level `<Display>` element** (page ordering and layout) and the **parameter-level `<Param><Display>` element** (RTDisplay, Positions, Units, Range, etc.).

> **Source**: [Protocol.Params.Param.Display](https://aka.dataminer.services/protocol-params-param-display), [Visualizing UI components](https://aka.dataminer.services/ui-components-visualization)

### Protocol-Level `<Display>` Element

The protocol-level `<Display>` tag (direct child of `<Protocol>`) controls page order and layout:

```xml
<Display defaultPage="General" pageOrder="General;Configuration;-----;Webinterface#http://[Polling Ip]/" wideColumnPages="Configuration" />
```

| Attribute | Description |
|-----------|-------------|
| `defaultPage` | Page shown when opening the element. **Must match** an existing page (= a page with at least one parameter positioned on it). |
| `pageOrder` | Semicolon-separated list defining page tab order. Without it, pages are alphabetical. |
| `wideColumnPages` | Semicolon-separated page names rendered as **single-column** (full-width) layout — use for pages that hold tables. |
| `type` | Special display modes: `element manager` (EPM), `spectrum analyzer`. |
| `pageOptions` | EPM-specific: e.g. `"*;CPEOnly"` to disable Data Display. |

**`pageOrder` special entries:**
- **Separators**: an entry starting with at least three dashes (`-----`) inserts a visual divider between page groups.
- **Web interface links**: `PageName#http://[Polling Ip]/` or `PageName#http://[id:PID]` — opens the device web UI in an embedded browser. The `[Polling Ip]` placeholder is replaced at runtime; `[id:PID]` uses the value of the referenced parameter (must have `RTDisplay` true and `Interprete/Type` = `string`).

**Page visibility** — pages can be shown/hidden dynamically via `<Display><Pages>`:

```xml
<Display defaultPage="General" pageOrder="General;Advanced">
  <Pages>
    <Page name="Advanced" visible="false">
      <Visibility>
        <If pid="10">1</If>
      </Visibility>
    </Page>
  </Pages>
</Display>
```

### Parameter-Level Display: Making a Parameter Visible

To display a parameter on a page, its `<Display>` block needs two things:

1. **`<RTDisplay>true</RTDisplay>`** — pushes the parameter to the SLElement process so it can be rendered.
2. **`<Positions>`** — specifies where on which page(s) the parameter appears.

```xml
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
```

#### `<Position>` Child Elements

| Element | Type | Description |
|---------|------|-------------|
| `<Page>` | non-empty string | Name of the Data Display page this parameter is positioned on. **Must match** a page declared in `pageOrder` — a `<Page>` value absent from `pageOrder` causes MAJOR "The specified page 'X' does not exist". |
| `<Row>` | unsignedInt (0-based) | Vertical position on the page. `0` = first row. |
| `<Column>` | unsignedInt (0-based) | Horizontal position. `0` = left column, `1` = right column. |

The `<Page>` element also supports an optional `measType` attribute to override how the parameter renders on that specific page.

#### Position Uniqueness Rule

**Each Page + Row + Column location must be occupied by at most ONE parameter.** Two unrelated parameters must never share the same position — this causes undefined rendering behavior.

The **sole exception** is **read/write parameter pairs**: the read param and its corresponding write param **MUST share the exact same `<Name>`, `<Description>`, and Position** (identical Page, Row, and Column). The **`<Name>` match is the primary key** — if read and write have different names, DataMiner treats them as unrelated parameters and renders them as two separate controls instead of a combined read/write combo.

```xml
<Param id="100"><Type>read</Type>
  <Display><RTDisplay>true</RTDisplay>
    <Positions><Position><Page>General</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
</Param>
<Param id="150"><Type>write</Type>
  <Display><RTDisplay>true</RTDisplay>
    <Positions><Position><Page>General</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
</Param>

<Param id="100"><Type>read</Type>
  <Display><RTDisplay>true</RTDisplay>
    <Positions><Position><Page>General</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
</Param>
<Param id="101"><Type>read</Type>
  <Display><RTDisplay>true</RTDisplay>
    <Positions><Position><Page>General</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
</Param>
```

#### Multi-Table Page Layout

When multiple table array params share a page, **pre-plan their row/column assignments before writing any XML**.

**Row assignment** — rows are per-object (one table = one row slot):
- 1st table on the page → `<Row>0</Row>`
- 2nd table → `<Row>1</Row>`
- 3rd table → `<Row>2</Row>`, and so on.

**NEVER assign the same Row to two different tables on the same page** — they will overlap.

**Column assignment**:
- Default is `<Column>0</Column>` for all tables.
- A table MAY be placed at `<Column>1</Column>` only when it has **very few displayed columns** so it fits alongside the Column 0 table on the same row.
- **NEVER** place two wide tables (many columns) side-by-side at Column 0 and Column 1 — the result is unreadable.

```xml
<Position><Page>Status</Page><Row>0</Row><Column>0</Column></Position>
<Position><Page>Status</Page><Row>1</Row><Column>0</Column></Position>
<Position><Page>Status</Page><Row>2</Row><Column>0</Column></Position>

<Position><Page>Status</Page><Row>0</Row><Column>0</Column></Position>
<Position><Page>Status</Page><Row>0</Row><Column>1</Column></Position>

<Position><Page>Status</Page><Row>0</Row><Column>0</Column></Position>
<Position><Page>Status</Page><Row>0</Row><Column>0</Column></Position>
```

#### Multiple Positions

A parameter can appear on **more than one page** by including multiple `<Position>` entries inside `<Positions>`:

```xml
<Positions>
  <Position>
    <Page>General</Page><Row>0</Row><Column>0</Column>
  </Position>
  <Position>
    <Page>Status</Page><Row>3</Row><Column>1</Column>
  </Position>
</Positions>
```

#### When `RTDisplay` Is Needed Without `Positions`

Some parameters need `<RTDisplay>true</RTDisplay>` even though they are **not** displayed on a page:
- Parameters referenced in **conditions** on groups/triggers/actions.
- Parameters used as **placeholders** in `pageOrder` web interface links (`[id:PID]`).
- Parameters consumed by **dashboards**, **GQI queries**, or **Visio** drawings.
- Parameters exposed for **external element** access (inter-element gets).
- **Table array parameters** that use `<Positions>` for the table itself (but their individual **column** parameters must NOT have `<Positions>`).

#### Table Parameters and Positions

- The **table array parameter** (type `array`) gets `<RTDisplay>true</RTDisplay>` and `<Positions>` to show the table on a page.
- **Column parameters** MUST NOT have `<Positions>` — `<Positions>` belongs only on the table array param. Adding `<Positions>` to column params causes a MINOR validator finding on every column.
- Table pages should be listed in `wideColumnPages` for single-column (full-width) rendering.

### Page Design Rules

- Maximum **2 columns** per page (column 0 and column 1).
- Every protocol must have a **General page** as the default. A General page only exists if at least one parameter has `<Page>General</Page>` in its `<Positions>` block — listing it in `pageOrder` or `defaultPage` alone is not sufficient.
- Include a page for **each functional block** of the device.
- If the device has a web UI, add a **Web Interface page** as the last entry in `pageOrder`, preceded by a `-----` separator. Use `Webinterface#http://[Polling Ip]/` — the `[Polling Ip]` placeholder is replaced at runtime.
- Maintain consistent **look and feel** across protocols in the same vendor product line.

**Minimum General page pattern for table-heavy SNMP connectors** — create at least one scalar positioned on the General page before writing any table params:

```xml
<Param id="100" trending="false">
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
</Param>
```

---

## Parameter Naming Conventions

The `<Name>` element is the internal identifier used by DataMiner for referencing parameters in QActions, conditions, and exports. It must follow strict casing rules:

- **Standalone read parameters**: `<Name>` must be **camelCase** — first word lowercase, subsequent words capitalized. Example: `hostname`, `softwareVersion`, `systemDescription`.
- **Write parameters**: same camelCase name as the corresponding read parameter (the `<Name>` match is what pairs them as a read/write combo).
- **Table array parameters**: camelCase, typically a concise noun reflecting the table content (e.g., `interfaces`, `portStatuses`).
- **Table column parameters**: camelCase and prefixed with the exact table name (e.g., `interfacesIndex`, `interfacesDescription`). The prefix always starts lowercase and is copied character-for-character from the table `<Name>`.
- **No spaces, underscores, or hyphens** in `<Name>` — use camelCase word boundaries only.

> **Wrong**: `<Name>Hostname</Name>`, `<Name>SoftwareVersion</Name>`, `<Name>System_Description</Name>`, `<Name>InterfacesName</Name>`
> **Correct**: `<Name>hostname</Name>`, `<Name>softwareVersion</Name>`, `<Name>systemDescription</Name>`, `<Name>interfacesName</Name>`

The `<Description>` element is separate and follows title-case display conventions — `<Name>` and `<Description>` have independent casing rules.

---

## Displayed Text Conventions

- **Title case** for descriptions: capitalize every word except ≤3-letter non-first words (unless noun/pronoun/verb/reserved term).
- **Brand/product names**: use official capitalization.
- **Acronyms** (IP, DVB, MPTS): capital letters per their defining standards.
- Avoid `"True/False"` display values — use meaningful values (e.g., `"Automatic"` / `"Manual"`).

---

## Buttons and Controls

- Button width: **explicitly defined**, minimum **110**, uniform across protocol.
- Page button labels end with **ellipsis** (`"..."`) with no space before it.
- No nested page buttons.
- **Toggle button**: 2 values where second is obvious from first. Otherwise use dropdown.
- Consider **progress bars** for long-running operations.

---

## Table Display Conventions

- Number columns with alarming show header sum, heatmap, and histogram by default — **always** add `disableHeaderSum`, `disableHeatmap`, and `disableHistogram` column options unless the user explicitly requests them enabled.
- Column names start with the table name.
- Disambiguate duplicate column descriptions with table name in parentheses.

---

## Connection Naming

- Single connection: `"IP Connection"`, `"HTTP Connection"`, `"SNMP Connection"`, `"Serial Connection"`.
- Multiple same-type connections must have a distinguishing suffix (e.g., `"IP Connection - Redundant"`).
- HTTP: default bus address = `"ByPassProxy"`.

---

## SNMP MIB Enum → Display Value Conversion

When discrete values come from SNMP MIB definitions, enum names are typically camelCase or PascalCase. Convert to **human-readable, space-separated, title-cased** display values.

### Conversion Algorithm

1. **Split on word boundaries**: insert a space before each uppercase letter that follows a lowercase letter, before a trailing run of uppercase letters treated as an acronym, and before a digit that follows a letter (or vice versa).
2. **Apply title case**: capitalize every word except short prepositions/conjunctions mid-value (a, an, and, as, at, but, by, for, in, nor, of, on, or, so, the, to, up, yet). Always capitalize the first word.

### CamelCase/PascalCase Examples

| Raw MIB enum name | Display value |
|-------------------|---------------|
| `deliveringPower` | `Delivering Power` |
| `DeliveringPower` | `Delivering Power` |
| `OtherFault` | `Other Fault` |
| `VoltsAC` | `Volts AC` |
| `VoltsDC` | `Volts DC` |
| `PercentRH` | `Percent RH` |
| `Class0` | `Class 0` |
| `adminUp` | `Admin Up` |
| `notPresent` | `Not Present` |
| `lowerNonCritical` | `Lower Non Critical` |

### Plain Lowercase Enum Names

Plain lowercase names still require title case — capitalize the first letter of every word:

| Raw MIB enum name | Display value |
|-------------------|---------------|
| `yocto` | `Yocto` |
| `milli` | `Milli` |
| `units` | `Units` |
| `kilo` | `Kilo` |
| `mega` | `Mega` |
| `online` | `Online` |
| `disabled` | `Disabled` |
| `ok` | `Ok` |

**Never use raw MIB enum names directly as `<Display>` values.**

---

## Scalar Parameter Measurement Type Selection

Every displayed parameter (`<RTDisplay>true</RTDisplay>`) must have a `<Measurement><Type>` tag:

| Interpreted type | `<Type>` to use |
|-----------------|-----------------|
| `double` (numeric) | `number` |
| `string` | `string` |
| Boolean 2-state enum (Enable/Disable, On/Off, True/False, Up/Down) | `togglebutton` |
| Enum with 3+ values (`double` + discreets) | `discreet` |
| OLE Automation date | `number` with `options="date"` |
| Elapsed time, duration, uptime, remaining run time, or timeout (seconds) | `number` with `options="time"` |
| Seconds since midnight | `number` with `options="time"` |
| Combined date+time | `number` with `options="datetime"` |

**`togglebutton` vs `discreet`**: When a parameter has **exactly 2 discrete states** with boolean semantics, **always use `togglebutton`** — `discreet` on a 2-state boolean triggers a MINOR validator recommendation. Use `discreet` only for 3 or more distinct values. This includes any SNMP `TruthValue` / `INTEGER {true(1), false(2)}`.

```xml
<Measurement>
  <Type>togglebutton</Type>
  <Discreets>
    <Discreet><Display>Disabled</Display><Value>1</Value></Discreet>
    <Discreet><Display>Enabled</Display><Value>2</Value></Discreet>
  </Discreets>
</Measurement>
```

### Discrete Parameters with Numeric Backend (Alarms & Trending)

When creating parameters that represent pre-known values (enumerations, states, modes, statuses, or boolean conditions):

- **MUST be discrete**: Use `<Measurement><Type>discreet</Type>` (for 3+ states) or `<Measurement><Type>togglebutton</Type>` (for 2-state booleans).
- **Backend value MUST be numeric (`double`)**: In `<Interprete>`, specify:
  ```xml
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  ```
  **Why a numeric backend is required:**
  1. **Alarming**: DataMiner alarm monitoring (`<Alarm><Monitored>true</Monitored>`) evaluates numeric thresholds (e.g. `<Normal>`, `<WaH>`, `<MaH>`, `<CH>`) to determine alarm states. String parameters cannot be monitored with standard numeric alarm templates and cause validator rule 2.5.1 findings.
  2. **Trending**: Numeric parameters support standard trending (`trending="true"`) in DataMiner, recording state transitions and historical data over time. String parameters have severely restricted trending capabilities.
- **Display value (`<Display>`) is for end users**: `<Discreet><Display>` can be any clear, human-readable text that conveys the state to operators in DataMiner Cube and Web apps.
- **Anti-pattern — Raw String Parameters for Known States**: Never create a `<Type>string</Type>` parameter to store known status or state values like `"Online"`, `"Offline"`, or `"Fault"`. Always store numeric values (`1`, `2`, `3`) mapped to those display labels via `<Discreets>`.

### Date / Time / Datetime

```xml
<Measurement><Type options="date">number</Type></Measurement>

<Measurement><Type options="time">number</Type></Measurement>

<Measurement><Type options="datetime">number</Type></Measurement>
```

**Duration / Time formatting (`options="time"`)**: Whenever a numeric parameter represents an elapsed duration, uptime, remaining battery run time, counter, or timeout in seconds, always specify `options="time"` on `<Measurement><Type>number</Type></Measurement>`. DataMiner automatically converts and displays the raw seconds value into a human-readable `hh:mm:ss` (or `d hh:mm:ss`) format in the UI. Omitting this leaves raw integer second values that are difficult for operators to read.

### Measurement Type `options` Reference

Valid values for the `options` attribute on `<Param><Measurement><Type options="...">`. Options are semicolon-separated. **Only these values are valid — do NOT invent others.** (For the allowed `<Type>` values themselves, see `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md`.)

| `<Type>` | Option | Description |
|----------|--------|-------------|
| `string` | `password` | Masks input (displays `*`), encrypts stored value. **Required for passwords, secrets, tokens, API keys.** Works for standalone params and table cells. |
| `string` | `hscroll` | Adds a horizontal scrollbar (long/list content). |
| `string` | `tab` | Sets tab distance (text start position in the box). |
| `string` | `fixedfont` | Fixed-width font for display. |
| `string` | `number` | Restricts input to numeric characters only. |
| `number` | `time` / `time:minute` / `time:hour` | Display as duration (value = total seconds / minutes / hours). |
| `number` | `date` | Display as date (OLE Automation date). |
| `number` | `datetime` / `datetime:minute` | Display as date+time (OLE Automation date); `:minute` omits seconds. |
| `analog` | `hscroll` | Stretches the analog parameter vertically. |
| `table` | `tab=columns:...,lines:...,width:...,sort:...,filter:...` | Configure table layout: column order, line count, widths, sort types, filter toggle. |
| `matrix` | `matrix=inputs,outputs,COMin,COMax,CIMin,CIMax[,pages][,noDisconnectsInBackup]` | Configure matrix dimensions and behavior. |
| `title` | `begin` / `end` | Horizontal line marking the start / end of a page section. |
| any | `custom=disableWrite:pid=value` | Makes a column read-only based on another column's value. |

> Schema doc: `https://aka.dataminer.services/protocol-params-param-measurement-type-options`

### Table `tab=` Layout Sub-Options

The `table` measurement type uses `<Type options="tab=...">table</Type>` to control table rendering. Sub-options are comma-separated inside the `tab=` value:

| Sub-option | Format | Required | Description |
|------------|--------|----------|-------------|
| `columns` | `pid\|displayIdx` per column, dash-separated | Yes | Which columns are **visible** and their **display order**. `pid` must match a `<ColumnOption pid>`. `displayIdx` is a **0-based** left-to-right position. **By default list EVERY `<ColumnOption pid>`** — columns not listed are **hidden**; omit a PID only when the user explicitly asks to hide that column (e.g., internal rate-calc helper columns). |
| `lines` | integer | No | Initial visible row count (does not limit actual data; scroll for the rest). Default `20`. |
| `width` | pixels per column, dash-separated | No | Width per visible column. Omit to auto-size. Example `width:100-150-200`. |
| `sort` | type per column, dash-separated | No | `INT`, `STRING`, or `DATETIME`. Optionally append `\|ASC\|priority` / `\|DESC\|priority` for default direction and multi-column sort priority (0-based, lower = higher). |
| `filter` | `true` | No | Adds a filter/search box. Omit or `false` to hide. |

**Hiding a column from the UI**: keep its `<ColumnOption>` in `<ArrayOptions>` but omit its PID from `columns:` (and from `width:`/`sort:`). Only listed columns render.

```xml
<ArrayOptions index="0">
  <ColumnOption idx="0" pid="1001" type="snmp" options="" />
  <ColumnOption idx="1" pid="1002" type="snmp" options="" />
  <ColumnOption idx="2" pid="1003" type="retrieved" options="" />
  <ColumnOption idx="3" pid="1004" type="snmp" options="" />
</ArrayOptions>
<Measurement>
  <Type options="tab=columns:1001|0-1002|1-1004|2,lines:20,width:80-150-120,sort:INT-STRING-STRING,filter:true">table</Type>
</Measurement>
```

> Schema for `ArrayOptions` / `ColumnOption` / `NamingFormat`: `dataminer-protocol-xml-reference/references/protocol-tables.md`.

---

## Table Relations and Foreign Keys

Relations define parent-child links between tables via `<Relation path="pid1;pid2">` with foreign key columns using `options=";foreignkey=parentPid"`. Required for tree controls, EPM topology, view tables, and alarm bubble-up.

**Quick constraints:**
- Do NOT place `foreignkey` on the **index column**.
- Do NOT target a **volatile** table with `foreignkey`.
- Remove dependent (child) rows **before** parent rows when cleaning up data.
- Use `numeric text` for FK key values — string-type keys may cause lookup problems.

> **Full reference**: `dataminer-xml-authoring/references/table-relations.md` — path semantics, relation ordering for EPM, `includeInAlarms` and `chain` options, FK column setup, tree control / EPM / view table integration, and a complete worked example.

### Conditions vs QAction

Prefer conditions on groups/timers over QAction if-checks for simple conditional execution — conditions execute in the SLProtocol thread without QAction overhead. Condition on group is preferable to condition on timer when the group alone needs to be skipped.
