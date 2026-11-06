# Automation Documentation Source Map

This file records the immutable upstream baseline used to maintain the Automation agent and skill ecosystem. It is maintenance metadata, not a replacement for the task-specific version decision.

Captured on 2026-09-11 against consumer repository revision `9038033cb7df40c1c063b3f02c9a0fda05453103`.

## Source-selection policy

- Ask for the target DataMiner core, web, Dev Pack, and IAS Toolkit versions for every implementation task.
- Do not treat the latest observed package as the automatic implementation target.
- Use the exact target package API where behavior differs by version.
- Keep new authoring SDK-first. Review and investigation must remain compatible with maintained legacy Cube-inline scripts.
- Treat public schema and package API/compile output as normative for structure and available members. Treat conceptual pages as behavioral authority unless reviewed package evidence proves that a page is version-lagged.
- Record unresolved disagreements. Do not silently select one conflicting example as universal behavior.

## Pinned upstream baseline

### Documentation corpus

- Repository: <https://github.com/SkylineCommunications/dataminer-docs>
- Revision: `103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c`
- Immutable source root: <https://github.com/SkylineCommunications/dataminer-docs/tree/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c>
- Published site: <https://aka.dataminer.services/1148BLexz>
- Build package declarations: [`src/NuGetPackages/NuGetPackages.csproj`](https://github.com/SkylineCommunications/dataminer-docs/blob/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c/src/NuGetPackages/NuGetPackages.csproj)

Use the immutable source revision for reproducible maintenance. Use the published site to verify the deployed result and redirects.

### Automation XML schema

- Package: `Skyline.DataMiner.XmlSchemas.Automation` 1.1.10
- Package: <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.xmlschemas.automation/1.1.10/skyline.dataminer.xmlschemas.automation.1.1.10.nupkg>
- Package SHA-256: `c164064bdfe6a99c8f13fd9563106d30715c6496da9b137ac0176aeef387826f`
- Schema path: `content/Skyline/XSD/automation.xsd`
- Schema SHA-256: `b7c17c970dd5847ed9f4bd33e08c0e7c8acf546094a38a14a35fabaea2d461ea`
- Source repository: <https://github.com/SkylineCommunications/Skyline.DataMiner.XmlSchemas>
- Package source commit: `d7b5c9ac6865f3e56804bf95e536d460b5e50e36`

This pin is the current closed-world structural baseline implemented by `dataminer-automation-xml` and its `references/dmsscript-reference.md` contract, reviewed on 2026-09-14. The exact vendored validation copy is `skills/dataminer-automation-xml/references/automation-1.1.10.xsd`; its package version, package/XSD hashes, source path, and source commit must move together when the baseline changes.

### Official project templates

- Package: `Skyline.DataMiner.VisualStudioTemplates` 2.8.14
- Package: <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.visualstudiotemplates/2.8.14/skyline.dataminer.visualstudiotemplates.2.8.14.nupkg>
- Package SHA-256: `fff84ca90810755d01f4c2a9e2f63ff21b65544cea7851054e7535813460b2a6`
- Source repository: <https://github.com/SkylineCommunications/Skyline.DataMiner.VisualStudioTemplates>
- Package source commit: `86c5f0383ad93e3eb7a6a037469b1aff18f84969`
- Relevant templates:
  - `content/templates/automation-project/.template_config/template.json`
  - `content/templates/automation-library-project/.template_config/template.json`

Template output must be observed by scaffolding into a temporary directory. Do not infer current output solely from the static local template reference.

### Target-specific Automation packages

| Role | Package and captured version | SHA-256 | Selection rule |
|---|---|---|---|
| Automation Dev Pack, locally shown example | `Skyline.DataMiner.Dev.Automation` 10.4.0.24 | `3341b712831e05543cef7ad09b527afc5e7dd65185258a77a6979394e6ff64e1` | This is the version currently shown in `dataminer-sdk/references/automation-template-reference.md`, not a universal target. |
| Automation Dev Pack, observed latest stable | `Skyline.DataMiner.Dev.Automation` 10.6.9.1 | `079268dc5d23e3f735c3649ad57d9e705f550634f6a16198465260f80b9ff6d8` | Select a compatible version from the task's requested DataMiner target. |
| IAS Toolkit used by the docs API build | `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` 10.6.3.6 | `3598b2f815dd66ed5f4ad8ee6cdf08cc7ba2dc15589694cbec92b69f08a68fb7` | Use the requested Toolkit line and its actual API; do not assume this captured version. |
| DataMinerSystem Automation API used by the docs build | `Skyline.DataMiner.Core.DataMinerSystem.Automation` 1.2.0.3 | `be15ff5b482dcd129bacddf034e55947916f3227ccc475429334e91bdb116708` | Match the selected Dev Pack and solution dependency graph. |
| C# analysis | `Skyline.DataMiner.CICD.CSharpAnalysis.Analyzer` 2.1.2 | `2d23bca16c8f91b40019620f4a4ea731c7a1edad757d2753145e1c1cb1a4452f` | Verify the version emitted by the selected template. |
| Secure coding analysis | `Skyline.DataMiner.Utils.SecureCoding.Analyzers` 2.2.3 | `54a960045d1871ce54c7a21c2aa044d343ad6a58389777cfc731d5739e211b62` | Verify the version emitted by the selected template. |

Exact package URLs:

- <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.dev.automation/10.4.0.24/skyline.dataminer.dev.automation.10.4.0.24.nupkg>
- <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.dev.automation/10.6.9.1/skyline.dataminer.dev.automation.10.6.9.1.nupkg>
- <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.interactiveautomationscripttoolkit/10.6.3.6/skyline.dataminer.utils.interactiveautomationscripttoolkit.10.6.3.6.nupkg>
- <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.core.dataminersystem.automation/1.2.0.3/skyline.dataminer.core.dataminersystem.automation.1.2.0.3.nupkg>
- <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.cicd.csharpanalysis.analyzer/2.1.2/skyline.dataminer.cicd.csharpanalysis.analyzer.2.1.2.nupkg>
- <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.securecoding.analyzers/2.2.3/skyline.dataminer.utils.securecoding.analyzers.2.2.3.nupkg>

## Reviewed Automation runtime and public API provenance

Reviewed on **2026-09-14** against the pinned documentation revision and signed packages below. These pins make the runtime/API guidance reproducible; they do not replace task-specific target-version selection.

### Runtime, logging, and error sources

- [`Handling_Async_Code.md` at revision `103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c`](https://github.com/SkylineCommunications/dataminer-docs/blob/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c/develop/devguide/Automation/Best_Practices/Handling_Async_Code.md) establishes the Automation single-thread rule: keep Engine interaction on the script's original execution thread. Local guidance consequently says do not use async Automation entry points, `async void`, `Task.Run`, parallel loops, manually started threads, or cross-thread use of Engine-derived/DataMiner objects. External async-only libraries may be synchronously consumed only with detached plain inputs/outputs.
- [`Automation_best_practices_information_events.md` at the same revision](https://github.com/SkylineCommunications/dataminer-docs/blob/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c/develop/devguide/Automation/Best_Practices/Automation_best_practices_information_events.md) limits information events to meaningful end-user audit events and recommends sparse logging. Local guidance therefore forbids `GenerateInformation` for tracing, progress, routine results, counts/missing keys, per-item loops, exception details, or secrets.
- [`How_to_make_your_automation_scripts_debug_ready.md` at the same revision](https://github.com/SkylineCommunications/dataminer-docs/blob/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c/develop/devguide/Automation/Howto/How_to_make_your_automation_scripts_debug_ready.md) supports logging full diagnostics with `Log(ex.ToString())`. Its sample forwards `ex.Message` to `ExitFail`; that sample is **superseded locally** by the approved stable-message contract: log `"Run|Unexpected exception: " + ex.ToString()` and call `ExitFail("Runtime operation failed.")` without exposing exception detail.

### Signed package and assembly evidence

| Artifact | Version/path | SHA-256 |
|---|---|---|
| Automation Dev Pack `.nupkg` | `Skyline.DataMiner.Dev.Automation` 10.6.9.1 | `079268dc5d23e3f735c3649ad57d9e705f550634f6a16198465260f80b9ff6d8` |
| Managed Automation dependency `.nupkg` | `Skyline.DataMiner.Files.SLManagedAutomation` 10.6.9.1 | `9435585db7b4876807aab6f05910d9788401270919612abde4a3834ae515b134` |
| Managed Automation assembly | `lib/net462/SLManagedAutomation.dll` | `9ed4257ca5300af1348d4a8e8ad2347e3010844e4ac167129295d51971950416` |
| Managed Automation XML documentation | `lib/net462/SLManagedAutomation.xml` | `05087aa6fa5d496e9f1d66c5cf038a86ffa75685a8f5335bd4bbe7f3f15d99ca` |

Dependency package: <https://api.nuget.org/v3-flatcontainer/skyline.dataminer.files.slmanagedautomation/10.6.9.1/skyline.dataminer.files.slmanagedautomation.10.6.9.1.nupkg>

### Verified `IEngine` public API facts

| Status | Verified members |
|---|---|
| Present | `GetScriptParam(int)`, `GetScriptParam(string)`, `GetMemory(int)`, `GetMemory(string)`, `GenerateInformation(string)`, `Log(string)` and documented overloads, `ExitFail(string)`, `ExitSuccess(string)`, `ShowUI(UIBuilder)`, `ShowUI(string)`, `ShowUI(string, bool)`, `SendSLNetMessage(DMSMessage)`, `FindElement`, `FindElementByKey`, `FindElementsByProtocol`, `GetDummy`, `PrepareSubScript` |
| Absent | `GetScriptParamValue<T>`, `SendMessage(DMSMessage)`, parameterless `ShowUI()` |

`SendSLNetMessage(DMSMessage)` is public raw SLNet access but is version-fragile. Prefer a typed API whenever one exists and verify the exact target-version message contract when raw messaging is unavoidable.

## Reviewed IAS Toolkit lifecycle provenance

Reviewed on **2026-09-14**. The NuGet packages declare repository URL <https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit>. Each SHA-256 below is for the linked signed `.nupkg` downloaded from the NuGet flat container.

| Reviewed | Toolkit version | Signed flat-container package | SHA-256 | Nuspec repository commit | Framework/dependency observation | Public API and compile observation |
|---|---|---|---|---|---|---|
| 2026-09-14 | `9.0.1` | [9.0.1 `.nupkg`](https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.interactiveautomationscripttoolkit/9.0.1/skyline.dataminer.utils.interactiveautomationscripttoolkit.9.0.1.nupkg) | `86b1c3600bc69842e9dba8c5efd65d09b359fb41da339bfca80240c82b1d0a41` | `da1f5693ee5d8109e63035800dec483c40e48236` | `net462`; dependency `Skyline.DataMiner.Dev.Automation` 10.4.7 | `Run` is public and non-obsolete and starts the loop; `ShowDialog` queues or switches dialogs. |
| 2026-09-14 | `9.0.2` | [9.0.2 `.nupkg`](https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.interactiveautomationscripttoolkit/9.0.2/skyline.dataminer.utils.interactiveautomationscripttoolkit.9.0.2.nupkg) | `c01254c7b0c29fe39aa0201c6a7f6c00942f5b2fae4bad6e586f6b2bf72cfc1e` | `d2ef29f1a44625e4d5e7b2e1388d1b283d99f9b6` | — | A `Run` compile probe produces `CS0618`; `ShowDialog` is preferred. |
| 2026-09-14 | `9.0.11` | [9.0.11 `.nupkg`](https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.interactiveautomationscripttoolkit/9.0.11/skyline.dataminer.utils.interactiveautomationscripttoolkit.9.0.11.nupkg) | `4d1c655ce93a55b4b15307b3d74883e6aedfa7d0e5b66a5b3a2e0d9312a684f7` | `e57dc6e95fa3f6f8edbc15419d0bba8633669b68` | — | `Run` still produces `CS0618`; `ShowDialog` is preferred. |
| 2026-09-14 | `10.0.1` | [10.0.1 `.nupkg`](https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.interactiveautomationscripttoolkit/10.0.1/skyline.dataminer.utils.interactiveautomationscripttoolkit.10.0.1.nupkg) | `624e4d35a001b1fc77e0a3bb3bcfdbdf190986d8cde3991b8c30b64744aab811` | `77988139c57f2833f75eca422ee612eb2f82f7d5` | — | A `Run` compile probe produces `CS1061` (no public definition); `ShowDialog` is public. |
| 2026-09-14 | `10.6.3.6` | [10.6.3.6 `.nupkg`](https://api.nuget.org/v3-flatcontainer/skyline.dataminer.utils.interactiveautomationscripttoolkit/10.6.3.6/skyline.dataminer.utils.interactiveautomationscripttoolkit.10.6.3.6.nupkg) | `3598b2f815dd66ed5f4ad8ee6cdf08cc7ba2dc15589694cbec92b69f08a68fb7` | `d93827eb1a608d0ba2d70beb3815eccb636fce8f` | `net48`; dependency `Skyline.DataMiner.Dev.Automation` 10.6.3 | The current fixture compiles `ShowDialog`. |

This evidence resolves the former `Run`-versus-`ShowDialog` conflict by Toolkit version; there is no universal either/or choice. The pinned `dataminer-docs` revision `103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c` still shows `InteractiveController.Run` in its getting-started example. That example is version-lagged: the signed package public API and compile evidence above govern version-specific authoring. Pin/select the Toolkit version first, then use `Run(initialDialog)` for `<= 9.0.1`, preferred `ShowDialog(initialDialog)` for 9.0.2–9.0.11, or `ShowDialog(initialDialog)` for `>= 10.0.1`, where `Run` is no longer public. These controller members are distinct from the Automation entry point `Script.Run(IEngine)`.

Local executable evidence is maintained in `tests/fixtures/dataminer-ias` and run by `scripts/validate-dataminer-ias-fixtures.ps1`.

### Pinned interactivity authority

The [`InteractivityOptions` page at revision `103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c`](https://github.com/SkylineCommunications/dataminer-docs/blob/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c/develop/schemadoc/Automation/InteractivityOptions.md) is the pinned authority for availability and semantics. Explicit `<Interactivity>` is supported from DataMiner 10.5.9/10.6.0: `Never` means no UI, `Optional` means UI only when needed, `Always` means always UI and is preferred for operator-facing low-code IAS, and `Auto` retains legacy string-detection compatibility rather than serving as a universal default. Earlier targets must omit the unsupported element and use legacy automatic detection.

## Canonical topic map

| Topic | Published source | Immutable source or origin | Primary local consumers |
|---|---|---|---|
| Automation development overview | <https://aka.dataminer.services/automation> | `develop/devguide/Automation/index.md`, UID `AutomationDevGuideIndex` | `dataminer-automation-core` |
| DMSScript schema | <https://aka.dataminer.services/schema-automation-script> | `develop/schemadoc/SchemaAutomationScript.md`, UID `SchemaAutomationScript`; Automation schema package above | `dataminer-automation-xml` |
| Engine API | <https://aka.dataminer.services/skyline-data-miner-automation-i-engine> | Generated from `src/DataMiner/SLManagedAutomation/IEngine.cs` and the docs build inputs | `engine-api-overview.md`, `dataminer-automation-scripting` |
| DataMinerSystem Automation API | <https://aka.dataminer.services/skyline-data-miner-core-data-miner-syst-85f222fb> | Generated from package 1.2.0.3 in the captured docs build | `dataminer-idms`, Automation scripting and tests |
| Thread and async safety | <https://aka.dataminer.services/AsyncAutomation> | `develop/devguide/Automation/Best_Practices/Handling_Async_Code.md`, UID `Handling_Async_Code` | Automation author, reviewer, investigator, core |
| Logging and information events | <https://aka.dataminer.services/automation-best-practices-information-events> | `develop/devguide/Automation/Best_Practices/Automation_best_practices_information_events.md`, UID `Automation_best_practices_information_events` | Automation core and scripting |
| Debug-ready exception behavior | <https://aka.dataminer.services/how-to-make-your-automation-scripts-debug-ready> | `develop/devguide/Automation/Howto/How_to_make_your_automation_scripts_debug_ready.md` | Automation author, reviewer, investigator |
| IAS setup and package identity | <https://aka.dataminer.services/1068hoHHP> | `develop/devguide/Automation/Howto/Getting_Started_with_the_IAS_Toolkit.md`, UID `Getting_Started_with_the_IAS_Toolkit` | `dataminer-interactive-automation`, Automation core |
| IAS compatibility table | <https://aka.dataminer.services/interactive-automation-script-toolkit> | `develop/TOOLS/NuGet/Interactive_Automation_Script_Toolkit.md`, UID `Interactive_Automation_Script_Toolkit` | IAS references and planning |
| Script interactivity | <https://aka.dataminer.services/interactivity-options> | [`develop/schemadoc/Automation/InteractivityOptions.md` at `103263b...`](https://github.com/SkylineCommunications/dataminer-docs/blob/103263b74f73d172b7c7bc3fc10c3bae6d8ffc2c/develop/schemadoc/Automation/InteractivityOptions.md), UID `Automation-InteractivityOptions`; Automation schema package above | Automation XML and IAS |
| Runtime flags | <https://aka.dataminer.services/skyline-data-miner-automation-run-time-flags> | Generated API reference from the captured docs build | Automation core and IAS |
| Script parameters | <https://aka.dataminer.services/skyline-data-miner-automation-script-param> | Generated API reference from the captured docs build | Automation XML, scripting, and unit testing |
| Credentials | <https://aka.dataminer.services/Automation-credentials> | `develop/devguide/Automation/Howto/Using_credentials_in_an_automation_script.md`, UID `Using_credentials_in_an_automation_script` | Automation XML, scripting, and security |
| Permissions | <https://aka.dataminer.services/data-miner-user-permissions> | `dataminer/Administrator_guide/Security/DataMiner_user_permissions.md` | Orchestrator planning and deployment |
| Script runners | <https://aka.dataminer.services/script-runners> | `dataminer/Functions/Automation_module/Running_Automation_scripts/Script_Runners.md`, UID `Script_Runners` | Orchestrator, runtime, and operations |
| Entry points and C# blocks | <https://aka.dataminer.services/adding-c-sharp-code-to-an-automation-script> | `dataminer/Functions/Automation_module/Using_CSharp/Adding_CSharp_code_to_an_Automation_script.md` | Automation core and scripting |
| Unit testing | <https://aka.dataminer.services/unit-tests> | `develop/best_practices/Unit_testing/Unit_tests.md` and current test packages | `dataminer-automation-unit-testing` |
| Visual Studio templates | <https://aka.dataminer.services/visual-studio-templates> | `develop/TOOLS/NuGet/VisualStudioTemplates.md`, UID `VisualStudioTemplates`; template package above | Automation scaffolder and SDK |
| SDK project properties | <https://aka.dataminer.services/1162cFU6p> | `develop/CICD/Skyline DataMiner Software Development Kit/skyline_dataminer_sdk_project_properties.md`, UID `skyline_dataminer_sdk_project_properties` | Automation scaffolder, SDK, packaging |
| CI/CD master workflow | <https://aka.dataminer.services/git-hub-reusable-workflows-master-workflow> | `develop/CICD/GitHub/GitHubReusableWorkflows/GitHub_Reusable_Workflows_Master_Workflow.md`, UID `github_reusable_workflows_master_workflow` | Automation SDK and release workflow |
| DIS debugging | <https://aka.dataminer.services/debugging-an-automation-script> | `develop/TOOLS/DIS/Debugging/Debugging_an_Automation_script.md` | Automation investigator and DIS workflow |

All paths above are relative to the pinned `dataminer-docs` revision.

## Local ownership map

| Local owner | Upstream facts owned |
|---|---|
| `skills/dataminer-automation-core/` | Runtime model, entry-point overview, error behavior, source routing |
| `skills/dataminer-automation-xml/` | DMSScript structure and version-gated XML |
| `skills/dataminer-automation-scripting/` | Engine/API usage, input/output behavior, thread and logging rules |
| `skills/dataminer-interactive-automation/` | IAS package/API, host behavior, lifecycle, and widgets |
| `skills/dataminer-automation-unit-testing/` | Supported seams, packages, isolation, and executable test patterns |
| `skills/dataminer-sdk/references/automation-template-reference.md` | Actual output and options of the pinned official template package |

## Known unresolved source conflicts

These are recorded for later correction and must not be resolved by assumption:

1. `Run(Engine)` versus `Run(IEngine)` across legacy and SDK project guidance.
2. `.sln` versus `.slnx` output and requirements across template versions and hosts.
3. Whether script-parameter values are encoded identically for every invocation path.
4. The analyzer package set and severity emitted by each supported template version.

## Maintenance procedure

When a source revision or package changes:

1. Record the new version, commit, and SHA-256 without removing the previous reviewed baseline.
2. Identify affected topics and local owners from this map.
3. Verify behavior against the task's requested target versions.
4. Update the owning references and their focused evals in the same change.
5. Change this map's captured baseline only after the affected references pass review and validation.
