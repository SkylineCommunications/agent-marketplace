# Groups, Timers, Triggers & Actions — Full Reference

Full XML examples, group types, ping group rules, timer design rules, trigger times, and action patterns.

## Groups

Groups define what to poll together in a single communication cycle.

```xml
<Groups>
  <Group id="1">
    <Name>General Poll</Name>
    <Description>General polling group</Description>
    <Type>poll</Type>
    <Content multipleGet="true">
      <Param>100</Param>
      <Param>101</Param>
      <Param>102</Param>
    </Content>
  </Group>
  <Group id="10" connection="1">
    <Name>HTTP Status</Name>
    <Type>poll</Type>
    <Content>
      <Session>10</Session>
    </Content>
  </Group>
</Groups>
```

### Group Types

| Type | Content Element | Use For |
|------|-----------------|---------|
| `poll` | `<Param>`, `<Pair>`, or `<Session>` | SNMP params, serial Pairs, **HTTP Sessions** |
| `poll action` | `<Action>` | Triggering XML Actions (NOT for HTTP sessions) |
| `poll trigger` | `<Trigger>` | Triggering XML Triggers |
| `action` | `<Action>` | Non-polling action execution |
| `trigger` | `<Trigger>` | Non-polling trigger execution |

> **Critical**: For HTTP polling, ALWAYS use `poll` type with `<Session>` content. NEVER use `poll action` for HTTP — `poll action` executes an XML `<Action>`, not an HTTP session.

**Rules:**
- Max **10 pairs/SNMP parameter references per group**. Each **SNMP table** in its own separate group.
- For SNMP poll groups containing **two or more scalar read parameters**, add `multipleGet="true"` on `<Content>` to poll them in a single SNMP GET request instead of individual requests. Omit it for a group with one scalar read parameter. Decide per group; do not copy the attribute to another group without counting its params.
- **CRITICAL — multipleGet on groups CANNOT be used for groups with table parameters in it.** Never set `multipleGet="true"` on any group containing a table parameter. `multipleGet` on `<Content>` is strictly reserved for groups containing 2+ scalar read parameters. For SNMP tables, retrieval methods are configured on the table parameter's `<SNMP><OID options="...">` tag (e.g. `options="instance;multipleGetBulk"` or `options="instance;multipleGetNext"`), never as `multipleGet` on the group.
- Count the direct `<Param>` references in each SNMP group after writing it. If one cadence has 11 scalar reads, split it into a group of 10 and a singleton group; only the group of 10 uses `multipleGet="true"`.
- Use the `connection` attribute on Groups to direct traffic to a specific connection (main = `0`, first advanced = `1`, etc.).

### Ping Group (Slow Poll / Timeout Recovery)

When an element enters timeout, DataMiner activates **slow poll mode**: normal polling stops and only a ping command is sent at regular intervals. When the device responds, normal polling resumes.

**How DataMiner selects the ping group:**
1. First, looks for a Group with `id="-1"`.
2. For serial: uses the Pair with `ping="true"`, or the lowest-ID pair containing a response.
3. For SNMP: uses the **first defined group** in the protocol (not necessarily the lowest ID).

```xml
<Pair id="1" ping="true">
   <Name>Ping</Name>
   <Content>
      <Command>1</Command>
      <Response>1</Response>
   </Content>
</Pair>
```

> **CRITICAL — NEVER place the After Startup group first in `<Groups>`**: The "After Startup" initialization group (`<Type>poll action</Type>`) is commonly generated as the first group because it runs on startup. This is **ALWAYS WRONG** for SNMP connectors — DataMiner selects the **first defined `<Group>`** (by XML position, not by `id` value) as the ping group, and a `poll action` group is not a valid SNMP ping group. This causes a MAJOR validator error ("Ping group for 'snmpv2' connection is not a 'snmpv2' poll group") **and** RTEs at runtime. **ALWAYS assign `id="1"` to the scalar poll group and `id="2"` (or higher) to the After Startup group** — ascending ID ordering then guarantees the poll group is physically first in the XML.
>
> ```xml
> <Groups>
>   <Group id="1">
>     <Name>General Parameters</Name>
>     <Type>poll</Type>
>     <Content><Param>10</Param></Content>
>   </Group>
>   <Group id="2">
>     <Name>After Startup</Name>
>     <Type>poll action</Type>
>     <Content><Action>1</Action></Content>
>   </Group>
> </Groups>
>
> <Groups>
>   <Group id="2">
>     <Name>After Startup</Name>
>     <Type>poll action</Type>
>     <Content><Action>1</Action></Content>
>   </Group>
>   <Group id="1">
>     <Name>General Parameters</Name>
>     <Type>poll</Type>
>     <Content><Param>10</Param></Content>
>   </Group>
> </Groups>
> ```

---

## Timers

Timers schedule when groups are polled.

```xml
<Timers>
  <Timer id="1">
    <Name>Fast Timer (10s)</Name>
    <Time initial="true">10000</Time>
    <Interval>75</Interval>
    <Content>
      <Group>1</Group>
    </Content>
  </Timer>
  <Timer id="2">
    <Name>Slow Timer (1m)</Name>
    <Time>60000</Time>
    <Interval>75</Interval>
    <Content>
      <Group>2</Group>
      <Group>3</Group>
    </Content>
  </Timer>
</Timers>
```

