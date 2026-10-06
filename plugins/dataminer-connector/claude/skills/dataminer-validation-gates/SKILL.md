---
name: dataminer-validation-gates
description: 'Run inline validation gates during connector development: schema verification for protocol.xml, C# style prevention (SA1505/SA1508/SA1028), and build quality checks for QActions. Use between XML authoring and QAction development to catch errors early.'
argument-hint: 'Describe the validation task: e.g. "validate XML after authoring", "check build quality after QAction changes", "run schema verification gate"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-05-27
  version: 2.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2026-05-27 | Removed EcsAgent CLI dependency. XML validation is now agent-driven using `dataminer-protocol-xml-reference` schema files. C# style is prevention-only (no post-hoc CLI fixer). Build validation uses plain `dotnet build`. |
| 1.2 | 2026-05-24 | Step 8 (official validator checkpoint) replaced inline CLI snippet with a pointer to `dataminer-validation` for the full CLI reference. |
| 1.1 | 2026-04-13 | Added Step 3: Fix C# (fix-csharp) for SA1505/SA1508/SA1028 auto-fix. Renumbered subsequent steps. |
| 1.0 | 2026-04-07 | Initial release. |

# Validation Gates

Inline validation gates that run between development phases to catch errors before they cascade. No external CLI tool is required — gates are implemented via agent-driven schema verification and standard `dotnet build`.

> **Paired agent**: `dataminer-connector-orchestrator` — the orchestrator calls these gates between delegation steps. This skill owns gate definitions and result interpretation.

## Step 1: Locate the solution

1. Locate the connector solution root (folder containing `.sln` or `.slnx`).
2. Identify `protocol.xml` (usually at the root of the connector project folder).

## Step 2: XML Schema Verification (after XML authoring)

Run after any `protocol.xml` changes, before QAction_Helper regeneration.

### Procedure

1. **Load core schema reference files** from `dataminer-protocol-xml-reference` — always load these four:
   - `dataminer-protocol-xml-reference/references/protocol-root.md`
   - `dataminer-protocol-xml-reference/references/protocol-params.md`
   - `dataminer-protocol-xml-reference/references/protocol-tables.md`
   - `dataminer-protocol-xml-reference/references/protocol-execution.md`

2. **Load area-specific references** based on what was changed:
   - SNMP parameters → `protocol-snmp.md`
   - HTTP sessions → `protocol-http.md`
   - Serial/smart-serial → `protocol-serial-smartserial.md`
   - WebSocket → `protocol-websocket.md`
   - Port settings/connections → `protocol-portsettings-connections.md`
   - Display/UI → `protocol-display-ui.md`
   - Alarming/trending → `protocol-monitoring.md`
   - QAction registration → `protocol-qactions.md`
   - Types/enums → `protocol-types-and-enums.md`
   - DVE/DCF/advanced → `protocol-advanced-features.md`

3. **Verify** each new or changed XML element against the loaded references:
   - Parent path exists in the schema references
   - Child element is valid at that parent path
   - Attributes are valid for that element/type
   - Required children and attributes are present
   - Enum values use exact casing and spelling
   - IDs match simple-type patterns
   - Elements are ordered by ascending ID within their section

4. **If violations are found**: fix them directly using the Error-to-Fix Mapping (Step 4 below), then re-read the affected section to confirm the fix is correct.

### What this gate catches

- Unknown or misplaced elements (e.g., `<Trending>` as `<Param>` child)
- Unknown or misplaced attributes (e.g., `foreignId` on `<Discreets>`)
- Invalid enum values (wrong RawType, SNMP Type, Measurement Type, OID type)
- Missing required elements (e.g., `<Monitored>` in `<Alarm>`)
- Wrong element ordering

## Step 3: C# Style Gate (after QAction C# code)

C# style issues (SA1505/SA1508/SA1028) are **prevented at authoring time** by the `dataminer-qaction` skill rules:
- **SA1505**: Never add blank lines immediately after opening brace `{`
- **SA1508**: Never add blank lines immediately before closing brace `}`
- **SA1028**: Never leave trailing whitespace on any line
- **Empty blocks**: Use `// TODO: Implement.` as placeholder — never leave empty brace bodies

