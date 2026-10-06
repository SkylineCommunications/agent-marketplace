# Rate Calculations (C# QAction Patterns)

**When to use**: Any parameter whose raw value is an incrementing counter — octet counters → bit rates, packet counters → packet rates, error counters → error rates. Raw counter values should never be displayed directly; always compute and display the rate.

> For the XML parameter structure (parameter triples, SNMP extras, wiring), see `dataminer-xml-authoring/references/rate-calculation-xml.md`.

## Choosing the Right Pattern

| Scenario | Pattern | NuGet Packages | Time Source |
|----------|---------|----------------|-------------|
| HTTP, serial, virtual, or SNMP-over-SLScripting connectors | **Custom (DateTime-based)** | `Skyline.DataMiner.Utils.Rates.Common` | `DateTime.UtcNow` |
| SNMP connectors (SLProtocol↔SLSNMPManager) | **SNMP (SnmpDeltaHelper-based)** | `Skyline.DataMiner.Utils.Rates.Protocol` + `Skyline.DataMiner.Utils.SNMP` | Group execution delta from DataMiner |

Both patterns share the same core lifecycle:
1. **Deserialize** previous state from a JSON buffer parameter → `FromJsonString(buffer, minDelta, maxDelta)`
2. **Calculate** the rate → `Calculate(counter, timeOrDelta)` — returns `double` (`-1` = N/A)
3. **Serialize** updated state back to the buffer parameter → `ToJsonString()`

Every rate calculation requires a **parameter triple**:
- **Counter parameter** — raw incrementing value from device/source
- **Rate parameter** — calculated rate (displayed, trended), with `<Exception>` value `-1` = N/A
- **Buffer Data parameter** — JSON string storing serialized helper state (hidden, not trended)

## Rate Helper Classes

| Class | Counter Size | Time Source | Use Case |
|-------|-------------|-------------|----------|
| `Rate32OnDateTime` | 32-bit (`uint`) | `DateTime.UtcNow` | HTTP/serial/virtual connectors — 32-bit counters |
| `Rate64OnDateTime` | 64-bit (`ulong`) | `DateTime.UtcNow` | HTTP/serial/virtual connectors — 64-bit counters |
| `Rate32OnTimeSpan` | 32-bit (`uint`) | Fixed `TimeSpan` | Regular-interval polling with known fixed period |
| `Rate64OnTimeSpan` | 64-bit (`ulong`) | Fixed `TimeSpan` | Regular-interval polling with known fixed period |
| `SnmpRate32` | 32-bit (`uint`) | `SnmpDeltaHelper` | SNMP connectors — uses group execution delta |
| `SnmpRate64` | 64-bit (`ulong`) | `SnmpDeltaHelper` | SNMP connectors — uses group execution delta |

## Custom Pattern — Standalone Counter

Install: `dotnet add QAction_N/QAction_N.csproj package Skyline.DataMiner.Utils.Rates.Common`. Add `Skyline.DataMiner.Utils.SafeConverters` when converting DataMiner `double` or `string` values to `uint` or `ulong` counters.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

using Skyline.DataMiner.Scripting;
using Skyline.DataMiner.Utils.Rates.Common;
using Skyline.DataMiner.Utils.SafeConverters;

public static class QAction
{
    private static TimeSpan minDelta = new TimeSpan(0, 0, 5);    // Ignore deltas < 5 seconds
    private static TimeSpan maxDelta = new TimeSpan(0, 10, 0);   // Ignore deltas > 10 minutes

