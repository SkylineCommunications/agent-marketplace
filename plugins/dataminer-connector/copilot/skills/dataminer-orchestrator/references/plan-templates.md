# Plan Templates & Connector Map

Reference for implementation plan formats (FEATURE, BUGFIX, INVESTIGATION, REVIEW, DOCUMENTATION) and Connector Map structure.

> **Parent skill**: `dataminer-orchestrator/SKILL.md` — return there for phase workflow and constraints.

---

## Confirmed Planning Decisions

These decisions apply to every connector plan:

1. **Target compatibility is task-specific.** Record the target minimum DataMiner version, any maximum supported version, and the compatible connector Dev Pack, template, validator, and schema sources. Derive values from an existing solution when possible. If a required target cannot be inferred, ask the user instead of selecting the latest version.
2. **VendorOID is never invented.** For a new connector or requested identity change, use the value already supplied in the request; if none is supplied, ask for it. For an existing connector, preserve the value in `protocol.xml` unless the user explicitly changes it. Validate the selected value against the schema chosen for the target and report a mismatch instead of silently substituting another OID.
3. **QAction helper generation is conditional.** Do not introduce or require a generated QAction helper as a universal completion gate. If the existing solution already consumes generated helper members and an XML change affects them, refresh the helper when the approved tool is available; otherwise skip helper generation.
4. **Simulation routing is unchanged.** When simulation is explicitly requested, retain the existing TOON simulation route and contract. This plan does not broaden, replace, or automatically invoke it.
5. **Artifact ownership is explicit.** Assign XML to `dataminer-xml-author`, or explicitly select initial inline ownership before any worker starts. QAction C# and projects belong to `dataminer-qaction-writer`, tests to `dataminer-test-writer`. QAction/trigger/action XML registrations remain with the XML owner, never the C# writer. A late XML request pauses C# work until the XML, conditional-helper, and affected build/validator gates run again.
6. **Sequencing is orchestrator-owned.** Specialists return results and do not start sideways handoffs. Each gate has at most three attempts; after the third failure the plan stops with a blocker and evidence.
7. **No concurrent XML takeover.** Poll counts and elapsed time do not transfer ownership.
   Wait or cancel and confirm termination before rereading and assigning another writer.
   If termination cannot be confirmed, report `BLOCKED`.
8. **Read-only routes terminate with findings.** REVIEW/INVESTIGATION bypass implementation
   and repair gates. Apply `dataminer-manifest/references/read-only-assessment.md` to diagnostic
   execution and optional coordination; repairs need a separate approved transition.

---

## Connector Map Template

Build this map by reading `protocol.xml` completely before proposing any changes. This prevents ID collisions, naming conflicts, and structural mismatches.

**How to build:**
1. Read `protocol.xml` completely
2. Scan for all parameter IDs, group IDs, timer IDs, trigger IDs, action IDs, QAction IDs
3. List all tables with their column PIDs
4. List all pages and which parameters are on each
5. Identify the connection type from the `<Type>` element
6. Calculate the next available IDs

