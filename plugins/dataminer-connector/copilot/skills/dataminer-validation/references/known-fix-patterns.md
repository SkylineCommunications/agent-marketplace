# Known Fix Patterns

Deterministic fix patterns for common validator findings. These fixes MUST always be applied regardless of severity level — they have unambiguous solutions and must NOT be left unresolved or merely reported.

> **Parent skill**: `dataminer-validation/SKILL.md` — return there for CLI reference, severity levels, and suppression syntax.

---

## "Missing attribute 'Param@id'" (CRITICAL) — fix FIRST

When the validator reports **"Missing attribute 'Param@id'"**, a `<Param>` element in the document is missing its `id` attribute. The most common root cause is a **missing `<Param id="X">` opening tag** — parameter body content was generated without being wrapped in an opening tag, typically after a write param was closed. **Fix this BEFORE all other findings** — this structural defect corrupts the validator's internal model and produces cascading false errors (e.g. "Missing dynamic part(s) in NamingFormat" MAJOR and NullReferenceException CRITICAL in `CheckVolatileTables`).

**Fix**:

1. Open `protocol.xml` and search for parameter body content (`<Name>`, `<Description>`, `<Type>`) that appears directly between two `</Param>` closing tags with no `<Param id="X">` opening tag in between.
2. Determine the correct PID from the `<ColumnOption>` referencing the orphaned content — the PID in the accompanying "ColumnOption@pid references a non-existing column" MAJOR finding (if present) is usually the missing ID.
3. Insert `<Param id="X">` immediately before the orphaned `<Name>` element.

```xml
<!-- ❌ Wrong — content of Param 2004 orphaned after Param 2053 closing tag -->
    </Param>  <!-- closes 2053 write param -->
    <Name>DetectionStatus</Name>   <!-- ERROR: no <Param id="2004"> opening tag -->
    <Description>...</Description>

<!-- ✅ Correct — Param 2004 properly wrapped -->
    </Param>  <!-- closes 2053 write param -->
    <Param id="2004">
      <Name>DetectionStatus</Name>
      <Description>...</Description>
```

After inserting the missing opening tag, re-run the validator — the cascading NamingFormat MAJOR errors and NullReferenceException findings will likely disappear.

---

## "Missing dynamic part(s) in NamingFormat" (MAJOR)

When the validator reports **"Missing dynamic part(s) in 'ArrayOptions/NamingFormat' tag. Table PID 'X'"**, the most common cause is static text with no parameter ID references, or incorrect bracket syntax like `[1002]` instead of the correct separator-based format. **ALWAYS fix.**

> **NamingFormat uses separator-based format**: the first character is the separator (use `,`), followed by parameter IDs (bare numbers) and/or static text separated by that character. Example: `<NamingFormat>,1002</NamingFormat>`. **NEVER** use bracket syntax like `[1002]` — the validator does not recognise brackets as dynamic parts.

> **If `<NamingFormat>` already uses correct separator-based format and the error still appears**, this is a **cascading error** caused by a structural defect elsewhere in the same table's `<ArrayOptions>`. Check for these root causes **first** — fixing them will resolve the NamingFormat MAJOR without touching NamingFormat:
> 1. **`<ColumnOption type="write">` on any column** — `write` is not a valid `EnumColumnOptionType`; it corrupts the validator's column map and makes all PID references appear unresolvable. Remove the write-param entry from `<ColumnOption>` entirely (write params are standalone `<Param type="write">` elements, not ColumnOption entries).
> 2. **Missing `<Param id="X">` opening tag** — see "Missing attribute 'Param@id'" pattern above.
> 3. **Wrong `tab=columns` format in `<Measurement>`** — verify the format is `pid|displayIdx` separated by dashes (e.g. `1001|0-1002|1`), not `pid|ColumnName` separated by commas.
>
> Re-run the validator after fixing the root cause — the NamingFormat MAJOR will typically disappear.

Replace invalid content with separator-based format referencing an actual column PID in that table. For SNMP tables, all SNMP columns use `type="snmp"` (see "Missing displaykey column" pattern below for when a separate non-SNMP displaykey column is needed). For non-SNMP tables, the referenced column uses `type="displaykey"`:

```xml
<!-- ❌ Wrong — static text causes MAJOR error -->
<ArrayOptions index="0">
  <NamingFormat>Row</NamingFormat>
</ArrayOptions>

<!-- ❌ Wrong — bracket syntax is NOT valid NamingFormat; causes MAJOR error -->
<ArrayOptions index="0">
  <NamingFormat>[1002]</NamingFormat>
</ArrayOptions>

<!-- ✅ Correct (SNMP table) — separator-based format; SNMP columns stay type="snmp" -->
<ArrayOptions index="0">
  <NamingFormat>,1002</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="snmp" options="" />
  <ColumnOption idx="1" pid="1002" type="snmp" options="" />
</ArrayOptions>

<!-- ✅ Correct (non-SNMP table) — NamingFormat column has type="displaykey" -->
<ArrayOptions index="0">
  <NamingFormat>,1002</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="index" />
  <ColumnOption idx="1" pid="1002" type="displaykey" options="" />
</ArrayOptions>
```

Apply this fix to **every** table that reports this error. Do **not** suppress.

---

## "Invalid Interprete/Type for primary key column" (MAJOR)

When the validator reports **"Invalid value 'double' in tag 'Interprete/Type' for primary key column. Possible values 'string'. PK column PID 'X'"**, the index (PK) column of a table has `<Type>double</Type>` in its `<Interprete>` block. **ALWAYS fix** — the PK column's `<Interprete><Type>` MUST be `string`, even when the key value is a numeric SNMP index:

