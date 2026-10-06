---
name: dataminer-nugets
description: Skyline DataMiner NuGet package selection and API references for Connector and Automation projects, including Dev Packs, IAS, DataMinerSystem, InterAppCalls, Protocol.Extension, Rates, and SecureCoding.
argument-hint: 'Describe the package task: e.g. "calculate SNMP bitrates", "add InterApp calls", "use SLProtocol extension wrappers"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 1.4
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-interactive-automation`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-interactive-automation`: IAS package branch only; the Automation plugin already supplies it for interactive tasks.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.4 | 2026-09-16 | Added explicit Automation package routing and connector/Automation boundary rules. |
| 1.3 | 2026-09-14 | Clarified Dev.Protocol base APIs versus generated helper and Protocol.Extension surfaces. |
| 1.2 | 2026-09-11 | Added the SecureCoding runtime/analyzer distinction and secure Newtonsoft deserialization reference. |
| 1.1 | 2026-05-14 | Expanded InterApp reference into a full lifecycle guide from NuGet and connector setup through message API, executors, receiver, sender, replies, broker behavior, known types, and validation pitfalls. |
| 1.0 | 2026-05-14 | Initial NuGet package selection skill with dedicated references for Dev.Protocol, InterAppCalls.Common, Protocol.Extension, Rates.Protocol, and Rates.Common. |

# DataMiner NuGet Package Selection

Load this skill before adding package references or writing custom helper code for connector QActions, connector API libraries, or related DataMiner C# projects.

## Package Rules

- Use official Skyline NuGets when they exist; they are mandatory over custom helper code for covered package scenarios.
- Use `PackageReference` only. Do not use `packages.config`.
- Do not copy DataMiner DLLs from a local DataMiner installation when a Dev Pack exists.
- Keep package versions aligned with the connector target DataMiner version and the package minimum DataMiner version.
- After package changes, run `dotnet restore` and `dotnet build` for the affected solution or projects.
- For SDK-style project creation, packaging, Catalog upload, deployment, validator, and Dev Pack selection policy, load `dataminer-sdk` as the authority.

## Quick Package Selection

| Task or Keyword | Package | Reference |
|-----------------|---------|-----------|
| Compile connector QActions, access `SLProtocol`, use DataMiner scripting APIs without manual DLL references | `Skyline.DataMiner.Dev.Protocol` | `references/skyline-dataminer-dev-protocol.md` |
| Compile Automation scripts and access `IEngine` | `Skyline.DataMiner.Dev.Automation` | Load `dataminer-sdk` and the Automation template reference |
| Build an Interactive Automation Script UI | `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` | Load `dataminer-interactive-automation` |
| Typed/bulk Automation element and table access | `Skyline.DataMiner.Core.DataMinerSystem.Automation` | Load `dataminer-idms` |
| InterApp full lifecycle, element-to-element messaging, automation-to-element calls, command/response messages, connector API messages | `Skyline.DataMiner.Core.InterAppCalls.Common` | `references/skyline-dataminer-core-interappcalls-common.md` |
| High-level `SLProtocol` wrappers, bulk `SetParameters`, `SetColumns`, `GetColumns`, `SetCell`, `DeleteRows`, `RunAction` | `Skyline.DataMiner.Utils.Protocol.Extension` | `references/skyline-dataminer-utils-protocol-extension.md` |
| SNMP-polled counters, SNMP bitrate, SNMP counter deltas, timeout delta buffering, table row rate calculations | `Skyline.DataMiner.Utils.Rates.Protocol` | `references/skyline-dataminer-utils-rates-protocol.md` |
| Custom/non-SNMP counters, HTTP/serial counters, explicit `DateTime` or `TimeSpan` timing, reusable non-protocol rate logic | `Skyline.DataMiner.Utils.Rates.Common` | `references/skyline-dataminer-utils-rates-common.md` |
| Untrusted JSON deserialization, `SLC_SC0004`, secure Newtonsoft settings, certificate callback analyzer guidance | `Skyline.DataMiner.Utils.SecureCoding` + `.Analyzers` | `references/skyline-dataminer-utils-securecoding.md` |

## Package Relationships

| Package | Relationship |
|---------|--------------|
| `Skyline.DataMiner.Dev.Protocol` | Dev Pack for connector projects. Other connector utility packages often depend on it. |
| `Skyline.DataMiner.Dev.Automation` | Dev Pack for Automation projects; it is not a replacement for `Dev.Protocol` in connector QActions. |
| `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` | IAS runtime UI package; its C# namespace is `Skyline.DataMiner.Utils.InteractiveAutomationScript`. |
| `Skyline.DataMiner.Core.DataMinerSystem.Automation` | Typed/bulk Automation DataMinerSystem API; add it only when the Automation task requires it. |
| `Skyline.DataMiner.Core.InterAppCalls.Common` | Standard package, not a Dev Pack. Include where message DTOs, executors, receiver logic, or sender logic are compiled. |
| `Skyline.DataMiner.Utils.Protocol.Extension` | Depends on `Skyline.DataMiner.Dev.Protocol`. Use from QAction projects when its wrappers simplify bulk SLProtocol calls. |
| `Skyline.DataMiner.Utils.Rates.Protocol` | Depends on `Skyline.DataMiner.Utils.Rates.Common`, `Skyline.DataMiner.Utils.SNMP`, `Skyline.DataMiner.Dev.Protocol`, and `Newtonsoft.Json`. Use for SNMP counters in connectors. |
| `Skyline.DataMiner.Utils.Rates.Common` | Used directly for non-SNMP counters or pulled transitively by `Rates.Protocol`. |
| `Skyline.DataMiner.Utils.SecureCoding` | Runtime security helpers, including `SecureNewtonsoftDeserialization`. |
| `Skyline.DataMiner.Utils.SecureCoding.Analyzers` | Build-time diagnostics such as `SLC_SC0004` and `SLC_SC0005`; it does not contain the runtime helper API. |

## Decision Notes

- For SNMP counters retrieved by DataMiner SNMP polling, prefer `Rates.Protocol` because it integrates with `SnmpDeltaHelper`.
- For counters retrieved through HTTP, serial, WebSocket, custom code, or an external timing source, prefer `Rates.Common`.
- For DataMiner API compilation in QAction projects, prefer `Dev.Protocol`; do not reference `Skyline.DataMiner.Files.*` packages directly unless the Dev Pack documentation explicitly requires a specific file package.
- For Automation scripts, prefer `Dev.Automation`; do not copy connector-only `SLProtocol`, QAction, or `protocol.xml` package assumptions into the script project.
- For wrapper methods that replace raw `NotifyProtocol` calls, prefer `Protocol.Extension` only when the wrapper improves readability or batching; do not add it for a single ordinary `GetParameter` or `SetParameter`.
- For InterApp, follow the full lifecycle reference: add receiver/return parameters, keep message DTO classes data-only, keep execution logic in executor classes, keep known types equivalent, and use valid reply/return-address handling.
- For Newtonsoft JSON deserialization, add the SecureCoding runtime package and call `SecureNewtonsoftDeserialization`; retaining only the analyzer package is insufficient.

## Verification

Use the narrowest applicable verification after adding or changing package usage:

```bash
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>"
```

For connector changes, also run the official validator through the `dataminer-validation` and `dataminer-sdk` guidance before final handoff.