```
## Connector Map
- **Name**: [protocol name from <Name>]
- **Version**: [from <Version>]
- **Connection Type**: [from <Type>]
- **Compatibility**:
  - Minimum DataMiner version: [from Compliancies/MinimumRequiredVersion or user]
  - Maximum supported version: [from Compliancies/MaximumSupportedVersion, or none]
  - Dev Pack / template / validator versions: [from project files and target-version resolution]
  - Schema source/version: [from the protocol XML source manifest selected for this task]
- **VendorOID**: [value and source: existing protocol.xml | user prompt | user answer; schema validation result]
- **Parameter ID Ranges**:
  - Standalone (1-999): [list, highest = X]
  - **Tables (1000+)**:
    For SNMP connectors, include the `SNMP Table OID` column and show each column's OID suffix. For non-SNMP connectors, omit the `SNMP Table OID` column.
    | Table PID | Name | SNMP Table OID | Columns (PID: name [OID suffix]) | Purpose | Measurement options |
    |-----------|------|----------------|----------------------------------|---------|---------------------|
    | 1000 | interfaceTable | 1.3.6.1.2.1.2.2 | 1001 Index [.1.1], 1002 Desc [.1.2], 1003 Status [.1.8] | Displayed (Interfaces page) | ✓ tab=columns:1001\|0-... |
    | 2000 | ifXTable | 1.3.6.1.2.1.31.1.1 | 2001 Index [.1.1], 2002 Name [.1.1] | Displayed (Interfaces page) | ✓ tab=columns:2001\|0-... |
    | 3000 | retrievedTable | 1.3.6.1.2.1.4.20 | 3001 Key [.1.1], 3002 Value [.1.2] | Displayed (Data page) | ✗ MISSING |

    > **SNMP connectors:** Each DataMiner table must map to exactly one SNMP table OID. If planned columns have different base OIDs, they belong in separate DataMiner tables.

    > **Planning notation only:** `[.1.1]` in the Columns cell is an OID suffix shorthand for this plan map — it is **not** the XML `<Description>` format. When authoring the actual XML, column `<Description>` values MUST always use parentheses: `Title Case Phrase (Table Name)` (e.g., `Index (If)`, `Operational Status (If)`). **Never use square brackets in a `<Description>` tag.**

    Purpose classification:
    - **Displayed** — table has a `<Positions>` entry on a UI page → Measurement options required.
    - **Background** — no page position (raw/processing table feeding a retrieved or view table, or internal logic) → Measurement options NOT required. Only flag **Displayed** tables that are missing Measurement options.
- **Groups**: [ID, type, content summary]
- **Timers**: [ID, interval, which groups]
- **Triggers**: [ID, on what, condition]
- **Actions**: [ID, type]
- **QActions**: [ID, trigger PID, .cs file]
- **Pages**: [name, parameters displayed]
- **Next Available IDs**:
  - Parameter: [next standalone], [next table PID]
  - Group: [X]
  - Timer: [X]
  - Trigger: [X]
  - Action: [X]
  - QAction: [X]
- **Artifact Ownership**:
  - `protocol.xml`: `dataminer-xml-author`
  - QAction C# / project files: `dataminer-qaction-writer`
  - Unit tests: `dataminer-test-writer`
  - Validator output: `dataminer-validator` (read-only)
  - Package/release/deployment/migration artifacts: orchestrator + selected official SDK/packager/deployment skill
```

---

## Plan Format: FEATURE / NEW

