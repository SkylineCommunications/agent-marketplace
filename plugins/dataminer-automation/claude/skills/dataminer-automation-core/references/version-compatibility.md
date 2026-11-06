# Automation Version Compatibility

This reference defines how to choose and record the target versions for an Automation task. It does not declare a universal "latest" target. Load `documentation-source-map.md` and select the DataMiner core/web range, Automation Dev Pack, IAS Toolkit, DataMinerSystem Automation package, XML schema, analyzer versions, and official template version that match the task.

## Version-selection contract

Before authoring or changing a script, record:

| Input | Why it matters |
|---|---|
| Minimum and maximum DataMiner version | Controls runtime features, XML elements, API members, permissions, and deployment behavior |
| Automation Dev Pack | Controls the compile-time `IEngine` and Automation assembly surface |
| IAS Toolkit version, when applicable | Controls `InteractiveController` lifecycle APIs and available widgets |
| DataMinerSystem Automation package | Controls typed/bulk `IDms` members and dependency compatibility |
| DMSScript schema package/XSD | Controls XML structure and supported values |
| C# and SecureCoding analyzer versions | Controls build diagnostics and security gates |
| Official template version | Controls generated project, solution, package, and metadata shape |

If a value cannot be derived from the repository or user request, ask instead of silently choosing a newer package.

## Pinned behavior boundaries

| Feature | Version-aware rule |
|---|---|
| `Script.Run(IEngine)` | The Automation C# entry point remains synchronous; it is distinct from IAS controller methods |
| IAS initial dialog | Toolkit `<= 9.0.1`: `controller.Run(initialDialog)`; `9.0.2`–`9.0.11`: prefer `ShowDialog(initialDialog)` because `Run` is obsolete; `>= 10.0.1`: `ShowDialog(initialDialog)` because `Run` is not public |
| `<Interactivity>` | Supported from DataMiner 10.5.9/10.6.0; use `Always` for an operator-facing low-code IAS when the target supports it; omit the element on earlier targets |
| `RunTimeFlags.NoKeyCaching` | Available behavior must be confirmed against the selected target; use only for a documented stale table-key mapping risk |
| `engine.Timeout` | Code-block default is 10 minutes; override only for a bounded, documented operation or UX requirement |
| Credentials Library | Runtime credential retrieval is documented from DataMiner 10.7.0/10.6.10 onward; older targets require a different approved input design |

## Compatibility workflow

1. Read the target project and package references rather than assuming the repository's captured versions apply.
2. Compare the selected target with `documentation-source-map.md` and record any drift.
3. Compile a minimal API probe or the real fixture when an API member is version-sensitive.
4. Validate the DMSScript against the matching pinned XSD and keep XML/C# IDs and project links aligned.
5. Test the chosen host and invocation context separately from compile success.

Official sources:

- [Automation development overview](https://aka.dataminer.services/automation)
- [IAS Toolkit compatibility](https://aka.dataminer.services/interactive-automation-script-toolkit)
- [Interactivity options](https://aka.dataminer.services/interactivity-options)
- [Engine API](https://aka.dataminer.services/skyline-data-miner-automation-i-engine)
- [Adding C# code to an Automation script](https://aka.dataminer.services/adding-c-sharp-code-to-an-automation-script)
