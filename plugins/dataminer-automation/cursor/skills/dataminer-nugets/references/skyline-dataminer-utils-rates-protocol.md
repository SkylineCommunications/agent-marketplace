# Skyline.DataMiner.Utils.Rates.Protocol

## Purpose

`Skyline.DataMiner.Utils.Rates.Protocol` calculates rates from counters polled through DataMiner SNMP groups. Use it for SNMP counter rates, bitrates, bandwidth, packet rates, error rates, discard rates, and table row counter deltas in connector QActions.

Official API docs: https://aka.dataminer.services/skyline-data-miner-utils-rates-protocol

NuGet: https://www.nuget.org/packages/Skyline.DataMiner.Utils.Rates.Protocol

Rate calculation article: https://community.dataminer.services/the-many-pitfalls-of-rate-calculations-and-how-you-can-avoid-them/

Example connector: https://github.com/SkylineCommunications/SLC-C-Example_Rates-SNMP

## When To Use

| Use case | Decision |
|----------|----------|
| Counters are retrieved by SNMP polling in the connector XML | Use `Rates.Protocol`. |
| Need SNMP group delta from DataMiner | Use `SnmpDeltaHelper` with `SnmpRate32` or `SnmpRate64`. |
| SNMP table counter per row | Use `rowKey` in `Calculate` and `BufferDelta`. |
| SNMP timeout or retry needs elapsed delta preserved | Use `BufferDelta`. |
| HTTP, serial, WebSocket, or custom code gives you counters | Use `Rates.Common` instead. |

## Package Facts

| Item | Value |
|------|-------|
| Current observed version | `1.0.0.5` |
| Target framework | `.NET Framework 4.6.2+` |
| Main namespace | `Skyline.DataMiner.Utils.Rates.Protocol` |
| Minimum DataMiner | 10.1.0 according to NuGet metadata |
| Main dependency | `Skyline.DataMiner.Utils.Rates.Common` |

## Dependencies

Observed for `1.0.0.5`:

| Dependency | Purpose |
|------------|---------|
| `Skyline.DataMiner.Utils.Rates.Common` | Core rate helper logic and `RateBase`. |
| `Skyline.DataMiner.Utils.SNMP` | `SnmpDeltaHelper` and SNMP delta calculation method support. |
| `Skyline.DataMiner.Dev.Protocol` | `SLProtocol` APIs for QAction projects. |
| `Newtonsoft.Json` | Rate helper JSON serialization. |

## Common PackageReference

```xml
<PackageReference Include="Skyline.DataMiner.Utils.Rates.Protocol" Version="1.0.0.5" />
```

Use `Skyline.DataMiner.Utils.SNMP` directly as well when code explicitly uses `SnmpDeltaHelper`, even if it is transitively present.

```xml
<PackageReference Include="Skyline.DataMiner.Utils.SNMP" Version="1.0.0.2" />
```

## Required Usings

```csharp
using Skyline.DataMiner.Utils.Rates.Common;
using Skyline.DataMiner.Utils.Rates.Protocol;
using Skyline.DataMiner.Utils.SNMP;
```

## Main Classes

| Type | Use |
|------|-----|
| `SnmpRate32` | Calculate rates from `uint` SNMP counters. Use for 32-bit counters such as `ifInOctets`. |
| `SnmpRate64` | Calculate rates from `ulong` SNMP counters. Use for 64-bit counters such as `ifHCInOctets`. |
| `SnmpRate<T, U>` | Generic base class for SNMP rate helpers. Normally use `SnmpRate32` or `SnmpRate64`. |
| `SnmpDeltaHelper` | From `Skyline.DataMiner.Utils.SNMP`. Retrieves elapsed time between two executions of an SNMP group. |

## Main Methods

| Method | Use |
|--------|-----|
| `SnmpRate32.FromJsonString(string, TimeSpan, TimeSpan, RateBase)` | Deserialize buffered rate state for 32-bit counters. Pass empty string to start fresh. |
| `SnmpRate64.FromJsonString(string, TimeSpan, TimeSpan, RateBase)` | Deserialize buffered rate state for 64-bit counters. Pass empty string to start fresh. |
| `SnmpRate32.Calculate(SnmpDeltaHelper, uint, string rowKey = null, double faultyReturn = -1)` | Calculate a 32-bit SNMP rate and update buffered state. |
| `SnmpRate64.Calculate(SnmpDeltaHelper, ulong, string rowKey = null, double faultyReturn = -1)` | Calculate a 64-bit SNMP rate and update buffered state. |
| `BufferDelta(SnmpDeltaHelper, string rowKey = null)` | Buffer elapsed SNMP delta when a group timed out or retried without a valid counter. |
| `ToJsonString()` | Serialize helper state back to a saved internal parameter or table column. |

## RateBase

| Value | Result unit |
|-------|-------------|
| `RateBase.Second` | Per second. Default. |
| `RateBase.Minute` | Per minute. |
| `RateBase.Hour` | Per hour. |
| `RateBase.Day` | Per day. |

