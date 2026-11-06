# Plan Templates & Connector Map

Reference for implementation plan formats (FEATURE, BUGFIX, INVESTIGATION, REVIEW, DOCUMENTATION) and Connector Map structure.

> **Parent skill**: `dataminer-connector-orchestrator/SKILL.md` — return there for phase workflow and constraints.

---

## Confirmed Planning Decisions

These decisions apply to every connector plan:

1. **Target compatibility is task-specific.** Record the target minimum DataMiner version, any maximum supported version, and the compatible connector Dev Pack, template, validator, and schema sources. Derive values from an existing solution when possible. For a new connector or when omitted, resolve the minimum DataMiner version dynamically from the official Skyline Software Support Lifecycles documentation (`https://docs.dataminer.services/dataminer/Reference/Software_support_life_cycles.html`) by selecting the oldest Main Release version whose support period is currently active relative to the current date; do not prompt the user or default to the latest version. Propose the resolved version in the plan for approval.
2. **Connector identity defaults when omitted.** IntegrationID, VendorOID, and DeviceOID are not strict requirements. If the user provides them, use the supplied values (and validate VendorOID against the target schema). If the user does not provide them, use the standard defaults:
   - `<IntegrationID>DMS-DRV-XXXX</IntegrationID>`
   - `<VendorOID>1.3.6.1.4.1.8813.2.XX</VendorOID>`
   - `<DeviceOID>XX</DeviceOID>`
   For an existing connector, preserve the values in `protocol.xml` unless the user explicitly changes them.
3. **QAction helper generation is conditional.** Do not introduce or require a generated QAction helper as a universal completion gate. If the existing or planned solution consumes generated helper members (including NEW connectors whose QActions will reference `Parameter.*` or `SLProtocolExt`) and an XML change affects them, generate/refresh the helper via `dataminer-qaction-helper-generator` (`qaction-helper-generation` or the official `Skyline.DataMiner.Files.QActionHelper` fallback); never manually hand-synthesize `QAction_Helper.cs`. Otherwise skip helper generation.
4. **Simulation routing is unchanged.** When simulation is explicitly requested, retain the existing TOON simulation route and contract. This plan does not broaden, replace, or automatically invoke it.
5. **Artifact ownership is explicit.** Assign XML to `dataminer-connector-xml-author`, or explicitly select initial inline ownership before any worker starts. QAction C# and projects belong to `dataminer-connector-qaction-writer`, tests to `dataminer-connector-test-writer`. QAction/trigger/action XML registrations remain with the XML owner, never the C# writer. A late XML request pauses C# work until the XML, conditional-helper, and affected build/validator gates run again.
6. **Sequencing is orchestrator-owned.** Specialists return results and do not start sideways handoffs. Each gate has at most three attempts; after the third failure the plan stops with a blocker and evidence.
7. **No concurrent XML takeover.** Poll counts and elapsed time do not transfer ownership.
   Wait or cancel and confirm termination before rereading and assigning another writer.
   If termination cannot be confirmed, report `BLOCKED`.
8. **Read-only routes terminate with findings.** REVIEW/INVESTIGATION bypass implementation
   and repair gates. Apply `dataminer-manifest/references/read-only-assessment.md` to diagnostic
   execution and optional coordination; repairs need a separate approved transition.
9. **QAction target and hard compilation gate.** All DataMiner connector QActions strictly target **.NET Framework 4.8 (`net48`)** and **C# 7.3** (`<LangVersion>7.3</LangVersion>`). Never use C# 8.0/9.0+ syntax or bump `<LangVersion>` above `7.3`. Only fully compiling code (`dotnet build` passing with 0 errors across the solution) may ever be returned to the user or committed/pushed to a PR.

---

## Connector Map Template

Build this map by reading `protocol.xml` completely before proposing any changes. This prevents ID collisions, naming conflicts, and structural mismatches.

**How to build:**
1. Read `protocol.xml` completely
2. Scan for root `<Version>` and active `<VersionHistory>` details (Branch ID, SystemVersion ID, MajorVersion ID, latest MinorVersion ID, last release date)
3. Scan for all parameter IDs, group IDs, timer IDs, trigger IDs, action IDs, QAction IDs
4. List all tables with their column PIDs
5. List all pages and which parameters are on each
6. Identify the connection type from the `<Type>` element
7. Calculate the next available IDs

