# SNMP Writes: Setting Single Parameters

Devices running an SNMP agent typically allow altering read-write variables via SNMP SET requests. In a DataMiner connector, a `write` parameter with an SNMP OID sends a SET when the user changes its value.

> **Source**: https://aka.dataminer.services/connections-snmp-altering-a-variable
>
> For **table cell** writes, see `dataminer-xml-authoring/references/snmp-writes-table-cell.md`.

---

## Important: Optimistic Update & Verification

When an SNMP write parameter is set by the user, DataMiner **immediately** copies the new value to the corresponding read parameter — even before the SET request reaches the device. This is an optimistic update: since SNMP sets rarely fail under normal conditions, the UI shows the new value right away.

However, because the SET _can_ fail, **always ensure a verification GET** restores the actual
device value in the read parameter.

For manual `snmpSet` or trigger+action patterns, queue the verification GET immediately after the
user-initiated write; `execute next` is appropriate for that event-driven priority. This is not
routine polling: ordinary poll groups belong on their timers. The `snmpSetAndGet="true"` attribute
performs the verification GET automatically and needs no extra trigger or action.

---

## Approach Overview

| Approach | Attribute/Option | Blocking? | Auto GET after SET? | Extra XML needed? | Recommended for |
|----------|-----------------|-----------|--------------------|--------------------|-----------------|
| `snmpSet` option | `options="snmpSet"` | No | No — add manual verification trigger | None (fire-and-forget) | Simple sets where you control the re-read schedule |
| Trigger + Action | _(none)_ | No | No — add manual verification trigger | Trigger + Action | Legacy connectors, special sequencing needs |
| `snmpSetAndGet` attribute | `snmpSetAndGet="true"` | No | **Yes** (via execute next) | None | **Default recommendation for single params** |
| `snmpSetWithWait` | `options="snmpSetWithWait"` | **Yes** | No | None | When you need confirmation the SET succeeded before continuing |
| `snmpSetAndGetWithWait` | `options="snmpSetAndGetWithWait"` | **Yes** | **Yes** (blocking) | None | When you need both confirmed SET and verified GET |

> **Recommended default**: Use `snmpSetAndGet="true"` for single standalone parameters. It handles both the SET and the verification GET automatically with minimal XML.

---

## Approach 1: `options="snmpSet"` (Preferred Simple Method)

Add `options="snmpSet"` on the write parameter. When the value changes, DataMiner sends an SNMP SET automatically — no trigger or action required.

```xml
<Param id="150" options="snmpSet">
  <Name>systemContact</Name>
  <Description>System Contact</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>other</RawType>
    <LengthType>next param</LengthType>
    <Type>string</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.4.0</OID>
    <Type>octetstring</Type>
  </SNMP>
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
</Param>
```