## SNMP Table Rate Pattern

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Utils.Rates.Protocol;
using Skyline.DataMiner.Utils.SNMP;

private const int GroupId = 1000;

private void AddBitRateColumns(Dictionary<int, List<object>> columnsToSet, string rowKey, uint newOctets, string previousRateData)
{
    TimeSpan minDelta = TimeSpan.FromSeconds(5);
    TimeSpan maxDelta = TimeSpan.FromMinutes(10);

    var deltaHelper = new SnmpDeltaHelper(protocol, GroupId, (uint)Parameter.streamsratecalculationsmethod);
    var rateHelper = SnmpRate32.FromJsonString(previousRateData, minDelta, maxDelta);

    double octetsPerSecond = rateHelper.Calculate(deltaHelper, newOctets, rowKey);
    double bitsPerSecond = octetsPerSecond > 0 ? octetsPerSecond * 8 : octetsPerSecond;

    columnsToSet[Parameter.Streams.tablePid].Add(rowKey);
    columnsToSet[Parameter.Streams.Pid.streamsbitrate].Add(bitsPerSecond);
    columnsToSet[Parameter.Streams.Pid.streamsbitratedata].Add(rateHelper.ToJsonString());
}
```

## SNMP Timeout Buffering Pattern

Use this when an SNMP group execution times out or a retry happens. SNMP delta is measured between group executions, so the elapsed delta must be buffered until the next successful counter retrieval.

```csharp
var columnsToSet = new Dictionary<int, List<object>>
{
    { Parameter.Streams.tablePid, new List<object>() },
    { Parameter.Streams.Pid.streamsbitratedata, new List<object>() },
};

var deltaHelper = new SnmpDeltaHelper(protocol, GroupId, (uint)Parameter.streamsratecalculationsmethod);
var rateHelper = SnmpRate32.FromJsonString(previousRateData, TimeSpan.FromSeconds(5), TimeSpan.FromMinutes(10));

rateHelper.BufferDelta(deltaHelper, rowKey);

columnsToSet[Parameter.Streams.tablePid].Add(rowKey);
columnsToSet[Parameter.Streams.Pid.streamsbitratedata].Add(rateHelper.ToJsonString());
```

## SNMP Agent Restart Pattern

If the device or SNMP agent rebooted, counters start over from zero. Reset buffered state rather than treating the reset as a normal wraparound.

```csharp
SnmpRate32 rateHelper;
if (isSnmpAgentRestarted)
{
    rateHelper = SnmpRate32.FromJsonString(String.Empty, minDelta, maxDelta);
}
else
{
    rateHelper = SnmpRate32.FromJsonString(previousRateData, minDelta, maxDelta);
}
```

For SNMP devices, `sysUpTime` (`1.3.6.1.2.1.1.3`) is the common generic signal for detecting reboots.

## Accurate Delta Tracking

`SnmpDeltaHelper.UpdateRateDeltaTracking` configures whether DataMiner tracks rate deltas in fast or accurate mode. Accurate tracking can improve large row-by-row table polling accuracy but costs more resources.

```csharp
CalculationMethod method = (CalculationMethod)Convert.ToInt32(protocol.GetParameter(Parameter.streamsratecalculationsmethod));
if (method == CalculationMethod.Accurate)
{
    SnmpDeltaHelper.UpdateRateDeltaTracking(protocol, groupId: 1000, CalculationMethod.Accurate);
}
```

## minDelta And maxDelta

| Setting | Meaning |
|---------|---------|
| `minDelta` | Minimum elapsed time required before a rate is calculated. Counters are buffered until this is met. Use it when the device updates counters slower than the polling interval. |
| `maxDelta` | Maximum elapsed time allowed between counters. Older data is not trusted because multiple wraparounds may have happened. |

## Counter Type Selection

| Counter source | Helper |
|----------------|--------|
| 32-bit SNMP counter | `SnmpRate32` |
| 64-bit SNMP counter | `SnmpRate64` |
| DataMiner parameter stores `UInt64` as `double` or `string` | Convert safely before passing to `SnmpRate64`; prefer `Skyline.DataMiner.Utils.SafeConverters`. |

## Pitfalls

| Pitfall | Correct handling |
|---------|------------------|
| Writing manual `(new - old) / seconds` logic | Use `SnmpRate32` or `SnmpRate64`. |
| Ignoring SNMP timeouts and retries | Call `BufferDelta` and save `ToJsonString()`. |
| Treating rebooted counters as wraparounds | Reset the helper state with empty serialized data. |
| Polling faster than the device updates counters | Use a realistic `minDelta`. |
| Polling too slowly for the counter range and max device rate | Use a realistic `maxDelta`. |
| Using 32-bit helper for 64-bit counters | Match helper type to counter range. |
| Converting large `UInt64` values through unsafe casts | Use `Skyline.DataMiner.Utils.SafeConverters`. |
| Choosing accurate SNMP delta tracking everywhere | Use accurate mode only when rate precision justifies extra resources. |

## Verification

```bash
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>"
```