```xml
<!-- ❌ Wrong — double type on PK column triggers MAJOR on every table -->
<Interprete>
  <RawType>numeric text</RawType>
  <Type>double</Type>
  <LengthType>next param</LengthType>
</Interprete>

<!-- ✅ Correct — string type required for ALL primary key columns -->
<Interprete>
  <RawType>numeric text</RawType>
  <Type>string</Type>
  <LengthType>next param</LengthType>
</Interprete>
```

Apply this fix to every PK column (the `<ColumnOption idx="0">` column of each table) that reports this error. Do **not** suppress.

---

## "Missing tag 'LengthType' in Param 'X'" (MAJOR)

When the validator reports **"Missing tag 'LengthType' in Param 'X'"**, the `<Interprete>` block for that parameter is either missing entirely, or present but missing the `<LengthType>next param</LengthType>` child element. This is **always required** for every SNMP parameter — scalars, table columns, and write params. **Always fix — never suppress.**

**Fix**: Add or complete the `<Interprete>` block for every affected parameter:

- **String/OctetString parameters**: `<Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>`
- **Numeric parameters** (Integer, Gauge, Counter, Timeticks): `<Interprete><RawType>numeric text</RawType><Type>double</Type><LengthType>next param</LengthType></Interprete>`
- **Primary key columns**: `<Interprete><RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>`

```xml
<!-- ❌ Wrong — Interprete block missing LengthType -->
<Param id="3" type="read" trending="true">
  <Name>ifNumber</Name>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
  </Interprete>
</Param>

<!-- ✅ Correct — LengthType present -->
<Param id="3" type="read" trending="true">
  <Name>ifNumber</Name>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
</Param>
```

This finding fires in bulk for SNMP connectors — **before making any edits, collect the complete list of all PIDs reported with this finding from the validator JSON results. Fix EVERY PID in a single comprehensive pass — do NOT stop after fixing a subset.** Verify by counting: the number of `<Interprete>` elements in the fixed XML must equal the number of SNMP `<Param>` elements (reads + writes + table columns).

---

## "ArrayOptions naming option references non-existing Param" (MAJOR)

When the validator reports **"Option 'naming' in attribute 'ArrayOptions@options' references a non-existing 'Param' with ID '[X]'"**, the `options` attribute on `<ArrayOptions>` contains a `naming=` token that points to a column parameter that is not defined in the protocol. **NEVER put a `naming=` token in the `ArrayOptions options` attribute.** Use **only** the `<NamingFormat>` child element for display key configuration, with separator-based format (first char = separator, then bare PIDs):

```xml
<!-- ❌ Wrong — naming= in options attribute causes MAJOR error when PID doesn't exist -->
<ArrayOptions index="0" options=";naming=1002">
</ArrayOptions>

<!-- ✅ Correct — NamingFormat child element with separator-based format -->
<ArrayOptions index="0">
  <NamingFormat>,1002</NamingFormat>
</ArrayOptions>

<!-- ✅ Correct — multi-column display key -->
<ArrayOptions index="0">
  <NamingFormat>,1002,1003</NamingFormat>
</ArrayOptions>
```

**Fix**: Remove the `naming=` token from the `options` attribute (omit the attribute entirely if it becomes empty after removal). Add or correct a `<NamingFormat>` child element using separator-based format so every PID between separators matches an actual `<Param id="...">` defined in the connector.

---

## "Missing tag 'Alarm/Monitored'" (MAJOR)

When the validator reports **"Missing tag 'Alarm/Monitored' in Param 'X'"**, the `<Alarm>` block for that parameter is missing an explicit `<Monitored>` child. Decide whether the parameter is intended to support alarming:

```xml
<!-- ❌ Wrong — Alarm block missing Monitored; causes MAJOR -->
<Alarm>
  <WaH>90</WaH>
  <MaH>95</MaH>
</Alarm>

<!-- Correct when the parameter is intended to support alarming -->
<Alarm>
  <Monitored>true</Monitored>
  <WaH>90</WaH>
  <MaH>95</MaH>
</Alarm>
```

- If alarming is required, add `<Monitored>true</Monitored>` first and retain justified thresholds.
- If an Alarm block is intentionally retained but monitoring must be disabled, use `<Monitored>false</Monitored>`.
- If the parameter has no alarming requirement or defaults, remove the entire `<Alarm>` block.

Do not suppress the missing-child finding. `Monitored` controls whether DataMiner activates alarm monitoring, and both `true` and `false` are schema-valid.

---

## "Missing Display/Range" (code 2.11.1)

For any `number` parameter that has a determinable value range, add `<Range>` inside `<Display>` — **NEVER suppress 2.11.1 when the range can be determined**:

```xml
<!-- ✅ Correct — add Range when bounds are known -->
<Display>
  <RTDisplay>true</RTDisplay>
  <Range>
    <Low>0</Low>
    <High>100</High>
  </Range>
</Display>

<!-- ✅ Correct — suppress only when genuinely unbounded (counters, totals, timestamps) -->
<!-- SuppressValidator 2.11.1 Cumulative counter with no meaningful upper bound -->
<Display>
  <RTDisplay>true</RTDisplay>
</Display>
<!-- /SuppressValidator 2.11.1 -->
```

Common parameters that **require** a `<Range>` (do not suppress): utilisation/load percentages (0-100), signal levels, temperatures, interface speeds (0 - device max speed).

Common parameters where suppression **is** appropriate: packet counters, byte counters, uptime ticks, session IDs, sequence numbers.

For **table column params** (no `<Positions>`), add `<Range>` inside the existing `<Display>` block alongside `<RTDisplay>true</RTDisplay>`:

