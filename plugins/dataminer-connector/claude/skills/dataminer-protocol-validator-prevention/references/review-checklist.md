# Connector Review Checklist — Additional Quality Domains

Extracted from `agents/dataminer-reviewer.agent.md` Step 4. The reviewer agent loads this reference and walks every domain. Use it as a finite checklist — do not skip domains because nothing obvious is wrong.

Findings discovered through this checklist should be reported with severity (Critical/Major/Minor/Info) and a concrete suggested fix, following the reviewer agent's Output Format.

## Review profile boundary

This file is the **normal connector review baseline**. The reviewer loads it by default and walks every
domain listed below; a normal review must not acquire the first-release evidence burden merely because
the connector is new, has version `1.0`, or is being reviewed before release.

When the caller explicitly selects `review_profile=first-release`, the reviewer runs this normal
baseline first and then loads
`skills/dataminer-protocol-validator-prevention/references/first-release-review-matrix.md`.
The first-release matrix is an additional source-traceability and evidence layer:

- `existing` rows point to coverage already performed by this checklist and must not create a duplicate finding.
- `enhance` rows add only the narrower evidence, feedback, owner, or gate that is missing from this baseline.
- `new` rows add first-release coverage only when their `applies_if` condition is proven.
- Manual/reference rows such as `Other Remarks`, `Remark (1st)`, and `Developer Comments` remain
  human context and never become automatic PASS/FAIL checks.
- The externally supplied OneNote checklist controls first-release coverage and release-gate policy.
  If its requirement conflicts with schema, validator, SDK/DIS/QAOps, vendor, or safety facts,
  report `CONFLICT`, cite both sources, and do not recommend an invalid or unsafe fix.

The raw checklist is an execution-time input and is not stored in connector repositories. The reviewer
must preserve the matrix's row-level developer feedback contract: failures identify the exact location,
current evidence/snippet, impact, correction, owner, and post-fix validation; missing runtime or external
evidence is reported as `UNVERIFIED` or `BLOCKED`, not silently passed.

## Timer design

- Last group in a timer must be a poll group.
- Non-poll-only timers disabled by default; started from after-startup logic.
- Keep timer count minimal — each timer = one thread.
- Timer interval must allow all groups to complete.

## Protocol communication

- Verify sets by re-reading after write.
- Handle timeouts proactively — do not wait for the protocol timeout.
- Prefer XML `<Condition>` constructs over QAction `if`-checks.
- Use QActions only when no XML construct can achieve the goal.

## Performance

- No protocol method calls inside loops.
- `GetColumns` < 120 K cells per call.
- Sets < 20 K cells.
- `FillArray` < 1000 rows.
- No action > 15 min (RTE); half-open at 7.5 min.
- Avoid `ClearAllKeys()`.
- Use `GetColumns` / `SetColumns` from `Skyline.DataMiner.Utils.Protocol.Extension` for column-level table access; verify the package reference and namespace import.
- SNMP poll groups with multiple single (scalar) parameters should set `multipleGet="true"` on `<Content>` to batch them into one GET request (multipleGet on groups CANNOT be used for groups with table parameters in it; table retrieval options belong on the table OID).

## Data handling patterns

- Tables should hold current entries.
- Decide whether "previous data comparison" or "infinitely growing data" patterns are needed.
- Clear table data when polling is disabled.

## DVE conventions

- Child element name format: `"Mother Protocol Name - Product Name"`.
- No auto-delete of DVE children.
- `ExportRules` should strip table name prefixes/suffixes from exported column descriptions.

## Connection settings / PortSettings

- Port settings must have default values.
- Inapplicable port types must be disabled (e.g. disable Serial and UDP for HTTP).
- HTTP default bus address = `"ByPassProxy"`.
- Correct connection naming (`"IP Connection"`, etc.).

## Relations

- For tables with foreign key columns, verify `<Relations>` are defined with correct `path` (semicolon-separated table PIDs).
- Child rows must reference valid parent keys.

## Conditions vs QActions

- Flag QActions that only contain simple `if`-checks that could be replaced with XML `<Condition>` elements on groups, timers, or triggers.

## VersionHistory

- Verify `<VersionHistory>` is maintained with correct version number, date, author, and change descriptions for each release.

## Unit tests

- Flag if no test project exists in the solution.
- Suggest adding unit tests for QActions using `Skyline.DataMiner.Utils.UnitTestingFramework`.

## EPM / Topology

- If topology elements (`<Topology>`, `<Chains>`) are present, verify:
  - Chain definitions reference valid tables.
  - Fields point to correct column PIDs.
  - `<Relations>` support the chain hierarchy.

## UI — Pages

- General page must exist and be the default.
- Web Interface page must be last, preceded by a separator.
- Max 2 columns per page.
- Each functional block has its own page.

## UI — Parameters

- Avoid True/False display values.
- All applicable params must have a unit; for dimensionless numbers (counts, IDs, indices, etc.) suppress validator rule 2.9.7 instead.
- Displayed params must have `<Subtext>` tooltips describing the parameter in plain language (never include technical details like SNMP OIDs).
- Date/time params use `"date"`, `"time"`, or `"datetime"` measurement.
- `<Range>` on displayed number params where bounds are determinable; suppress 2.11.1 for unbounded numbers.
- Monitored params should have alarm thresholds where determinable; suppress 2.5.1 for params without industry-standard defaults.

## UI — Displayed text

- Title case for descriptions.
- Official brand/product capitalization.
- Acronyms per the defining standard.

## UI — Buttons & Controls

- Minimum button width 110; explicit and uniform.
- Page button labels end with `"..."` (no space before).
- No nested page buttons.

## UI — Tables

- Displayed tables must have a `<Measurement>` section.
- Column names start with the table name.
- Number columns: check header sum relevance (`disableHeaderSum` if not meaningful).
- Automatically polled SNMP columns (`ColumnOption type="snmp"`) must not use `;save`; polling refreshes them. Alarm monitoring and trending do not justify persistence. Keep `;save` available for explicitly justified non-SNMP columns and standalone configuration/state parameters.

For a first-release review, do not duplicate these baseline findings in the matrix output. Reference the
normal-check result from the matching `existing` or `enhance` row and report only the additional
first-release evidence or release-gate state.
