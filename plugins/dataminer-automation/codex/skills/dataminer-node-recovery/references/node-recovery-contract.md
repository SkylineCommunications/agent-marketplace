# Node Recovery contract

> Parent skill: `dataminer-node-recovery/SKILL.md`.

## Entry-point matrix

| Contract | Documented entry point | Input | Output | Runtime |
|----------|------------------------|-------|--------|---------|
| Local | `OnNodeRecoveryLocalStateChange` with the documented `OnNodeRecoveryLocalStateChange` trigger type | `IEngine`, `LocalStateChangeInput`; includes `LocalNodeId`, `NodeStateInfo` dictionary, and `NodeStateChange` dictionary. | `LocalStateChangeOutput` (empty serializable output type). | Every Agent with its updated local view; duplicates and multiple changes are expected. |
| Global | `OnNodeRecoveryGlobalStateChange` with the documented `OnNodeRecoveryGlobalStateChange` trigger type | `IEngine`, `GlobalStateChangeInput`; includes `LeaderNodeId` and equivalent global dictionaries. | `GlobalStateChangeOutput` (empty serializable output type). | Elected leader only; requires at least three Agents and a strict majority. |

The trigger documentation shows the attributes under
`AutomationEntryPointType.Types`. A public source snapshot exposes the values
under another Automation entry-point enum. This is an unresolved
version/source mismatch. Verify the selected Dev Pack and source version with
a compile probe. Never hard-code 14/15 and never use reflection to bypass the
uncertainty.

## State and trigger semantics

The documented state labels are `Healthy`, `Outage`, and `Unknown`;
maintenance is a separate flag. Verify the selected package's type/member
names before coding.

| Situation | Local | Global |
|-----------|-------|--------|
| Normal view | Updated local state/change dictionaries. | Updated global dictionaries plus leader ID. |
| Startup | May report `Unknown -> Healthy`. | May run after leader election with previous `Unknown`. |
| Outage | Multiple invocations for one outage are possible. | Only the strict-majority partition has a leader. |
| Maintenance | A maintenance change can trigger local execution. | Handle only from the global view supplied by the contract. |
| One invocation | Can contain multiple state changes. | Use the supplied global set; do not assume one change. |

The official contract does not establish a retry, exactly-once, or
serialization guarantee. Design duplicate-tolerant actions, but label
idempotency as an implementation recommendation rather than a platform
promise.

## Names, settings, and installation

| Setting | Documented value |
|---------|------------------|
| Local default script | `NodeRecovery - Local State Change` |
| Global default script | `NodeRecovery - Global State Change` |
| Override file | `C:\Program Files\Skyline Communications\DataMiner NodeRecovery\appsettings.custom.json` |
| Configuration | Keep the settings identical across cluster nodes. |
| Installation | Install the Node Recovery DxM on every Agent with Swarming enabled before configuring trigger scripts. |
| Runtime gate | DataMiner 10.6.0/10.6.3 or higher is the documented gate. |

The plan does not establish a Node Recovery-specific SDK template, package,
deployment hook, or repository configuration bundle. Use the generic official
Automation project only when the selected Dev Pack compiles the exact
Node Recovery types.

## Data access and action review

For unreachable Agents, use SLNet messaging through
`engine.GetUserConnection().HandleMessage()` rather than APIs that only expose
reachable elements. Review every action for:

- node ID/state/maintenance validation;
- local duplicate/conflict safety;
- explicit leader/majority assumptions for global actions;
- no dependence on an undocumented retry or execution order;
- side effects that are safe if a local trigger runs again.

## Validation levels

| Level | Evidence | Limitation |
|-------|----------|------------|
| Pure logic unit test | State/change mapping and duplicate-safe decisions. | Does not prove Node Recovery invocation or cluster view. |
| Static/build check | Exact types/attribute after Dev Pack probe, serializable output, configured names/settings, no numeric enum workaround. | Does not prove installation, leader election, or outage detection. |
| Local runtime | Controlled two-or-more-node test with outage/startup/maintenance changes. | Requires a real compatible cluster. |
| Global runtime | Controlled three-or-more-node majority, leader-election, outage/partition test. | Requires a real compatible cluster; no official harness is identified. |

If the real cluster is unavailable, ship only the static/pure-logic evidence
approved by the plan and report the runtime gap visibly.

## Official sources

- [Node Recovery trigger scripts](https://aka.dataminer.services/node-recovery-triggers)
- [Node Recovery settings](https://aka.dataminer.services/node-recovery-settings)
- [Installing Node Recovery](https://aka.dataminer.services/node-recovery-installing)
- [Node Recovery states](https://aka.dataminer.services/node-recovery-states)
- [Node Recovery detection](https://aka.dataminer.services/node-recovery-detection)
- [Node Recovery API](https://aka.dataminer.services/node-recovery-api)
- [Node Recovery API types](https://aka.dataminer.services/skyline-data-miner-net-node-recovery)