```xml
<!-- ✅ Correct — column param with Range, no Positions -->
<Display>
  <RTDisplay>true</RTDisplay>
  <Range>
    <Low>0</Low>
    <High>100</High>
  </Range>
</Display>
```

This finding fires in bulk for table connectors with many numeric columns — **before making any edits, collect the complete list of all PIDs reported with this finding from the validator JSON results. Fix EVERY PID in a single pass — do NOT stop after fixing a subset.**

---

## "Missing Units tag for number Param" (code 2.9.7, MINOR)

When the validator reports **"Missing 'Units' tag for 'number' Param with ID 'X'"**, a displayed `number` parameter has neither a `<Display><Units>` element nor a `2.9.7` suppression. **ALWAYS resolve — never leave unresolved.**

**Decision tree**:
- If a recognized physical or standard unit applies → add `<Display><Units>X</Units></Display>`.
- If no meaningful unit applies (counter, index, identifier, ratio, hop count, error code, etc.) → suppress 2.9.7 by wrapping `<Display>`.

For **table column params** (no `<Positions>`), add `<Units>` inside the existing `<Display>` block alongside `<RTDisplay>true</RTDisplay>`:

```xml
<!-- ✅ Correct — column param with Units, no Positions -->
<Display>
  <RTDisplay>true</RTDisplay>
  <Units>Octets</Units>
</Display>

<!-- ✅ Correct — column param, no meaningful unit, suppressed -->
<!-- SuppressValidator 2.9.7 Cumulative byte counter, no standard unit applicable -->
<Display>
  <RTDisplay>true</RTDisplay>
</Display>
<!-- /SuppressValidator 2.9.7 -->
```

**Valid recognized units** (partial list): `%`, `dBm`, `dB`, `bps`, `Kbps`, `Mbps`, `Gbps`, `Bps`, `KBps`, `MBps`, `Octets`, `Packets`, `ms`, `s`, `MHz`, `GHz`, `GB`, `MB`, `KB`, `W`, `deg C`, `V`, `A`.

**Common SNMP interface unit mapping** — apply to avoid companion "Unknown unit" and "Obsolete unit" findings:

| Column type | Correct unit | Common wrong values |
|-------------|-------------|---------------------|
| Byte/octet counters (ifInOctets, ifOutOctets, etc.) | `Octets` | ❌ `octets`, `bytes`, `byte` |
| Bit-rate or speed columns | `bps` / `Kbps` / `Mbps` (match scale) | ❌ `bit/s`, `bits/second` |
| Packet counters | `Packets` or suppress 2.9.7 | ❌ `packets` |
| Error/discard counters | suppress 2.9.7 | — |
| Interface speed (ifSpeed) | `bps` or suppress 2.9.7 | ❌ `bit/s` |

> **Note**: unit strings are **case-sensitive**. `Octets` ≠ `octets`. Using the wrong case is reported as **"Obsolete unit 'X'. New syntax 'Y'"** — fix by correcting the casing, not by suppressing.

This finding fires in bulk for table connectors with many numeric columns — **before making any edits, collect the complete list of all PIDs reported with this finding from the validator JSON results. Fix EVERY PID in a single pass — do NOT stop after fixing a subset.** Do **not** suppress when a recognized unit can be determined.

---

## "Invalid value 'tab' in Measurement/Type" (MAJOR / XSD ERROR)

When the validator reports **"Invalid value 'tab' in tag 'Measurement/Type'"** (or the XSD error `The value 'tab' is invalid according to its datatype`), the table array parameter's `<Measurement><Type>` element contains the literal text `tab` instead of the required value `table`. **ALWAYS fix** — `table` is the only valid text content for a table's `<Measurement><Type>`. The `tab=` prefix belongs exclusively in the `options` **attribute**:

```xml
<!-- ❌ Wrong — 'tab' is not a valid Measurement/Type value -->
<Measurement>
  <Type options="tab=columns:1001|0-1002|1,lines:25,width:100-150,sort:INT-STRING,filter:true">tab</Type>
</Measurement>

<!-- ✅ Correct — element value is 'table'; 'tab=' goes in the options attribute only -->
<Measurement>
  <Type options="tab=columns:1001|0-1002|1,lines:25,width:100-150,sort:INT-STRING,filter:true">table</Type>
</Measurement>
```

Apply this fix to every table param that reports this error. Do **not** suppress.

---

## "Unsupported `index` attribute value in `ArrayOptions`" (MAJOR / XSD ERROR)

When the validator (or XSD validation) reports **"The 'index' attribute is invalid — the value '0;1' is not a valid UInt32 value"**, the `<ArrayOptions index="...">` attribute contains a semicolon-separated list instead of a single integer. **ALWAYS fix** — the `index` attribute must be a single zero-based integer identifying the PK column. For a composite display key, keep `index="0"` and combine values in `<NamingFormat>`:

```xml
<!-- ❌ Wrong — semicolon-separated values are invalid; 'index' must be a single integer -->
<ArrayOptions index="0;1">
  ...
</ArrayOptions>

<!-- ✅ Correct — single integer index; composite display key goes in NamingFormat -->
<ArrayOptions index="0">
  <NamingFormat>,1002,1003</NamingFormat>
  ...
</ArrayOptions>
```

Apply this fix to every table reporting this XSD error. Do **not** suppress.

---

## "Volatile option suggested for table" (MINOR)

When the validator reports **"Suggested 'ArrayOptions/options' option 'volatile' in Table PID 'X'"**, the table is populated at runtime but is missing the `volatile` flag. The `volatile` option tells DataMiner not to persist table rows across element restarts.

**Before adding `volatile`, check the table's constraints** — `volatile` may only be used when **all** of the following hold:

- No alarm monitoring on any column
- No `save` option on any column
- No foreign keys in the table (no `foreignkey=` in any `ColumnOption`)
- Not used for DCF interfaces
- Not used for DVEs

