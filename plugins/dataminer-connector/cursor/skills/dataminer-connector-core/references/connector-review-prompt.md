# Connector Architect Review Prompt

Use this prompt after generating or modifying connector code to verify correctness against known good patterns.
Modeled after the SLC-AI-Playbook architect review prompt.

---

## How to Use

After completing a connector development task, paste this prompt into a new message (or invoke the `dataminer-reviewer` agent):

### Review profile selection

Use the **normal** profile by default. It runs the existing connector checklist below and must not
acquire first-release evidence requirements merely because the connector is new, has version `1.0`,
or is being reviewed before release.

To run the first-release profile, add this context before the prompt:

```text
Review profile: first-release
Connector lifecycle: [draft / shipped maintenance / first Catalog release / other]
External checklist file: [absolute path or attachment; never a repository copy]
Connection type: [SNMP / HTTP / serial / smart-serial / virtual]
Feature flags: [tables, writes, QActions, traps, DVE, DCF, Spectrum Analyzer, Matrix, topology, tests, simulation]
Supplied evidence: [vendor docs/MIB/API, simulation, QAOps/device target, Catalog/DCP, approvals, human UI/runtime evidence]
Required human sign-offs: [owners, artifacts, or pending]
```

For first-release reviews, also load
`skills/dataminer-protocol-validator-prevention/references/first-release-review-matrix.md` after
the normal checklist. The external OneNote checklist controls coverage and release-gate policy;
its source version/date are intentionally unknown and `SCRXXX` is accepted as supplied. Reuse
existing baseline results, add only `enhance` deltas and applicable `new` rows, and never duplicate
findings. If a checklist requirement conflicts with schema, validator, SDK/DIS/QAOps, vendor, or
safety facts, report `CONFLICT` and do not recommend an invalid or unsafe fix.

