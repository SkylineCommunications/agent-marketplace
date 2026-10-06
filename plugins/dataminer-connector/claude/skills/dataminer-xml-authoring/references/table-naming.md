# Table Naming Conventions

Reference for DataMiner connector table and column naming rules, with SNMP MIB-to-DataMiner name translation examples.

> **Parent skill**: `dataminer-xml-authoring/SKILL.md` — return there for core authoring rules.

---

## Table and Column Naming

Every table you author is validated by the `NamingConventions` check. A single mistake in the table name or column descriptions can produce one finding **per column**, so getting this right before moving on saves large cleanup passes later.

Apply these product conventions when naming tables and columns:

1. **Table `<Name>` is camelCase and has no spaces.**
   - For an SNMP table, deriving the name from the MIB table object by stripping a trailing `Table` is recommended, but a clear descriptive camelCase name is also valid.
   - This `<Name>` becomes the exact prefix for every column `<Name>` in the table.

2. **Column `<Name>` is camelCase and starts with the exact table `<Name>`.**
   - Format: `tableNameColumnName`.
   - The first character MUST be lowercase. The prefix MUST match the table `<Name>` character-for-character (same casing).
   - ❌ `InterfacesIndex` → ✅ `interfacesIndex`.
   - ❌ `interfaceIndex` (wrong prefix) → ✅ `interfacesIndex` (when table name is `interfaces`).

3. **Duplicate column descriptions are disambiguated across tables.**
   - Append the table description or a clear abbreviation in parentheses when the same column description occurs in different tables.
   - ✅ `Name (Interfaces)` and `Name (Devices)`.
   - A parenthetical suffix is not required when the description is already unambiguous.

4. **Column `<Description>` prefix is Title Case, never a raw MIB column name.** *(style convention)*
   - ❌ `ifIndex` → ✅ `Index`.
   - ❌ `ifDescr` → ✅ `Description`.

> **Apply these rules inline as you write each table and column.** Do not defer naming cleanup to a final pass — it is easy to miss columns in multi-table connectors, and each violation becomes a separate finding.

---

## SNMP MIB Table → DataMiner `<Name>` Translation

SNMP MIB table object names commonly end in `Table` (e.g., `ifTable`, `pethPsePortTable`, `lldpRemTable`, `entPhySensorTable`). When preserving the MIB identifier, strip that suffix and camelCase the remainder.

| SNMP MIB table name | DataMiner `<Name>` |
|---------------------|-------------------|
| `ifTable` | `if` |
| `ifXTable` | `ifX` |
| `pethPsePortTable` | `pethPsePort` |
| `lldpRemTable` | `lldpRem` |
| `lldpLocPortTable` | `lldpLocPort` |
| `entPhySensorTable` | `entPhySensor` |
| `entPhysicalTable` | `entPhysical` |
| `dot1dBasePortTable` | `dot1dBasePort` |
| `ipAddrTable` | `ipAddr` |
| `tcpConnTable` | `tcpConn` |
| `tx21BucInfoTable` | `tx21BucInfo` |
| `tx21BucAlarmTable` | `tx21BucAlarm` |
| `tx21BucSensorTable` | `tx21BucSensor` |
| `bucInfoTable` | `bucInfo` |
| `bucAlarmTable` | `bucAlarm` |
| `bucSensorTable` | `bucSensor` |

### Anti-Patterns

Avoid spaces and display labels in table `<Name>` values. Descriptive camelCase names are valid as long as every column uses the exact same prefix:

| ❌ Wrong | ✅ Correct | Why |
|---------|-----------|-----|
| `<Name>Interface Table</Name>` | `<Name>if</Name>` | English expansion + space; columns like `ifIndex` don't start with "Interface Table" |
| `<Name>PoE Port Table</Name>` | `<Name>pethPsePort</Name>` | English expansion + spaces |
| `<Name>LLDP Remote Table</Name>` | `<Name>lldpRem</Name>` | English expansion + spaces |
| `<Name>interfacesTable</Name>` | `<Name>interfaces</Name>` | "Table" suffix breaks `columnName.StartsWith(tableName)` check |
| `<Name>If Table</Name>` | `<Name>if</Name>` | Space in name — always a single camelCase word |
| `<Name>ifTable</Name>` | `<Name>if</Name>` | Verbatim MIB name — "Table" suffix NOT stripped |
| `<Name>Tx21BucInfo</Name>` (from SEQUENCE type `Tx21BucInfoEntry`) | `<Name>tx21BucInfo</Name>` | Derive from OBJECT-TYPE descriptor `tx21BucInfoTable`, not the uppercase SEQUENCE type name |