**Decision tree**:

1. **All constraints satisfied** → add `options=";volatile"`. This is the common case for pure display/QAction tables.
2. **Any constraint is violated** (alarm monitoring, `save` columns, FK, DCF, DVE) → **suppress the finding** with a brief reason. Do NOT add `volatile` — it is incompatible with those features.
3. **Row churn > 7 changes/min or > 10 000 changes/day on the same element** → `volatile` is mandatory. If the table also requires alarming, persistence, foreign keys, DCF, or DVE behavior, stop and redesign or split the data model. Do not silently remove a functional requirement merely to apply the validator suggestion.

```xml
<!-- ✅ Case 1 — display-only table: add volatile -->
<ArrayOptions index="0" options=";volatile">
  <NamingFormat>,1002</NamingFormat>
</ArrayOptions>

<!-- ✅ Case 2 — table has alarm monitoring: suppress the finding -->
<!-- SuppressValidator 2.X.X Table uses alarm monitoring; volatile not applicable -->
<ArrayOptions index="0">
  <NamingFormat>,1002</NamingFormat>
</ArrayOptions>
<!-- /SuppressValidator 2.X.X -->
```

**NEVER** write `options=""` — an empty `options` attribute causes a separate validator WARNING. Either include `;volatile` or omit the `options` attribute entirely.

---

## "Ping group not a valid poll group" (MAJOR)

When the validator reports **"Ping group for 'snmpv2' connection is not a 'snmpv2' poll group. Group ID 'X'"**, the first `<Group>` element in the protocol's `<Groups>` section is not typed as a `poll` group. DataMiner always selects the **first defined group** as the ping group for SNMP connectors. **ALWAYS fix — do not suppress.**

```xml
<!-- ❌ Wrong — first group is not a poll group -->
<Group id="1">
  <Name>Initialise</Name>
  <Type>action</Type>
  <Content><Action>1</Action></Content>
</Group>

<!-- ✅ Correct — first group is a poll group polling at least one SNMP param -->
<Group id="1">
  <Name>General Parameters</Name>
  <Type>poll</Type>
  <Content>
    <Param>10</Param>
  </Content>
</Group>
```

**Fix**: Move or reorder groups so the first `<Group>` in the `<Groups>` section is a `<Type>poll</Type>` group. If no scalar poll group exists yet, create one polling the System Description OID or similar always-present parameter.

---

## "Missing displaykey column" (MINOR)

When the validator reports **"Missing column with ColumnOption@type='displaykey'. Table PID X"**, the table's `<ArrayOptions>` block has no `ColumnOption` with `type="displaykey"`. This finding applies to **non-SNMP tables** (HTTP, serial, custom) using `type="retrieved"` columns, or to SNMP tables where `<NamingFormat>` references **multiple PIDs** and needs a separate non-SNMP column to hold the concatenation. **Always fix — do not suppress.**

For **SNMP tables with single-PID `<NamingFormat>`**: all SNMP columns use `type="snmp"` and no displaykey column is needed — this finding should not fire.

For **SNMP tables with multi-PID `<NamingFormat>`** (e.g., `,1002,1003`): add a separate non-SNMP column (no `<SNMP><OID>` block, `<Interprete><Type>string</Type>`) with `type="displaykey"` to hold the concatenated display key.

For **non-SNMP tables**: the column whose PID is the primary (first) PID in `<NamingFormat>` must have `type="displaykey"`. All other non-index columns keep `type="retrieved"`.

```xml
<!-- ❌ Wrong — all columns typed 'retrieved', no displaykey (non-SNMP table) -->
<ArrayOptions index="0" options=";volatile">
  <NamingFormat>,1002</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="index" />
  <ColumnOption idx="1" pid="1002" type="retrieved" />
  <ColumnOption idx="2" pid="1003" type="retrieved" />
</ArrayOptions>

<!-- ✅ Correct for non-SNMP table — NamingFormat column has type="displaykey" -->
<ArrayOptions index="0" options=";volatile">
  <NamingFormat>,1002</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="index" />
  <ColumnOption idx="1" pid="1002" type="displaykey" />
  <ColumnOption idx="2" pid="1003" type="retrieved" />
</ArrayOptions>

<!-- ✅ Correct for SNMP table with multi-PID NamingFormat — separate non-SNMP displaykey column -->
<ArrayOptions index="0" options=";volatile">
  <NamingFormat>,1002,1003</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="snmp" options="" />
  <ColumnOption idx="1" pid="1004" type="displaykey" options="" />  <!-- non-SNMP: no <SNMP><OID> block -->
  <ColumnOption idx="2" pid="1002" type="snmp" options="" />
  <ColumnOption idx="3" pid="1003" type="snmp" options="" />
</ArrayOptions>
```

**Key rule**: `type="displaykey"` is **NEVER** valid on an SNMP-polled column (a column with `<SNMP><OID>`). SNMP columns always use `type="snmp"`.

---

## "RTDisplay(true) expected on column param" (MAJOR)

When the validator reports **"RTDisplay(true) expected on Param 'X'"** for a table column parameter, that column param is missing a `<Display><RTDisplay>true</RTDisplay></Display>` block. **ALWAYS fix** — every table column param that is referenced in the table's `tab=columns:...` display options MUST have `<Display><RTDisplay>true</RTDisplay></Display>`. This finding typically appears in bulk when a table was generated without the Display block on any of its columns — fix all affected column params at once. Do **not** suppress.

> **Key distinction**: column params need `<RTDisplay>true</RTDisplay>` but do **NOT** get a `<Positions>` block — `<Positions>` belongs exclusively on the table array param.

