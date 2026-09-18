# Skyline Agent Marketplace

> [!IMPORTANT]
> The Skyline Agent Marketplace, including the DataMiner App Builder, is owned by Skyline Communications NV and its use is governed by the Skyline Agent Marketplace License in the LICENSE file. By installing or using it, you accept that license. You may not redistribute these files or use them to develop or offer a competing marketplace, App Builder, agent, or similar tool. "DataMiner" and "Skyline" are trademarks of Skyline Communications NV.

> [!WARNING]
> The agents in this marketplace are experimental. Their distribution and output may change significantly or become unavailable. Users remain solely responsible for validating and testing generated work before use in production environments.

Skyline Communications' public marketplace for AI agents and reusable skills.

* Version: **0.0.3**
* License: [Skyline Agent Marketplace License](LICENSE)

## Installing

Add this repository as a plugin marketplace in your client, then install an agent. The root marketplace catalogs route each client to the matching agent package under `plugins/<plugin>/<client>/`.

## Included Skills

* `dataminer-api` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-api/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-api/SKILL.md)
* `dataminer-create-new-app` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-create-new-app/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-create-new-app/SKILL.md)
* `dataminer-data-discovery` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-data-discovery/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-data-discovery/SKILL.md)
* `dataminer-debug-issues` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-debug-issues/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-debug-issues/SKILL.md)
* `dataminer-execute-automation-script` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-execute-automation-script/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-execute-automation-script/SKILL.md)
* `dataminer-execute-query` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-execute-query/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-execute-query/SKILL.md)
* `dataminer-frontend` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-frontend/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-frontend/SKILL.md)
* `dataminer-headless-ias` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-headless-ias/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-headless-ias/SKILL.md)
* `dataminer-performing-actions` — see [`plugins/dataminer-app-builder/copilot/skills/dataminer-performing-actions/SKILL.md`](plugins/dataminer-app-builder/copilot/skills/dataminer-performing-actions/SKILL.md)

## Included Agents

* `dataminer-app-builder` — role: orchestrator

## Platform Support

Skills and agents are packaged per client under `plugins/<plugin>/<client>/`; root marketplace catalogs contain routing metadata only.

* GitHub Copilot & Visual Studio Code: `.github/plugin/marketplace.json` routes to `plugins/<plugin>/copilot/`
* Cursor: `.cursor-plugin/marketplace.json` routes to `plugins/<plugin>/cursor/`
* Claude Code: `.claude-plugin/marketplace.json` routes to `plugins/<plugin>/claude/`
* OpenAI Codex: `.agents/plugins/marketplace.json` routes to `plugins/<plugin>/codex/`
