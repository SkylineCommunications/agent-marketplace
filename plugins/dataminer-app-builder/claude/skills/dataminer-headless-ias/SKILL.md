---
name: dataminer-headless-ias
description: Use when a frontend app needs to drive a DataMiner Interactive Automation Script (IAS) from a custom UI. Covers the full WebSocket + HTTP protocol flow, dialog parsing, values string construction, re-render handling, and multi-dialog wizard navigation.
license: LicenseRef-Skyline-Agent-Marketplace
user-invocable: true
---

# Headless IAS (Interactive Automation Script) Client

Drive a DataMiner Interactive Automation Script from a custom UI instead of the built-in dialog renderer.

---

## 0. Before You Start

### Find the script name

If the user doesn't know the exact script name, retrieve all available Automation script names via:

```
POST {baseUrl}/API/v1/Json.asmx/GetAutomationScripts
{ "connection": "<connection-string>" }
```

Response: a flat string array of script names, e.g. `["MyScript", "AnotherScript", …]`.

Present the list to the user so they can pick the right one.

### Ask for the script source

**Always ask the user to provide the C# source of the selected script before doing anything else.**
Without it you cannot know the dialog structure, widget layout, button wiring, async data calls, or re-render triggers — all of which are required to drive the script correctly.

---

## 1. WebSocket Protocol Flow

For WebSocket connection setup (URL, `SetConnectionID`, keep-alive, `ClientSubscriptionID` management), see the **dataminer-api** skill (`references/websocket-setup.md`). The `connection` string comes from the session bootstrap call described in the **dataminer-api** skill.

See `references/websocket-protocol.md` for IAS-specific message formats (flow diagram, `LaunchAutomationScript`, `ContinueAutomationScript`, and incoming message types).

**Key points:**
- `LaunchAutomationScript` is required — without it the WebSocket never receives dialog events.
- `HasFindInteractiveClient` must be `false` in the script settings — otherwise the script races with the manual launch.
- Wait for **all** `AsyncCalls` dropdown updates before sending `ContinueAutomationScript`. Sending too early means missing options and errors.
- **Dropdown options arrive via two paths:** (1) asynchronously via `DMAAutomationScriptUIDropDownUpdate` messages (counted by `AsyncCalls`), or (2) inline in the layout component's `Options` array (set synchronously during re-renders). Always extract options from both.

---

## 2. Analyzing a Script's C# Source

When the user provides the script source, read it to extract everything needed to build the headless client.

### What to look for

**Dialogs** — Each `View` + `Presenter` pair is one dialog. Read each View's `Build()` method top-to-bottom — every `AddWidget(...)` call is a row with a label and a widget.

**Buttons** — In each Presenter, find what each button does:
- `ButtonNext.Pressed += …` → advances to the next dialog
- `ButtonSave.Pressed += …` or `ButtonCreate.Pressed += …` → submits / saves
- `ButtonPrevious.Pressed += …` → goes back
- When a dialog has both "Next" and "Save/Create", prefer "Next" to go through all dialogs.

**Async data** — `Task.Run(...)` calls in init methods load data for dropdowns. Each async task = one `DMAAutomationScriptUIDropDownUpdate` on the WebSocket. The `AsyncCalls` count tells you how many to wait for.

**Conditional widgets** — Checkboxes with `WantsOnChange` that toggle `IsVisible` on another widget. These hidden widgets have no DestVar in the initial layout — they only appear after a re-render.

**Dependent dropdowns** — One dropdown's `Changed` handler repopulates another dropdown (e.g. Organization → Job Owner). To set both values, you must trigger the parent's `_onchange` first, wait for the re-render, then set the child. The child's new options typically arrive **inline in the re-rendered layout** (in the component's `Options` array), not via `DMAAutomationScriptUIDropDownUpdate`. Always parse inline options from the layout in addition to async updates.

**FocusLost textboxes** — Textboxes with `WantsOnFocusLost: true` populate the server model only via a `FocusLost` event. Look for `TextBox.FocusLost += (s, e) => model.Property = e.Value;` in the Presenter. These values are **not** read from the submitted form data — the model field stays empty unless FocusLost fires. Trigger it with `_onfocuslost` before clicking Save.

**Re-render triggers** — Any component with `WantsOnChange: true` and a `Changed` event in the Presenter will re-render the dialog when `_onchange` points to its DestVar. This refreshes the layout (new/updated components) without advancing to the next dialog.

### How to map widgets

For each widget, note:

| Property      | How to identify                                                                                |
|---------------|------------------------------------------------------------------------------------------------|
| Label         | Static text in the same row                                                                    |
| Type          | `Type` field in the WS message: `textbox`, `time`, `timespan`, `dropdown`, `checkbox`, `button`|
| DebugTag      | Set on the widget in C#. Appears as `DebugTag` in the WS component. Most reliable identifier.  |
| WantsOnChange    | If `true`, fires a server event when `_onchange` points to its DestVar                      |
| WantsOnFocusLost | If `true`, fires a FocusLost event when `_onfocuslost` points to its DestVar                |
| Conditional      | Only appears after a checkbox/dropdown triggers a re-render                                 |