```xml
<!-- ❌ Wrong — column param missing Display/RTDisplay -->
<Param id="1002">
  <Name>InterfacesDescription</Name>
  <Description>Description (Interfaces)</Description>
  ...
  <Measurement><Type>string</Type></Measurement>
</Param>

<!-- ✅ Correct — column param with RTDisplay(true), no Positions -->
<Param id="1002">
  <Name>InterfacesDescription</Name>
  <Description>Description (Interfaces)</Description>
  ...
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement><Type>string</Type></Measurement>
</Param>
```

Apply this fix to **every** column param of every table that reports this error. Do **not** suppress.

---

## "Unexpected RTDisplay(true) on column param" (MINOR)

When the validator reports **"Unexpected RTDisplay(true) on Param 'X'"** for a table column parameter, that column param has a `<Display><RTDisplay>true</RTDisplay></Display>` block alongside a `<Positions>` block — column params must not be positioned on a page independently. **ALWAYS fix** — **NEVER** add a `<Positions>` block to individual table column params. Only the table array param (e.g. PID 1000) owns the `<Positions>` block. Remove `<Positions>` from the affected column param's `<Display>` section (keep `<RTDisplay>true</RTDisplay>`). This finding typically appears in bulk when a table has many columns — **before making any edits, collect the complete list of all PIDs reported with this finding from the validator JSON results. Fix EVERY PID on that list in a single comprehensive editing pass — do NOT stop after fixing a subset.** Any param reported with this finding is a table column param by definition — no further verification needed. Do **not** suppress.

> **Note**: column params that have `<Display><RTDisplay>true</RTDisplay></Display>` without `<Positions>` are correct — see "RTDisplay(true) expected on column param" above for the opposite finding.

---

## "Specified page 'X' does not exist" (MAJOR)

When the validator reports **"The specified page 'General' does not exist"** or **"The specified defaultPage 'General' does not exist"**, the `pageOrder` or `defaultPage` attribute references a page that no parameter is positioned on. **ALWAYS fix** — a page only exists when at least one parameter has `<Page>General</Page>` inside its `<Positions>` block. Listing it in `pageOrder`/`defaultPage` alone is NOT sufficient.

**Fix**: Add one or more scalar parameters (e.g. System Description, Device Name, Firmware Version) with `<Page>General</Page>` in their `<Positions>`. Do **not** remove `"General"` from `pageOrder` or `defaultPage`.

```xml
<!-- ✅ Add at minimum a System Description param positioned on the General page -->
<Param id="10" trending="false">
  <Name>SystemDescription</Name>
  <Description>System Description</Description>
  <Information><Subtext>Textual description of the device.</Subtext></Information>
  <Type>read</Type>
  <Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>
  <SNMP><Enabled>true</Enabled><OID type="complete">1.3.6.1.2.1.1.1.0</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions><Position><Page>General</Page><Row>0</Row><Column>0</Column></Position></Positions>
  </Display>
  <Measurement><Type>string</Type></Measurement>
</Param>
```

This simultaneously resolves the Completeness WARN ("No 'General' page found") and both Validator MAJOR findings.

---

## "Unrecommended index value in ArrayOptions" (MINOR)

When the validator reports **"Unrecommended value '1' in attribute 'index'. Recommended values '0'. Table ID 'X'"**, the `<ArrayOptions index="1">` attribute is not set to `0`. **ALWAYS fix** — the `index` attribute MUST be `0`, meaning the first column (`idx="0"`) is the primary key column. A non-zero index means the PK is not the first column, which violates the recommended table structure.

**Fix**: Set `index="0"` and ensure the `<ColumnOption idx="0">` entry is the primary key / index column. Reorder `<ColumnOption>` entries (and corresponding `<Param>` definitions) if needed so the PK column is at `idx="0"`:

```xml
<!-- ❌ Wrong — PK is at idx=1, index="1" -->
<ArrayOptions index="1">
  <NamingFormat>,2002</NamingFormat>
  <ColumnOption idx="0" pid="2001" type="retrieved" options="" />
  <ColumnOption idx="1" pid="2002" type="index" options="" />
</ArrayOptions>

<!-- ✅ Correct — PK is at idx=0, index="0" -->
<ArrayOptions index="0">
  <NamingFormat>,2002</NamingFormat>
  <ColumnOption idx="0" pid="2001" type="index" options="" />
  <ColumnOption idx="1" pid="2002" type="displaykey" options="" />
</ArrayOptions>
```

Apply this fix to every table reporting this finding. Do **not** suppress.

---

## "Missing WebInterface page" — always fix, never suppress

When the validator reports "Missing WebInterface page", add the `Webinterface#http://[Polling Ip]/` entry to the `pageOrder` attribute of the `<Display>` element. **NEVER** add a `<WebInterface>` child element to `<Protocol>` — that tag is not a valid Protocol child and will cause an XSD error.

```xml
<!-- ✅ Correct — add Webinterface# entry to pageOrder, separated by a separator -->
<Display defaultPage="General"
         pageOrder="General;-----;Webinterface#http://[Polling Ip]/"
         wideColumnPages="" />

<!-- ❌ Wrong — <WebInterface> is NOT a valid Protocol child element; causes XSD error -->
<Protocol>
  <WebInterface>...</WebInterface>
</Protocol>
```

If the connector already has an invalid `<WebInterface>` element, remove it entirely and add the `Webinterface#...` entry to `pageOrder` instead. This warning is **never appropriate to suppress** — every connector with a physical or network connection must expose a web interface page via `pageOrder`. Only omit for `virtual` or `service` connection types.

---

## "Discreet display values must use title casing" — always fix