---

## SNMP MIB Column Name → DataMiner Column Prefix

Column `<Name>` values must be `tableNameColumnName` — where `tableName` is **exactly** the table's `<Name>` value (same casing). When the table name comes from a MIB, the column prefix must match, not an English expansion.

| Table `<Name>` | ❌ Wrong column prefix | ✅ Correct column prefix |
|----------------|----------------------|------------------------|
| `if` | `interfaceIndex`, `interfaceDescr` | `ifIndex`, `ifDescr` |
| `lldpRem` | `lldpRemoteTimeMark`, `lldpRemotePortId` | `lldpRemTimeMark`, `lldpRemPortId` |
| `pethPsePort` | `poEPortGroupIndex` | `pethPsePortGroupIndex` |
| `entPhySensor` | `entitySensorValue` | `entPhySensorValue` |

> **The NamingConventions check uses the table `<Name>` as-is for the `StartsWith` check.** Any mismatch (English expansion, wrong casing, extra suffix) fails **every column** in that table.

---

## SNMP MIB Column Name → DataMiner Column `<Description>` Prefix

Column `<Description>` format is `Title Case Phrase (Table Description)`. The description prefix (before the parentheses) must be a human-readable English phrase — **NEVER copy the MIB column name verbatim**, as MIB names are camelCase and start with a lowercase letter, which violates Title Case.

| MIB column name | ❌ Wrong description prefix | ✅ Correct description prefix |
|-----------------|---------------------------|------------------------------|
| `ifIndex` | `ifIndex` | `Index` |
| `ifDescr` | `ifDescr` | `Description` |
| `ifType` | `ifType` | `Type` |
| `ifOperStatus` | `ifOperStatus` | `Operational Status` |
| `ifInOctets` | `ifInOctets` | `In Octets` |
| `ifOutOctets` | `ifOutOctets` | `Out Octets` |
| `ifHCInOctets` | `ifHCInOctets` | `HC in Octets` |
| `pethPsePortGroupIndex` | `pethPsePortGroupIndex` | `Group Index` |
| `pethPsePortIndex` | `pethPsePortIndex` | `Port Index` |
| `lldpRemTimeMark` | `lldpRemTimeMark` | `Time Mark` |
| `lldpRemPortId` | `lldpRemPortId` | `Port ID` |
| `entPhySensorValue` | `entPhySensorValue` | `Value` |
| `entPhySensorType` | `entPhySensorType` | `Type` |
| `entPhySensorPrecision` | `entPhySensorPrecision` | `Precision` |

### Full Description Examples

| Column param `<Description>` ✅ |
|---------------------------------|
| `Index (If)` |
| `Description (If)` |
| `Operational Status (If)` |
| `In Octets (If)` |
| `HC in Octets (If Extended)` |
| `Group Index (Peth Pse Port)` |
| `Port Index (Peth Pse Port)` |
| `Time Mark (Lldp Rem)` |
| `Value (Ent Phy Sensor)` |

---

## Worked Table Examples

These full examples show the naming conventions and the **TABLE GENERATION GATE** rules (see the `dataminer-xml-authoring` SKILL.md) applied in context. The gate rules and the Table Column Pre-Completion Checklist remain in the SKILL.md — consult them while writing; use these as the shape to follow.

### Canonical SNMP Table (Interfaces)

