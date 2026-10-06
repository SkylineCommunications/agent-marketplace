---
name: dataminer-protocol-validator-prevention
description: 'DataMiner protocol.xml validator prevention rules: concise authoring guardrails derived from Skyline.DataMiner.CICD.Validators. Use when creating, editing, reviewing, or validating protocol.xml so Critical findings are prevented and Major, Minor, and Warning findings are avoided.'
argument-hint: 'Describe the protocol.xml area being authored or the validator category to prevent: params, tables, HTTP, QActions, groups, timers, tree controls, etc.'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-27
  version: 1.17
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.17 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 1.16 | 2026-09-17 | Clarified that GetColumns/SetColumns are Protocol.Extension package methods, and preserved the secure HTTP guidance and normal-vs-first-release review profile boundary. |
| 1.13 | 2026-07-17 | Added connector XML comment hygiene: forbid explanatory, TODO, debug, and design-note comments while preserving copyright and justified `SuppressValidator` comments. |
| 1.11 | 2026-06-26 | Added ⚠ camelCase callout block to Params section and Review Checklist grep check; added WebInterface page rule to Display Pages and Review Checklist; added before/after XML example for empty-vs-absent-vs-correct `<Range>` (standalone param 102 and table column 1004 patterns); added table-column-specific `<Discreets>` XML example (PID 1000+ range, MAJOR finding pattern); added RTDisplay+Positions before/after XML for column params (1001/1002 pattern); added combined `number` column template (Units + Range + RTDisplay for 1003 pattern). |
| 1.10 | 2026-06-26 | Unified `<Name>` camelCase rule: removed PascalCase exception for table column params — camelCase now applies to ALL `<Param>` `<Name>` values including table array params and column params. |
| 1.9 | 2026-06-25 | HTTP headers: added suppression as a valid alternative to `pid`-only refactor when a vendor/non-standard header key is genuinely required by the external API. Added `SuppressValidator 8.3.1` example. Updated Review Checklist to include the suppression path. |
| 1.8 | 2026-06-25 | Added ⚠ MAJOR callout block at top of HTTP section; added complete pid-only parameter example with full param definition; added explicit grep command for multi-session header key fixes; added missing HTTP header check to Review Checklist (v1.7 changelog had claimed this but it was absent). |
| 1.7 | 2026-06-25 | Elevated SNMP Critical rule to a prominent ⚠ callout in Protocol Root And Metadata and moved SNMP item to first position in Review Checklist; added HTTP headers item to Review Checklist; added empty-`<Discreets />` example to Params: Discreets; extended Units/Range and RTDisplay rules to explicitly cover table column parameters (1000+ range). |
| 1.6 | 2026-06-24 | Strengthened Copy action `id` rule with explicit Minor finding description and example; strengthened SNMP Critical rule to mention all connector types; added explicit SNMP and Copy action checks to Review Checklist. |
| 1.5 | 2026-06-24 | Added camelCase naming rule for standalone parameters in Params/IDs/Names/Descriptions; added Description title casing rule; added mandatory Units+Range rule for numeric standalone params; added Copy action `id` rule in Actions; added SNMP tag and camelCase items to Review Checklist. |
| 1.4 | 2026-06-24 | Strengthened HTTP multiplicity rules: clarified that the same bad header key generates one finding per session (not just per connection), added guidance to grep all sessions in one pass. |
| 1.3 | 2026-06-24 | Strengthened HTTP header rules: clarified "valid" header keys, added rule and example for vendor/non-standard headers (X-PAN-KEY style), added multiplicity-awareness note. |
| 1.2 | 2026-05-27 | Added Authority Matrix (XML triangle): explicit ownership and conflict resolution between `dataminer-protocol-xml-reference`, this skill, `dataminer-xml-authoring`, and `instructions/dataminer-protocol-xml.instructions.md`. |
| 1.1 | 2026-05-14 | Routed major-change workflow details to `dataminer-dis` and reduced duplicated MCC guidance. |
| 1.0 | 2026-05-14 | Initial release. |

# DataMiner Protocol Validator Prevention

This skill contains concise preventative rules derived from `C:\Projects\GitHub\Skyline.DataMiner.CICD.Validators\Protocol\ErrorMessages.xml` and the generated validator docs under `C:\Projects\GitHub\Skyline.DataMiner.CICD.Validators\Documentation\checks`.

It is intentionally not a full validator message catalog. When developing a connector, run the validator to get exact rule IDs, messages, details, and fixes. Use this skill to avoid introducing validator findings in the first place.

## Authority Matrix (XML Triangle)

Four customization files cover `protocol.xml`. Each owns a distinct concern; **defer to the owner on conflicts**:

