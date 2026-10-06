---
description: "Quick-reference guard rails for editing DataMiner connector protocol.xml files."
applyTo: "**/protocol.xml"
version: "1.8"
updated: "2026-10-05"
---

# DataMiner Protocol XML — Guard Rails

> For comprehensive authoring guidance, load the `dataminer-xml-authoring` skill. For naming conventions and ID management, load the `dataminer-connector-core` skill. For the full ownership matrix across all four `protocol.xml` customization files, see the **Authority Matrix** at the top of `dataminer-protocol-validator-prevention/SKILL.md`.
> **Canonical examples** (follow these exactly — do not invent structures):
> - SNMP connector: `dataminer-connector-core/references/example-snmp-connector.md`
> - HTTP connector: `dataminer-connector-core/references/example-http-connector.md`
>
> **Hard rule**: If a tag, attribute, or enum value is not in the schema or these examples, do NOT use it. Fetch the schema docs first: `https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.{element.path}.html`

## XML Formatting (Applies to All Output)

- **Use tab characters for indentation — NEVER spaces.** One tab per nesting level; every child element is indented one level deeper than its parent.
- This rule applies to every XML block you produce: full skeletons, parameter snippets, incremental additions, and inline edits.
- Preserve the existing file's line endings and formatting outside the lines being changed. Do not reformat an entire file for a scoped edit.

## Surgical Editing and Validation

- Before a scoped edit, read the target element and nearby lines and note the current value.
- Use the file-editing tool available in the current environment directly. An assistant tool name such as `apply_patch` is a tool call, not a PowerShell executable; do not pipe patch text into a shell expecting that command to exist.
- If an edit fails, do not cycle through patch flags or guess at the cause. Read the actual error and re-read the on-disk target block; inspect tabs or line endings only when the evidence points to them. Make at most one corrected attempt, then stop and report the blocker if it still fails.
- Immediately after editing, verify the exact intended value with a case-sensitive check and inspect the diff to ensure the change stayed within scope.
- For a unit change, load `dataminer-protocol-xml-reference/references/protocol-uom.md` before editing and preserve the exact case-sensitive unit string listed there.
- For a unit-only display-metadata change, use a focused XML parse/value assertion and the official connector validator; skip a full solution build when no code or generated output changed. If the validator is unavailable, report that gate as not run and follow the validation skill's installation policy.
- If validation reports unrelated findings, distinguish them from findings caused by this edit. Do not call a nonzero validator result clean or broaden a scoped change to fix pre-existing issues unless requested.

## XML Comment Hygiene (Applies to All Output)

- **Do not add explanatory or documentation comments to connector `protocol.xml` files.** This includes TODO, FIXME, debug, workaround, and design-note comments.
- Copyright comments are allowed.
- `SuppressValidator` comments are allowed only when they directly wrap the affected element and include a specific reason for a genuinely non-applicable finding. They are intentional validator exceptions, not general documentation.
- Put connector documentation in `<Description>`, `<Information><Subtext>`, connector Markdown, or C# documentation comments instead of XML comments. `<Information><Subtext>` provides operator-facing tooltip text in DataMiner Cube: write it in plain, user-friendly language and **never** include low-level technical information such as SNMP OIDs (the OID belongs exclusively in `<SNMP><OID>`).
- When modifying an existing file, remove newly introduced non-allowed comments and do not copy explanatory comments from examples into the output XML.

## Closed-World Schema Rule

**NEVER invent, guess, or hallucinate XML tags, attributes, or attribute values.** Only use elements, attributes, and option values that are documented in the DataMiner protocol schema. The schema is a closed world — if it isn't explicitly listed, it does not exist.

- **Before writing any element or attribute you are not 100% certain about**, verify it in the schema docs: `https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.{dot.separated.path}.html`
- **Never fabricate child elements** — e.g. `<Param><Subtext>` ❌, `<Param><Trending>` ❌, `<Param><Units>` ❌. See the "Valid `<Param>` Child Elements" allowlist below.
- **Never fabricate attributes** — only use attributes listed in the schema for that element.
- **Never fabricate attribute option values** — e.g. `<Type options="encrypt">` ❌ (not a real option). See the "Measurement Type Options" section below for valid `options` values.
- When in doubt, load the `dataminer-protocol-xml-reference` skill or fetch the schema URL — do NOT guess.

## Element Ordering (Ascending ID)

All ID-based XML sections must have their elements ordered by **ascending numeric ID**. This replaces the removed XML fix CLI — apply this rule to every edit.

