# Raw NotifyProtocol / NotifyDataMinerQueued Calls

> **Parent skill**: `dataminer-qaction/SKILL.md` — return there for wrapper methods, table fill patterns, and SLProtocol API.

Modern code should prefer typed wrapper methods (`FillArray`, `FillArrayNoDelete`, `FillArrayWithColumn`, `RunAction`, `GetColumns`) over raw numeric calls. Use raw calls only when maintaining legacy code or when no wrapper exists (127, 128).

---

## NotifyDataMinerQueued Calls

These calls use `protocol.NotifyDataMinerQueued(type, ...)` — a different call path from `NotifyProtocol`. They communicate with SLDataMiner rather than SLProtocol.

### 127 — NT_UPDATE_DESCRIPTION_XML

Adjusts parameter settings at runtime: description text, unit, range boundaries, step size.

**Signature:**
```csharp
int result = (int)protocol.NotifyDataMinerQueued(127/*NT_UPDATE_DESCRIPTION_XML*/, elementDetails, updates);
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `elementDetails` | `uint[]` | `[0]` = Agent ID, `[1]` = Element ID |
| `updates` | `object[]` | Array of `string[]` update entries |

Each update entry is a `string[]` with three elements:

| Index | Content |
|-------|---------|
| `[0]` | Update type (see table below) |
| `[1]` | New value |
| `[2]` | Parameter ID |

**Update types:**

| Type | What it changes |
|------|-----------------|
| `1` | Description |
| `2` | Unit (requires DataMiner 10.2.5 / 10.3.0+) |
| `3` | Range low |
| `4` | Range high |
| `5` | Step size |

**Return:** `0` on success.

**Example — change description and range of two parameters:**
```csharp
uint agentId = (uint)protocol.DataMinerID;
uint elementId = (uint)protocol.ElementID;
uint[] elementDetails = new uint[] { agentId, elementId };

string[] updateDescription = new string[] { "1", "Main Device A", "10" };
string[] updateRangeLow = new string[] { "3", "0", "10" };
string[] updateRangeHigh = new string[] { "4", "100", "10" };

object[] updates = new object[] { updateDescription, updateRangeLow, updateRangeHigh };

int result = (int)protocol.NotifyDataMinerQueued(127/*NT_UPDATE_DESCRIPTION_XML*/, elementDetails, updates);
```

> Use `NotifyDataMinerQueued` (not `NotifyDataMiner`) when modifying the executing element's own parameters.

> **DELT**: Validator rule `[Major][3.23.1]` flags this call as incompatible with Dynamic Element Linking Technology.

---

### 128 — NT_UPDATE_PORTS_XML

Updates matrix element configurations: port labels, states, permissions, lock/follow/master settings, dimensions, and layout.

**Signature (single update):**
```csharp
int result = (int)protocol.NotifyDataMinerQueued(128/*NT_UPDATE_PORTS_XML*/, updateConfig, updateValue);
```

**Parameters (single update):**

| Parameter | Type | Format |
|-----------|------|--------|
| `updateConfig` | `string` | `"changeType;elementID;parameterID;agentID"` |
| `updateValue` | `string` | Content depends on `changeType` |

**Parameters (bulk update):**

| Parameter | Type | Description |
|-----------|------|-------------|
| `updateConfigs` | `object[]` | Array of `uint[]`: `[0]` = change type, `[1]` = element ID, `[2]` = matrix param ID, `[3]` = agent ID, `[4]` = discreet info trigger flag (1 = suppress) |
| `updateValues` | `object[]` | Array of `string[]`: `[0]` = primary value, `[1]` = secondary value |

**Change types:**

| Type | Description |
|------|-------------|
| `0` | Label |
| `1` | State (enabled/disabled) |
| `2` | Current settings |
| `3` | Page info |
| `4` | Not allowed (restrict outputs) |
| `5` | Allowed (permit outputs) |
| `6` | Lock |
| `7` | Follow |
| `8` | Master |
| `9` | Size (format: `"inputs;outputs"`) |
| `10` | Layout (`InputLeftOutputTop` or `InputTopOutputLeft`) |

**Return:** `0` = success, `1` = failure.

**Example — set input label:**
```csharp
string config = $"0;{protocol.ElementID};{matrixParamId};{protocol.DataMinerID}";
string value = "1;Input Port A";
int result = (int)protocol.NotifyDataMinerQueued(128/*NT_UPDATE_PORTS_XML*/, config, value);
```

**Example — disable an input:**
```csharp
string config = $"1;{protocol.ElementID};{matrixParamId};{protocol.DataMinerID}";
string value = "1;disabled";
protocol.NotifyDataMinerQueued(128/*NT_UPDATE_PORTS_XML*/, config, value);
```

**Example — set matrix layout:**
```csharp
string config = $"10;{protocol.ElementID};{matrixParamId};{protocol.DataMinerID}";
protocol.NotifyDataMiner(128/*NT_UPDATE_PORTS_XML*/, config, "InputLeftOutputTop");
```

> Updates generate a `labels.xml` file in `C:\Skyline DataMiner\Elements\[Element Name]`.
> Matrix dimensions cannot exceed the hard-coded protocol maximum.
> Layout options (`InputLeftOutputTop`, `InputTopOutputLeft`) are also available as `MatrixLayoutOptions` enum values from `Skyline.DataMiner.Net.Matrices` (SLNetTypes.dll).

> **DELT**: Validator rule `[Major][3.20.1]` flags this call as incompatible with Dynamic Element Linking Technology.

---

## NotifyProtocol Calls

These calls use `protocol.NotifyProtocol(type, ...)` — the standard SLProtocol call path. All five have modern wrapper methods.

### 193 — NT_FILL_ARRAY

Replaces the entire table content. Rows not in the provided data are deleted.

**Wrapper:** `protocol.FillArray(tablePid, columns)` — see Table Fill Methods in `dataminer-qaction/SKILL.md`.

**Raw signature:**
```csharp
object result = protocol.NotifyProtocol(193/*NT_FILL_ARRAY*/, tableId, tableContent);
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `tableId` | `int` | Table parameter ID |
| `tableContent` | `object[]` | Column-oriented: each element is an `object[]` of values for one column |

