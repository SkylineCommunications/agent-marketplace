---
name: dataminer-manifest
description: Domain-neutral DataMiner build manifest for Connector and Automation pipeline runs. Defines the JSON schema and update protocol for connector-build-manifest.json.
argument-hint: N/A — loaded automatically by agents for manifest operations
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-27
  version: 1.3
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.3 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 1.2 | 2026-09-16 | Generalized the manifest for Connector and Automation artifacts with explicit domain and project metadata while preserving connector compatibility. |
| 1.1 | 2026-07-02 | `connector.solutionPath` description generalized from ".sln file" to ".sln or .slnx file" — the connector template's default format was verified live, and downstream tooling (validator CLI, dotnet build) confirmed to support both identically. |
| 1.0 | 2026-04-13 | Initial release. Manifest schema and agent protocol. |

## Overview

The **build manifest** (`connector-build-manifest.json`) is a single JSON file that lives in a pipeline run directory. It is created by the pipeline CLI or the orchestrator agent and updated by each agent during execution. The historical filename is retained for compatibility; the manifest supports `domain: "connector"` and `domain: "automation"`.

It provides:
- **Shared context** — connector name, classification, connection type, plan summary
- **Agent results** — status, timing, summary, and artifacts for each agent
- **Issues** — problems found during the pipeline, tracked across agents
- **Decisions** — architectural choices with rationale, for auditability
- **Validation gates** — XML and build gate pass/fail status

---

## Schema

```json
{
  "schemaVersion": "1.1",
  "runId": "{connector-name}-{yyyyMMdd-HHmmss}",
  "createdAt": "2026-04-13T09:32:11Z",
  "updatedAt": "2026-04-13T09:38:05Z",

  "domain": "connector",
  "artifactType": "classic-connector",
  "project": {
    "name": "ExampleVendor_ExampleDevice",
    "mode": "classic",
    "solutionPath": "runs/ExampleVendor_ExampleDevice-20260413-093211/workspace/ExampleVendor_ExampleDevice.sln"
  },
  "connector": {
    "name": "Skyline.Protocol.ExampleVendor.ExampleDevice",
    "vendor": "ExampleVendor",
    "connectionType": "HTTP",
    "version": "1.0.0.1",
    "solutionPath": "runs/ExampleVendor_ExampleDevice-20260413-093211/workspace/ExampleVendor_ExampleDevice.sln"
  },

  "classification": "NEW",
  "planSummary": "Create HTTP connector with 3 parameter groups (system-info, performance, alarms), timer-based polling at 30s.",

  "agentResults": {
    "scaffolder": {
      "status": "completed",
      "startedAt": "2026-04-13T09:32:15Z",
      "completedAt": "2026-04-13T09:33:45Z",
      "summary": "Created solution with 3 parameter groups, 12 parameters",
      "artifacts": ["workspace/ExampleVendor_ExampleDevice.sln", "workspace/protocol.xml"]
    },
    "xml-author": {
      "status": "completed",
      "startedAt": "2026-04-13T09:33:50Z",
      "completedAt": "2026-04-13T09:36:12Z",
      "summary": "Wrote HTTP sessions for all 3 groups",
      "artifacts": ["workspace/protocol.xml"]
    },
    "validator": {
      "status": "failed",
      "startedAt": "2026-04-13T09:37:50Z",
      "completedAt": "2026-04-13T09:38:05Z",
      "summary": "1 error: Missing trending attribute on parameter 100",
      "artifacts": []
    },
    "qaction-writer": { "status": "pending" },
    "reviewer":       { "status": "pending" },
    "test-writer":    { "status": "pending" },
    "investigator":   { "status": "pending" },
    "help-writer":    { "status": "pending" }
  },

  "issues": [
    {
      "id": "ISS-001",
      "severity": "error",
      "source": "validator",
      "category": "validation",
      "description": "Parameter 100 missing trending attribute",
      "resolution": null,
      "resolvedBy": null
    }
  ],

  "decisions": [
    {
      "id": "DEC-001",
      "agent": "scaffolder",
      "timestamp": "2026-04-13T09:33:00Z",
      "description": "Used timer-based polling at 30s interval",
      "rationale": "Device does not support push/traps"
    }
  ],

  "validationGates": {
    "xml": { "passed": true,  "attempts": 1, "lastRun": "2026-04-13T09:34:20Z" },
    "build": { "passed": false, "attempts": 0, "lastRun": null }
  },

  "finalStatus": "in-progress"
}
```

### Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `schemaVersion` | string | `"1.0"` or `"1.1"`; new domain/project fields use `"1.1"` |
| `runId` | string | Unique run identifier: `{name}-{yyyyMMdd-HHmmss}` |
| `createdAt` | ISO 8601 | When the manifest was created |
| `updatedAt` | ISO 8601 | Last modification timestamp |
| `domain` | string | `connector` or `automation` |
| `artifactType` | string | `classic-connector`, `sdk-connector`, `automation-script`, or `automation-library` |
| `project.name` | string | Project or connector name |
| `project.mode` | string | `classic`, `sdk`, `legacy-inline`, or `library` |
| `project.solutionPath` | string | Relative path to the .sln or .slnx file |
| `connector.name` | string | Full connector protocol name |
| `connector.vendor` | string | Vendor name |
| `connector.connectionType` | string | SNMP, HTTP, serial, smart-serial, virtual |
| `connector.version` | string | Connector version (e.g. `1.0.0.1`) |
| `connector.solutionPath` | string | Relative path to the .sln or .slnx file |
| `classification` | string | NEW, FEATURE, BUGFIX, INVESTIGATION, REVIEW, DOCUMENTATION, TESTING, LIVE-TEST, RELEASE, DEPLOYMENT, or OPERATIONS |
| `planSummary` | string | One-paragraph plan description |
| `agentResults.{name}.status` | string | `pending`, `running`, `completed`, `failed`, `skipped` |
| `agentResults.{name}.startedAt` | ISO 8601 | When the agent started |
| `agentResults.{name}.completedAt` | ISO 8601 | When the agent finished |
| `agentResults.{name}.summary` | string | Brief result description (under 200 chars) |
| `agentResults.{name}.artifacts` | string[] | Relative paths to output files |
| `issues[].id` | string | Unique issue ID (ISS-NNN) |
| `issues[].severity` | string | `critical`, `major`, `minor`, `warning` |
| `issues[].source` | string | Agent name that found the issue |
| `issues[].category` | string | `validation`, `build`, `structure`, `naming`, `logic` |
| `issues[].description` | string | What the issue is |
| `issues[].resolution` | string | How it was fixed (null if unresolved) |
| `issues[].resolvedBy` | string | Agent that fixed it (null if unresolved) |
| `decisions[].id` | string | Unique decision ID (DEC-NNN) |
| `decisions[].agent` | string | Agent that made the decision |
| `decisions[].timestamp` | ISO 8601 | When the decision was made |
| `decisions[].description` | string | What was decided |
| `decisions[].rationale` | string | Why it was decided |
| `validationGates.xml.passed` | boolean | Whether the XML validation gate passed |
| `validationGates.build.passed` | boolean | Whether the build quality gate passed |
| `finalStatus` | string | `in-progress`, `completed`, `failed` |

---

### Domain rules

- Connector runs may continue using the historical `connector` object and `connector.solutionPath`; do not remove it from existing manifests.
- Automation runs must set `domain: "automation"`, an `artifactType`, and `project.mode`; do not emit connector-only keys such as `connectionType`, `VendorOID`, or protocol-specific ID maps unless a linked connector is actually part of the run.
- Shared `agentResults`, `issues`, `decisions`, and `validationGates` retain the same ownership and update protocol in both domains.

## Agent Read/Update Protocol

For REVIEW, INVESTIGATION, and report-only validation, first apply
`references/read-only-assessment.md`. That boundary takes precedence over the write steps below:
only explicitly supplied external paths may be updated. Reject in-repository or ambiguous
paths visibly and return coordination results in the response instead.

### On Startup

1. Read `connector-build-manifest.json` from the manifest path provided in your invocation context.
2. Update `agentResults["{your-agent-name}"].status` to `"running"` and set `startedAt` to the current ISO 8601 timestamp.
3. Read prior agents' `summary` and `status` fields to understand the current pipeline state.

### During Work

- **Append to `issues[]`** when you find a problem. Assign a sequential ID (`ISS-NNN`) continuing from the last existing issue.
- **Append to `decisions[]`** when you make a significant architectural choice. Assign a sequential ID (`DEC-NNN`).
- **Update `validationGates`** if you run a validation gate (XML or build).

### On Completion

1. Update `agentResults["{your-agent-name}"]`:
   - Set `status` to `"completed"` or `"failed"`
   - Set `completedAt` to the current ISO 8601 timestamp
   - Write a brief `summary` (under 200 characters)
   - List any output files in `artifacts[]`
2. Update `updatedAt` to the current timestamp.
3. Write the full manifest back to disk using the `Write` tool.

### File I/O

- **Read** the full file, parse JSON, update in-memory, **write** the complete file back.
- Use the `Write` tool for atomic file writes.
- Do not modify fields owned by other agents' `agentResults` entries (except appending to shared arrays `issues[]` and `decisions[]`).

---

## Path Convention

The manifest path is provided in the agent's invocation prompt (e.g., `"Manifest path: runs/MyConnector-20260413-093211/connector-build-manifest.json"`).

**If no manifest path is provided, skip all manifest operations silently.** This makes manifest support opt-in and non-breaking for interactive use.

---

## Constraints

- Never modify other agents' `agentResults` entries (only your own).
- Keep `summary` fields under 200 characters.
- Always update `updatedAt` when writing the manifest.
- Use sequential IDs for issues and decisions (ISS-001, ISS-002, ...; DEC-001, DEC-002, ...).
