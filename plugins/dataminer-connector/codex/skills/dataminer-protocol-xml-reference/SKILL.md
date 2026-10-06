---
name: dataminer-protocol-xml-reference
description: 'protocol.xml, DPML, DataMiner connector XML schema authority: use when creating, editing, reviewing, fixing, or validating protocol.xml tags, attributes, enum values, fixed values, ID patterns, child placement, namespaces, keys, and keyrefs. The bundled references are the operational XSD replacement and MUST be followed exactly.'
argument-hint: Describe the protocol.xml element, attribute, enum, schema error, or XML area to source-check.
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-27
  version: 3.1
---

Read the [Protocol XML guard rails](references/dataminer-protocol-xml.instructions.md)
alongside the relevant schema references. Published plugins include a copy beside this skill's
references and a native Copilot rule. Automatic application is client-dependent; load the
guidance explicitly when it is not attached.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 3.1 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 3.0 | 2026-09-11 | Refreshed the closed-world authority to Protocol schema 1.1.10, added Swarming and `Fix@introducedIn`, and added reproducible schema hash/fact checks. |
| 2.3 | 2026-09-11 | Added a machine-readable source manifest that distinguishes the local 1.1.7 schema baseline from observed upstream schema, validator, template, and analyzer versions. |
| 2.2 | 2026-05-24 | Added Authority Scope cross-reference: this skill wins on schema-fact conflicts vs. `dataminer-xml-authoring`. |
| 2.1 | 2026-05-14 | Earlier baseline. |

# DataMiner Protocol XML Reference

This skill is the mandatory schema gate for `protocol.xml` work.

## Authority Scope

The hard operational authority for connector work is this skill and its bundled reference files.

These files were authored from:

- `protocol.xsd` 1.1.10.
- Included `uom.xsd`.
- NuGet package reference in this repository: `Skyline.DataMiner.XmlSchemas.Protocol` version `1.1.10`.

The exact local and observed upstream package versions, source revisions, artifact paths, and SHA-256 values are recorded in `references/source-manifest.json`. The manifest is maintenance metadata: its newer observed versions do not authorize newer schema content until the bundled references have been regenerated and validated.

During connector authoring, reviewing, or fixing, do not read `.xsd` files to fill gaps. If the bundled references do not define a schema detail, stop and request a skill/reference expansion.

This skill owns XML vocabulary only:

- Element names and casing.
- Attribute names and casing.
- Parent/child placement.
- Cardinality.
- Required fields.
- Fixed values.
- Enum values.
- Simple type restrictions.
- Namespace facts.
- Uniqueness, keys, and keyrefs.

Every schema fact in this skill is mandatory. Treat this skill like a closed-world schema contract:

- If a tag is not listed for the exact parent path, it MUST NOT be authored there.
- If an attribute is not listed for the exact element/type, it MUST NOT be authored there.
- If an enum/fixed value is not listed, it MUST NOT be used.
- If a branch is represented only as a navigation/map file, load the referenced structural file before authoring descendants.
- If a needed schema detail is missing, stop and request a reference expansion; do not guess and do not inspect `.xsd` files during connector work.

This skill does not own runtime behavior, best practices, version-impact policy, device communication behavior, or validator-only findings. For those, load:

- `dataminer-connector-core/references/logic-*.md` for DataMiner runtime behavior.
- `dataminer-protocol-validator-prevention` for validator-derived guardrails.
- `dataminer-xml-authoring` for authoring workflow, templates, pedagogy, and worked examples. When `dataminer-xml-authoring` references and this skill disagree on a schema fact, **this skill wins**.

## Hard Constraint

Before creating, editing, reviewing, fixing, or validating `protocol.xml`:

- Load this skill.
- Load every relevant schema reference file for the XML area being changed.
- Verify every new or changed element, attribute, enum value, fixed value, and XSD-patterned string against the bundled schema references.
- Do not write XML from memory.
- Do not invent tag names, attribute names, enum values, wrappers, casing, or XSD-patterned option tokens.

For attributes typed as `xs:string`, this skill only confirms that a string is schema-valid. It does not make arbitrary option tokens valid. A token MUST NOT be authored unless that token is listed in this skill or another loaded non-schema authority explicitly owns that option semantics.

## Reference Files

Load references by XML area:

