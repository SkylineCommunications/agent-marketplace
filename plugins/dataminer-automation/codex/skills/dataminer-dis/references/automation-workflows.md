# DIS Automation Workflows

Use this reference when Visual Studio and DIS are available for Automation XML/C# authoring or debugging. It complements `dataminer-automation-xml`, `dataminer-automation-scripting`, and `dataminer-interactive-automation`; it does not replace the pinned XSD, package API, or target-host decision.

## Authoring and validation

1. Connect DIS to the target DataMiner Agent through **DIS > DMA > Connect**.
2. Import the Automation script.
3. Use the XML editor for schema-aware `DMSScript` editing and the **Edit C#** action for the selected `Exe` block.
4. Confirm the exact project link, descendant IDs, target package versions, and XML/C# numeric parameter parity.
5. Build with the selected SDK/Dev Pack and analyzers. DIS visual feedback is useful, but the pinned XSD/build gates remain authoritative.

## DIS Inject debug flow

1. Open **Tool Windows > DIS Inject** and select the **Automation script** tab.
2. Select the target Automation script, map each Exe ID to the intended temporary project, assign script parameters, and link every dummy.
3. Set breakpoints, click **Attach**, and wait for the temporary project build/upload and debugger attachment to `SLAutomation`.
4. Click **Execute** only for the approved diagnostic case.
5. Capture the target/version, script/Exe identity, parameter/dummy mapping, breakpoint evidence, logs, and result. Detach and restore the original deployed artifact before handoff.

DIS Inject is a controlled debug route, not a packaging, publication, deployment, or live-test completion gate. Do not inject an unreviewed build into a production element.

Official source: [Debugging an Automation script](https://aka.dataminer.services/debugging-an-automation-script) and [DIS Inject](https://aka.dataminer.services/dis-inject-tool-window).