| File | Owns | Defers to |
|---|---|---|
| `dataminer-protocol-xml-reference` | Closed-world schema facts: tags, attributes, enums, parent/child placement, cardinality. **Sole owner of `protocol-*` schema reference files** | — (wins on schema-fact conflicts) |
| `dataminer-protocol-validator-prevention` (this skill) | Validator-derived prevention rules and severity policy | `dataminer-protocol-xml-reference` for schema shape |
| `dataminer-xml-authoring` | Authoring workflow, templates, skeletons, worked examples, pedagogical explanations. **Carries no schema reference files** — defers all schema lookups to `dataminer-protocol-xml-reference` | Both of the above for schema and rule conflicts |
| Guard rails linked from `dataminer-protocol-xml-reference` | Terse rules loaded explicitly; native automatic attachment is client-dependent | All three skills above for full detail |

When a rule belongs to more than one area, keep the authoritative version here or in `dataminer-protocol-xml-reference` and have the other files cross-reference it rather than restate it. The duplicate `protocol-*.md` schema files that previously lived under `dataminer-xml-authoring/references/` were retired in favour of the single `dataminer-protocol-xml-reference` copy.

## Review Profile Selection

The `review-checklist.md` reference is the default **normal connector review baseline**. Load and walk
it for every connector review. Do not activate first-release-only evidence because a connector is new,
has version `1.0`, uses a new branch, or is classified as `NEW`.

Load
`skills/dataminer-protocol-validator-prevention/references/first-release-review-matrix.md`
only when the caller explicitly supplies `review_profile=first-release` and the review context identifies
the connector lifecycle. Run the normal baseline first, then apply the matrix's `existing`, `enhance`,
and `new` coverage rules without duplicating findings already produced by the baseline.

The first-release matrix is the checklist and release-gate policy layer; this skill remains the
technical authority for validator-prevention and protocol XML facts. When a first-release checklist
requirement conflicts with schema, validator, SDK/DIS/QAOps, vendor, or safety evidence, report
`CONFLICT`, cite the competing sources, and do not emit an invalid or unsafe fix. The raw external
checklist is supplied at execution time and is not stored in connector repositories.

## Severity Policy

- Critical findings must be resolved. Do not knowingly generate or leave Critical findings in touched XML or QAction code.
- Major findings should be avoided whenever possible. Do not introduce Major findings; fix Major findings in touched areas unless explicitly deferred.
- Minor findings should be avoided. Fix Minor findings in touched areas when practical.
- Warning findings should be addressed. If a warning is intentionally left, document why.
- `Certainty=Certain` means fix it.
- `Certainty=Uncertain` means verify it; if confirmed, fix it.
- `FixImpact=Breaking` means do not auto-fix blindly. Assess versioning and major-change impact before changing shipped behavior.
- Bubble-up or blank severity findings still come from validator logic. Investigate them; do not suppress by default.

## Validator Scope

The protocol validator catalog currently covers these authoring areas:

- Protocol root, metadata, connection model, display pages, minimum required version, endless-loop detection.
- Params, tables, columns, display, alarming, trending, interpretation, discreets, SNMP OIDs, dependencies, load sequence, volatile tables.
- QActions XML and C# validation.
- Groups, triggers, actions, timers, commands, responses, pairs.
- HTTP sessions, requests, responses, headers, and PID references.
- Relations, parameter groups, export rules, topologies, chains, tree controls.
- Ports and port settings naming.

Run the validator after XML edits. These rules reduce validator findings but do not replace validation.

Load `dataminer-dis` as well when the user is working in Visual Studio with DIS available and major-change-sensitive edits need DIS Comparer/Major Change Checker review.

## Universal Prevention Rules

- Required tags and attributes must exist, be non-empty, and be trimmed.
- IDs must be numeric where expected, must not have leading zeroes, must be in the allowed range, and must be unique in their category.
- ID references must point to existing items of the expected type.
- Names and descriptions must be non-empty, trimmed, unique where required, and free of invalid characters.
- Do not leave duplicate tags where only one is meaningful.
- Do not mix legacy and new connection syntax unless the validator explicitly supports the combination.
- Do not rely on placeholders, invalid defaults, or empty option attributes.
- Avoid creating logic loops where groups, triggers, actions, or QActions repeatedly invoke each other.
- When a fix has breaking impact, assess protocol versioning before changing the XML.

## XML Comment Hygiene

- Connector `protocol.xml` output must not contain explanatory or documentation comments.
- Do not add TODO, FIXME, debug, workaround, or design-note comments to connector XML. Do not confuse this rule with placeholder metadata values such as `TODO_CONNECTOR_NAME`; those values are handled separately and must still be replaced before release.
- Copyright comments are permitted.
- `SuppressValidator` comments are permitted only when a validator finding is genuinely not applicable, the comment directly wraps the affected element, and the reason is specific. Suppression comments are intentional validator exceptions, not a substitute for XML documentation.
- Put user-facing or authoring explanations in XML description fields, Markdown, or C# documentation comments.

