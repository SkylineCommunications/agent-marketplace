# Table Authoring Gates — Full Reference

Full TABLE GENERATION GATE rule details, Table Column Naming Convention, Table Column Pre-Completion Checklist, Table Measurement Section, Table Rules, Data Handling Patterns, `instance` Option, and Multi-PID NamingFormat patterns.

## TABLE GENERATION GATE — Detailed Rules

Apply to **EVERY table, without exception**. Full details below; see `SKILL.md` for the compact rule list to check at authoring time.

### Rule 0 — Table `<Name>` Must NOT End with "Table"

**ALWAYS** derive the DataMiner `<Name>` from the SNMP MIB object name by stripping the `Table` suffix and camelCasing the remainder. The NamingConventions check uses `columnName.StartsWith(tableName)` — a wrong table name fails **every single column** in that table at once.

❌ `interfaceTable` (English + "Table" suffix) → ✅ `if`
❌ `lLDPRemoteTable` → ✅ `lldpRem`
❌ `poEPortTable` → ✅ `pethPsePort`
❌ `entitySensorTable` → ✅ `entPhySensor`

**ALSO: NEVER use the verbatim MIB table name** — ❌ `<Name>ifTable</Name>` (raw MIB name: "Table" suffix NOT stripped) → ✅ `<Name>if</Name>`.

See `dataminer-xml-authoring/references/table-naming.md` for the full MIB-to-DataMiner translation table.

### Rule 1 — `<NamingFormat>` Uses Separator-Based Format

**NEVER** write only static text or bracket syntax. The correct format uses the **first character as the separator** (`,`), followed by bare column PIDs.

❌ `<NamingFormat>Interface</NamingFormat>` (static) → ❌ `<NamingFormat>[1002]</NamingFormat>` (brackets — **not valid**) → ✅ `<NamingFormat>,1002</NamingFormat>` (separator-based)

### Rule 2 — PK Column `<Interprete><Type>` MUST Be `string`

The column at `<ColumnOption idx="0">` is the primary key. **ALWAYS** use `<Type>string</Type>` in its `<Interprete>` block, **even when the SNMP index is a numeric value**.

❌ `<Type>double</Type>` on PK → ✅ `<RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType>`

### Rule 2b — Display Key Column `<Interprete><Type>` MUST Also Be `string`

When a table has a non-SNMP `<ColumnOption type="displaykey">` column, that column **ALWAYS** uses `<Type>string</Type>` in its `<Interprete>` block.

❌ `<Type>double</Type>` on display key column → ✅ text: `<RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType>`; numeric-valued: `<RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType>`

### Rule 3 — Column Params MUST NOT Have `<Positions>`

**NEVER** add a `<Positions>` block inside a column param's `<Display>`. `<Positions>` belongs only on the table array param.

❌ `<Display><RTDisplay>true</RTDisplay><Positions>…</Positions></Display>` on a column → ✅ `<Display><RTDisplay>true</RTDisplay></Display>` (no Positions)

**After writing EACH column param, immediately verify it has no `<Positions>` before writing the next.**

⚠️ **PER-TABLE SELF-CHECK**: After finishing ALL column params for a table, count the `<Positions>` elements. Expected: exactly **1** (only the table array param owns `<Positions>`). If count > 1, remove excess `<Positions>` blocks from column params.

### Rule 4 — SNMP Columns MUST Have `type="snmp"`

Every `<ColumnOption>` whose corresponding `<Param>` has an `<SNMP><OID>` block **MUST** use `type="snmp"`. **NEVER** put `type="displaykey"` on an SNMP-polled column.

`displaykey` is reserved for **non-SNMP columns** (no `<SNMP><OID>` block) that auto-hold the NamingFormat concatenation. When `<NamingFormat>` references a **single PID**, no separate displaykey column is needed. When `<NamingFormat>` references **multiple PIDs**, add a **separate non-SNMP column** with `type="displaykey"`.

❌ `type="displaykey"` on a column that has `<SNMP><OID>1.3.6…</OID></SNMP>` → ✅ `type="snmp"` on that SNMP column

### Rule 5 — `<ArrayOptions index="0">` ALWAYS

