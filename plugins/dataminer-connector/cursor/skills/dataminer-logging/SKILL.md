---
name: dataminer-logging
description: Domain-neutral structured agent logging for Connector and Automation pipeline runs. Each agent writes timestamped JSON events to a per-agent log file.
argument-hint: N/A — loaded automatically by agents for logging operations
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-27
  version: 1.2
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.2 | 2026-09-27 | Aligned packaged resource references and execution contracts. |
| 1.1 | 2026-09-16 | Generalized logging fields and examples for Connector and Automation domains. |
| 1.0 | 2026-04-13 | Initial release. Log entry schema, run summary schema, and logging protocol. |

## Overview

Each agent writes a structured JSON log to `logs/{agent-name}.log.json` within the pipeline run directory. The log is a JSON array of event entries, appended over the agent's lifetime. A run-level summary (`logs/run-summary.json`) is written by the orchestrator or `run-pipeline` CLI after all agents complete.

---

## Log Entry Schema

Each log file is a JSON array of entry objects:

```json
[
  {
    "timestamp": "2026-04-13T09:37:50Z",
    "level": "info",
    "agent": "validator",
    "domain": "connector",
    "artifactType": "classic-connector",
    "phase": "VALIDATE",
    "event": "agent_start",
    "message": "Starting validation of connector solution",
    "data": null
  },
  {
    "timestamp": "2026-04-13T09:37:52Z",
    "level": "info",
    "agent": "validator",
    "phase": "VALIDATE",
    "event": "tool_call",
    "message": "Running dataminer-validator CLI",
    "data": { "tool": "Bash", "command": "dataminer-validator validate protocol-solution ..." }
  },
  {
    "timestamp": "2026-04-13T09:38:00Z",
    "level": "error",
    "agent": "validator",
    "phase": "VALIDATE",
    "event": "issue_found",
    "message": "Parameter 100 missing trending attribute",
    "data": { "issueId": "ISS-001", "severity": "error", "code": "2.5.1" }
  },
  {
    "timestamp": "2026-04-13T09:38:05Z",
    "level": "info",
    "agent": "validator",
    "phase": "VALIDATE",
    "event": "agent_complete",
    "message": "Validation completed with 1 error",
    "data": { "status": "failed", "durationMs": 15000, "errors": 1, "warnings": 0 }
  }
]
```

### Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | ISO 8601 | When the event occurred |
| `level` | string | `debug`, `info`, `warn`, `error` |
| `agent` | string | Agent name (e.g. `validator`, `xml-author`, `automation-author`) |
| `domain` | string | `connector` or `automation` |
| `artifactType` | string | Artifact kind associated with the event |
| `phase` | string | Current workflow phase (e.g. `IMPLEMENT`, `VALIDATE`) |
| `event` | string | Structured event type (see below) |
| `message` | string | Human-readable description (under 500 chars) |
| `data` | object? | Optional structured data for the event |

### Event Types

| Event | When to Log | Typical Data |
|-------|-------------|--------------|
| `agent_start` | Agent begins work | `null` |
| `agent_complete` | Agent finishes | `{ status, durationMs, errors, warnings }` |
| `tool_call` | Significant tool invocation | `{ tool, command or filePath }` |
| `validation_gate` | XML or build gate result | `{ gate, passed, attempts, errors }` |
| `issue_found` | Problem discovered | `{ issueId, severity, code }` |
| `decision_made` | Architectural choice | `{ decisionId, description }` |
| `handoff` | Delegating to another agent | `{ targetAgent, reason }` |
| `error` | Unexpected failure | `{ errorMessage, stackTrace? }` |

---

## Run Summary Schema

Written to `logs/run-summary.json` after all agents complete:

```json
{
  "runId": "ExampleVendor_ExampleDevice-20260413-093211",
  "startedAt": "2026-04-13T09:32:11Z",
  "completedAt": "2026-04-13T09:45:30Z",
  "totalDurationMs": 799000,
  "agents": [
    { "name": "scaffolder",    "status": "completed", "durationMs": 90000,  "logFile": "logs/scaffolder.log.json" },
    { "name": "xml-author",    "status": "completed", "durationMs": 142000, "logFile": "logs/xml-author.log.json" },
    { "name": "validator",     "status": "failed",    "durationMs": 15000,  "logFile": "logs/validator.log.json" }
  ],
  "issueCount": { "critical": 0, "major": 0, "minor": 1, "warning": 2 },
  "gateResults": {
    "xml":   { "passed": true,  "attempts": 1 },
    "build": { "passed": true,  "attempts": 2 }
  },
  "finalStatus": "failed"
}
```

---

## Logging Protocol

For REVIEW, INVESTIGATION, and report-only validation, first apply
`dataminer-manifest/references/read-only-assessment.md`. Its external-only coordination boundary
takes precedence over these file-write steps. Do not write a log inside the reviewed repository.

### On Startup

1. Create the log file at `{logDir}/{agent-name}.log.json` with an initial array containing one `agent_start` entry.
2. If the file already exists (retry scenario), read the existing array and append to it.

### During Work

Log entries for these key events:
- **Tool calls** — significant tool invocations (file writes, CLI commands). Do not log every `Read` or `Grep` — only tool calls that change state or produce important results.
- **Validation gates** — XML and build gate results with pass/fail and attempt count.
- **Issues found** — any problems discovered, with severity.
- **Decisions made** — architectural choices that affect the connector.
- **Handoffs** — when delegating to another agent.
- **Errors** — unexpected failures with error messages.

### On Completion

Write a final `agent_complete` entry with:
- `status`: `"completed"` or `"failed"`
- `durationMs`: elapsed time since `agent_start`
- `errors`: count of error-level issues found
- `warnings`: count of warning-level issues found

### File I/O

- **Read** the existing array, **append** new entries, **write** the full array back.
- Use the `Write` tool for file writes.
- Each write replaces the entire file (append by reading, adding to the array, and writing back).

---

## Path Convention

The log directory path is provided in the agent's invocation prompt (e.g., `"Log directory: runs/MyConnector-20260413-093211/logs/"`).

**If no log directory is provided, skip all logging operations silently.** This makes structured logging opt-in and non-breaking for interactive use.

---

## Constraints

- Log entries are append-only — never remove existing entries.
- Keep individual `message` fields under 500 characters.
- Do not log full file contents — only file paths and summaries.
- Include `domain` and `artifactType` on new events; do not emit connector-only identifiers in Automation logs.
- The `data` field must be a valid JSON object (no circular references).
- Only log significant events — not every tool call or file read.
