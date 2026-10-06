---
name: dataminer-validation
description: 'DataMiner connector validation: running the validator CLI, parsing JSON output, severity levels (Critical/Major/Minor/Warning), suppressing validator remarks with XML comments, common error codes, and fix suggestions. Use when validating a connector solution or interpreting validator results.'
argument-hint: 'Describe the validation task: e.g. "run validator on my solution", "suppress validator warning 2.5.1"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-29
  version: 3.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 3.0 | 2026-09-29 | Require checking existing validator availability and user approval before machine-wide installation. |
| 2.9 | 2026-09-14 | Made helper recovery conditional on projects that actually reference generated helper output. |
| 2.8 | 2026-09-11 | Reconciled high-churn `volatile` guidance: incompatible alarm/persistence requirements now require explicit redesign instead of silently removing behavior. |
| 2.7 | 2026-07-17 | Clarified that validator suppression comments are the intentional exception to connector XML comment hygiene, not a general documentation mechanism. |
| 2.6 | 2026-07-02 | Confirmed `.slnx` support by live-testing `dataminer-validator` CLI 3.2.0 against an official-template `.sln` and its `dotnet sln migrate`-generated `.slnx` counterpart (identical results). Generalized all `--solution-path` examples, the Options Reference, and workflow text from `.sln`-only to `.sln`/`.slnx`. |
| 2.5 | 2026-05-24 | Extracted 200-line "Common Suppressions" worked examples (2.9.7, 2.5.1, 2.11.1) into `references/suppression-examples.md`. SKILL.md now keeps only syntax + rules + pointer; full examples load on demand. |
| 2.4 | 2026-05-24 | Reduced "Mandatory Validator Cadence" section to a pointer (authoritative cadence lives in `dataminer-sdk`) to remove duplication. |
| 2.3 | 2026-05-14 | Added DIS routing and validator CLI version-awareness. |
| 2.2 | 2026-05-14 | Added SDK-first validation rule, validator cadence, and `dataminer-sdk` cross-reference. |
| 2.1 | 2026-04-18 | Added 'hg'/SI-prefix combinations to 2.9.7 bad-unit examples with "when uncertain, suppress" default rule, targeting "Unknown unit 'hg'" findings from non-registered pressure/mass unit strings. |
| 2.0 | 2026-04-13 | Extracted Common Fix Patterns into `references/known-fix-patterns.md`. Skill now focuses on CLI reference, severity levels, suppression syntax, and common suppressions. |
| 1.1 | 2026-03-27 | Initial release. |

# DataMiner Connector Validation

Covers running the official Skyline validator and interpreting its output.

> **Paired agent**: `dataminer-validator` — owns workflow, output format, and fix-or-suppress decisions. This skill owns CLI reference, severity definitions, suppression syntax, and error codes. Keep shared concepts (severity thresholds, suppression rules) in sync.

Load `dataminer-sdk` alongside this skill. Load `dataminer-dis` as well when the user is working in Visual Studio with DIS available and interactive validator review would help. The official Skyline validator is mandatory during development; manual XML review or only local helper gates are never sufficient.

---

## Prerequisites

First check whether the official validator is already available:

```bash
dataminer-validator --help
```

If it is unavailable, inspect the repository's approved tool setup before installing anything. Do not
install the validator globally as an automatic fallback: a global install changes machine-wide
tooling. Ask the user before doing that. After approval, the one-time global install is:

```bash
dotnet tool install --global Skyline.DataMiner.CICD.Tools.Validator
```

If the tool cannot be installed or the user has not approved a machine-wide install, report the
official validation gate as **not run**. XML parsing, manual review, and a solution build are
supplemental checks and must not be reported as a passing official validation.

---

## Running the Validator

Current validator releases use hierarchical subcommands:

```bash
dataminer-validator validate protocol-solution --solution-path "<path-to>.sln" --output-directory "<output-folder>" -of JSON
```

Some older machine-wide installs only expose the legacy command:

```bash
dataminer-validator validate-protocol-solution --solution-path "<path-to>.sln" --output-directory "<output-folder>" -of JSON
```

> `--solution-path` accepts either a `.sln` or a `.slnx` file — verified working identically against `dataminer-validator` CLI 3.2.0 (a `.slnx` generated from the same `.sln` via `dotnet sln migrate` produced identical validation results). The examples above use `.sln` for brevity; substitute `.slnx` if that's your solution's format.

Check `dataminer-validator --help` before assuming the command shape.

## DIS Validator

When the user is working in Visual Studio with DIS installed, DIS Validator is **highly advised** for iterative review because it adds:

- direct navigation to findings,
- auto-fix discovery,
- certainty and fix-impact review,
- suppression/postponement actions, and
- grouped interactive review.

DIS is not mandatory. For headless or automated workflows, keep using the official CLI.

## Mandatory Validator Cadence

The full lifecycle cadence (scaffolding → XML edits → conditional helper refresh → QAction changes → completion) lives in `dataminer-sdk` → "Mandatory Validation Cadence". The non-negotiable rule: run the official validator after meaningful XML milestones, re-run after build-affecting changes, and always before reporting complete. Project-local gates supplement but never replace it.