The `index` attribute identifies the primary key column by its 0-based `idx` value. Since the PK **must always be the first column** (`idx="0"`), `index` **MUST always be `"0"`**.

❌ `<ArrayOptions index="1">`, `<ArrayOptions index="2">` → ✅ `<ArrayOptions index="0">`

### Rule 6 — Table and Column `<SNMP>` Blocks Use DIFFERENT Formats

For SNMP connectors, the table array param **MUST** have `<SNMP><Enabled>true</Enabled><OID type="complete">table-oid</OID></SNMP>` and **every** column param **MUST** have `<SNMP><OID>column-oid</OID></SNMP>`.

**NEVER copy the table's SNMP block onto a column** — column `<SNMP>` blocks use a **minimal format**: NO `<Enabled>`, NO `type=` attribute on `<OID>`, NO `id=` attribute on `<OID>`.

❌ column: `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">col.oid</OID></SNMP>` → ✅ column: `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>`

### Rule 7 — Table Array Param `<Display>` MUST Have BOTH `<RTDisplay>` AND `<Positions>`

**NEVER** write `<Display><RTDisplay>true</RTDisplay></Display>` on a table array param without a `<Positions>` block. RTDisplay alone causes MINOR "Unexpected RTDisplay(true)" on the table AND **cascades to every column param**.

❌ `<Display><RTDisplay>true</RTDisplay></Display>` on table array param → ✅ `<Display><RTDisplay>true</RTDisplay><Positions><Position><Page>Interfaces</Page><Row>0</Row><Column>0</Column></Position></Positions></Display>`

### Rule 8 — NEVER `displayColumn` — ALWAYS `<NamingFormat>`

**NEVER** write `displayColumn="N"` on `<ArrayOptions>`. Use `<NamingFormat>` instead.

❌ `<ArrayOptions index="0" displayColumn="1">` → ✅ `<ArrayOptions index="0"><NamingFormat>,1002</NamingFormat>`

### Rule 9 — Make a Compatible `volatile` Decision

Use `volatile` **only when ALL of the following hold**: (a) no alarm monitoring on any column, (b) no `save` option on any column, (c) no foreign keys in the table, (d) not used for DCF, and (e) not used for DVEs.

If expected row additions/deletions exceed 7 changes/minute or 10 000 changes/day on the same element, the DataMiner documentation requires `volatile`. When a high-churn table also needs an incompatible behavior, do not silently choose one requirement or emit both. Redesign the data model, for example by separating a volatile raw table from a lower-churn monitored/persisted table, and confirm the tradeoff with the user.

**NEVER** write `options=""` (empty attribute causes a validator warning). Omit the attribute when no options apply.

❌ `<ArrayOptions index="0" options="">` → ✅ `<ArrayOptions index="0" options=";volatile">` on a compatible display-only/QAction-only table, or `<ArrayOptions index="0">` on a non-volatile table.

### Rule 10 — Table Array Param `<Measurement>` MUST Use `table` Type

**ALWAYS** write `<Measurement><Type options="tab=columns:...">table</Type></Measurement>` on a `<Param type="array">`.

**NEVER** set `<Type>discreet</Type>` on a table array param. **NEVER** add an empty `<Discreets />` inside a `<Type>table</Type>` measurement.

❌ `<Measurement><Type>discreet</Type></Measurement>` on `<Param type="array">` → ❌ `<Measurement><Type>table</Type><Discreets /></Measurement>` → ✅ `<Measurement><Type options="tab=columns:1001|0-1002|1,lines:20,...">table</Type></Measurement>`

### Rule 11 — `<NamingFormat>` MUST Reference User-Meaningful Columns

When the primary key contains values not meaningful to an operator (sequential integers, GUIDs, SNMP numeric indices), `<NamingFormat>` MUST reference a user-meaningful column.

**Multi-PID display key rule**: When `<NamingFormat>` references **more than one PID** (e.g., `,1002,1003`), a dedicated `<ColumnOption type="displaykey">` column MUST be added as the **last** column. Single-PID references need no separate displaykey column.

❌ Table with PK = auto-increment ID and no meaningful `<NamingFormat>` → ✅ `<NamingFormat>,1002</NamingFormat>` pointing to a name column

