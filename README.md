# DataMiner DevOps Agent

AI orchestrator and portable skills for building custom DataMiner web applications with React, Vite, TypeScript, and DataMiner web services.

* Version: **0.0.1**
* License: MIT

## Installing

Clone or reference this repository. Load individual skills from `skills/` or install the complete **DataMiner DevOps Agent** experience via the plugin manifest for your client.

## Included Skills

* `dataminer-api` — see [`skills/dataminer-api/SKILL.md`](skills/dataminer-api/SKILL.md)
* `dataminer-create-new-app` — see [`skills/dataminer-create-new-app/SKILL.md`](skills/dataminer-create-new-app/SKILL.md)
* `dataminer-data-discovery` — see [`skills/dataminer-data-discovery/SKILL.md`](skills/dataminer-data-discovery/SKILL.md)
* `dataminer-debug-issues` — see [`skills/dataminer-debug-issues/SKILL.md`](skills/dataminer-debug-issues/SKILL.md)
* `dataminer-execute-automation-script` — see [`skills/dataminer-execute-automation-script/SKILL.md`](skills/dataminer-execute-automation-script/SKILL.md)
* `dataminer-execute-query` — see [`skills/dataminer-execute-query/SKILL.md`](skills/dataminer-execute-query/SKILL.md)
* `dataminer-frontend` — see [`skills/dataminer-frontend/SKILL.md`](skills/dataminer-frontend/SKILL.md)
* `dataminer-headless-ias` — see [`skills/dataminer-headless-ias/SKILL.md`](skills/dataminer-headless-ias/SKILL.md)
* `dataminer-performing-actions` — see [`skills/dataminer-performing-actions/SKILL.md`](skills/dataminer-performing-actions/SKILL.md)

## Included Agents

* `dataminer-app-builder` — role: subagent
* `dataminer-devops` — role: orchestrator

## Platform Support

* GitHub Copilot: `agents/` and `skills/` (Agent Skills / Open Agent Plugin compatible)
* Claude Code: `adapters/claude/agents/` and `skills/`
* OpenAI Codex: `adapters/codex/agents/` and `skills/`
* Visual Studio Code: `adapters/vscode/` extension package
* Cursor: `adapters/cursor/` rules and `AGENTS.md`
