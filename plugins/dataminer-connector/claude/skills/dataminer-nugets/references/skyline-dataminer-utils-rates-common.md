# Skyline.DataMiner.Utils.Rates.Common

## Purpose

`Skyline.DataMiner.Utils.Rates.Common` provides core rate helpers for counters when you already have timing information. Use it for non-SNMP counters retrieved through HTTP, serial, WebSocket, files, custom code, or any source that gives a reliable `DateTime` or `TimeSpan` for the counter sample.

Official API docs: https://aka.dataminer.services/skyline-data-miner-utils-rates-common

NuGet: https://www.nuget.org/packages/Skyline.DataMiner.Utils.Rates.Common

Rate calculation article: https://community.dataminer.services/the-many-pitfalls-of-rate-calculations-and-how-you-can-avoid-them/

Example connector: https://github.com/SkylineCommunications/SLC-C-Example_Rates-Custom

## When To Use

| Use case | Decision |
|----------|----------|
| HTTP API returns monotonically increasing counters | Use `Rates.Common` with `Rate32OnDateTime` or `Rate64OnDateTime`. |
| Serial/WebSocket/custom polling gives counter samples | Use `Rates.Common`. |
| You know exact elapsed time between two counters | Use `Rate32OnTimeSpan` or `Rate64OnTimeSpan`. |
| SNMP counters are retrieved by DataMiner SNMP polling | Use `Rates.Protocol`, not direct `Rates.Common`. |
| `Rates.Protocol` already references this package transitively | Do not add a direct reference unless code uses `Rates.Common` types directly. |

## Package Facts

| Item | Value |
|------|-------|
| Current observed version | `1.0.0.5` |
| Target framework | `.NET Framework 4.6.2+` |
| Main namespace | `Skyline.DataMiner.Utils.Rates.Common` |
| Dependencies | `Microsoft.CSharp`, `Newtonsoft.Json` |
| Used by | `Skyline.DataMiner.Utils.Rates.Protocol` |

## Common PackageReference

```xml
<PackageReference Include="Skyline.DataMiner.Utils.Rates.Common" Version="1.0.0.5" />
```

## Required Using

```csharp
using Skyline.DataMiner.Utils.Rates.Common;
```

## Main Classes

| Type | Use |
|------|-----|
| `Rate32OnDateTime` | Calculate rates from `uint` counters and UTC `DateTime` samples. |
| `Rate64OnDateTime` | Calculate rates from `ulong` counters and UTC `DateTime` samples. |
| `Rate32OnTimeSpan` | Calculate rates from `uint` counters and elapsed `TimeSpan` values. |
| `Rate64OnTimeSpan` | Calculate rates from `ulong` counters and elapsed `TimeSpan` values. |
| `RateHelper<T, U>` | Generic base class. Normally use concrete helper types. |
| `RateOnDateTime<T, U>` | Generic base class for DateTime-based helpers. |
| `RateOnTimeSpan<T, U>` | Generic base class for TimeSpan-based helpers. |
| `Counter32WithDateTime` | Internal/helper counter container for 32-bit DateTime samples. |
| `Counter64WithDateTime` | Internal/helper counter container for 64-bit DateTime samples. |
| `Counter32WithTimeSpan` | Internal/helper counter container for 32-bit TimeSpan samples. |
| `Counter64WithTimeSpan` | Internal/helper counter container for 64-bit TimeSpan samples. |

## Main Methods

| Method | Use |
|--------|-----|
| `Rate32OnDateTime.FromJsonString(string, TimeSpan, TimeSpan, RateBase)` | Deserialize buffered 32-bit DateTime rate state. |
| `Rate64OnDateTime.FromJsonString(string, TimeSpan, TimeSpan, RateBase)` | Deserialize buffered 64-bit DateTime rate state. |
| `Rate32OnTimeSpan.FromJsonString(string, TimeSpan, TimeSpan, RateBase)` | Deserialize buffered 32-bit TimeSpan rate state. |
| `Rate64OnTimeSpan.FromJsonString(string, TimeSpan, TimeSpan, RateBase)` | Deserialize buffered 64-bit TimeSpan rate state. |
| `Calculate(counter, DateTime utcDateTime, double faultyReturn = -1)` | Calculate rate using a UTC timestamp. Throws if `DateTime.Kind` is not `Utc`. |
| `Calculate(counter, TimeSpan timeSpan, double faultyReturn = -1)` | Calculate rate using elapsed time. |
| `Reset()` | Clear buffered counter data in the helper. |
| `ToJsonString()` | Serialize helper state to store in an internal parameter or table column. |

