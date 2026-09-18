---
name: dataminer-execute-automation-script
description: Use when implementing or debugging a call to the DataMiner ExecuteAutomationScriptWithOutput JSON API. Contains the exact JSON request structure, scriptOptions fields, and how parameters are encoded.
license: LicenseRef-DataMiner-App-Builder
---

# Execute Automation Script With Output Skill

Execute an automation script and receive its output via the DataMiner JSON API.

## Endpoint

```
POST /API/v1/Json.asmx/ExecuteAutomationScriptWithOutput
Content-Type: application/json
```

## Request Body

```json
{
  "connection": "<session token>",
  "script": {
    "__type": "Skyline.DataMiner.Web.Common.v1.DMAAutomationScript",
    "Name": "<script name>",
    "Folder": "<folder name>",
    "Description": "",
    "Settings": {
      "__type": "Skyline.DataMiner.Web.Common.v1.DMAAutomationScriptSettings",
      "RequireInteractive": false,
      "HasFindInteractiveClient": false
    },
    "Parameters": [
      {
        "__type": "Skyline.DataMiner.Web.Common.v1.DMAAutomationScriptParameter",
        "ParameterId": 1,
        "Values": null,
        "MemoryFile": "",
        "Name": "<param name>",
        "Value": "<encoded value>"
      }
    ],
    "Dummies": [],
    "MemoryFiles": []
  },
  "scriptOptions": {
    "__type": "Skyline.DataMiner.Web.Common.v1.DMAAutomationScriptOptions",
    "WaitForScript": true,
    "CheckSets": true,
    "LockElements": false,
    "ForceLockElements": false,
    "WaitWhenLocked": true,
    "IsInUse": false,
    "AskForConfirmation": false,
    "GenerateStartedInfoEvent": true,
    "customSuccessMessage": null,
    "hideSuccessPopup": true,
    "skipPresetsIfComplete": true,
    "hidePresets": true,
    "popupIsMinimizable": false,
    "popupType": 1,
    "ClientTimeZone": { "Type": 0, "Info": null }
  }
}
```

## Parameter Value Encoding

Script parameters in C# typically deserialize their `Value` string using `JsonSerializer.Deserialize<string[]>`. The encoding convention is:

| Intent | `Value` to send |
|---|---|
| Provide a value | `'["<value>"]'` — JSON-encoded string array |
| Skip / no change | `"null"` — literal string null |
| Clear / empty | `"[]"` — empty JSON array |
| Raw string (no deserialization) | Plain string e.g. `"update"` |

**Important:** `""` (empty string) ≠ `"null"`. Use `"null"` to skip, `"[]"` to clear.

All defined parameters should be included in every call — use `"null"` for any you don't want to change.

## Response

```json
{
  "d": {
    "ErrorCode": 0,
    "Output": [
      { "Name": "string", "Value": "string" }
    ]
  }
}
```

A non-zero `ErrorCode` or an exception message in the response indicates the script failed.

## Frontend Wrapper

In the app, wrap `ExecuteAutomationScriptWithOutput` in a helper function that handles encoding automatically. Provide only the params you want to set; the wrapper maps omitted ones to `"null"` and empty strings to `"[]"`.