### Rule 12 — Multiple Tables on the Same Page MUST Be Stacked Vertically

Rows are per-object: 1st table → `<Row>0</Row>`, 2nd → `<Row>1</Row>`, 3rd → `<Row>2</Row>`, etc. **Pre-plan all row/column assignments for a page before writing any XML.**

❌ Two tables both at `<Row>0</Row><Column>0</Column>` on the same page → silently overlap. ✅ Table A at `<Row>0</Row>`, Table B at `<Row>1</Row>`.

---

## Table Column Naming Convention

- **Table `<Name>`**: camelCase **with NO whitespace**, matching the prefix used in column names (e.g., `interfaces`, `runningProcesses`). Prefer a concise content name without a redundant `Table` suffix.

  **SNMP MIB tables**: deriving the name from the OBJECT-TYPE identifier by stripping a trailing `Table` is recommended. A descriptive camelCase name is also valid when it is clearer.

  Column names **MUST** use the exact same prefix as the table `<Name>` value — **do NOT change casing when deriving the column prefix** (table `<Name>if</Name>` → columns `ifIndex`, `ifDescr`, **NOT** `ifTableIndex`, `ifTableDescr`).

- **Table `<Description>`**: human-readable Title Case (for example, `Interfaces` or `Running Processes`).

- **Column `<Name>`**: camelCase format `tableNameColumnName` — concatenate the table name with the column name (e.g., table "interfaces" + "index" → `interfacesIndex`, "description" → `interfacesDescription`). No parenthetical suffix in the Name.

> **⚠ PER-COLUMN SELF-CHECK — apply immediately after writing each column `<Name>`:**
> 1. First character is **lowercase** — any uppercase start is a NamingConventions WARN or FAIL.
> 2. The leading prefix **exactly matches** the table `<Name>` value **character-for-character including casing** — `InterfacesName` is wrong even though the table is named `interfaces`; `interfacesName` is correct.
> 3. Re-check the table and its referenced column params only; unrelated `<Name>` elements elsewhere in the protocol are out of scope.

### Before/After: PascalCase Prefix Trap (NamingConventions WARN/FAIL)

The most common column naming mistake: the table `<Name>` is correctly camelCase but authors capitalise its first letter when using it as a column prefix.

```xml
<!-- ❌ WRONG — table name is "interfaces" but column prefix is "Interfaces" (PascalCase) -->
<Param id="1000" type="array"><Name>interfaces</Name></Param>
<Param id="1001"><Name>InterfacesIndex</Name></Param>
<Param id="1002"><Name>InterfacesName</Name></Param>
<Param id="1003"><Name>InterfacesIpAddress</Name></Param>
<Param id="1004"><Name>InterfacesLinkState</Name></Param>
<Param id="1005"><Name>InterfacesRxPackets</Name></Param>
<Param id="1006"><Name>InterfacesTxPackets</Name></Param>

<!-- ✅ CORRECT — prefix matches table name exactly: "interfaces" (lowercase i) -->
<Param id="1000" type="array"><Name>interfaces</Name></Param>
<Param id="1001"><Name>interfacesIndex</Name></Param>
<Param id="1002"><Name>interfacesName</Name></Param>
<Param id="1003"><Name>interfacesIpAddress</Name></Param>
<Param id="1004"><Name>interfacesLinkState</Name></Param>
<Param id="1005"><Name>interfacesRxPackets</Name></Param>
<Param id="1006"><Name>interfacesTxPackets</Name></Param>
```

| Wrong ❌ | Correct ✅ | Notes |
|---|---|---|
| `InterfacesName` | `interfacesName` | Prefix must start lowercase |
| `InterfacesIpAddress` | `interfacesIpAddress` | Acronym prefix stays lowercase |
| `InterfacesLinkState` | `interfacesLinkState` | All words after prefix remain TitleCased |
| `InterfacesRxPackets` | `interfacesRxPackets` | Abbreviations follow camelCase |
| `InterfacesTxPackets` | `interfacesTxPackets` | Abbreviations follow camelCase |
| `DeviceKey` | `deviceKey` | Single-word prefix: apply same rule |
| `DeviceName` | `deviceName` | Single-word prefix: apply same rule |
| `DeviceStatus` | `deviceStatus` | Single-word prefix: apply same rule |
| `DeviceSpeed` | `deviceSpeed` | Single-word prefix: apply same rule |

