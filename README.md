# DataMiner DevOps Agent

> [!IMPORTANT]
> The DataMiner App Builder is owned by Skyline Communications NV and its use is governed by the DataMiner App Builder License in the LICENSE file. By installing or using it, you accept that license. You may not redistribute these files or use them to develop or offer a competing App Builder, agent or similar tool. "DataMiner" and "Skyline" are trademarks of Skyline Communications NV.

> [!WARNING]
> This experimental agent, its distribution, and its output may change significantly or become unavailable. Apps may need to be rebuilt after updates. App creators remain solely responsible for validating and testing every app before use; the DataMiner App Builder cannot be held responsible for failures in production environments.

AI orchestrator and portable skills for building custom DataMiner web applications with React, Vite, TypeScript, and DataMiner web services.

* Version: **0.0.2**
* License: [DataMiner App Builder License](LICENSE)

## Installing

Add this repository as a plugin marketplace in your client, then install **DataMiner DevOps Agent**. The root marketplace catalogs route each client to its matching package under `adapters/`. For local development, register the matching adapter directory directly.

## Included Skills

* `dataminer-api` — see [`adapters/copilot/skills/dataminer-api/SKILL.md`](adapters/copilot/skills/dataminer-api/SKILL.md)
* `dataminer-create-new-app` — see [`adapters/copilot/skills/dataminer-create-new-app/SKILL.md`](adapters/copilot/skills/dataminer-create-new-app/SKILL.md)
* `dataminer-data-discovery` — see [`adapters/copilot/skills/dataminer-data-discovery/SKILL.md`](adapters/copilot/skills/dataminer-data-discovery/SKILL.md)
* `dataminer-debug-issues` — see [`adapters/copilot/skills/dataminer-debug-issues/SKILL.md`](adapters/copilot/skills/dataminer-debug-issues/SKILL.md)
* `dataminer-execute-automation-script` — see [`adapters/copilot/skills/dataminer-execute-automation-script/SKILL.md`](adapters/copilot/skills/dataminer-execute-automation-script/SKILL.md)
* `dataminer-execute-query` — see [`adapters/copilot/skills/dataminer-execute-query/SKILL.md`](adapters/copilot/skills/dataminer-execute-query/SKILL.md)
* `dataminer-frontend` — see [`adapters/copilot/skills/dataminer-frontend/SKILL.md`](adapters/copilot/skills/dataminer-frontend/SKILL.md)
* `dataminer-headless-ias` — see [`adapters/copilot/skills/dataminer-headless-ias/SKILL.md`](adapters/copilot/skills/dataminer-headless-ias/SKILL.md)
* `dataminer-performing-actions` — see [`adapters/copilot/skills/dataminer-performing-actions/SKILL.md`](adapters/copilot/skills/dataminer-performing-actions/SKILL.md)

## Included Agents

* `dataminer-app-builder` — role: subagent
* `dataminer-devops` — role: orchestrator

## Platform Support

Skills and agents are packaged per IDE under `adapters/`; root marketplace catalogs contain routing metadata only.

* GitHub Copilot & Visual Studio Code: `.github/plugin/marketplace.json` routes to `adapters/copilot/`
* Cursor: `.cursor-plugin/marketplace.json` routes to `adapters/cursor/`
* Claude Code: `.claude-plugin/marketplace.json` routes to `adapters/claude/`
* OpenAI Codex: `.agents/plugins/marketplace.json` routes to `adapters/codex/`
