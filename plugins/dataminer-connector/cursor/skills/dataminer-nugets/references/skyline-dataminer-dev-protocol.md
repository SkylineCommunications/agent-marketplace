# Skyline.DataMiner.Dev.Protocol

## Purpose

`Skyline.DataMiner.Dev.Protocol` is the official DataMiner connector Dev Pack. Use it in connector QAction projects and test projects that need DataMiner protocol APIs such as `SLProtocol` without referencing DLLs from a local DataMiner installation.

Official docs: https://aka.dataminer.services/DataMinerDevPacks

NuGet: https://www.nuget.org/packages/Skyline.DataMiner.Dev.Protocol

## When To Use

| Use case | Decision |
|----------|----------|
| Compiling QAction projects | Add `Skyline.DataMiner.Dev.Protocol`. |
| Compiling generated `QAction_Helper` projects | Add `Skyline.DataMiner.Dev.Protocol`. |
| Unit tests using `SLProtocolMock` with QAction code | Add `Skyline.DataMiner.Dev.Protocol` to the test project. |
| Automation scripts using `IEngine` | Use `Skyline.DataMiner.Dev.Automation`, not `Dev.Protocol`. |
| Direct reference to `C:\Skyline DataMiner\Files\*.dll` | Do not do this when a Dev Pack exists. |

## Package Facts

| Item | Value |
|------|-------|
| Package type | Dev Pack / meta-package |
| Version scheme | `A.B.C.D`, where `A.B.C` matches the DataMiner version and `D` is a revision |
| Current observed package | `10.6.9.1` |
| Target framework group | `.NET Framework 4.6.2` dependencies |
| Runtime installation | Dev Pack assemblies are for development and are not installed as deliverable runtime assemblies |

## Common PackageReference

```xml
<PackageReference Include="Skyline.DataMiner.Dev.Protocol" Version="10.6.9.1" />
```

Match the version to the connector target DataMiner version. Prefer the latest revision for the selected DataMiner version.

## Main Dependencies

Observed for `10.6.9.1`:

| Dependency | Purpose |
|------------|---------|
| `Skyline.DataMiner.Dev.Common` | Shared DataMiner development dependencies. |
| `Skyline.DataMiner.Files.Interop.SLDms` | DataMiner protocol interop assembly. |
| `Skyline.DataMiner.Files.QActionHelperBaseClasses` | Base classes used by generated QAction helpers. |
| `Skyline.DataMiner.Files.SLManagedScripting` | Contains `Skyline.DataMiner.Scripting` APIs such as `SLProtocol`. |

## Common Namespaces And Types

| Namespace | Common types |
|-----------|--------------|
| `Skyline.DataMiner.Scripting` | `SLProtocol`, `LogType`, `LogLevel`, `NotifyProtocol`, `NotifyProtocol.SaveOption`, `NotifyProtocol.KeyType` |

`SLProtocolExt`, `Parameter`, generated table types, and generated row types come from a connector's `QAction_Helper` project, not from the Dev Pack. `GetColumns` and `SetColumns` come from `Skyline.DataMiner.Utils.Protocol.Extension`.

## SLProtocol Essentials

`SLProtocol` allows QAction code to communicate with the SLProtocol process. Its methods are blocking except queued notification methods. Prefer readable wrapper methods over raw `NotifyProtocol` numbers when a wrapper exists.