```
## Implementation Plan

### Task: [description]
### Classification: NEW | FEATURE

### Target Compatibility
| Axis | Selected value | Evidence / source |
|------|----------------|-------------------|
| Minimum DataMiner version | [value] | [existing XML or user requirement] |
| Maximum supported version | [value or none] | [existing XML or user requirement] |
| Protocol schema | [package/version/revision] | [source manifest] |
| Connector Dev Pack | [package/version or not applicable] | [existing project or target-compatible selection] |
| Template / validator | [version] | [existing solution or current approved tool] |

### Connector Identity
- VendorOID: [value]
- Source: existing protocol.xml | user prompt | user answer
- Target-schema validation: pass | unresolved conflict requiring user decision

### Proposed Changes

#### Parameters
| PID | Name | Description | Type | Measurement (options) | Cadence (Fast / Slow) | Alarm / Thresholds | SNMP OID / Source | Page |
|-----|------|-------------|------|-----------------------|-----------------------|--------------------|-------------------|------|

> For parameters with pre-known values, plan them as discrete with numeric backend mapping (e.g., `discreet (1: Online, 2: Offline, 3: Fault)` or `togglebutton (1: Disabled, 2: Enabled)`) to support alarming and trending.

#### Groups
| ID | Type | Content | Connection | Timer | Cadence |
|----|------|---------|------------|-------|---------|

#### Timers
| Timer ID | Name | Time (ms) | Initial | Content Groups | Cadence Type |
|----------|------|-----------|---------|----------------|--------------|
| 1 | Fast Timer | 30000 | true | Dynamic scalars, Tables | Dynamic / Operational telemetry |
| 2 | Slow Timer | 3600000 | true | Static device info | Static / Asset & configuration |

> **Universal Tiered Polling, Time Measurement, and Monitoring Rules (All Connection Types):**
> - **Tiered Polling**: Partition polling into at least two tiers. Fast timer (10s–60s) for dynamic telemetry and active tables; slow timer (10m–1h, `initial="true"`) for static, asset, or slow-changing data (system description, vendor, model, serial, version, static phase/port counts, license limits). Never poll static data rapidly.
> - **Time & Duration Formatting**: Any duration, uptime, remaining run time, or timeout parameter in seconds MUST be planned with `<Type options="time">number</Type>` for automatic `hh:mm:ss` display in the UI.
> - **Operational Health Monitoring (Mandatory for Valid Parameters)**: Every valid operational telemetry parameter (voltages, currents, power, frequencies, battery capacities/charge/runtimes, temperatures, operational status enums, link states, error rates) MUST be planned with `<Alarm><Monitored>true</Monitored>` and standard default thresholds (or justified 2.5.1 suppression). Non-alarmable parameters (write params, dummy params, table array params, index PKs, display keys, RTDisplay=false intermediates, static asset information, volatile tables) must omit `<Alarm>` or have `<Monitored>false</Monitored>`.
> - **Discrete Values for Pre-Known States/Values**: Any parameter representing pre-known values (enumerations, operational states, modes, statuses, boolean conditions) MUST be planned as a discrete parameter (`<Type>discreet</Type>`, or `togglebutton` for 2-state booleans). The backend/stored value MUST be numeric (`<Interprete><Type>double</Type>`) so DataMiner can alarm and trend it; `<Discreet><Display>` provides the human-readable text seen by end users. Never use raw string parameters for pre-known enumerations or states.

#### Triggers / Actions (if needed)
| Trigger ID | On | Condition | Action ID | Action Type |
|------------|-----|-----------|-----------|-------------|

#### QActions (if needed)
| ID | Trigger PID | Purpose | File |
|----|-------------|---------|------|

#### NuGet Packages
List any Skyline utility packages needed for C# implementation. Load `dataminer-nugets` and consult `dataminer-connector-core/references/nuget-packages.md`.
| Package | Purpose | QAction / Project |
|---------|---------|-------------------|

> If the task involves rate/throughput/bitrate calculations, you MUST include `Skyline.DataMiner.Utils.Rates.Protocol`.
> If the task involves interface utilization, include `Skyline.DataMiner.Utils.Interfaces`.
> If unit tests are planned, include `Skyline.DataMiner.Utils.UnitTestingFramework` and `FluentAssertions` for the test project.

#### Table Display Options
For SNMP connectors, include the `SNMP Table OID` column. For non-SNMP connectors, omit it.
| Table PID | Table Name | SNMP Table OID | Purpose | Measurement Options |
|-----------|-----------|----------------|---------|---------------------|
| 1000 | interfaceTable | 1.3.6.1.2.1.2.2 | Displayed — Interfaces page | ✓ tab=columns:1001\|0-1002\|1-1003\|2 |
| 2000 | rawDataTable | — | Background — feeds 3000 | — not required |
| 3000 | newTable | 1.3.6.1.2.1.31.1.1 | Displayed — Data page | ✗ MISSING — must add |

> For any **Displayed** table marked ✗, add `<Measurement><Type options="tab=columns:pid|idx-...,lines:25,width:...,sort:...,filter:true">table</Type></Measurement>`.
> Column PIDs in options must match every `<ColumnOption pid="...">` in the table's `<ArrayOptions>`.
> Background tables (no page position) are exempt.

> **SNMP connectors:** Verify that each row with an SNMP Table OID is distinct from the others. Columns from different SNMP MIB tables (different base OIDs) must each be in a separate DataMiner table — never merged into one.

#### Pages affected
- [page name]: [what's added/changed]

### Execution Order
1. XML changes (load `dataminer-xml-authoring`)
2. If the existing solution consumes generated QAction helper members and the XML change affects them, refresh the helper with the approved tool when available; otherwise record "not required"
3. QAction C# code (load `dataminer-qaction`)
4. Unit tests (load `dataminer-unit-testing`)
5. Validate (load `dataminer-validation`)

### Route and Completion Controls

- Record the owner for every changed path and the gate that must pass before the next handoff.
- Do not allow a specialist to invoke another specialist directly; return the result to the orchestrator.
- Retry a failed gate no more than three times with the exact finding attached to the owning specialist.
- Add the task-class final gate: build/validator for implementation, exact test run for testing, official package verification for packaging, compare/release evidence for release, immutable artifact/rollback evidence for deployment, and source/target compatibility plus rollback evidence for migration.

### Simulation
- Requested: yes | no
- Route: existing TOON workflow when requested; no automatic simulation work otherwise

### Impact on existing elements
- [any timers, groups, or pages that are modified]
```

