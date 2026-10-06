# Execution Patterns (Timers, Triggers, Actions)

Worked authoring patterns for `<Timers>`, `<Triggers>`, and `<Actions>` beyond the basic poll-timer / parameter-change-trigger shown in the SKILL.md body. For the schema vocabulary (allowed tags, attributes, enum values, parent/child placement) load `dataminer-protocol-xml-reference` → `references/protocol-execution.md`. For runtime behavior load `dataminer-connector-core/references/logic-triggers-actions.md`.

## Trigger Patterns

### Multiple-Parameter Trigger

One trigger firing on a change to any parameter in a semicolon-separated list:

```xml
<Trigger id="2">
  <Name>On Any Config Change</Name>
  <On id="100;101;102">parameter</On>
  <Time>change</Time>
  <Type>action</Type>
  <Content>
    <Id>5</Id>
  </Content>
</Trigger>
```

### Timeout Trigger

Reacts when the connection times out after its configured retries:

```xml
<Trigger id="10">
  <Name>On Communication Timeout</Name>
  <On>communication</On>
  <Time>timeout after retries</Time>
  <Type>action</Type>
  <Content>
    <Id>100</Id>
  </Content>
</Trigger>
```

### Response Trigger

Fires after a specific response is received (serial/HTTP framing):

```xml
<Trigger id="20">
  <Name>After Response</Name>
  <On id="1">response</On>
  <Time>after</Time>
  <Type>action</Type>
  <Content>
    <Id>10</Id>
  </Content>
</Trigger>
```

### Conditional Trigger

Runs its action only when the condition evaluates true:

```xml
<Trigger id="30">
  <Name>Conditional Update</Name>
  <On id="100">parameter</On>
  <Time>change</Time>
  <Type>action</Type>
  <Content>
    <Id>1</Id>
  </Content>
  <Condition><![CDATA[(id:100 > 0)]]></Condition>
</Trigger>
```

### Chained Triggers

A trigger whose `<Type>trigger</Type>` activates a second trigger, which then runs the action — useful for sequencing:

```xml
<Trigger id="40">
  <Name>Chain Step 1</Name>
  <On id="100">parameter</On>
  <Time>change</Time>
  <Type>trigger</Type>
  <Content>
    <Id>41</Id>
  </Content>
</Trigger>

<Trigger id="41">
  <Name>Chain Step 2</Name>
  <On id="40">trigger</On>
  <Time>after</Time>
  <Type>action</Type>
  <Content>
    <Id>10</Id>
  </Content>
</Trigger>
```

### QAction Triggered via Parameter

A parameter change drives a QAction either directly (`triggers="<pid>"` on the `<QAction>`) or via an explicit trigger → action chain:

```xml
<QAction id="100" triggers="1000">
</QAction>

<Trigger id="100">
  <Name>Trigger QAction</Name>
  <On id="1000">parameter</On>
  <Time>change after response</Time>
  <Type>action</Type>
  <Content>
    <Id>100</Id>
  </Content>
</Trigger>

<Action id="100">
  <On id="100">parameter</On>
  <Type>run actions</Type>
</Action>
```

## Timer Patterns

### After-Startup Timer (`loop`)

A timer with `<Time initial="0">loop</Time>` runs its content once on startup — common for an initialization group:

```xml
<Timer id="10">
  <Name>After Startup</Name>
  <Time initial="0">loop</Time>
  <Content>
    <Group>1</Group>
  </Content>
</Timer>
```

### Staggered Poll (per-group delays)

`waitTime` on a `<Group>` inside a timer spaces the groups apart within one cycle — useful to avoid bursting a device:

```xml
<Timer id="5">
  <Name>Staggered Poll</Name>
  <Time>5000</Time>
  <Interval>100</Interval>
  <Content>
    <Group>1</Group>
    <Group waitTime="500">2</Group>
    <Group waitTime="500">3</Group>
  </Content>
</Timer>
```

> Keep the number of timers as low as possible (each is a thread). See the **Timers** section in the SKILL.md for the timer-design rules and default speeds.
