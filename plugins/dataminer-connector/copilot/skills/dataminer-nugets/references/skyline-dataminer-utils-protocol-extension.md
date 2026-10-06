# Skyline.DataMiner.Utils.Protocol.Extension

## Purpose

`Skyline.DataMiner.Utils.Protocol.Extension` provides high-level extension methods for common low-level `SLProtocol` operations. Use it when the wrapper improves readability, type safety, or batching of protocol calls.

Official API docs: https://aka.dataminer.services/skyline-data-miner-utils-protocol-extension

Source: https://github.com/SkylineCommunications/SLC-S-ProtocolExtension

NuGet: https://www.nuget.org/packages/Skyline.DataMiner.Utils.Protocol.Extension

## When To Use

| Use case | Decision |
|----------|----------|
| Bulk standalone parameter sets from a dictionary | Use `SetParameters`. |
| Bulk table column updates from dictionaries/lists | Use `SetColumns`. |
| Read multiple table columns by 0-based column indexes | Use `GetColumns`. |
| Read one table column by 0-based column index | Use `GetColumn`. |
| Read or set one cell by primary key and 0-based column index | Use `GetCell` or `SetCell`. |
| Delete many rows by primary key | Use `DeleteRows`. |
| Trigger a protocol action by ID | Use `RunAction`. |
| One ordinary `GetParameter` or `SetParameter` | Do not add this package just for that. |

## Package Facts

| Item | Value |
|------|-------|
| Current observed version | `1.0.0.4` |
| Target framework | `.NET Framework 4.6.2+` |
| Main namespace | `Skyline.DataMiner.Utils.Protocol.Extension` |
| Main class | `ProtocolExtension` |
| Dependency | `Skyline.DataMiner.Dev.Protocol >= 10.2.0.25` |

## Common PackageReference

```xml
<PackageReference Include="Skyline.DataMiner.Utils.Protocol.Extension" Version="1.0.0.4" />
```

## Extension Methods

| Method | Use | Notes |
|--------|-----|-------|
| `DeleteRows(this SLProtocol, int tablePid, IEnumerable<object> keysToDelete)` | Delete multiple rows. | Values are cast to `string`; pass string keys when possible. |
| `DeleteRows(this SLProtocol, int tablePid, IEnumerable<string> keysToDelete)` | Delete multiple rows. | Returns immediately for empty collections. |
| `GetCell(this SLProtocol, int tablePid, string rowPK, int columnIdx)` | Get one cell. | `columnIdx` is 0-based and converted internally to 1-based. Returns `null` for uninitialized cells. |
| `GetColumn(this SLProtocol, int tablePid, uint columnIdx)` | Get one table column. | `columnIdx` is 0-based. |
| `GetColumns(this SLProtocol, int tablePid, IEnumerable<uint> columnsIdx)` | Get multiple table columns. | `columnsIdx` are 0-based. Returns an empty object array for no columns. |
| `RunAction(this SLProtocol, int actionId)` | Run a protocol action. | Wraps `NotifyProtocol(221/*NT_RUN_ACTION*/, actionId, null)`. |
| `SetCell(this SLProtocol, int tablePid, string rowPK, int columnIdx, object value, DateTime? dateTime = null)` | Set one cell. | `columnIdx` is 0-based. `null` clears the cell. Primary key cannot be updated. |
| `SetColumns(this SLProtocol, IList<int> columnsPid, IReadOnlyList<IEnumerable<object>> columnsValues, DateTime? dateTime = null)` | Set multiple columns. | First PID must be the table PID and first values collection must contain primary keys. Do not provide the primary key column PID. |
| `SetColumns(this SLProtocol, IDictionary<int, List<object>> setColumnsData, DateTime? dateTime = null)` | Set multiple columns from a dictionary. | First dictionary item must contain the table PID as key and primary keys as values. |
| `SetParameters(this SLProtocol, IDictionary<int, object> paramsToSet, DateTime? dateTime = null)` | Set multiple standalone parameters. | Uses `SLProtocol.SetParameters` internally. |

## Required Using

```csharp
using Skyline.DataMiner.Utils.Protocol.Extension;
```

## SetParameters Pattern

```csharp
var paramsToSet = new Dictionary<int, object>
{
    { Parameter.status, 1 },
    { Parameter.message, "Updated" },
};

protocol.SetParameters(paramsToSet);
```

## SetColumns Dictionary Pattern

The first dictionary item must be the table PID with the primary keys. The remaining keys are column PIDs.

```csharp
var rowsToSet = new Dictionary<int, List<object>>
{
    { Parameter.Streams.tablePid, new List<object>() },
    { Parameter.Streams.Pid.streamsbitrate, new List<object>() },
    { Parameter.Streams.Pid.streamsbitratedata, new List<object>() },
};

rowsToSet[Parameter.Streams.tablePid].Add("stream-1");
rowsToSet[Parameter.Streams.Pid.streamsbitrate].Add(125000.0);
rowsToSet[Parameter.Streams.Pid.streamsbitratedata].Add(serializedRateHelper);

protocol.SetColumns(rowsToSet);
```

## GetColumns Pattern

```csharp
object[] columns = protocol.GetColumns(
    Parameter.Streams.tablePid,
    new uint[]
    {
        (uint)Parameter.Streams.Idx.streamsindex,
        (uint)Parameter.Streams.Idx.streamsbitrate,
    });

object[] keys = (object[])columns[0];
object[] rates = (object[])columns[1];
```

## SetCell Pattern

```csharp
bool changed = protocol.SetCell(
    Parameter.Streams.tablePid,
    "stream-1",
    Parameter.Streams.Idx.streamsbitrate,
    125000.0);
```

## DeleteRows Pattern

```csharp
protocol.DeleteRows(Parameter.Streams.tablePid, new[] { "stream-1", "stream-2" });
```

## Index And PID Rules

| Concept | Rule |
|---------|------|
| `columnIdx` in `GetCell`, `GetColumn`, `GetColumns`, `SetCell` | 0-based table column index matching generated `Parameter.Table.Idx.*` values. |
| `columnsPid` in `SetColumns` | Column parameter IDs, not indexes. The first item is the table PID. |
| Dictionary order for `SetColumns` | In .NET Framework, `Dictionary` enumeration preserves insertion order in common practice but this is not a semantic guarantee. Keep construction explicit and avoid transformations that can reorder items. |
| Primary key column | Do not include the primary key column PID in `SetColumns`; provide primary keys under the table PID entry. |

## Pitfalls

| Pitfall | Correct handling |
|---------|------------------|
| Passing 1-based column positions to `SetCell` or `GetCell` | Pass 0-based `Idx` values. The wrapper adds 1 internally. |
| Mismatched column list lengths in `SetColumns` | Ensure every value list has the same row count. |
| Empty collections | Methods may return without doing anything. This is intentional. |
| Adding the package for trivial reads/sets | Use built-in `SLProtocol` methods unless these wrappers materially improve the code. |
| Confusing table PID with primary key column PID | Use table PID for the first `SetColumns` key. |

## Verification

```bash
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>"
```