## Protocol Root And Metadata

> ⚠ **FIRST CHECK — CRITICAL: Before writing or reviewing any other XML, confirm `<SNMP includepages="true">auto</SNMP>` is present as a direct child of `<Protocol>`. If it is absent, add it now. This is the single most common Critical validator finding and applies to ALL connector types — HTTP, SNMP, serial, and virtual. Do not proceed until this is verified.**

- Always include a valid root `Protocol` tag.
- Always include valid `Name`, `Provider`, `Version`, `ElementType`, `Type`, and compliancy/minimum-version metadata expected by the validator.
- For connector authoring, include and correctly fill these 10 project-required metadata tags: `Name`, `Description`, `Version`, `IntegrationID`, `Provider`, `Vendor`, `VendorOID`, `DeviceOID`, `ElementType`, and `VersionHistory`.
- Ask the user for `Name`, `Version`, `IntegrationID`, `Vendor`, `VendorOID`, `DeviceOID`, and `ElementType` when they are not provided by the task or existing connector.
- `Provider` is always `Skyline Communications`.
- If required metadata is unknown and XML must still be scaffolded, use obvious placeholders that cannot be mistaken for final values, such as `TODO_CONNECTOR_NAME`, `TODO_VERSION`, `TODO_INTEGRATION_ID`, `TODO_VENDOR`, `TODO_VENDOR_OID`, `TODO_DEVICE_OID`, and `TODO_ELEMENT_TYPE`.
- Never silently invent realistic-looking metadata values. Either use user-provided values or obvious placeholders.
- Trim `Name`, `Version`, and other metadata values.
- Avoid invalid protocol name characters and invalid protocol name prefixes.
- Keep `Provider` valid and non-empty.
- Keep `Version` non-empty and correctly formatted.
- Keep `ElementType` non-empty.
- Keep `Type` non-empty and use a supported protocol type.
- The protocol-level `<SNMP>` tag is **REQUIRED for ALL connector types including HTTP, SNMP, serial, and virtual connectors**. The validator raises a **Critical** finding when it is absent. Always include `<SNMP includepages="true">auto</SNMP>` as a direct child of `<Protocol>`, regardless of the connection type used. This is one of the most common Critical findings; verify it is present on every new or cloned connector before any other review step.
- Do not increase `MinimumRequiredVersion` without treating it as a major/system-version-impacting change.
- If using features introduced in a minimum DataMiner version, set `MinimumRequiredVersion` high enough.
- Keep XML declaration valid.
- Keep `baseFor` valid when building mediation/base protocols.
- Do not duplicate `RawType` tags or other singleton tags.

## XML Formatting And Physical Ordering

- Use tab characters for XML indentation, one tab per nesting level.
- Do not use spaces for XML indentation.
- Every child element should be indented one level deeper than its parent.
- Within each ID-based XML section, keep items in ascending numeric ID order.
- The physical XML order must match the numeric order; do not append a low-ID helper item after higher-ID items.
- Read/write parameter pairs are the exception: the write parameter must appear immediately after its read parameter.
- Avoid large gaps between related IDs; group same-functionality items together.
- Do not reorder shipped IDs or change shipped physical ordering without checking impact.

## Protocol Connection Model

- Use one consistent connection syntax unless a documented migration pattern requires both.
- Keep `/Protocol/Type`, `Type@advanced`, `PortSettings`, `Ports/PortSettings`, and `Connections` aligned.
- Do not declare unknown connection types in `Type@advanced`.
- Trim values inside `Type@advanced`.
- Do not leave empty `Type@advanced` values.
- Do not reference non-existing dynamic IP or connection selection parameters.
- Dynamic IP option references must point to standalone read parameters with the expected type and RTDisplay behavior.
- Connection ping groups must be valid for the connector type.
- HTTP ping groups should reference valid sessions.
- SNMP ping behavior depends on first valid polling group if no ping group exists.
- Serial ping behavior depends on `Pair@ping` or the first valid pair containing a response.

## Display Pages