**Return:** `true` on success, `null` on error.

**Example:**
```csharp
object[] keys = new object[] { "1", "2", "3" };
object[] names = new object[] { "Alpha", "Beta", "Gamma" };
object[] values = new object[] { 10.0, 20.0, 30.0 };

protocol.NotifyProtocol(193/*NT_FILL_ARRAY*/, 1000, new object[] { keys, names, values });
```

**Advanced — Clear/Leave and DateTime:**

Pass an `object[]` as the first argument instead of a plain `int` to enable advanced features:

```csharp
// tableInfo: [tableId, useClearAndLeave, globalTimestamp]
object tableInfo = new object[] { 1000, true, DateTime.Now };

object[] keys = new object[] { "1", "2" };
object[] names = new object[] { protocol.Leave, "BetaNew" };
object[] values = new object[] { protocol.Clear, 99.0 };

protocol.NotifyProtocol(193/*NT_FILL_ARRAY*/, tableInfo, new object[] { keys, names, values });
```

**Per-cell timestamps** override the global timestamp by wrapping individual values:
```csharp
object[] names = new object[] { "Alpha", new object[] { "Beta", DateTime.Now - TimeSpan.FromDays(1) } };
```

**Constraints:**
- Columns must be `retrieved` type; other column types are skipped automatically
- Primary keys must be strings
- Not compatible with `autoincrement` column option
- `null` values clear the corresponding cell

---

### 194 — NT_FILL_ARRAY_NO_DELETE

Adds or updates rows without deleting existing rows not in the provided data (upsert).

**Wrapper:** `protocol.FillArrayNoDelete(tablePid, columns)` — see Table Fill Methods in `dataminer-qaction/SKILL.md`.

**Raw signature:**
```csharp
object result = protocol.NotifyProtocol(194/*NT_FILL_ARRAY_NO_DELETE*/, tableId, tableContent);
```

**Parameters:** Same shape as NT_FILL_ARRAY (193) — column-oriented `object[]`.

**Return:** `true` on success, `null` on error.

**Example:**
```csharp
object[] keys = new object[] { "2", "4" };
object[] names = new object[] { "BetaUpdated", "Delta" };
object[] values = new object[] { 25.0, 40.0 };

protocol.NotifyProtocol(194/*NT_FILL_ARRAY_NO_DELETE*/, 1000, new object[] { keys, names, values });
```

**Advanced features:** Same Clear/Leave, global DateTime, and per-cell timestamp support as NT_FILL_ARRAY (193) — pass `object[]` as the first argument to enable them.

**Constraints:**
- Columns must be `retrieved` type
- Primary keys must be strings
- Not compatible with `autoincrement` column option
- `null` values clear the corresponding cell

---

### 220 — NT_FILL_ARRAY_WITH_COLUMN

Updates specific columns for specific rows, identified by primary key. Does not affect other columns or rows not in the provided keys.

**Wrapper:** `protocol.FillArrayWithColumn(tablePid, columnPid, keys, values)` — see Table Fill Methods in `dataminer-qaction/SKILL.md`.

