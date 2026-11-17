# Groups And Timers Logic

Authority scope: this file explains group, timer, and polling behavior. It is not the XML schema reference. For valid XML children, attributes, enum values, and keyrefs, use `dataminer-connector-protocol-xml`.

## Groups

Groups bundle one homogeneous set of items for execution:

- Parameters.
- Pairs.
- Actions.
- Sessions.
- Triggers.

A group executes its items sequentially. Mixed group content is an XML schema concern and is covered by the XML reference, but the runtime consequence is also important: DataMiner treats the group as one execution unit and waits for linked logic to finish before the group is considered complete.

## Group Types

| Group type | Timer-run behavior |
|---|---|
| `poll` | Queued on the protocol thread. |
| `poll action` | Queued on the protocol thread. |
| `poll trigger` | Queued on the protocol thread. |
| `action` | Executed immediately by the timer thread. |
| `trigger` | Executed immediately by the timer thread. |

From actions/triggers, the distinction between `poll action` and `action`, or `poll trigger` and `trigger`, is not the same as timer execution; queued execution through actions still goes through the group queue.

Prefer queued poll groups unless explicit parallel timer-thread execution is needed.

## Timer Behavior

Timers define which groups are scheduled and how often scheduling is attempted. In DataMiner, `<Timer>` has two distinct timing elements:

- **`<Time>` (Polling Cycle / Period)**: Specifies how frequently the timer fires (in ms) to add its groups to the queue (e.g. 10000 = every 10 seconds). This dictates the polling frequency.
- **`<Interval>` (`Timer.Interval`) (Inter-Group Spacing Delay)**: Specifies the delay (in ms) between consecutive groups within the same timer cycle, as well as between consecutive pairs within a group. Default is 75 ms.

Key behavior:
- Every timer creates a timer thread.
- The timer cycle time (`<Time>`) controls how frequently groups are queued, not exact execution time.
- Actual execution depends on queue state and execution time of earlier work.
- Timer content groups execute in the order listed by the timer, separated by the `<Interval>` delay.
- Groups can interleave with work from other timers, external SETs, triggers, and actions.

If a timer's last group is a poll-style group, the timer waits for the previous iteration to finish before adding that group again. This prevents queue overflow when execution takes longer than the timer cycle time (`<Time>`).

Avoid a non-poll final group in regular timers; it can make the timer appear idle too early and cause queue or stack flooding.

### Rate Limiting, Request Pacing, and Load Control (<Interval> vs <Time>)

When an external device or HTTP API is under high processing load or returning call failures due to a high volume of requests or bursts:

- **When reducing polling is not an option**: If operational requirements mandate that data cannot be polled less frequently (i.e. increasing `<Time>` is not permitted), the correct solution is to **increase `Timer.Interval`** (the `<Interval>` element in `<Timer>`).
  - Increasing `Timer.Interval` (e.g. from 75 ms to 250 ms or 500 ms) inserts a larger delay between consecutive groups/requests within that timer run.
  - This spaces out the calls evenly over the polling cycle, eliminating request bursts and giving the external API processing headroom without reducing the polling rate or dropping any metrics.
- **Why reducing the number of groups is WRONG**:
  - Keeping the same number of sessions while reducing the number of groups does not reduce the number of HTTP calls (each session still issues its HTTP request).
  - Because `Timer.Interval` is the spacing delay applied *between groups*, reducing the number of groups removes pacing delays and causes sessions in the same group to execute in immediate succession with zero inter-group delay. This intensifies the request burst and worsens device overload.
  - Decreasing `Timer.Interval` is also wrong because it shortens the delay between requests, accelerating the burst.
  - DataMiner does not have an automatic built-in load balancing mechanism for external HTTP APIs; pacing must be configured via `Timer.Interval`.

### Polling During Startup

Timer threads start during element initialization, and timers with `<Time initial="true">` will
immediately queue their groups. Therefore, do not use the after-startup trigger/action chain to poll
data that will be retrieved through a timer. The after-startup chain can still be used for one-time
element initialization (e.g. running an initialization QAction or setting initial state), but
routine polling groups should be managed by their timers.

## Race Conditions

Non-poll timer groups execute on timer threads and can read or write state while the protocol thread is processing other work. This can cause race conditions, especially with helper parameters and shared QAction state.

Use a buffer group with queued execution when ordering matters:

- Timer runs a lightweight action group.
- That group uses an execute action to queue the real work.
- The real work runs on the protocol thread in a predictable order.

## Polling Patterns

### SNMP Polling

- SNMP scalar polling places parameter IDs in groups and schedules those groups with timers.
- Keep each SNMP poll group to at most 10 parameter references. Split larger sets at the group
  boundary before authoring XML.
- Multiple scalar OIDs can be retrieved in one SNMP Get request when the group is configured for
  multiple get behavior. Configure this per group: enable it for 2+ scalar reads and omit it for a
  singleton or a table group; do not copy the setting across groups.
