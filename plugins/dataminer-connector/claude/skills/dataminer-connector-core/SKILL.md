---
name: dataminer-connector-core
description: Foundation skill for all DataMiner connector tasks. Explains what DataMiner is, how connectors fit into the platform, how a connector executes at runtime, and routes to the right specialist skill for any task. Load this skill first — always.
argument-hint: 'Describe the task or question: e.g. "implement HTTP polling", "write a QAction", "create a new connector", "understand parameter change events"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-05
  version: 4.5
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-dataapi`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-dataapi`: Alternative dynamic-element route without a protocol.xml; outside connector authoring.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 4.5 | 2026-10-05 | Added review checklist item for discrete parameters with numeric backend for pre-known values. |
| 4.4 | 2026-10-02 | Corrected canonical SNMP writes and SNMP/HTTP timer-driven polling examples; clarified startup scheduling. |
| 4.3 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 4.2 | 2026-09-17 | Corrected QAction API ownership and made generated QAction helper use conditional. |
| 4.1 | 2026-09-17 | Added the SecureCoding runtime package and aligned canonical JSON parsing with SLC_SC0004/SLC_SC0005 guidance. |
| 4.0 | 2026-09-17 | Corrected the canonical HTTP/SNMP examples to the current namespace and root marker, removed unnecessary non-alarmable Alarm blocks, and added schema-validated complete example files. |
| 3.9 | 2026-09-17 | Added explicit first-release profile selection, external checklist/evidence context, row-level developer feedback, snippets, and separate release-readiness reporting to the reusable connector review prompt; replaced removed connector guide URLs and removed an invalid sibling-repository review-prompt link. |
| 3.8 | 2026-06-17 | Routing: added `dataminer-dmprotocol-packaging` (create a `.dmprotocol` from a classic connector solution) and `dataminer-dataapi` (push data into a name-addressable dynamic element via the local DataAPI HTTP feature, with the fixed-PID caveat). |
| 3.6 | 2026-06-11 | Added a routing shortcut for Automation-script + QAOps tasks (no protocol.xml authoring): go straight to `dataminer-idms` + `dataminer-qaops`; the connector logic references are not needed. |
| 3.5 | 2026-06-10 | Added QAOps routing for running `.dmtest` packages and authoring real DataMiner integration tests. |
| 3.4 | 2026-05-14 | Added `dataminer-dis` routing for code-relevant Visual Studio workflows. |
| 3.3 | 2026-05-14 | Added `dataminer-sdk` routing for official Skyline SDK/templates/CLI/Dev Pack usage. |
| 3.2 | 2026-05-14 | Removed conventions reference from core. XML schema authority now lives in `dataminer-protocol-xml-reference`;
| 3.1 | 2026-05-08 | Added Hard Rules (anti-hallucination) section. Added glossary, canonical SNMP example, canonical HTTP example, and connector review prompt to reference table. Added canonical QAction example to dataminer-qaction skill. |
| 3.0 | 2026-04-21 | Restructured from conventions-only to DataMiner overview + skill router. Moved all conventions to `references/conventions.md`. Absorbed 5 logic reference files from dataminer-xsd-reference (conditions, groups-timers, parameters, qactions, triggers-actions). |
| 2.2 | 2026-04-19 | Strengthened parameter Name character rule. |
| 2.1 | 2026-04-18 | Clarified Parameter ID Conventions. |
| 2.0 | 2026-04-13 | Reduced connection-specific constraints in core. |

---

# DataMiner Connector Core

## What is DataMiner?

DataMiner is a **network management and monitoring platform** by Skyline Communications. It provides:

- **Unified monitoring** of any device, system, or service — regardless of vendor or protocol
- **Element management**: each monitored device is an *element*, defined by a *connector* (also called a protocol or driver)
- **Alarming & trending**: automatic alarm detection, history trending on any parameter
- **Automation**: scripting engine for workflows, provisioning, and service orchestration
- **Visualization**: dashboards, Visio-based topology maps, web interface
- **Correlation**: cross-element alarm correlation and root cause analysis
- **DCF** (DataMiner Connectivity Framework): physical and logical connectivity modeling

DataMiner runs as a set of cooperating Windows services (`SLDataMiner`, `SLProtocol`, `SLScripting`, `SLElement`, `SLNet`, etc.). Elements are distributed across `SLProtocol` instances. QAction C# code runs inside the 32-bit `SLScripting` process.

---

## What is a Connector?

A connector is an **XML + C# package** that teaches DataMiner how to communicate with a specific device or API. It defines:

