---
name: dataminer-node-recovery
description: 'Author and review DataMiner Node Recovery local/global trigger scripts: typed entry-point contracts, cluster semantics, state and maintenance handling, settings/install boundaries, and multi-node validation.'
argument-hint: 'Describe the Node Recovery task: e.g. "handle a local state change", "handle a global leader event", or "review cluster trigger configuration".'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-15
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-15 | Initial release for Node Recovery local/global contracts, cluster semantics, and validation boundaries. |

# DataMiner Node Recovery scripts

Load `dataminer-automation-core` first, then classify the contract as a local
or global Node Recovery state-change trigger. These are typed entry points, not
normal `Run(IEngine)` scripts. Use `references/node-recovery-contract.md` for
the contract table.

## Exact contract, with an explicit enum gate

The documented shape is:

```csharp
[AutomationEntryPoint(
    AutomationEntryPointType.Types.OnNodeRecoveryLocalStateChange)]
public LocalStateChangeOutput OnNodeRecoveryLocalStateChange(
    IEngine engine,
    LocalStateChangeInput input)
```

and:

```csharp
[AutomationEntryPoint(
    AutomationEntryPointType.Types.OnNodeRecoveryGlobalStateChange)]
public GlobalStateChangeOutput OnNodeRecoveryGlobalStateChange(
    IEngine engine,
    GlobalStateChangeInput input)
```

Before generating either attribute, compile a minimal probe against the
selected Dev Pack and verify the exact enum/type namespace. The plan records a
public-source enum mismatch: **do not hard-code numeric values 14/15, and do
not use reflection as a workaround**. Preserve this uncertainty until the
target package resolves it.

Both methods return an empty serializable output object in the documented
contract. Do not add normal `ExitSuccess`/`ExitFail` calls merely because the
host is Automation.

## Local versus global

| Contract | Execution | Input view | Design requirement |
|----------|-----------|------------|--------------------|
| Local | Runs on every Agent with an updated local view; duplicates and multiple changes are expected. | `LocalNodeId`, dictionaries of `NodeStateInfo` and `NodeStateChange`. | Make actions safe under repeated/conflicting local observations. |
| Global | Runs only on an elected leader; requires at least three nodes and a strict majority. | `LeaderNodeId` and equivalent global state/change dictionaries. | Gate leader-only actions on the supplied view; test leader election/partition behavior. |

Documented state labels are `Healthy`, `Outage`, and `Unknown`; maintenance is
a separate flag. Verify the exact enum/member spelling in the selected package
instead of inventing or hard-coding values.

Local triggers can occur multiple times for one outage, at startup for
`Unknown -> Healthy`, and when maintenance changes. One invocation can contain
multiple changes. Global triggers can run after leader election with a previous
`Unknown` state; only the strict-majority partition has a leader.

## Installation and configuration

- Install the Node Recovery DxM on every Agent with Swarming enabled before
  configuring trigger scripts. The documented runtime gate is DataMiner
  10.6.0/10.6.3 or higher.
- Default script names are `NodeRecovery - Local State Change` and
  `NodeRecovery - Global State Change`.
- Names can be overridden in
  `C:\Program Files\Skyline Communications\DataMiner NodeRecovery\appsettings.custom.json`.
  Keep configuration identical across cluster nodes.
- No Node Recovery-specific SDK template, package, deployment hook, or
  configuration bundle is established by the plan. Use the official generic
  Automation project only if the selected Dev Pack compiles the exact types.

For unreachable Agents, use SLNet messaging through
`engine.GetUserConnection().HandleMessage()`; do not use APIs that only see
reachable elements.

## Safe action design

Validate node IDs, state/maintenance data, and the presence of each expected
change. Prefer idempotent or duplicate-tolerant actions because local
observations can repeat. Idempotency is a plan recommendation, not a
documented Node Recovery retry guarantee. Keep local and global side effects
separate and make leader assumptions explicit.

## Validation boundary

1. Unit-test pure state-to-action logic without claiming cluster execution.
2. Static-check the public class, verified attribute/type names, serializable
   output, settings/name documentation, and absence of numeric enum/reflection
   workarounds.
3. Run a controlled two-or-more-node test for local behavior when available.
4. Run a controlled three-or-more-node majority/leader/outage/partition test
   for global behavior when available.
5. If no approved real cluster/QAOps target exists, report static/build-only
   coverage and the missing environment. The plan identifies no official
   Node Recovery QAOps harness.

## References

- [Node Recovery contract](references/node-recovery-contract.md)
- [Node Recovery trigger scripts](https://aka.dataminer.services/node-recovery-triggers)
- [Node Recovery settings](https://aka.dataminer.services/node-recovery-settings)
- [Installing Node Recovery](https://aka.dataminer.services/node-recovery-installing)
- [Node Recovery states](https://aka.dataminer.services/node-recovery-states)
- [Node Recovery detection](https://aka.dataminer.services/node-recovery-detection)
- [Node Recovery API](https://aka.dataminer.services/node-recovery-api)
- [Node Recovery API types](https://aka.dataminer.services/skyline-data-miner-net-node-recovery)
