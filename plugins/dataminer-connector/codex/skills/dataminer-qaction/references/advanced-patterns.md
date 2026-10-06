# Advanced QAction Patterns

Reference for inter-element communication, custom table context menus, multithreaded timer QActions, InterApp calls, DSI middleware, and common NuGet packages.

> **Parent skill**: `dataminer-qaction/SKILL.md` — return there for core QAction rules, table fill methods, and SLProtocol API.

---

## Inter-Element Communication

### Read Parameter from Another Element

```csharp
// Get DMA ID and Element ID (usually from user-configured parameters)
int dmaId = Convert.ToInt32(protocol.GetParameter(Parameter.targetdmaid));
int elementId = Convert.ToInt32(protocol.GetParameter(Parameter.targetelementid));

// Read a parameter from another element
object value = protocol.GetParameterByData(
    Parameter.targetparamid,  // param ID to read
    dmaId,
    elementId);
```

### Set Parameter on Another Element

```csharp
protocol.SetParameterByData(
    Parameter.targetparamid,  // param ID to set
    dmaId,
    elementId,
    newValue);
```

### SLNet Messages (Advanced)

For complex cross-element operations, use SLNet directly:

```csharp
using Skyline.DataMiner.Net;
using Skyline.DataMiner.Net.Messages;

var request = new GetParameterMessage(dmaId, elementId, paramId);
var response = (GetParameterResponseMessage)protocol.SLNet.SendSingleResponseMessage(request);
object value = response.Value.InteropValue;
```

> SLNet is powerful but tightly coupled to DataMiner internals. Prefer SLProtocol methods when possible.

Reference: https://aka.dataminer.services/advanced-inter-element-communication

---

## Custom Table Context Menu

Context menus allow users to right-click table rows and trigger QAction logic.

### XML Side

Define a write parameter for the context menu and link it to the table:

```xml
<Param id="1099" trending="false" save="false">
  <Name>interfaceTableContextMenu</Name>
  <Description>Interface Table Context Menu</Description>
  <Type>write</Type>
  <Interprete><RawType>other</RawType><Type>string</Type><LengthType>next param</LengthType></Interprete>
  <Display><RTDisplay>true</RTDisplay></Display>
  <Measurement>
    <Type>discreet</Type>
    <Discreets>
      <Discreet>
        <Display>Delete Row</Display>
        <Value>delete</Value>
      </Discreet>
      <Discreet>
        <Display>Refresh</Display>
        <Value>refresh</Value>
      </Discreet>
    </Discreets>
  </Measurement>
</Param>
```

Add `options="tab=columns:...,filter:true;ctxMenu=1099"` to the table's `<Measurement>`.

### QAction Side

```csharp
public static void Run(SLProtocol protocol)
{
    try
    {
        string contextData = Convert.ToString(protocol.GetParameter(Parameter.Write.interfacetablecontextmenu));
        // Format: "action:primaryKey" or depends on configuration
        string[] parts = contextData.Split(':');
        string action = parts[0];
        string rowKey = parts.Length > 1 ? parts[1] : String.Empty;

        switch (action)
        {
            case "delete":
                protocol.DeleteRow(Parameter.Interfacestable.tablePid, rowKey);
                break;
            case "refresh":
                // Trigger a poll group
                protocol.CheckTrigger(1);
                break;
        }
    }
    catch (Exception ex)
    {
        protocol.Log($"QA{protocol.QActionID}|Run|Error: {ex}", LogType.Error, LogLevel.NoLogging);
    }
}
```

> Consider using `Skyline.DataMiner.Utils.Table.ContextMenu` NuGet for a structured approach.

Reference: https://aka.dataminer.services/ui-components-custom-table-context-menu

---

## Multithreaded Timer QActions

QActions triggered by multithreaded timers execute per-row with `row="true"`:

```xml
<QAction id="100" name="ProcessRow" encoding="csharp" options="group" triggers="100" row="true">
```

### Thread Safety

```csharp
private static readonly object lockObj = new object();

public static void Run(SLProtocol protocol)
{
    try
    {
        string rowKey = protocol.RowKey();  // Current row's primary key

        // Thread-safe shared data access
        lock (lockObj)
        {
            // Critical section — get-modify-set on shared data
        }

        // Per-row operations (safe without locking)
        object[] row = (object[])protocol.GetRow(Parameter.Devicestable.tablePid, rowKey);
        // ... process row ...
    }
    catch (Exception ex)
    {
        protocol.Log($"QA{protocol.QActionID}|Run|Error for row {protocol.RowKey()}: {ex}", LogType.Error, LogLevel.NoLogging);
    }
}
```

- Use `protocol.RowKey()` to get the current row's primary key.
- Implement `lock` for any shared state accessed across threads.
- Threads that outlive their QAction are dangerous — avoid fire-and-forget patterns.

