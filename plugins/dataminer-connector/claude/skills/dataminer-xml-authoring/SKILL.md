---
name: dataminer-xml-authoring
description: 'DPML XML authoring for DataMiner connectors: protocol structure, parameters, groups, timers, triggers, actions, tables (array parameters), alarming, trending, UI pages/layout, display keys, DVEs, commands/responses, and Measurement sections. Use when creating or editing protocol.xml content.'
argument-hint: 'Describe the XML change: e.g. "add SNMP table with 5 columns", "create HTTP polling session", "configure alarming thresholds", "add DVE child element"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-05
  version: 2.41
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.41 | 2026-10-05 | Added authoring rules and checklist item for discrete parameters with numeric backends for pre-known values. |
| 2.40 | 2026-10-02 | Clarified SNMP write setup, scalar multipleGet grouping, action priority, and timer-driven startup polling. |
| 2.39 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 2.38 | 2026-09-11 | Corrected HTTP authentication to require Header@key, removed hard-coded secret patterns, and added secret/certificate safeguards. |
| 2.37 | 2026-09-11 | Corrected the Protocol namespace and OID type list, made Alarm support and duplicate-description suffixes conditional, and reconciled high-churn `volatile` requirements with incompatible table features. |
| 2.36 | 2026-09-11 | Corrected the full parameter-schema reference to point to its owning `dataminer-protocol-xml-reference` skill. |
| 2.35 | 2026-08-13 | Corrected VendorOID guidance: the value must be a Skyline-assigned connector OID matching the DataMiner schema, not the device vendor's IANA enterprise or sysObjectID OID. |
| 2.34 | 2026-08-13 | Consolidated naming guidance into scoped mechanical rules, removed an unsafe whole-file `<Name>` grep, and clarified that descriptive camelCase table names are valid. |
| 2.33 | 2026-08-13 | **MIB table name derivation trap.** Added `tx21BucInfoTable`→`tx21BucInfo`, `tx21BucAlarmTable`→`tx21BucAlarm`, `tx21BucSensorTable`→`tx21BucSensor` examples across SKILL.md, table-naming reference, table-authoring-gates reference, pre-completion checklist, and `dataminer-xml-author` agent Step 3b. Clarified that the DataMiner table `<Name>` must be derived from the lowercase-first OBJECT-TYPE descriptor, not from the uppercase-first SEQUENCE type name (`Tx21BucInfoEntry`). |
| 2.32 | 2026-08-13 | **Five NamingConventions/XmlStructure fixes from eval findings (bucInfo-table columns, multi-word compound prefix).** (1) Added `BucInfoIndex`→`bucInfoIndex`, `BucInfoModelNumber`→`bucInfoModelNumber`, `BucInfoSerialNumber`→`bucInfoSerialNumber`, `BucInfoFirmwareVersion`→`bucInfoFirmwareVersion`, `BucInfoPowerWatts`→`bucInfoPowerWatts`, `BucInfoFrequencyBand`→`bucInfoFrequencyBand`, `BucInfoRFRange`→`bucInfoRFRange`, `BucInfoIFRange`→`bucInfoIFRange`, `BucInfoLOFrequency`→`bucInfoLOFrequency` to the camelCase conversion table — covers the multi-word compound prefix trap. (2) Extended inline authoring gate callout: when the table `<Name>` is itself a multi-word camelCase string (e.g. `bucInfo`), the column prefix must equal that exact string verbatim — `BucInfo` is wrong even though each word looks correctly cased. (3) Added Before/After: Multi-Word Compound Prefix Trap example block to `references/table-authoring-gates.md` using a `bucInfo` table. (4) Strengthened VendorOID routing rule to explicitly name `VendorOID` as the concrete XmlStructure WARN example and clarified that when the vendor OID is unknown, the agent must look it up at IANA or ask the user — not leave Skyline's OID as a placeholder. |
| 2.31 | 2026-08-13 | **Four NamingConventions fixes from eval findings (interfaces-table column descriptions).** (1) Extended routing rule: NamingConventions findings now explicitly cover `<Description>` suffix violations ("`Description 'X' should end with '(Y)'"`) in addition to `<Name>` casing violations — both are blocking and require `dataminer-xml-author` invocation immediately. (2) Extended inline authoring gate to cover `<Description>` suffix: every table column `<Description>` MUST end with `(TableDescription)` — apply at write time, not post-scan. (3) Added `InterfaceKey`→`interfaceKey`, `InterfaceName`→`interfaceName`, `InterfaceType`→`interfaceType`, `InterfaceSpeed`→`interfaceSpeed`, `InterfaceStatus`→`interfaceStatus` to the camelCase conversion table (singular "Interface" prefix trap). (4) Added Before/After: Description Suffix Trap example block to `references/table-authoring-gates.md` using an `interfaces` table. |
| 2.30 | 2026-08-13 | **Three NamingConventions fixes from eval findings (device-table columns).** (1) Added `DeviceKey`→`deviceKey`, `DeviceName`→`deviceName`, `DeviceStatus`→`deviceStatus`, `DeviceSpeed`→`deviceSpeed` rows to the camelCase conversion table — covers the common single-word table prefix trap. (2) Strengthened routing rule: NamingConventions findings BLOCK task completion — the orchestrator must invoke `dataminer-xml-author` immediately, not as an optional post-step, and must not return results until all findings are resolved. (3) Added Before/After: Short Single-Word Prefix Trap example block to `references/table-authoring-gates.md` using a `device` table. |
| 2.29 | 2026-08-12 | **Four NamingConventions fixes from eval findings.** (1) Added NamingConventions WARN/FAIL to agent routing rule — `dataminer-xml-author` must now be invoked for both XmlStructure WARNs and NamingConventions WARNs or FAILs on parameter/table column `<Name>` casing. (2) Extended inline authoring gate callout to explicitly cover table column `<Name>` elements — prefix must match table `<Name>` verbatim including casing. (3) Added four table column examples to camelCase conversion table (`InterfacesName`, `InterfacesIpAddress`, `InterfacesLinkState`, `InterfacesTxPackets`). (4) Added per-column self-check rule + Before/After: PascalCase Prefix Trap example block to `references/table-authoring-gates.md`. |
| 2.28 | 2026-08-12 | Added VendorOID and optional Trigger/Action completeness guidance plus routing for XmlStructure findings. |
| 2.27 | 2026-07-17 | Added connector XML comment hygiene and removed explanatory comments from copyable XML examples; copyright and justified `SuppressValidator` comments remain allowed. |
| 2.26 | 2026-06-27 | **File size reduction for auto-improve compatibility.** Moved `## Parameters`, `## Groups`, `## Timers`, `## Triggers`, `## Actions`, `## Commands & Responses`, TABLE GENERATION GATE detailed rules (0–12), Table Column Pre-Completion Checklist, Table Measurement/Rules/Data Handling/instance/Multi-PID sections, and the global Pre-Completion Checklist to dedicated reference files (`references/parameters.md`, `references/groups-timers-triggers-actions.md`, `references/commands-responses.md`, `references/table-authoring-gates.md`, `references/pre-completion-checklist.md`). Archived changelog v2.8–v2.20 to `references/CHANGELOG.md`. Replaced each moved section with a compact summary + cross-reference. Updated Reference Files table with new reference rows. Reduced SKILL.md from 109 KB to ≤40 KB to allow auto-improve AI passes. |
| 2.25 | 2026-06-26 | **Eight targeted fixes from eval findings.** (1) Fixed Connection-Type-Specific Sections table: `<SNMP includepages="true">auto</SNMP>` is required for ALL connection types — not SNMP-only. (2) Added HTTP-specific params to camelCase conversion table and extended 100–999-range callout to cover HTTP response/status-code params. (3) Added `Uptime`→`uptime` and `ApiKeyHeader`→`apiKeyHeader` to conversion table; added PID 1–10 HTTP-infrastructure callout. (4) Added "Unrecommended characters" rule: `<Name>` values MUST contain only alphanumerics. (5) Added Before/After example for HTTP response params (PIDs 99–100, 199–200). (6) Added before/after block to Table Column Naming Convention showing singular-vs-plural prefix trap. (7) Added `key` attribute to HTTP Sessions XML example + mandatory `key` rule. (8) Added HTTP Session `key` attribute item to Pre-Completion Checklist. |
| 2.24 | 2026-06-26 | **Schema-file consolidation (single schema owner).** Retired the six duplicate `protocol-*` schema reference files — `dataminer-protocol-xml-reference` is now the sole schema authority. Migrated timer/trigger/action worked patterns → `references/execution-patterns.md`; `<Measurement><Type options>` semantics table → `references/authoring-best-practices.md`. |
| 2.23 | 2026-06-26 | Added inline camelCase authoring gate rule directly before the naming convention table. Added prominent callout box identifying PID 100–999 system-info scalars as the #1 NamingConventions WARN source. Added before/after XML snippet showing PIDs 100–102 wrong and correct names. |
| 2.22 | 2026-06-26 | Unified all `<Name>` elements to camelCase: table `<Name>` and column `<Name>` now use camelCase — PascalCase is no longer used anywhere in connector XML naming. |
| 2.21 | 2026-06-26 | Added `SystemUptime` → `systemUptime` to camelCase conversion table; added empty-Range-vs-missing-Range distinction to both the scalar Range checklist item and the Table Column Pre-Completion Checklist Range row. |

> **Older entries (v2.8–v2.20)**: `dataminer-xml-authoring/references/CHANGELOG.md`

# DataMiner DPML XML Authoring

Covers all aspects of writing and modifying `protocol.xml` content. Load `dataminer-connector-core` alongside this skill for naming conventions and ID management.

> **Paired agent**: `dataminer-xml-author` — owns workflow and validation steps. This skill owns XML templates, examples, and element reference. Keep shared constraints (alarm tags, naming rules) in sync.
>
> **Agent routing on validation findings**:
> - When the **XmlStructure** check returns WARN findings, the `dataminer-xml-author` agent MUST be invoked to correct the `protocol.xml` before the task is considered complete. Do not close a task with open XmlStructure WARNs. `<VendorOID>` must use a Skyline-assigned connector OID matching `1.3.6.1.4.1.8813.2.<number>`; it is not the device vendor's IANA enterprise or sysObjectID OID. If the assigned value is unknown, ask the user rather than inventing one or leaving a placeholder.
> - When the **NamingConventions** check returns WARN or FAIL findings on parameter or table column `<Name>` elements, or on genuinely duplicated table column `<Description>` values that require disambiguation, the `dataminer-xml-author` agent MUST be invoked **immediately** to fix the violations in `protocol.xml`. A parenthetical table suffix is not required for a unique description. **This is a blocking requirement**: the orchestrator must not return results or mark the task complete until all NamingConventions findings are resolved. Treating it as an optional post-step or deferring it causes the agent-routing gap detected in eval. Do not close a task with open NamingConventions WARNs or FAILs.

A quick-reference version is linked from `dataminer-protocol-xml-reference`. Load its guard rails
explicitly; automatic attachment depends on the client and installation.

## Reference Files

Load these references when needed:

| Topic | Reference File |
|-------|---------------|
| **Protocol XML schema — ALL sections** (tags, attributes, enum values, fixed values, parent/child placement, cardinality for Params, Tables, Groups, Timers, Triggers, Actions, HTTP, SNMP, PortSettings, QActions, metadata, …) | **`dataminer-protocol-xml-reference`** — the sole schema authority. Load it and its `references/protocol-*.md` files. See **Schema Lookups** below. |
| Timer / trigger / action worked patterns (timeout, response, chained, conditional, multi-param, staggered poll, QAction-via-trigger) | `dataminer-xml-authoring/references/execution-patterns.md` |
| Alarm thresholds, units, ranges, trending, UI conventions, MIB enum conversion, measurement type selection, measurement `options` semantics | `dataminer-xml-authoring/references/authoring-best-practices.md` |
| Table relations, foreign keys, relation ordering, alarm bubble-up | `dataminer-xml-authoring/references/table-relations.md` |
| SNMP MIB table/column naming translation examples | `dataminer-xml-authoring/references/table-naming.md` |
| SNMP trap reception, bindings, alarm generation | `dataminer-xml-authoring/references/snmp-traps.md` |
| SNMP writes: setting single parameters | `dataminer-xml-authoring/references/snmp-writes-single.md` |
| SNMP writes: altering table cells | `dataminer-xml-authoring/references/snmp-writes-table-cell.md` |
| HTTP authentication: API key, Basic Auth, Bearer/OAuth2 | `dataminer-xml-authoring/references/http-auth-patterns.md` |
| WebSocket connections | `dataminer-xml-authoring/references/websocket-connections.md` |
| Serial and Smart-Serial connections | `dataminer-xml-authoring/references/serial-connections.md` |
| Rate calculation parameters, naming, and wiring | `dataminer-xml-authoring/references/rate-calculation-xml.md` |
| Advanced: redundant polling, inter-element communication | `dataminer-xml-authoring/references/advanced-connectivity.md` |
| DVE export, EPM/Topology, Tree Control, Matrix, View/Logger Tables, Multithreaded Timers, Mediation, Charts | `dataminer-xml-authoring/references/specialized-features.md` |
| DCF interfaces, connections, properties, tables, API | `dataminer-dcf` |
| **Full `<Param>` XML examples, attribute tables, valid children, schema verification, position uniqueness, Read/Write pair XML** | `dataminer-xml-authoring/references/parameters.md` |
| **Groups, Timers, Triggers & Actions — full XML examples, group types, ping group, timer design rules, trigger times** | `dataminer-xml-authoring/references/groups-timers-triggers-actions.md` |
| **Serial Commands & Responses — full XML patterns** | `dataminer-xml-authoring/references/commands-responses.md` |
| **TABLE GENERATION GATE detailed rules 0–12, Table Column Naming Convention detail, Table Column Pre-Completion Checklist, Table Rules, Data Handling, `instance` option, Multi-PID NamingFormat** | `dataminer-xml-authoring/references/table-authoring-gates.md` |
| **Pre-Completion Checklist — full item-by-item checklist for every authoring task** | `dataminer-xml-authoring/references/pre-completion-checklist.md` |
| Archived changelog (v2.8–v2.20) | `dataminer-xml-authoring/references/CHANGELOG.md` |

### Schema Lookups (Cross-Reference)

This skill owns **authoring** content — templates, worked examples, gates, and pedagogy. It does **not** carry protocol XML schema reference files. For the closed-world **schema authority** — exact tag/attribute/enum lists, fixed values, parent/child placement, cardinality — load `dataminer-protocol-xml-reference` and consult its `references/protocol-*.md` files. That skill is the single source of truth for schema facts; there is no longer a competing copy in this skill to conflict with it.

For the ownership matrix across the XML skills and their guard rails, see the **Authority Matrix**
in `dataminer-protocol-validator-prevention`.

---

## XML Formatting

> **HARD RULE: Use tab characters (`\t`) for indentation — NEVER spaces. One tab per nesting level. Every child element is indented one level deeper than its parent. This applies to all generated XML: skeletons, parameter snippets, incremental additions, and inline edits — no exceptions.**

- The skeleton and examples below use spaces for readability in this markdown source. When generating actual `protocol.xml` content, always output tab-indented XML.

## XML Comment Hygiene

Actual connector `protocol.xml` output must not contain explanatory or documentation comments. Do not add TODO, FIXME, debug, workaround, or design-note comments. Copyright comments are allowed. `SuppressValidator` comments are allowed only when they directly wrap the affected element and include a specific reason for a genuinely non-applicable validator finding.

Put explanations in `<Description>`, `<Information><Subtext>`, surrounding Markdown, or C# documentation comments. Do not copy comments from Markdown examples into generated XML. Apply this rule to full files, snippets, incremental edits, cloned files, and final formatting passes.

---

## Connector XML Skeleton

```xml
<?xml version="1.0" encoding="utf-8"?>
<Protocol xmlns="http://www.skyline.be/protocol" ...>
  <Name>Vendor Device Name</Name>
  <Description>Vendor Device Name DataMiner Driver</Description>
  <Version>1.0.0.1</Version>
  <IntegrationID>DMS-DRV-1234</IntegrationID>
  <Provider>Skyline Communications</Provider>
  <Vendor>Vendor Inc</Vendor>
  <VendorOID>1.3.6.1.4.1.8813.2.12345</VendorOID>
  <DeviceOID>1</DeviceOID>
  <ElementType>Switch</ElementType>
  <Type relativeTimers="true">snmpv2</Type>
  <SNMP includepages="true">auto</SNMP>
  <Display defaultPage="General" pageOrder="General;-----;Webinterface#http://[Polling Ip]/" wideColumnPages="" />
  <Compliancies>
    <CassandraReady>true</CassandraReady>
    <MinimumRequiredVersion>10.4.0.0 - 14003</MinimumRequiredVersion>
  </Compliancies>
  <Params>...</Params>
  <Commands>...</Commands>
  <Responses>...</Responses>
  <Pairs>...</Pairs>
  <Groups>...</Groups>
  <Triggers>...</Triggers>
  <Actions>...</Actions>
  <Timers>...</Timers>
  <PortSettings>...</PortSettings>
  <QActions>...</QActions>
  <VersionHistory>
    <Branches>
      <Branch id="1">
        <Comment>Main Branch</Comment>
        <SystemVersions>
          <SystemVersion id="0">
            <MajorVersions>
              <MajorVersion id="0">
                <MinorVersions>
                  <MinorVersion id="1">
                    <Date>YYYY-MM-DD</Date>
                    <Provider>
                      <Author>Author Name</Author>
                      <Company>Skyline Communications</Company>
                    </Provider>
                    <Changes>
                      <NewFeature>Initial version</NewFeature>
                    </Changes>
                  </MinorVersion>
                </MinorVersions>
              </MajorVersion>
            </MajorVersions>
          </SystemVersion>
        </SystemVersions>
      </Branch>
    </Branches>
  </VersionHistory>
</Protocol>
```

> **⚠ VendorOID — use the Skyline-assigned connector OID:**
> `<VendorOID>` must match the DataMiner schema pattern `1.3.6.1.4.1.8813.2.<number>`. Do not substitute the device vendor's IANA enterprise or sysObjectID OID.
> - ❌ `<VendorOID>1.3.6.1.4.1.8813</VendorOID>` — bare Skyline root
> - ❌ `<VendorOID>1.3.6.1.4.1.9.1.516</VendorOID>` — device vendor OID, outside the schema pattern
> - ✅ `<VendorOID>1.3.6.1.4.1.8813.2.12345</VendorOID>` — example shape; use the actually assigned value
>
> If the assigned connector OID is unknown, ask the user rather than inventing a value.

> **⚠ `<Triggers>` and `<Actions>`:**
> Include and populate these sections when the connector implements corresponding execution logic. When no such logic exists, omission and empty sections are both schema-valid; follow the existing connector convention.

---

## Connection-Type-Specific Sections

Not all XML sections apply to every connection type. Use this table to determine which sections to include:

| Section | SNMP | HTTP | Serial | Smart-Serial | WebSocket | Virtual |
|---------|------|------|--------|-------------|-----------|---------|
| `<Params>` | Yes | Yes | Yes | Yes | Yes | Yes |
| `<Commands>` | No | **No** | Yes | Yes | Yes | No |
| `<Responses>` | No | **No** | Yes | Yes | Yes | No |
| `<Pairs>` | No | **No** | Yes | Yes | Yes | No |
| `<HTTP>` | No | **Yes** | No | No | **Yes** (via HTTP connection) | No |
| `<SNMP>` (protocol-level) | **Yes** | **Yes** | **Yes** | **Yes** | **Yes** | **Yes** |
| `<Groups>` | Yes | Yes | Yes | Yes | Yes | Yes |
| `<Triggers>` | Empty* | Empty* | Empty* | Empty* | Empty* | Empty* |
| `<Actions>` | Empty* | Empty* | Empty* | Empty* | Empty* | Empty* |
| `<Timers>` | Yes | Yes | Yes | Yes | Yes | Yes |
| `<QActions>` | Yes | Yes | Yes | Yes | Yes | Yes |
| `<PortSettings>` | Yes | Yes | Yes | Yes | Yes | No |

\* `<Triggers>` / `<Actions>`: Include empty `<Triggers></Triggers>` / `<Actions></Actions>` elements when no execution logic is needed; populate them only when triggers or actions are required.

> **Critical**: HTTP connectors must NOT include `<Commands>`, `<Responses>`, or `<Pairs>` sections. HTTP uses `<HTTP>` sessions instead. Including serial-only sections in an HTTP connector will cause confusion and validator warnings.
>
> **Note**: WebSocket uses an HTTP connection with `<WebSocket>true</WebSocket>` in `CommunicationOptions`. It uses Commands/Responses/Pairs for message framing, plus optionally `<HTTP>` sessions for custom handshakes.

### PortSettings Reference by Connection Type

The `<PortSettings name="...">` element customizes the DataMiner Cube Element Creation Wizard. Always configure relevant defaults and disable non-applicable port types:

- **SNMP (`snmp`, `snmpv2`, `snmpv3`)**: Bus address is not used (disable it), IP port defaults to 161, and serial port is disabled.
  ```xml
  <PortSettings name="SNMP Connection">
    <BusAddress><Disabled>true</Disabled></BusAddress>
    <IPport><DefaultValue>161</DefaultValue></IPport>
    <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
  </PortSettings>
  ```
- **HTTP / REST / HTTPS (`http`)**: Bus address defaults to `bypassProxy` for direct API calls, IP port defaults to 80 (or 443 for HTTPS), Type defaults to `ip`, and UDP and serial ports are disabled.
  ```xml
  <PortSettings name="HTTP Connection">
    <BusAddress><DefaultValue>bypassProxy</DefaultValue></BusAddress>
    <IPport><DefaultValue>80</DefaultValue></IPport>
    <Type><DefaultValue>ip</DefaultValue></Type>
    <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
    <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
  </PortSettings>
  ```
- **Serial (`serial`)**: Type defaults to `serial` (or `ip` for terminal server), Bus address disabled (unless RS-485 multi-drop, where it defaults to `1`), standard serial framing defaults (Baudrate 9600, Databits 8, Stopbits 1, Parity No, Flowcontrol No), IP port default, and UDP disabled.
  ```xml
  <PortSettings name="Serial Connection">
    <Type><DefaultValue>serial</DefaultValue></Type>
    <BusAddress><Disabled>true</Disabled></BusAddress>
    <Baudrate><DefaultValue>9600</DefaultValue></Baudrate>
    <Databits><DefaultValue>8</DefaultValue></Databits>
    <Stopbits><DefaultValue>1</DefaultValue></Stopbits>
    <Parity><DefaultValue>No</DefaultValue></Parity>
    <Flowcontrol><DefaultValue>No</DefaultValue></Flowcontrol>
    <IPport><DefaultValue>4001</DefaultValue></IPport>
    <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
  </PortSettings>
  ```
- **Smart Serial (`smart-serial`)**: Type defaults to `ip`, Bus address disabled, IP port defaults to listener port (e.g. 50000), and serial port is disabled.
  ```xml
  <PortSettings name="Smart Serial Connection">
    <Type><DefaultValue>ip</DefaultValue></Type>
    <BusAddress><Disabled>true</Disabled></BusAddress>
    <IPport><DefaultValue>50000</DefaultValue></IPport>
    <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
  </PortSettings>
  ```
- **SSH (`serial` with SSH)**: Type defaults to `ip`, Bus address disabled, IP port defaults to 22, and UDP/serial disabled.
  ```xml
  <PortSettings name="SSH Connection">
    <Type><DefaultValue>ip</DefaultValue></Type>
    <BusAddress><Disabled>true</Disabled></BusAddress>
    <IPport><DefaultValue>22</DefaultValue></IPport>
    <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
    <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
  </PortSettings>
  ```
- **Virtual (`virtual`)**: No communication ports needed. Omit `<PortSettings>` or supply `<PortSettings name="Virtual Connection" />`.

---

## Parameters

Parameters are the fundamental data units. **Full XML examples, attribute tables, valid children list, schema verification rule, position uniqueness rule, and Read/Write pair XML**: `dataminer-xml-authoring/references/parameters.md`.

**Parameter types**: `read` (device value), `write` (sends to device), `array` (table), `dummy` (internal trigger-only — MUST have `<Information><Subtext>`; NEVER for HTTP response intermediates — those are `type="read"` with `RTDisplay=false`), `bus`, `fixed`, `group`. **NEVER use `<Type>read write</Type>`** — write-capable parameters are always two separate `<Param>` elements.

### Standalone Parameter Naming Convention

> **⚠ INLINE AUTHORING GATE — apply at the moment you write each `<Name>` and `<Description>`, not during a post-generation scan:**
> Before committing any `<Name>` value, confirm its first character is **lowercase**. PascalCase names look plausible and are invisible in a quick visual review — they surface as NamingConventions WARN or FAIL findings after submission.
>
> **PIDs 100–999 (system-info scalars such as `SystemName`, `SystemDescription`, `SystemUptime`) are a common source of NamingConventions WARN findings.** Before finalising, inspect the `<Name>` children of `<Protocol><Params><Param>` elements and correct uppercase-first values. Do not scan unrelated protocol-level `<Name>` elements.
>
> **This rule applies equally to table column `<Name>` elements.** The prefix derived from the table `<Name>` must keep its own casing — a table named `interfaces` produces column prefix `interfaces` (lowercase `i`), **not** `Interfaces`. Example: table `<Name>interfaces</Name>` → columns `interfacesName`, `interfacesIpAddress`, `interfacesLinkState`. Writing `InterfacesName` is a NamingConventions WARN or FAIL even though it starts with the correct prefix word.
>
> **Multi-word compound table names follow the same rule.** If the table `<Name>` is itself a multi-word camelCase string (e.g. `bucInfo`), the column prefix must equal that exact string verbatim — `BucInfoIndex` is wrong even though each individual word looks correctly cased. The first character of the whole prefix must be lowercase: `bucInfoIndex`, `bucInfoModelNumber`, `bucInfoFirmwareVersion`. When 10+ columns share the same table, one capitalisation mistake propagates to every column at once.
>
> **Disambiguate duplicate table-column descriptions.** When columns in different tables use the same description, append the table description or a clear abbreviation in parentheses, for example `Name (Interfaces)` and `Name (Devices)`. A suffix is not required when the description is already unambiguous.

**All `<Param>/<Name>` elements** — standalone params AND table/column params — MUST use **camelCase**: first character **lowercase**, subsequent words title-cased. **NEVER** start any parameter name with an uppercase letter.

| Wrong ❌ | Correct ✅ | Notes |
|---|---|---|
| `Hostname` | `hostname` | Single word: all lowercase |
| `SoftwareVersion` | `softwareVersion` | Multi-word: first word lowercase |
| `SystemDescription` | `systemDescription` | PID 100–999 prime source |
| `SystemName` | `systemName` | PID 100–999 prime source |
| `SystemUptime` | `systemUptime` | PID 100–999 prime source |
| `AdminStatus` | `adminStatus` | |
| `FirmwareVersion` | `firmwareVersion` | PID 1–10 common |
| `IpAddress` | `ipAddress` | Acronym as first word: fully lowercase |
| `SerialNumber` | `serialNumber` | |
| `DeviceModel` | `deviceModel` | |
| `ApiKeyHeader` | `apiKeyHeader` | HTTP infrastructure params |
| `SystemInfoStatusCode` | `systemInfoStatusCode` | HTTP response/status params |
| `InterfacesStatusCode` | `interfacesStatusCode` | HTTP response/status params |
| `InterfacesName` | `interfacesName` | Table column: prefix must be camelCase |
| `InterfacesIpAddress` | `interfacesIpAddress` | Table column: acronym prefix stays lowercase |
| `InterfacesLinkState` | `interfacesLinkState` | Table column: PascalCase prefix is wrong |
| `InterfacesTxPackets` | `interfacesTxPackets` | Table column: abbreviations follow camelCase |
| `DeviceKey` | `deviceKey` | Table column: single-word prefix trap |
| `DeviceName` | `deviceName` | Table column: single-word prefix trap |
| `DeviceStatus` | `deviceStatus` | Table column: single-word prefix trap |
| `DeviceSpeed` | `deviceSpeed` | Table column: single-word prefix trap |
| `InterfaceKey` | `interfaceKey` | Table column: singular "Interface" prefix trap |
| `InterfaceName` | `interfaceName` | Table column: singular "Interface" prefix trap |
| `InterfaceType` | `interfaceType` | Table column: singular "Interface" prefix trap |
| `InterfaceSpeed` | `interfaceSpeed` | Table column: singular "Interface" prefix trap |
| `InterfaceStatus` | `interfaceStatus` | Table column: singular "Interface" prefix trap |
| `BucInfoIndex` | `bucInfoIndex` | Table column: multi-word compound prefix trap |
| `BucInfoModelNumber` | `bucInfoModelNumber` | Table column: multi-word compound prefix trap |
| `BucInfoSerialNumber` | `bucInfoSerialNumber` | Table column: multi-word compound prefix trap |
| `BucInfoFirmwareVersion` | `bucInfoFirmwareVersion` | Table column: multi-word compound prefix trap |
| `BucInfoPowerWatts` | `bucInfoPowerWatts` | Table column: multi-word compound prefix trap |
| `BucInfoFrequencyBand` | `bucInfoFrequencyBand` | Table column: multi-word compound prefix trap |
| `BucInfoRFRange` | `bucInfoRFRange` | Table column: multi-word compound prefix trap |

> **Quick check**: inspect only `<Protocol><Params><Param><Name>` values. Other protocol sections also contain `<Name>` elements and may legitimately use different casing.
>
> **`<Name>` values MUST contain only alphanumeric characters** — no spaces, hyphens, or underscores.

### `<SNMP><OID type="...">` Valid Values

Only `complete`, `auto`, `composed`, `wildcard`. **NEVER** use SNMP data type names (`octetstring`, `timeticks`, `integer`, etc.), SNMP operation names, or direction names (`read`, `write`) as the `type` attribute of `<OID>` — all cause **XSD ERROR**. SNMP data types belong in a separate `<SNMP><Type>` child element. Full patterns: `dataminer-xml-authoring/references/parameters.md`.

### Read/Write Parameter Pairs

Two separate `<Param>` elements — one `read`, one `write`. DataMiner links them as a single control when:
1. `<Name>` is **identical** on both (exact match — different names = two separate unlinked controls)
2. `<Description>` is **identical** on both
3. `<Positions>` are **identical** on both

Write ID = read ID + **50** (preferred) or **+100** (max). **NEVER** use offset > 100 (❌ read 103 → write 1103). Write param appears **immediately after** read param in XML. All params ordered by ascending ID.

> **Full XML examples and Read/Write Pair Pre-Completion Checklist**: `dataminer-xml-authoring/references/parameters.md`

---

---

## SNMP Writes (Set Operations)

SNMP write parameters send SET requests to the remote device when the user changes their value. DataMiner uses an **optimistic update**: the corresponding read parameter is immediately set to the new value, even before the SET reaches the device. Because the SET can fail, **always ensure a verification GET** follows the write to restore the correct value if needed.

**Recommended default for every supplied single-parameter write**: Use the
`snmpSetAndGet="true"` attribute on the **`<Param>` opening tag** of the write parameter — it
handles both the SET and the verification GET automatically with no extra triggers or actions.
Verify that each write parameter has an explicit SET behavior; do not invent writable OIDs or
device capabilities. **NEVER place this attribute on `<SNMP>`, `<OID>`, or any child element** —
it is only valid on `<Param>` itself: `<Param id="150" snmpSetAndGet="true">`.

Alternative options include `options="snmpSet"` (fire-and-forget SET, add your own verification trigger), `options="snmpSetWithWait"` (blocking SET), and `options="snmpSetAndGetWithWait"` (blocking SET + GET).

> **Full patterns and decision tables**:
> - Single parameters: `dataminer-xml-authoring/references/snmp-writes-single.md`
> - Table cells: `dataminer-xml-authoring/references/snmp-writes-table-cell.md`

---

## Groups

Groups define what to poll together in a single communication cycle. **Full XML examples, group types table, ping group pattern**: `dataminer-xml-authoring/references/groups-timers-triggers-actions.md`.

**Key rules:**
- SNMP scalar groups use `<Type>poll</Type>` with scalar read `<Param>` entries. Set
  `multipleGet="true"` on `<Content>` when the group contains two or more scalar reads; omit it
  for a singleton group and for table groups. Keep each group to at most 10 SNMP parameter
  references, and put each SNMP table in its own group. Count the direct `<Param>` entries when
  finishing a group; split 11 reads into groups of 10 and 1, and omit `multipleGet` on the singleton.
  Decide independently for each group; never copy `multipleGet` from one group's `<Content>` to another.
- **CRITICAL — multipleGet on groups CANNOT be used for groups with table parameters in it.** Never set `multipleGet="true"` on a table polling group. `multipleGet` is strictly for groups with 2+ scalar read parameters. Table retrieval methods (`multipleGetBulk`, `multipleGetNext`) are configured on the table parameter's `<SNMP><OID options="...">` tag, never on the group.
- HTTP sessions: `<Type>poll</Type>` + `<Content><Session>` — **NEVER** `poll action` for HTTP.
- **CRITICAL — SNMP ping group**: The **first `<Group>`** in `<Groups>` must be `<Type>poll</Type>`. An `After Startup` (`poll action`) group placed first causes MAJOR "Ping group for 'snmpv2' connection is not a 'snmpv2' poll group" **and RTEs at runtime**. Always assign `id="1"` to the scalar poll group.
- Use the `connection` attribute to target a specific connection.

---

## Timers

Timers schedule when groups are polled. **Full XML examples and design rules**: `dataminer-xml-authoring/references/groups-timers-triggers-actions.md`.

Default speeds: alarm/status = **10s**, config = **1min**, static = **1hr**. Default interval: **75ms**.
Timers start with the element and are the normal polling path; do not queue timer-scheduled groups
again from after-startup logic (the after-startup chain can still be used for one-time initialization). Use `initial="true"` on `<Time>` when the first poll must happen
immediately. Use `relativeTimers="true"` on `<Type>`.

---

## Triggers

Triggers react to protocol events and execute actions. **Full XML examples and trigger times table**: `dataminer-xml-authoring/references/groups-timers-triggers-actions.md`.

---

## Actions

**Full XML examples**: `dataminer-xml-authoring/references/groups-timers-triggers-actions.md`.

Use `<Type>execute</Type>` for ordinary action-triggered group execution. Use
`<Type>execute next</Type>` only when the group must run immediately after the current item;
timer-scheduled polling does not need an action, and after-startup logic must not re-queue groups
already assigned to timers (though the after-startup chain can still be used for one-time initialization).

The validator rule below is conditional: it does not require an AfterStartup action for routine
poll groups already scheduled by timers.

> **CRITICAL — AfterStartup actions MUST use `<On id="N">group</On>`** with `<Type>execute</Type>`. The validator reports MAJOR "After startup Action must have an On tag with value 'group'" for any other `<On>` value. **NEVER** write `<On type="group" id="N">` (putting `type` as an XML attribute) — causes **XSD ERROR** "The 'type' attribute is not declared".

---

## Alarming, Monitoring & Trending

Alarm tags use abbreviated names (`CH`, `MaH`, `MiH`, `WaH`, `Normal`, `WaL`, `MiL`, `MaL`, `CL`). **All valid operational parameters MUST have `<Alarm><Monitored>true</Monitored>`** — every displayed operational health, status, and telemetry parameter (voltages, currents, power, frequencies, battery charge/capacity, remaining runtimes, temperatures, fan speeds, link states, error rates, operational status enums with `<RTDisplay>true</RTDisplay>`) is valid for alarming and must be monitored with appropriate default thresholds (or justified `2.5.1` suppression). Only non-alarmable parameters (write parameters, dummy parameters, table array containers, index PKs, display keys, RTDisplay=false intermediates, static asset information, and volatile tables) omit `<Alarm>`. Every `<Alarm>` block that is present explicitly starts with `<Monitored>true</Monitored>` (or `<Monitored>false</Monitored>` if intentionally unmonitored). Provide default thresholds when industry norms exist; suppress 2.5.1 when no reasonable default exists. Add units when meaningful; suppress 2.9.7 for dimensionless numbers. Add range when bounded; suppress 2.11.1 for unbounded counters.

> **Full reference**: `dataminer-xml-authoring/references/authoring-best-practices.md` — threshold guidelines, unit/range suppression examples, trending configuration.

---

## Tables (Array Parameters)

### SNMP Table Persistence Rule

Automatically polled SNMP table columns MUST NOT be persisted. For every `<ColumnOption type="snmp">`, omit the `save` token from the `options` attribute. SNMP polling refreshes these values, so saving them is unnecessary and can restore stale values before the next poll.

This rule is scoped to automatically polled SNMP columns. It does not prohibit `save="true"` on standalone configuration or state parameters, or `;save` on explicitly justified non-SNMP columns such as `retrieved`, `custom`, `state`, DCF, or foreign-key columns. Alarm monitoring and trending do not, by themselves, justify saving an SNMP-polled value.

> **IMPORTANT**: Even when a connector is table-heavy, you **MUST** still create a General page with at least one scalar parameter. **Write the General page scalar parameters FIRST, before any table parameters.** A `pageOrder` that lists "General" but has no parameter with `<Page>General</Page>` in its `<Positions>` block causes **MAJOR "The specified page 'General' does not exist"** AND **MAJOR "The specified defaultPage 'General' does not exist"**.

> **TABLE GENERATION GATE — apply to EVERY table, without exception:**
> These five rules cause MAJOR/MINOR/NamingConventions findings on **every table** and **every column** when violated. Verify each rule for each table as you write it, not only in the post-completion pass:
> 0. **Table and column names are mechanically linked** — choose a concise camelCase table `<Name>` that starts lowercase. For an SNMP table, deriving it from the MIB OBJECT-TYPE name by removing a trailing `Table` is recommended; a clear descriptive camelCase name is also valid. Every column `<Name>` then uses the exact table `<Name>` character-for-character as its prefix. Do not change casing or singularize/pluralize the prefix while creating column names.
> 1. **`<NamingFormat>` MUST use separator-based format** — **NEVER** write only static text (`<NamingFormat>Row</NamingFormat>`) or bracket syntax (`<NamingFormat>[1002]</NamingFormat>`). Both cause MAJOR "Missing dynamic part(s) in NamingFormat". The correct format uses the **first character as the separator** (`,`), followed by bare column PIDs. ❌ `<NamingFormat>Interface</NamingFormat>` (static) → ❌ `<NamingFormat>[1002]</NamingFormat>` (brackets — **not valid**) → ✅ `<NamingFormat>,1002</NamingFormat>` (separator-based)
> 2. **PK column `<Interprete><Type>` MUST be `string`** — The column at `<ColumnOption idx="0">` is the primary key. **ALWAYS** use `<Type>string</Type>` in its `<Interprete>` block, **even when the SNMP index is a numeric value**. Using `<Type>double</Type>` triggers MAJOR "Invalid value 'double' in tag 'Interprete/Type' for primary key column" on every affected table. ❌ `<Type>double</Type>` on PK → ✅ `<RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType>`
> 2b. **Display key column `<Interprete><Type>` MUST also be `string`** — When a table has a non-SNMP `<ColumnOption type="displaykey">` column (see Rule 4), that column **ALWAYS** uses `<Type>string</Type>` in its `<Interprete>` block, **even when the column contains a numeric value**. Using `<Type>double</Type>` triggers MAJOR "Invalid value 'double' in tag 'Interprete/Type' for display key column" — a distinct MAJOR from the PK finding. This rule applies only to non-SNMP displaykey columns (columns with no `<SNMP><OID>` block). ❌ `<Type>double</Type>` on display key column → ✅ text display key: `<RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType>`; numeric-valued display key: `<RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType>`
> 3.**Column params MUST NOT have `<Positions>`** — **NEVER** add a `<Positions>` block inside a column param's `<Display>`. `<Positions>` belongs only on the table array param (`<Param type="array">`). Every column with `<Positions>` triggers MINOR "Unexpected RTDisplay(true)" — and it fires in bulk, once per column. With 4 tables × 8 columns, a single mistake produces **30+ MINOR findings simultaneously** and causes the Validator check to fail. ❌ `<Display><RTDisplay>true</RTDisplay><Positions>…</Positions></Display>` on a column → ✅ `<Display><RTDisplay>true</RTDisplay></Display>` (no Positions). **After writing EACH column param, immediately verify it has no `<Positions>` before writing the next — do not defer this check. ⚠️ PER-TABLE SELF-CHECK: After finishing ALL column params for this table, count the `<Positions>` elements in the XML you just wrote for this table block. Expected count: exactly **1** (only the `<Param type="array">` owns `<Positions>`). If count > 1, you have mistakenly added `<Positions>` to one or more column params — find each excess `<Positions>` block and remove it **before** writing the next table.**
> 4. **SNMP columns MUST have `type="snmp"` — NEVER `type="displaykey"` on a column with `<SNMP><OID>`** — Every `<ColumnOption>` whose corresponding `<Param>` has an `<SNMP><OID>` block **MUST** use `type="snmp"`. **NEVER** put `type="displaykey"` on an SNMP-polled column — `displaykey` is reserved for **non-SNMP columns** (no `<SNMP><OID>` block) that are auto-populated by DataMiner from the `<NamingFormat>` concatenation. When `<NamingFormat>` references a **single PID** (e.g., `,1002`) and that column is SNMP-polled, **no separate displaykey column is needed** — the SNMP column stays `type="snmp"`. When `<NamingFormat>` references **multiple PIDs** (e.g., `,1002,1003`), add a **separate non-SNMP column** with `type="displaykey"` (no `<SNMP><OID>`, `<Interprete><Type>string</Type>`) to hold the concatenated display key. ❌ `type="displaykey"` on a column that has `<SNMP><OID>1.3.6…</OID></SNMP>` → ✅ `type="snmp"` on that SNMP column; add a separate non-SNMP `type="displaykey"` column only when NamingFormat has multiple PIDs
> 5. **`<ArrayOptions index="0">` ALWAYS** — The `index` attribute identifies the primary key column by its 0-based `idx` value. Since the PK **must always be the first column** (`idx="0"`), `index` **MUST always be `"0"`**. Any non-zero value shifts the PK to a later column and triggers MINOR "Unrecommended value 'N' in attribute 'index'. Recommended values '0'" — once per offending table. ❌ `<ArrayOptions index="1">`, `<ArrayOptions index="2">` → ✅ `<ArrayOptions index="0">`
> 6. **Table and column `<SNMP>` blocks MUST be present — and they use DIFFERENT formats** — For SNMP connectors, the table array param **MUST** have `<SNMP><Enabled>true</Enabled><OID type="complete">table-oid</OID></SNMP>` and **every** column param **MUST** have `<SNMP><OID>column-oid</OID></SNMP>`. **NEVER copy the table's SNMP block onto a column** — column `<SNMP>` blocks use a **minimal format**: NO `<Enabled>`, NO `type=` attribute on `<OID>`, NO `id=` attribute on `<OID>`. Using the table format on columns (e.g. `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">column.oid</OID></SNMP>` ❌) causes MAJOR "Unsupported Param reference in SNMP/OID@id" (2.48.4) on **every column**. Omitting `<SNMP>` blocks entirely means the table is never polled. **Verify IMMEDIATELY after writing each table and its columns — do not defer to post-completion.** ❌ column with table-style SNMP: `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">1.3.6.1.2.1.2.2.1.2</OID></SNMP>` → ✅ table: `<SNMP><Enabled>true</Enabled><OID type="complete">1.3.6.1.2.1.2.2</OID></SNMP>`, column: `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>`
> 7. **Table array param `<Display>` MUST contain BOTH `<RTDisplay>true</RTDisplay>` AND `<Positions>`** — **NEVER** write `<Display><RTDisplay>true</RTDisplay></Display>` on a table array param without a `<Positions>` block. RTDisplay alone (no Positions) causes MINOR "Unexpected RTDisplay(true)" on the table AND **cascades to every column param** — with 4 tables × 8 columns this produces **30+ MINOR findings simultaneously** and also generates MAJOR "The specified page 'X' does not exist" for each page the missing `<Positions>` would have referenced. ❌ `<Display><RTDisplay>true</RTDisplay></Display>` on a table array param → ✅ `<Display><RTDisplay>true</RTDisplay><Positions><Position><Page>Interfaces</Page><Row>0</Row><Column>0</Column></Position></Positions></Display>`. **Verify IMMEDIATELY after writing each table array param's `<Display>` block — confirm both child elements are present before moving to the next table.**
> 8. **NEVER use `displayColumn` — ALWAYS use `<NamingFormat>`** — **NEVER** write `displayColumn="N"` on `<ArrayOptions>`. The `displayColumn` attribute is deprecated and causes MINOR "Unrecommended use of displayColumn" for **every** table that uses it. **ALWAYS** use a `<NamingFormat>` child element instead. Check this **as you write each `<ArrayOptions>` block** — do not defer to the post-completion pass. ❌ `<ArrayOptions index="0" displayColumn="1">` → ✅ `<ArrayOptions index="0"><NamingFormat>,1002</NamingFormat>` (the referenced SNMP column keeps `type="snmp"`)
> 9. **Make a compatible `volatile` decision** — `volatile` means DataMiner will never write this table's rows to the database. Use it only when there is no alarm monitoring, `save` column, foreign key, DCF usage, or DVE usage. If expected row additions/deletions exceed 7 changes/minute or 10 000 changes/day on the same element, the docs require `volatile`. If that high-churn table also needs an incompatible behavior, stop and redesign or split the table instead of silently choosing one requirement or emitting both. **NEVER** write `options=""`; omit the attribute when no option applies.
> 10. **Table array param `<Measurement>` MUST use `table` type — NEVER `discreet`** — **ALWAYS** write `<Measurement><Type options="tab=columns:...">table</Type></Measurement>` on a `<Param type="array">`. **NEVER** set `<Measurement><Type>discreet</Type>` on a table array param — `discreet` is the measurement type for enum scalar and column params, not for table container params. Using `<Type>discreet</Type>` on a table array param causes MAJOR **"Missing 'Measurement/Discreets' tag for 'discreet' Param with ID 'X'"** — once per table. With 4 tables this produces **4 MAJOR findings simultaneously**. **Verify IMMEDIATELY after writing each table array param's `<Measurement>` block.** ❌ `<Measurement><Type>discreet</Type></Measurement>` on a `<Param type="array">` → ✅ `<Measurement><Type options="tab=columns:1001|0-1002|1,lines:25,width:100-200,sort:INT-STRING,filter:true">table</Type></Measurement>`
> 11. **`<NamingFormat>` MUST reference user-meaningful columns when the PK is not meaningful** — When the primary key (index) column contains values that are not meaningful to an operator (sequential integers, GUIDs, internal hashes, SNMP numeric indices), the `<NamingFormat>` MUST reference a column (or combination of columns) whose values are meaningful to the end user. Example: PK = `1` (not meaningful) → `<NamingFormat>,1002</NamingFormat>` where column 1002 holds `PSU 1` (meaningful because PSU = Power Supply Unit 1). If the PK itself is already user-meaningful (e.g., interface name `eth0`, MAC address), `<NamingFormat>` can reference the PK column directly. **Multi-PID display key rule**: When `<NamingFormat>` references **more than one PID** (e.g., `,1002,1003` → "Slot 1/Port 2"), a dedicated `<ColumnOption type="displaykey">` column MUST be added as the **last** column in the table. This column is auto-filled by SLElement with the concatenated display key value — it has no `<SNMP><OID>` block, uses `<Interprete><Type>string</Type>`, and cannot be trended, alarmed, or saved. When `<NamingFormat>` references only a **single PID**, no separate displaykey column is needed — the referenced column (staying `type="snmp"` or `type="retrieved"`) serves as the display key directly. **Rationale**: Without a meaningful display key, alarms and UI show raw IDs (e.g., "Row 3" or "a1b2c3d4-...") — unacceptable for operator usability. ❌ Table with PK = auto-increment ID and no `<NamingFormat>` (alarms show "Row 1") → ✅ `<NamingFormat>,1002</NamingFormat>` pointing to a name column; ❌ `<NamingFormat>,1002,1003</NamingFormat>` without a displaykey column → ✅ add `<ColumnOption idx="N" pid="XXXX" type="displaykey" options="" />` as the last column
> 12. **Multiple tables on the same page MUST be stacked vertically — NEVER overlapping** — Rows are per-object: the 1st table on a page gets `<Row>0</Row>`, the 2nd gets `<Row>1</Row>`, the 3rd `<Row>2</Row>`, etc. **Pre-plan all row/column assignments for a page before writing any XML** — do NOT default every table to Row 0. Default column is `<Column>0</Column>`. A table MAY use `<Column>1</Column>` only when it has **very few displayed columns** and is placed alongside a Column 0 table on the same row. **NEVER** place two wide tables side-by-side at Column 0 + Column 1 on the same row. ❌ Two tables both at `<Row>0</Row><Column>0</Column>` on the same page → they silently overlap. ✅ Table A at `<Row>0</Row><Column>0</Column>`, Table B at `<Row>1</Row><Column>0</Column>`. **POST-WRITE CHECK**: after assigning positions to all tables on a page, verify that no two table array params share an identical Page + Row + Column combination.

```xml
<Param id="1000" trending="false">
  <Name>interfaces</Name>
  <Description>Interfaces</Description>
  <Information>
    <Subtext>Interface statistics for all network interfaces on this device.</Subtext>
  </Information>
  <Type>array</Type>
  <ArrayOptions index="0">
    <NamingFormat>,1002</NamingFormat>
    <ColumnOption idx="0" pid="1001" type="snmp" options="" />
    <ColumnOption idx="1" pid="1002" type="snmp" options="" />
    <ColumnOption idx="2" pid="1003" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete">1.3.6.1.2.1.2.2</OID>
  </SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
    <Positions>
      <Position>
        <Page>Interfaces</Page>
        <Row>0</Row>
        <Column>0</Column>
      </Position>
    </Positions>
  </Display>
  <Measurement>
    <Type options="tab=columns:1001|0-1002|1-1003|2,lines:25,width:100-150-200,sort:INT-STRING-STRING,filter:true">table</Type>
  </Measurement>
</Param>
<Param id="1001">
  <Name>interfacesIndex</Name>
  <Description>Index (Interfaces)</Description>
  <Information>
    <Subtext>Unique numeric index identifying each interface row.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>number</Type>
  </Measurement>
</Param>
<Param id="1002">
  <Name>interfacesDescription</Name>
  <Description>Description (Interfaces)</Description>
  <Information>
    <Subtext>Human-readable description of the interface as configured on the device.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP><OID>1.3.6.1.2.1.2.2.1.2</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>string</Type>
  </Measurement>
</Param>
<Param id="1003">
  <Name>interfacesStatus</Name>
  <Description>Status (Interfaces)</Description>
  <Information>
    <Subtext>Operational status of the interface (1 = up, 2 = down, 3 = testing).</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>numeric text</RawType>
    <Type>double</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <SNMP><OID>1.3.6.1.2.1.2.2.1.8</OID></SNMP>
  <Display>
    <RTDisplay>true</RTDisplay>
  </Display>
  <Measurement>
    <Type>number</Type>
  </Measurement>
</Param>
```

### Table Column Naming Convention

- **Table `<Name>`**: camelCase with no whitespace, matching the exact prefix used in column names (e.g., `interfaces`, `runningProcesses`). Removing a redundant `Table` suffix is recommended, especially when deriving a name from an SNMP OBJECT-TYPE descriptor, but `interfacesTable` remains valid when every column consistently uses that exact prefix. Derive SNMP names from the lowercase-first OBJECT-TYPE descriptor rather than the SEQUENCE type name, and never introduce spaces or change prefix casing between the table and its columns. See `dataminer-xml-authoring/references/table-naming.md` for examples.
- **Table `<Description>`**: Title Case. Use either a human-readable name (e.g., `Interfaces`, `Running Processes`) or the camelCase-split form of the MIB-derived `<Name>` (e.g., `If`, `Peth Pse Port`, `Lldp Rem`). **NEVER include the word "Table"** (e.g., `Interfaces` ✅, `InterfacesTable` ❌, `Interfaces Table` ❌).
- `<Name>`: camelCase format `tableNameColumnName` — concatenate the table name with the column name (e.g., table "interfaces" with column "Index" → `interfacesIndex`, column "Description" → `interfacesDescription`, column "Status" → `interfacesStatus`). No parenthetical suffix in the Name. **The first character MUST be lowercase** — the NamingConventions check flags any table column `<Name>` that starts with an uppercase letter.
- `<Description>`: Use a human-readable Title Case phrase. When the same description occurs in different tables, append the table description or a clear abbreviation in parentheses (e.g., `State (Interfaces)`, `State (Streams)`). A unique description does not require a suffix. Do not copy raw camelCase MIB identifiers as display text.

### Title Case Rule for Descriptions

Applies to ALL parameter `<Description>` values — both standalone and table column descriptions.

**Rule**: Capitalize every word EXCEPT the following short words when they appear in the **middle** of the description (never at the start): **a, an, and, as, at, but, by, for, in, nor, of, on, or, so, the, to, up, yet**.

> **This rule applies equally to `<Discreet><Display>` values** (the human-readable labels shown in dropdowns and toggle buttons), not only to parameter `<Description>` values. ❌ `<Display>admin up</Display>` → ✅ `<Display>Admin Up</Display>`. ❌ `<Display>not present</Display>` → ✅ `<Display>Not Present</Display>`.

> **Every `<Display>` value must start with a capital letter — regardless of source format.** This applies to camelCase MIB names, plain lowercase words, and human-authored labels alike. ❌ `<Display>yocto (10^-24)</Display>` → ✅ `<Display>Yocto (10^-24)</Display>`. ❌ `<Display>disabled</Display>` → ✅ `<Display>Disabled</Display>`. See `dataminer-xml-authoring/references/authoring-best-practices.md` for the full conversion table including plain lowercase enum names.

> **CamelCase/PascalCase MIB enum names MUST be split into separate words before applying title case.** SNMP MIB definitions use camelCase enum names (e.g., `deliveringPower`, `VoltsAC`, `Class0`). **NEVER** use these raw names directly as `<Display>` values — always split on word boundaries (uppercase after lowercase, acronym boundaries, letter-digit transitions) and then title-case. ❌ `<Display>DeliveringPower</Display>` → ✅ `<Display>Delivering Power</Display>`. ❌ `<Display>VoltsAC</Display>` → ✅ `<Display>Volts AC</Display>`. ❌ `<Display>Class0</Display>` → ✅ `<Display>Class 0</Display>`. See `dataminer-xml-authoring/references/authoring-best-practices.md` for the full conversion table.

Always capitalize:
- The **first word** of the description, regardless of length
- **Nouns, verbs, adjectives, and adverbs** even if short (e.g., "Is", "Be", "Are", "No", "Set", "Get", "Run")
- **Acronyms and initialisms** (e.g., IP, HC, DVB, MPTS) per their standard form
- **Brand/product names** per their official capitalization

| Correct ✅ | Incorrect ❌ | Why |
|-----------|-------------|-----|
| `System up Time` | `System Up Time` | "up" is a preposition here, lowercase mid-description |
| `HC in Octets (Interfaces Extended)` | `HC In Octets (Interfaces Extended)` | "in" is a preposition, lowercase mid-description |
| `In Octets (Interfaces)` | `in Octets (Interfaces)` | "In" is the first word — always capitalize |
| `Number of Ports` | `Number Of Ports` | "of" is a preposition, lowercase mid-description |
| `Bit Rate to Device` | `Bit Rate To Device` | "to" is a preposition, lowercase mid-description |

### Table Column Pre-Completion Checklist

After writing any table columns, verify each column parameter against this checklist before proceeding:

| Check | Rule | Example pass | Example fail |
|-------|------|-------------|-------------|
| `<Name>` is camelCase concat | `tableNameColumnName` | `runningProcessesCpu` | `Cpu`, `cpu`, `CPU (Running Processes)` |
| `<Name>` has no parenthetical | No `(...)` in `<Name>` | `interfacesIndex` | `Index (Interfaces)` |
| Duplicate column descriptions are disambiguated | When the same description occurs in multiple tables | `CPU (Running Processes)` | Ambiguous `CPU` in several tables |
| `<Description>` uses Title Case | Lowercase **a/an/and/as/at/but/by/for/in/nor/of/on/or/so/the/to/up/yet** mid-description only — **the first word is ALWAYS capitalized**. Common SNMP network table pitfalls: "in/out" as direction prepositions are lowercase mid-description (❌ `HC In Octets` → ✅ `HC in Octets`), but ARE capitalized when they are the first word (✅ `In Octets (Interfaces)`). "of" is always lowercase mid-description (❌ `Number Of Entries` → ✅ `Number of Entries`). "to/from" are always lowercase mid-description (❌ `Bytes To Device` → ✅ `Bytes to Device`). **Scan every `<Description>` value against this list before finishing.** | `HC in Octets (Interfaces Extended)`, `In Octets (Interfaces)`, `Out Octets (Interfaces)`, `Number of Entries (Interfaces)` | `HC In Octets`, `in Octets (Interfaces)`, `Number Of Entries (Interfaces)` |
| `<Measurement><Type>` present — **NEVER `UNDEFINED`** | Every column needs a display type matching its data. For a **numeric SNMP index PK column** use `<Type>number</Type>` (even though `Interprete/Type` is `string`). **NEVER** write `<Type>UNDEFINED</Type>` — UNDEFINED is not a valid type value and causes a MAJOR validator error. If uncertain: use `number` for numeric indexes/counters, `string` for text/MAC/IP columns. | `<Type>number</Type>` | `<Type>UNDEFINED</Type>`, *(missing)* |
| **`<Information><Subtext>` present — write INLINE** | **ALWAYS** add `<Information><Subtext>...</Subtext></Information>` to **each column as you write it** — never defer to post-completion. Subtext must provide a user-friendly description and must **never** include SNMP OIDs or low-level technical information. A connector with 4 tables × 8 columns has 32+ mandatory column Subtexts; missing any of them causes a Completeness WARN. **Do not rely solely on the final-pass count** — generate Subtext inline so it is never accidentally omitted. | `<Information><Subtext>Unique row index.</Subtext></Information>` | *(missing)* |
| **Column has `<SNMP><OID>` block** | **EVERY** SNMP column param **MUST** have `<SNMP><OID>full.column.oid</OID></SNMP>` — without this, the column is never polled and returns no data. Use the **minimal column format**: NO `<Enabled>`, NO `type=` on `<OID>`, NO `id=` on `<OID>`. Write the `<SNMP>` block **inline as you create each column** — never defer. | `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` | *(missing entirely)* — column has no `<SNMP>` block |
| No `id=` on `<SNMP><OID>` | **NEVER** add an `id` attribute to `<SNMP><OID>` in a column param, and **NEVER** copy the table array param's full SNMP block onto columns — produces MAJOR 2.48.4 + MINOR 2.47.2 for every column. Two wrong patterns: **(A)** `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">column.oid</OID></SNMP>` (table block copied); **(B)** `<OID id="3">column.oid</OID>` (MIB column index) | `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` | `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">1.3.6.1.2.1.2.2.1.1</OID></SNMP>` |
| PK column has `<Interprete><Type>string</Type>` | **ALWAYS** add `<Interprete><RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` to the index (PK) column — **NEVER** omit `<Interprete>` or use `<Type>double</Type>` on a PK column; causes a MAJOR validator error on every table | `<Interprete><RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` | `<Interprete><RawType>numeric text</RawType><Type>double</Type>…</Interprete>` — `double` on PK column ❌ |
| **Display key column has `<Interprete><Type>string</Type>`** | When a table has a non-SNMP `type="displaykey"` column (for multi-PID NamingFormat concatenation), **ALWAYS** use `<Type>string</Type>` in its `<Interprete>` block. **NEVER** use `<Type>double</Type>` — triggers MAJOR "Invalid value 'double' in tag 'Interprete/Type' for display key column". This applies only to non-SNMP displaykey columns (no `<SNMP><OID>` block). Text display keys: `<RawType>other</RawType><Type>string</Type>`. Numeric display keys formatted as strings: `<RawType>numeric text</RawType><Type>string</Type>`. | `<Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` on display key column | `<Interprete><RawType>numeric text</RawType><Type>double</Type>…</Interprete>` on display key column ❌ |
| **All SNMP columns have `<Interprete>` with `<LengthType>`**| **ALWAYS** add `<Interprete><RawType>…</RawType><Type>…</Type><LengthType>next param</LengthType></Interprete>` to **every** SNMP column param — not just the PK column. Omitting `<LengthType>` on any column causes a MAJOR "Missing tag 'LengthType'" error. String columns: `<RawType>other</RawType><Type>string</Type>`. Numeric columns: `<RawType>numeric text</RawType><Type>double</Type>`. PK always uses `<Type>string</Type>`. **NEVER use `<Type>number</Type>` in `<Interprete>` — `number` is only valid inside `<Measurement><Type>`, not inside `<Interprete><Type>`. Using `<Interprete><Type>number</Type>` causes an XSD ERROR on every affected parameter.** | `<Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>` | *(no `<Interprete>` on non-PK SNMP column)*; `<Interprete><Type>number</Type>` ❌ — use `<Type>double</Type>` |
| `<Display>` on column params: RTDisplay YES, Positions NO | Column params **MUST** have `<Display><RTDisplay>true</RTDisplay></Display>` — omitting it causes MAJOR "RTDisplay(true) expected". **NEVER** add `<Positions>` to a column param's `<Display>` block; `<Positions>` belongs only on the table array param. A column with RTDisplay=true and no Positions is **correct**. A column with RTDisplay=true AND Positions triggers MINOR "Unexpected RTDisplay(true)". | `<Display><RTDisplay>true</RTDisplay></Display>` (no Positions) on column param | `<Display><RTDisplay>true</RTDisplay><Positions>…</Positions></Display>` on column param |
| SNMP columns have `type="snmp"` — displaykey is non-SNMP only | Every `<ColumnOption>` whose `<Param>` has an `<SNMP><OID>` block **MUST** use `type="snmp"` — **NEVER** `type="displaykey"` on an SNMP-polled column. `type="displaykey"` is only for a separate **non-SNMP column** (no `<SNMP><OID>`, `<Interprete><Type>string</Type>`) that auto-holds the concatenated display key when `<NamingFormat>` references **multiple PIDs**. Single-PID `<NamingFormat>` tables referencing an SNMP column need **no** displaykey column. | `<ColumnOption idx="1" pid="1002" type="snmp" />` when 1002 is an SNMP column referenced by `<NamingFormat>,1002</NamingFormat>` | `<ColumnOption idx="0" pid="1001" type="displaykey" />` when 1001 has `<SNMP><OID>1.3.6…</OID></SNMP>` ❌ |
| **`number` column has `<Range>` or 2.11.1 suppression** | For every column with `<Measurement><Type>number</Type></Measurement>`, **ALWAYS** make an explicit range decision: add `<Display><RTDisplay>true</RTDisplay><Range><Low>0</Low><High>X</High></Range></Display>` when the range is determinable (e.g., utilisation 0–100, rates 0–device max speed, temperatures), or suppress 2.11.1 with reason `Cumulative counter with no meaningful upper bound` when the param is unbounded (byte counters, packet counters, uptime ticks). **NEVER leave a `number` column with neither `<Range>` nor a 2.11.1 suppression.** This check applies to every column in every table — with 4 tables × 4 columns, 16+ findings can fire at once if skipped. | `<Display><RTDisplay>true</RTDisplay><Range><Low>0</Low><High>100</High></Range></Display>` | *(no Range, no 2.11.1 suppression)* |
| **`number` column has `<Units>` or 2.9.7 suppression** | For every column with `<Measurement><Type>number</Type></Measurement>`, **ALWAYS** make an explicit unit decision: add `<Display><RTDisplay>true</RTDisplay><Units>X</Units></Display>` when a recognized unit applies (%, bps, Kbps, Mbps, Octets, Packets, ms, etc.), or suppress 2.9.7 with reason `Dimensionless count, no unit applicable` when no meaningful unit exists (index, count, identifier). **NEVER use non-standard unit strings** — ❌ `bit/s` → ✅ `bps`; ❌ `octets` (lowercase) → ✅ `Octets` (capital O — case-sensitive, validator reports "Obsolete unit 'octets'. New syntax 'Octets'" for the lowercase form); ❌ `bytes` → ✅ `Octets`; ❌ `packets` → ✅ `Packets`. **NEVER leave a `number` column with neither `<Units>` nor a 2.9.7 suppression.** | `<Display><RTDisplay>true</RTDisplay><Units>Octets</Units></Display>` | *(no Units, no 2.9.7 suppression)*; `<Units>octets</Units>` ❌ (lowercase); `<Units>bit/s</Units>` ❌ |
| **Operational column has `<Alarm><Monitored>true</Monitored>`** | Every column measuring operational telemetry or status (voltages, currents, power, frequencies, temperatures, statuses, error rates) in a non-volatile table **MUST** have `<Alarm><Monitored>true</Monitored></Alarm>` with standard thresholds or justified `2.5.1` suppression. Columns with alarming show header sum, heatmap, and histogram by default — always add `disableHeaderSum;disableHeatmap;disableHistogram` to `ColumnOption@options`. | `<Alarm><Monitored>true</Monitored><Normal>1</Normal><CH>2</CH></Alarm>` or with 2.5.1 suppression | Operational column with no `<Alarm>` block |

If any column fails a check, correct it before marking the task complete.

### Table Measurement Section

Only required when the table is **displayed to the user**. Hidden/background tables don't need it.

```xml
<Measurement>
  <Type options="tab=columns:1001|0-1002|1-1003|2,lines:25,width:100-150-200,sort:INT-STRING-STRING,filter:true">table</Type>
</Measurement>
```

#### `tab=` Sub-Options

| Sub-option | Format | Required | Description |
|------------|--------|----------|-------------|
| `columns` | `pid\|displayIdx` per column, dash-separated | Yes | Controls which columns are **visible** and their **display order**. `pid` must match a `<ColumnOption pid>` in `<ArrayOptions>`. `displayIdx` is a **0-based** index that sets the column's **visual position** in the table (left-to-right). Columns **not listed** in `columns:` are **hidden** from the UI — this is how to hide internal/helper columns (e.g., buffer data columns used only by QActions). The `displayIdx` is independent of `<ColumnOption idx>`. |
| `lines` | integer | No | Initial number of visible rows rendered in the table widget. Does **not** limit the actual data in the table — all rows remain accessible via scrolling. Default: `25`. |
| `width` | pixels per column, dash-separated | No | Width of each column in pixels (one value per column listed in `columns:`). If omitted, DataMiner Cube auto-sizes columns. Example: `width:100-150-200` sets three columns to 100px, 150px, and 200px. |
| `sort` | type per column, dash-separated | No | Sorting type for each column. Valid types: `INT`, `STRING`, `DATETIME`. Optionally append `\|ASC\|priority` or `\|DESC\|priority` to set a default sort direction and multi-column sort priority (0-based; lower = higher priority). Example: `sort:STRING\|ASC\|0-INT-STRING` sorts the first column ascending by default. |
| `filter` | `true` | No | Adds a filter/search box above the table. Omit entirely or set `false` to hide the filter. |

#### Hiding Columns from the UI

To hide a column (e.g., a buffer data column for rate calculations), keep its `<ColumnOption>` in `<ArrayOptions>` but **omit** its PID from the `columns:` list and omit its entries from `width:` and `sort:`. Only columns listed in `columns:` are rendered.

```xml
<ArrayOptions index="0">
  <ColumnOption idx="0" pid="1001" type="snmp" options="" />
  <ColumnOption idx="1" pid="1002" type="snmp" options="" />
  <ColumnOption idx="2" pid="1003" type="retrieved" options="" />
  <ColumnOption idx="3" pid="1004" type="snmp" options="" />
</ArrayOptions>
<Measurement>
  <Type options="tab=columns:1001|0-1002|1-1004|2,lines:25,width:80-150-120,sort:INT-STRING-STRING,filter:true">table</Type>
</Measurement>
```

> **Full syntax reference**: `dataminer-protocol-xml-reference/references/protocol-params.md` → "Param/ArrayOptions Element" and "Param/Measurement Element" sections for the full `tab=columns:...` options syntax.

### Table Rules
- **ALL columns MUST be listed in `tab=columns:` by default** — Every `<ColumnOption pid>` defined in `<ArrayOptions>` must appear in the `tab=columns:` list unless the user explicitly requests a column to be hidden (e.g., "hide the buffer column", "internal use only"). **NEVER silently omit a column from `columns:`** — doing so makes it invisible in DataMiner Cube without any indication to the user. ❌ A table with columns 1001, 1002, 1003 but `tab=columns:1001|0-1002|1` (column 1003 missing without instruction) → ✅ `tab=columns:1001|0-1002|1-1003|2` unless hiding 1003 was explicitly requested.
- Primary key must be the **first column**. First 100 bytes must be unique. **Numeric keys** preferred. **The PK column's `<Interprete><Type>` MUST always be `string`**, even when the key value is a numeric SNMP index — using `double` or any other type causes a MAJOR validator error. Correct pattern for a numeric SNMP index PK: `<Interprete><RawType>numeric text</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>`.
- **NEVER add an `id` attribute to `<SNMP><OID>` in a table column parameter, and NEVER copy the table array param's full SNMP block onto columns.** Column OIDs must use the **minimal column format**: `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` ✅ — NO `<Enabled>`, NO `type=`, NO `id=`. Two common wrong patterns: **(A)** copying the table's full SNMP block: `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">1.3.6.1.2.1.2.2.1.1</OID></SNMP>` ❌; **(B)** setting `id=` to the MIB column index: `<OID id="1000">1.3.6.1.2.1.2.2.1.1</OID>` ❌. Both cause MAJOR "Unsupported Param reference in SNMP/OID@id" (2.48.4) **plus** MINOR "Invalid combination of OID value and SNMP/OID@id" (2.47.2) for every single column — generating dozens of validator findings at once. The `id` attribute on `<SNMP><OID>` is reserved for wildcard instance-holder patterns, not for table columns.
- Use `NamingFormat` over `displayColumn` for display keys. Do not change existing `displayColumn` to `NamingFormat` (breaking change). **`NamingFormat` uses separator-based format**: the first character is the separator (use `,`), followed by parameter IDs (bare numbers) and/or static text separated by that character. A `<NamingFormat>` with no parameter ID between separators is invalid and causes a MAJOR validator error. Use the index column PID as the minimum: `<NamingFormat>,1001</NamingFormat>`, or a multi-column combination: `<NamingFormat>,1002,-,1001</NamingFormat>`. **NEVER** write `<NamingFormat>Row</NamingFormat>` or any plain text without parameter IDs. **NEVER** use bracket syntax like `[1002]` — brackets are not part of the NamingFormat schema.
- The `[IDX]` suffix is **not required** in new implementations.
- Column parameter `<Name>` must use `tableNameColumnName` camelCase format (see Table Column Naming Convention above). Append the table description or a clear abbreviation to `<Description>` only when another table uses the same description.
- Columns of type `"number"` with alarming show a header sum, heatmap, and histogram by default. **Always** add column options `disableHeaderSum`, `disableHeatmap`, and `disableHistogram` unless the user explicitly requests them enabled.
- **SNMP tables with the same index but different OID roots must be separate array parameters.** Two SNMP tables that share an index (e.g. `ifIndex`) but belong to different OID trees (e.g. `ifTable` at `1.3.6.1.2.1.2.2` and `ifXTable` at `1.3.6.1.2.1.31.1.1`) are polled as independent units and must be modelled as separate `<Param type="array">` entries in the connector. Link them via a `<Relation>` and the shared index column. Do **not** merge their columns into a single table.
- **ALWAYS add `<Display><RTDisplay>true</RTDisplay><Positions>…</Positions></Display>` to the table array parameter itself** (the `<Param type="array">`, e.g. PID 1000). Without it the table does not render in DataMiner Cube and the validator reports MAJOR "RTDisplay(true) expected on Param 'N'" errors for every such table.
- **Column params MUST have `<Display><RTDisplay>true</RTDisplay></Display>`** (omitting it causes MAJOR "RTDisplay(true) expected"). **NEVER add `<Positions>` to a column param's `<Display>` block** — `<Positions>` belongs exclusively on the table array param. A column with RTDisplay=true and no Positions is correct. A column with RTDisplay=true AND Positions triggers MINOR "Unexpected RTDisplay(true)".
- **Table polling groups: multipleGet CANNOT be used for groups with table parameters in it** — `multipleGet="true"` on `<Group><Content>` is strictly for groups containing multiple scalar parameters. It CANNOT be used on groups with table parameters in it. For SNMP tables, the retrieval method (such as `multipleGetBulk` or `multipleGetNext`) must be configured on the table parameter's `<SNMP><OID options="...">` tag, NEVER as `multipleGet` on the group.
- DO NOT place `foreignkey` on the **index column** (the column at the `idx` matching `<ArrayOptions index="...">`). The index column is the primary key and cannot also be a foreign key. Place `options=";foreignkey=parentTablePid"` on a separate non-index column.

### Data Handling Patterns
- Tables should hold **current entries** by default.
- **"Previous data comparison" pattern**: add columns for Auto Removal Delay, Missing Since, Status, and a Remove button.
- **"Infinitely growing data" pattern**: configure max rows, max time retention, delete batch size.
- **Clear table data** when polling is disabled.
- Only **save parameters** when necessary. Use `saveInterval` for frequently changing parameters.
- Respect **foreign key constraints** — remove dependent (child) rows before parent rows. The `foreignkey` option must not be on the index column, and the target table must not be volatile (see Relations section).

### The `instance` Option (Multi-Column SNMP Index)

Some SNMP tables define **multiple index columns** (composite key), meaning the row instance identifier consists of values from more than one column (e.g., PoE table indexed by group+port, LLDP table indexed by timemark+localport+remoteindex). Add `instance` to the **table OID** `options` to have DataMiner write the full composite instance identifier into the first column automatically.

**When to use `instance`:**
- The SNMP table has **2+ index columns** in its MIB definition
- The SNMP table's index is defined in a **different table** (e.g., entPhySensorTable uses entPhysicalIndex from ENTITY-MIB)

**Rules when using `instance`:**
- Place `instance` on the **table `<OID>` element only** — combine with a retrieval method: `options="instance;multipleGetBulk"`
- The first column (PK at `idx="0"`) receives the auto-generated instance value — **do NOT specify an `<SNMP><OID>` on this column**; any OID will be ignored
- All other columns **MUST** specify their column OIDs as normal
- **NEVER** put `options="instance"` on any `<ColumnOption>` element — SNMP column options must remain empty or contain only documented display options. Use `;save` only on explicitly justified non-SNMP columns. Putting `instance` on a `<ColumnOption>` causes validator errors 2922 and 2901.

```xml
<Param id="2000" trending="false">
  <Name>pethPsePort</Name>
  <Description>Peth Pse Port</Description>
  <Type>array</Type>
  <ArrayOptions index="0">
    <NamingFormat>,2002</NamingFormat>
    <ColumnOption idx="0" pid="2001" type="snmp" options="" />
    <ColumnOption idx="1" pid="2002" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete" options="instance;multipleGetBulk">1.3.6.1.2.1.105.1.1</OID>
  </SNMP>
</Param>

<Param id="2001">
  <Name>pethPsePortInstance</Name>
  <Description>Instance (Peth Pse Port)</Description>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display><RTDisplay>true</RTDisplay></Display>
  <Measurement><Type>string</Type></Measurement>
</Param>
```

### Multi-PID NamingFormat with Displaykey Column

When `<NamingFormat>` references **multiple SNMP column PIDs** (e.g., `,2003,2004`), add a **separate non-SNMP column** with `type="displaykey"` to hold the concatenated display key. This column has **no `<SNMP><OID>` block** — DataMiner auto-populates it from the NamingFormat concatenation. All SNMP columns keep `type="snmp"`.

```xml
<Param id="3000" trending="false">
  <Name>lldpRem</Name>
  <Description>Lldp Rem</Description>
  <Type>array</Type>
  <ArrayOptions index="0" options=";volatile">
    <NamingFormat>,3003,3004</NamingFormat>
    <ColumnOption idx="0" pid="3001" type="snmp" options="" />
    <ColumnOption idx="1" pid="3002" type="displaykey" options="" />
    <ColumnOption idx="2" pid="3003" type="snmp" options="" />
    <ColumnOption idx="3" pid="3004" type="snmp" options="" />
  </ArrayOptions>
  <SNMP>
    <Enabled>true</Enabled>
    <OID type="complete" options="instance;multipleGetBulk">1.3.6.1.2.1.99.1.1</OID>
  </SNMP>
</Param>

<Param id="3002">
  <Name>lldpRemDisplayKey</Name>
  <Description>Display Key (Lldp Rem)</Description>
  <Information>
    <Subtext>Concatenated display key for this table row.</Subtext>
  </Information>
  <Type>read</Type>
  <Interprete>
    <RawType>other</RawType>
    <Type>string</Type>
    <LengthType>next param</LengthType>
  </Interprete>
  <Display><RTDisplay>true</RTDisplay></Display>
  <Measurement><Type>string</Type></Measurement>
</Param>
```

> **Key distinction**: SNMP columns (with `<SNMP><OID>`) → `type="snmp"`. The displaykey column (no `<SNMP><OID>`) → `type="displaykey"`. Never mix these — putting `type="displaykey"` on an SNMP column is always wrong.

---

## Rate Calculations

Rate calculations convert incrementing counters into per-second rates. Each rate needs a **parameter triple** (Counter + Rate + Buffer Data), plus SNMP connectors need timeout/restart parameters and wiring.

> **Before implementing rate calculations**, read `dataminer-xml-authoring/references/rate-calculation-xml.md` for parameter templates, naming conventions, and timer/trigger/group wiring patterns (Custom and SNMP). For C# implementation patterns, see `dataminer-qaction/references/rate-calculations.md`.

---

## Commands & Responses

> **Full serial XML patterns** (header/trailer framing, length fields, CRC checksums, SSH, code pages, smart-serial): `dataminer-xml-authoring/references/commands-responses.md` and `dataminer-xml-authoring/references/serial-connections.md`.

### HTTP Sessions

```xml
<HTTP>
  <Session id="1" name="Get Device Status">
    <Connection id="0">
      <Request verb="GET" url="/api/v1/status">
        <Headers>
          <Header key="Accept">application/json</Header>
          <Header key="Authorization" pid="50"></Header>
        </Headers>
      </Request>
      <Response statusCode="200">
        <Content pid="100"></Content>
      </Response>
    </Connection>
  </Session>
</HTTP>
```

> `Session@id` is required; `Session@name` is optional. `Session@key` is not a schema attribute. Every request `<Header>` requires its own `key` attribute. For authentication patterns, load `dataminer-xml-authoring/references/http-auth-patterns.md`.

---

## Discrete Parameters & Measurement Types

Every displayed parameter must have `<Measurement><Type>`: `number` for numeric, `string` for text, `discreet` for enums, `number` with `options="date"/"time"/"datetime"` for temporal values. Use `<Discreets>` with `<Display>`/`<Value>` pairs for enum parameters.

> **Full reference**: `dataminer-xml-authoring/references/authoring-best-practices.md` — scalar measurement type decision table, MIB enum conversion, discrete parameter XML, date/time options, and the measurement `options` semantics table. For the `<Param>` / `<Measurement>` `options` attribute **schema** (which attributes are allowed on which element), see `dataminer-protocol-xml-reference/references/protocol-params.md`. (`volatile` table semantics are in the **Tables** section and Pre-Completion Checklist above.)

---

## DVEs (Dynamic Virtual Elements)

- DVE child element name format: `"Mother Protocol Name - Product Name"`.
- Export rules should remove table name suffixes from exported column descriptions.
- A protocol must **not auto-delete DVE children**.

---

## User Interface

Maximum **2 columns** per page. **All pages must be declared in `pageOrder`** — the `<Page>` element in a parameter's `<Positions>` references a page declared in `pageOrder`, it does not create one. **General** page required — at least one scalar parameter must have `<Page>General</Page>` in its `<Positions>` block (listing `"General"` in `pageOrder` alone is NOT sufficient, but it IS required). **Web Interface** page always last in `pageOrder`, preceded by `-----` separator — use `Webinterface#http://[Polling Ip]/` (NEVER a `<WebInterface>` element or a PID ≥ 65000). Button widths: minimum 110px, uniform. Toggle button for 2 obvious-opposite values; dropdown otherwise. Meaningful display values over `"True/False"`. Every parameter needs `<Information><Subtext>`.

> **Full reference**: `dataminer-xml-authoring/references/authoring-best-practices.md` — page layout rules, minimum General page pattern, web interface page configuration, parameter display conventions, button/control guidelines, and connection naming.

---

## Conditions & Relations

Conditions enable conditional execution on Groups, Timers, Triggers, Actions, Pairs, and QActions using `<Condition>` with operands (`id:pid`, literals, `empty`) and operators (`==`, `!=`, `AND`, `OR`, etc.). Relations define parent-child table links via `<Relation path="pid1;pid2">` with foreign key columns using `options=";foreignkey=parentPid"`.

> **Conditions reference**: `dataminer-xml-authoring/references/authoring-best-practices.md` — conditions best practice.
> **Relations reference**: `dataminer-xml-authoring/references/table-relations.md` — path semantics, relation ordering for EPM, options (`includeInAlarms`, `chain`), FK column conventions, tree control / EPM / view table integration.

---

## SNMP Traps

Trap parameters use `<Type>dummy</Type>` with `<TrapOID>` to match incoming traps by OID pattern. Bindings can be mapped to parameters or passed to QActions.

> **Full reference**: `dataminer-xml-authoring/references/snmp-traps.md` — TrapOID attributes (type, setBindings, checkBindings, ipid), alarm generation with mapAlarm, TrapMappings for complex logic, and QAction processing of allBindingInfo.

---

## HTTP Authentication Patterns

HTTP connectors support API Key, Basic Auth, and Bearer/OAuth2 token patterns via `<Header>` elements with `pid` references to credential parameters.

> **Full reference**: `dataminer-xml-authoring/references/http-auth-patterns.md` — API key header, Basic Auth (Base64 encoding), Bearer token (login session + token refresh) with complete XML examples.

---

## WebSocket Connections

WebSocket enables persistent, bidirectional communication over a single TCP connection. DataMiner implements WebSocket as an HTTP connection with `<WebSocket>true</WebSocket>` in `CommunicationOptions`. Uses Commands/Responses/Pairs for message framing.

**Key points:**
- Use **Dynamic IP (Use Case 2)** for auto-reconnection — Use Case 1 requires element restart after disconnect.
- Add `<NotifyConnectionPIDs><Connections>7</Connections>` to monitor connection status (0=Closed, 1=Open).
- Add `<WebSocketMessageType>text</WebSocketMessageType>` to Commands when the server expects text frames (default is binary).
- For custom handshakes, use an `<HTTP>` session — DataMiner auto-appends WebSocket upgrade headers.

> **Before implementing a WebSocket connector**, read `dataminer-xml-authoring/references/websocket-connections.md` for the full connection definition, use case comparison, required triggers/actions, status parameter, custom handshake, and binary handling patterns.

---

## Specialized Features

DVE export rules, EPM/Topology, Tree Controls, Matrix parameters, View Tables, Logger Tables, Multithreaded Timers, Mediation Layer, Chart Components, and XSD Schema reference are covered in the dedicated reference file.

> **Full reference**: `dataminer-xml-authoring/references/specialized-features.md` — complete XML examples and configuration for all specialized features.

---

## Redundant Polling / Inter-Element Communication / Troubleshooting

> **Before implementing** redundant polling (connection failover), inter-element communication (virtual source/destination parameters, element connections), or investigating protocol thread RTEs, read `dataminer-xml-authoring/references/advanced-connectivity.md` for configuration patterns, XML examples, and diagnostic steps.

**Quick reference:**
- **Redundant polling**: Add `communicationOptions="redundantPolling"` to `<Type>`. Requires exactly two connections of the same type.
- **Element connections**: Use `<Type virtual="source">` / `<Type virtual="destination">` on parameters. Configured in DataMiner UI, not hardcoded.
- **Protocol thread RTE**: 15-minute inactivity timeout. Break long group chains into smaller independent groups.

---

## SNMP Block Patterns (SNMP Connectors)

Three distinct `<SNMP>` block formats exist — using the wrong format on the wrong parameter type causes XSD errors or silent polling failures. **Apply the correct pattern to EVERY parameter as you write it. NEVER copy the table array block onto column params:**

| Parameter type | `<SNMP>` block format | Example |
|---|---|---|
| **Scalar `read` param** | `<SNMP><Enabled>true</Enabled><OID type="complete">full.scalar.oid.0</OID></SNMP>` — optional `<Type>` child for non-default SNMP types | `<SNMP><Enabled>true</Enabled><OID type="complete">1.3.6.1.2.1.1.1.0</OID></SNMP>` |
| **Table `array` param** | `<SNMP><Enabled>true</Enabled><OID type="complete">table.oid</OID></SNMP>` — same as scalar but OID points to the SNMP table (no trailing `.0`) | `<SNMP><Enabled>true</Enabled><OID type="complete">1.3.6.1.2.1.2.2</OID></SNMP>` |
| **Column param** | `<SNMP><OID>column.oid</OID></SNMP>` — **minimal format: NO `<Enabled>`, NO `type=` attribute, NO `id=` attribute** — ❌ NEVER `<SNMP><Enabled>true</Enabled><OID type="complete" id="1001">column.oid</OID></SNMP>` | `<SNMP><OID>1.3.6.1.2.1.2.2.1.1</OID></SNMP>` |

> **CRITICAL**: If you write ANY SNMP parameter without an `<SNMP>` block, that parameter will never be polled and the connector returns no data. The XmlStructure check reports "SNMP connector but no parameters have `<SNMP>` elements" when ALL parameters are missing their blocks — a total authoring failure.

---

## Pre-Completion Checklist

Before finishing any XML authoring task, explicitly verify each item and fix failures **in the same response**:

- [ ] **XML comment hygiene**: Scan the complete `protocol.xml` for comments. Remove explanatory, documentation, TODO, FIXME, debug, workaround, and design-note comments. Retain only copyright comments and justified `SuppressValidator` wrappers with specific reasons.
- [ ] **General page exists**: At least one scalar parameter has `<Page>General</Page>` in its `<Positions>`. Listing `"General"` in `pageOrder` alone is NOT sufficient.
- [ ] **RTDisplay on every displayed table**: Every `<Param>` with `<Type>array</Type>` shown on a page has `<Display><RTDisplay>true</RTDisplay><Positions>...</Positions></Display>`.
- [ ] **RTDisplay on every displayed scalar**: Every `<Param>` with `<Type>read</Type>` that has a `<Positions>` block **MUST** have `<Display><RTDisplay>true</RTDisplay></Display>`. **If the total count of `<RTDisplay>true</RTDisplay>` elements in the XML is 0, you have missed RTDisplay on ALL displayed parameters** — XmlStructure reports "No parameters with RTDisplay=true found" and the validator reports MAJOR errors for every displayed param. Count the `<RTDisplay>true</RTDisplay>` occurrences and verify the count is ≥ the number of parameters that have `<Positions>` blocks.
- [ ] **Table column params: RTDisplay YES, Positions NEVER**:Every table column param MUST have `<Display><RTDisplay>true</RTDisplay></Display>` but **NEVER** a `<Positions>` block. `<Positions>` belongs exclusively on the table array param (`<Param type="array">`). Adding `<Positions>` to any column param causes MINOR "Unexpected RTDisplay(true)" — this typically fires in bulk (one per column) and indicates every column in that table was mistakenly given a Positions block. Scan every column param and remove any `<Positions>` found inside its `<Display>` section. **Count-based verification**: Count the total number of `<Positions>` elements in the XML. The expected count equals (number of displayed table array params) + (number of displayed scalar params). Column params **never** own a `<Positions>` element — if your total `<Positions>` count exceeds this expected value, the excess are inside column params (typically caused by copying the scalar param template). Find every excess `<Positions>` block inside a column param's `<Display>` and remove it.
- [ ] **SNMP blocks present** (SNMP connectors): **EVERY** `read` scalar and `array` parameter **MUST** have an `<SNMP>` block — **NEVER omit it**. Column parameters need `<SNMP><OID>...</OID></SNMP>`. **MANDATORY COUNT VERIFICATION**: Count the `<SNMP>` elements in the XML. If the count is 0 for an SNMP connector, you have omitted SNMP blocks on **ALL** parameters — XmlStructure reports "SNMP connector but no parameters have `<SNMP>` elements" and the connector polls nothing. Add `<SNMP>` blocks to every `read` scalar and `array` parameter before finishing. The count of `<SNMP>` blocks must be ≥ the number of `read` scalar params + `array` params.
- [ ] **SNMP OID type attribute and block-child scan** (SNMP connectors): Scan **every `<OID type="...">` attribute** in the XML — the only valid values are `complete`, `auto`, `composed`, `wildcard`. `id` is an optional `<OID>` attribute, not an `OID@type` value. **NEVER** use SNMP data type names (`integer`, `octetstring`, `gauge`, `gauge32`, `counter`, `counter32`, `timeticks`, `ipaddress`, etc.), SNMP operation names (`Get`, `GetNext`, `GetBulk`), or direction names (`read`, `write`) — each is an **XSD ERROR** that fails the entire file. Also scan every `<SNMP>` block for invalid child elements: **NEVER** place `<GetNext/>` or `<GetBulk/>` inside a parameter's `<SNMP>` block — they are not valid children and cause an **XSD ERROR**. SNMP data types belong in `<SNMP><Type>timeticks</Type>` (a separate child element); GetNext/GetBulk walk configuration belongs at the group level only. ❌ `<OID type="id">`, `<OID type="integer">`, `<OID type="octetstring">`, `<SNMP><GetNext/></SNMP>` → ✅ `<OID type="complete">1.3.6.1.2.1.1.3.0</OID><Type>timeticks</Type>`
- [ ] **`<LengthType>next param</LengthType>` in every SNMP parameter** (SNMP connectors): **EVERY** SNMP parameter — scalars, table columns, **and write params** — **MUST** have an `<Interprete>` block containing `<LengthType>next param</LengthType>`. **NEVER omit `<Interprete>` from any SNMP param, including write params** — write params that set a table cell value are just as subject to this rule as their read counterparts. Omitting `<Interprete>` entirely, or omitting `<LengthType>` inside it, causes a MAJOR "Missing tag 'LengthType'" on **every** affected param. Verify by counting: the number of `<Interprete>` elements in the XML must equal the number of SNMP `<Param>` elements (reads + writes + table columns). If the counts differ, find and fix the missing blocks before finishing.
- [ ] **`volatile` table decision**: Use `volatile` only when there is no alarm monitoring, `save` column, foreign key, DCF usage, or DVE usage. If expected row additions/deletions exceed 7 changes/minute or 10 000 changes/day on one element, the docs require `volatile`; if an incompatible behavior is also required, stop and redesign or split the data model. **NEVER** write `options=""`; omit the attribute when no option applies.
- [ ] **First `<Group>` in `<Groups>` is a `poll` group** (SNMP connectors): DataMiner selects the **first defined `<Group>`** element as the ping group for the SNMP connection. **Verify that the very first `<Group>` in `<Groups>` has `<Type>poll</Type>`** and references at least one SNMP scalar parameter. An "After Startup" `<Type>poll action</Type>` group placed first causes MAJOR "Ping group for 'snmpv2' connection is not a 'snmpv2' poll group" and RTEs at runtime. If the After Startup group is currently first, reorder so a `<Type>poll</Type>` scalar SNMP group precedes it.
- [ ] **pageOrder consistency** (bidirectional — `pageOrder` is the authoritative page declaration): **Pages are declared by listing them in `pageOrder`** — a parameter's `<Positions><Page>` element references an existing page, it does NOT create one. **EVERY page name referenced in ANY parameter's `<Positions><Page>` element MUST appear in `pageOrder`** — a page present in `<Positions>` but absent from `pageOrder` is invisible in DataMiner Cube and causes MAJOR validator errors ("The specified page 'X' does not exist"). Conversely, every page listed in `pageOrder` must have at least one parameter positioned on it. **If `pageOrder` contains only `"General"` but parameters reference `"Interfaces"`, `"PoE"`, `"LLDP"`, etc., those pages do not exist and the Completeness check reports page count 0 and the validator reports MAJOR for every missing page.** Fix: collect the unique set of `<Page>` values from all `<Positions>` blocks and verify each one appears in `pageOrder`.
- [ ] **WebInterface page present**: `pageOrder` contains `Webinterface#http://[Polling Ip]/` for non-virtual connectors. Added as the last entry after a `-----` separator. **NEVER** add a `<WebInterface>` XML element.
- [ ] **NamingFormat uses separator-based PID references — NEVER `displayColumn` attribute, NEVER `naming=` in `<ArrayOptions options>`**: **NEVER** use the `displayColumn="N"` attribute on `<ArrayOptions>` — it is deprecated and causes MINOR "Unrecommended use of displayColumn" for every affected table. ❌ `<ArrayOptions index="0" displayColumn="1">` → ✅ `<ArrayOptions index="0"><NamingFormat>,1002</NamingFormat>`. Every table's `<NamingFormat>` uses the separator-based format (first char = separator, e.g. `,`) with at least one bare parameter ID referencing an actual column PID (e.g. `<NamingFormat>,1002</NamingFormat>`). A static string with no parameter IDs, or bracket syntax like `[1002]`, causes a MAJOR error. **Also verify that no `<ArrayOptions>` element has a `naming=` token in its `options` attribute** — `naming=` in `ArrayOptions@options` causes MAJOR "Option 'naming' in attribute 'ArrayOptions@options' references a non-existing Param". Display keys belong **exclusively** in the `<NamingFormat>` child element; if a `naming=` token is present in `<ArrayOptions options="...">`, remove it and add/correct `<NamingFormat>,pid</NamingFormat>` as a child.
- [ ] **Table column naming**: Each column `<Name>` is camelCase `tableNameColumnName`, where `tableName` is the exact value in the table's `<Name>` element. Removing a redundant `Table` suffix is recommended, but consistency is mandatory: the column prefix must match the chosen table name character-for-character. Disambiguate duplicate column descriptions across tables with a parenthetical table description or abbreviation.
- [ ] **Parameter `<Name>` is camelCase — NEVER PascalCase**: The NamingConventions check enforces lowercase-first on **standalone `read` parameters** and on **all table column parameters**. For every other `<Param>` (`write`, `dummy`, `fixed`, `bus`, `group`) keep the `<Name>` camelCase as a style convention even though the check does not currently flag them. Scan ALL params including write params in read/write pairs and internal params like AfterStartup. Common violations: ❌ `<Name>Hostname</Name>` → ✅ `<Name>hostname</Name>`; ❌ `<Name>SoftwareVersion</Name>` → ✅ `<Name>softwareVersion</Name>`; ❌ `<Name>StatusCodeVMs</Name>` → ✅ `<Name>statusCodeVMs</Name>`; ❌ `<Name>SystemDescription</Name>` → ✅ `<Name>systemDescription</Name>`. **Single-word device-property names (`Hostname`, `Version`, `Uptime`, `Status`, `Model`) are the prime violation source** — they look like normal noun capitalizations but the NamingConventions check requires lowercase-first on `read` params and table columns. If any checked `<Name>` begins with uppercase, correct it before finishing — each violation is a separate NamingConventions finding.
- [ ] **Multi-table page layout — no overlapping table positions**: For every page that has more than one table array param positioned on it, verify that each table has a **unique Row** (0, 1, 2 …). No two tables may share the same Page + Row + Column. Default column is 0; Column 1 is allowed only for narrow tables (very few columns). ❌ Multiple tables all at `<Row>0</Row><Column>0</Column>` on the same page → all overlap silently. ✅ Tables stacked: Row 0, Row 1, Row 2 …
- [ ] **No orphaned parameter content**: After every `</Param>` closing tag, the next element is either another `</Param>` or a `<Param id="X">` opening tag.
- [ ] **`<Information><Subtext>` on every `<Param>`**: Count every `<Param>` block (scalars, **table array params**, write params, table columns, dummy/internal). Every single one must contain `<Information><Subtext>`. Scan the generated XML top-to-bottom — if the count of `<Information>` elements does not match the count of `<Param>` elements, add the missing subtexts before finishing. **For SNMP connectors with multiple tables, the count is large (e.g., 4 tables × 8 columns = 32 column params, plus 4 table array params, plus scalars and write params = 37+ total). Table array params (`<Type>array</Type>`) are the most commonly forgotten — they are written first and treated as structural elements, but EVERY `<Param>` requires `<Information><Subtext>` without exception.** If all parameters were generated without Subtext, do a complete pass now: for each `<Param>` that lacks `<Information><Subtext>`, add `<Information><Subtext>Brief semantic description</Subtext></Information>` immediately after `<Description>`. Subtext should describe the parameter in plain language for operators; never include SNMP OIDs or low-level technical details. Do NOT skip write params, PK index columns, or table array params — every `<Param>` without exception.
- [ ] **Units or 2.9.7 suppression on every `number` param**: For every parameter with `<Measurement><Type>number</Type></Measurement>`, make an explicit decision: either add `<Display><Units>X</Units></Display>` (when a recognized physical unit applies — %, dBm, bps, Kbps, Mbps, ms, s, MHz, GB, MB, W, deg C, etc.) **or** wrap `<Display>` with `<!-- SuppressValidator 2.9.7 <reason> -->`. **NEVER leave a number param with neither Units nor a 2.9.7 suppression** — the validator reports a MINOR finding for every such parameter. See `dataminer-validation` skill's 2.9.7 section for the valid unit registry and reason templates. Common reason: `Dimensionless count, no unit applicable`; `Index parameter, no unit applicable`.
- [ ] **Alarm monitoring on valid parameters**: All valid operational health, status, and telemetry parameters (battery capacity %, remaining run time, voltages, currents, power, frequencies, status enums, link states, error rates) MUST have `<Alarm><Monitored>true</Monitored>` with sensible default thresholds (or justified `SuppressValidator 2.5.1` when nominal values depend on installation/grid context or device defaults are unstandardized). Only non-alarmable parameters (write parameters, dummy parameters, table array containers, index PKs, display keys, RTDisplay=false intermediates, static asset information, and volatile tables) omit `<Alarm>`. Every `<Alarm>` block that is present explicitly starts with `<Monitored>true</Monitored>` (or `<Monitored>false</Monitored>` if intentionally unmonitored).
- [ ] **Range or 2.11.1 suppression on every displayed scalar `number` param**: For every **non-column** scalar parameter with `<Measurement><Type>number</Type></Measurement>` and `<RTDisplay>true</RTDisplay>`, make an explicit range decision: add `<Range><Low>X</Low><High>Y</High></Range>` inside `<Display>` when the range is determinable (percentages 0–100, signal levels, temperatures, counters with a device-spec maximum) — **or** suppress 2.11.1 with a reason when the param is genuinely unbounded (cumulative byte/packet counters, uptime ticks, sequence numbers). **NEVER leave a displayed scalar `number` param with neither `<Range>` nor a 2.11.1 suppression.** (Table column params have a separate Range check in the Table Column Pre-Completion Checklist above.)

---

## Common Mistakes

> **MANDATORY — ALWAYS LOAD** `dataminer-xml-authoring/references/dataminer-protocol-rules.md` before writing any XML element, enum value, or attribute. For XSD structure and valid values, load the relevant `protocol-*.md` file for the element being authored.