- `<Time>` is in milliseconds. `initial="true"` causes polling immediately on startup.
- `<Interval>` is the spacing (ms) between groups within the same timer cycle.
- Timer threads start during element initialization, so recurring poll groups are scheduled by their timers; do not also enqueue those groups from after-startup logic (the after-startup chain can still be used for one-time initialization). Use `initial="true"` when the first poll must happen immediately.

### Timer Design Rules

- Keep the number of timers **as low as possible** — each creates an additional thread.
- **Tiered Polling Cadences (Universal across SNMP, HTTP, Serial, etc.)**:
  Never poll all data in a single fast timer. Group polling into at least two distinct tiers:
  - **Fast Timer (e.g., 10s–30s, or up to 60s)**: High-churn operational telemetry, live device metrics, active operational states, alarms, dynamic tables, and uptime counters.
  - **Slow Timer (e.g., 10m–1h, with `<Time initial="true">`)**: Static, asset, or slow-changing data that rarely if ever changes during runtime. Examples across all protocol types: system description, manufacturer/vendor, model, serial number, firmware/software versions, hardware revisions, MAC addresses, phase/port counts, license limits, contact/location metadata, or non-critical static configuration.
  Rapidly polling static asset data wastes network bandwidth and device/DataMiner CPU.
- Default timer speeds: alarm/status = **10s**, config = **1min** (`dataDisplay` = 30000), static = **1hr**.
- Default interval: **75 ms**.
- Timer interval must allow **all groups to complete** before the timer triggers again.
- Timer interval cannot exceed **24 hours**. Set timer time cannot exceed **24 days**.
- **Favor conditions over starting/stopping timers**. Condition on group > condition on timer.
- If a timer contains poll groups, the **last group** must also be a poll group.
- Timers with only non-poll groups: **disabled by default**, started from after-startup logic.
- Use `relativeTimers="true"` on `<Type>`.

---

## Triggers

Triggers react to protocol events and execute actions.

```xml
<Triggers>
  <Trigger id="1">
    <Name>On Response Group 1</Name>
    <On id="1">group</On>
    <Time>after</Time>
    <Type>action</Type>
    <Content>
      <Id>1</Id>
    </Content>
  </Trigger>
  <Trigger id="10">
    <Name>On Param 100 Change</Name>
    <On id="100">parameter</On>
    <Time>change</Time>
    <Type>action</Type>
    <Content>
      <Id>10</Id>
    </Content>
  </Trigger>
</Triggers>
```

### Trigger Times

| Time | Description |
|------|-------------|
| `change` | When a parameter value changes |
| `after` | After a group/command completes |
| `before` | Before a group/command executes |
| `timeout` | On communication timeout |
| `each` | Every time (regardless of change) |

---

## Actions

Use `<Type>execute</Type>` for ordinary action-triggered group execution. Use
`<Type>execute next</Type>` only when the target group must run immediately after the current
item. Routine polling should be timer-scheduled, and after-startup logic must not re-queue a group
already assigned to a timer. The after-startup chain/sequence can still be used for one-time
initialization (such as executing an initialization group or triggering an After Startup QAction).

The validator rule below is conditional: it does not require an AfterStartup action for routine
poll groups already scheduled by timers.

```xml
<Actions>
  <Action id="1">
    <Name>Execute QAction 1</Name>
    <On>parameter</On>
    <Type>run actions</Type>
  </Action>
  <Action id="10">
    <Name>Run QAction 10</Name>
    <On id="10">QAction</On>
    <Type>execute</Type>
  </Action>
</Actions>
```

> **CRITICAL — AfterStartup actions MUST use `<On id="N">group</On>`**: Any `<Action>` that is referenced by an AfterStartup group (`<Type>poll action</Type>`) **MUST** have `<On id="N">group</On>` with `<Type>execute</Type>` to trigger a polling group on startup. The validator reports MAJOR **"After startup Action must have an On tag with value 'group'"** when the action uses any other `<On>` value. **NEVER** write an AfterStartup action with `<On>parameter</On>`, `<On>QAction</On>`, or any value other than `group`. The `id` attribute on `<On>` specifies which group ID to execute. Common mistake: writing `<On type="group" id="N">` (putting `type` as an XML attribute) — this causes **XSD ERROR** "The 'type' attribute is not declared" AND leaves the `<On>` text value empty, which also triggers the MAJOR validator finding.
>
> ```xml
> <Action id="1">
>   <Name>After Startup</Name>
>   <On id="2">group</On>
>   <Type>execute</Type>
> </Action>
>
> <Action id="1">
>   <Name>After Startup</Name>
>   <On>parameter</On>
>   <Type>run actions</Type>
> </Action>
>
> <Action id="1">
>   <Name>After Startup</Name>
>   <On type="group" id="2"></On>
>   <Type>execute</Type>
> </Action>
> ```