**Important**: You still need a verification trigger + `execute next` action to re-read the value after the SET. See the [Verification Pattern](#verification-re-read-pattern) below.

---

## Approach 2: Trigger + "set parameter" Action (Manual)

Without `snmpSet`, you can wire a trigger that fires on write-param change and an action of type `set` to perform the SNMP SET.

```xml
<Param id="150">
  <Name>systemContact</Name>
  <Description>System Contact</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>other</RawType>
    <LengthType>next param</LengthType>
    <Type>string</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.4.0</OID>
    <Type>octetstring</Type>
  </SNMP>
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
</Param>

<Trigger id="150">
  <Name>On Write System Contact</Name>
  <On id="150">parameter</On>
  <Time>change</Time>
  <Type>action</Type>
  <Content>
    <Id>150</Id>
  </Content>
</Trigger>

<Action id="150">
  <Name>Set System Contact</Name>
  <On id="150">parameter</On>
  <Type>set</Type>
</Action>
```

This approach is more verbose. Prefer `options="snmpSet"` or `snmpSetAndGet` unless you need special sequencing.

---

## Approach 3: `snmpSetAndGet` Attribute (Recommended Default)

The `snmpSetAndGet` attribute on the write parameter performs both the SET and a follow-up GET of the corresponding read parameter automatically. The GET is added to the execution queue via `execute next`.

```xml
<Param id="150" snmpSetAndGet="true">
  <Name>systemContact</Name>
  <Description>System Contact</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>other</RawType>
    <LengthType>next param</LengthType>
    <Type>string</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.4.0</OID>
    <Type>octetstring</Type>
  </SNMP>
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
</Param>
```

No additional trigger or action is needed — the GET is handled automatically. The GET will not execute if the SET failed.

> **Non-main connection**: If the SNMP connection is not the main connection, specify the connection in the `<Type>` options:
> ```xml
> <Param id="150" snmpSetAndGet="true">
>   <Type options="connection=1">write</Type>
>   ...
> </Param>
> ```

---

## Approach 4: `options="snmpSetWithWait"`

Performs the SET and **waits** until the SNMP manager receives a "noError" response from the device. A group is added to the execution queue for the SET. This is a **blocking** operation — the protocol engine waits for the SET to complete before proceeding.

```xml
<Param id="150" options="snmpSetWithWait">
  <Name>systemContact</Name>
  <Description>System Contact</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>other</RawType>
    <LengthType>next param</LengthType>
    <Type>string</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.4.0</OID>
    <Type>octetstring</Type>
  </SNMP>
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
</Param>
```

Use when you need **confirmation** that the SET succeeded (e.g., before making a dependent change). Does NOT automatically perform a GET — add a verification trigger if needed.

---

## Approach 5: `options="snmpSetAndGetWithWait"`

Performs the SET, waits for success, then performs a GET and waits for the response. Both operations are **blocking**. There is no value verification — the GET result is simply stored.

```xml
<Param id="150" options="snmpSetAndGetWithWait">
  <Name>systemContact</Name>
  <Description>System Contact</Description>
  <Type>write</Type>
  <Interprete>
    <RawType>other</RawType>
    <LengthType>next param</LengthType>
    <Type>string</Type>
  </Interprete>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.1.4.0</OID>
    <Type>octetstring</Type>
  </SNMP>
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
</Param>
```

Use when both SET confirmation and immediate value verification are required.

---

## Verification / Re-Read Pattern

When using `options="snmpSet"` or the trigger+action approach (approaches 1 and 2), you must
**manually** add a verification step. This is a response to the user-initiated SET, not normal
polling. The pattern triggers a re-read of the polling group containing the corresponding read
parameter, using `execute next` to queue it immediately after the current group.

```xml
<Trigger id="1">
  <Name>On Write System Contact</Name>
  <On id="150">parameter</On>
  <Time>change</Time>
  <Type>action</Type>
  <Content>
    <Id>1</Id>
  </Content>
</Trigger>

<Action id="1">
  <Name>Refresh General Info</Name>
  <On id="1">group</On>
  <Type>execute next</Type>
</Action>

<Group id="1">
  <Name>General Info</Name>
  <Description>General Info</Description>
  <Content multipleGet="true">
    <Param>100</Param>
    <Param>101</Param>
    <Param>102</Param>
  </Content>
</Group>
```

> **Note**: `snmpSetAndGet="true"` and `snmpSetAndGetWithWait` handle the verification GET automatically — no manual trigger/action needed for those approaches.

---

## Quick Decision Guide

1. **Just need a simple SNMP write with automatic readback?** → `snmpSetAndGet="true"` (Approach 3)
2. **Need confirmation the SET succeeded before next steps?** → `options="snmpSetWithWait"` (Approach 4)
3. **Need confirmed SET + confirmed readback?** → `options="snmpSetAndGetWithWait"` (Approach 5)
4. **Want fire-and-forget SET with your own refresh logic?** → `options="snmpSet"` (Approach 1) + verification trigger
5. **Legacy connector or special sequencing?** → Trigger + Action (Approach 2) + verification trigger
