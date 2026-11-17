# Polling Manager Example Connector

**Source**: https://github.com/SkylineCommunications/SLC-C-Example_Polling-Manager  
**Branch**: `1.0.0.X`  
**Connector Name**: Skyline Example Polling Manager  
**Type**: `virtual` (with `relativeTimers="true"`)

This is the **authoritative reference implementation** for the Polling Manager pattern. When implementing a polling manager, clone this repo's approach and adapt it to your connector.

---

## Repository Structure

```
├── protocol.xml                          # Full connector XML
├── QAction_1/                            # Precompiled shared library
│   └── PollingManager/
│       ├── GenericAPI/                   # Reusable framework (copy as-is)
│       │   ├── PollingManager.cs         # Core polling logic
│       │   ├── PollingManagerContainer.cs# Singleton container
│       │   ├── Pollable/
│       │   │   ├── IPollable.cs          # Interface
│       │   │   ├── PollableBase.cs       # Abstract base
│       │   │   ├── GenericPoll.cs        # Default impl
│       │   │   └── PollingManagerConfigurationBase.cs
│       │   ├── Handlers/                 # Response handler base
│       │   ├── Enums/                    # AdminState, PollStatus, Column, etc.
│       │   ├── Exceptions/               # PollingException
│       │   ├── Extensions/               # Helper extensions
│       │   ├── Structs/                  # Dependency struct
│       │   └── ClearParameters/          # Clear parameter base
│       └── CustomCode/                   # Connector-specific (customize this)
│           ├── Configuration/
│           │   ├── PollEntry.cs          # Enum of data sets
│           │   └── PollingManagerConfiguration.cs
│           ├── PollEntrys/               # Custom PollableBase subclasses
│           ├── ResponseHandlers/         # Per-data-set response handlers
│           └── ClearParameters/          # Per-data-set clear param configs
├── QAction_2/                            # After Startup
├── QAction_990/                          # Timer-driven process loop
├── QAction_997/                          # Context menu handler
├── QAction_1050/                         # Row set handler (interval/status/poll)
├── QAction_61000/                        # Response processor
└── QAction_Helper/                       # Auto-generated helper
```

---

## Key Code Examples

### QAction 2 — After Startup (Initialization)

```csharp
using Skyline.DataMiner.PollingManager;
using Skyline.DataMiner.Scripting;

public static class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            PollingManagerContainer.InitiateManagerAfterStartup(protocol);
        }
        catch (Exception ex)
        {
            protocol.Log(
                $"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|After Startup|Exception thrown:{Environment.NewLine}{ex}",
                LogType.Error,
                LogLevel.NoLogging);
        }
    }
}
```

### QAction 990 — Process Loop (Timer Tick)

```csharp
using Skyline.DataMiner.PollingManager;
using Skyline.DataMiner.Scripting;

public static class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            PollingManagerContainer
                .GetManager(protocol)
                .CheckForUpdate();
        }
        catch (Exception ex)
        {
            protocol.Log(
                $"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Polling Manager - Process|Exception thrown:{Environment.NewLine}{ex}",
                LogType.Error,
                LogLevel.NoLogging);
        }
    }
}
```

### QAction 997 — Context Menu

```csharp
using Skyline.DataMiner.PollingManager;
using Skyline.DataMiner.Scripting;

public static class QAction
{
    public static void Run(SLProtocol protocol, object contextMenu)
    {
        try
        {
            PollingManagerContainer
                .GetManager(protocol)
                .HandleContextMenu(contextMenu);
        }
        catch (Exception ex)
        {
            protocol.Log(
                $"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Polling Manager - Context Menu|Exception thrown:{Environment.NewLine}{ex}",
                LogType.Error,
                LogLevel.NoLogging);
        }
    }
}
```

### QAction 1050 — Row Sets (Interval, Admin Status, Poll Button)

```csharp
using Skyline.DataMiner.PollingManager;
using Skyline.DataMiner.Scripting;
using Skyline.Protocol.PollingManager.GenericAPI.Enums;
using Skyline.Protocol.PollingManager.GenericAPI.Extensions;

public static class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            Trigger trigger = (Trigger)protocol.GetTriggerParameter();
            object value = protocol.GetParameter((int)trigger);
            string rowId = protocol.RowKey();

            PollingManagerContainer
                .GetManager(protocol)
                .HandleRowUpdate(rowId, trigger.ToColumn(), value);
        }
        catch (Exception ex)
        {
            protocol.Log(
                $"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Polling Manager - Sets|Exception thrown:{Environment.NewLine}{ex}",
                LogType.Error,
                LogLevel.NoLogging);
        }
    }
}
```