## RateBase

| Value | Result unit |
|-------|-------------|
| `RateBase.Second` | Per second. Default. |
| `RateBase.Minute` | Per minute. |
| `RateBase.Hour` | Per hour. |
| `RateBase.Day` | Per day. |

## DateTime Pattern

Use UTC timestamps. The API rejects non-UTC `DateTime` values to avoid daylight-saving-time issues.

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Utils.Rates.Common;

private void AddRateColumns(Dictionary<int, List<object>> columnsToSet, string rowKey, ulong newOctetCount, string previousRateData)
{
    TimeSpan minDelta = TimeSpan.FromSeconds(20);
    TimeSpan maxDelta = TimeSpan.FromMinutes(10);

    Rate64OnDateTime helper = Rate64OnDateTime.FromJsonString(previousRateData, minDelta, maxDelta);
    double octetsPerSecond = helper.Calculate(newOctetCount, DateTime.UtcNow);
    double bitsPerSecond = octetsPerSecond > 0 ? octetsPerSecond * 8 : octetsPerSecond;

    columnsToSet[Parameter.Streams.tablePid].Add(rowKey);
    columnsToSet[Parameter.Streams.Pid.streamsbitrateondates].Add(bitsPerSecond);
    columnsToSet[Parameter.Streams.Pid.streamsbitrateondatesdata].Add(helper.ToJsonString());
}
```

## TimeSpan Pattern

Use TimeSpan helpers only when the elapsed time is known and reliable.

```csharp
TimeSpan minDelta = TimeSpan.FromSeconds(20);
TimeSpan maxDelta = TimeSpan.FromMinutes(10);

Rate64OnTimeSpan helper = Rate64OnTimeSpan.FromJsonString(previousRateData, minDelta, maxDelta);
double octetsPerSecond = helper.Calculate(newOctetCount, TimeSpan.FromSeconds(10));
double bitsPerSecond = octetsPerSecond > 0 ? octetsPerSecond * 8 : octetsPerSecond;
```

## Reset Pattern

If the data source reboots and counters restart from zero, reset the helper state.

```csharp
Rate64OnDateTime helper = Rate64OnDateTime.FromJsonString(String.Empty, minDelta, maxDelta);
```

You can also call `Reset()` on an existing helper instance before serializing it again.

## minDelta And maxDelta

| Setting | Meaning |
|---------|---------|
| `minDelta` | Minimum elapsed time required before a rate is calculated. Counters are buffered until this is met. |
| `maxDelta` | Maximum elapsed time allowed between counters. Older samples are discarded because multiple wraparounds may have happened. |

## Counter Type Selection

| Counter source | Helper |
|----------------|--------|
| 32-bit counter with UTC sample time | `Rate32OnDateTime` |
| 64-bit counter with UTC sample time | `Rate64OnDateTime` |
| 32-bit counter with elapsed time | `Rate32OnTimeSpan` |
| 64-bit counter with elapsed time | `Rate64OnTimeSpan` |

## Faulty Return

The `faultyReturn` argument is returned when a correct rate cannot be calculated, such as before enough buffered data is available. Default is `-1`.

```csharp
double rate = helper.Calculate(newCounter, DateTime.UtcNow, faultyReturn: Double.NaN);
```

## Pitfalls

| Pitfall | Correct handling |
|---------|------------------|
| Writing manual `(new - old) / seconds` logic | Use the rate helpers. |
| Passing `DateTime.Now` to DateTime helpers | Use `DateTime.UtcNow`. |
| Using `Rates.Common` for SNMP XML polling | Use `Rates.Protocol` with `SnmpDeltaHelper`. |
| Ignoring data-source counter update frequency | Configure a realistic `minDelta`. |
| Ignoring possible multiple wraparounds | Configure a realistic `maxDelta`. |
| Treating data-source reboot as a normal wraparound | Reset buffered helper state. |
| Unsafe conversion from DataMiner `double` to `ulong` | Prefer `Skyline.DataMiner.Utils.SafeConverters`. |
| Using 32-bit helper for 64-bit counters | Match helper type to counter range. |

## Verification

```bash
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>"
```
