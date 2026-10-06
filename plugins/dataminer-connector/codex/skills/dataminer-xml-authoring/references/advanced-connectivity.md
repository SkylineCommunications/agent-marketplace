# Advanced Connectivity Features

Redundant polling, inter-element communication, and troubleshooting patterns for DataMiner connectors.

---

## Redundant Polling

Redundant polling provides automatic failover between two connections of the same type. When the primary connection times out (after exhausting retries), DataMiner switches to the secondary without the element entering timeout — timeout only occurs when **both** connections are unreachable.

### Configuration

```xml
<Type communicationOptions="redundantPolling" relativeTimers="true" advanced="snmp:Secondary">snmp</Type>
```

**Supported connection-type pairs:**
- Two SNMP connections
- Two serial connections
- Two smart-serial connections
- Two HTTP connections

**Rules:**
- Requires exactly **two connections** of the same type.
- Switching happens after all retries are exhausted on one group, then proceeds to the next group.
- SNMP Get operations via QActions do **not** trigger switching.
- Groups with a specific `connection` attribute do **not** trigger switching.
- For smart-serial: requires response pairs or `NT_CHANGE_COMMUNICATION_STATE (249)` calls to trigger failover.

---

## SNMP Table Retrieval and Performance

Choose the retrieval method from the device's SNMP version, table behavior, response size, and observed resource limits. The official [SNMP table retrieval guide](https://aka.dataminer.services/connections-snmp-retrieving-tables) is authoritative for the available options and version-specific behavior.

- Start with `multipleGetBulk` for SNMPv2+ when the device supports it and the response size is safe.
- Use `multipleGetNext` for SNMPv1; GetBulk is not available on SNMPv1.
- If `multipleGetNext` exceeds device memory or processing capacity, evaluate `bulk` (GetNext + MultipleGet, column-based) and reduce the cells requested per operation.
- Prefer row-complete methods (`multipleGet`, `multipleGetNext`, or `multipleGetBulk`) when row indexes can shift during polling. Plain `GetNext` and column-based retrieval are more exposed to mixed-row results.
- Set `multipleGetBulk:<max-repetitions>` from packet captures and device behavior. The documented default when omitted is 10; it is not a universal safe value.
- Check the path MTU before increasing max-repetitions. The documentation uses 1472 bytes of SNMP payload as a typical Ethernet target to avoid fragmentation; validate the actual path instead of treating that number as an invariant.
- Record table row/cell volume, request count, response size, poll duration, and device CPU/memory symptoms before changing an option.

---

## Inter-Element Communication

When a connector needs data from another element (possibly on another DMA), several approaches are available:

| Method | Use Case |
|--------|----------|
| **Element Connections** | UI-configured parameter linking between elements |
| **Parameter Replication** | Automatic parameter value mirroring |
| **Class Library** | API-based reads/writes via `SLNet` |
| **InterApp Calls** | Structured cross-element messaging |

For full InterApp implementation from NuGet and connector parameters through receiver and sender logic, use `dataminer-nugets/references/skyline-dataminer-core-interappcalls-common.md`.

### Element Connections (Virtual Parameters)

Element connections link parameters between elements using the `virtual` attribute. No protocol changes needed on the remote element.

```xml
<Param id="65" setter="true">
   <Name>Total Bandwidth</Name>
   <Description>Total Bandwidth</Description>
   <Type virtual="source">write</Type>
   <Interprete>
      <RawType>numeric text</RawType>
      <LengthType>next param</LengthType>
      <Type>double</Type>
   </Interprete>
   <Display><RTDisplay>true</RTDisplay></Display>
   <Measurement><Type>number</Type></Measurement>
</Param>

<Param id="66">
   <Name>Received Bandwidth</Name>
   <Description>Received Bandwidth</Description>
   <Type virtual="destination">read</Type>
   <Interprete>
      <RawType>numeric text</RawType>
      <LengthType>next param</LengthType>
      <Type>double</Type>
   </Interprete>
   <Display><RTDisplay>true</RTDisplay></Display>
   <Measurement><Type>number</Type></Measurement>
</Param>
```

**Rules:**
- Source parameters must have `RTDisplay="true"`.
- The `virtual` attribute restricts which parameters can be linked in the Element Connections app.
- Element connections are configured by operators in the DataMiner UI, not hardcoded in the protocol.
- This is separate from DCF — element connections pass parameter values; DCF models physical/logical connectivity.

Reference: https://aka.dataminer.services/advanced-inter-element-communication

---

## Troubleshooting Connector Issues

### Protocol Thread RTE (Runtime Error)

An RTE occurs when a protocol thread shows no activity for **15 minutes** (default). This blocks the SLProtocol process and can cascade to other elements.

**Common causes:**
- Groups requiring too long to complete data retrieval.
- Cascading linked logic creating blocking chains on the protocol thread.
- Malfunctioning third-party software preventing communication.

**Diagnosis:**
1. Check Watchdog log in System Center > Logging > DataMiner. Search for the first RTE (count = 1) to identify the primary element.
2. Use SLNetClientTest to retrieve pending protocol calls and identify which group/action consumes the most time.
3. If the RTE alarm toggles active/cleared, an operation exceeds 15 min (or 7.5 min for half-open RTEs).

**Resolution:** Break long chains by executing logical flows via separate groups. Divide large polling operations into smaller independent chunks.

### Performance Profiling

Use **dotTrace** (JetBrains) to profile QAction performance when investigating slow connectors. Attach to the SLScripting process.

Reference: https://aka.dataminer.services/Investigating-a-protocol-thread-RTE