When the validator reports **"'Discreet/Display' values do not follow title casing rules"**, the `<Display>` text inside a `<Discreet>` entry is not title-cased. **Always fix — do not suppress.** Apply the same title case rules as parameter descriptions: capitalize every word except **a/an/and/as/at/but/by/for/in/nor/of/on/or/so/the/to/up/yet** when mid-value; always capitalize the first word.

**CamelCase/PascalCase MIB enum names** are the most common source of this finding. SNMP MIB definitions use names like `deliveringPower`, `VoltsAC`, `OtherFault`, `Class0` — these must be **split into separate words** (on uppercase-after-lowercase, acronym boundaries, and letter-digit transitions) and then title-cased. **NEVER** use raw MIB enum names directly as `<Display>` values.

```xml
<!-- ❌ Wrong — lowercase or sentence-case discreet values -->
<Discreet><Display>enabled</Display><Value>1</Value></Discreet>
<Discreet><Display>not available</Display><Value>2</Value></Discreet>
<Discreet><Display>out of service</Display><Value>3</Value></Discreet>

<!-- ✅ Correct — title-cased discreet values -->
<Discreet><Display>Enabled</Display><Value>1</Value></Discreet>
<Discreet><Display>Not Available</Display><Value>2</Value></Discreet>
<Discreet><Display>Out of Service</Display><Value>3</Value></Discreet>
```

```xml
<!-- ❌ Wrong — raw CamelCase MIB enum names used verbatim -->
<Discreet><Display>DeliveringPower</Display><Value>3</Value></Discreet>
<Discreet><Display>OtherFault</Display><Value>6</Value></Discreet>
<Discreet><Display>VoltsAC</Display><Value>3</Value></Discreet>
<Discreet><Display>VoltsDC</Display><Value>4</Value></Discreet>
<Discreet><Display>PercentRH</Display><Value>9</Value></Discreet>
<Discreet><Display>TruthValue</Display><Value>12</Value></Discreet>
<Discreet><Display>Class0</Display><Value>1</Value></Discreet>

<!-- ✅ Correct — split into words and title-cased -->
<Discreet><Display>Delivering Power</Display><Value>3</Value></Discreet>
<Discreet><Display>Other Fault</Display><Value>6</Value></Discreet>
<Discreet><Display>Volts AC</Display><Value>3</Value></Discreet>
<Discreet><Display>Volts DC</Display><Value>4</Value></Discreet>
<Discreet><Display>Percent RH</Display><Value>9</Value></Discreet>
<Discreet><Display>Truth Value</Display><Value>12</Value></Discreet>
<Discreet><Display>Class 0</Display><Value>1</Value></Discreet>
```

---

## "Togglebutton recommended for two-state parameters" — always fix

When the validator reports **"Measurement/Type 'togglebutton' is recommended for Param with ID 'X'"**, the parameter has exactly two discreet values (e.g. Enabled/Disabled, On/Off) and should use `<Type>togglebutton</Type>` instead of a plain discreet dropdown. **Always apply this fix — do not suppress:**

```xml
<!-- ❌ Wrong — regular dropdown for a two-state parameter -->
<Measurement>
  <Type>discreet</Type>
  <Discreets>
    <Discreet><Display>Disabled</Display><Value>0</Value></Discreet>
    <Discreet><Display>Enabled</Display><Value>1</Value></Discreet>
  </Discreets>
</Measurement>

<!-- ✅ Correct — togglebutton for exactly two states -->
<Measurement>
  <Type>togglebutton</Type>
  <Discreets>
    <Discreet><Display>Disabled</Display><Value>0</Value></Discreet>
    <Discreet><Display>Enabled</Display><Value>1</Value></Discreet>
  </Discreets>
</Measurement>
```

---

## "NT_SNMP_SET not compatible with DELT" (MAJOR)

When the validator reports **"Invocation of method 'SLProtocol.NotifyProtocol(292/\*NT_SNMP_SET\*/, ...)' is not compatible with 'DELT'. QAction ID 'X'"**, a QAction is using `NotifyProtocol(292)` to perform an SNMP SET programmatically. This call is incompatible with DELT (Dynamic Element Linking Technology) and is flagged MAJOR on every QAction that contains it. **Always fix — do not suppress.**

The root cause is typically that the QAction writer generated explicit NT_SNMP_SET code for table cell writes when the declarative **`snmpSetAndGet="true"` attribute** approach should be used instead. For the vast majority of SNMP table cell writes, no QAction is needed at all.

**Fix**: Remove the QAction that calls `NotifyProtocol(292, …)` and replace the write parameter with the `snmpSetAndGet="true"` attribute:

```xml
<!-- ❌ Wrong — using NT_SNMP_SET in a QAction triggers DELT MAJOR -->
<!--   QAction 201: protocol.NotifyProtocol(292, ...); -->

<!-- ✅ Correct — snmpSetAndGet="true" on the write param, no QAction needed -->
<Param id="1053" snmpSetAndGet="true">
  <Name>InterfacesAdminStatus</Name>
  <Description>Admin Status (Interfaces)</Description>
  <Information>
    <Subtext>Sets the administrative status of the interface via SNMP SET.</Subtext>
  </Information>
  <Type>write</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.2.2.1.7</OID>
  </SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions>
      <Position>
        <Page>Interfaces</Page>
        <Row>1</Row>
        <Column>1</Column>
      </Position>
    </Positions>
  </Display>
  <Measurement>
    <Type>number</Type>
  </Measurement>
</Param>
```

The table array param must also carry the `instance` option on its OID so DataMiner resolves the row key automatically for the SET:

```xml
<SNMP>
  <Enabled>true</Enabled>
  <OID type="complete" options="instance;multipleGetNext">1.3.6.1.2.1.2.2</OID>
</SNMP>
```

