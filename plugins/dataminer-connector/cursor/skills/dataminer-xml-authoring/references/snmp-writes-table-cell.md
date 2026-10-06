# SNMP Writes: Altering a Table Cell

Different approaches are available to implement SNMP SET on a table cell (column write parameter). The right choice depends on whether you need automatic row resolution, blocking behavior, or custom QAction logic.

> **Source**: https://aka.dataminer.services/connections-snmp-altering-a-table-cell
>
> For **single standalone parameter** writes, see `dataminer-xml-authoring/references/snmp-writes-single.md`.

---

## Approach Overview

| Approach | Key Mechanism | Auto Row Resolution? | Blocking? | QAction Required? | Recommended for |
|----------|--------------|---------------------|-----------|-------------------|-----------------|
| `snmpSetAndGet` attribute | `snmpSetAndGet="true"` on column write | Yes (via `instance` option) | No | No | **Default recommendation** — simplest |
| `snmpSetAndGetWithWait` option | `options="snmpSetAndGetWithWait"` on column write | Yes (via `instance` option) | **Yes** | No | When SET confirmation is needed |
| Instance holder pattern | Hidden write param + instance param + QAction | Manual (QAction resolves row) | No | **Yes** | Complex logic, conditional sets, multi-step operations |
| Via SLScripting (`NT_SNMP_SET`) | `NotifyProtocol(292, ...)` in QAction | Manual | Depends | **Yes** | Full programmatic control |

> **Recommended default**: Use `snmpSetAndGet="true"` on the column write parameter with the `instance` option on the table OID.

---

## Prerequisite: The `instance` Option

For approaches 1 and 2, the table parameter **must** use the `instance` option in its SNMP OID tag. This tells DataMiner how to resolve the row key for the SET/GET operation.

```xml
<Param id="1000" trending="false">
  <Name>Interfaces</Name>
  <Description>Interfaces</Description>
  <Type>array</Type>
  <ArrayOptions index="0">
    <ColumnOption idx="0" pid="1001" type="snmp" options="" />
    <ColumnOption idx="1" pid="1002" type="snmp" options="" />
    <ColumnOption idx="2" pid="1003" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete" options="instance;multipleGetNext">1.3.6.1.2.1.2.2</OID>
  </SNMP>
  ...
</Param>
```

The table must also be **displayed** (`RTDisplay = true`), as a user interaction is needed to trigger the write.

---

## Approach 1: `snmpSetAndGet` Attribute (Recommended Default)

Add the `snmpSetAndGet` attribute on the column write parameter. When a user changes the cell value, DataMiner automatically performs the SET then a GET (via `execute next`) of the affected cell.

### Column Write Parameter

```xml
<Param id="1053" snmpSetAndGet="true">
  <Name>interfacesAdminStatus</Name>
  <Description>Admin Status (Interfaces)</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <LengthType>next param</LengthType>
    <Type>double</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.2.2.1.7</OID>
    <Type>integer</Type>
  </SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>discreet</Type>
    <Discreets>
      <Discreet>
        <Display>Up</Display>
        <Value>1</Value>
      </Discreet>
      <Discreet>
        <Display>Down</Display>
        <Value>2</Value>
      </Discreet>
      <Discreet>
        <Display>Testing</Display>
        <Value>3</Value>
      </Discreet>
    </Discreets>
  </Measurement>
</Param>
```

### Table ColumnOption Entry

Include the write column in the table's `<ArrayOptions>`:

```xml
<ArrayOptions index="0">
  <ColumnOption idx="0" pid="1001" type="snmp" options="" />
  <ColumnOption idx="1" pid="1002" type="snmp" options="" />
  <ColumnOption idx="2" pid="1003" type="snmp" options="" />
  <ColumnOption idx="3" pid="1053" type="write" options="" />
</ArrayOptions>
```

**Key points:**
- The GET will NOT execute if the SET failed.
- No additional triggers, actions, or QActions needed.
- The column write OID should be the **column OID without the instance suffix** — DataMiner appends the row instance automatically because of the `instance` option on the table.

> **Non-main connection**: Specify the connection in the `<Type>` options:
> ```xml
> <Param id="1053" snmpSetAndGet="true">
>   <Type options="connection=1">write</Type>
>   ...
> </Param>
> ```

### `snmpSetAndGet` Values

| Value | Behavior |
|-------|----------|
| `true` | SET then GET of the cell (default via `execute next`) |
| `executeNext` | Same as `true` — explicit `execute next` semantics |
| `row;executeNext` | SET then GET of the **entire row** (not just the cell) |

---

## Approach 2: `options="snmpSetAndGetWithWait"` on Column

Similar to Approach 1, but **blocking**: waits for the SET to succeed, then waits for the GET to complete. Requires the `instance` option on the table and a wildcard `*` in the column write OID.

