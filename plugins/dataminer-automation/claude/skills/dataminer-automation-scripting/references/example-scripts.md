# Automation Script Pattern Library (C#)

Copy-ready Engine (`IEngine`) patterns. All members are real — verify anything else against the API reference.

> **Parent skill**: `dataminer-automation-scripting/SKILL.md`.

---

## Required entry wrapper

```csharp
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
```

Keep this entry point synchronous and keep all Engine/DataMiner objects on its thread.

## Pattern 1 — Read a script parameter (normalized)

```csharp
private static string GetParam(IEngine engine, int id)
{
	return engine.GetScriptParam(id).Value.Trim().TrimStart('[', '"').TrimEnd('"', ']');
}
```

## Pattern 2 — Resolve an element (name or key) and act

```csharp
string identifier = GetParam(engine, 10);

Element element = identifier.Contains("/")
	? engine.FindElementByKey(identifier)   // "DataMinerID/ElementID"
	: engine.FindElement(identifier);        // element name

if (element == null)
{
	engine.ExitFail("The requested element was not found.");
	return;
}

if (!element.IsActive)
{
	engine.ExitFail("The requested element is not active.");
	return;
}
```

## Pattern 3 — Read / write a standalone parameter

```csharp
object current = element.GetParameter(parameterId);
element.SetParameter(parameterId, newValue);
```

## Pattern 4 — Read / write a table cell by primary key

```csharp
object cell = element.GetParameterByPrimaryKey(columnPid, rowKey);
element.SetParameterByPrimaryKey(columnPid, rowKey, value);
```

> For many rows, switch to the DataMinerSystem library instead of looping these calls.

## Pattern 5 — Bulk / typed table access via IDms

```csharp
using System.Linq;

using Skyline.DataMiner.Core.DataMinerSystem.Automation;
using Skyline.DataMiner.Core.DataMinerSystem.Common;

IDms dms = engine.GetDms();
IDmsElement dmsElement = dms.GetElement(new DmsElementId(element.DmaId, element.ElementId));
IDmsTable table = dmsElement.GetTable(tablePid);
object[][] rows = table.GetData().Values.ToArray();
// ... process rows in memory, then write back in bulk ...
```

> Confirm exact `IDms` members against the DataMinerSystem.Automation API reference for your DM version before relying on them.

## Pattern 6 — Numeric / culture-safe parsing

```csharp
using System.Globalization;

if (!Double.TryParse(GetParam(engine, 11), NumberStyles.Any, CultureInfo.InvariantCulture, out double value))
{
	engine.ExitFail("Run|Value is not a valid number.");
	return;
}
```

## Pattern 7 — Audit event and explicit result

```csharp
// Use only when this material configuration change belongs in end-user audit history.
engine.GenerateInformation("Provision|Element configuration changed.");

// Omit this when natural successful return is sufficient.
engine.ExitSuccess("Provisioning completed.");
```

Use `engine.Log("Method|detail")` sparingly for non-sensitive diagnostics. Never send tracing, counts/missing keys, per-item output, exception details, or secrets through `GenerateInformation`.

## Pattern 8 — Run another script (sub-script)

```csharp
// Verify API for your DM version before use.
SubScriptOptions sub = engine.PrepareSubScript("OtherScriptName");
sub.SelectScriptParam("paramName", "value");
sub.StartScript();
```

## Pattern 9 — Consume an external async-only API synchronously

```csharp
private static string ReadExternalText(System.Net.Http.HttpClient client, System.Uri endpoint)
{
	return client.GetStringAsync(endpoint).GetAwaiter().GetResult();
}
```

Pass only detached non-DataMiner inputs, keep only plain detached output, and continue all Engine work on the `Run` thread. Never pass or capture `engine`, `Element`, dummy, script parameter/memory, sub-script, or `IDms` objects. Do not use `Task.Run`, parallel loops, or manual threads.

---

### Reminders
- Keep the synchronous `Run` → `RunSafe` wrapper and rethrow abort/force-abort/timeout/detach exceptions.
- Every `GetScriptParam(id)` must have a matching `<ScriptParameter id="...">` in the XML.
- `net48` / C# 7.3 — no nullable reference types.