### QAction 61000 — Response Processing

```csharp
using Skyline.DataMiner.PollingManager;
using Skyline.DataMiner.Scripting;

public static class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            int trigger = protocol.GetTriggerParameter();
            PollingManagerContainer.GetManager(protocol).ProcessResponse(trigger);
        }
        catch (Exception ex)
        {
            protocol.Log(
                $"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Polling Manager - Responses|Exception thrown:{Environment.NewLine}{ex}",
                LogType.Error,
                LogLevel.NoLogging);
        }
    }
}
```

---

## PollingManagerContainer (Singleton Pattern)

```csharp
namespace Skyline.DataMiner.PollingManager
{
    using System;
    using System.Collections.Concurrent;
    using Skyline.DataMiner.Scripting;

    public static class PollingManagerContainer
    {
        private static readonly ConcurrentDictionary<string, PollingManager> Managers =
            new ConcurrentDictionary<string, PollingManager>();

        public static PollingManager GetManager(SLProtocol protocol)
        {
            if (!TryGetManager(protocol, out PollingManager manager))
            {
                return AddManager(protocol, new PollingManagerConfiguration(protocol));
            }
            manager.Protocol = protocol;
            return manager;
        }

        public static PollingManager InitiateManagerAfterStartup(SLProtocol protocol)
        {
            if (TryGetManager(protocol, out _))
            {
                protocol.Log("Polling manager for element already exists. Reinitializing manager",
                    LogType.Information, LogLevel.NoLogging);
                TryRemoveInstance(protocol);
            }
            return AddManager(protocol, new PollingManagerConfiguration(protocol));
        }

        public static bool TryRemoveInstance(SLProtocol protocol)
        {
            return Managers.TryRemove(GetKey(protocol), out _);
        }

        private static PollingManager AddManager(SLProtocol protocol,
            PollingManagerConfigurationBase configuration)
        {
            string key = GetKey(protocol);
            if (!Managers.ContainsKey(key))
            {
                configuration.Create();
                var manager = new PollingManager(protocol, Parameter.Pollingmanager.tablePid, configuration);
                Managers.TryAdd(key, manager);
            }
            Managers[key].Protocol = protocol;
            return Managers[key];
        }

        private static string GetKey(SLProtocol protocol)
        {
            return string.Join("/", protocol.DataMinerID, protocol.ElementID);
        }

        private static bool TryGetManager(SLProtocol protocol, out PollingManager manager)
        {
            return Managers.TryGetValue(GetKey(protocol), out manager);
        }
    }
}
```

---

## PollingManagerConfiguration (Custom Code — Adapt Per Connector)