| Member | Use |
|--------|-----|
| `GetParameter(int)` | Read one standalone parameter. Returns `null` when the PID does not exist; numeric uninitialized standalone parameters may return `0`. |
| `SetParameter(int, object)` | Set one parameter. `null` does not clear a parameter; it keeps the current value. |
| `GetParameters(object)` | Read multiple parameters in one call. |
| `SetParameters(int[], object[])` | Set multiple parameters in one call. Prefer over repeated `SetParameter`. |
| `SetParameters(int[], object[], DateTime[])` | Set multiple parameters with history timestamps. |
| `GetParameterIndexByKey(int, string, int)` | Read a table cell by table PID, primary key, and 1-based column position. |
| `SetParameterIndexByKey(int, string, int, object)` | Set a table cell by table PID, primary key, and 1-based column position. |
| `GetRow(int, string)` | Read a table row by primary key. Prefer string primary key overloads over row-index overloads. |
| `SetRow(int, string, object)` | Set a row by primary key. |
| `AddRow(int, object[])` | Add a row. |
| `DeleteRow(int, string)` | Delete one row. |
| `DeleteRow(int, string[])` | Delete multiple rows. Prefer over loops. |
| `GetKeys(int)` | Read all table primary keys. |
| `Exists(int, string)` | Check if a row exists. |
| `FillArray(int, object[])` | Replace a full table with column-oriented data. |
| `FillArrayNoDelete(int, object[])` | Upsert column-oriented data and keep unlisted rows. |
| `FillArray(int, List<object[]>, NotifyProtocol.SaveOption)` | Set row-oriented data with `Full` or `Partial` behavior. |
| `FillArrayWithColumn(int, int, object[], object[])` | Update one column for multiple rows. |
| `CheckTrigger(int)` | Fire a protocol trigger programmatically. Use XML triggers to start groups. |
| `NotifyProtocol(int, object, object)` | Low-level call to SLProtocol. Prefer typed wrappers unless no wrapper exists. |
| `Log(string, LogType, LogLevel)` | Write DataMiner logging. Use `LogType.Error` and `LogLevel.NoLogging` for caught exceptions that must always be visible. |
| `GetTriggerParameter()` | Get the PID that triggered the current QAction. |
| `SLNet` | Access the SLNet connection, commonly used by InterApp calls. |
| `QActionID` | Current QAction ID, useful in log prefixes. |
| `Clear` | Sentinel used to clear a cell when cell actions are enabled. |
| `Leave` | Sentinel used to preserve a cell when cell actions are enabled. |

Public member documentation:

- [`SLProtocol`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol)
- [`FillArray`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-3c9b855b)
- [`FillArrayNoDelete`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-14a2b9b0)
- [`FillArrayWithColumn`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-718806b5)
- [`SetRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-set-row)
- [`AddRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol-add-row)
- [`DeleteRow`](https://aka.dataminer.services/skyline-data-miner-scripting-sl-protoco-4534d4e6)

## NotifyProtocol.SaveOption

| Value | Behavior |
|-------|----------|
| `NotifyProtocol.SaveOption.Full` | Rows not present in the provided row list are removed. |
| `NotifyProtocol.SaveOption.Partial` | Rows not present in the provided row list are preserved. |

## Table Data Shape Rules

| API | Data shape |
|-----|------------|
| `FillArray(tablePid, object[] columns)` | Column-oriented. Each element is one column value array. |
| `FillArrayNoDelete(tablePid, object[] columns)` | Column-oriented. Each element is one column value array. |
| `FillArray(tablePid, List<object[]> rows, SaveOption)` | Row-oriented. Each list item is a complete row. |
| `SetRow(tablePid, key, object rowData)` | Row-oriented for one primary key. |

## C# Pattern

```csharp
using System;
using Skyline.DataMiner.Scripting;

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            object value = protocol.GetParameter(Parameter.example);
            protocol.SetParameter(Parameter.exampleprocessed, Convert.ToString(value));
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Error: {ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

## Pitfalls

| Pitfall | Correct handling |
|---------|------------------|
| Copying DataMiner assemblies manually | Use `Skyline.DataMiner.Dev.Protocol`. |
| Using `packages.config` | Use `PackageReference`. |
| Many `SetParameter` calls in loops | Use `SetParameters`, table bulk calls, or `Protocol.Extension` wrappers. |
| Assuming `null` clears standalone parameters | `SetParameter(..., null)` keeps the current value. Use supported clear mechanisms. |
| Using local time for history timestamps without considering DST | Prefer UTC where the target API requires UTC, especially rate helpers. |
| Raw `NotifyProtocol` numbers for common operations | Use `SLProtocol` wrapper methods or `Protocol.Extension` for readability and type safety. |
| Casting to `SLProtocolExt` | When using generated helper properties or tables, change the entry point parameter directly to `SLProtocolExt protocol` (no casting). Call built-in table methods directly on `protocol`. |
| Calling `GetColumns`/`SetColumns` without their package | Add `Skyline.DataMiner.Utils.Protocol.Extension` and import its namespace. |

## Verification

```bash
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>"
```