- Keep `Display@defaultPage` non-empty, trimmed, and present in `pageOrder` when page order is defined.
- Keep every page referenced by parameter positions present in `pageOrder` or otherwise valid for the display model.
- Keep `pageOrder` values trimmed and unique.
- Do not list unknown or unused pages unless intentionally supported.
- Keep `wideColumnPages` values valid and referring to existing pages.
- `Visibility@overridePID` must reference an existing parameter and be valid for the visibility feature.
- Every non-virtual connector **MUST** include `Webinterface#http://[Polling Ip]/` as the final entry in the `pageOrder` attribute, after a `-----` separator. Omitting it triggers WARNING "Missing WebInterface page". Use the `pageOrder` attribute — **do NOT** add a `<WebInterface>` XML child element (the `pageOrder` entry is the correct mechanism, not a separate XML element). Example correct `pageOrder` attribute value: `"General;-----;Webinterface#http://[Polling Ip]/"`. Virtual connectors (`<Type>virtual</Type>`) are exempt.

## Params: IDs, Names, And Descriptions

- Every `Param` needs a valid `id`.
- Parameter IDs must be unique and in an allowed range.
- Do not use reserved ranges for ordinary user-defined parameters.
- Use mediation/base-protocol ranges only for mediation/base-protocol parameters.
- Use SLA, enhanced service, spectrum, and DataMiner module ranges only for their documented purposes.
- Follow the connector parameter allocation model unless an existing connector pattern or explicit requirement says otherwise: `1-99` for general/internal/metadata-style parameters, `100-999` for standalone read parameters, and `1000+` for table array and column parameters.
- Do not place standalone non-table read parameters in the `1000+` table range.
- Write parameter IDs should use a fixed offset from the read parameter; prefer `+50`, allow `+100`, and never exceed `+100`.
- Do not place write parameters in a separate high-numbered range such as `50000 + read ID`.
- Keep read/write parameter pairs physically adjacent in the XML.
- Every `Param` needs a valid `Name`.
- Parameter names should be unique where the validator requires uniqueness.
- Avoid restricted parameter names.
- Avoid invalid characters in parameter names.
- Keep parameter names and descriptions trimmed.
- All `<Param>` `<Name>` values **MUST use camelCase**: the first character is lowercase and each subsequent word begins with an uppercase letter. **NEVER** use an uppercase first letter for any param name — this applies to standalone params (type `read`, `write`, `dummy`, `fixed`, `bus`, `group`) AND table array params AND table column params. Common standalone violations — ❌ `SystemDescription` → ✅ `systemDescription`; ❌ `SystemName` → ✅ `systemName`; ❌ `SystemUptime` → ✅ `systemUptime`; ❌ `SoftwareVersion` → ✅ `softwareVersion`; ❌ `Hostname` → ✅ `hostname`. Common table/column violations — ❌ `Interfaces` (table) → ✅ `interfaces`; ❌ `InterfacesIndex` (column) → ✅ `interfacesIndex`. This rule applies to all PID ranges. Every uppercase-first `<Name>` is a separate NamingConventions WARN finding.

> ⚠ **camelCase GATE — apply at write-time, not post-submission: Every `<Param>/<Name>` MUST start with a lowercase letter. PascalCase names look plausible and are invisible in a quick visual review — they only surface as NamingConventions WARN findings after submission. After generating parameters, run `grep -n '<Name>[A-Z]' protocol.xml` (bash) or `Select-String -Path protocol.xml -Pattern '<Name>[A-Z]'` (PowerShell) — every match is a violation, fix all before proceeding. Three of the most common violations: ❌ `SystemName` → ✅ `systemName`; ❌ `SystemDescription` → ✅ `systemDescription`; ❌ `SystemUptime` → ✅ `systemUptime`.**
- Every user-facing parameter should have a useful non-empty `Description`.
- Avoid duplicate descriptions where the validator expects uniqueness.
- Do not change shipped parameter IDs unless accepted as a major change.
- Do not remove parameters without major-change handling.

## Params: Type And Options

- Every parameter needs a valid `Type`.
- `Type@id` must reference an existing and valid target when used.
- `Type@options` must be non-empty, trimmed, and made of documented option tokens.
- Header/trailer link options must be present, valid, and unique when required.
- Do not duplicate `headerTrailerLink` options.
- Dynamic IP options must reference existing standalone read parameters of the expected type.
- Virtual parameter attributes must be valid and used only in supported contexts.
- Save attributes must be used only where supported.
- Load sequence must reference existing parameters and valid order semantics.

## Params: Display And Positions