```xml
<Param id="1000" trending="false">
  <Name>interfaces</Name>
  <Description>Interfaces</Description>
  <Information>
    <Subtext>Interface statistics for all network interfaces on this device.</Subtext>
  </Information>
  <Type>array</Type>
  <ArrayOptions index="0">
    <NamingFormat>,1002</NamingFormat>
    <ColumnOption idx="0" pid="1001" type="snmp" options="" />
    <ColumnOption idx="1" pid="1002" type="snmp" options="" />
    <ColumnOption idx="2" pid="1003" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.2.2</OID>
  </SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions>
      <Position>
        <Page>Interfaces</Page>
        <Row>0</Row>
        <Column>0</Column>
      </Position>
    </Positions>
  </Display>
  <Measurement>
    <Type options="tab=columns:1001|0-1002|1-1003|2,lines:20,width:100-150-200,sort:INT-STRING-STRING,filter:true">table</Type>
  </Measurement>
</Param>
<Param id="1001">
  <Name>interfacesIndex</Name>
  <Description>Index (Interfaces)</Description>
  <Information>
    <Subtext>Unique numeric index identifying each interface row.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>number</Type>
  </Measurement>
</Param>
<Param id="1002">
  <Name>interfacesDescription</Name>
  <Description>Description (Interfaces)</Description>
  <Information>
    <Subtext>Human-readable description of the interface as configured on the device.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP><OID>1.3.6.1.2.1.2.2.1.2</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>string</Type>
  </Measurement>
</Param>
<Param id="1003">
  <Name>interfacesStatus</Name>
  <Description>Status (Interfaces)</Description>
  <Information>
    <Subtext>Operational status of the interface (1 = up, 2 = down, 3 = testing).</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP><OID>1.3.6.1.2.1.2.2.1.8</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>number</Type>
  </Measurement>
</Param>
```

### Composite SNMP Index — the `instance` Option

Use `instance` on the **table `<OID>`** (combined with a retrieval method, e.g. `options="instance;multipleGetBulk"`) when the SNMP table has 2+ index columns, or its index is defined in a different table. The first column (PK, `idx="0"`) receives the auto-generated instance value and **must not** specify an `<SNMP><OID>`. **NEVER** put `options="instance"` on a `<ColumnOption>` (causes validator errors 2922 and 2901).

```xml
<Param id="2000" trending="false">
  <Name>pethPsePort</Name>
  <Description>Peth Pse Port</Description>
  <Type>array</Type>
  <ArrayOptions index="0">
    <NamingFormat>,2002</NamingFormat>
    <ColumnOption idx="0" pid="2001" type="snmp" options="" />
    <ColumnOption idx="1" pid="2002" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete" options="instance;multipleGetBulk">1.3.6.1.2.1.105.1.1</OID>
  </SNMP>
</Param>

<Param id="2001">
  <Name>pethPsePortInstance</Name>
  <Description>Instance (Peth Pse Port)</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display><RTDisplay>true</RTDisplay></Display>
  <Measurement><Type>string</Type></Measurement>
</Param>
```

### Multi-PID NamingFormat with a Displaykey Column

When `<NamingFormat>` references **multiple SNMP column PIDs** (e.g., `,3003,3004`), add a **separate non-SNMP column** with `type="displaykey"` to hold the concatenated display key. It has **no `<SNMP><OID>` block** (DataMiner auto-populates it); all SNMP columns keep `type="snmp"`.

```xml
<Param id="3000" trending="false">
  <Name>lldpRem</Name>
  <Description>Lldp Rem</Description>
  <Type>array</Type>
  <ArrayOptions index="0" options=";volatile">
    <NamingFormat>,3003,3004</NamingFormat>
    <ColumnOption idx="0" pid="3001" type="snmp" options="" />
    <ColumnOption idx="1" pid="3002" type="displaykey" options="" />
    <ColumnOption idx="2" pid="3003" type="snmp" options="" />
    <ColumnOption idx="3" pid="3004" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete" options="instance;multipleGetBulk">1.3.6.1.2.1.99.1.1</OID>
  </SNMP>
</Param>

<Param id="3002">
  <Name>lldpRemDisplayKey</Name>
  <Description>Display Key (Lldp Rem)</Description>
  <Information>
    <Subtext>Concatenated display key for this table row.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display><RTDisplay>true</RTDisplay></Display>
  <Measurement><Type>string</Type></Measurement>
</Param>
```

> **Key distinction**: SNMP columns (with `<SNMP><OID>`) → `type="snmp"`. The displaykey column (no `<SNMP><OID>`) → `type="displaykey"`. Never mix these — putting `type="displaykey"` on an SNMP column is always wrong.
