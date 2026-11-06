# IAS Toolkit Reference

Practical reference for the Interactive Automation Script Toolkit. The NuGet package is `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit`; the C# namespace is `Skyline.DataMiner.Utils.InteractiveAutomationScript`. Pin the package version before using its API.

> **Parent skill**: `dataminer-interactive-automation/SKILL.md`. C# rules: `dataminer-automation-scripting`.
> **Verify before inventing**: confirm exact widget names, properties, events, and lifecycle members against the selected package or a version-matched official example.
> **Runtime authority**: `dataminer-automation-core/references/runtime-safety-and-errors.md`. IAS callbacks remain inside the Automation single-thread contract.

## IAS runtime boundary

Use synchronous `public void Run(IEngine engine)`. Do not use an async entry point, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, or manually started threads. Keep `IEngine`/`Engine` and everything obtained through it—including dialogs, `Element`, dummy, `ScriptParam`/memory, sub-script, and `IDms` objects—on the original `Run` thread. Toolkit events and headless wire `AsyncCalls` do not authorize worker threads.

An external async-only API may be consumed synchronously with `GetAwaiter().GetResult()` only when it receives detached non-DataMiner inputs and returns plain detached data. Continue every Automation/DataMiner operation on `Run`.

Rethrow `ScriptAbortException`, `ScriptForceAbortException`, `ScriptTimeoutException`, and `InteractiveUserDetachedException`. Unexpected exceptions log full diagnostics only through `engine.Log("Run|Unexpected exception: " + ex.ToString());` and then call `engine.ExitFail("Runtime operation failed.");`. Never expose exception detail or sensitive data through `ExitFail`.

---

## Controller lifecycle decision matrix

| IAS Toolkit version | Initial-dialog call | Status and subsequent navigation |
|---|---|---|
| `<= 9.0.1` | `controller.Run(initialDialog)` | `Run` is public/non-obsolete and starts the loop. `controller.ShowDialog(nextDialog)` only queues or switches a subsequent dialog. |
| `9.0.2` through `9.0.11` | `controller.ShowDialog(initialDialog)` | Preferred. Controller `Run` is obsolete and produces `CS0618`; use `ShowDialog` for navigation too. |
| `>= 10.0.1` | `controller.ShowDialog(initialDialog)` | Controller `Run` is no longer public; use `ShowDialog` for navigation too. |

Do not present `Run / ShowDialog` as interchangeable. Both names in this table refer to `InteractiveController`; neither changes the required Automation script entry point `Script.Run(IEngine)`.

## Interactivity decision matrix

Explicit `<Interactivity>` values are supported from DataMiner feature release 10.5.9 and main release 10.6.0.

| Value | Runtime intent | Selection |
|---|---|---|
| `Never` | No UI | Current noninteractive scripts. |
| `Optional` | UI only when needed | A workflow that can complete without UI but sometimes prompts. |
| `Always` | Always UI | Preferred for operator-facing low-code IAS. |
| `Auto` | Legacy string detection | Compatibility only; not a universal default. |

Before DataMiner 10.5.9/10.6.0, `<Interactivity>` is unsupported. Omit the element and let legacy automatic detection apply.

## Runtime-control decision matrix

| Concern | Default/meaning | Authoring decision |
|---|---|---|
| Table key-mapping cache | `RunTimeFlags.NoKeyCaching` disables only table key-mapping caching. | Use the flag only when a documented operation can change a table-key mapping and make the cached mapping stale. Omit it otherwise. |
| Code-block duration | Default timeout is 10 minutes. | Omit an `engine.Timeout` assignment when 10 minutes is adequate. Override only for a documented, bounded operation or UX requirement; never use a generic generous or multi-hour timeout. |
| Successful completion | A natural return is success. | Use `engine.ExitSuccess` only for an explicit success message/result. Do not force it from terminal IAS events. Keep `engine.ExitFail` for failures and re-throw abort/detach exceptions. |

## Current initial-dialog example

This example targets Toolkit 10.0.1 or later and DataMiner 10.5.9/10.6.0 or later. It is an operator-facing low-code IAS, so its DMSScript uses `<Interactivity>Always</Interactivity>`. It has no operation that can stale a table-key mapping, and its UX fits within the 10-minute default; no key-cache flag or timeout override is needed.

```csharp
namespace CurrentIas
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
				controller = new InteractiveController(engine);
				var initialDialog = new InitialDialog(engine);
				controller.ShowDialog(initialDialog);
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
	}

	internal sealed class InitialDialog : Dialog
	{
		public InitialDialog(IEngine engine) : base(engine)
		{
			Title = "Confirm";
			AddWidget(new Label("Confirm the operation."), 0, 0);
		}
	}
}
```

