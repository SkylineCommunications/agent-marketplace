# Data Generation Heuristics

Rules for generating realistic simulation values based on parameter names, SNMP types, and C# property types. Apply these heuristics when populating the `.toon` simulation file.

## Priority Order

1. **C# class structure** (HTTP only) — if a deserialization class is found, use its property names and types to determine values
2. **Parameter name pattern match** — match against the table below
3. **SNMP type default** — fall back to type-based defaults
4. **Generic default** — `Sample` for strings, `0` for numbers

## Name Pattern Lookup Table

Match parameter names case-insensitively. Use the first matching pattern.

### System/Device Identity

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*sysDescr*`, `*systemDescription*` | OctetString | `Linux router 5.15.0-generic x86_64` |
| `*sysName*`, `*systemName*`, `*hostname*` | OctetString | `device-core-01` |
| `*sysLocation*`, `*location*` | OctetString | `Building A Floor 3 Rack 12` |
| `*sysContact*`, `*contact*` | OctetString | `admin@example.local` |
| `*sysObjectID*`, `*sysOid*` | OctetString | `1.3.6.1.4.1.9.1.1` |
| `*model*`, `*productName*` | OctetString | `X-Series 5000` |
| `*firmware*`, `*softwareVersion*`, `*version*` | OctetString | `4.2.1-build.2847` |
| `*serialNumber*`, `*serial*` | OctetString | `SN-2026-0708-001` |

### Time and Uptime

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*uptime*`, `*sysUpTime*` | TimeTicks | `8640000` (= 1 day in hundredths of seconds) |
| `*lastChange*`, `*lastUpdated*` | TimeTicks | `360000` |
| `*timestamp*`, `*time*`, `*date*` | OctetString | `"2026-07-08T12:00:00Z"` |

### Network Interface

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*ifIndex*`, `*index*` (in table context) | Integer32 | Sequential: `1`, `2`, `3` |
| `*ifDescr*`, `*interfaceName*`, `*portName*` | OctetString | `GigabitEthernet0/1`, `GigabitEthernet0/2`, `Loopback0` |
| `*ifType*` | Integer32 | `6` (ethernetCsmacd) |
| `*ifSpeed*`, `*speed*`, `*bandwidth*` | Gauge32 | `1000000000` (1 Gbps) |
| `*ifHighSpeed*` | Gauge32 | `1000` (1 Gbps in Mbps) |
| `*ifMtu*`, `*mtu*` | Integer32 | `1500` |
| `*ifOperStatus*`, `*operStatus*` | Integer32 | Cycle: `1` (up), `1`, `2` (down) |
| `*ifAdminStatus*`, `*adminStatus*` | Integer32 | `1` (up) |
| `*ifPhysAddress*`, `*macAddress*` | OctetString | `00:1A:2B:3C:4D:01`, `:02`, `:03` |
| `*ifAlias*`, `*alias*`, `*label*` | OctetString | `Uplink to Core`, `Server VLAN`, `Management` |

### Counters and Statistics

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*ifInOctets*`, `*inOctets*`, `*rxBytes*` | Counter32 | `485729301` |
| `*ifOutOctets*`, `*outOctets*`, `*txBytes*` | Counter32 | `291048576` |
| `*ifInErrors*`, `*inErrors*`, `*rxErrors*` | Counter32 | `12` |
| `*ifOutErrors*`, `*outErrors*`, `*txErrors*` | Counter32 | `3` |
| `*ifInDiscards*`, `*inDiscards*` | Counter32 | `0` |
| `*ifOutDiscards*`, `*outDiscards*` | Counter32 | `0` |
| `*ifInUcastPkts*`, `*inPackets*`, `*rxPackets*` | Counter32 | `3847291` |
| `*ifOutUcastPkts*`, `*outPackets*`, `*txPackets*` | Counter32 | `2918374` |
| `*count*`, `*counter*` | Counter32 | `42857` |
| `*rate*`, `*bitRate*`, `*utilization*` | Gauge32 | `450000000` |

### IP Addressing

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*ipAddress*`, `*ipAddr*`, `*address*` | IpAddress | `192.168.1.1`, `.2`, `.3` |
| `*subnetMask*`, `*netMask*`, `*mask*` | IpAddress | `255.255.255.0` |
| `*gateway*`, `*defaultGateway*`, `*nextHop*` | IpAddress | `192.168.1.1` |
| `*routeDest*`, `*destination*` | IpAddress | `10.0.0.0`, `192.168.1.0`, `0.0.0.0` |

### Status and State

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*status*` (generic) | Integer32 | `1` (first enum value / "normal") |
| `*state*` | Integer32 | `1` |
| `*enabled*`, `*active*` | Integer32 | `1` (true/enabled) |
| `*severity*`, `*alarmLevel*` | Integer32 | `0` (normal) |
| `*health*`, `*healthStatus*` | OctetString | `healthy` |