**Matching priority** when building values: DebugTag → label text → type + position.

---

## 3. Building the Values String

Every `ContinueAutomationScript` call sends a single values string. There are two formats depending on the action:

**Standard (click / trigger):**
```
_onchange=<clickedDestVar>\x1d<destVar1>=<val1>\x1d<destVar2>=<val2>…
```

**FocusLost (for `WantsOnFocusLost` textboxes):**
```
_onfocuslost=<textboxDestVar>\x1d<destVar1>=<val1>\x1d<destVar2>=<val2>…
```

`\x1d` is the group separator character.

### Rules

- **Every component with a DestVar must be included** — even if left empty. Missing keys crash the script.
- **`_onchange`** = the DestVar of the component you want to "click" or trigger.
- **`_onfocuslost`** = the DestVar of a `WantsOnFocusLost` textbox whose value must reach the server model via its `FocusLost` event. This is a standalone key — do **not** include `_onchange` in the same message. The server fires FocusLost on the targeted textbox and re-renders the dialog.
- **Button values**: the clicked button's value = its own DestVar. All other buttons = empty string.
- **Don't hardcode DestVar GUIDs** — they change between script instances. Parse the layout and match by DebugTag or label.

### Value formats by type

| Type     | Format                                   | Example                        |
|----------|------------------------------------------|--------------------------------|
| Textbox  | Plain string                             | `My Job Name`                  |
| Time     | ISO 8601, 7-digit fractional seconds     | `2026-06-02T12:55:00.0000000Z` |
| Timespan | `d.HH:mm:ss` or `H:mm:ss`               | `1.00:00:00`, `0:30:00`        |
| Checkbox | `True` or `False` (capital first letter) | `False`                        |
| Dropdown | Display text of the selected option      | `Draft`, `-Select-`            |
| Button   | Own DestVar if clicked, empty if not     | `e5fea13e-…` or `` (empty)     |

---

## 4. Handling Multi-Dialog Wizards and Re-renders

### Phase state machine

Track which dialog/phase you're in. Each `DMAAutomationScriptUIUpdate` either advances to the next dialog or re-renders the current one.

```
DIALOG_1_INITIAL   → first dialog received
DIALOG_1_RERENDER  → same dialog re-rendered (after a WantsOnChange trigger)
DIALOG_2           → second dialog
…
DIALOG_N           → last dialog
DONE               → awaiting Completed
```

### When to trigger a re-render vs. advance

- If the user provided a value for a `WantsOnChange` dropdown/checkbox → set `_onchange` to that component's DestVar, fill all values, send. This re-renders the same dialog (new layout, possibly new components). Stay in a "rerender" phase.
- If no re-render is needed → fill values and set `_onchange` to the advancing button (Next / Save / Create). This moves to the next dialog or submits.

### Re-render behavior

1. Server sends a **new** `DMAAutomationScriptUIUpdate` for the **same** dialog.
2. Layout may have new components (e.g. a timespan picker now visible) or updated values.
3. Wait for all `AsyncCalls` again.
4. Fill and submit the refreshed layout.

Re-renders refresh — only button clicks advance or submit.

### Back-navigation

Previous/Back buttons are **server-side navigation**, not local UI state. Clicking "Previous" must send a `ContinueAutomationScript` with `_onchange` set to the Previous button's DestVar. The server returns the prior dialog's layout with fresh components. Never go back by only changing local step state — the session's components will be out of sync and subsequent actions will fail (e.g. "Next button not found" because the server is still on a different dialog).

### Common patterns

| Pattern                    | How to detect in C# source                                       | Headless handling                                          |
|----------------------------|-------------------------------------------------------------------|------------------------------------------------------------|
| Multi-dialog wizard        | Multiple View/Presenter pairs; Next/Previous buttons              | Phase state machine; click Next to advance, click Previous to go back (both are server round-trips) |
| Checkbox-gated fields      | `CheckBox.Changed` toggles `IsVisible` on another widget         | Trigger re-render to get the new DestVar                   |
| Dependent dropdowns        | `DropDown.Changed` repopulates another dropdown                  | `_onchange` on parent → re-render; read child options from layout `Options` array (inline, not async) |
| Template/workflow selector | Dropdown `Changed` updates multiple fields across the dialog     | Trigger re-render → read updated values from new layout    |
| Skip-ahead                 | Both "Save" and "Next" buttons on same dialog                    | Click "Save" to skip remaining dialogs if allowed          |
| Async data load            | `Task.Run(() => handler.GetAll…())` in init                      | Count matches `AsyncCalls`; wait for all before submitting |
| FocusLost textbox          | `TextBox.FocusLost += (s, e) => model.Prop = e.Value;` with `WantsOnFocusLost: true` | Two-step submit: (1) send `_onfocuslost` targeting the textbox, wait for re-render, (2) click Save button |