> **Rule**: The column prefix is derived by copying the table `<Name>` **verbatim** — do NOT apply any additional capitalisation. If the table is `interfaces`, the prefix is `interfaces`. If the table is `pethPsePort`, the prefix is `pethPsePort`. If the table is `bucInfo`, the prefix is `bucInfo` (lowercase `b`) — not `BucInfo`. Never "title-case" the prefix. **Derive the table `<Name>` from the OBJECT-TYPE descriptor (e.g. `tx21BucInfoTable`), not from the uppercase SEQUENCE type name (`Tx21BucInfoEntry`).**

### Before/After: Multi-Word Compound Prefix Trap (NamingConventions WARN/FAIL)

Multi-word camelCase table names (e.g. `bucInfo`, `pethPsePort`) are an especially subtle trap — each word looks correctly cased individually, so the PascalCase mistake (`BucInfo` instead of `bucInfo`) is invisible in a quick visual review. This pattern produces a NamingConventions FAIL for every column in the table simultaneously.

```xml
<!-- ❌ WRONG — table name is "bucInfo" but column prefix is "BucInfo" (PascalCase first letter) -->
<Param id="1000" type="array"><Name>bucInfo</Name></Param>
<Param id="1001"><Name>BucInfoIndex</Name></Param>
<Param id="1002"><Name>BucInfoModelNumber</Name></Param>
<Param id="1003"><Name>BucInfoSerialNumber</Name></Param>
<Param id="1004"><Name>BucInfoFirmwareVersion</Name></Param>
<Param id="1005"><Name>BucInfoPowerWatts</Name></Param>

<!-- ✅ CORRECT — prefix matches table name exactly: "bucInfo" (lowercase b) -->
<Param id="1000" type="array"><Name>bucInfo</Name></Param>
<Param id="1001"><Name>bucInfoIndex</Name></Param>
<Param id="1002"><Name>bucInfoModelNumber</Name></Param>
<Param id="1003"><Name>bucInfoSerialNumber</Name></Param>
<Param id="1004"><Name>bucInfoFirmwareVersion</Name></Param>
<Param id="1005"><Name>bucInfoPowerWatts</Name></Param>
```

> **Trigger**: 10+ simultaneous NamingConventions FAILs from a single table are almost always caused by this pattern. When you see bulk column failures, check whether the table `<Name>` starts with a lowercase letter and whether every column `<Name>` copies it exactly.

### Before/After: Short Single-Word Prefix Trap (NamingConventions WARN/FAIL)

Single-word table names (e.g. `device`) are the most common source of this mistake — authors capitalise the first letter of the prefix without thinking because the word looks like a "type name".

```xml
<!-- ❌ WRONG — table name is "device" but column prefix is "Device" (PascalCase) -->
<Param id="1000" type="array"><Name>device</Name></Param>
<Param id="1001"><Name>DeviceKey</Name></Param>
<Param id="1002"><Name>DeviceName</Name></Param>
<Param id="1003"><Name>DeviceStatus</Name></Param>
<Param id="1004"><Name>DeviceSpeed</Name></Param>

<!-- ✅ CORRECT — prefix matches table name exactly: "device" (lowercase d) -->
<Param id="1000" type="array"><Name>device</Name></Param>
<Param id="1001"><Name>deviceKey</Name></Param>
<Param id="1002"><Name>deviceName</Name></Param>
<Param id="1003"><Name>deviceStatus</Name></Param>
<Param id="1004"><Name>deviceSpeed</Name></Param>
```

- **Column `<Description>`**: Use a human-readable Title Case phrase. When the same description occurs in different tables, append the table description or a clear abbreviation in parentheses (e.g., `Name (Interfaces)`, `Name (Devices)`). Do not copy raw camelCase MIB identifiers as display text.

