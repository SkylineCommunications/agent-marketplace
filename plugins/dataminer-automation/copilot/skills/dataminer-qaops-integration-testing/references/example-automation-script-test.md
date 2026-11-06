# Worked Example: Test an Automation Script Against Real Elements

Canonical example for the request pattern: *"Test if my Automation script correctly stops all the elements of the &lt;protocol name&gt; protocol."*

Follow this example for any test that must run an Automation script on a real DataMiner and assert resulting element, service, view, or parameter state.

> **Before writing the test**: load `dataminer-qaops-integration-testing/references/system-state-preflight.md`. QAOps DaaS systems ship with pre-installed baseline content (e.g. a Microsoft Platform element + connector in a version range you do not control). Every test starts by snapshotting the elements of the target protocol (names, IDs, protocol versions, states), logging that snapshot, and embedding it in every assertion message. This example's script stops **all** elements of the protocol, so pre-existing baseline elements are deliberately *incorporated into expectations* (they are part of the target set and get restored in cleanup) — that is the "mirror interfering artifacts into expectations" policy from the preflight reference.

All APIs below are verified against `Skyline.DataMiner.Core.DataMinerSystem.Common`:

```text
https://docs.dataminer.services/develop/api/types/Skyline.DataMiner.Core.DataMinerSystem.Common.html
```

## Scenario Breakdown

| Step | What | How |
|------|------|-----|
| Prerequisite | The Automation script is on the test DataMiner | Same-solution Automation script projects are included in the Test Package by default (see `test-package-prerequisites.md`) |
| Prerequisite | The connector (e.g. Microsoft Platform) is on the test DataMiner | Add it from the Catalog by Catalog ID (see `test-package-prerequisites.md`); note a DaaS baseline version may *also* be present |
| Arrange | Snapshot system state; elements of the target protocol exist and are active | Snapshot per `system-state-preflight.md`; create test-owned elements with `IDma.CreateElement(ElementConfiguration)` when the scenario needs more |
| Act | Run the Automation script | `dms.GetScript(name).Execute(...)` |
| Assert | All target elements are stopped | Poll `IDmsElement.State` until `ElementState.Stopped` or timeout |
| Cleanup | Restore created/changed state | Start stopped elements again; delete elements the test created |

## Key APIs

| Need | API |
|------|-----|
| Find a script | `IDms.GetScript(string name)` / `IDms.ScriptExists(string name)` |
| Run a script | `IDmsAutomationScript.Execute(IEnumerable<DmsAutomationScriptParamValue>, IEnumerable<DmsAutomationScriptDummyValue>, DmsAutomationScriptRunOptions)` |
| All elements | `IDms.GetElements()` |
| Element's protocol | `IDmsElement.Protocol` (`IDmsProtocol`, has `Name` and `Version`) |
| Element state | `IDmsElement.State` (`ElementState`: `Active`, `Paused`, `Stopped`, `Error`, ...) |
| Start/stop element | `IDmsElement.Start()` / `IDmsElement.Stop()` |
| Get a protocol | `IDms.GetProtocol(string name, string version)` |
| Create an element | `IDma.CreateElement(ElementConfiguration)` with `ElementConfiguration(IDms, string, IDmsProtocol)` |
| Get an agent | `IDms.GetAgents()` / `IDms.GetAgent(int id)` |

## Example Test

```csharp
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Skyline.DataMiner.Core.DataMinerSystem.Common;

[TestClass]
[TestCategory("IntegrationTest")]
public class StopElementsScriptTests
{
    private const string ProtocolName = "Microsoft Platform";
    private const string ScriptName = "StopAllMicrosoftPlatformElements";
    private static readonly TimeSpan StateChangeTimeout = TimeSpan.FromMinutes(2);

    [TestMethod]
    public void Execute_StopScript_AllMicrosoftPlatformElementsStopped()
    {
        IDms dms = DmsTestSetup.Dms;

        // Arrange: snapshot the system first (system-state-preflight.md). This script's selection is
        // global ("all elements of the protocol"), so pre-existing baseline elements are part of the
        // target set on purpose — log them and carry the report in every assertion message.
        List<IDmsElement> targetElements = dms.GetElements()
            .Where(e => String.Equals(e.Protocol.Name, ProtocolName, StringComparison.OrdinalIgnoreCase))
            .ToList();

        string stateReport = $"Elements of '{ProtocolName}' on the system:" + Environment.NewLine + "  " + String.Join(
            Environment.NewLine + "  ",
            targetElements.Select(e => $"'{e.Name}' ({e.AgentId}/{e.Id}) version '{e.Protocol.Version}' state {e.State}"));
        Console.WriteLine(stateReport);

        Assert.AreNotEqual(0, targetElements.Count, $"No elements of protocol '{ProtocolName}' exist on the test DataMiner. This test creates its own elements below when none exist (Empty-System Contract) — this assert only fires after creation failed.");

        foreach (IDmsElement element in targetElements.Where(e => e.State == ElementState.Stopped))
        {
            element.Start();
        }

        foreach (IDmsElement element in targetElements)
        {
            WaitForState(dms, element, ElementState.Active);
        }

        // Act: run the Automation script under test.
        Assert.IsTrue(dms.ScriptExists(ScriptName), $"Automation script '{ScriptName}' was not found on the test DataMiner.");
        IDmsAutomationScript script = dms.GetScript(ScriptName);
        script.Execute(
            Enumerable.Empty<DmsAutomationScriptParamValue>(),
            Enumerable.Empty<DmsAutomationScriptDummyValue>(),
            new DmsAutomationScriptRunOptions());

        // Assert: every element of the protocol must reach the Stopped state.
        foreach (IDmsElement element in targetElements)
        {
            WaitForState(dms, element, ElementState.Stopped);
        }

        // Cleanup: restore the elements for subsequent tests.
        foreach (IDmsElement element in targetElements)
        {
            element.Start();
        }
    }

    private static void WaitForState(IDms dms, IDmsElement element, ElementState expected)
    {
        var stopwatch = Stopwatch.StartNew();

        while (stopwatch.Elapsed < StateChangeTimeout)
        {
            // Re-fetch to observe the current state instead of a cached snapshot.
            IDmsElement current = dms.GetElement(element.DmsElementId);
            if (current.State == expected)
            {
                return;
            }

            Thread.Sleep(TimeSpan.FromSeconds(5));
        }

        Assert.Fail($"Element '{element.Name}' ({element.AgentId}/{element.Id}, protocol version '{element.Protocol.Version}') did not reach state '{expected}' within {StateChangeTimeout.TotalSeconds} s.");
    }
}
```

