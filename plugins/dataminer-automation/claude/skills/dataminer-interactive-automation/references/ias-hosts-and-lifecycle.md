# IAS Hosts and Lifecycle

An Interactive Automation Script (IAS) is still an Automation script with a synchronous `Run(IEngine)` entry point. The host determines whether a UI can be shown, how a user attaches, which timeout applies, and which live verification route is meaningful.

## Host matrix

| Host/context | Supported behavior to plan | Verification |
|---|---|---|
| Direct DataMiner Cube execution | Use the version-selected IAS Toolkit lifecycle and target-supported `<Interactivity>` value. A manually executed script is automatically attached to the Cube user. | Verify the dialog lifecycle, controls, detach behavior, permissions, and natural/explicit completion in the target environment. |
| Scheduler, Correlation, QAction, or another non-UI caller | The caller is not a UI client. If operator input is required, use the target-verified `FindInteractiveClient` flow with a bounded timeout; failure to attach must be explicit and stable. | Verify both an attached Cube path and the no-client timeout path. `FindInteractiveClient` does not work for web sessions. |
| Low-Code Apps IAS component | Only interactive scripts are shown. Required parameters/dummies must be configured by the component or its actions; script dimensions are ignored and the UI fills the component. | Verify the component start/abort/finish behavior, concurrent-start waiting, target web version, and component-specific 15-minute timeout. |
| Web session | Do not rely on Cube attachment APIs. Embed the script through the supported IAS component or use a non-interactive workflow. | Verify the web/low-code component with the target DataMiner web version. |
| DIS-attached debug session | Use DIS Inject to link the exact script/Exe projects, assign parameters/dummies, attach to `SLAutomation`, and execute deliberately. | Debug only a controlled target; detach and restore the original artifact before reporting completion. |
| Headless execution | No UI is authoritative by default. Use only when explicitly requested and label the route non-authoritative if it cannot exercise the intended host. | Verify the non-UI result contract, timeout, permissions, logs, and cleanup separately from UI behavior. |

## Lifecycle decisions

1. Pin DataMiner core/web and IAS Toolkit versions before choosing the initial-dialog API.
2. Select `<Interactivity>` from target support and UX: `Always` for operator-facing low-code IAS when supported, `Optional` when UI is conditional, `Never` for noninteractive scripts, and `Auto` only for deliberate legacy detection. Omit it on older targets that do not support the element.
3. Define required parameters, dummies, memory, permissions, credential access, lock behavior, timeout, abort/detach behavior, and output/result contract.
4. Keep all Engine-derived work on the `Run` thread. UI callbacks do not authorize worker threads.
5. Test the actual host. A successful build or Cube run does not prove web/low-code rendering.

Official sources:

- [Launching and attaching interactive Automation scripts](https://aka.dataminer.services/launching-and-attaching-interactive-aut-b5db4e7f)
- [Interactive Automation Script in Low-Code Apps](https://aka.dataminer.services/IASComponent)
- [Find interactive client](https://aka.dataminer.services/find-interactive-client)
- [Getting started with the IAS Toolkit](https://aka.dataminer.services/1068hoHHP)