> **⚠ PER-COLUMN SELF-CHECK — apply immediately after writing each column `<Description>`:**
> 1. The description is human-readable Title Case rather than a raw MIB identifier.
> 2. If another table uses the same description, append the table description or a clear abbreviation in parentheses.
> 3. Use one consistent disambiguation form throughout each table.

### Duplicate Column Description Disambiguation

A parenthetical table suffix is required only when another table defines a column with the same description. A unique column description remains valid without a suffix.

```xml
<!-- Valid while the descriptions are unique in the connector -->
<Param id="1001"><Description>Interface Key</Description></Param>
<Param id="1002"><Description>Interface Name</Description></Param>

<!-- Disambiguate a duplicate description across different tables -->
<Param id="1003"><Description>State (Interfaces)</Description></Param>
<Param id="2003"><Description>State (Streams)</Description></Param>
```

When disambiguation is needed, derive `(TableDescription)` from the relevant table array parameter's `<Description>` value or use one consistent clear abbreviation.

### Before/After: Singular-vs-Plural Prefix Trap

```xml
<Param id="1000" type="array">
  <Name>interface</Name>
</Param>
<Param id="1001">
  <Name>interfaceName</Name>
</Param>

<Param id="1000" type="array">
  <Name>interfaces</Name>
</Param>
<Param id="1001">
  <Name>interfacesName</Name>
</Param>
```

### Title Case Rule for Descriptions

Applies to ALL parameter `<Description>` values — both standalone and table column descriptions.

**Rule**: Capitalize every word EXCEPT the following short words when they appear in the **middle** of the description (never at the start): **a, an, and, as, at, but, by, for, in, nor, of, on, or, so, the, to, up, yet**.

> **This rule applies equally to `<Discreet><Display>` values** (the human-readable labels shown in dropdowns and toggle buttons), not only to parameter `<Description>` values. ❌ `<Display>admin up</Display>` → ✅ `<Display>Admin Up</Display>`.

> **Every `<Display>` value must start with a capital letter.** ❌ `<Display>disabled</Display>` → ✅ `<Display>Disabled</Display>`.

> **CamelCase/PascalCase MIB enum names MUST be split into separate words before applying title case.** ❌ `<Display>DeliveringPower</Display>` → ✅ `<Display>Delivering Power</Display>`. ❌ `<Display>VoltsAC</Display>` → ✅ `<Display>Volts AC</Display>`. ❌ `<Display>Class0</Display>` → ✅ `<Display>Class 0</Display>`.

Always capitalize:
- The **first word** of the description, regardless of length
- **Nouns, verbs, adjectives, and adverbs** even if short (e.g., "Is", "Be", "Are", "No", "Set", "Get", "Run")
- **Acronyms and initialisms** (e.g., IP, HC, DVB, MPTS) per their standard form
- **Brand/product names** per their official capitalization

| Correct ✅ | Incorrect ❌ | Why |
|-----------|-------------|-----|
| `System up Time` | `System Up Time` | "up" is a preposition here, lowercase mid-description |
| `HC in Octets (Interfaces Extended)` | `HC In Octets (Interfaces Extended)` | "in" is a preposition, lowercase mid-description |
| `In Octets (Interfaces)` | `in Octets (Interfaces)` | "In" is the first word — always capitalize |
| `Number of Ports` | `Number Of Ports` | "of" is a preposition, lowercase mid-description |
| `Bit Rate to Device` | `Bit Rate To Device` | "to" is a preposition, lowercase mid-description |

---

## Table Column Pre-Completion Checklist

After writing any table columns, verify each column parameter against this checklist before proceeding:

