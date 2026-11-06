---
name: dataminer-interactive-automation
description: 'Build interactive (operator-facing) DataMiner Automation scripts (IAS): the Interactive Automation Script Toolkit (InteractiveController, Dialog, Section, widgets), AddWidget grid layout, event-driven navigation, and the engine.ShowUI low-level alternative. Load for any wizard, form, or dashboard automation script.'
argument-hint: 'Describe the UI task: e.g. "show a confirmation dialog", "build a multi-step wizard", "let the user pick elements from a dropdown", "add a button that runs an action"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 1.4
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.4 | 2026-09-16 | Added host-specific IAS lifecycle and verification routing for Cube, web, low-code, attached, DIS, and explicit headless contexts. |
| 1.3 | 2026-09-14 | Applied Run-thread-only IAS execution, canonical safe errors, audit logging rules, and verified ShowUI overloads. |
| 1.2 | 2026-09-14 | Added version-specific controller lifecycles, target-gated interactivity, conditional runtime controls, and a current ShowDialog example. |
| 1.1 | 2026-09-11 | Distinguished the IAS Toolkit NuGet package from its C# namespace. |
| 1.0 | 2026-06-27 | Initial release. Grounded in the official `SLC-AS-Example_InteractiveAutomationScriptToolkit` repo. No connector analog. |

You are guided here for **Interactive Automation Scripts (IAS)** — scripts that present a UI to an operator.

> **Skill authorities**: load `dataminer-automation-core` first and `dataminer-automation-scripting` for the C# rules. Load `references/ias-hosts-and-lifecycle.md` before selecting a host, attachment, web/low-code, or headless route. The UI layer uses the NuGet package `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` and C# namespace `Skyline.DataMiner.Utils.InteractiveAutomationScript` (load `dataminer-nugets` to select and pin the package version).
> **Canonical reference**: the official repo `SLC-AS-Example_InteractiveAutomationScriptToolkit` (CheckBoxList, DropDownFilter, DynamicButtonList, DynamicSections (MVP), HideUI, LazyLoadDropDown, ModelViewPresenter). Use `dataminer-github-example-finder` to locate it, but match examples to the selected Toolkit version.

New authoring is SDK-first. Maintained legacy Cube-inline scripts remain valid for review and investigation. Use headless IAS only when the user explicitly requests that non-authoritative flow; do not substitute it for supported Cube, web, or low-code IAS hosts. All DataMiner, web, Dev Pack, and Toolkit versions are task-specific. IAS remains an Automation script: keep `IEngine`/`Engine`, dialogs, and every Engine-derived/DataMiner object on the synchronous `Run` thread; Toolkit events do not authorize worker threads.

## Two approaches

| Approach | Use When |
|----------|----------|
| **IAS Toolkit** (`InteractiveController` + `Dialog` + widgets) | Any non-trivial UI — wizards, forms, dashboards. Default choice after pinning a compatible Toolkit version. |
| **Low-level `engine.ShowUI(UIBuilder)`** (`UIBuilder` → `UIResults`) | Tiny/legacy single-screen prompts, or when the Toolkit package cannot be added. Parameterless `ShowUI()` is absent. |

## Decide the initial-dialog lifecycle first

`InteractiveController` changed across Toolkit versions. Pin/select the Toolkit package version, then use exactly the matching initial-dialog API:

| IAS Toolkit version | Initial dialog | Subsequent dialogs |
|---|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` starts the interactive loop. | `controller.ShowDialog(nextDialog)` only switches or queues a subsequent dialog. |
| `9.0.2` through `9.0.11` | `controller.ShowDialog(initialDialog)` is preferred; controller `Run` is obsolete and produces `CS0618`. | Use `ShowDialog` for navigation. |
| `>= 10.0.1` | `controller.ShowDialog(initialDialog)`; controller `Run` is no longer public. | Use `ShowDialog` for navigation. |

Never offer `Run / ShowDialog` as an interchangeable choice. These are `InteractiveController` lifecycle members; they are distinct from the required Automation entry point `Script.Run(IEngine)`.

## Select DMSScript interactivity from the UX

Explicit `<Interactivity>` is supported from DataMiner feature release 10.5.9 and main release 10.6.0:

| Value | Behavior and selection rule |
|---|---|
| `Never` | No UI. Use for noninteractive scripts. |
| `Optional` | UI is shown only when needed. |
| `Always` | UI is always shown. Prefer this for operator-facing low-code IAS. |
| `Auto` | Legacy string-detection compatibility only. It is not the universal default. |

Before those DataMiner versions, the element is unsupported: omit `<Interactivity>` and rely on legacy automatic detection. Record the target and UX rationale in the plan.

## Decide runtime controls independently

Neither control is generic IAS setup:

| Control | Decision |
|---|---|
| `engine.SetFlag(RunTimeFlags.NoKeyCaching)` | Disables only table key-mapping caching. Use it only when a documented operation can change a table-key mapping and make its cached mapping stale; otherwise omit it. |
| `engine.Timeout` | Automation code blocks have a 10-minute default timeout. Override it only for a documented, bounded operation or UX requirement. Omit it when 10 minutes is adequate; never prescribe a generic generous or multi-hour timeout. |

Natural return from `Script.Run(IEngine)` is successful completion. Use `engine.ExitSuccess` only when an explicit success message/result is required; do not force it from a terminal IAS event. Rethrow abort, force-abort, timeout, and `InteractiveUserDetachedException`. For unexpected `Exception ex`, log `"Run|Unexpected exception: " + ex.ToString()` and call `engine.ExitFail("Runtime operation failed.")`; never expose exception detail or sensitive data through `ExitFail`.

## IAS Toolkit core building blocks

| Type | Role |
|------|------|
| `InteractiveController` | Owns the interactive loop; initialize it with `new InteractiveController(engine)` and use the version-selected lifecycle above. |
| `Dialog` (base class) | A screen. Subclass it; place widgets with `AddWidget(widget, row, col[, rowSpan, colSpan])`; set `Title`. |
| `Section` | Reusable group of widgets you can add to a dialog. |
| **Widgets** | `Label`, `TextBox`, `Numeric`, `CheckBox`, `CheckBoxList`, `DropDown`, `RadioButtonList`, `Button`, `Time`, `DateTimePicker`, `WhiteSpace`, … (verify the exact set against the selected package/example). |

Widgets are event-driven: `button.Pressed += (s, e) => ...`, `checkBoxList.Changed += (s, e) => ...`. Pass state to later screens through constructors or a shared model.

## Current entry pattern (`>= 10.0.1` Toolkit)

This example assumes an IAS Toolkit version at or above 10.0.1 and a DataMiner 10.5.9/10.6.0-or-later operator-facing low-code target whose XML uses `<Interactivity>Always</Interactivity>`. It performs no table key mapping, and the default 10-minute timeout is adequate, so neither runtime control is added. When the dialog lifecycle completes without failure, the entry point returns naturally.

```csharp
namespace My_Interactive_1
{
	using System;