**Applicable sections**: `<Params>`, `<Groups>`, `<Triggers>`, `<Actions>`, `<Timers>`, `<Commands>`, `<Responses>`, `<Pairs>`, `<HTTP>` (Session elements), `<QActions>`.

**One exception — Read/Write parameter pairs**: A write parameter must appear **immediately after** its corresponding read parameter, even if the write ID is higher than the next unrelated parameter. Example: `id="100"` (read) → `id="150"` (write) → `id="101"` (next read) is correct.

**Rules**:
- Never place a low-ID element after higher-ID elements (e.g., `<Param id="2">` after `<Param id="13">` is invalid).
- When inserting new elements, place them at the correct sorted position — do not append at the end.
- After any edit, verify the section remains in ascending order (respecting the Read/Write exception).

## Valid `<Param>` Child Elements

Only these elements are valid direct children of `<Param>`: `Alarm`, `ArrayOptions`, `CRC`, `CrossDriverOptions`, `Dashboard`, `Database`, `Dependencies`, `Description`, `Display`, `HyperLinks`, `Icon`, `Information`, `Interprete`, `Length`, `Matrix`, `Measurement`, `Mediation`, `Message`, `Name`, `Replication`, `SNMP`, `Type`.

**Any tag NOT in this list is INVALID inside `<Param>`.** Common mistakes:
- `<Param><Subtext>` -> `<Param><Information><Subtext>`
- `<Param><Includes>` -> `<Param><Information><Includes>`
- `<Param><Trending>` -> attribute `trending="true"` on `<Param>`
- `<Param><Units>` -> `<Param><Display><Units>`
- `<Param><Decimals>` -> `<Param><Display><Decimals>`

Schema docs: `https://aka.dataminer.services/protocol-params-param`

## Parameter Naming

Apply these rules to `<Protocol><Params><Param>` elements:

- Every parameter `<Name>` starts with a lowercase letter.
- For each table array parameter, every referenced column `<Name>` starts with the table parameter's exact `<Name>` value.
- When columns in different tables share a description, disambiguate them by appending the table description or a clear abbreviation in parentheses.

## Critical One-Liners (top 5 highest-risk rules)

These five rules cause the most bulk findings when violated. For the **full rule set**, load the `dataminer-xml-authoring` skill (TABLE GENERATION GATE, Pre-Completion Checklist).