| Check | Rule | Example pass | Example fail |
|-------|------|-------------|-------------|
| `<Name>` is camelCase concat | `tableNameColumnName` | `runningProcessesCpu` | `Cpu`, `cpu`, `CPU (Running Processes)` |
| `<Name>` has no parenthetical | No `(...)` in `<Name>` | `interfacesIndex` | `Index (Interfaces)` |
| Duplicate column descriptions are disambiguated | When the same description occurs in multiple tables | `CPU (Running Processes)` | Ambiguous `CPU` in several tables |
| `<Description>` uses Title Case | Lowercase **a/an/and/as/at/but/by/for/in/nor/of/on/or/so/the/to/up/yet** mid-description only — the first word is ALWAYS capitalized. Common pitfalls: "in/out" as direction prepositions are lowercase mid-description (❌ `HC In Octets` → ✅ `HC in Octets`), but capitalized when first word (✅ `In Octets (Interfaces)`). "of" always lowercase mid-description (❌ `Number Of Entries` → ✅ `Number of Entries`). | `HC in Octets (Interfaces Extended)`, `In Octets (Interfaces)` | `HC In Octets`, `in Octets (Interfaces)` |
| `<Measurement><Type>` present — **NEVER `UNDEFINED`** | Every column needs a display type. For a **numeric SNMP index PK column** use `<Type>number</Type>`. **NEVER** write `<Type>UNDEFINED</Type>`. | `<Type>number</Type>` | `<Type>UNDEFINED</Type>`, *(missing)* |
| **`<Information><Subtext>` present — write INLINE** | **ALWAYS** add `<Information><Subtext>...</Subtext></Information>` to **each column as you write it** — never defer. Subtext must describe the column in user-friendly language; do not include SNMP OIDs or low-level technical information. | `<Information><Subtext>Unique row index.</Subtext></Information>` | *(missing)* |
| **Column has `<SNMP><OID>` block** | **EVERY** SNMP column param **MUST** have `<SNMP><OID>full.column.oid</OID></SNMP>`. Use **minimal column format**: NO `<Enabled>`, NO `type=`, NO `id=`. | `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` | *(missing entirely)* |
| No `id=` on `<SNMP><OID>` | **NEVER** add an `id` attribute to `<SNMP><OID>` in a column param. Two wrong patterns: **(A)** `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">col.oid</OID></SNMP>` (table block copied); **(B)** `<OID id="3">col.oid</OID>` (MIB column index) | `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` | `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">…</OID></SNMP>` |
| PK column has `<Interprete><Type>string</Type>` | **ALWAYS** add `<Interprete><RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` to the index (PK) column | `<Interprete><RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` | `<Type>double</Type>` on PK column ❌ |
| **Display key column has `<Interprete><Type>string</Type>`** | Non-SNMP `type="displaykey"` column: **ALWAYS** use `<Type>string</Type>`. Text: `<RawType>other</RawType><Type>string</Type>`. Numeric-valued: `<RawType>numeric text</RawType><Type>string</Type>`. | `<Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` | `<Type>double</Type>` on display key column ❌ |
| **All SNMP columns have `<Interprete>` with `<LengthType>`** | **ALWAYS** add `<Interprete><RawType>…</RawType><Type>…</Type><LengthType>next param</LengthType></Interprete>` to **every** SNMP column. **NEVER use `<Type>number</Type>` in `<Interprete>`** — `number` is only valid inside `<Measurement><Type>`. | `<Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` | `<Interprete><Type>number</Type>` ❌ |
| `<Display>` on column params: RTDisplay YES, Positions NO | `<Display><RTDisplay>true</RTDisplay></Display>` — omitting causes MAJOR. **NEVER** add `<Positions>` to a column param's `<Display>`. | `<Display><RTDisplay>true</RTDisplay></Display>` (no Positions) | `<Display><RTDisplay>true</RTDisplay><Positions>…</Positions></Display>` on column param |
| SNMP columns have `type="snmp"` | `type="displaykey"` only for non-SNMP column with no `<SNMP><OID>` block. Single-PID `<NamingFormat>` needs no displaykey column. | `<ColumnOption idx="1" pid="1002" type="snmp" />` | `<ColumnOption idx="0" pid="1001" type="displaykey" />` when 1001 has SNMP OID ❌ |
| **Automatically polled SNMP columns do not use `save`** | Every `ColumnOption type="snmp"` must omit the `save` token from `options`; polling refreshes the value. Alarm/trending requirements do not change this rule. | `options=";disableHeaderSum;disableHeatmap"` or no `options` attribute | `type="snmp" options=";save"` ❌ |
| **`number` column has `<Range>` or 2.11.1 suppression** | **NEVER leave a `number` column with neither `<Range>` nor a 2.11.1 suppression.** **NEVER write `<Range />` or `<Range></Range>`** (empty Range = WARNING). | `<Range><Low>0</Low><High>100</High></Range>` | `<Range />` (empty) ❌; no Range at all ❌ |
| **`number` column has `<Units>` or 2.9.7 suppression** | **NEVER leave a `number` column with neither `<Units>` nor a 2.9.7 suppression.** Unit strings: ❌ `bit/s` → ✅ `bps`; ❌ `octets` → ✅ `Octets`; ❌ `bytes` → ✅ `Octets`; ❌ `packets` → ✅ `Packets`. | `<Display><RTDisplay>true</RTDisplay><Units>Octets</Units></Display>` | *(no Units, no 2.9.7 suppression)*; `<Units>octets</Units>` ❌ |
| **Operational column has `<Alarm><Monitored>true</Monitored>`** | Every column measuring operational telemetry or status (voltages, currents, power, frequencies, temperatures, statuses, error rates) in a non-volatile table **MUST** have `<Alarm><Monitored>true</Monitored></Alarm>` with standard thresholds or justified `2.5.1` suppression. Columns with alarming show header sum, heatmap, and histogram by default — always add `disableHeaderSum;disableHeatmap;disableHistogram` to `ColumnOption@options`. | `<Alarm><Monitored>true</Monitored><Normal>1</Normal><CH>2</CH></Alarm>` or with 2.5.1 suppression | Operational column with no `<Alarm>` block |

