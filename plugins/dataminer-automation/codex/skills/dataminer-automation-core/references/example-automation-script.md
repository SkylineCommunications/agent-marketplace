# Canonical Non-Interactive Automation Script

A complete, **real** Skyline pattern (adapted from `SLC-AS-SetParameter`): read script parameters → resolve an element → set a parameter → return naturally on success. Follow this structure for non-interactive scripts.

> **Parent skill**: `dataminer-automation-core/SKILL.md`. For the C# rules behind it, load `dataminer-automation-scripting`; for the XML half, load `dataminer-automation-xml`.

---

## C# — `<Name>.cs`

```csharp
namespace SLCASSetParameter
{
	using System;
	using System.Globalization;

	using Skyline.DataMiner.Automation;

	/// <summary>
	/// Represents a DataMiner Automation script.
	/// </summary>
	public class Script
	{
		/// <summary>The script entry point.</summary>
		/// <param name="engine">Link with SLAutomation process.</param>
		public void Run(IEngine engine)
		{
			try
			{
				RunSafe(engine);
			}
			catch (ScriptAbortException)
			{
				// Expected termination from an explicit engine.ExitFail / engine.ExitSuccess call.
				throw;
			}
			catch (ScriptForceAbortException)
			{
				throw;
			}
			catch (ScriptTimeoutException)
			{
				throw;
			}
			catch (InteractiveUserDetachedException)
			{
				// Only relevant for interactive scripts; safe to keep.
				throw;
			}
			catch (Exception ex)
			{
				engine.Log("Run|Unexpected exception: " + ex.ToString());
				engine.ExitFail("Runtime operation failed.");
			}
		}

		private static void RunSafe(IEngine engine)
		{
			string elementIdentifier = engine.GetScriptParam(10).Value.Trim().TrimStart('[', '"').TrimEnd('"', ']');
			if (String.IsNullOrWhiteSpace(elementIdentifier))
			{
				engine.ExitFail("Element identifier is required.");
				return;
			}

			string paramIdString = engine.GetScriptParam(11).Value.Trim().TrimStart('[', '"').TrimEnd('"', ']');
			if (!Int32.TryParse(paramIdString, NumberStyles.Integer, CultureInfo.InvariantCulture, out int paramId))
			{
				engine.ExitFail("Parameter identifier must be a valid integer.");
				return;
			}

			string value = engine.GetScriptParam(12).Value.Trim().TrimStart('[', '"').TrimEnd('"', ']');

			Element element = elementIdentifier.Contains("/")
				? engine.FindElementByKey(elementIdentifier)   // "DataMinerID/ElementID"
				: engine.FindElement(elementIdentifier);        // element name

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

			element.SetParameter(paramId, value);
		}
	}
}
```

### Why it is shaped this way

- **Namespace** wraps the class (named after the script). `using` directives sit **inside** the namespace, `System` first. (Different from QActions, where `public class QAction` is at global scope.)
- **`Run` → `RunSafe`** rethrows runtime/detach exceptions. The unexpected handler writes `ex.ToString()` only to `engine.Log` and sends the stable `"Runtime operation failed."` through `ExitFail`.
- **Single-thread runtime** keeps `engine`, the resolved `Element`, and all DataMiner interaction on the original `Run` thread; an async entry point, `Task.Run`, parallel loop, or manual thread must not be used.
- **Validate every input** and fail fast with a concise, stable `engine.ExitFail` message that does not echo possibly sensitive raw input.
- **Resolve the element robustly** (name vs `DmaId/ElementId` key) and check `IsActive`.

---

## XML — `<Name>.xml` (DMSScript)

This skeleton targets DataMiner 10.5.9/10.6.0 or later, where explicit interactivity is supported. Because this script never presents UI, it uses `Never`. For an earlier DataMiner target, omit the unsupported `<Interactivity>` element; legacy automatic detection applies.

```xml
<?xml version="1.0" encoding="utf-8" ?>
<DMSScript options="272" xmlns="http://www.skyline.be/automation">
	<Name>SLC-AS-SetParameter</Name>
	<Description></Description>
	<Type>Automation</Type>
	<Author>MOD, JST</Author>
	<CheckSets>FALSE</CheckSets>
	<Folder></Folder>
	<Interactivity>Never</Interactivity>

	<Protocols>
	</Protocols>

	<Memory>
	</Memory>

	<Parameters>
		<ScriptParameter id="10" type="string" values="">
			<Description>Element Identifier</Description>
		</ScriptParameter>
		<ScriptParameter id="11" type="string" values="">
			<Description>Parameter Identifier</Description>
		</ScriptParameter>
		<ScriptParameter id="12" type="string" values="">
			<Description>Value</Description>
		</ScriptParameter>
	</Parameters>

	<Script>
		<Exe id="1" type="csharp">
			<Value><![CDATA[[Project:SLC-AS-SetParameter]]]></Value>
			<!--<Param type="debug">true</Param>-->
			<Message></Message>
		</Exe>
	</Script>
</DMSScript>
```

The `<Exe>` `<Value>` uses `[Project:<Name>]` so the SDK compiles and links the project — never paste C# inline when using the SDK template. `Auto` is reserved for legacy string-detection compatibility and is not the default for current non-interactive authoring.

> **Why `<Exe id="1">` is valid here — and when you MUST change it:** Every descendant `@id` across the entire DMSScript document (`Protocol`, `File`, `ScriptParameter`, and `Exe`) shares one document-wide namespace. In this example, `<Exe id="1">` does not collide only because the script parameters use `id="10"`, `id="11"`, and `id="12"`. When you add 1-based parameters, dummies, or memory files (`id="1"`, `id="2"`, …) to a scaffolded script, you **must** update the scaffold's `<Exe id="1">` to the next free document-wide ID after the highest used ID (`max + 1`, for example `<Exe id="3" type="csharp">` when parameters `1` and `2` exist). Overlapping `<Exe id>` values make the script fail immediately in DataMiner.