```text
Act as a Senior DataMiner Connector Architect at Skyline Communications.

Review profile: [normal (default) or first-release]
Connector lifecycle: [required for first-release]
External checklist file: [required for first-release; external path or attachment]
Connection type: [value and evidence]
Feature flags: [confirmed/inferred values]
Supplied evidence: [paths, references, or unavailable items]

Respond with:
✅ What is correct
⚠️ Risks or issues found (with parameter ID, file, and line where relevant)
🔧 Concrete fix for each issue

For every applicable checklist item, provide a row-level result rather than only a global PASS/FAIL:
- Status: PASS, FAIL, NOT_APPLICABLE, UNVERIFIED, BLOCKED, WAIVED, or CONFLICT
- Checklist/source ID and exact file, line, XML path/PID/column, method, or evidence location
- Developer feedback stating what was observed, why it matters, what to correct, the owner, and how to validate the fix
- A minimal 3-15 line XML/C# snippet with line numbers for source-based failures when it helps; redact secrets and omit large/generated/vendor dumps
- An actionable evidence request or unblock step for UNVERIFIED/BLOCKED

For first-release output, distinguish:
- AI code review: PASS or FAIL
- Release readiness: READY, NOT READY, BLOCKED, or HUMAN SIGN-OFF PENDING

Do not claim PASS or READY when required runtime, human, administrative, vendor, or external evidence is missing.

---

## Naming and IDs

- [ ] All `<Name>` elements use camelCase with no spaces, hyphens, or underscores
- [ ] Table column `<Name>` follows `tableNameColumnName` camelCase format
- [ ] Duplicate table column descriptions are disambiguated with `Column Name (Table Description)` or a clear table abbreviation; unique descriptions do not require a suffix
- [ ] Write parameter ID = read ID + 50 (or +100); never > +100 and never in a remote high range
- [ ] Standalone read parameters are in the 100–999 range; table parameters start at 1000+
- [ ] All protocol element IDs are in ascending order in the XML
- [ ] Write parameters appear immediately after their read parameters in the XML
- [ ] Display key (resolved via NamingFormat) is meaningful to the operator — raw numeric IDs or GUIDs are never acceptable as display keys

---

## XML Structure

- [ ] All 10 required metadata tags are present (Name, Description, Version, IntegrationID, Provider, Vendor, VendorOID, DeviceOID, ElementType, VersionHistory)
- [ ] `protocol.xml` contains no explanatory, documentation, TODO, FIXME, debug, workaround, or design-note comments; copyright comments and justified `SuppressValidator` wrappers are the only permitted XML comment exceptions
- [ ] `VendorOID` is a Skyline-assigned connector OID matching `1.3.6.1.4.1.8813.2.<number>`
- [ ] `DeviceOID` is a single integer, not a dotted OID
- [ ] Every parameter has `<Information><Subtext>` with a meaningful operator-facing description without technical protocol details (such as SNMP OIDs)
- [ ] Only parameters intended to support alarming have an `<Alarm>` block; every present block starts with an explicit valid `<Monitored>true|false</Monitored>` value
- [ ] Alarm threshold abbreviations are used: `CH`, `MaH`, `MiH`, `WaH`, `Normal`, `WaL`, `MiL`, `MaL`, `CL`
- [ ] No `displayColumn` attribute on any `<ArrayOptions>` — `NamingFormat` (options=";naming=...") is used instead
- [ ] Tables with non-meaningful index columns (numeric IDs, GUIDs, auto-increments) have a `<NamingFormat>` pointing to a column with user-meaningful values (e.g., name/label — not the raw index)
- [ ] Multi-PID `<NamingFormat>` (referencing >1 column) has a corresponding `<ColumnOption type="displaykey">` as the **last** column in the table
- [ ] Table array parameters use `<Measurement><Type>table</Type>` — never `discreet`
- [ ] `volatile` in `<ArrayOptions options>` is only used when **all** apply: no alarm monitoring on any column, no `save` option on any column, no foreign keys, not used for DCF, not used for DVEs; a high-churn conflict with those features is escalated for redesign
- [ ] No `foreignkey` on the index column (idx=0 column)
- [ ] No `foreignkey` pointing to a volatile table

---

## Alarming and Trending

- [ ] Numeric parameters have `<Units>` where a physical unit applies
- [ ] Numeric displayed parameters have `<Range>` or a `SuppressValidator 2.11.1` comment
- [ ] Parameters with alarming have thresholds or a `SuppressValidator 2.5.1` comment with justification
- [ ] All valid operational health, status, and telemetry parameters (capacities, voltages, currents, power, frequencies, states, error rates) have `<Alarm><Monitored>true</Monitored>` with appropriate default thresholds (or justified `SuppressValidator 2.5.1`)
- [ ] Parameters with pre-known values (enumerations, states, modes, statuses, boolean conditions) use discrete measurement (`<Type>discreet</Type>` or `togglebutton`) with a numeric backend (`<Interprete><Type>double</Type>`) so they can be alarmed and trended, with clear operator-facing labels in `<Discreet><Display>`
- [ ] Time values and durations in seconds use `<Measurement><Type options="time">number</Type></Measurement>` for automatic `hh:mm:ss` display
- [ ] `trending="true"` on numeric parameters that should be trended

---

## QAction C# Code

- [ ] Every `Run` entry point has a `try/catch(Exception ex)` wrapper
- [ ] All logging uses `ex.ToString()` — not `ex.Message`
- [ ] Log format is `QA{protocol.QActionID}|MethodName|message`
- [ ] `public class QAction` is at global scope — not inside a namespace
- [ ] `FillArray`, `FillArrayNoDelete`, `FillArrayWithColumn`, `SetRow`, `AddRow`, and `DeleteRow` are called directly on `SLProtocol`
- [ ] `GetColumns`/`SetColumns` are used only with the `Skyline.DataMiner.Utils.Protocol.Extension` package and namespace
- [ ] When using generated helper properties/tables, QAction entry point uses `SLProtocolExt protocol` directly (no casting); helper-free QActions use `SLProtocol protocol`
- [ ] No `GetParameter`/`SetParameter` calls inside loops — use bulk methods
- [ ] IDs use generated `Parameter.xxx` constants when available, otherwise descriptive local constants
- [ ] `CultureInfo.InvariantCulture` is used for all number/date parsing
- [ ] No `ClearAllKeys()` calls — selective removal or `FillArray` used instead
- [ ] All SA*/SLC*/SXA* analyzer warnings are resolved
- [ ] `Newtonsoft.Json` or another listed NuGet package is used for JSON — no custom JSON parsing

---

## Communication Patterns

**General Polling:**
- [ ] Polling is tiered across appropriate timers: static, asset, or slow-changing data (system description, vendor/model, serial number, versions, static counts) is on a slow timer (10m–1h, `initial="true"`), while fast timers (10s–60s) are reserved for dynamic operational telemetry and active tables

**HTTP connectors:**
- [ ] `<Type>http</Type>` in protocol header
- [ ] No `<SNMP>` element in an HTTP connector
- [ ] HTTP groups use `<Session>N</Session>` — not `<Param>`
- [ ] `statusCode` on `<Response>` is a parameter ID — not an HTTP status code value
- [ ] QAction-filled table columns use `type="retrieved"` — not `type="snmp"`

**SNMP connectors:**
- [ ] Scalar and table-array OIDs use an appropriate schema-valid `type`; table column OIDs use the required minimal form without `type`, `id`, or `Enabled`
- [ ] Scalar OIDs include the `.0` suffix
- [ ] SNMP table groups use `<Param>tablePid</Param>` — not `<Session>`
- [ ] Automatically polled SNMP table columns use `type="snmp"` without `;save` in `ColumnOption@options`; alarming or trending does not justify saving polled values
- [ ] Non-SNMP QAction/API-populated columns remain `type="retrieved"` (or another justified non-SNMP type) when persistence is required

---

## Final Gates

- [ ] `dotnet build` succeeds with zero errors
- [ ] DataMiner validator passes with zero unresolved remarks of any severity
- [ ] No `SuppressValidator` comments without a written justification

For the first-release profile, append a coverage summary, human/external evidence requests, the
row-level feedback ledger, and separate AI code-review/release-readiness verdicts. Keep the raw
checklist outside the repository and preserve existing XML/QAction fixer handoffs as read-only
recommendations.
```