**Raw signature:**
```csharp
protocol.NotifyProtocol(220/*NT_FILL_ARRAY_WITH_COLUMN*/, columnInfo, values);
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `columnInfo` | `object[]` | `[0]` = table PID (int), `[1..n-1]` = column PID(s) (int), `[n]` = optional config `object[]` |
| `values` | `object[]` | `[0]` = primary keys (object[]), `[1..n]` = column values (object[] or string[]) |

> The raw call parameter layout differs from the wrapper. The wrapper takes `(tablePid, columnPid, keys[], values[])` as four separate arguments. The raw call packs table PID and column PID(s) into a single `columnInfo` array, and packs keys and values into a single `values` array.

**Example — update one column:**
```csharp
object[] columnInfo = new object[] { 1000, 1002 };
object[] values = new object[]
{
    new object[] { "1", "2", "3" },
    new object[] { "AlphaNew", "BetaNew", "GammaNew" },
};

protocol.NotifyProtocol(220/*NT_FILL_ARRAY_WITH_COLUMN*/, columnInfo, values);
```

**Example — update multiple columns in one call:**
```csharp
object[] columnInfo = new object[] { 1000, 1002, 1003 };
object[] values = new object[]
{
    new object[] { "1", "2" },
    new object[] { "AlphaNew", "BetaNew" },
    new object[] { 99.0, 88.0 },
};

protocol.NotifyProtocol(220/*NT_FILL_ARRAY_WITH_COLUMN*/, columnInfo, values);
```

**Advanced — Clear/Leave:**
```csharp
object[] columnInfo = new object[] { 1000, 1002, new object[] { true } };
object[] values = new object[]
{
    new object[] { "1", "2" },
    new object[] { "AlphaNew", protocol.Clear },
};

protocol.NotifyProtocol(220/*NT_FILL_ARRAY_WITH_COLUMN*/, columnInfo, values);
```

**Advanced — global timestamp:**
```csharp
object[] columnInfo = new object[] { 1000, 1002, new object[] { false, DateTime.Now } };
```

**Constraints:**
- Columns must be `retrieved` type
- Column data must be wrapped in `object[]` or `string[]`
- Validator rule `[Major][3.34.4]`: when DateTime arguments are provided, the target column must have `historySet="true"` on the `<Param>` element

---

### 221 — NT_RUN_ACTION

Executes a protocol action by its ID.

**Wrapper:** `protocol.RunAction(actionId)` from `Skyline.DataMiner.Utils.Protocol.Extension` — see `dataminer-nugets/references/skyline-dataminer-utils-protocol-extension.md`.

**Raw signature:**
```csharp
protocol.NotifyProtocol(221/*NT_RUN_ACTION*/, actionId, null);
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `actionId` | `int` | ID of the `<Action>` to execute |

**Return:** Does not return an object.

**Example:**
```csharp
int actionId = 10;
protocol.NotifyProtocol(221/*NT_RUN_ACTION*/, actionId, null);
```

---

### 321 — NT_GET_TABLE_COLUMNS

Retrieves specific columns from a table by 0-based column index.

**Wrapper:** `protocol.GetColumns(tablePid, columnIdxs)` from `Skyline.DataMiner.Utils.Protocol.Extension` — see `dataminer-nugets/references/skyline-dataminer-utils-protocol-extension.md`.

**Raw signature:**
```csharp
object[] columns = (object[])protocol.NotifyProtocol(321/*NT_GET_TABLE_COLUMNS*/, tablePid, columnsToGetIdx);
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `tablePid` | `int` | Table parameter ID |
| `columnsToGetIdx` | `uint[]` | 0-based column indexes to retrieve |

**Return:** `object[]` where each element is an `object[]` containing the column data. Returns `null` on error.

**Example:**
```csharp
uint[] columnsToGet = new uint[] { 0, 2 };
object[] columns = (object[])protocol.NotifyProtocol(321/*NT_GET_TABLE_COLUMNS*/, 1000, columnsToGet);

if (columns != null)
{
    object[] primaryKeys = (object[])columns[0];
    object[] values = (object[])columns[1];
}
```

---

## Quick Reference

| Type | Name | Call Path | Wrapper | DELT |
|------|------|-----------|---------|------|
| 127 | NT_UPDATE_DESCRIPTION_XML | `NotifyDataMinerQueued` | None | Incompatible (3.23.1) |
| 128 | NT_UPDATE_PORTS_XML | `NotifyDataMinerQueued` | None | Incompatible (3.20.1) |
| 193 | NT_FILL_ARRAY | `NotifyProtocol` | `protocol.FillArray()` | OK |
| 194 | NT_FILL_ARRAY_NO_DELETE | `NotifyProtocol` | `protocol.FillArrayNoDelete()` | OK |
| 220 | NT_FILL_ARRAY_WITH_COLUMN | `NotifyProtocol` | `protocol.FillArrayWithColumn()` | OK |
| 221 | NT_RUN_ACTION | `NotifyProtocol` | `protocol.RunAction()` | OK |
| 321 | NT_GET_TABLE_COLUMNS | `NotifyProtocol` | `protocol.GetColumns()` | OK |

Reference: https://aka.dataminer.services/notify-types-overview