### Options Reference

| Option | Short | Description |
|--------|-------|-------------|
| `--solution-path` | | Path to the `.sln` or `.slnx` file (required) |
| `--output-directory` | | Where to write results |
| `--output-format` | `-of` | `JSON`, `XML`, or `HTML` (default: JSON + HTML) |
| `--output-file-name` | `-ofn` | Custom results filename (without extension) |
| `--include-suppressed` | `-is` | Include suppressed results |
| `--perform-restore` | `-pr` | Run `dotnet restore` first (default: true) |

> The validator requires a full Visual Studio solution (`.sln` or `.slnx`). It does not work on standalone `protocol.xml` files.

> For compare/Major Change Checker work, current validator releases support `dataminer-validator compare protocol-solution ...`. If the installed CLI lacks `compare`, use DIS Comparer or update the tool.

> **If you see "C# checks could not be executed"**: This warning means the solution did not compile before validation ran. C# static checks are skipped entirely. To resolve:
> 1. Run `dotnet build "<path>.sln"` (or `.slnx`) and fix any compilation errors first.
> 2. Re-run the validator with `--perform-restore true` explicitly passed (it defaults to true but may be overridden).
> 3. If a project references generated helper types and the build fails because that output is missing or stale, regenerate it before re-running. Do not introduce a helper into an intentionally helper-free project.
>
> Until this is resolved, validator results are **incomplete** — do not treat a clean XML-only run as fully passing.

---

## Interpreting Results

### Severity Levels

| Severity | Action Required |
|----------|----------------|
| **Critical** | Must fix — breaks functionality or prevents connector from working |
| **Major** | Must fix — significant standards violation or functional issue |
| **Minor** | Must fix or suppress — best-practice violation |
| **Warning** | Must fix or suppress — low-priority improvement |

### Workflow

1. Find the `.sln` or `.slnx` file in the workspace.
2. Run the validator command.
3. Read the generated JSON results.
4. Group results by severity (Critical → Major → Minor → Warning).
5. For each issue, identify:
   - The validator code (e.g. `2.5.1`)
   - The affected element/parameter
   - A one-line description
   - A suggested fix
6. Fix Critical and Major issues first. Re-run to confirm.
7. ALL validator remarks must be fixed or suppressed with valid justification — zero unresolved remarks are allowed regardless of severity. **ALWAYS fix Minor or Warning findings that correspond to a known fix pattern with a determinable solution (e.g., 2.11.1 Missing Display/Range, 2.9.7 Missing Units when unit is known) — do NOT treat these as optional.** **When the same finding type appears for 5 or more PIDs (bulk finding), enumerate ALL affected PIDs from the JSON results before making any edits, then fix every one in a single comprehensive pass. Stopping after fixing a subset leaves the connector in a partially-fixed state and fails the zero-remarks policy.**

---

## Suppressing Validator Remarks

When a remark is not meaningful for a specific parameter, suppress it with XML comments wrapping the element that causes the remark.

These `SuppressValidator` wrappers are an intentional, narrowly scoped exception to the connector XML comment-hygiene rule. They are not a place for general documentation or implementation notes; use a specific reason tied to the suppressed finding.

### Syntax

```xml
<!-- SuppressValidator <code> <reason> -->
<TagThatCausesRemark>...</TagThatCausesRemark>
<!-- /SuppressValidator <code> -->
```

- `<code>` is the validator result code (e.g. `2.5.1`).
- `<reason>` is **mandatory** — explain why it's suppressed.
- Comments must directly wrap the **specific child element** causing the remark, not the entire `<Param>`.

### Suppression Rules

- Only suppress remarks that are **genuinely not applicable**.
- Always provide a **clear, specific reason**.
- Do NOT suppress Critical or Major issues without compelling justification.
- Suppressed remarks can be reviewed with the `--include-suppressed` flag.

### Common Suppressions And Worked Examples

For full worked examples of the most common suppressions — `2.9.7` (Missing Units / Unknown unit), `2.5.1` (Missing alarm thresholds), and `2.11.1` (Missing Range) — load `dataminer-validation/references/suppression-examples.md`. That reference includes wrapper placement, unit-string pitfalls (case sensitivity, `°C` vs `deg C`, unregistered SI prefixes), and reason templates for each code.

<!-- INTENTIONALLY SHORT: full examples extracted to references/suppression-examples.md in v2.5 to keep this skill load-light. -->

---

## Reference Files

| Topic | Reference File |
|-------|---------------|
| Worked suppression examples for codes 2.9.7, 2.5.1, 2.11.1 (wrapper placement, unit pitfalls, reason templates) | `dataminer-validation/references/suppression-examples.md` |
| Deterministic fix patterns with XML examples (18+ patterns) | `dataminer-validation/references/known-fix-patterns.md` |

Load the reference file when interpreting validator results. It covers: Missing Param@id, NamingFormat, PK Interprete/Type, ArrayOptions naming, Display/Range, Measurement/Type tab, index attribute, volatile, ping group, displaykey column, RTDisplay, page existence, WebInterface, discreet title casing, togglebutton, Alarm/Info tag, and more.