When the dialog lifecycle completes successfully, `Script.Run(IEngine)` returns naturally. Add `ExitSuccess` only if the caller or operator requires an explicit success message/result.

## Low-level Engine UI API

Verified public overloads are `ShowUI(UIBuilder)`, `ShowUI(string)`, and `ShowUI(string, bool)`. Parameterless `ShowUI()` is absent. Prefer the version-matched Toolkit for non-trivial UI and keep any low-level UI call on the `Run` thread.

## Controller and dialogs

| Member | Purpose |
|--------|---------|
| `new InteractiveController(engine)` | Create the controller after selecting a compatible Toolkit version. |
| `class XDialog : Dialog` | Subclass per screen. The constructor takes `IEngine` and calls `: base(engine)`. |
| `dialog.Title` | Window title. |
| `dialog.AddWidget(widget, row, col)` | Place a widget on the grid. |
| `dialog.AddWidget(widget, row, col, rowSpan, colSpan)` | Place a widget spanning cells. |
| `AddWidget(..., verticalAlignment:, horizontalAlignment:)` | Optional alignment arguments. |
| `dialog.AddSection(section, ...)` | Add a reusable `Section` of widgets. |

## Common widgets

| Widget | Notes | Key members/events |
|--------|-------|--------------------|
| `Label` | Static text. | `Text` |
| `TextBox` | Single/multi-line input. | `Text`, `IsMultiline`, `Height`, `Changed` |
| `Numeric` | Numeric input. | `Value`, `Minimum`, `Maximum`, `Changed` |
| `CheckBox` | Single boolean. | `IsChecked`, `Changed` |
| `CheckBoxList` | Multi-select list. | ctor takes options; `Checked`, `IsSorted`, `Changed` |
| `DropDown` | Single-select list. | `Selected`, `Options`, `Changed` |
| `RadioButtonList` | Single-select radio. | `Selected`, `Changed` |
| `Button` | Action button. | ctor takes caption; `Pressed` |
| `Time` / `DateTimePicker` | Time/date input. | `Time` / value, `Changed` |
| `WhiteSpace` | Spacer for layout. | — |

> The example repository also demonstrates `DropDownFilter`, `DynamicButtonList`, `LazyLoadDropDown`, and collapsible/`Section`-based layouts. Reuse version-compatible component classes rather than reimplementing them.

## Grid layout

- Widgets sit on a **row/column grid**: `AddWidget(widget, row, col, rowSpan, colSpan)`.
- Keep columns consistent across widgets so the dialog aligns. Use `colSpan` to stretch wide controls such as a multiline `TextBox` or footer `Button`.
- Use `WhiteSpace` and alignment arguments to tune spacing instead of empty labels.

## Navigation / wizard pattern

For Toolkit 9.0.1 and the 9.0.2-or-later lines in the lifecycle matrix, `ShowDialog` is the subsequent-dialog navigation method. Only its use for the *initial* dialog differs by version.

```csharp
// In step 1's "Next" button handler:
nextButton.Pressed += (s, e) =>
{
	var step2 = new Step2Dialog(engine); // pass state through the constructor/model
	step2.Back.Pressed += (a, b) => controller.ShowDialog(this);
	controller.ShowDialog(step2);
};
```

Pass state between dialogs via constructor arguments or a shared model object. For non-trivial flows use the **Model-View-Presenter** pattern (`ModelViewPresenter` / `DynamicSections` examples): the `Dialog` is the View, and a Presenter wires events to a Model.

## Final checklist

- [ ] DataMiner core/web, Automation Dev Pack, and exact Toolkit package versions are recorded.
- [ ] The initial-dialog API matches the selected Toolkit lifecycle row.
- [ ] The DMSScript value matches target support and UX, or the unsupported element is omitted on a legacy target.
- [ ] `NoKeyCaching` is used only if a documented operation can change a table-key mapping and make its cached mapping stale.
- [ ] The default 10-minute timeout is retained unless a documented, bounded operation/UX requirement needs an override.
- [ ] Natural return is used unless an explicit success message/result is required.
- [ ] `InteractiveUserDetachedException` and other runtime abort exceptions are rethrown.
- [ ] No async entry point, `async void`, `Task.Run`, parallel loop, manual thread, or cross-thread Engine-derived/DataMiner object exists.
- [ ] External async-only calls are synchronously consumed with detached plain data.
- [ ] Unexpected exceptions use the exact full-diagnostic `Log` plus stable `ExitFail` contract; failures contain no exception detail or sensitive data.
- [ ] `GenerateInformation` is limited to meaningful lifecycle/CRUD/operator audit events; diagnostic `Log` use is sparse and non-sensitive.