    public static void Run(SLProtocol protocol)
    {
        try
        {
            // 1. Get new counter value from data source
            uint counter = SafeConvert.ToUInt32(Convert.ToDouble(protocol.GetParameter(Parameter.counter)));

            // 2. Deserialize previous state from buffer parameter
            string bufferedData = Convert.ToString(protocol.GetParameter(Parameter.counterrateondatesdata));
            Rate32OnDateTime rateHelper = Rate32OnDateTime.FromJsonString(bufferedData, minDelta, maxDelta);

            // 3. Calculate rate using current UTC time
            double rate = rateHelper.Calculate(counter, DateTime.UtcNow);

            // 4. Save counter, calculated rate, and updated buffer atomically
            Dictionary<int, object> paramsToSet = new Dictionary<int, object>
            {
                { Parameter.counter, counter },
                { Parameter.counterrateondates, rate },
                { Parameter.counterrateondatesdata, rateHelper.ToJsonString() },
            };

            protocol.SetParameters(paramsToSet.Keys.ToArray(), paramsToSet.Values.ToArray());
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

## Custom Pattern — Table (Per-Row Rates)

For tables, iterate all rows and calculate rates per row. Use bulk `GetColumns` / `SetColumns` for performance. The sample below uses `Skyline.DataMiner.Utils.Protocol.Extension` wrappers for those calls:

```csharp
using System;
using Skyline.DataMiner.Scripting;
using Skyline.DataMiner.Utils.Protocol.Extension;
using Skyline.DataMiner.Utils.Rates.Common;
using Skyline.DataMiner.Utils.SafeConverters;

// Entry-point QAction — delegates to helper class
public static class QAction
{
    public static void Run(SLProtocol protocol)
    {
        try
        {
            DateTime now = DateTime.UtcNow;

            // 1. Load previous buffer data for all rows
            uint[] columnsToGet = new uint[]
            {
                (uint)Parameter.Streams.Idx.streamsindex,
                (uint)Parameter.Streams.Idx.streamsoctetscounter,
                (uint)Parameter.Streams.Idx.streamsbitrateondatesdata,
            };
            var tableData = protocol.GetColumns(Parameter.Streams.tablePid, columnsToGet);
            object[] keys = (object[])tableData[0];
            object[] octetsCounters = (object[])tableData[1];
            object[] rateDatesData = (object[])tableData[2];

            // 2. Prepare output lists
            var setKeys = new List<object>();
            var setRates = new List<object>();
            var setBuffers = new List<object>();

            TimeSpan minDelta = new TimeSpan(0, 0, 20);
            TimeSpan maxDelta = new TimeSpan(0, 10, 0);

            // 3. Calculate rate for each row
            for (int i = 0; i < keys.Length; i++)
            {
                setKeys.Add(Convert.ToString(keys[i]));

                ulong newOctetCount = SafeConvert.ToUInt64(Convert.ToDouble(octetsCounters[i]));
                string previousRateData = Convert.ToString(rateDatesData[i]);

                Rate64OnDateTime rateHelper = Rate64OnDateTime.FromJsonString(previousRateData, minDelta, maxDelta);
                double octetRate = rateHelper.Calculate(newOctetCount, now);
                double bitRate = octetRate > 0 ? octetRate * 8 : octetRate;  // Octets → Bits

                setRates.Add(bitRate);
                setBuffers.Add(rateHelper.ToJsonString());
            }

            // 4. Write all results atomically
            var setColumnsData = new Dictionary<int, List<object>>
            {
                { Parameter.Streams.tablePid, setKeys },
                { Parameter.Streams.Pid.streamsbitrateondates, setRates },
                { Parameter.Streams.Pid.streamsbitrateondatesdata, setBuffers },
            };
            protocol.SetColumns(setColumnsData);
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

## SNMP Pattern — Standalone Counter

Install: `dotnet add QAction_N/QAction_N.csproj package Skyline.DataMiner.Utils.Rates.Protocol` and `dotnet add QAction_N/QAction_N.csproj package Skyline.DataMiner.Utils.SNMP`. Add `Skyline.DataMiner.Utils.Protocol.Extension` when using the `protocol.GetColumns` or `protocol.SetColumns` wrappers shown in table examples.

The SNMP pattern adds three capabilities over the Custom pattern:
1. **SnmpDeltaHelper** — uses DataMiner's group execution delta instead of wall-clock time
2. **Timeout handling** — `BufferDelta()` preserves state when a poll times out without computing a rate
3. **SNMP agent restart detection** — resets rate state when `sysUptime` goes backwards

**Success path** (after-group trigger, conditioned on no timeout):
```csharp
using System;
using System.Collections.Generic;
using System.Linq;

using Skyline.DataMiner.Scripting;
using Skyline.DataMiner.Utils.Rates.Protocol;
using Skyline.DataMiner.Utils.SafeConverters;
using Skyline.DataMiner.Utils.SNMP;

public void ProcessData()
{
    // Create delta helper for the poll group
    SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(protocol, groupId);

    SnmpRate32 snmpRateHelper;
    if (isSnmpAgentRestarted)
    {
        // Device restarted — reset buffer to avoid faulty rate from counter reset
        snmpRateHelper = SnmpRate32.FromJsonString(
            String.Empty,
            minDelta: new TimeSpan(0, 0, 5),
            maxDelta: new TimeSpan(0, 10, 0));
    }
    else
    {
        // Normal case — load previous state from buffer parameter
        snmpRateHelper = SnmpRate32.FromJsonString(
            counterRateData,
            minDelta: new TimeSpan(0, 0, 5),
            maxDelta: new TimeSpan(0, 10, 0));
    }

    // Calculate rate: (delta_counter / delta_time)
    double rate = snmpRateHelper.Calculate(snmpDeltaHelper, counter);

    // Save rate and updated buffer
    protocol.SetParameter(Parameter.counterrate, rate);
    protocol.SetParameter(Parameter.counterratedata, snmpRateHelper.ToJsonString());
}
```

**Timeout path** (timeout trigger — buffers delta without calculating rate):
```csharp
public void ProcessTimeout()
{
    SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(protocol, groupId);

    SnmpRate32 snmpRateHelper = SnmpRate32.FromJsonString(
        counterRateData,
        minDelta: new TimeSpan(0, 0, 5),
        maxDelta: new TimeSpan(0, 10, 0));

    // Buffer the delta — don't calculate rate (no valid data received)
    snmpRateHelper.BufferDelta(snmpDeltaHelper);

    protocol.SetParameter(Parameter.counterratedata, snmpRateHelper.ToJsonString());
}
```

**SNMP agent restart detection** (poll `sysUptime` before each rate group):
```csharp
using Skyline.DataMiner.Utils.SNMP;

public static void ProcessNewSysUptimeValue(SLProtocol protocol)
{
    string sysUptimeBuffer = Convert.ToString(protocol.GetParameter(Parameter.sysuptimebuffer));
    double sysUptime = Convert.ToDouble(protocol.GetParameter(Parameter.sysuptime));

    SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(protocol, 1);
    SnmpHelper snmpHelper = SnmpHelper.FromJsonString(sysUptimeBuffer, snmpDeltaHelper);

    if (snmpHelper.IsSnmpAgentRestarted(sysUptime))
    {
        // sysUptime went backwards — device restarted, set restart flags
        protocol.SetParameter(Parameter.countersnmpagentrestartflag, 1);
        protocol.SetParameter(Parameter.streamssnmpagentrestartflag, 1);
    }

    protocol.SetParameter(Parameter.sysuptimebuffer, snmpHelper.ToJsonString());
}
```

## SNMP Pattern — Table (Per-Row Rates)

For SNMP tables, each row is processed individually with the row's primary key passed to `Calculate()`. This enables **per-row delta tracking** when using the Accurate calculation method:

```csharp
public void ProcessData()
{
    SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(
        protocol, groupId, (uint)Parameter.streamsratecalculationsmethod);

    for (int i = 0; i < keys.Length; i++)
    {
        string streamPK = Convert.ToString(keys[i]);
        uint octets = SafeConvert.ToUInt32(Convert.ToDouble(octetsCounters[i]));

        SnmpRate32 snmpRate32Helper;
        if (isSnmpAgentRestarted)
        {
            snmpRate32Helper = SnmpRate32.FromJsonString(
                String.Empty, minDelta, maxDelta);
        }
        else
        {
            snmpRate32Helper = SnmpRate32.FromJsonString(
                Convert.ToString(rateData[i]), minDelta, maxDelta);
        }

        // Pass row PK for per-row delta tracking (Accurate mode)
        double octetRate = snmpRate32Helper.Calculate(snmpDeltaHelper, octets, streamPK);
        double bitRate = octetRate > 0 ? octetRate * 8 : octetRate;

        // Collect results for bulk SetColumns
        setKeys.Add(streamPK);
        setRates.Add(bitRate);
        setBuffers.Add(snmpRate32Helper.ToJsonString());
    }
}
```

**Table timeout path** — buffer delta per row:
```csharp
public void ProcessTimeout()
{
    SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(
        protocol, groupId, (uint)Parameter.streamsratecalculationsmethod);

    for (int i = 0; i < keys.Length; i++)
    {
        string streamPK = Convert.ToString(keys[i]);
        SnmpRate32 snmpRate32Helper = SnmpRate32.FromJsonString(
            Convert.ToString(rateData[i]), minDelta, maxDelta);

        snmpRate32Helper.BufferDelta(snmpDeltaHelper, streamPK);

        setKeys.Add(streamPK);
        setBuffers.Add(snmpRate32Helper.ToJsonString());
    }
}
```

## SNMP Fast vs Accurate Calculation Method

The `SnmpDeltaHelper` constructor optionally accepts a parameter ID for a rate-method selector:

```csharp
// Fast (default): single delta per group execution — all rows share the same time delta
SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(protocol, groupId);

// Accurate: per-row delta tracking — each row tracks its own time delta via PK
SnmpDeltaHelper snmpDeltaHelper = new SnmpDeltaHelper(
    protocol, groupId, (uint)Parameter.streamsratecalculationsmethod);
```

- **Fast** (value `1`): All rows in a table share the same group execution delta. Simpler, lower overhead.
- **Accurate** (value `2`): Each row tracks its own delta via primary key. Use when rows may be added/removed between polls or when precise per-row timing matters.

The method selector is a saved discreet parameter (`<Param save="true">`) with values `1` (Fast) and `2` (Accurate). Changing it at runtime via a write parameter updates the `SnmpDeltaHelper.UpdateRateDeltaTracking()` state.

## Key Behaviours

- **Returns `-1` for N/A** — first call with empty buffer, or when delta is outside `minDelta`/`maxDelta` bounds. Use `<Exception value="-1">` on the rate parameter.
- **Counter wrap-around** — handled automatically for both 32-bit and 64-bit counters. No special handling needed.
- **Octet → bit conversion** — multiply by 8 **after** rate calculation: `octetRate > 0 ? octetRate * 8 : octetRate`. Preserve `-1` (N/A) values.
- **`minDelta` / `maxDelta` thresholds** — rate is `-1` if the time between polls is outside these bounds. Prevents spikes from very short intervals or stale data from very long gaps.
- **Atomic updates** — always set counter, rate, and buffer data in a single `SetParameters` / `SetColumns` call to avoid inconsistent state.
- **Buffer parameter required** — every rate needs a companion buffer parameter (string, not trended, not displayed) to persist helper state as JSON between QAction invocations.

Deep package references: `dataminer-nugets/references/skyline-dataminer-utils-rates-common.md` and `dataminer-nugets/references/skyline-dataminer-utils-rates-protocol.md`
