# SNMP Simulation Schema

Defines the `.toon` simulation file structure for SNMP connectors. Every SNMP OID in the connector's `protocol.xml` must be represented in the output.

## Schema Structure

```
meta:                          ← Required metadata
  connector: <name>
  version: <version>
  type: snmp
  generated: <ISO timestamp>
snmp:                          ← SNMP simulation data
  scalars[N]{oid,type,value}:  ← All standalone OIDs (typically ending .0)
    <rows>
  tables[N]:                   ← All SNMP tables
    - name: <table name>
      baseOid: <table OID prefix>
      columns[N]{subOid,type,name}:
        <column definitions>
      rows[N]{index,<subOid1>,<subOid2>,...}:
        <row data>
```

## Field Definitions

### meta (Required)

| Field | Type | Description |
|-------|------|-------------|
| `connector` | string | Protocol name from `<Protocol><Name>` (format: `Vendor - Product`) |
| `version` | string | Protocol version from `<Protocol><Version>` |
| `type` | string | Always `snmp` for SNMP-only connectors |
| `generated` | string | ISO 8601 timestamp of generation (quoted, contains `:`) |

### snmp.scalars (Tabular Array)

Each row represents one scalar OID (standalone parameter, not part of a table).

| Column | Description |
|--------|-------------|
| `oid` | Full OID string (e.g., `1.3.6.1.2.1.1.1.0`) |
| `type` | ASN.1 type: `OctetString`, `Integer32`, `Counter32`, `Gauge32`, `TimeTicks`, `Counter64`, `IpAddress` |
| `value` | Simulated value (quoted if contains commas or looks like a literal) |

### snmp.tables (List Array)

Each item represents one SNMP table.

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Table parameter name from `<Param><Name>` |
| `baseOid` | string | Common OID prefix for all columns (e.g., `1.3.6.1.2.1.2.2.1`) |
| `columns` | tabular array | Column definitions: `{subOid,type,name}` |
| `rows` | tabular array | Row data: `{index,<subOid1>,<subOid2>,...}` |

### columns Tabular Array

| Column | Description |
|--------|-------------|
| `subOid` | Sub-OID number appended to baseOid (e.g., `2` → `baseOid.2.index`) |
| `type` | ASN.1 type of this column |
| `name` | Column parameter name from `<Param><Name>` |

### rows Tabular Array

- First field is always `index` (the SNMP table instance index, typically sequential integers)
- Remaining fields match the `subOid` values from the columns definition, in the same order
- Generate 3 rows by default

## Extraction Rules

### Step 1: Find All SNMP Parameters

Search `protocol.xml` for all `<Param>` elements that contain `<SNMP><OID>`:

```xml
<Param id="100">
  <Name>systemDescription</Name>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.1.0</OID>
    <Type>OctetString</Type>
  </SNMP>
</Param>
```

### Step 2: Classify as Scalar vs Table Column

- **Scalar**: Parameter is NOT referenced as a column in any `<ArrayOptions>` table. Typically has a complete OID ending in `.0`
- **Table column**: Parameter appears in an `<ArrayOptions options=";naming=...">` or is referenced via `<ColumnOption>` in a table parameter

### Step 3: Identify Tables

Find parameters with `<ArrayOptions>`:

```xml
<Param id="1000">
  <Name>interfacesTable</Name>
  <ArrayOptions index="0">
    <ColumnOption idx="0" pid="1001" type="snmp" options="" />
    <ColumnOption idx="1" pid="1002" type="snmp" options="" />
    <ColumnOption idx="2" pid="1003" type="snmp" options="" />
  </ArrayOptions>
</Param>
```

The column params (1001, 1002, 1003) each have their own `<SNMP><OID>` with a sub-OID.

### Step 4: Determine Base OID

The base OID is the common prefix shared by all column OIDs in the table. For example:
- Column 1 OID: `1.3.6.1.2.1.2.2.1.1` → sub-OID `1`
- Column 2 OID: `1.3.6.1.2.1.2.2.1.2` → sub-OID `2`
- Base OID: `1.3.6.1.2.1.2.2.1`

### Step 5: Map SNMP Types

| protocol.xml `<Type>` | TOON `type` value |
|----------------------|-------------------|
| `OctetString` or `octetstring` | `OctetString` |
| `Integer` or `Integer32` | `Integer32` |
| `Counter32` | `Counter32` |
| `Gauge32` or `Gauge` | `Gauge32` |
| `TimeTicks` | `TimeTicks` |
| `Counter64` | `Counter64` |
| `IpAddress` | `IpAddress` |
| (missing or empty) | `OctetString` (default) |

## Complete Example

Given a protocol.xml with system MIB scalars and an interfaces table:

```toon
meta:
  connector: Acme - Network Switch 5000
  version: 1.0.0.1
  type: snmp
  generated: "2026-07-08T12:00:00Z"
snmp:
  scalars[5]{oid,type,value}:
    1.3.6.1.2.1.1.1.0,OctetString,Acme Switch OS 4.2.1
    1.3.6.1.2.1.1.3.0,TimeTicks,8640000
    1.3.6.1.2.1.1.4.0,OctetString,admin@acme.local
    1.3.6.1.2.1.1.5.0,OctetString,switch-core-01
    1.3.6.1.2.1.1.6.0,OctetString,Building A Floor 3
  tables[2]:
    - name: interfacesTable
      baseOid: 1.3.6.1.2.1.2.2.1
      columns[5]{subOid,type,name}:
        1,Integer32,ifIndex
        2,OctetString,ifDescr
        3,Integer32,ifType
        5,Gauge32,ifSpeed
        8,Integer32,ifOperStatus
      rows[3]{index,1,2,3,5,8}:
        1,1,GigabitEthernet0/1,6,1000000000,1
        2,2,GigabitEthernet0/2,6,1000000000,2
        3,3,Management0,6,100000000,1
    - name: ipRouteTable
      baseOid: 1.3.6.1.2.1.4.21.1
      columns[4]{subOid,type,name}:
        1,IpAddress,ipRouteDest
        2,Integer32,ipRouteIfIndex
        7,IpAddress,ipRouteNextHop
        8,Integer32,ipRouteType
      rows[3]{index,1,2,7,8}:
        1,10.0.0.0,1,10.0.0.1,4
        2,192.168.1.0,2,192.168.1.1,3
        3,0.0.0.0,1,10.0.0.1,4
```

## Validation Checklist

Before completing output, verify:

- [ ] `meta.type` is `snmp`
- [ ] Every `<Param>` with `<SNMP><OID>` in protocol.xml appears either in `scalars` or in a table's `columns`
- [ ] `scalars[N]` count matches actual row count
- [ ] Each table's `columns[N]` count matches actual column rows
- [ ] Each table's `rows[N]` count matches actual data rows (default 3)
- [ ] Row field headers (`{index,subOid1,subOid2,...}`) match the column `subOid` values in order
- [ ] All OIDs are copied verbatim from protocol.xml (never invented)
- [ ] Values that contain commas are quoted
- [ ] `generated` timestamp is quoted (contains `:`)
- [ ] No trailing spaces on any line