---

## Table Measurement Section

Only required when the table is **displayed to the user**. Hidden/background tables don't need it. The table array param's `<Measurement>` uses `tab=` layout options:

```xml
<Measurement>
  <Type options="tab=columns:1001|0-1002|1-1003|2,lines:20,width:100-150-200,sort:INT-STRING-STRING,filter:true">table</Type>
</Measurement>
```

**Full `tab=` sub-options** (`columns`, `lines`, `width`, `sort`, `filter`) and the **hide-a-column** pattern: `dataminer-xml-authoring/references/authoring-best-practices.md` → "Table `tab=` Layout Sub-Options". By default list **every** `<ColumnOption pid>` in `columns:` — an unlisted column is silently hidden. For `ArrayOptions` / `ColumnOption` / `NamingFormat` schema: `dataminer-protocol-xml-reference/references/protocol-tables.md`.

---

## Table Rules

- **ALL columns MUST be listed in `tab=columns:` by default** — Every `<ColumnOption pid>` defined in `<ArrayOptions>` must appear in the `tab=columns:` list unless the user explicitly requests a column to be hidden. ❌ A table with columns 1001, 1002, 1003 but `tab=columns:1001|0-1002|1` (column 1003 missing) → ✅ `tab=columns:1001|0-1002|1-1003|2` unless hiding 1003 was explicitly requested.
- Primary key must be the **first column**. First 100 bytes must be unique. **Numeric keys** preferred. PK column's `<Interprete><Type>` MUST always be `string`.
- **NEVER add an `id` attribute to `<SNMP><OID>` in a table column parameter, and NEVER copy the table array param's full SNMP block onto columns.** Column OIDs use the **minimal column format**: `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` ✅ — NO `<Enabled>`, NO `type=`, NO `id=`.
- Use `NamingFormat` over `displayColumn` for display keys. Do not change existing `displayColumn` to `NamingFormat` (breaking change). **`NamingFormat` uses separator-based format**: first character is the separator (use `,`), followed by parameter IDs. **NEVER** write `<NamingFormat>Row</NamingFormat>` or any plain text without parameter IDs. **NEVER** use bracket syntax like `[1002]`.
- Column parameter `<Name>` must use `tableNameColumnName` camelCase format. Append the table description or a clear abbreviation to `<Description>` only when another table uses the same description.
- Columns of type `"number"` with alarming show a header sum, heatmap, and histogram by default. **Always** add column options `disableHeaderSum`, `disableHeatmap`, and `disableHistogram` unless the user explicitly requests them enabled.
- **SNMP tables with the same index but different OID roots must be separate array parameters.**
- **ALWAYS add `<Display><RTDisplay>true</RTDisplay><Positions>…</Positions></Display>` to the table array parameter itself.**
- **Column params MUST have `<Display><RTDisplay>true</RTDisplay></Display>`** but **NEVER `<Positions>`** in a column param's `<Display>`.
- **Table polling groups: multipleGet CANNOT be used for groups with table parameters in it** — In DataMiner, `multipleGet="true"` on `<Group><Content>` is strictly for groups containing multiple scalar parameters. It CANNOT be used on groups with table parameters in it. For SNMP tables, the retrieval method (such as `multipleGetBulk` or `multipleGetNext`) must be configured on the table parameter's `<SNMP><OID options="...">` tag, NEVER as `multipleGet` on the group.
- **Automatically polled SNMP columns MUST NOT use `;save`** in `ColumnOption@options`. Keep `;save` only for explicitly justified non-SNMP columns such as `retrieved`, `custom`, `state`, DCF, or foreign-key data.
- DO NOT place `foreignkey` on the **index column**. Place `options=";foreignkey=parentTablePid"` on a separate non-index column.

