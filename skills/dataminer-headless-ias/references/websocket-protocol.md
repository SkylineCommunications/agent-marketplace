# DataMiner WebSocket Protocol — Headless IAS Reference

For generic WebSocket connection setup (URL, `SetConnectionID`, keep-alive, message structure, `ClientSubscriptionID` management), see the **dataminer-api** skill (`references/websocket-setup.md`).

This reference covers IAS-specific WebSocket messages used to drive an Interactive Automation Script from a custom UI.

---

## Full Protocol Flow

```
Client                              Server
  │                                    │
  │── WS open ──────────────────────►  │
  │── SetConnectionID(sessionGUID) ──► │
  │◄── String (echo connection ID) ──  │
  │                                    │
  │── HTTP ExecuteAutomationScript ──► │  → returns { ScriptID }
  │                                    │
  │── WS LaunchAutomationScript ─────► │  → subscribes to script events
  │◄── DMAAutomationScriptBasicUpdate  │  Type: "Started"
  │                                    │
  │◄── DMAAutomationScriptUIUpdate ──  │  dialog layout + AsyncCalls count
  │◄── DMAAutomationScriptUIDropDown…  │  × AsyncCalls (dropdown options)
  │── ContinueAutomationScript ──────► │  values string with filled form
  │                                    │
  │    … repeat for each dialog …      │
  │                                    │
  │◄── DMAAutomationScriptBasicUpdate  │  Type: "Completed", Data: "SUCCEEDED"
```

**Key points:**
- `LaunchAutomationScript` is required — without it the WebSocket never receives dialog events.
- `LaunchAutomationScript` takes `scriptID`; `ContinueAutomationScript` takes `scriptId` (camelCase). The casing differs per method.
- `HasFindInteractiveClient` must be `false` in the script settings — otherwise the script races with the manual launch.
- Wait for **all** `AsyncCalls` dropdown updates before sending `ContinueAutomationScript`. Sending too early means missing options and errors.
- **Every re-render (including `_onfocuslost`) produces a new `DMAAutomationScriptUIUpdate` for the same dialog with its own `AsyncCalls`** — wait for those updates again before advancing, or they will be miscounted against the next dialog.
- **Dropdown options arrive via two paths:** (1) asynchronously via `DMAAutomationScriptUIDropDownUpdate` messages (counted by `AsyncCalls`), or (2) inline in the layout component's `Options` array (set synchronously during re-renders). Always extract options from both.
- **Handle `WebSocketError`** (fail fast, surface `Data.Message`) — it's how server-side script crashes are reported.

---

## WebSocket Message Reference

### LaunchAutomationScript

Send after `ExecuteAutomationScript` returns the `ScriptID`. Subscribes the WebSocket to all script events for that run.

```json
{
  "ClientSubscriptionID": <N>,
  "Method": "LaunchAutomationScript",
  "Parameters": {
    "connection": "<connection-string>",
    "scriptID": <ScriptID>
  }
}
```

### ContinueAutomationScript

Send to submit a completed dialog form or trigger a re-render/FocusLost event.

> **Note the casing**: this method's parameter is `scriptId` (camelCase) — different from `LaunchAutomationScript`, which uses `scriptID`. Sending `scriptID` here fails with `WebSocketError: "Parameter 'scriptId' is not defined."`

```json
{
  "ClientSubscriptionID": <N>,
  "Method": "ContinueAutomationScript",
  "Parameters": {
    "connection": "<connection-string>",
    "scriptId": <ScriptID>,
    "values": "<values-string>"
  }
}
```

The `values` string format is described in the **Building the Values String** section of the skill.

---

## Incoming Message Types

| Message type | When received | Key fields |
|---|---|---|
| `DMAAutomationScriptBasicUpdate` | Script started, completed, or errored | `Type`: `"Started"` / `"Completed"`, `Data`: `"SUCCEEDED"` / error message |
| `DMAAutomationScriptUIUpdate` | New dialog layout (initial or re-render) | `Components[]`, `AsyncCalls` count |
| `DMAAutomationScriptUIDropDownUpdate` | Async dropdown options loaded | `Info.DropDownID` (the DestVar), `Info.Options[]` |
| `WebSocketError` | Server-side failure (bad parameter, script crash, invalid value) | `Data.Message` — fail fast and surface this |