- **Parameters**: every data point (read values, write controls, tables, internal state)
- **Communication**: how to talk to the device — HTTP sessions, SNMP OID mappings, serial commands/responses, WebSocket frames, SSH scripts
- **Logic**: timers to schedule polling, groups to batch work, triggers/actions to react to events, QActions for C# code
- **UI**: page layout, table display, alarm thresholds, trending configuration

A connector is a single `protocol.xml` file (DPML — DataMiner Protocol Markup Language), accompanied by one or more C# QAction `.csproj` files compiled into DLLs.

### Connection Types

| Type | Use When |
|------|----------|
| **HTTP/HTTPS** | REST APIs, SOAP services, web interfaces |
| **SNMP v1/v2c/v3** | Network devices exposing MIB |
| **Serial** | Fixed-frame request/response protocols |
| **Smart-serial** | Stream-based protocols, unsolicited data |
| **WebSocket** | Persistent bidirectional connections |
| **SSH** | CLI-based devices |
| **Virtual** | No device connection, internal logic only |

---

## Hard Rules (Anti-Hallucination)

These rules apply to **every** connector task. Automatic instruction attachment depends on
the client and installation. Load `dataminer-protocol-xml-reference` for XML and
`dataminer-qaction` for C#, including their linked guard rails, whether or not rules are attached.

> **Do NOT invent XML elements or attributes.** Fetch the schema docs first: `https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.{element.path}.html`. An element that "looks right" but isn't in the schema causes XSD validation failures.

> **Do NOT invent SLProtocol API methods or misclassify their owner.** `FillArray`, `FillArrayNoDelete`, `FillArrayWithColumn`, `SetRow`, `AddRow`, `DeleteRow`, and `CheckTrigger` are built-in `SLProtocol` members. `GetColumns` and `SetColumns` are extension methods from `Skyline.DataMiner.Utils.Protocol.Extension`. Generated `SLProtocolExt` adds connector-specific typed properties/table wrappers; it is not required for the built-in calls.

> **Do NOT invent NuGet packages.** Only use packages listed in `references/nuget-packages.md`.

> **Do NOT guess device behavior, OIDs, or API response formats.** Explicitly state what information is missing and ask. Never assume an OID, endpoint URL, or JSON field name.

> **If context is missing, say so.** Never fill in unknowns with plausible-sounding values.

> **Prefer canonical examples over invention.** Load `references/example-snmp-connector.md`, `references/example-http-connector.md`, or `dataminer-qaction/references/example-json-table.md` and follow them exactly.

> **Always verify against the official documentation.** Documentation links are in the table at the bottom of this file.

---

## How a Connector Executes (Runtime Flow)

Understanding this flow is essential for every connector task.

### The Core Loop

```
Timers
  │
  ▼  (every N ms, add groups to queue)
Group Execution Queue   ◀── also fed by: triggers, actions, user SETs, after-startup
  │
  ▼  (protocol thread dequeues one group at a time)
Group
  │
  ├── Poll group  →  Parameters  →  SNMP OID / Serial command / HTTP session
  ├── Action group  →  Actions  →  copy, increment, run QAction, execute group…
  └── Trigger group  →  Triggers  →  chain to more actions
          │
          ▼  (response received)
       Parameters set  →  change events fire  →  triggers/QActions react
```

### Key Concepts

| Concept | What It Does |
|---------|-------------|
| **Parameter** | Named data slot. Stores a value. Changing it fires change events. |
| **Timer** | Thread that fires every N ms, adds groups to the queue. |
| **Group** | Batch of same-type items (params, pairs, sessions, actions, triggers). Executed sequentially. |
| **Pair** | Serial command + response matched together. |
| **Session** | HTTP session (request + response). |
| **Trigger** | WHEN something happens → WHAT to do (fire actions or other triggers). |
| **Action** | Atomic operation: copy value, execute group, run QActions, start/stop timer, SNMP set… |
| **QAction** | C# code block. Runs in SLScripting. Triggered by parameter change events. |
| **Condition** | Boolean expression on parameter values. Controls whether element/trigger/group executes. |

### Threading Model (summary)

- Each element has one **protocol thread** processing the group queue sequentially.
- Each timer definition spawns its own **timer thread**. `poll*` groups → queued. `action`/`trigger` groups → execute on timer thread directly (enables parallelism, but beware race conditions).
- External SETs (UI, automation) arrive via **SLDataMiner's SetParam thread** and transfer to the protocol thread.
- QActions run on **SLScripting**, a separate 32-bit process. Each `SLProtocol` method call from a QAction is inter-process communication — minimize them.

