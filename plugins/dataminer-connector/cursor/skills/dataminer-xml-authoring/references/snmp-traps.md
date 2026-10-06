# SNMP Traps

Reference for configuring SNMP trap reception, binding mapping, alarm generation, and QAction processing.

> **Parent skill**: `dataminer-xml-authoring/SKILL.md` — return there for core authoring rules.

---

## Trap Parameters

Trap parameters receive SNMP traps matching a specific OID pattern.

```xml
<Param id="21">
  <Name>trapReceiver</Name>
  <Description>Trap Receiver</Description>
  <Type>dummy</Type>
  <Display><RTDisplay>false</RTDisplay></Display>
  <SNMP>
    <Enabled>true</Enabled>
    <TrapOID setBindings="1,250" type="wildcard" ipid="100">1.3.6.1.4.1.99999.0.1.*</TrapOID>
  </SNMP>
</Param>
```

## TrapOID Attributes

| Attribute | Description |
|-----------|-------------|
| `type="complete"` | Match exact OID |
| `type="wildcard"` | Match with `*` wildcards |
| `setBindings="N,pid"` | Map binding N to parameter pid |
| `setBindings="allBindingInfo"` | Pass all bindings to QAction as `object[]` |
| `checkBindings="N=pattern"` | Validate binding before processing |
| `ipid="pid"` | Filter by source IP (from parameter) |

## Alarm Generation from Traps

```xml
<TrapOID mapAlarm="TRUE|Severity:1:Critical,1;Normal,2|Value:Trap '[1]' '[2]' '[3]'|Link:2,3"
  type="wildcard">1.3.6.1.4.1.99999.0.1.*</TrapOID>
```

## TrapMappings (Complex Logic)

```xml
<TrapMappings>
  <TrapMapping bindingMatch="3:TS Sync Loss" severity="Critical" value="[4]:[3]:[5]"/>
  <TrapMapping bindingMatch="*" severity="information" value="Unknown trap:[4]-[3]-[5]"/>
</TrapMappings>
```

## QAction Processing

With `setBindings="allBindingInfo"`, the QAction receives an `object[]`:
- `trapInfo[0]`: General info (OID, source IP, tick count)
- `trapInfo[1..n]`: Variable bindings (OID and value pairs)