```csharp
namespace Skyline.Protocol.PollingManager.CustomCode.Configuration
{
    using System.Collections.Generic;
    using Skyline.DataMiner.PollingManager;
    using Skyline.DataMiner.Scripting;
    using Skyline.Protocol.PollingManager.GenericAPI.Handlers;

    public class PollingManagerConfiguration : PollingManagerConfigurationBase
    {
        public PollingManagerConfiguration(SLProtocol protocol) : base(protocol)
        {
            Dependencies = new List<Dependency>();
            ResponseHandlers = new Dictionary<int, ResponseHandler>();
            Rows = CreateRows(protocol);
        }

        public override Dictionary<int, ResponseHandler> ResponseHandlers { get; }
        protected override List<Dependency> Dependencies { get; }
        protected override Dictionary<PollEntrys, PollableBase> Rows { get; }

        protected override void CreateClearParameterRelations()
        {
            // Link parameters/tables to poll entries for clearing on disable
            var system = GetRequiredRow(PollEntrys.System, "System row required.");
            ClearParametersConfiguration.SystemInfo.ApplyToRow(system);
        }

        protected override void CreateDependencies()
        {
            // Example: System data set only polls when API version == "Version2"
            var apiDependency = new Dependency("Version2", true, "Only supported in API version 2.0");
            var systemRow = GetRequiredRow(PollEntrys.System, "System row missing.");
            systemRow.AddDependency(Parameter.apiversion_5, apiDependency);
        }

        protected override void CreateRelations()
        {
            // Parent/child: disabling parent warns about children
            var vlan = GetRequiredRow(PollEntrys.VLAN, "VLAN row required.");
            var interfaces = GetRequiredRow(PollEntrys.Interfaces, "Interfaces row required.");
            var pvst = GetRequiredRow(PollEntrys.PVST, "PVST row required.");
            vlan.AddChildren(pvst);
            interfaces.AddChildren(pvst);
        }

        protected override void CreateResponseHandlers()
        {
            // Map process parameter IDs to response handler classes
            ResponseHandlers.Add(Parameter.processsysteminformation_61001,
                new ResponseSystemInformation(PollEntrys.System));
            ResponseHandlers.Add(Parameter.processtemperatureinformation_61002,
                new ResponseTemperature(PollEntrys.Temperature));
        }

        private static Dictionary<PollEntrys, PollableBase> CreateRows(SLProtocol protocol)
        {
            return new Dictionary<PollEntrys, PollableBase>
            {
                { PollEntrys.APIVersion, new GenericPoll(protocol, "[Mandatory] API Information") { Mandatory = true } },
                { PollEntrys.System, new GenericPoll(protocol, "[Dependency] System Information (API 2.0)", 60_001) },
                { PollEntrys.VLAN, new VlanInformation(protocol, "[Parent] VLAN Information") },
                { PollEntrys.Temperature, new GenericPoll(protocol, "[Fail] Temperature Information", 60_002) },
                { PollEntrys.CPU, new CpuInformationPoll(protocol, "[Basic] CPU Information") },
                { PollEntrys.Interfaces, new InterfaceInformation(protocol, "[Parent] Interface Information") },
                { PollEntrys.PVST, new PvstVlanInformation(protocol, "[Child] VLAN - Interfaces - PVST+") },
            };
        }
    }
}
```

---

## PollEntry Enum (Define Your Data Sets)

```csharp
namespace Skyline.Protocol.PollingManager.CustomCode.Configuration
{
    public enum PollEntrys
    {
        APIVersion,
        System,
        VLAN,
        Temperature,
        CPU,
        Interfaces,
        PVST,
    }
}
```

---

## GenericPoll (Default PollableBase Implementation)

```csharp
namespace Skyline.Protocol.PollingManager.CustomCode.Configuration
{
    using Skyline.DataMiner.PollingManager;
    using Skyline.DataMiner.Scripting;

    public class GenericPoll : PollableBase
    {
        public GenericPoll(SLProtocol protocol, string description)
            : base(protocol, description) { }

        public GenericPoll(SLProtocol protocol, string description, int triggerID)
            : base(protocol, description, triggerID) { }

        protected override void Poll()
        {
            // Custom poll logic for in-code processing (TriggerId == 0)
            Protocol.Log($"Polling '{Name}'.");
        }

        protected override void PrePollConfiguration()
        {
            // Pre-poll setup (e.g., set API version header before HTTP call)
        }
    }
}
```

---

## XML Protocol Snippet — Core Polling Manager Elements

### Timer + Process Group

```xml
<Timers>
    <Timer id="1" fixedTimer="true">
        <Name>Very Fast Timer (1s)</Name>
        <Time initial="false">1000</Time>
        <Interval>75</Interval>
        <Content>
            <Group>990</Group>
        </Content>
    </Timer>
</Timers>

<Groups>
    <Group id="990">
        <Name>PollingManager_Process</Name>
        <Description>Polling Manager - Process</Description>
        <Type>action</Type>
        <Content>
            <Action>990</Action>
        </Content>
    </Group>
</Groups>

<Actions>
    <Action id="990">
        <Name>Polling Manager - Process</Name>
        <On id="990">parameter</On>
        <Type>run actions</Type>
    </Action>
</Actions>
```

### Per-Data-Set Trigger Chain (Example: System Information)