```xml
<Param id="1053" options="snmpSetAndGetWithWait">
  <Name>interfacesAdminStatus</Name>
  <Description>Admin Status (Interfaces)</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <LengthType>next param</LengthType>
    <Type>double</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.2.2.1.7.*</OID>
    <Type>integer</Type>
  </SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>discreet</Type>
    <Discreets>
      <Discreet>
        <Display>Up</Display>
        <Value>1</Value>
      </Discreet>
      <Discreet>
        <Display>Down</Display>
        <Value>2</Value>
      </Discreet>
      <Discreet>
        <Display>Testing</Display>
        <Value>3</Value>
      </Discreet>
    </Discreets>
  </Measurement>
</Param>
```

Note the wildcard `*` at the end of the OID — DataMiner replaces it with the row instance.

---

## Approach 3: Instance Holder Pattern (Manual with QAction)

This approach gives full control but requires more XML and a QAction. Use when you need custom logic (e.g., conditional sets, value transformations, multi-step operations).

### Step 1: Column Write Parameter (displayed, NO SNMP tag)

This is the parameter the user interacts with in the table. It triggers the QAction but does NOT perform the SNMP SET itself.

```xml
<Param id="1053">
  <Name>interfacesAdminStatus</Name>
  <Description>Admin Status (Interfaces)</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <LengthType>next param</LengthType>
    <Type>double</Type>
  </Interprete>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>discreet</Type>
    <Discreets>
      <Discreet><Display>Up</Display><Value>1</Value></Discreet>
      <Discreet><Display>Down</Display><Value>2</Value></Discreet>
      <Discreet><Display>Testing</Display><Value>3</Value></Discreet>
    </Discreets>
  </Measurement>
</Param>
```

> **Important**: Do NOT include an `<SNMP>` tag on this parameter.

### Step 2: Hidden Write Parameter (with `snmpSet` + wildcard OID)

This hidden parameter performs the actual SNMP SET. It references an instance holder parameter via the `id` attribute on the OID.

```xml
<Param id="1090" options="snmpSet">
  <Name>interfacesAdminStatusSnmpSet</Name>
  <Description>Interface Admin Status SNMP Set</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <LengthType>next param</LengthType>
    <Type>double</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete" id="1091">1.3.6.1.2.1.2.2.1.7.*</OID>
    <Type>integer</Type>
  </SNMP>
</Param>
```

- `id="1091"` links to the instance holder parameter (step 3)
- The `*` wildcard is replaced with the value of parameter 1091 at runtime

### Step 3: Instance Holder Parameter (read, hidden)

Stores the primary key of the row being written.

```xml
<Param id="1091">
  <Name>interfacesTableInstance</Name>
  <Description>Interface Table Instance</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <LengthType>next param</LengthType>
    <Type>string</Type>
  </Interprete>
  <Measurement>
    <Type>string</Type>
  </Measurement>
</Param>
```

### Step 4: QAction with `row="true"`

Resolves the row, copies the value to the hidden SET parameter, and triggers a table refresh.

```xml
<QAction id="1053" name="Set Admin Status" encoding="csharp" triggers="1053" row="true">
<![CDATA[
using Skyline.DataMiner.Scripting;

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        object value = protocol.GetParameter(1053);
        string primaryKey = protocol.RowKey();

        // Set the instance parameter to the row's primary key
        protocol.SetParameter(1091, primaryKey);

        // Set the hidden write parameter — triggers the SNMP SET
        protocol.SetParameter(1090, value);

        // Refresh the table to verify the SET
        protocol.CheckTrigger(1);
    }
}
]]>
</QAction>
```

The `protocol.CheckTrigger(1)` call triggers the table re-read. Make sure trigger 1 points to an `execute next` action on the table polling group.

---

## Approach 4: Via SLScripting (`NT_SNMP_SET`)

For full programmatic control, use `NotifyProtocol` type 292 (`NT_SNMP_SET`) in a QAction to perform the SNMP SET directly.

Steps:
1. Create a column write parameter (displayed, no SNMP tag)
2. Create a QAction triggered by the write parameter that calls `NT_SNMP_SET`

> **Reference**: https://aka.dataminer.services/nt-snmp-set

> ⚠️ **DELT MAJOR validator finding**: Using `NotifyProtocol(292/*NT_SNMP_SET*/, ...)` in a QAction triggers a **MAJOR** validator finding on every QAction that calls it: *"Invocation of method 'SLProtocol.NotifyProtocol(292/\*NT_SNMP_SET\*/, ...)' is not compatible with 'DELT'"*. **NEVER use this approach unless no alternative exists** (e.g., dynamic OID construction, conditional multi-OID sets). For all other table cell writes, use `snmpSetAndGet="true"` (Approach 1), which requires no QAction and produces no validator findings.

This approach is rarely needed for simple column writes. Use only when the other approaches are insufficient (e.g., dynamic OID construction, conditional multi-OID sets).

---

## Quick Decision Guide

1. **Simple table cell write with automatic readback?** → `snmpSetAndGet="true"` (Approach 1) + `instance` on table
2. **Need blocking confirmation of SET + GET?** → `options="snmpSetAndGetWithWait"` (Approach 2) + `instance` on table
3. **Need custom logic, value transformation, or conditional writes?** → Instance holder pattern (Approach 3)
4. **Need full programmatic control over the SNMP SET?** → `NT_SNMP_SET` via SLScripting (Approach 4)
