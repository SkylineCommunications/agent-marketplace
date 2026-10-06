# Rate Calculation XML Structure

Rate calculations convert incrementing counters (octets, packets, errors) into per-second rates. Every rate needs a **parameter triple**: Counter + Rate + Buffer Data.

> For the C# implementation patterns (helper classes, Custom/SNMP patterns), see `dataminer-qaction/references/rate-calculations.md`.

## Standalone Rate Parameter Triple

```xml
<Param id="500" trending="true">
  <Name>Counter</Name>
  <Description>Counter</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
</Param>

<Param id="501" trending="true">
  <Name>CounterRate</Name>
  <Description>Counter Rate</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
    <Decimals>3</Decimals>
    <Exceptions>
      <Exception id="1" value="-1">
        <Display state="disabled">N/A</Display>
        <Value>-1</Value>
      </Exception>
    </Exceptions>
  </Interprete>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Units>Units/s</Units>
    <Decimals>3</Decimals>
  </Display>
</Param>

<Param id="502" trending="false">
  <Name>CounterRateData</Name>
  <Description>Counter Rate Data</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display>
    <RTDisplay>false</RTDisplay>
  </Display>
</Param>
```

## Table Rate Columns

In a table, rate columns follow the same triple pattern. Counter may be `type="snmp"` or `type="retrieved"` depending on source; rate and buffer are always `type="retrieved"`:

```xml
<Param id="1000">
  <Name>Streams</Name>
  <Type>array</Type>
  <ArrayOptions index="0">
    <ColumnOption idx="0" pid="1001" type="snmp" />
    <ColumnOption idx="1" pid="1002" type="snmp" />
    <ColumnOption idx="2" pid="1003" type="snmp" />
    <ColumnOption idx="3" pid="1004" type="retrieved" />
    <ColumnOption idx="4" pid="1005" type="retrieved" />
  </ArrayOptions>
</Param>

<Param id="1004" trending="true">
  <Name>StreamsBitRate</Name>
  <Description>Bit Rate (Streams)</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
    <Decimals>3</Decimals>
    <Exceptions>
      <Exception id="1" value="-1">
        <Display state="disabled">N/A</Display>
        <Value>-1</Value>
      </Exception>
    </Exceptions>
  </Interprete>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Units>bps</Units>
    <Decimals>3</Decimals>
  </Display>
</Param>

<Param id="1005" trending="false">
  <Name>StreamsBitRateData</Name>
  <Description>Bit Rate Data (Streams)</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display>
    <RTDisplay>false</RTDisplay>
  </Display>
</Param>
```

## SNMP Rate Additional Parameters

SNMP connectors need extra parameters per rate group for timeout handling and agent restart detection:

```xml
<Param id="491">
  <Name>CounterTimeoutTrigger</Name>
  <Description>Counter Timeout Trigger</Description>
  <Type>dummy</Type>
</Param>

<Param id="492">
  <Name>CounterGroupAfterRetries</Name>
  <Description>Counter Group After Retries</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Measurement>
    <Type>discreet</Type>
    <Discreets>
      <Discreet><Display>Success</Display><Value>0</Value></Discreet>
      <Discreet><Display>Timeout</Display><Value>1</Value></Discreet>
    </Discreets>
  </Measurement>
</Param>

<Param id="493">
  <Name>CounterAfterGroupTrigger</Name>
  <Description>Counter After Group Trigger</Description>
  <Type>dummy</Type>
</Param>

<Param id="494" trending="false">
  <Name>CounterSnmpAgentRestartFlag</Name>
  <Description>Counter SNMP Agent Restart Flag</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Measurement>
    <Type>discreet</Type>
    <Discreets>
      <Discreet><Display>Not Restarted</Display><Value>0</Value></Discreet>
      <Discreet><Display>Restarted</Display><Value>1</Value></Discreet>
    </Discreets>
  </Measurement>
</Param>
```

## Rate Parameter Naming Conventions

| Parameter Role | Name Pattern | Example |
|---------------|-------------|---------|
| Raw counter | `<Resource>Counter` or `<Resource>` | `StreamsOctetsCounter` |
| DateTime-based rate | `<Resource>RateOnDates` | `CounterRateOnDates` |
| TimeSpan-based rate | `<Resource>RateOnTimes` | `StreamsBitRateOnTimes` |
| SNMP rate (no suffix needed) | `<Resource>Rate` | `CounterRate` |
| Buffer data (DateTime) | `<Resource>RateOnDatesData` | `CounterRateOnDatesData` |
| Buffer data (TimeSpan) | `<Resource>RateOnTimesData` | `StreamsBitRateOnTimesData` |
| Buffer data (SNMP) | `<Resource>RateData` | `CounterRateData` |