- **All valid operational parameters MUST have `<Alarm><Monitored>true</Monitored>`** — every displayed operational health, status, and telemetry parameter (voltages, currents, power, frequencies, battery charge/capacity, remaining runtimes, temperatures, link states, error counters, operational status enums with `<RTDisplay>true</RTDisplay>`) is valid for alarming and MUST have `<Alarm><Monitored>true</Monitored>` with default thresholds or justified `2.5.1` suppression. Non-alarmable parameters (write parameters, dummy parameters, table array params, index PKs, display keys, RTDisplay=false intermediates, static asset information like serial numbers, volatile tables) must NOT be monitored. For every `<Alarm>` block present, explicitly place `<Monitored>true</Monitored>` (or `<Monitored>false</Monitored>` if intentionally unmonitored) first.
- **Pre-known values MUST be numeric discreets** — when creating a parameter with pre-known finite values (enums, operational states, modes, statuses, boolean conditions), implement it as a discrete parameter (`<Type>discreet</Type>`, or `<Type>togglebutton</Type>` for 2-state booleans) with numeric backend (`<Interprete><Type>double</Type></Interprete>`). The numeric backend value allows DataMiner to alarm and trend the parameter. The `<Discreet><Display>` text provides clear, human-readable labels for the end user in Cube/web UI. Never store pre-known states as raw strings.
- **Table vs Column `<SNMP>` blocks are DIFFERENT** — table: `<SNMP><Enabled>true</Enabled><OID type="complete">oid</OID></SNMP>`. Column: `<SNMP><OID>oid</OID></SNMP>` (NO `<Enabled>`, NO `type=`, NO `id=`). Copying the table format onto columns causes MAJOR 2.48.4 on every column.
- **Automatically polled SNMP columns must not be saved** — omit the `save` token from every `ColumnOption type="snmp"`. This does not prohibit persistence for standalone configuration/state parameters or explicitly justified non-SNMP columns.
- **PK column `<Interprete><Type>` MUST be `string`** — never `double`, even for numeric SNMP indexes. Causes MAJOR on every table.
- **Column params MUST NOT have `<Positions>`** — `<Positions>` belongs only on the table array param. Causes MINOR on every column.
- **One parameter per position** — each Page+Row+Column must be unique. Only exception: read/write pairs MUST share the same position to render as one combined control.
- **Tiered polling cadences across all connection types** — group polling into at least two tiers. Fast timers (10s–60s) for dynamic telemetry and active tables; slow timers (10m–1h, `<Time initial="true">`) for static asset, capability, or slow-changing configuration data (system description, vendor/model, serial number, versions, static counts). Never poll static data rapidly.
- **Duration / Time formatting (`options="time"`)** — whenever a numeric parameter represents elapsed time, uptime, remaining run time, or a timeout in seconds, always specify `<Measurement><Type options="time">number</Type></Measurement>` for automatic `hh:mm:ss` formatting.
- **Multiple tables on a page: stack vertically, never overlap** — assign Row 0, 1, 2 … to each table in turn (rows are per-object). Default to Column 0. Column 1 is only allowed for a table with very few columns placed alongside a Column 0 table. NEVER put two tables at the same Row+Column — they overlap silently.
- **PortSettings configured by connection type** — always include `<PortSettings name="...">` with connection-appropriate defaults and disable invalid port options:
  - **SNMP**: `<BusAddress><Disabled>true</Disabled></BusAddress>`, `<IPport><DefaultValue>161</DefaultValue></IPport>`, `<PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>`.
  - **HTTP**: `<BusAddress><DefaultValue>bypassProxy</DefaultValue></BusAddress>`, `<IPport><DefaultValue>80</DefaultValue></IPport>` (or 443), `<Type><DefaultValue>ip</DefaultValue></Type>`, `<PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>`, `<PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>`.
  - **Serial**: `<Type><DefaultValue>serial</DefaultValue></Type>`, `<BusAddress><Disabled>true</Disabled></BusAddress>` (unless RS-485), standard framing defaults, `<IPport><DefaultValue>4001</DefaultValue></IPport>`, `<PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>`.
  - **Smart Serial**: `<Type><DefaultValue>ip</DefaultValue></Type>`, `<BusAddress><Disabled>true</Disabled></BusAddress>`, `<IPport><DefaultValue>50000</DefaultValue></IPport>`, `<PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>`.
  - **SSH**: `<Type><DefaultValue>ip</DefaultValue></Type>`, `<BusAddress><Disabled>true</Disabled></BusAddress>`, `<IPport><DefaultValue>22</DefaultValue></IPport>`, `<PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>`, `<PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>`.
- **Read/write pairs: `<Name>` MUST be identical** — this is the primary key DataMiner uses to link them into a combined UI control. Different names → two separate unlinked controls. Never append "Write", "Set", or any suffix to the write param's `<Name>`. The **read parameter MUST always have the lower ID** (write ID = read ID + 50 preferred, +100 max) so the read appears first in sorted order.
- **Alarm tags**: exactly `CH`, `MaH`, `MiH`, `WaH`, `Normal`, `WaL`, `MiL`, `MaL`, `CL`, `Info` — never invent abbreviations or use full names.

## XSD-Critical Enum Values

Consult `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md` for all valid enum values (`RawType`, `Interprete/Type`, `Measurement/Type`, `SNMP/Type`, `OID type`, `ColumnOption type`). Key reminders:

- **`<RawType>`**: NEVER use SNMP type names (`octetstring` ❌, `gauge32` ❌).
- **`<OID type>`**: only `complete`, `auto`, `composed`, `wildcard` — `id` is a separate attribute, not a type value. NEVER use SNMP data types or direction names.
- **`<ColumnOption type>`**: never `write`. No `foreignId` attribute on `<Discreets>`.

### Password Parameters (Mandatory for Sensitive Data)

Write parameters for **passwords, secrets, tokens, API keys, or any sensitive data** MUST use:

```xml
<Measurement>
	<Type options="password">string</Type>
</Measurement>
```

- The `password` option **masks input** (displays `*`), **encrypts the stored value**, and works for both standalone parameters and dynamic table column cells.
- The `<Type>` content MUST be `string` when using `password`.
- On a **read parameter**, the `password` option hides the displayed value in Cube.
- Omitting `password` on a credential parameter exposes secrets in plain text — this is a **security vulnerability**.

Schema reference: `https://aka.dataminer.services/protocol-params-param-measurement-type-options`