| XML Area | Schema Reference File |
|---|---|
| Source provenance, package hashes, upstream revisions, ownership, and known drift | `dataminer-protocol-xml-reference/references/source-manifest.json` |
| Root `Protocol`, namespace, required top-level tags, Swarming, VersionHistory, root keys/keyrefs, ID simple types | `dataminer-protocol-xml-reference/references/protocol-root.md` |
| Enum values and simple-type gates, including Swarming bypass checks | `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md` |
| DataMiner version values and `TypeDataMinerVersion` pattern | `dataminer-protocol-xml-reference/references/protocol-dataminer-versions.md` |
| UOM values from the included unit schema | `dataminer-protocol-xml-reference/references/protocol-uom.md` |
| HTTP request, response, and common header enum values | `dataminer-protocol-xml-reference/references/protocol-http-headers.md` |
| Icon enum values for `Icon@ref` and `iconRef` attributes | `dataminer-protocol-xml-reference/references/protocol-icons.md` |
| Connection-family XML vocabulary map | `dataminer-protocol-xml-reference/references/protocol-driver-type-gate.md` |
| `Params`, `Param`, interpretation, display containers, SNMP child placement, nested `Param` branches | `dataminer-protocol-xml-reference/references/protocol-params.md` |
| Tables, `ArrayOptions`, `ColumnOption`, `NamingFormat` | `dataminer-protocol-xml-reference/references/protocol-tables.md` |
| HTTP sessions, requests, responses, headers | `dataminer-protocol-xml-reference/references/protocol-http.md` |
| SNMP root marker, `Param/SNMP`, `OID`, `TrapOID`, SNMP type values | `dataminer-protocol-xml-reference/references/protocol-snmp.md` |
| Serial/smart-serial XML containers and framing-related parameter types | `dataminer-protocol-xml-reference/references/protocol-serial-smartserial.md` |
| WebSocket-related XML locations and `WebSocketMessageType` | `dataminer-protocol-xml-reference/references/protocol-websocket.md` |
| `Type`, `PortSettings`, `Ports`, `Connections` schema | `dataminer-protocol-xml-reference/references/protocol-portsettings-connections.md` |
| Commands, responses, pairs, groups, timers, triggers, actions | `dataminer-protocol-xml-reference/references/protocol-execution.md` |
| Display containers, UI placement containers, measurement UI placement, matrix locations | `dataminer-protocol-xml-reference/references/protocol-display-ui.md` |
| Alarm/trending/history-set XML locations | `dataminer-protocol-xml-reference/references/protocol-monitoring.md` |
| QAction XML registration, attributes, options pattern | `dataminer-protocol-xml-reference/references/protocol-qactions.md` |
| Swarming, DVE, DCF, mediation, logger/view tables, topology, tree, threads, process automation, ownership, advanced schema locations | `dataminer-protocol-xml-reference/references/protocol-advanced-features.md` |
| Schema validation and anti-invention checklist | `dataminer-protocol-xml-reference/references/protocol-validation-workflow.md` |

Each reference file declares its coverage. Treat every coverage statement as a closed-world contract: only explicitly listed tags, attributes, values, fixed values, and pattern forms are authorable. Navigation/map files identify the owning structural reference instead of authorizing descendants by themselves.

## Logic Pairing

Schema validity is not enough to safely change a connector. Before implementing behavior, load the relevant logic file from `dataminer-connector-core`:

| Runtime Topic | Logic Reference |
|---|---|
| SLDataMiner/SLProtocol/SLScripting/SLElement, queues, startup, connections, RTDisplay consumers | `logic-execution-flow.md` |
| Parameter change events, storage, read/write pairs, tables, alarming/trending/history/traps | `logic-parameters.md` |
| Groups, timers, polling, ping behavior, multithreaded timers | `logic-groups-timers.md` |
| Triggers, actions, queue actions, SNMP sets, serial command/response actions | `logic-triggers-actions.md` |
| QAction execution, entry points, IPC, row context, concurrency, history sets | `logic-qactions.md` |
| Condition expression behavior and evaluation timing | `logic-conditions.md` |

## Pre-Edit Schema Checklist

Before changing XML, confirm:

- The parent path is listed in the loaded bundled references.
- The child element is listed at that exact parent path.
- The attribute is listed on that exact element or type.
- Required siblings/children/attributes are present.
- Repeated elements respect `minOccurs` and `maxOccurs`.
- Enum/fixed values use exact strings.
- ID values match the XSD simple type.
- Schema key/keyref references resolve.
- If the field is `xs:string`, arbitrary option tokens are not treated as confirmed.

If any item cannot be verified from these files, do not edit that XML. Request a skill/reference expansion.

## Completion Gate

Before considering `protocol.xml` schema work complete:

- Run the configured schema validation gate where available.
- Fix schema errors before validator/style/runtime issues.
- Report schema validation not run and why.

## Source Corpus Read

This skill was authored from `protocol.xsd` 1.1.10 and included `uom.xsd`. Those files are source material for maintaining this skill, not a fallback reference during connector work. Consult `references/source-manifest.json` to reproduce the local baseline or assess recorded upstream drift.