## Creating Fixture Elements (Always Create Your Own)

When the test logic targets specific elements, **always create your own fixture element and act on it by identity** — even when elements of the protocol already exist:

```csharp
IDmsProtocol protocol = dms.GetProtocol(ProtocolName, "Production");
IDma agent = dms.GetAgents().First();

string fixtureName = $"IntegrationTest Microsoft Platform {Guid.NewGuid():N}";
DmsElementId createdId = agent.CreateElement(new ElementConfiguration(dms, fixtureName, protocol));

IDmsElement created = dms.GetElement(createdId); // act/assert on createdId, never on "first of protocol"
```

Rules:

- **Never adopt a pre-existing element as the fixture** and never skip creation because elements of the protocol already exist — on QAOps DaaS a baseline element (e.g. Microsoft Platform) is always present, in an uncontrolled version range, and binding to it caused a multi-run debugging spiral once. Existence checks like "create only when none exist" are an anti-pattern.
- **Empty-System Contract**: the test must equally pass when NO element of the protocol exists (empty system + Test Package prerequisites only). Creation is the default path; never turn baseline existence into a precondition (`system-state-preflight.md` → "Empty-System Contract").
- **Serial-connector creation gap** (verified; applies to Core.DataMinerSystem packages ≤1.2.0.x — newer versions derive valid defaults from the protocol, see `dataminer-idms`): on affected versions `ElementConfiguration` rejects every connection variant for serial connectors such as Microsoft Platform (`IncorrectDataException: Invalid connection type provided at index 0`, thrown client-side in the constructor). Fixture fallback: `existing.Duplicate(uniqueName, agent)` when a baseline element exists; on an empty system fail fast naming the library version + gap. Details: `dataminer-idms` cheatsheet → "Creating Elements".
- Use a unique, clearly test-scoped element name (e.g. `IntegrationTest <protocol> <guid>`) so cleanup and identity targeting are unambiguous.
- Record and assert `created.Protocol.Version` when the test uses version-bound data (PID maps from a specific protocol.xml) — the Catalog-installed version and the DaaS baseline version can differ, with different PIDs.
- Wait for the element to become `Active` and `IsStartupComplete()` (poll-wait pattern) before acting on it; element creation and startup are asynchronous.
- Delete created elements in cleanup (`element.Delete()`), even when the test fails — prefer `try/finally` or a `[TestCleanup]` method. Restore pre-existing elements to their snapshot state when the script changed them.
- The connector must already be on the DataMiner: add it as a Catalog prerequisite in the Test Package (see `test-package-prerequisites.md`).
- Verify the exact protocol version to use (`Production` or a specific version) on the test system; do not guess.

## Asynchronous State Rules

- Element start/stop/create operations are **asynchronous**. Never assert immediately; always poll with a timeout.
- Re-fetch the element (`dms.GetElement(...)`) inside the poll loop; cached `IDmsElement` instances do not refresh automatically.
- Use generous timeouts (minutes, not seconds) — QAOps DaaS systems may be slower than local systems.
- Script execution with `Execute(...)` is synchronous for the script run itself, but effects triggered by the script (element state changes) may still complete afterwards.

## Adapting This Example

| User asks to verify | Change |
|---------------------|--------|
| Elements are paused/restarted | Assert `ElementState.Paused` / poll through `Restart()` behavior |
| Script sets parameter values | Use `element.GetStandaloneParameter<T>(pid)` or `element.GetTable(pid)` and assert values |
| Script creates/deletes elements | Compare `dms.GetElements()` snapshots before/after |
| Script with input parameters | Build `DmsAutomationScriptParamValue` entries instead of `Enumerable.Empty<...>()` |
| Alarm behavior | Use `element.GetAlarmLevel()` / alarm count methods |

For APIs not listed here, consult the official namespace documentation before use — do not invent members.
