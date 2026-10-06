# Skyline DataMiner Utility NuGet Packages for Connectors

This is the quick catalog of Skyline utility NuGet packages relevant to connector (protocol/driver) development. Deep package-specific API guidance lives in the `dataminer-nugets` skill.
**ALWAYS prefer these official packages over custom implementations.** Do not write manual rate calculation logic, counter delta tracking, type conversions, trap parsing, or context menu handling when a package exists below.

Packages listed here are compatible with **.NET Framework 4.6.2+** and net48 connector projects unless stated otherwise. Individual packages can target .NET Standard.

---

## Rate & Counter Calculations

### `Skyline.DataMiner.Utils.Rates.Protocol`
- **Version**: 1.0.0.5
- **When to use**: **SNMP-polled** rate calculations, bitrate, throughput, bandwidth, counter deltas, speed calculations, bits per second, bytes per second, packets per second, octets per second, error rates, discard rates.
- **Description**: Provides helpers to calculate rates from SNMP counters with DataMiner SNMP group deltas and timeout delta buffering.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.Rates.Protocol;
  using Skyline.DataMiner.Utils.SNMP;

  // For 32-bit counters (e.g., ifInOctets, ifOutOctets)
   SnmpDeltaHelper deltaHelper = new SnmpDeltaHelper(protocol, groupId, (uint)Parameter.ratecalculationmethod);
  SnmpRate32 rate32Helper = SnmpRate32.FromJsonString(bufferedData, minDelta, maxDelta);
  double rateValue = rate32Helper.Calculate(deltaHelper, newCounter, rowKey);

  // For 64-bit counters (e.g., ifHCInOctets, ifHCOutOctets)
  SnmpRate64 rate64Helper = SnmpRate64.FromJsonString(bufferedData, minDelta, maxDelta);
  double rateValue64 = rate64Helper.Calculate(deltaHelper, newCounter64, rowKey);
  ```
- **Depends on**: `Skyline.DataMiner.Utils.Rates.Common`, `Skyline.DataMiner.Utils.SNMP`, `Skyline.DataMiner.Dev.Protocol`, `Newtonsoft.Json`.
- **Minimum DMA**: 10.1.0
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-utils-rates-protocol.md`

### `Skyline.DataMiner.Utils.Rates.Common`
- **Version**: 1.0.0.5
- **When to use**: Non-SNMP/custom counter rate calculations where the code has reliable `DateTime` or `TimeSpan` timing. Automatically pulled as a dependency of `Rates.Protocol` for SNMP scenarios.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.Rates.Common;

  Rate64OnDateTime rateHelper = Rate64OnDateTime.FromJsonString(bufferedData, minDelta, maxDelta);
  double rateValue = rateHelper.Calculate(newCounter, DateTime.UtcNow);
  string newBufferedData = rateHelper.ToJsonString();
  ```
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-utils-rates-common.md`

### `Skyline.DataMiner.Utils.Interfaces`
- **Version**: 1.0.0.3
- **When to use**: **Interface utilization calculations, duplex status, bandwidth utilization percentages**
- **Description**: Calculates interface utilization from rate values and interface speed, handling full/half duplex scenarios.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.Interfaces;

  double utilization = Interface.CalculateUtilization(inRate, outRate, ifSpeed, DuplexStatus.FullDuplex);
  ```
- **Minimum DMA**: 10.1.0

---

## SNMP Utilities

### `Skyline.DataMiner.Utils.SNMP`
- **Version**: 1.0.0.2
- **When to use**: **SNMP counter delta tracking, SNMP rate calculations at the table level**
- **Description**: Provides `SnmpDeltaHelper` for tracking SNMP counter changes across polling cycles for an entire table at once.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.SNMP;

  SnmpDeltaHelper.UpdateRateDeltaTracking(protocol, tablePid: 1000, CalculationMethod.Accurate);
  ```
- **Minimum DMA**: 10.1.0

