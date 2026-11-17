# Validator Suppression Examples

Full reference for suppressing validator remarks via XML comments. Load this when authoring or reviewing suppression comments in `protocol.xml`.

## Syntax

```xml
<!-- SuppressValidator <code> <reason> -->
<TagThatCausesRemark>...</TagThatCausesRemark>
<!-- /SuppressValidator <code> -->
```

- `<code>` is the validator result code (e.g. `2.5.1`).
- `<reason>` is **mandatory** — explain why it's suppressed.
- Comments must directly wrap the **specific child element** causing the remark, not the entire `<Param>`.

## Example

```xml
<Param id="100" trending="false">
  <Name>packetCount</Name>
  <Description>Packet Count</Description>
  <Type>read</Type>
  <!-- SuppressValidator 2.5.1 No meaningful alarm thresholds for this counter -->
  <Alarm>
    <Monitored>true</Monitored>
  </Alarm>
  <!-- /SuppressValidator 2.5.1 -->
</Param>
```

## Suppression Rules

- Only suppress remarks that are **genuinely not applicable**.
- Always provide a **clear, specific reason**.
- Do NOT suppress Critical or Major issues without compelling justification.
- Suppressed remarks can be reviewed with the `--include-suppressed` flag.

## Common Suppressions

### 2.9.7 — Missing Units tag for dimensionless number parameters

The **default** when a number parameter has no meaningful unit is to **suppress** this remark. A number has no meaningful unit when it is not tied to a physical or standardized measurement unit (e.g., index, count, ID, sequence number, ratio, priority level, hop count, retry count, slot number, error code, VLAN ID, port number, PID, session count, or any plain counter/identifier). Only add `<Display><Units>` when a recognized unit applies (%, dBm, Mbps, Kbps, bps, ms, s, MHz, GB, MB, dB, V, A, W, deg C, etc.). **NEVER use non-standard unit strings** — the validator will report "Unknown unit" for any unrecognized string. Common mistakes to avoid:
- ❌ `bit/s` → ✅ `bps` (or `Kbps`, `Mbps`, `Gbps` if the value is already scaled)
- ❌ `bits/second`, `bytes/s` → ✅ `bps`, `Bps`
- ❌ `hundredths of a second` — DataMiner has no unit for SNMP timetick values. If the raw SNMP value is in hundredths of a second and you cannot convert it, **suppress 2.9.7** with reason `"SNMP timetick value, no standard unit applicable"`.
- ❌ `octets` → ✅ `Octets` — unit strings are **case-sensitive**; the validator reports **"Obsolete unit 'octets'. New syntax 'Octets'"** when lowercase is used. **ALWAYS use the exact casing from the DataMiner unit registry.** Common case-sensitive corrections: `octets` → `Octets`, `packets` → `Packets`.
- ❌ `°C` → ✅ `deg C` — DataMiner does not support the degree symbol (`°`) in unit strings. Always use `deg C` for degrees Celsius.
- ❌ `hg`, `hPa`, `mmHg`, `mg`, `kg/s`, or **any SI-prefix combination not in the recognized list** — DataMiner recognizes only a fixed set of named unit strings; SI prefix variants and pressure units such as `hg`, `hPa`, `mmHg` are **NOT registered** and trigger "Unknown unit 'X'". When uncertain whether a unit string is in the DataMiner registry, **suppress 2.9.7 with a reason** rather than guessing — an unrecognized string leaves an unresolvable validator remark.

Suppress 2.9.7 by wrapping the `<Display>` element:

```xml
<Param id="200" trending="true">
  <Name>portCount</Name>
  <Description>Port Count</Description>
  <Information>
    <Subtext>Total number of ports available on the device.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <!-- SuppressValidator 2.9.7 Dimensionless count, no unit applicable -->
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions>
      <Position>
        <Page>General</Page>
        <Row>6</Row>
        <Column>0</Column>
      </Position>
    </Positions>
  </Display>
  <!-- /SuppressValidator 2.9.7 -->
</Param>
```

**Reason templates** — adapt to the specific parameter:
- `Dimensionless count, no unit applicable`
- `Index parameter, no unit applicable`
- `Identifier parameter, no unit applicable`
- `Ratio value (0-1), no unit applicable`
- `Plain number parameter, no unit applicable`

### 2.5.1 — Missing alarm thresholds for monitored parameters without determinable defaults

When a monitored parameter has no reasonable default alarm thresholds (the threshold values depend entirely on the deployment context or no industry norm exists), suppress 2.5.1 by wrapping the `<Alarm>` element:

```xml
<Param id="400" trending="true">
  <Name>activeConnections</Name>
  <Description>Active Connections</Description>
  <Information>
    <Subtext>Number of currently active client connections on the device.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <!-- SuppressValidator 2.9.7 Dimensionless count, no unit applicable -->
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions>
      <Position>
        <Page>General</Page>
        <Row>5</Row>
        <Column>0</Column>
      </Position>
    </Positions>
  </Display>
  <!-- /SuppressValidator 2.9.7 -->
  <!-- SuppressValidator 2.5.1 Threshold depends on device capacity, no universal default -->
  <Alarm>
    <Monitored>true</Monitored>
  </Alarm>
  <!-- /SuppressValidator 2.5.1 -->
</Param>
```

When a parameter DOES have well-known thresholds, provide them instead of suppressing:

```xml
<Alarm>
  <Monitored>true</Monitored>
  <WaH>90</WaH>
  <MaH>95</MaH>
  <CH>99</CH>
</Alarm>
```

**Reason templates** — adapt to the specific parameter:
- `Threshold depends on device capacity, no universal default`
- `No industry-standard threshold for this metric`
- `Deployment-specific threshold, cannot provide meaningful default`
- `Counter value, no meaningful alarm threshold`

### 2.11.1 — Missing Range for number parameters

**ALWAYS add `<Display><Range>` when a determinable range exists — suppression is a last resort, not the default.**

Parameters with a determinable range include (but are not limited to): percentages (0–100), signal levels (e.g. dBm −120 to 0), speeds/rates with a device maximum, temperatures, utilisation ratios, and any parameter with a device-spec upper bound.

Only suppress 2.11.1 for parameters that are **genuinely unbounded** at design time: cumulative counters, cumulative totals, free-form numeric identifiers, and timestamps.

When a displayed number parameter truly has no determinable value range, suppress 2.11.1 by wrapping the `<Display>` element:

```xml
<Param id="300" trending="true">
  <Name>totalPacketsProcessed</Name>
  <Description>Total Packets Processed</Description>
  <Information>
    <Subtext>Cumulative number of packets processed since the last element restart.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <!-- SuppressValidator 2.9.7 Dimensionless count, no unit applicable -->
  <!-- SuppressValidator 2.11.1 Cumulative counter with no meaningful upper bound -->
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions>
      <Position>
        <Page>Statistics</Page>
        <Row>0</Row>
        <Column>0</Column>
      </Position>
    </Positions>
  </Display>
  <!-- /SuppressValidator 2.11.1 -->
  <!-- /SuppressValidator 2.9.7 -->
</Param>
```

When a parameter DOES have a well-known range, add it instead of suppressing:

```xml
<Display>
  <RTDisplay>true</RTDisplay>
  <Range>
    <Low>0</Low>
    <High>100</High>
  </Range>
</Display>
```

**Reason templates** — adapt to the specific parameter:
- `Cumulative counter with no meaningful upper bound`
- `Unbounded metric, no determinable range`
- `Free-form numeric identifier, range not applicable`
