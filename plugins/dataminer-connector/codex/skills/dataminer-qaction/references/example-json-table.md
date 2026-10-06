# Canonical QAction Examples

Authoritative C# patterns for DataMiner connector QActions.
**Always follow these exact patterns.** Do NOT invent SLProtocol methods not shown here or in the `dataminer-qaction` skill.

SLProtocol API: https://aka.dataminer.services/logic-q-actions

---

## Pattern 1: Parse JSON Response → Fill Table

The most common QAction pattern. Triggered by an HTTP response body parameter; parses JSON and fills a table.

### `protocol.xml` Registration

```xml
<QAction id="1" name="ParseDevicesResponse" encoding="csharp" triggers="101">
```

- `triggers="101"` — fires when parameter 101 (the response body) changes.
- QAction class lives in `QAction_1/QAction_1.cs`.

### `QAction_1.cs`

Add the `Skyline.DataMiner.Utils.SecureCoding` runtime package and retain the `Skyline.DataMiner.Utils.SecureCoding.Analyzers` package. The runtime helper is required for deserialization; the analyzer alone does not provide it.

```csharp
using System;
using System.Collections.Generic;
using System.Globalization;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

using Skyline.DataMiner.Scripting;
using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

/// <summary>
/// DataMiner QAction Class: Parse Devices Response.
/// </summary>
public class QAction
{
    /// <summary>
    /// The QAction entry point.
    /// </summary>
    /// <param name="protocol">Link with SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        try
        {
            string rawResponse = Convert.ToString(protocol.GetParameter(Parameter.responsedevices_101));

            if (string.IsNullOrEmpty(rawResponse))
            {
                protocol.Log($"QA{protocol.QActionID}|Run|Empty response — skipping.", LogType.Information, LogLevel.NoLogging);
                return;
            }

            ParseAndFillTable(protocol, rawResponse);
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }

    private static void ParseAndFillTable(SLProtocol protocol, string rawResponse)
    {
        var devicesResponse = SecureNewtonsoftDeserialization.DeserializeObject<DevicesResponse>(rawResponse);
        if (devicesResponse?.Devices == null)
        {
            protocol.Log($"QA{protocol.QActionID}|ParseAndFillTable|Null or empty devices list.", LogType.Error, LogLevel.NoLogging);
            return;
        }

        var tableRows = new List<object[]>();

        foreach (var device in devicesResponse.Devices)
        {
            tableRows.Add(new object[]
            {
                device.Id,                               // idx 0 — devicesIndex
                device.Name ?? String.Empty,             // idx 1 — devicesName
                ConvertStatus(device.Status),            // idx 2 — devicesStatus
            });
        }

        protocol.FillArray(Parameter.Devices.TablePid, tableRows, NotifyProtocol.SaveOption.Full);
    }

    private static double ConvertStatus(string status)
    {
        switch (status?.ToUpperInvariant())
        {
            case "ONLINE": return 1;
            case "DEGRADED": return 2;
            case "OFFLINE": return 3;
            default: return -1;
        }
    }
}

/// <summary>
/// Represents the JSON response from /api/v1/devices.
/// </summary>
internal class DevicesResponse
{
    [JsonProperty("devices")]
    public List<DeviceItem> Devices { get; set; }
}

/// <summary>
/// Represents a single device entry in the response.
/// </summary>
internal class DeviceItem
{
    [JsonProperty("id")]
    public string Id { get; set; }

    [JsonProperty("name")]
    public string Name { get; set; }

    [JsonProperty("status")]
    public string Status { get; set; }
}
```

### Key Rules Applied

| Rule | What Was Done |
|------|---------------|
| Always try/catch the `Run` method | Outer try/catch wraps the entire entry point |
| Avoid scattered parameter IDs | Uses `Parameter.responsedevices_101` because this example consumes a generated helper; helper-free code uses descriptive local constants |
| Use `e.ToString()` not `e.Message` | Full exception with stack trace in log |
| Use `String.Empty` not `""` | Applied to null-safe field assignment |
| Log format `QA{id}|MethodName|message` | Prefix on all log messages |
| Use `CultureInfo.InvariantCulture` for parsing | Would apply if `double.Parse()` were used |
| Null check before iterating | `devicesResponse?.Devices == null` check |

---

## Pattern 2: Get/Set Multiple Scalar Parameters (Bulk)

Use `GetParameters` / `SetParameters` for batch operations — NEVER call `GetParameter`/`SetParameter` in a loop.