If these issues slip through (visible in build output), fix them directly via file editing:
1. Remove any blank line immediately after `{`
2. Remove any blank line immediately before `}`
3. Remove trailing whitespace from affected lines
4. Insert `// TODO: Implement.` in empty `try`/`catch`/method bodies

Scope: Only check `QAction_*/QAction_*.cs` files. Skip `QAction_Helper` (auto-generated).

## Step 4: Build Quality Gate (after C# code)

Run after writing or modifying QAction C# code:

```bash
dotnet build "{solution_root}/{solution_name}.sln" --warnaserror
```

- If build **succeeds**: gate passes.
- If build **fails with errors**: read the MSBuild output. Compilation errors go back to **dataminer-qaction-writer** with the error messages. SA*/SLC*/SXA* warnings (treated as errors by `--warnaserror`) should be fixed directly via file editing per Step 3 rules.
- Retry up to **3 times**. If still failing, report remaining errors to the user.

## Step 5: XSD Error-to-Fix Mapping

When schema verification or `dotnet build` reports XML structural issues, match each finding against this table to determine the exact fix. Apply fixes directly instead of guessing.

| Error Pattern | Root Cause | Fix |
|---|---|---|
| `has invalid child element 'WebInterface'` | `<WebInterface>` is not a valid `<Protocol>` child | Remove `<WebInterface>`. Add `Webinterface#http://[Polling Ip]/` to `<Display pageOrder="...">` |
| `has invalid child element 'Trending'` | `<Trending>` is not a valid `<Param>` child | Remove `<Trending>true</Trending>`, add `trending="true"` attribute to `<Param>` |
| `has invalid child element 'Subtext'` | `<Subtext>` is not a valid `<Param>` child | Move to `<Information><Subtext>` inside `<Param>` |
| `has invalid child element 'Units'` | `<Units>` is not a valid `<Param>` child | Move to `<Display><Units>` |
| `has invalid child element 'Includes'` | `<Includes>` is not a valid `<Param>` child | Move to `<Information><Includes>` |
| `attribute 'foreignId' is not declared` | `foreignId` does not exist on `<Discreets>` | Remove the attribute. Use `<ColumnOption type="foreignkey" ... options=";foreignkey={pid}" />` instead |
| `not valid.*EnumParamInterpretRawType` | Invalid `<RawType>` value (often an SNMP type name) | Replace with valid RawType (`other`, `numeric text`, `unsigned number`, etc.). Consult `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md` |
| `not valid.*EnumSNMPType` | Invalid `<SNMP><Type>` value (short form or wrong casing) | Use full lowercase form: `gauge32`, `counter32`, `uinteger32`, `octetstring`. Consult `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md` |
| `not valid.*EnumParamMeasurementType` | Invalid `<Measurement><Type>` value | Use valid value: `table` (not `tab`), `number`, `string`, `discreet`, etc. Consult `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md` |
| `not valid.*EnumOIDType` | Invalid `<OID type>` attribute (SNMP type name) | Change to `complete` and put the SNMP type in `<SNMP><Type>` instead |
| `not valid.*EnumColumnOptionType` | Invalid `<ColumnOption type>` attribute | Use valid type: `snmp`, `retrieved`, `custom`, `displaykey`, `foreignkey`, etc. Never `write` |
| `not valid.*TypeAlarmTemplateDefaultValues` | Alarm threshold with comma decimal separator | Replace `,` with `.` in alarm threshold values (e.g., `3,4` → `3.4`) |
| `not valid.*EnumParamInterpretType` | Invalid `<Interprete><Type>` value | Only 3 valid values: `string`, `double`, `high nibble` |

**Workflow when schema issues are found**:
1. Match against this table and fix directly.
2. Re-verify the fixed section against the loaded schema references.
3. For unknown errors not in this table, consult `dataminer-protocol-xml-reference/references/protocol-types-and-enums.md` or the relevant branch reference file.

## Step 6: Official validator checkpoint

For non-trivial XML changes and before final handoff, run the official Skyline validator. Load `dataminer-validation` for the full CLI reference (current `validate protocol-solution` vs. legacy `validate-protocol-solution`, options, JSON parsing, suppression).

Use this to confirm that the connector is not only schema-clean, but also compliant with broader Skyline validator rules.