- If a parameter is displayed, include valid `Display`, `RTDisplay`, and `Positions` data.
- Use `RTDisplay=true` only when the parameter must be loaded into `SLElement`.
- Hidden/internal helper parameters should normally have `RTDisplay=false`.
- Table column params (`1000+` range) MUST have `<Display><RTDisplay>true</RTDisplay></Display>` but **MUST NOT** have a `<Positions>` block — `<Positions>` belongs exclusively on the table array param. A column with `RTDisplay=true` AND `<Positions>` triggers MINOR "Unexpected RTDisplay(true)" once per column. A standalone param that has `RTDisplay=true` but no `<Positions>` also triggers MINOR "Unexpected RTDisplay(true)" because the param is not being displayed.

  ```xml
  <!-- ❌ WRONG — table column with both RTDisplay=true AND <Positions> → MINOR "Unexpected RTDisplay(true)" per column -->
  <Param id="1001" trending="false">
    <Display>
      <RTDisplay>true</RTDisplay>
      <Positions>              <!-- NEVER add Positions to a column param -->
        <Page>Interfaces</Page>
        <Row>0</Row>
        <Column>0</Column>
      </Positions>
    </Display>
  </Param>

  <!-- ✅ CORRECT — table column param: RTDisplay=true, NO <Positions> -->
  <Param id="1001" trending="false">
    <Display>
      <RTDisplay>true</RTDisplay>
      <!-- No <Positions> block — Positions belongs ONLY on the table array param (<Param type="array">) -->
    </Display>
  </Param>
  ```

  Post-write count check: the number of `<Positions>` elements in a table block must equal exactly **1** (only the table array param). If the count exceeds 1, each excess is inside a column param — remove every excess `<Positions>` block.
- Position pages must exist and be trimmed.
- Position row and column values must be valid, non-empty, trimmed, and numeric where expected.
- Do not display parameters on invalid pages or outside valid layout coordinates.
- Avoid missing positions on parameters that should be visible.
- Avoid display blocks that add no valid display information.

## Params: Units, Ranges, And Trending

- Units must be valid UOM or otherwise supported by schema/docs.
- Units must be trimmed and not empty.
- Every `number` parameter (standalone or table column, in any PID range) with `<Measurement><Type>number</Type></Measurement>` requires a non-empty `<Display><Units>` tag. Omitting it on any `number` param — including table column params in the `1000+` range — triggers MINOR "Missing 'Units' tag".
- Range `<Low>` and `<High>` values must be valid for the parameter interpretation. **NEVER write an empty `<Range />` or `<Range></Range>` tag** — an empty Range element triggers WARNING "Empty tag 'Display/Range'", which is a distinct finding from the MINOR "Missing 'Display/Range' tag" raised when `<Range>` is absent entirely. Both are validator findings and both must be avoided: ❌ `<Range />` → WARNING; ❌ no `<Range>` on a displayed `number` param → MINOR; ✅ `<Range><Low>0</Low><High>100</High></Range>`.
- Every displayed `number` parameter — standalone scalar **and** table column params in the `1000+` range — requires either a valid `<Range>` with `<Low>` and `<High>` or a `SuppressValidator 2.11.1` comment with a clear reason (e.g. cumulative counters with no meaningful upper bound).
- Low must not exceed high.
- Do not define impossible or misleading ranges.
- Trending attributes and trend type values must be valid.
- Do not trend parameters that should not be trended.
- Do not disable trending on shipped trended parameters without major-change handling.
- Do not set incompatible trending types, such as unsupported sum-style behavior on discrete values.

## Params: Interpretation

- `Interprete/Type`, `RawType`, `LengthType`, `Length`, `DefaultValue`, `Others`, and `Exceptions` must be valid for the parameter type.
- Do not put SNMP data types in `RawType`.
- Do not use invalid `Interprete/Type` for primary-key columns; use string behavior for primary keys.
- Length fields must be valid numbers and consistent with length type.
- `LengthType@id` must reference an existing parameter when used.
- Exception values and displays must be valid, unique where required, and trimmed.
- Exception display state values must be valid.
- Default values must be valid for the parameter interpretation.

## Params: Alarming

- Do not alarm `write` parameters.
- Alarmable parameters should be visible when expected by validator/best practice.
- Include `Alarm/Monitored` when alarming is intended.
- `Monitored` values and attributes must be valid.
- `disabledIf` must reference existing parameters and valid values.
- Alarm type/options must be valid for the measurement type.
- Use valid threshold tags only.
- Use valid `Info` alarm values when defining info-level behavior.
- Do not define thresholds that conflict with parameter ranges or exception behavior.

## Params: Discreets

- Discreet values must be present, unique, and valid for the parameter interpretation.
- Discreet displays must be present, trimmed, meaningful, and unique where required.
- Discreet `<Display>` values **MUST use Title Case**. Examples — WRONG: `not available`, `in service`. CORRECT: `Not Available`, `In Service`. Lowercase or sentence-case discreet displays trigger Minor validator findings.
- A `<Discreets>` container **MUST contain at least one `<Discreet>` child element**. An empty `<Discreets />` or `<Discreets></Discreets>` with no children triggers MAJOR "Missing 'Discreet' tag(s) in 'Measurement/Discreets'". This applies whether the param is a standalone `discreet` param or a table column with `<Measurement><Type>discreet</Type></Measurement>`. ❌ `<Discreets />` or `<Discreets></Discreets>` (empty) → MAJOR; ✅ at least one `<Discreet><Value>0</Value><Display>Unknown</Display></Discreet>` entry present.
- Discreet options must be documented and valid.
- Confirm options must be valid when used.
- Dependency IDs must reference existing parameters.
- Dependency values must be valid for the dependency parameter.
- Matrix discreet definitions must match matrix requirements.
- Do not change shipped discreet values/displays without major-change handling.