```csharp
using System;
using System.Globalization;

using Skyline.DataMiner.Scripting;

/// <summary>
/// DataMiner QAction Class: Process Status Response.
/// </summary>
public class QAction
{
    /// <summary>
    /// The QAction entry point.
    /// </summary>
    /// <param name="protocol">Link with SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        try
        {
            // ✅ Bulk read — one IPC call instead of N
            object[] values = (object[])protocol.GetParameters(new uint[]
            {
                Parameter.systemname_102,
                Parameter.systemuptime_101,
            });

            string systemName = Convert.ToString(values[0]);
            double uptime = Convert.ToDouble(values[1], CultureInfo.InvariantCulture);

            // ... process values ...

            string processedName = systemName.Trim();
            double uptimeSeconds = uptime / 100.0;

            // ✅ Bulk write — one IPC call instead of N
            protocol.SetParameters(
                new int[] { Parameter.systemname_102, Parameter.systemuptime_101 },
                new object[] { processedName, uptimeSeconds });
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

---

## Pattern 3: Update a Single Table Column (FillArrayWithColumn)

When only one column of data changes, use `FillArrayWithColumn` to update just that column without touching others.

```csharp
using System;
using Skyline.DataMiner.Scripting;

/// <summary>
/// DataMiner QAction Class: Update Device Status Column.
/// </summary>
public class QAction
{
    /// <summary>
    /// The QAction entry point.
    /// </summary>
    /// <param name="protocol">Link with SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        try
        {
            // Build lists of primary keys and new column values
            var keys = new object[] { "device-001", "device-002", "device-003" };
            var statuses = new object[] { 1.0, 2.0, 1.0 };

            // ✅ Updates only the DevicesStatus column — does not touch DevicesName or other columns
            protocol.FillArrayWithColumn(
                Parameter.Devices.tablePid,
                Parameter.Devices.Pid.devicesStatus_1003,
                keys,
                statuses);
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

---

## Pattern 4: Add or Update a Single Row (SetRow / AddRow)

Use `SetRow` to update an existing row. Use `AddRow` to add a row only when its primary key is absent; it does nothing when that key already exists. Prefer `FillArray` for full table refreshes and `FillArrayNoDelete` for bulk upserts.

```csharp
using System;

using Skyline.DataMiner.Scripting;

/// <summary>
/// DataMiner QAction Class: Upsert Device Row.
/// </summary>
public class QAction
{
    /// <summary>
    /// The QAction entry point.
    /// </summary>
    /// <param name="protocol">Link with SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        try
        {
            const string rowKey = "device-001";
            var row = new object[] { rowKey, "Main Switch", 1.0 };
            if (protocol.Exists(Parameter.Devices.tablePid, rowKey))
            {
                protocol.SetRow(Parameter.Devices.tablePid, rowKey, row);
            }
            else
            {
                protocol.AddRow(Parameter.Devices.tablePid, row);
            }
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

---

## Pattern 5: Shared Helper Code (QAction 1, precompile)

Place reusable logic in QAction 1 with `options="precompile"`. Other QActions reference it via `dllImport="QAction_1.dll"`.

### `protocol.xml` Registration for QAction 1

```xml
<QAction id="1" name="SharedHelpers" encoding="csharp" options="precompile">
```

### Other QActions That Use It

```xml
<QAction id="2" name="ParseResponse" encoding="csharp" triggers="101" dllImport="QAction_1.dll">
```

### `QAction_1.cs` — Shared helpers

```csharp
using System;
using System.Globalization;

using Skyline.DataMiner.Scripting;

/// <summary>
/// DataMiner QAction Class: Shared Helpers (precompile).
/// </summary>
public class QAction
{
    /// <summary>
    /// The QAction entry point. Not triggered directly.
    /// </summary>
    /// <param name="protocol">Link with SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        // TODO: Implement.
    }
}

/// <summary>
/// Shared utility methods for all QActions.
/// </summary>
public static class Helpers
{
    /// <summary>
    /// Safely parses a double from a string using invariant culture.
    /// Returns -1 on parse failure.
    /// </summary>
    /// <param name="value">The string to parse.</param>
    /// <returns>The parsed double, or -1 if parsing failed.</returns>
    public static double ParseDouble(string value)
    {
        if (double.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out double result))
        {
            return result;
        }

        return -1;
    }
}
```

---

## Anti-Patterns: Never Do These

| ❌ Wrong | ✅ Correct | Reason |
|----------|-----------|--------|
| `protocol.GetParameter(1003)` (hardcoded ID) | `protocol.GetParameter(Parameter.devicesStatus_1003)` | Magic numbers trigger validator warning 3.6.2 |
| `protocol.GetParameter()` in a loop | `protocol.GetParameters(ids[])` once | Each call is IPC; loops cause RTEs |
| `protocol.SetParameter()` in a loop | `protocol.SetParameters(ids[], values[])` once | Same IPC cost problem |
| `catch (Exception ex) { ... ex.Message ... }` | `... ex.ToString() ...` | `ex.Message` loses stack trace |
| `public class QAction` inside a namespace | `public class QAction` at global scope | Namespaced class silently never fires |
| `double.Parse(str)` | `double.Parse(str, CultureInfo.InvariantCulture)` | Culture-dependent separators cause bugs |
| Empty `try` block (blank lines) | `// TODO: Implement.` placeholder | SA1505/SA1508 build warnings |
| Catching silently (no log) | Always log in `catch` | Silent failures are invisible |
