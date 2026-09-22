# Skyline Agent Marketplace

> [!IMPORTANT]
> The Skyline Agent Marketplace, including the DataMiner App Builder, is owned by Skyline Communications NV and its use is governed by [Skyline Agent Marketplace License](LICENSE). By installing or using it, you accept that license.



Skyline Communications' public marketplace for AI agents and reusable skills.

- **Version:** `0.0.4`
- **Marketplace name:** `skyline-agent-marketplace`
- **Repository:** `SkylineCommunications/agent-marketplace`
- **Marketplace source:** `https://github.com/SkylineCommunications/agent-marketplace.git`

> [!WARNING]
> The agents in this marketplace are experimental. Their distribution and output may change significantly or become unavailable. Users remain solely responsible for validating and testing generated work before use in production environments.

## Plugins

| Plugin | Agents | Skills |
| --- | --- | --- |
| [`dataminer-app-builder`](plugins/dataminer-app-builder) | `dataminer-app-builder` | `dataminer-create-new-app`<br>`dataminer-e2e-testing`<br>`dataminer-frontend`<br>`dataminer-api`<br>`dataminer-data-discovery`<br>`dataminer-execute-query`<br>`dataminer-execute-automation-script`<br>`dataminer-performing-actions`<br>`dataminer-headless-ias`<br>`dataminer-debug-issues` |

Each plugin is independently installable. The **Agents** and **Skills** columns are generated from the publication manifest and show the complete plugin closure published in this marketplace.

## Install and manage plugins

Use the official client documentation for the current installation, marketplace, trust, update, and uninstall instructions. Client commands and UI flows can change independently of this repository.

The marketplace source is:

```text
https://github.com/SkylineCommunications/agent-marketplace.git
```

The marketplace registration name is `skyline-agent-marketplace`. Installable plugin names are listed in the table above.

### Official installation references

| Client | Official installation and management reference |
| --- | --- |
| GitHub Copilot CLI | [Finding and installing plugins](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-finding-installing) |
| VS Code with GitHub Copilot | [Agent plugins](https://code.visualstudio.com/learn/agents/3-agent-plugins) |
| Claude Code | [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) |
| Cursor | [Customize Cursor](https://cursor.com/docs/customize-cursor) and [plugins reference](https://cursor.com/docs/reference/plugins) |
| OpenAI Codex | [Package and manage plugins](https://developers.openai.com/plugins/build/plugins) |

## Find installed plugins in Windows Explorer

The locations below are client-managed. A client may use a cache, a user-level directory, a project directory, or an IDE-managed location. Use the linked official documentation and the client UI as the source of truth if a path differs.

| Client | Windows Explorer location or management note | Official reference |
| --- | --- | --- |
| GitHub Copilot CLI | `%USERPROFILE%\.copilot\installed-plugins\` | [Copilot CLI configuration directory](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference) |
| VS Code with GitHub Copilot | Plugins installed through Copilot CLI are shared from `%USERPROFILE%\.copilot\installed-plugins\`; direct VS Code plugin locations are managed by the IDE | [Agent plugins](https://code.visualstudio.com/learn/agents/3-agent-plugins) |
| Claude Code | User configuration and plugins: `%USERPROFILE%\.claude\`; project plugins: `<project>\.claude\` | [Explore the `.claude` directory](https://code.claude.com/docs/en/claude-directory) |
| Cursor | No single fixed Windows Explorer location is promised by the official docs; use Cursor **Customize** to manage user, workspace, and team plugins | [Customize Cursor](https://cursor.com/docs/customize-cursor) |
| OpenAI Codex | Personal marketplace catalog: `%USERPROFILE%\.agents\plugins\marketplace.json`; personal plugin source examples: `%USERPROFILE%\.codex\plugins\` | [Codex plugins](https://developers.openai.com/plugins/build/plugins) |

## Package format and repository layout

This repository uses the [Agent Plugins 1.0](https://agent-plugins.org/) format. The root marketplace catalogs route each supported client to its plugin package:

```text
.github/plugin/marketplace.json       GitHub Copilot and VS Code
.claude-plugin/marketplace.json       Claude Code
.cursor-plugin/marketplace.json       Cursor
.agents/plugins/marketplace.json      OpenAI Codex
plugins/<plugin>/<client>/            Client-specific plugin package
```

Review `plugin.json`, skills, agents, hooks, and MCP configuration before installing a plugin. Plugins may contain executable scripts or integrations that run with client permissions.

## Official references

- [Agent Plugins specification](https://agent-plugins.org/)
- [GitHub Copilot plugins](https://docs.github.com/en/copilot/concepts/agents/about-plugins)
- [VS Code Agent Plugins](https://code.visualstudio.com/learn/agents/3-agent-plugins)
- [Claude Code plugins](https://code.claude.com/docs/en/discover-plugins)
- [Cursor plugins](https://cursor.com/docs/reference/plugins)
- [OpenAI Codex plugins](https://developers.openai.com/plugins/build/plugins)