## Params: Tables And ArrayOptions

- `array` parameters must have valid `ArrayOptions`.
- `ArrayOptions@index` must be present, valid, and reference a valid primary-key column index.
- Primary-key column must exist and be suitable as a primary key.
- `ColumnOption@idx` must be valid and unique.
- `ColumnOption@pid` must reference an existing column parameter.
- Every column parameter should be structurally valid and named consistently.
- Avoid missing column parameters and orphaned columns.
- `displayColumn`, `NamingFormat`, and naming/display-key options must not conflict.
- Display-key definitions must reference valid columns/parameters and must not point to the primary key when unsupported.
- Display key columns must be last and should not be manually filled.
- NamingFormat references must be valid, trimmed, and without spaces around IDs.
- Partial-table settings must be valid and not introduced without major-change handling.
- Logger table settings must be complete and valid before marking a table as database/logger table.
- Volatile-table options must be set correctly for dynamic tables that should not persist.
- Automatically polled SNMP table columns (`ColumnOption type="snmp"`) must not contain the `save` option. This is a supplemental semantic quality rule and may not be reported by the official validator; it does not prohibit saved standalone configuration/state parameters or explicitly justified non-SNMP columns.
- Avoid custom processing order unless explicitly required and validated.

## Params: SNMP OID And TrapOID

- `SNMP/OID@id` must reference a standalone read or bus parameter.
- Use `SNMP/OID@id` only for documented cases: subtables, filtered rows, and dynamic OID patterns.
- Except for subtables, `OID@id` only makes sense when the OID contains a wildcard.
- `OID@options` must use documented option tokens and valid combinations.
- Do not use unsupported OID option combinations.
- `TrapOID@mapAlarm` must use valid mappings and references.
- Trap mapping parameters must exist and be valid for alarm mapping.

## Params: Dependencies And Information

- Dependency IDs must reference existing parameters.
- Dependency values must be valid for referenced parameters.
- Information `Includes`, `Subtext`, and similar helper tags must be in the correct XML location.
- Do not place information/display/trending/unit tags directly under `Param` when schema expects them under child containers.

## QActions XML And C# Prevention

- Every `QAction` needs a valid unique ID.
- Every named `QAction` must have a valid, trimmed name.
- `QAction@triggers` must reference existing parameters and use valid syntax.
- A shared/no-entry-point QAction should not define triggers.
- Conditions must reference existing parameters and valid expressions.
- `encoding` must be supported; prefer `csharp` for modern QActions.
- `dllImport` should use supported placeholders and must avoid deprecated DLL references.
- Ensure QAction code compiles before considering XML complete.
- Include secure coding dependencies/assemblies expected by the validator.
- Avoid deprecated or unsupported Notify calls when typed/helper alternatives exist.
- Avoid unsupported or unrecommended constructors, finalizers, and property sets.
- Validate `GetParameter`, `GetParameters`, `SetParameter`, `SetRow`, `FillArray`, `FillArrayNoDelete`, and `FillArrayWithColumn` usage patterns.
- For `FillArrayWithColumn`, ensure column counts, table IDs, primary keys, and update modes match validator expectations.
- Do not use static/shared state patterns that validator flags as unsafe.
- InterApp/Core messaging patterns must include valid reply/error handling.
- File encoding must be valid for QAction source.
- Never call `JsonConvert.DeserializeObject` directly. Always use `SecureNewtonsoftDeserialization.DeserializeObject` from the `Skyline.DataMiner.Utils.SecureCoding` NuGet package. Omitting this triggers SLC_SC0004 build warnings. Ensure the NuGet package reference is present in the QAction .csproj file whenever JSON deserialization is used.

## Groups

- Every group needs a valid unique ID.
- Group names should be unique and meaningful when present.
- Group content must reference existing params, actions, pairs, sessions, or triggers.
- Do not mix content item types in a group.
- Group `connectionPID` must reference a valid parameter with valid connection index values.
- Group conditions must be valid and reference existing parameters.
- Group content should not be empty unless a documented pattern requires it.
- Use valid group type for the execution pattern.

## Triggers