**Decision rule**: Only use `NT_SNMP_SET` (Approach 4 from `dataminer-xml-authoring/references/snmp-writes-table-cell.md`) when you need dynamic OID construction, conditional multi-OID sets, or other logic that cannot be expressed declaratively. For all other table cell writes, use `snmpSetAndGet="true"`.

---

## "Unrecommended `Alarm/Info` tag" — always remove

When the validator reports **"Unrecommended tag 'Alarm/Info'"**, the parameter contains an `<Info>` child element inside `<Alarm>`. This tag has no effect in modern DataMiner versions. **Always remove it — do not suppress:**

```xml
<!-- ❌ Wrong — <Info> is an unrecommended Alarm child -->
<Alarm>
  <Monitored>true</Monitored>
  <Info>...</Info>
</Alarm>

<!-- ✅ Correct — remove the Info tag -->
<Alarm>
  <Monitored>true</Monitored>
</Alarm>
```

---

## "Missing 'Discreet' tag(s) in 'Measurement/Discreets' tag" / "Missing 'Measurement/Discreets' tag for 'discreet' Param" (MAJOR)

When the validator reports **"Missing 'Discreet' tag(s) in 'Measurement/Discreets' tag. Param ID 'X'"** OR **"Missing 'Measurement/Discreets' tag for 'discreet' Param with ID 'X'"**, a `<Param>` has `<Measurement><Type>discreet</Type>` with either an absent or empty `<Discreets>` block. **ALWAYS fix — do not suppress.** These two validator messages are distinct but share the same class of fix.

**Root cause A (most common — fires in bulk on table array params)**: The `<Param type="array">` (table array param) has `<Measurement><Type>discreet</Type>…</Measurement>` instead of `<Measurement><Type options="tab=columns:...">table</Type></Measurement>`. The agent confused the table container param with an enum column param.

**Root cause B**: The table array param has correct `<Type>table</Type>` but also contains a spurious empty `<Discreets/>` child, which the validator treats as a `discreet` measurement with zero entries.

**Root cause C (column or scalar param — triggers "Missing 'Measurement/Discreets' tag for 'discreet' Param")**: A column or scalar param has `<Measurement><Type>discreet</Type></Measurement>` with **no `<Discreets>` element at all** (not even an empty `<Discreets/>`). Fix: add a fully populated `<Discreets>` block with all enum values from the MIB/spec.

```xml
<!-- ❌ Wrong A — 'discreet' type on a table array param causes MAJOR -->
<Param id="1000" type="array" trending="false">
  ...
  <Measurement>
    <Type>discreet</Type>
    <Discreets/>
  </Measurement>
</Param>

<!-- ❌ Wrong B — spurious <Discreets/> inside a table Measurement causes MAJOR -->
<Param id="1000" type="array" trending="false">
  ...
  <Measurement>
    <Type options="tab=columns:1001|0-1002|1,lines:25">table</Type>
    <Discreets/>
  </Measurement>
</Param>

<!-- ✅ Correct — table array param uses 'table' type with no <Discreets> child -->
<Param id="1000" type="array" trending="false">
  ...
  <Measurement>
    <Type options="tab=columns:1001|0-1002|1,lines:25,width:100-200,sort:INT-STRING,filter:true">table</Type>
  </Measurement>
</Param>
```

**If the finding is on a column or scalar param** (not the table array param), there are two sub-cases:

*Sub-case C1*: The param has `<Measurement><Type>discreet</Type><Discreets/></Measurement>` — `<Discreets>` is present but empty. Fix: populate all `<Discreet>` entries from the MIB/spec.

*Sub-case C2 (triggers "Missing 'Measurement/Discreets' tag for 'discreet' Param")*: The param has `<Measurement><Type>discreet</Type></Measurement>` — **no `<Discreets>` element at all**. Fix: add a fully populated `<Discreets>` block.

```xml
<!-- ❌ Wrong C1 — discreet column with empty Discreets block -->
<Measurement>
  <Type>discreet</Type>
  <Discreets/>
</Measurement>

<!-- ❌ Wrong C2 — discreet column with Discreets block entirely absent -->
<Measurement>
  <Type>discreet</Type>
</Measurement>

<!-- ✅ Correct — all enum values populated with title-cased Display labels -->
<Measurement>
  <Type>discreet</Type>
  <Discreets>
    <Discreet><Display>Other</Display><Value>1</Value></Discreet>
    <Discreet><Display>Ethernet</Display><Value>6</Value></Discreet>
    <Discreet><Display>Loopback</Display><Value>24</Value></Discreet>
    <Discreet><Display>Virtual</Display><Value>53</Value></Discreet>
  </Discreets>
</Measurement>
```

This finding fires once per affected param. When it fires on all table array params (4× in a 4-table connector), fix the `<Measurement>` block of each table array param.

---

## "'foreignId' attribute is not declared" (XSD ERROR)

When XSD validation reports **"The 'foreignId' attribute is not declared"** on a `<ColumnOption>` or `<Param>` element, the generated XML contains a `foreignId` attribute that does not exist in the DataMiner protocol XSD schema. **ALWAYS fix — remove the attribute.** This error fires once per element that carries it, typically once per table when a connector was generated with foreign key annotations.

The correct way to express a foreign key relationship between two tables is through the `type="foreignkey"` value and the `options=";foreignkey=parentTablePid"` attribute on a non-index `<ColumnOption>`:

```xml
<!-- ❌ Wrong — 'foreignId' is not a valid XSD attribute; causes XSD ERROR -->
<ColumnOption idx="1" pid="1101" type="snmp" foreignId="1001" />

<!-- ✅ Correct — foreign key expressed via type and options -->
<ColumnOption idx="1" pid="1101" type="foreignkey" options=";foreignkey=1000" />
```