```
## Connector Map
- **Name**: [protocol name from <Name>]
- **Version Details**:
  - Current Version: [from root <Version>, format Branch.SystemVersion.MajorVersion.MinorVersion, e.g. 1.0.0.1]
  - Active Branch ID: [from <VersionHistory><Branches><Branch id="...">]
  - Active SystemVersion ID: [from <SystemVersions><SystemVersion id="...">]
  - Active MajorVersion ID: [from <MajorVersions><MajorVersion id="...">]
  - Latest MinorVersion ID: [from <MinorVersions><MinorVersion id="...">]
  - Last Release Date: [from latest <MinorVersion><Date>, YYYY-MM-DD]
- **Connection Type**: [from <Type>]
- **Compatibility**:
  - Minimum DataMiner version: [from Compliancies/MinimumRequiredVersion or lifecycle docs (oldest supported Main Release) or user]
  - Maximum supported version: [from Compliancies/MaximumSupportedVersion, or none]
  - Dev Pack / template / validator versions: [from project files and target-version resolution]
  - Schema source/version: [from the protocol XML source manifest selected for this task]
- **IntegrationID**: [value and source: existing protocol.xml | user prompt | default: DMS-DRV-XXXX]
- **VendorOID**: [value and source: existing protocol.xml | user prompt | default: 1.3.6.1.4.1.8813.2.XX; schema validation result]
- **DeviceOID**: [value and source: existing protocol.xml | user prompt | default: XX]
- **Parameter ID Ranges**:
  - Standalone: [list/ranges in use, highest = X]
  - **Tables**:
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
- **QActions**: [ID, trigger PID, options/dllImport, project & .cs file/folder structure (including QAction_1 shared folders/namespaces/files)]
- **Pages**: [name, parameters displayed]
- **Next Available IDs**:
  - Parameter: [next standalone], [next table PID]
  - Group: [X]
  - Timer: [X]
  - Trigger: [X]
  - Action: [X]
  - QAction: [X]
- **Artifact Ownership**:
  - `protocol.xml`: `dataminer-connector-xml-author`
  - QAction C# / project files: `dataminer-connector-qaction-writer`
  - Unit tests: `dataminer-connector-test-writer`
  - Validator output: `dataminer-connector-validator` (read-only)
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
| Minimum DataMiner version | [value] | [existing XML | lifecycle docs (oldest active Main Release) | user requirement] |
| Maximum supported version | [value or none] | [existing XML or user requirement] |
| QAction target & language | `.NET Framework 4.8` (`net48`) / `C# 7.3` | Mandatory DataMiner SLScripting & Validator contract |
| Protocol schema | [package/version/revision] | [source manifest] |
| Connector Dev Pack | [package/version or not applicable] | [existing project or target-compatible selection] |
| Template / validator | [version] | [existing solution or current approved tool] |

### Connector Identity
- IntegrationID: [value] (source: existing protocol.xml | user prompt | default: DMS-DRV-XXXX)
- VendorOID: [value] (source: existing protocol.xml | user prompt | default: 1.3.6.1.4.1.8813.2.XX)
- DeviceOID: [value] (source: existing protocol.xml | user prompt | default: XX)
- Target-schema validation: pass | default | unresolved conflict requiring user decision

### Version & Version History
#### For NEW connectors (Initial Release)
- Initial Version: `1.0.0.1` (format Branch.SystemVersion.MajorVersion.MinorVersion)
- Release Date: [YYYY-MM-DD]
- Provider:
  - Author: [Author Name]
  - Company: Skyline Communications
- Initial Changes block:
  - `<NewFeature>Initial version</NewFeature>`
- VersionHistory structure:
  - Branch ID: `1` (Comment: Main Branch)
  - SystemVersion ID: `0`
  - MajorVersion ID: `0`
  - MinorVersion ID: `1`
- References (optional):
  - TaskId: [DCP/task ID if applicable]