- Every trigger needs a valid unique ID.
- Trigger `On@id` must exist, be valid for the selected `On` type, and reference the correct item type.
- Do not use multiple IDs where only one is supported.
- Avoid leading zeroes in trigger references.
- Trigger content IDs must reference existing actions or triggers as required by trigger type.
- Trigger conditions must be valid and reference existing parameters.
- `On` and `Time` combinations must be valid.
- Avoid duplicate triggers with the same effective activation.
- After-startup flows must use valid trigger/action/group types and valid conditions.
- Avoid multiple after-startup triggers where validator forbids them.

## Actions

- Every action needs a valid unique ID.
- Action names should be unique and meaningful when present.
- `Action/On` must be present, non-empty, trimmed, and valid.
- `Action/On@id` must reference an existing item of the expected type.
- `Action/On@nr` must be valid when used.
- `Action/Type` must be present, non-empty, trimmed, and valid.
- Action type and `On` combinations must be supported.
- Type-specific attributes such as `id`, `value`, `nr`, `options`, `return`, `startoffset`, `endoffset`, `allowed`, `reschedule`, `scale`, `sequence`, `script`, `arguments`, and `returnValue` must only be used for action types that support them.
- Action conditions must be valid and reference existing parameters.
- For the `Copy` action type, `<Type>` **must** carry a non-empty `id` attribute referencing the destination parameter (the parameter whose value is overwritten by the copy). An absent or empty `id` on a Copy action triggers a **Minor** finding. Example — ❌ WRONG: `<Type>copy</Type>` or `<Type id="">copy</Type>`. ✅ CORRECT: `<Type id="102">copy</Type>` where `102` is the destination parameter ID.

## Timers

- Every timer needs a valid unique ID.
- Timer names should be unique and meaningful when present.
- Timer `Time`, `Interval`, `Content`, and options must be valid.
- Timer `Time` should be compatible with loop/numeric constraints and not be untrimmed or empty.
- Timer options must use documented tokens and valid combinations.
- Multithreaded timer options must include required table/IP/each/thread-pool settings.
- Timer content groups must reference existing groups and valid columns when column-based selection is used.
- Timer conditions must be valid and reference existing parameters.
- Avoid timers that can flood the protocol queue or create runtime errors through non-poll final groups.
- Never create multiple timers with the same `<Time>` value; the validator raises a Minor finding per duplicate. To poll multiple groups at the same interval, use a single timer whose `<Content>` lists all required `<Group>` references, rather than one timer per table/group.

## HTTP

> ⚠ **MAJOR — BEFORE touching any HTTP `<Header>` element: `Header@key` is required by the Protocol schema.** Standard keys should use their documented names. A required vendor-specific key such as `X-PAN-KEY`, `X-API-Key`, or `X-Auth-Token` is schema-valid through the string branch but can trigger validator finding 8.3.1 because it is outside the validator's standard-header allowlist. Retain the key and use a narrow justified suppression when the external API requires it; never emit a keyless Header.

- Every HTTP session and connection needs a valid unique ID.
- Request and response PID attributes must reference existing parameters of the expected type.
- Header PID attributes must reference existing parameters.
- Every Header has a non-empty, trimmed `key`. Standard names include `Content-Type`, `Accept`, and `Authorization`.
- Vendor-specific names are schema-valid but can trigger finding 8.3.1. When the name is a documented requirement of the target API, wrap the keyed Header with a specific suppression:

  ```xml
  <!-- SuppressValidator 8.3.1 X-PAN-KEY is a required authentication header for the Palo Alto Networks API -->
  <Header key="X-PAN-KEY" pid="301"/>
  <!-- /SuppressValidator 8.3.1 -->
  ```

- Use this only when:
  - The header key is **documented by the external API** as required.
  - The header name is static and well-known (not a typo or made-up name).
  - The reason clearly identifies the external API that mandates this header.
- The referenced PID contains only the header value. It must not contain `"HeaderName: value"`.
- Credential inputs use password masking and have no source-controlled secret `DefaultValue`.
- Never log passwords, tokens, API keys, cookies, complete Authorization headers, or credential-bearing response bodies.

- A single non-standard header key multiplies across every session and connection that references the containing request — the validator raises one MAJOR finding per session. Resolve all occurrences together. When the validator reports the same "Unknown Header key" finding for **multiple Session IDs** (e.g., both `Session ID '1'` and `Session ID '2'` report `X-PAN-KEY`), apply the same justified suppression to every required occurrence in a single edit pass:
  1. Run `grep -n 'key="X-PAN-KEY"'` (substituting the actual key name) across the entire `protocol.xml`.
  2. Collect every matching `<Header>` line regardless of which `<Session>` or `<Connection>` it belongs to.
  3. Retain `key` and `pid`, and add the same justified suppression to each required occurrence.
