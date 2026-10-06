---
name: dataminer-toon-simulation
description: 'Generate TOON-format simulation files from DataMiner connector protocol.xml: endpoint extraction, realistic data generation, and TOON encoding rules for HTTP and SNMP connectors.'
argument-hint: 'Describe the simulation task: e.g. "generate simulation file for this SNMP connector" or "create HTTP simulation data from protocol.xml"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-11
  version: 1.1
---

# DataMiner TOON Simulation File Generation

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.1 | 2026-09-11 | Added recognition of SecureCoding deserialization when inferring HTTP response models from QActions. |

Generate `.toon` simulation files that define realistic mock data for every endpoint in a DataMiner connector. The output file is a standalone simulation definition designed for consumption by a dedicated simulator tool/process.

> **Paired agent**: `dataminer-simulation-generator` — owns the generation workflow. This skill owns the TOON encoding rules, simulation schema definitions, and data generation heuristics.

## Supported Connection Types

| Type | Simulation Section | Data Source in protocol.xml |
|------|-------------------|----------------------------|
| SNMP | `snmp.scalars`, `snmp.tables` | `<Param>` with `<SNMP><OID>` elements |
| HTTP | `http.sessions[].connections[].response` | `<HTTP><Session><Connection>` elements + QAction C# deserialization classes |

## Reference Files

Load these references when needed:

| Topic | Reference File |
|-------|---------------|
| TOON encoding rules (syntax, indentation, quoting, arrays) | `references/toon-syntax-primer.md` |
| SNMP simulation schema + annotated example | `references/simulation-schema-snmp.md` |
| HTTP simulation schema + annotated example + C# class inspection | `references/simulation-schema-http.md` |
| Data generation heuristics (name patterns → values, type defaults) | `references/data-generation-heuristics.md` |

## Output File

- **Filename**: `simulation.toon`
- **Location**: Solution root (same level as `protocol.xml` or `.sln`)
- **Encoding**: UTF-8, LF line endings, 2-space indent, no trailing spaces or trailing newline

## Quick Schema Overview

Every simulation file has this top-level structure:

```toon
meta:
  connector: Vendor - Product
  version: 1.0.0.1
  type: snmp
  generated: 2026-07-08T12:00:00Z
```

Then one or both protocol-specific sections follow:

- **SNMP connectors** → `snmp:` section with `scalars` tabular array and `tables` list
- **HTTP connectors** → `http:` section with `sessions` list containing connections and response bodies
- **Mixed connectors** → both sections present

## Endpoint Extraction Summary

### SNMP Extraction

1. Find all `<Param>` elements containing `<SNMP><OID>` children
2. Classify each:
   - **Scalar**: standalone param with `<OID type="complete">` (full OID ending in `.0` or similar)
   - **Table column**: param referenced in an `<ArrayOptions>` table definition, OID is a sub-ID
3. Group table columns by their parent table parameter (the param with `<ArrayOptions>`)
4. Extract the SNMP `<Type>` for each OID (OctetString, Integer32, Counter32, Gauge32, TimeTicks, Counter64, IpAddress)

### HTTP Extraction

1. Find all `<HTTP><Session>` elements → each becomes a session entry
2. For each `<Connection>` within a session → extract `<Request verb="..." url="...">` and `<Response><Content pid="..."/>`
3. Cross-reference content PIDs to determine response shape:
   - If PID maps to a single read param → scalar JSON response
   - If PID maps to params parsed into a table → JSON array response
4. **Inspect QAction C# code** for deserialization classes (see HTTP schema reference for details)

## Data Generation Quick Rules

| Pattern in Parameter Name | Generated Value |
|--------------------------|-----------------|
| `*uptime*`, `*sysUpTime*` | 1234567 (TimeTicks) |
| `*name*`, `*sysName*` | `router-core-01` |
| `*descr*`, `*description*` | `Linux router 5.15.0-generic` |
| `*speed*`, `*ifSpeed*` | 1000000000 |
| `*status*`, `*operStatus*` | 1 (up) |
| `*address*`, `*ipAddr*` | `192.168.1.1` |
| `*count*`, `*counter*` | 42857 |
| `*index*` | Sequential integers starting at 1 |

See `references/data-generation-heuristics.md` for the complete lookup table.

## Constraints

- Never invent OIDs or URLs not present in `protocol.xml`
- Every parameter with an SNMP OID or HTTP response mapping MUST appear in the output
- Table rows default to 3 unless the connector structure suggests otherwise
- HTTP response bodies MUST be syntactically valid JSON matching the parameter parsing structure
- Output MUST be valid TOON (per syntax primer rules)
- `[N]` counts MUST match actual row counts
- No trailing spaces on any line; no trailing newline at end of file