#### For FEATURE additions (Existing connector)
- Current Version: [from root <Version>]
- Proposed New Version: [e.g. 1.0.0.5 for Minor increment, or 1.0.1.1 for Major increment if breaking]
- Version Bump Type: Minor increment (routine feature addition e.g. 1.0.0.4 -> 1.0.0.5) | Major increment (breaking/MajorChange update e.g. 1.0.0.4 -> 1.0.1.1)
- Release Date: [YYYY-MM-DD]
- Provider:
  - Author: [Author Name]
  - Company: Skyline Communications
- Proposed `<Changes>` block:
  - `<NewFeature>`: [Description of new feature]
  - `<Change>`: [Modification/enhancement details, if applicable]
- References (optional):
  - TaskId: [DCP/task ID if applicable]

### Proposed Changes

#### Parameters
| PID | Name | Description | Type | Measurement (options) | Cadence (Fast / Slow) | Alarm / Thresholds | SNMP OID / Source | Page |
|-----|------|-------------|------|-----------------------|-----------------------|--------------------|-------------------|------|

> For parameters with pre-known values, plan them as discrete with numeric backend mapping (e.g., `discreet (1: Online, 2: Offline, 3: Fault)` or `togglebutton (1: Disabled, 2: Enabled)`) to support alarming and trending.
> For read/write parameter pairs, plan both the `read` and `write` rows with the **exact same `Name`, `Description`, and `Page`/position** (write PID = read PID + 50 preferred, +100 max, placed immediately after the read row). Never append `_Write`, `Write`, `(Write)`, or `Set` to the write parameter's `Name` or `Description`, or the UI will fail to link them as a combined control even on the same position.
> **Order the Parameters table strictly from low PID to high PID** (with only the read/write pair exception where each write row immediately follows its paired read row). Never group rows by UI page, API endpoint, or feature in a way that places higher-PID parameters (such as table and column parameters) before lower-PID parameters.
> For HTTP connectors where a parameter contains the dynamic request URL, plan `<Request verb="..." pid="<paramId>">` (`Protocol.HTTP.Session.Connection.Request-pid`) and omit `url` — never plan `url="[param:<paramId>]"`.

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
| ID | Trigger PID | Options / dllImport | Purpose | Project / File Structure |
|----|-------------|---------------------|---------|--------------------------|

> **Multi-file `QAction_1` (`precompile`) planning rule**: Code in `QAction_1` does **not** have to live in a single giant `QAction_1/QAction_1.cs` file. Whenever code is shared across multiple QActions or a connector has non-trivial C# domain models/DTOs, parsers, table builders, or helpers, plan `QAction_1` (`options="precompile"`, no `triggers`) with a clean folder, namespace, and class-per-file layout inside the `QAction_1/` project (e.g., `QAction_1/Models/<Model>.cs`, `QAction_1/Parsers/<Parser>.cs`, `QAction_1/Helpers/<Helper>.cs`), and keep triggered QActions (`QAction_N/QAction_N.cs`) as thin entry points with `dllImport="[ProtocolName].[ProtocolVersion].QAction.1.dll"` in `protocol.xml` and `<ProjectReference Include="..\QAction_1\QAction_1.csproj" />` in `QAction_N.csproj`.

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
2. If the existing or planned solution consumes generated QAction helper members and the XML change affects them, generate/refresh the helper via `dataminer-qaction-helper-generator` (never hand-synthesize `QAction_Helper.cs`); otherwise record "not required"
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

### Version & Version History
- Current Version: [from root <Version>]
- Proposed New Version: [e.g. 1.0.0.5 for Minor increment, or 1.0.1.1 for Major increment if breaking]
- Version Bump Type: Minor increment (routine bugfix e.g. 1.0.0.4 -> 1.0.0.5) | Major increment (breaking change)
- Release Date: [YYYY-MM-DD]
- Provider:
  - Author: [Author Name]
  - Company: Skyline Communications
- Proposed `<Changes>` block:
  - `<Fix introducedIn="...">`: [Bug fix details referencing version where defect was introduced, e.g. introducedIn="1.0.0.4"]
  - `<Change>`: [Modification/adjustment details, if applicable]
  - `<NewFeature>`: [Description of new feature, if applicable]
- References (optional):
  - TaskId: [DCP/task ID if applicable]

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
- [ ] VendorOID was preserved from the existing connector, supplied by the user, or set to the default (1.3.6.1.4.1.8813.2.XX), and validates against the selected schema
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