---

## Plan Format: BUGFIX

```
## Fix Plan

### Symptoms: [what's broken]
### Root Cause: [analysis from Connector Map + code reading]
### Target Compatibility: [minimum/maximum DataMiner, schema, Dev Pack, validator]
### Fix: [specific changes needed]
### Files affected: [list]
### New NuGet Dependencies (if applicable)
| Package | Purpose |
|---------|--------|
### Execution Order: [XML first if both XML and C# need changes]
```

---

## Plan Format: INVESTIGATION

```
## Investigation Plan

### Symptoms: [what the user reported]
### Hypothesis: [initial theory based on Connector Map analysis]
### Diagnostic Steps:
1. [what to check first]
2. [what to check next]
3. [...]
### Data Flow Trace: [parameter → group → timer chain, or trigger → action → QAction chain]
```

Investigation plans do NOT include implementation — only diagnosis. Changes require separate user approval.

---

## Plan Format: REVIEW

```
## Review Plan

### Scope: [full connector / specific area]
### Review profile: normal | first-release
### Connector lifecycle: [draft / shipped maintenance / first Catalog release / other]
### External checklist input
- Checklist path or attachment: [external path; never a repository copy]
- Source version/date: unknown when absent
- Checklist maintainer: [owner]

### Review context
- Connection type: [SNMP / HTTP / serial / smart-serial / virtual]
- Feature flags: [tables, writes, QActions, traps, DVE, DCF, Spectrum Analyzer, Matrix, topology, tests, simulation, etc.]
- Vendor/API/MIB evidence: [paths, links, or unavailable]
- Simulation / QAOps / device evidence: [paths, targets, or unavailable]
- Catalog/DCP/approval evidence: [references, owners, or unavailable]
- Human UI/runtime sign-offs: [named owners, artifacts, or pending]

### Checklist:
- [ ] Metadata completeness
- [ ] Target DataMiner range, schema, Dev Pack, template, and validator compatibility
- [ ] VendorOID was preserved from the existing connector or supplied by the user, and validates against the selected schema
- [ ] Parameter naming/ID conventions
- [ ] Connection-type correctness
- [ ] Alarm/trending configuration
- [ ] Timer design
- [ ] QAction quality
- [ ] UI layout
- [ ] Table display options (every table with a UI page position has `<Measurement>` with `Type options="tab=columns:..."` listing all column PIDs; background/processing tables without a page position are exempt)
- [ ] Performance patterns
- [ ] Data handling patterns
- [ ] Unit test coverage

### First-release execution rules (when selected)
- [ ] Run the normal baseline first.
- [ ] Load `first-release-review-matrix.md` only after explicit opt-in.
- [ ] Reuse `existing` baseline results; report only `enhance` deltas and applicable `new` rows.
- [ ] Preserve every source occurrence, including duplicate IDs and `SCRXXX`; do not convert `Other Remarks` or form fields into automatic checks.
- [ ] Give every applicable row developer-facing feedback; FAIL rows include exact location, current snippet where useful, correction, owner, and post-fix validation.
- [ ] Report missing runtime/external/human evidence as `UNVERIFIED` or `BLOCKED`, never as PASS.
- [ ] Report checklist/technical contradictions as `CONFLICT` and do not recommend invalid or unsafe fixes.
- [ ] Produce separate `AI code review` and `Release readiness` verdicts.

### Evidence and handoff
- [ ] Required evidence requests and owners are listed before reviewer delegation.
- [ ] The reviewer handoff includes this complete Review Plan, not only a generic review sentence.
- [ ] Existing XML/QAction fixer handoffs remain read-only suggestions (`send: false`).
```

---

## Lightweight Mode

For trivial single-element tasks (e.g., "rename this parameter"), a brief 3-line plan is sufficient. Full tables are not needed for simple changes. Use judgment.