### `Skyline.DataMiner.Utils.SNMP.Traps.Protocol`
- **Version**: 1.0.0.2
- **When to use**: **SNMP trap processing, trap parsing, trap handling QActions**
- **Description**: Parses incoming SNMP trap data into structured objects for easy processing in QActions.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.SNMP.Traps.Protocol;

  TrapInfo trap = TrapInfo.FromTrapData(trapInfo);
  string oid = trap.Oid;
  string value = trap.GetBindingValue(bindingIndex);
  ```
- **Minimum DMA**: 10.1.0

---

## Table Utilities

### `Skyline.DataMiner.Utils.Table.ContextMenu`
- **Version**: 1.0.0.1
- **When to use**: **Table context menus, right-click menus, table row actions, add/edit/delete row dialogs**
- **Description**: Provides a structured approach to handling table context menu interactions in connectors.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.Table.ContextMenu;

  var contextMenu = new ContextMenuTableManagerBasic(protocol, contextMenuData, tablePid);
  contextMenu.ProcessContextMenu();
  ```
- **Minimum DMA**: 10.1.0

### `Skyline.DataMiner.Utils.TableCleanup`
- **When to use**: **Table cleanup, row expiry, max row limits, stale row removal, row age management**
- **Description**: Provides table cleanup methods based on maximum row count or maximum row age.
- **GitHub**: https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.TableCleanup

---

## Type Safety

### `Skyline.DataMiner.Utils.SafeConverters`
- **Version**: 1.0.0.1
- **When to use**: **Safe type conversion, converting counter values, ulong/uint/double conversion, avoiding overflow exceptions**
- **Description**: Provides safe conversion methods that handle edge cases (null, overflow, format exceptions) without throwing.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.SafeConverters;

  ulong counter = SafeConvert.ToUInt64(counterAsDouble);
  uint value = SafeConvert.ToUInt32(rawValue);
  ```

---

## Protocol Utilities

### `Skyline.DataMiner.Utils.GetAfterSet.Protocol`
- **When to use**: **Get-after-set, re-polling after a set command, confirming set values, set verification**
- **Description**: Automatically re-polls parameters after a set operation to confirm the device accepted the new value.
- **GitHub**: https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.GetAfterSet.Protocol

### `Skyline.DataMiner.Utils.Protocol.Extension`
- **Version**: 1.0.0.4
- **When to use**: **High-level SLProtocol wrappers, coder-friendly protocol methods**
- **Description**: Extension methods for the SLProtocol class providing higher-level, more readable API calls.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.Protocol.Extension;

  protocol.SetParameters(paramsToSet);
  protocol.SetColumns(columnsToSet);
  ```
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-utils-protocol-extension.md`

---

## Dev Packs And InterApp

### `Skyline.DataMiner.Dev.Protocol`
- **When to use**: **Connector QAction compilation, generated QAction_Helper compilation, SLProtocol API access without manual DLL references**.
- **Description**: Official connector Dev Pack. Use instead of copying assemblies from a local DataMiner installation.
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-dev-protocol.md`

### `Skyline.DataMiner.Core.InterAppCalls.Common`
- **Version**: 1.1.1.1
- **When to use**: **InterApp calls, element-to-element messaging, automation-to-element messaging, connector API request/response messages**.
- **Description**: Command/message framework with `Message`, `IInterAppCall`, `InterAppCallFactory`, message executors, receiver/return connector parameters, known types, replies, and broker-aware return handling.
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-core-interappcalls-common.md`

---

## Dev Packs And InterApp

### `Skyline.DataMiner.Dev.Protocol`
- **When to use**: **Connector QAction compilation, generated QAction_Helper compilation, SLProtocol API access without manual DLL references**.
- **Description**: Official connector Dev Pack. Use instead of copying assemblies from a local DataMiner installation.
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-dev-protocol.md`

### `Skyline.DataMiner.Core.InterAppCalls.Common`
- **Version**: 1.1.1.1
- **When to use**: **InterApp calls, element-to-element messaging, automation-to-element messaging, connector API request/response messages**.
- **Description**: Command/message framework with `Message`, `IInterAppCall`, `InterAppCallFactory`, message executors, receiver/return connector parameters, known types, replies, and broker-aware return handling.
- **Deep reference**: `dataminer-nugets/references/skyline-dataminer-core-interappcalls-common.md`

---

## Data Import/Export

