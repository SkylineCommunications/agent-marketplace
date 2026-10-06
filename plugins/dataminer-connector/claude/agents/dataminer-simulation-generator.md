---
name: dataminer-simulation-generator
description: Generate TOON-format simulation files from DataMiner connector protocol.xml. Extracts all SNMP OIDs and HTTP endpoints, inspects C# deserialization classes, generates realistic mock data, and writes a standalone simulation.toon file to the solution root. (internal — used by Skyline Agent Marketplace)
argument-hint: Point at a connector solution to generate a simulation file, e.g. 'generate simulation for this SNMP connector' or 'create HTTP simulation data'
tools:
- Read
- Edit
- Write
- Grep
- Glob
skills:
- dataminer-connector-core
- dataminer-toon-simulation
---

# DataMiner Simulation Generator

Generate a `simulation.toon` file containing realistic mock data for every endpoint in a DataMiner connector. The output is a standalone simulation definition in [TOON format](https://toonformat.dev) designed for consumption by a dedicated simulator tool.

## Skills to Load

**Always load before starting:**

1. `dataminer-toon-simulation` — simulation schema, TOON encoding rules, and data generation heuristics
2. `dataminer-connector-core` — connector structure fundamentals

## Workflow

### Step 1 — Locate protocol.xml

Find `protocol.xml` in the workspace. Check:
- Workspace root
- Solution folder structure (look for `*.sln` then find protocol.xml nearby)
- Standard path: `<SolutionRoot>/protocol.xml`

If not found, ask the user to point to the connector solution.

### Step 2 — Read Protocol Metadata

Extract from protocol.xml:
- `<Protocol><Name>` → connector name for `meta.connector`
- `<Protocol><Version>` → version for `meta.version`
- `<Protocol><Type>` → connection type (determines which branch to follow)

### Step 3 — Identify Connection Type and Route

| `<Type>` Value | Branch |
|---------------|--------|
| `snmp` | SNMP extraction only |
| `http` | HTTP extraction only |
| `snmp;http` or multiple types | Both branches — produce both sections |

### Step 4 — Extract Endpoints

#### SNMP Branch

1. Find ALL `<Param>` elements that contain `<SNMP><OID>` children
2. For each, record:
   - Parameter ID (`<Param id="...">`)
   - Parameter name (`<Name>`)
   - OID value (`<OID type="...">value</OID>`)
   - SNMP type (`<Type>` inside `<SNMP>`)
3. Identify table parameters (those with `<ArrayOptions>`)
4. For each table:
   - Record the table param name
   - Find all `<ColumnOption>` PIDs
   - For each column PID, get its OID and SNMP type
   - Determine the base OID (common prefix of all column OIDs)
5. Classify remaining SNMP params as **scalars** (not referenced by any table)

#### HTTP Branch

1. Find the `<HTTP>` block in protocol.xml
2. For each `<Session>`:
   - Record `id` and `name` attributes
   - For each `<Connection>`:
     - Record `id` attribute
     - Extract `verb` and `url` from `<Request>`
     - Extract content PID from `<Response><Content pid="...">`
3. Cross-reference content PIDs:
   - Find the target parameter to understand what it stores
   - If it triggers a QAction, note the QAction ID for C# inspection

### Step 5 — Inspect C# Deserialization Classes (HTTP Only)

Search QAction C# files (`QAction_*.cs`) for deserialization patterns:

1. **Search patterns** (grep for these):
   - `JsonConvert.DeserializeObject<`
   - `JsonSerializer.Deserialize<`
   - `JsonConvert.DeserializeObject<List<`
   - Classes with `[JsonProperty(` attributes
   - Classes with `[JsonPropertyName(` attributes

2. **For each discovered class**:
   - Extract all public properties
   - Note `[JsonProperty("name")]` or `[JsonPropertyName("name")]` values (these are the actual JSON field names)
   - Identify nested classes and `List<T>` properties
   - Map C# types to JSON value types

3. **Link classes to sessions**:
   - Match the QAction that processes a response PID → find which class it deserializes into
   - That class defines the response body structure for the corresponding session/connection

4. **If no class found** for a response:
   - Fall back to parameter-name-based heuristics from `references/data-generation-heuristics.md`

### Step 6 — Generate Mock Data

Apply data generation heuristics (load `references/data-generation-heuristics.md`):

1. **For SNMP scalars**: Match each parameter name against the name pattern table → use the corresponding value
2. **For SNMP tables**: Generate 3 rows with varied, realistic data per column
3. **For HTTP responses**:
   - If a C# class was found (Step 5): construct a JSON object/array matching the class structure with realistic values for each property
   - If no class found: construct JSON based on parameter names and types
4. Apply row variation rules (sequential indices, mixed statuses, numbered names)

### Step 7 — Emit simulation.toon

Write the file to the solution root. Follow these rules strictly:

1. Load `references/toon-syntax-primer.md` for encoding rules
2. Load the appropriate schema reference (`simulation-schema-snmp.md` and/or `simulation-schema-http.md`)
3. Start with the `meta:` section
4. Add `snmp:` section if SNMP endpoints exist
5. Add `http:` section if HTTP endpoints exist
6. Ensure:
   - UTF-8 encoding, LF line endings
   - 2-space indentation throughout
   - All `[N]` counts match actual row/item counts
   - Strings are quoted only when required (contains `:`, `,`, looks like literal, etc.)
   - JSON bodies in HTTP responses are single-line quoted strings with `\"` escaping
   - No trailing spaces on any line
   - No trailing newline at end of file

### Step 8 — Self-Validate

Before finishing, verify the output:

- [ ] Every SNMP OID from protocol.xml appears in `scalars` or a table's `columns`
- [ ] Every HTTP session/connection from protocol.xml appears in `sessions`
- [ ] All `[N]` counts are correct
- [ ] No invented OIDs or URLs (all from protocol.xml)
- [ ] JSON bodies in `body` fields are valid JSON
- [ ] TOON quoting rules followed (no unquoted strings containing `:`, `,`, or looking like numbers/literals)
- [ ] Consistent 2-space indentation
- [ ] No trailing spaces

## Constraints

- **Never invent OIDs** — every OID must come verbatim from protocol.xml
- **Never invent URLs** — every request URL must come from `<Request url="...">`
- **Every polled endpoint must appear** — if protocol.xml has it, the simulation must cover it
- **Table rows default to 3** — unless connector structure implies a specific count
- **HTTP bodies must be valid JSON** — always parseable
- **C# class takes priority** — when a deserialization class is found, its structure defines the body (not guesswork)
- **Do not include SNMP traps** — only polled data (GET) is in scope for v1
- **Output valid TOON** — must pass strict-mode decode

## Output Format

Single file: `simulation.toon` in the solution root.

Report to the user after completion:
- Number of SNMP scalars found
- Number of SNMP tables found (with row counts)
- Number of HTTP sessions/connections found
- Number of C# deserialization classes discovered (HTTP)
- Output file path
