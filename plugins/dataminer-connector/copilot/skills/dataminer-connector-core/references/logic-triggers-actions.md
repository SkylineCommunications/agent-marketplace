# Triggers And Actions Logic

Authority scope: this file explains trigger and action runtime behavior. It is not the XML schema reference. For valid trigger/action XML structure and enum values, use `dataminer-protocol-xml-reference`.

## Triggers

A trigger defines when logic activates and what content it activates.

Runtime activation sources include parameters, commands, responses, pairs, groups, timers, sessions, protocol events, and communication events. The exact XML values are schema-controlled; the behavior is:

- Parameter triggers react to parameter change events.
- Group, pair, command, response, session, and timer triggers react to lifecycle moments such as before, after, timeout, or success.
- Protocol triggers include startup and link-file events.
- A trigger can execute actions or other triggers.

QAction-triggered `CheckTrigger` blocking behavior is owned by `logic-qactions.md`.

## Change-Triggered Logic

- Same-value updates from QActions trigger parameter change logic.
- Same-value updates from protocol constructs generally do not.
- Use a clear action when repeated identical incoming values must activate logic again.
- `On id="each"` behavior is a fallback pattern for items without a more specific trigger; use specific triggers when possible.

## After-Startup Pattern

After-startup triggers run before the element is fully operational. Heavy work should not execute directly in the startup trigger.

Recommended runtime flow for initialization:

1. After-startup trigger fires.
2. Trigger executes an action (`<On id="N">group</On>`).
3. Action queues an initialization group (`<Type>poll action</Type>`).
4. Group runs when the protocol thread is ready.
5. Group executes real initialization logic (e.g. running actions on an initialization parameter to trigger an After Startup QAction).

The after-startup chain/sequence can still be used whenever one-time initialization is needed.
However, **do not use it to actually poll data at the start of an element if that same data will be
retrieved through a timer**. For routine data polling, let the timer manage the schedule and set
`<Time initial="true">` on the timer if an immediate first poll is required. For ordinary
action-triggered group execution, use `execute`; reserve `execute next` for cases that require the
target group to run immediately after the current item.

## Actions

An action defines where to operate and what operation to perform.

Action behavior groups:

- Queue actions add groups to different queue positions.
- Parameter actions copy, clear, increment, multiply, normalize, save, set, run QActions, or otherwise transform values.
- Timer actions start, stop, restart, or reschedule timers.
- Communication actions open, close, lock, unlock, and priority-lock communication.
- Command/response actions make commands, read responses, calculate CRC/length, replace bytes, and process stuffing.
- Other actions include aggregation, merging, file reading, swapping columns, WMI execution, and stopping current groups.

Not every action type is valid for every target. XML validity belongs in the schema reference; semantic support belongs in official action behavior and validator results.

## Queue-Affecting Actions

| Action | Runtime behavior |
|---|---|
| `execute next` | Queue target group immediately after current item. |
| `execute one top` | Queue target group immediately after current item only if not already queued. |
| `execute` | Queue target group before timer-added groups. |
| `execute one now` | Queue before timer-added groups only if not already queued. |
| `add to execute` | Queue target group after timer-added groups. |
| `execute one` | Queue after timer-added groups only if not already queued. |
| `force execute` | Interrupt current group after current item, execute target group, then resume. |

Use `execute one` variants when repeated activation can flood the queue. Use `force execute` only in exceptional cases.

## Blocking Behavior

- Direct trigger/action chains block until linked logic finishes.
- Trigger/action chains that only queue a group return once the group is queued.
- Long chains block entry points and delay other work.
- Prefer queued groups for long or lower-priority operations.

## SNMP Set Behavior

- SNMP write parameters can use set behavior patterns.
- DataMiner can update the local read parameter optimistically after a set.
- Author a fast get or refresh after SNMP sets when confirmation matters.
- Multiple SNMP sets require an action of type `set` on a group with more than one write parameter.
- Dynamic SNMP get is intended for trap-driven or OID-driven refresh, not as post-set verification by itself.

## Serial Command/Response Actions

Serial and smart-serial protocols use actions to build, read, and validate frames.

- Commands and responses are ordered parameter sequences.
- Pairs bind commands to responses.
- Responses with variable-length fields need read actions before response parsing can complete.
- Length validation requires explicit length actions.
- CRC calculation and validation require explicit CRC actions; declaring a CRC parameter is not enough.
- When length validation must cancel response processing, the length action must be last in the trigger.
- Reused or repeated responses may need clear actions to avoid stale values.

## makeCommandByProtocol

When `makeCommandByProtocol` is enabled:

- Automatic make actions are not executed.
- A before-command each trigger must run an explicit make command action.
- Before-command triggers execute before the group is added to the queue and before before-group triggers.

## Communication Actions

- Open/close actions control port state.
- Lock/unlock actions control exclusive port access.
- Priority lock/unlock is used when priority communication must temporarily take over.
- Break-signal designs use separate connections and explicit open/lock/unlock/pair behavior.

## Action/Trigger Design Rules

- Keep chains short.
- Prefer XML conditions when a simple condition can avoid a QAction.
- Use queued execution to isolate long work.
- Avoid sleep on protocol-critical paths.
- Use `run actions` on a parameter when the goal is to trigger QActions tied to that parameter.