```xml
<!-- Poll Group (executed by CheckTrigger from C#) -->
<Group id="60001">
    <Name>PollingManager_Poll_System_Information</Name>
    <Description>Poll System Information</Description>
    <Content>
        <!-- Add Session or Pair here for actual device communication -->
    </Content>
</Group>

<!-- Trigger to execute the poll group -->
<Trigger id="60001">
    <Name>Polling Manager - Poll System Information</Name>
    <Type>action</Type>
    <Content>
        <Id>60001</Id>
    </Content>
</Trigger>

<!-- After-group trigger for response processing -->
<Trigger id="61001">
    <Name>Process Poll System Information</Name>
    <On id="60001">group</On>
    <Time>after</Time>
    <Type>action</Type>
    <Content>
        <Id>61001</Id>
    </Content>
</Trigger>

<!-- Action to execute poll group -->
<Action id="60001">
    <Name>Polling Manager - Poll System Information</Name>
    <On id="60001">group</On>
    <Type>execute one</Type>
</Action>

<!-- Action to run response QAction -->
<Action id="61001">
    <Name>Polling Manager - Process Poll System Information</Name>
    <On id="61001">parameter</On>
    <Type>run actions</Type>
</Action>

<!-- Process parameter (triggers QAction 61000) -->
<Param id="61001">
    <Name>ProcessSystemInformation</Name>
    <Description>Process System Information</Description>
    <Type>read</Type>
    <Interprete>
        <RawType>other</RawType>
        <LengthType>next param</LengthType>
        <Type>string</Type>
    </Interprete>
</Param>
```

### Context Menu Parameter

```xml
<Param id="997">
    <Name>PollingManager_ContextMenu</Name>
    <Description>Context Menu for Polling Manager</Description>
    <Type>write</Type>
    <Interprete>
        <RawType>numeric text</RawType>
        <Type>double</Type>
        <LengthType>next param</LengthType>
    </Interprete>
    <Display>
        <RTDisplay>true</RTDisplay>
    </Display>
    <Measurement>
        <Type width="110">button</Type>
        <Discreets>
            <Discreet options="table:selection">
                <Display>Enable</Display>
                <Value>1</Value>
            </Discreet>
            <Discreet options="table:selection">
                <Display>Enable (Forced)</Display>
                <Value>2</Value>
            </Discreet>
            <Discreet options="table:selection">
                <Display>Disable</Display>
                <Value>3</Value>
            </Discreet>
            <Discreet options="table:selection">
                <Display>Disable (Forced)</Display>
                <Value>4</Value>
            </Discreet>
            <Discreet options="table:selection">
                <Display>Poll</Display>
                <Value>5</Value>
            </Discreet>
            <Discreet options="separator">
                <Display>Separator 1</Display>
                <Value>-1</Value>
            </Discreet>
            <Discreet>
                <Display>Enable All</Display>
                <Value>11</Value>
            </Discreet>
            <Discreet>
                <Display>Disable All</Display>
                <Value>12</Value>
            </Discreet>
            <Discreet>
                <Display>Poll All</Display>
                <Value>13</Value>
            </Discreet>
            <Discreet options="separator">
                <Display>Separator 2</Display>
                <Value>-2</Value>
            </Discreet>
            <Discreet options="table:selection">
                <Display>Reset to Default</Display>
                <Value>21</Value>
            </Discreet>
        </Discreets>
    </Measurement>
</Param>
```

### QAction Declarations

```xml
<QActions>
    <QAction id="1" name="Precompiled Code" encoding="csharp" options="precompile" />
    <QAction id="2" name="After Startup" encoding="csharp" triggers="2" />
    <QAction id="990" name="Polling Manager - Process" encoding="csharp" triggers="990" />
    <QAction id="997" name="Polling Manager - ContextMenu" encoding="csharp" triggers="997" />
    <QAction id="1050" name="Polling Manager - Sets" encoding="csharp" triggers="1054;1056;1057" row="true" />
    <QAction id="61000" name="Polling Manager - Responses" encoding="csharp" triggers="61001;61002" />
</QActions>
```

---

## Adaptation Checklist

When adapting this example to your connector:

1. **Define your data sets** in `PollEntry.cs` enum
2. **Choose poll type per data set**: trigger-based (needs group/trigger chain) vs in-code (TriggerId=0)
3. **Set suggested intervals** per data set (default polling period in seconds)
4. **Configure dependencies** if any data set depends on a parameter value
5. **Configure parent/child relations** if disabling one should warn about others
6. **Mark mandatory rows** that cannot be disabled
7. **Implement response handlers** for trigger-based data sets
8. **Implement clear-parameter logic** to reset params/tables when disabled
9. **Adjust parameter IDs** to fit your connector's ID scheme
10. **Add poll groups** with appropriate content (HTTP sessions, SNMP pairs, etc.)