> For full detail: load `references/logic-execution-flow.md`

### Startup Sequence

1. Parameters, timers, groups, triggers, actions, QActions, and sessions are initialized
2. Stored parameter values and templates are loaded
3. Timer threads start
4. Protocol thread starts
5. **After-startup triggers run** before the element is fully operational — this chain can still be used for one-time initialization (such as executing an initialization QAction, setting initial state, or running an initialization action group)
6. The protocol queue processes work and the element becomes operational

> **After-Startup vs. Timer Polling**: The after-startup chain can still be used for one-time initialization, but **never use it to poll data at the start of an element if that same data will be retrieved through a timer**. Routine polling groups are managed automatically by their timers (use `<Time initial="true">` on the timer when an immediate first poll is needed). Reserve after-startup triggers/actions for one-time setup logic. See `logic-execution-flow.md#after-startup-pattern` and `logic-triggers-actions.md#after-startup-pattern`.

---

## Skill Routing Table

Use this table to decide which skill(s) to load for a task.

| Task | Load Skill(s) |
|------|---------------|
| Create a new connector from scratch | `dataminer-sdk` (load `references/connector-template-reference.md`) |
| Write or edit `protocol.xml` structure, tags, attributes, enum values, IDs, keyrefs | `dataminer-protocol-xml-reference` |
| Understand DataMiner runtime behavior before making XML changes | Relevant `logic-*` reference file(s) in this skill |
| Write or modify C# QAction code | `dataminer-qaction` |
| HTTP/HTTPS communication implementation | `dataminer-http-communication` |
| Run the validator, interpret results, fix validator errors | `dataminer-validation` |
| Write unit tests for QActions | `dataminer-unit-testing` |
| Run DataMiner integration/regression test packages on QAOps DaaS targets | `dataminer-qaops` + `dataminer-qaops-test-runs` |
| Test Automation script, element, or solution behavior on a real DataMiner (QAOps) | `dataminer-qaops` + `dataminer-qaops-integration-testing` + `dataminer-sdk` |
| Author an Automation script + QAOps verification, with **no** `protocol.xml` authoring | `dataminer-idms` + `dataminer-qaops` (then `dataminer-qaops-integration-testing`/`-test-runs`); skip this skill's logic/example references — they are connector-only |
| Generate or refresh `QAction_Helper.cs` when requested or when consumed generated members changed | `dataminer-qaction-helper-generator` |
| Create a `.dmprotocol` package from a classic (non-SDK) connector solution | `dataminer-dmprotocol-packaging` |
| Push data into a name-addressable **dynamic** element via the DataAPI HTTP feature (no fixed PIDs / no protocol.xml) | `dataminer-dataapi` (and `dataminer-idms` for the normal fixed-PID path) |
| Write connector help/documentation pages | `dataminer-connector-help` |
| Review a connector against XML schema, runtime logic, QAction, and validator expectations | `dataminer-protocol-xml-reference` + relevant `logic-*` files + `dataminer-qaction` + `dataminer-validation` |
| Plan and delegate a multi-step connector task | `dataminer-orchestrator` |
| Run inline validation gates (XSD check, C# auto-fix) | `dataminer-validation-gates` |
| Investigate runtime symptoms, RTEs, slow SNMP tables, smart-serial server queues, Swarming, or TLS | `dataminer-connector-debugging` + the relevant communication reference |
| Understand DataMiner / connector terminology | `references/glossary.md` (this skill) |
| SNMP connector pattern reference | `references/example-snmp-connector.md` (this skill) |
| HTTP connector pattern reference | `references/example-http-connector.md` (this skill) |
| Post-generation review checklist | `references/connector-review-prompt.md` (this skill) |
| Understand runtime execution, threading, startup | `references/logic-execution-flow.md` (this skill) |
| Understand parameter behavior, change events | `references/logic-parameters.md` (this skill) |
| Understand groups, timers, polling scheduling | `references/logic-groups-timers.md` (this skill) |
| Understand triggers, actions, event handling | `references/logic-triggers-actions.md` (this skill) |
| Understand QAction fundamentals, compilation, entry points | `references/logic-qactions.md` (this skill) |
| Understand conditions, conditional execution | `references/logic-conditions.md` (this skill) |
| DCF interfaces, connections, properties, tables, API | `dataminer-dcf` |
| Polling Manager (configurable per-data-set polling intervals, enable/disable, dependencies) | `dataminer-polling-manager` |
| Find the right Skyline NuGet package or package-specific API reference | `dataminer-nugets` + `references/nuget-packages.md` (quick catalog) |

> **Hard rule — "test/verify on a real DataMiner" always means QAOps, never a local DataMiner.** Any request to test, run, or verify behavior on a real DataMiner (Automation scripts, IDms code, connectors, element/service behavior) goes through QAOps: `dataminer-qaops` → `dataminer-qaops-integration-testing` → `dataminer-qaops-test-runs`. A local `C:\Skyline DataMiner` install that happens to be on the machine is **not** the test target — never point tests at it, reference its `Files` DLLs, or run integration tests with local `dotnet test`. Authoring code locally and verifying it on a real system are distinct phases; when you reach verification, re-route to QAOps.

---

## Reference Files

Load these on demand — only when relevant to the task.

| File | Contents | Load When |
|------|----------|-----------|
| `glossary.md` | Authoritative definitions of all DataMiner/connector terms (Protocol, Element, Parameter, QAction, Group, Timer, etc.) | Any task where DataMiner terminology is used |
| `example-snmp-connector.md` | Complete canonical SNMP connector: scalars, `snmpSetAndGet` read/write pair, table, timers, and after-startup initialization chain | Any SNMP connector authoring task — follow this pattern exactly |
| `example-http-connector.md` | Complete canonical HTTP REST connector: session, status/body parameters, timer-driven poll group, after-startup initialization, and QAction trigger | Any HTTP connector authoring task — follow this pattern exactly |
| `connector-review-prompt.md` | Post-generation review checklist covering naming, IDs, XML structure, alarming, C# patterns, communication | After completing any connector task — run this review before delivery |
| `logic-execution-flow.md` | SLDataMiner/SLProtocol/SLScripting architecture, threading model, group queue, startup sequence, IPC | Understanding runtime behavior or debugging timing issues |
| `logic-parameters.md` | Parameter types, change event order, uninitialized values, read/write pairs, dummy params, saved params | Parameter design or parameter-triggered logic |
| `logic-groups-timers.md` | Group types, timer behavior, poll-type wait, race conditions, queue overflow prevention | Polling/scheduling design |
| `logic-triggers-actions.md` | Trigger activation sources/timing, all action types, trigger chains, conditional execution patterns | Event-driven logic, writing triggers/actions |
| `logic-qactions.md` | QAction fundamentals, entry points, inputParameters, blocking behavior, row triggers, compilation, DLL import | Writing or reviewing C# QActions |
| `logic-conditions.md` | Condition syntax, operators, operands, CDATA rules, element-type applicability | Adding conditional execution to any element |
| `dataminer-connector-debugging` | Evidence-first runtime diagnosis, RTE/pending calls, Stream Viewer, DIS Inject, SNMP performance, smart-serial, Swarming, TLS, and logging-load routing | Any runtime investigation or performance review |
| `references/authority-boundaries.md` | Sole owner for each Connector schema, validator, API, runtime, DIS, documentation, packaging, and deployment concern | Maintaining agents or resolving a rule conflict |
| `nuget-packages.md` | Quick catalog of Skyline utility NuGet packages (rates, SNMP, tables, type safety, testing). Deep package API guidance lives in `dataminer-nugets`. | Before writing custom C# — always check here first |

---

## Documentation Links

| Topic | URL |
|-------|-----|
| Protocol schema | https://aka.dataminer.services/schema-protocol |
| Schema element reference | https://aka.dataminer.services/protocol |
| Dev guide home | https://aka.dataminer.services/getting-started-with-data-source-integrations |
| Connector fundamentals | https://aka.dataminer.services/getting-started-with-data-source-integrations |
| Connections | https://aka.dataminer.services/connections |
| UI Components | https://aka.dataminer.services/ui-components |
| Monitoring (alarming) | https://aka.dataminer.services/monitoring |
| Advanced functionality | https://aka.dataminer.services/advanced-functionality |
| Coding guidelines | https://aka.dataminer.services/coding-guidelines |
| SNMP connections | https://aka.dataminer.services/connections-snmp |
| HTTP connections | https://aka.dataminer.services/http-connections |
| Serial connections | https://aka.dataminer.services/connections-serial |
| Logic (params, groups…) | https://aka.dataminer.services/logic |
| Reserved IDs | https://aka.dataminer.services/reserved-i-ds |
| Reserved names | https://aka.dataminer.services/ReservedParameterNames |