Reference: https://aka.dataminer.services/advanced-multithreaded-timers

---

## InterApp Calls (Cross-Element Messaging)

InterApp is a structured message/request-response framework for communication between connectors, Automation scripts, and applications that can reach a DataMiner System. Prefer it over raw SLNet for complex inter-element workflows where both source and destination code can share message DTOs and known types.

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallBulk;
using Skyline.DataMiner.Core.InterAppCalls.Common.Shared;

// MyCustomMessage is a user-defined DTO inheriting from Message.
List<Type> knownTypes = new List<Type> { typeof(MyCustomMessage) };
IInterAppCall call = InterAppCallFactory.CreateNew();
call.Source = new Source("My Connector", protocol.DataMinerID, protocol.ElementID);

var message = new MyCustomMessage { /* properties */ };
call.Messages.Add(message);
call.Send(protocol.SLNet.RawConnection, dmaId, elementId, 9000000, knownTypes);
```

- Add and process receiver/return parameters `9000000` (`interApp_receive`) and `9000001` (`interApp_return`) in receiving connectors.
- Keep message DTOs data-only and keep namespaces/known types equivalent at sender and receiver.
- Implement receiver logic in a QAction triggered by `interApp_receive`; deserialize with `InterAppCallFactory.CreateFromRaw` and execute destination-specific executors.
- For reply flows, follow broker/`ReturnAddress` rules and never use a source-element return parameter while waiting in the same QAction.
- Use NuGet package `Skyline.DataMiner.Core.InterAppCalls.Common`; full lifecycle reference: `dataminer-nugets/references/skyline-dataminer-core-interappcalls-common.md`.

Reference: https://aka.dataminer.services/InterApp

---

## DSI Middleware (OpenConfig / Ember+)

DataMiner supports middleware protocols via the Data Source Interface (DSI):

- **OpenConfig/gNMI**: For network devices supporting OpenConfig YANG models. Uses gRPC-based streaming telemetry.
- **Ember+**: For broadcast/media devices using the Lawo Ember+ protocol.

These are specialized connection types that use dedicated DataMiner middleware components rather than standard serial/HTTP connections. Consult the dedicated documentation when implementing:

- OpenConfig: https://aka.dataminer.services/dsi-open-config
- Ember+: https://aka.dataminer.services/dsi-ember-plus

---

## Common NuGet Packages

Useful `Skyline.DataMiner.Utils` packages available for QAction development. Add to individual QAction `.csproj` files:

```bash
dotnet add QAction_N/QAction_N.csproj package <PackageName>
```

| Package | Description | When to use |
|---------|-------------|-------------|
| `Skyline.DataMiner.Utils.SecureCoding.Analyzers` | Internally-developed Roslyn security analyzer | **Required in ALL QActions** — see `.csproj` snippet below |
| `Newtonsoft.Json` | JSON attributes and token model types | Use with the SecureCoding runtime for HTTP JSON responses; do not deserialize directly |
| `Skyline.DataMiner.Dev.Protocol` | Core `SLProtocol` API | Included by template — always present |
| `Skyline.DataMiner.Utils.Rates.Common` | Non-SNMP rate calculation (counters -> rates): `Rate32OnDateTime`, `Rate64OnDateTime`, `Rate32OnTimeSpan`, `Rate64OnTimeSpan` | HTTP, serial, virtual, or custom counters with DateTime/TimeSpan timing |
| `Skyline.DataMiner.Utils.Rates.Protocol` | SNMP rate calculation: `SnmpRate32`, `SnmpRate64` | SNMP counters using `SnmpDeltaHelper` and timeout delta buffering |
| `Skyline.DataMiner.Utils.Table.ContextMenu` | Structured context menu handling | Tables with right-click actions |
| `Skyline.DataMiner.Utils.HTTP` | HTTP helper utilities | Advanced HTTP request building / auth helpers |
| `Skyline.DataMiner.Utils.SNMP` | SNMP helpers: `SnmpDeltaHelper` (group execution delta), `SnmpHelper` (sysUptime / agent restart detection) | SNMP rate calculations, timeout handling, agent restart detection |
| `Skyline.DataMiner.Utils.SafeConverters` | Safe type conversion | Safely parsing values from `protocol.GetParameter` without cast exceptions |
| `Skyline.DataMiner.Utils.UnitTestingFramework` | Unit testing with SLProtocolMock | Test projects only — never in production QActions |
| `Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit` | Interactive Automation script UI | Automation scripts only — not used in connectors |

**`SecureCoding.Analyzers` must be added with `<IncludeAssets>` so it is treated as a build-time-only analyzer reference:**
```xml
<PackageReference Include="Skyline.DataMiner.Utils.SecureCoding.Analyzers" Version="*">
  <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
</PackageReference>
```

Add other packages to individual QAction `.csproj` files:
```xml
<PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
```