If no actual foreign key relationship is intended between the tables, remove the `foreignId` attribute and keep the `<ColumnOption>` with the appropriate type (`snmp`, `retrieved`, `displaykey`, etc.).

Do **not** suppress — the attribute is structurally invalid and must be removed.

---

## "ColumnOption options are separated by first character 'i'" (MINOR 2922) / "Unknown or malformed ColumnOption option 'nstance'" (MINOR 2901)

When the validator reports **"ColumnOption options are separated by first character 'i'. Using semicolon ';' is recommended"** paired with **"Unknown or malformed ColumnOption option 'nstance'"**, a `<ColumnOption>` element has `options="instance"`. The DataMiner options parser treats the **first character** of the `options` attribute as the separator — so `options="instance"` is parsed as separator=`i`, option=`nstance`, which is meaningless. **ALWAYS fix — do not suppress.**

The `instance` option belongs **exclusively** on the table's `<SNMP><OID>` element, never on individual `<ColumnOption>` elements.

**Fix**: Remove `options="instance"` from every affected `<ColumnOption>` (set to `options=""` or remove the attribute). Ensure the table's `<OID>` element carries the `instance` option combined with a retrieval method.

```xml
<!-- ❌ Wrong — instance on ColumnOption causes 2922 + 2901 on every affected column -->
<ArrayOptions index="0">
  <NamingFormat>,1002</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="snmp" options="instance" />
  <ColumnOption idx="1" pid="1002" type="snmp" options="instance" />
  <ColumnOption idx="2" pid="1003" type="snmp" options="" />
</ArrayOptions>
<SNMP>
  <Enabled>true</Enabled>
  <OID type="complete" options=";multipleGetBulk">1.3.6.1.2.1.105.1.1</OID>
</SNMP>

<!-- ✅ Correct — instance on the table OID only; ColumnOption options are empty -->
<ArrayOptions index="0">
  <NamingFormat>,1002</NamingFormat>
  <ColumnOption idx="0" pid="1001" type="snmp" options="" />
  <ColumnOption idx="1" pid="1002" type="snmp" options="" />
  <ColumnOption idx="2" pid="1003" type="snmp" options="" />
</ArrayOptions>
<SNMP>
  <Enabled>true</Enabled>
  <OID type="complete" options="instance;multipleGetBulk">1.3.6.1.2.1.105.1.1</OID>
</SNMP>
```

This error typically appears on every `<ColumnOption>` that carries `options="instance"` — fix all of them in the table.

---

## "Unsupported Param reference in SNMP/OID@id" / "Invalid combination of OID value and SNMP/OID@id" (2.48.4 MAJOR + 2.47.2 MINOR)

When the validator reports **"Unsupported Param 'N' reference in attribute 'SNMP/OID@id' in Param 'X'"** (MAJOR, 2.48.4) — often paired with **"Invalid combination of OID value '...' and SNMP/OID@id value 'N' in Param 'X'"** (MINOR, 2.47.2) — a table column parameter has an `id=` attribute on its `<SNMP><OID>` element. **ALWAYS fix — do not suppress.** These findings fire for every affected column and accumulate across tables.

**Root cause — two common variants**:

**(A) Copying the table array param's full SNMP block onto columns** (most common in agent-generated connectors): The column gets `<SNMP><Enabled>true</Enabled><OID type="complete" id="tableParamId">column.oid</OID></SNMP>` instead of the correct minimal column format. For example, table param 1000 has columns 1001–1008, and every column's `<SNMP>` block is written as `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">…</OID></SNMP>` ❌ — referencing the first column's PID as the `id` attribute.

**(B) Setting `id=` to the last OID segment** (the MIB column index): column OID `1.3.6.1.2.1.2.2.1.3` → `id="3"` ❌, column OID `1.3.6.1.2.1.2.2.1.8` → `id="8"` ❌.

**Fix**: Replace the entire column `<SNMP>` block with the **minimal column format** — remove `<Enabled>`, remove `type=`, remove `id=`, leave only the bare OID text:

```xml
<!-- ❌ Wrong variant A — full table SNMP block copied onto columns -->
<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">1.3.6.1.2.1.2.2.1.1</OID></SNMP>
<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">1.3.6.1.2.1.2.2.1.2</OID></SNMP>
<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">1.3.6.1.2.1.2.2.1.8</OID></SNMP>

<!-- ❌ Wrong variant B — id= set to MIB column index -->
<SNMP><OID id="1">1.3.6.1.2.1.2.2.1.1</OID></SNMP>
<SNMP><OID id="2">1.3.6.1.2.1.2.2.1.2</OID></SNMP>
<SNMP><OID id="8">1.3.6.1.2.1.2.2.1.8</OID></SNMP>

<!-- ✅ Correct — minimal column format: bare OID, no Enabled, no type, no id -->
<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>
<SNMP><OID>1.3.6.1.2.1.2.2.1.2</OID></SNMP>
<SNMP><OID>1.3.6.1.2.1.2.2.1.8</OID></SNMP>
```

**Remember**: Table array param and column param `<SNMP>` blocks are **structurally different**. Table: `<SNMP><Enabled>true</Enabled><OID type="complete">table.oid</OID></SNMP>`. Column: `<SNMP><OID>column.oid</OID></SNMP>` — NO `<Enabled>`, NO `type=`, NO `id=`. NEVER copy the table format onto columns.

This finding fires in bulk — **before making any edits, collect the complete list of all PIDs reported with this finding from the validator JSON results. Fix EVERY PID in a single pass — do NOT stop after fixing a subset.** Each fix is replacing the full `<SNMP>` block with the minimal column format.