- Do not leave empty headers or empty header key/PID attributes.
- Request `pid` and request data `pid` references must be valid for the data they supply.
- Response `Content@pid`, `Headers/Header@pid`, and `statusCode` references must point to suitable parameters.
- Username, password, proxy server, proxy user, and proxy password attributes must be valid when present.
- Do not use unsupported request/header syntax combinations.
- Keep TLS certificate verification enabled. Do not set `SkipCertificateVerification/DefaultValue` to `true` without an explicit target requirement and documented risk.
- Custom C# certificate callbacks must not always return `true`; this triggers `SLC_SC0005`.

## Commands, Responses, And Pairs

- Every command, response, and pair needs a valid unique ID.
- Command/response names should be unique and meaningful when present.
- Command content parameters must reference existing parameters valid for command composition.
- Response content parameters must reference existing parameters valid for response parsing.
- Command logic must match parameter sequence and required make/length/CRC actions.
- Response logic must match framing, length, CRC, and parsing requirements.
- Pair content must include a valid command and valid response references when responses are expected.
- Response-on-bad-command references must point to existing responses and valid contexts.
- Pair conditions must be valid.
- ASCII attributes must be valid when used.

## Ports And PortSettings

- Main and additional `PortSettings` names must be valid and trimmed when required.
- Additional port settings must align with declared additional connections.
- Do not leave port settings unnamed when validator requires names.
- Use port setting structures appropriate for main versus additional connections.

## Relations, Topologies, Chains, And ParameterGroups

- Relation names should be meaningful and unique when required.
- Relation paths must reference existing table/parameter IDs in valid order.
- Do not define relations with missing, invalid, duplicate, or impossible path segments.
- Topology names must be valid and unique where required.
- Chain child names must be valid and unique where required.
- Parameter groups must have valid unique IDs and names.
- Parameter group type must be valid.
- `dynamicId` and `dynamicIndex` must reference valid table/matrix structures.
- Parameter group params must reference existing parameters and must not duplicate invalid references.
- Do not define empty or inconsistent parameter groups.

## ExportRules

- Export rule table attributes must reference existing tables.
- `where`, `whereTag`, `whereAttribute`, and `whereValue` must be valid, documented, and mutually consistent.
- Do not reference tags, attributes, or values that cannot match exported XML.
- Keep export rules ordered intentionally; later matching rules can override earlier rules.

## TreeControls

- Tree control `parameterId` must reference an existing table/parameter suitable for tree control use.
- Hierarchy paths must reference existing tables and valid parent/child relationships.
- Hierarchy table IDs must exist and be valid for the hierarchy.
- Parent attributes must reference valid parent table entries.
- Condition attributes must be valid and reference existing parameters/columns.
- Extra details and extra tabs must reference existing details tables, discreet columns, table IDs, and parameters.
- Hidden, readonly, override display, and override icon column lists must contain valid, existing, trimmed, non-duplicate column IDs.
- Do not include irrelevant columns in hidden/readonly/override lists.
- Do not define tree controls with missing or impossible table relationships.

## Major Change Checker Prevention

- Treat shipped connector behavior changes as impact-sensitive work.
- Use `dataminer-dis` for DIS Comparer / Major Change Checker guidance when the user is in Visual Studio.
- High-risk changes include protocol name, parameter removal, parameter ID changes, discreet display/value changes, table PK/display-key/column-order/partial/logger changes, DVE export name changes, `Type@options` changes, minimum required version changes, and shipped layout or connection behavior changes.
- Do not auto-fix `FixImpact=Breaking` findings until versioning and upgrade impact are assessed.

## Review Checklist

Before finishing a `protocol.xml` change:

- Confirm no Critical finding pattern was introduced.
- Confirm Major finding patterns in the touched area were avoided or explicitly deferred.
- Confirm Minor and Warning finding patterns in the touched area were addressed where practical.
- Confirm all new IDs are unique, valid, and references resolve.
- Confirm all new options are documented and trimmed.
- Confirm all changed shipped behavior has major/system-version impact assessed.
- Confirm `<SNMP includepages="true">auto</SNMP>` is present as a direct child of `<Protocol>` (Critical finding if absent, applies to all connector types including HTTP, SNMP, serial, and virtual).
- Confirm every HTTP `<Header>` has its schema-required `key`. For an `X-`-prefixed or vendor-specific key, verify the external API requirement and add `<!-- SuppressValidator 8.3.1 <reason> -->` when the validator does not recognize it. Never convert a Header to pid-only form.
- Confirm every `Copy` action's `<Type>` element has a non-empty `id` attribute referencing the destination parameter (Minor finding if absent or empty).
- Run the validator and use its full output for exact rule IDs and details.