---

## Data Handling Patterns

- Tables should hold **current entries** by default.
- **"Previous data comparison" pattern**: add columns for Auto Removal Delay, Missing Since, Status, and a Remove button.
- **"Infinitely growing data" pattern**: configure max rows, max time retention, delete batch size.
- **Clear table data** when polling is disabled.
- Only **save parameters** when necessary. Use `saveInterval` for frequently changing parameters.
- Respect **foreign key constraints** — remove dependent (child) rows before parent rows.

## Runtime Performance Gate

For a table that is slow, incomplete, or unstable, record the retrieval method and measured volume before changing the XML:

- Prefer row-complete SNMP retrieval when row indexes can shift; use the official retrieval reference for `multipleGetBulk`, `multipleGetNext`, `multipleGet`, `bulk`, `subtable`, and `instance` compatibility.
- Check SNMP response size against the actual path MTU. The documentation's typical Ethernet guidance is to keep the SNMP payload below 1472 bytes, not to assume every network has that path MTU.
- Keep `GetColumns` below 120 K cells per call, sets below 20 K cells, and `FillArray` below 1000 rows per call; split work when measurements approach these limits.
- Check device memory/processing capacity and DataMiner protocol-thread duration separately. A smaller request can fix device pressure while leaving connector-side processing as the bottleneck.
- Keep diagnostic logging scoped to the relevant module and capture window because high log levels consume CPU and disk.

---

## The `instance` Option (Multi-Column SNMP Index)

Some SNMP tables define **multiple index columns** (composite key). Add `instance` to the **table OID** `options` to have DataMiner write the full composite instance identifier into the first column automatically.

**When to use `instance`:**
- The SNMP table has **2+ index columns** in its MIB definition
- The SNMP table's index is defined in a **different table** (e.g., entPhySensorTable uses entPhysicalIndex from ENTITY-MIB)

**Rules when using `instance`:**
- Place `instance` on the **table `<OID>` element only** — combine with a retrieval method: `options="instance;multipleGetBulk"`
- The first column (PK at `idx="0"`) receives the auto-generated instance value — **do NOT specify an `<SNMP><OID>` on this column**
- **NEVER** put `options="instance"` on any `<ColumnOption>` element

> **Worked example** (PoE port table with composite group+port index): `dataminer-xml-authoring/references/table-naming.md` → "Composite SNMP Index — the `instance` Option".

---

## Multi-PID NamingFormat with Displaykey Column

When `<NamingFormat>` references **multiple SNMP column PIDs** (e.g., `,2003,2004`), add a **separate non-SNMP column** with `type="displaykey"` to hold the concatenated display key. This column has **no `<SNMP><OID>` block** — DataMiner auto-populates it from the NamingFormat concatenation. All SNMP columns keep `type="snmp"`.

> **Worked example** (LLDP remote table with a concatenated displaykey column): `dataminer-xml-authoring/references/table-naming.md` → "Multi-PID NamingFormat with a Displaykey Column".

> **Key distinction**: SNMP columns (with `<SNMP><OID>`) → `type="snmp"`. The displaykey column (no `<SNMP><OID>`) → `type="displaykey"`. Never mix these.