---

## Rate Calculation Wiring

### Custom Pattern Wiring (HTTP/Serial/Virtual)

Simple: Timer → Group (poll action) → Action (run actions) → QAction.

```xml
<Timer id="1">
  <Name>Fast Timer (10s)</Name>
  <Time initial="true">10000</Time>
  <Interval>75</Interval>
  <Content>
    <Group>90</Group>
    <Group>990</Group>
  </Content>
</Timer>

<Group id="90">
  <Name>Fill Counter</Name>
  <Type>poll action</Type>
  <Content>
    <Action>90</Action>
  </Content>
</Group>

<Action id="90">
  <Name>Counter Calculate Rate</Name>
  <On id="90">parameter</On>
  <Type>run actions</Type>
</Action>

<QAction id="90" name="CounterProcessingQAction" encoding="csharp" triggers="90">
</QAction>
```

### SNMP Pattern Wiring

SNMP wiring is more complex — it handles timeouts and agent restart detection.

**Execution flow:**
1. Timer executes a `poll action` group that runs `execute next` on sysUptime poll + counter poll groups
2. **Before-group trigger** resets the timeout flag to 0
3. If poll succeeds → **after-group trigger** (conditioned on timeout flag = 0) → rate calculation QAction
4. If poll times out → **timeout trigger** → buffer delta QAction; **timeout-after-retries** → sets flag to 1

```xml
<Timer id="1">
  <Name>Fast Timer (10s)</Name>
  <Time initial="true">10000</Time>
  <Interval>75</Interval>
  <Content>
    <Group>501</Group>
  </Content>
</Timer>

<Action id="501">
  <Name>SysUptimeAndCounter ExecuteNext</Name>
  <On id="500;1">group</On>
  <Type>execute next</Type>
</Action>

<Group id="501">
  <Name>Poll System Uptime And Counter</Name>
  <Type>poll action</Type>
  <Content>
    <Action>501</Action>
  </Content>
</Group>

<Group id="500">
  <Name>Poll Counter</Name>
  <Type>poll</Type>
  <Content><Param>500</Param></Content>
</Group>

<Group id="1">
  <Name>System Uptime</Name>
  <Type>poll</Type>
  <Content><Param>100</Param></Content>
</Group>

<Trigger id="490">
  <Name>CountersBeforeGroup</Name>
  <On id="500">group</On>
  <Time>before</Time>
  <Type>action</Type>
  <Content><Id>490</Id></Content>
</Trigger>

<Action id="490">
  <Name>Counter Timeout After Retries Flag Reset</Name>
  <On id="492">parameter</On>
  <Type id="10">copy</Type>
</Action>

<Trigger id="491">
  <Name>CountersTimeout</Name>
  <On id="500">parameter</On>
  <Time>timeout</Time>
  <Type>action</Type>
  <Content><Id>491</Id></Content>
</Trigger>

<Action id="491">
  <Name>Counter Timeout Run Action</Name>
  <On id="491">parameter</On>
  <Type>run actions</Type>
</Action>

<Trigger id="492">
  <Name>CountersTimeoutAfterRetries</Name>
  <On id="500">parameter</On>
  <Time>timeout after retries</Time>
  <Type>action</Type>
  <Content><Id>492</Id></Content>
</Trigger>

<Action id="492">
  <Name>Counter Timeout After Retries Flag</Name>
  <On id="492">parameter</On>
  <Type id="11">copy</Type>
</Action>

<Trigger id="493">
  <Name>CountersAfterGroup</Name>
  <On id="500">group</On>
  <Time>after</Time>
  <Condition><![CDATA[id:492 == 0]]></Condition>
  <Type>action</Type>
  <Content><Id>493</Id></Content>
</Trigger>

<Action id="493">
  <Name>Counter Calculate Bit Rates</Name>
  <On id="493">parameter</On>
  <Type>run actions</Type>
</Action>
```

> **Repeat this pattern** for each rate group (standalone counters, table rates). The timeout QAction calls `BufferDelta()`, the after-group QAction calls `Calculate()`. Both share the same `SnmpRate32` helper via the buffer parameter.