	using Skyline.DataMiner.Automation;
	using Skyline.DataMiner.Utils.InteractiveAutomationScript;

	public class Script
	{
		private InteractiveController controller;

		public void Run(IEngine engine)
		{
			try
			{
				RunSafe(engine);
			}
			catch (ScriptAbortException) { throw; }
			catch (ScriptForceAbortException) { throw; }
			catch (ScriptTimeoutException) { throw; }
			catch (InteractiveUserDetachedException) { throw; }
			catch (Exception ex)
			{
				engine.Log("Run|Unexpected exception: " + ex.ToString());
				engine.ExitFail("Runtime operation failed.");
			}
		}

		private void RunSafe(IEngine engine)
		{
			controller = new InteractiveController(engine);
			var initialDialog = new MyDialog(engine);
			controller.ShowDialog(initialDialog);
		}
	}
}
```

## Dialog pattern

```csharp
public class MyDialog : Dialog
{
	private readonly Button okButton;

	public MyDialog(IEngine engine) : base(engine)
	{
		Title = "Select Option(s)";

		var checkBoxList = new CheckBoxList(new[] { "A", "B", "C" }) { IsSorted = true };
		var output = new TextBox { IsMultiline = true, Height = 150 };
		checkBoxList.Changed += (s, e) => output.Text = String.Join(Environment.NewLine, checkBoxList.Checked);

		okButton = new Button("OK");
		okButton.Pressed += (s, e) => Accepted?.Invoke(this, EventArgs.Empty);

		AddWidget(new Label("Select Option(s)"), 0, 0, verticalAlignment: VerticalAlignment.Top);
		AddWidget(checkBoxList, 0, 1);
		AddWidget(output, 1, 0, 1, 2);
		AddWidget(okButton, 2, 0, 1, 2);
	}

	public event EventHandler Accepted;
}
```

## Constraints

- Pin the Toolkit version and use only its matching initial-dialog lifecycle.
- Keep the Automation entry point synchronous. Do not use async entry points, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, or manually started threads. Never move `IEngine`/`Engine`, `Element`, dummy, `ScriptParam`/memory, dialog/sub-script, `IDms`, or related DataMiner objects off `Run`. Consume an external async-only API synchronously only with detached plain inputs/results.
- Keep the canonical runtime/detach rethrows and exact unexpected `Log` + stable `ExitFail` handler. Never expose exception text/message/stack, credentials, tokens, raw payloads, or sensitive inputs through `ExitFail`.
- Use `GenerateInformation` only for meaningful material lifecycle/CRUD/operator audit events; never trace/progress, routine output, counts/missing keys, per-item loops, exception details, or secrets. Keep `Log` sparse and non-sensitive.
- Always keep `catch (InteractiveUserDetachedException) { throw; }` so detachment retains runtime semantics.
- Select `<Interactivity>` by target support and UX; do not use `Auto` as a current default.
- Add `NoKeyCaching` only if a concrete operation can change a table-key mapping and make its cached mapping stale.
- Retain the default 10-minute timeout unless a documented, bounded operation or UX requirement justifies an override.
- Let successful execution return naturally unless an explicit success message/result is required.
- Lay widgets on the grid with explicit `row, col[, rowSpan, colSpan]`; align with `HorizontalAlignment` / `VerticalAlignment`.
- For complex UIs, use **Sections** and the **MVP** pattern (see `DynamicSections` / `ModelViewPresenter` in the example repo) to keep dialogs maintainable.
- Verify any widget/property you are unsure about against the pinned Toolkit package or a version-matched example — do not invent widget names or members. Verified low-level overloads are `ShowUI(UIBuilder)`, `ShowUI(string)`, and `ShowUI(string, bool)`; parameterless `ShowUI()` is absent.

## Reference Files

| File | Contents | Load When |
|------|----------|-----------|
| `references/ias-toolkit-reference.md` | Versioned lifecycle, interactivity/runtime matrices, current example, widget catalog, layout, and navigation | Building any interactive dialog |
| `references/ias-hosts-and-lifecycle.md` | Cube, web, low-code, attached, DIS, and explicit headless host contracts and verification gates | Choosing or testing an IAS host |