- **multipleGet on groups CANNOT be used for groups with table parameters in it.** It is strictly reserved for groups with 2+ scalar parameters. Table retrieval methods (such as `multipleGetBulk` or `multipleGetNext`) are configured on the table parameter's `<SNMP><OID options="...">` tag, never on the `<Group>` element.
- If no explicit ping group exists, DataMiner uses the first parameter from the first group defined in the protocol, not the lowest group ID.
- The first SNMP group should therefore be a valid polling group, not a poll action or trigger group.
- SNMPv1 multiple get fails the entire response on `noSuchName`; SNMPv2/SNMPv3 can still return available variables.

### HTTP Polling

- HTTP polling executes HTTP sessions through groups containing session references.
- A timer schedules the group; the group sends one or more HTTP sessions.
- Use poll groups for ordinary HTTP request/response polling.
- Plain HTTP polling does not use serial command/response/pair structures.
- HTTP 4xx (client errors), 5xx (server errors), and 6xx (system errors) responses always contribute to Element Timeout behavior. 1xx and 2xx do not cause timeout, while 3xx redirects automatically when a `Location` header is present (unless customRedirect is configured).
- HTTP 3xx redirects are followed automatically when a `Location` header is present unless custom redirect behavior is configured.
- Placing multiple groups in the protocol execution queue one after another to send out different HTTP requests that use the same `<Session>` definition does **not** cause all generated sessions to be identical with only the last values set on session parameters. Each request is composed for its respective group execution.

### Serial Polling

- Serial polling executes pairs through groups.
- A pair binds a command to zero, one, or multiple responses.
- Limit pairs per group to avoid long blocking execution.
- Multiple responses in a pair are matched in response order.

### WebSocket Polling

- WebSocket connection setup is HTTP-based.
- WebSocket message exchange uses command/response/pair behavior.
- Request/response WebSocket patterns use pairs with command and response.
- Push-message WebSocket patterns can use command-only pairs and classify incoming responses independently.

## Ping Behavior

In DataMiner connectors, "ping" serves two distinct purposes:

### 1. Element Wizard Connection Testing (`ping="true"`)
- Allows users to test communication settings (e.g. IP address, port, credentials) in the Element Creation or Update Wizard **before creating or saving the element**.
- Configured by setting the attribute `ping="true"` on a polling group (or `<Pair ping="true">` in serial):
  ```xml
  <Group id="10" ping="true">
    <Name>Test Connection</Name>
    <Type>poll</Type>
    <Content>
      <Session>10</Session>
    </Content>
  </Group>
  ```
- If a group with `ping="true"` is defined, the **Test connection** button in the Element Wizard is enabled. Clicking it executes the designated group against the entered IP address. If no group has `ping="true"`, the button is disabled.

### 2. Slow Poll Mode / Timeout Recovery (Running Elements)
- Used after element creation when an element loses communication and enters timeout: normal timers stop and only a recovery ping group runs at regular intervals.
- Selection rules:
  - **HTTP**: Uses the group with `id="-1"` containing a lightweight session.
  - **SNMP**: Uses the **first defined group** in `protocol.xml` (must be a valid SNMP poll group, not After Startup).
  - **Serial**: Uses the pair with `ping="true"`, or the lowest-ID pair containing a response.
- Slow poll mode ping behavior only applies to the main connection.

## Multithreaded Timers

Multithreaded timers are a specialized polling model.

- They require documented options such as IP/table targeting, per-row scheduling, and thread-pool sizing.
- They must contain a group of type `poll` so DataMiner can detect the connection family.
- Group conditions and before-group triggers are not supported in multithreaded timer execution.
- Use queue size, polling rate, and thread-pool settings to control load.
- SNMP parameters in multithreaded SNMP groups require documented load-OID behavior.
- HTTP/serial multithreaded requests require documented before/after QAction patterns.

## Timer Control Actions

Timer control actions can start, stop, restart, or reschedule timers.

- `restart timer` stops the timer, removes its groups from the queue, and starts it again.
- Rescheduling changes the timer interval.
- Stopping a timer prevents future scheduling but does not necessarily cancel work that is already executing.

## Conditions On Groups And Timers

- Group conditions are evaluated when the group executes, not when it is added to the queue.
- Timer conditions are evaluated when the timer fires.
- Prefer group conditions over timer conditions when the intent is to skip work at execution time.
- In multithreaded timer execution, group conditions are not supported.

## Load Control

- Separate timers by polling frequency: fast, normal, slow, and maintenance-style polling.
- Keep group execution short.
- Use `<Interval>` (`Timer.Interval`) to pace groups across the polling cycle when communicating with rate-limited or high-load devices and APIs, especially when reducing polling frequency (`<Time>`) is not an option.
- Use the queue-control actions described in `logic-triggers-actions.md` when repeated triggers can flood the queue.
- Avoid long network timeouts on high-frequency timers.
- Avoid frequent updates to DCF-generating tables because they can trigger heavy interface alarm recalculation.
