# Groups And Timers Logic

Authority scope: this file explains group, timer, and polling behavior. It is not the XML schema reference. For valid XML children, attributes, enum values, and keyrefs, use `dataminer-protocol-xml-reference`.

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

Timers define which groups are scheduled and how often scheduling is attempted.

- Every timer creates a timer thread.
- The timer interval controls when groups are queued, not exact execution time.
- Actual execution depends on queue state and execution time of earlier work.
- Timer content groups execute in the order listed by the timer.
- Groups can interleave with work from other timers, external SETs, triggers, and actions.

If a timer's last group is a poll-style group, the timer waits for the previous iteration to finish before adding that group again. This prevents queue overflow when execution takes longer than the timer interval.

Avoid a non-poll final group in regular timers; it can make the timer appear idle too early and cause queue or stack flooding.

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
- HTTP 4xx and 5xx responses cause timeout behavior.
- HTTP 3xx redirects are followed automatically when a `Location` header is present unless custom redirect behavior is configured.

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

- HTTP ping groups should reference valid HTTP sessions.
- SNMP ping behavior falls back to the first valid polling group when no explicit ping group exists.
- Serial ping behavior depends on pair ping settings or the first valid pair containing a response.
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
- Use the queue-control actions described in `logic-triggers-actions.md` when repeated triggers can flood the queue.
- Avoid long network timeouts on high-frequency timers.
- Avoid frequent updates to DCF-generating tables because they can trigger heavy interface alarm recalculation.