### `Skyline.DataMiner.Utils.ExportImport`
- **Version**: 1.0.0
- **When to use**: **CSV import, CSV export, JSON file parsing, XML file import/export, data file handling**
- **Description**: Methods to export or import data for object collections. Supports CSV, JSON, and XML formats.
- **GitHub**: https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.ExportImport

### `Skyline.DataMiner.Utils.Json.Rpc.Api`
- **Version**: 1.0.0.1
- **When to use**: **JSON-RPC protocol implementation, JSON-RPC request/response structures**
- **Description**: Common structures for JSON-RPC protocol implementations in connectors.
- **Entry point**:
  ```csharp
  using Skyline.DataMiner.Utils.Json.Rpc.Api;

  public class MyRequest : Request { }
  public class MyResponse : ResultResponse { }
  ```

---

## Testing (test project only)

### `Skyline.DataMiner.Utils.UnitTestingFramework`
- **When to use**: **Unit testing QActions** — add to the test project `.csproj`, not to QAction projects.
- **Description**: Provides `SLProtocolMock` for testing QActions without a live DataMiner agent.
- **Full documentation**: See `dataminer-unit-testing` skill.
- **GitHub**: https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.UnitTestingFramework

### `FluentAssertions`
- **Version**: 7.2.0
- **When to use**: Readable test assertions — add to the test project `.csproj`.
- **Note**: Third-party package (not Skyline), but standard in connector test projects.

---

## Security

### `Skyline.DataMiner.Utils.SecureCoding`
- **Captured version**: 2.2.3
- **When to use**: Runtime security helpers, including deserialization of untrusted JSON with `SecureNewtonsoftDeserialization`.
- **Namespace**: `Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft`
- **Full documentation**: `dataminer-nugets/references/skyline-dataminer-utils-securecoding.md`

### `Skyline.DataMiner.Utils.SecureCoding.Analyzers`
- **Captured version**: 2.2.3
- **When to use**: Automatically included in all QAction `.csproj` files by the scaffold template. Build-time analyzer only.
- **Note**: Do NOT remove. It reports insecure usage but does not replace the `Skyline.DataMiner.Utils.SecureCoding` runtime package.

---

## Quick Lookup: Feature → Package

| Feature / Task Keywords | Package to Use |
|------------------------|----------------|
| QAction compilation, SLProtocol API, Dev Pack | `Skyline.DataMiner.Dev.Protocol` |
| InterApp, element-to-element messaging, connector API messages | `Skyline.DataMiner.Core.InterAppCalls.Common` |
| SNMP rate, SNMP bitrate, SNMP counter delta, SNMP bps, SNMP octets/sec | `Skyline.DataMiner.Utils.Rates.Protocol` |
| custom rate, HTTP counter rate, serial counter rate, DateTime/TimeSpan rate | `Skyline.DataMiner.Utils.Rates.Common` |
| interface utilization, duplex, bandwidth % | `Skyline.DataMiner.Utils.Interfaces` |
| SNMP counter tracking, delta table | `Skyline.DataMiner.Utils.SNMP` |
| trap parsing, SNMP trap handling | `Skyline.DataMiner.Utils.SNMP.Traps.Protocol` |
| context menu, right-click, table actions | `Skyline.DataMiner.Utils.Table.ContextMenu` |
| table cleanup, row expiry, max rows | `Skyline.DataMiner.Utils.TableCleanup` |
| safe type conversion, ulong, uint | `Skyline.DataMiner.Utils.SafeConverters` |
| get after set, re-poll, set confirmation | `Skyline.DataMiner.Utils.GetAfterSet.Protocol` |
| SLProtocol wrappers, SetColumns, SetParameters, DeleteRows | `Skyline.DataMiner.Utils.Protocol.Extension` |
| CSV, JSON file, XML file, import, export | `Skyline.DataMiner.Utils.ExportImport` |
| JSON-RPC protocol | `Skyline.DataMiner.Utils.Json.Rpc.Api` |
| secure JSON deserialization, SLC_SC0004 | `Skyline.DataMiner.Utils.SecureCoding` |
| unit testing QActions | `Skyline.DataMiner.Utils.UnitTestingFramework` |