### Capacity and Performance

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*cpu*`, `*cpuUsage*`, `*cpuLoad*` | Gauge32 | `23` (percentage) |
| `*memory*`, `*memUsage*`, `*memUsed*` | Gauge32 | `67` (percentage) |
| `*memTotal*`, `*totalMemory*` | Integer32 | `8589934592` (8 GB in bytes) |
| `*memFree*`, `*freeMemory*` | Integer32 | `2831155200` |
| `*diskUsage*`, `*storageUsed*` | Gauge32 | `45` (percentage) |
| `*temperature*`, `*temp*` | Integer32 | `42` (Celsius) |
| `*power*`, `*watts*` | Integer32 | `350` |
| `*voltage*` | Integer32 | `220` |
| `*fanSpeed*`, `*fan*` | Integer32 | `4500` (RPM) |

### Names and Identifiers

| Pattern | Type | Generated Value |
|---------|------|-----------------|
| `*name*` (generic) | OctetString | `Device-01`, `Device-02`, `Device-03` |
| `*id*` (generic, not index) | Integer32 | Sequential: `1001`, `1002`, `1003` |
| `*uuid*`, `*guid*` | OctetString | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` |
| `*description*`, `*descr*` | OctetString | `Primary interface`, `Secondary link`, `Management port` |

## SNMP Type Defaults

When no name pattern matches, use these type-based defaults:

| SNMP Type | Default Value |
|-----------|--------------|
| `OctetString` | `Sample` |
| `Integer32` | `1` |
| `Counter32` | `0` |
| `Counter64` | `0` |
| `Gauge32` | `0` |
| `TimeTicks` | `0` |
| `IpAddress` | `0.0.0.0` |

## HTTP/JSON Type Defaults

When generating JSON response bodies and no name heuristic matches:

| C# Type | JSON Default |
|---------|-------------|
| `string` | `"sample"` |
| `int`, `long` | `0` |
| `double`, `float`, `decimal` | `0.0` |
| `bool` | `true` |
| `DateTime` | `"2026-07-08T12:00:00Z"` |
| `List<T>`, `T[]` | Array with 3 elements |
| Nullable type (`T?`) | Non-null value of T |
| Nested class/record | Object with all properties populated |

## Table Row Generation

### Default Row Count

Generate **3 rows** per table unless:
- The connector structure implies a specific count (e.g., a fixed-size chassis with N slots)
- A `<Discreets>` element or enum suggests a bounded set

### Row Variation Rules

For multi-row tables, vary values across rows to make simulation realistic:

1. **Index columns**: Sequential integers starting at 1
2. **Name/description columns**: Numbered variants (`Port 1`, `Port 2`, `Port 3`)
3. **Status columns**: Mix states (e.g., row 1 = up, row 2 = up, row 3 = down)
4. **Counter columns**: Different magnitudes (row 1 high, row 2 medium, row 3 low)
5. **Address columns**: Sequential IPs (`.1`, `.2`, `.3`)
6. **Speed columns**: Same value across rows (consistent hardware)

### Interface Name Patterns

For network interface tables, use realistic interface names per row:

| Row | Name Pattern |
|-----|-------------|
| 1 | `GigabitEthernet0/1` or `eth0` or `Port 1` |
| 2 | `GigabitEthernet0/2` or `eth1` or `Port 2` |
| 3 | `Loopback0` or `mgmt0` or `Port 3` |

## HTTP Property Name → Value Mapping

For JSON properties discovered from C# classes or parameter names:

| Property Name Pattern | JSON Value |
|----------------------|-----------|
| `*hostname*`, `*host*` | `"gateway-01"` |
| `*model*`, `*product*` | `"X-Series 5000"` |
| `*version*`, `*firmware*` | `"4.2.1"` |
| `*status*`, `*state*` | `"online"` or `"active"` |
| `*uptime*` (number) | `86400` |
| `*uptime*` (string) | `"1d 0h 0m"` |
| `*cpu*`, `*cpu_usage*` | `23.5` |
| `*memory*`, `*mem_usage*` | `67.2` |
| `*speed*` (number) | `10000000000` |
| `*count*`, `*total*` | `42` |
| `*enabled*`, `*active*` (bool) | `true` |
| `*name*`, `*label*` | `"Port 1"`, `"Port 2"`, `"Port 3"` |
| `*id*` (number) | Sequential: `1`, `2`, `3` |
| `*url*`, `*uri*`, `*endpoint*` | `"https://api.example.com/v1"` |
| `*email*`, `*mail*` | `"admin@example.local"` |
| `*ip*`, `*address*` (string) | `"192.168.1.1"` |
| `*error*`, `*errors*` (number) | `0` |
| `*description*`, `*desc*` | `"Primary connection"` |
