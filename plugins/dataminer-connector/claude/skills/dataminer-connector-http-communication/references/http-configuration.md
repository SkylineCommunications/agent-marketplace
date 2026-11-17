# HTTP Configuration

Element configuration, dynamic IP, HTTPS, and proxy settings for HTTP connections.

## Element Wizard Configuration

When creating an element with an HTTP connection:

| Field | Description |
|-------|-------------|
| **IP address/host** | Server IP address or hostname |
| **IP port** | Port number (443 = HTTPS by default) |
| **Bus address** | Enter `bypassProxy` to bypass network proxy |

## Recommended HTTP/HTTPS PortSettings

Best practice: restrict the element wizard to only valid HTTP options by defining `<PortSettings>` in the protocol. This prevents operators from selecting invalid port types (serial, UDP) during element creation.

### Template

```xml
<PortSettings name="HTTP Connection - API Endpoint">
    <BusAddress>
        <DefaultValue>bypassProxy</DefaultValue>
    </BusAddress>
    <IPport>
        <DefaultValue>443</DefaultValue>
        <Disabled>true</Disabled>
    </IPport>
    <Type>
        <DefaultValue>ip</DefaultValue>
    </Type>
    <PortTypeUDP>
        <Disabled>true</Disabled>
    </PortTypeUDP>
    <PortTypeSerial>
        <Disabled>true</Disabled>
    </PortTypeSerial>
</PortSettings>
```

### Guidelines

| Setting | Recommendation | Reason |
|---------|---------------|--------|
| `BusAddress` | DefaultValue `bypassProxy` | Default to bypassing proxy for direct API communication; operator can override or clear if proxy is required |
| `IPport` | DefaultValue `443`, optionally Disabled | Standard HTTPS port; disable if always fixed |
| `Type` | DefaultValue `ip` | HTTP always uses TCP/IP |
| `PortTypeUDP` | Disabled | HTTP never uses UDP |
| `PortTypeSerial` | Disabled | HTTP never uses serial |

### When to Keep IPport Editable

- If the API may run on different ports per deployment (e.g. custom port per customer)
- Remove `<Disabled>true</Disabled>` from `<IPport>` to allow operators to change it

### Multiple Connections

For connectors with multiple HTTP connections (using `advanced` attribute on `<Type>`), define additional port settings blocks:

```xml
<Ports>
    <PortSettings name="REST Connection - Secondary">
        <BusAddress><DefaultValue>bypassProxy</DefaultValue></BusAddress>
        <IPport><DefaultValue>8080</DefaultValue></IPport>
        <Type><DefaultValue>ip</DefaultValue></Type>
        <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
        <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
    </PortSettings>
</Ports>
```

## Proxy Configuration

### Session Attribute

```xml
<Session id="1" proxyServer="100">
    <!-- Parameter 100 contains proxy address -->
</Session>
```

### Behavior Matrix

| Bus Address | Proxy Parameter | Result |
|-------------|-----------------|--------|
| `bypassProxy` | Contains proxy | Use specified proxy |
| `bypassProxy` | Empty/Not Initialized | Bypass all proxies |
| *(empty)* | Contains proxy | Use specified proxy |
| *(empty)* | Empty/Not Initialized | Use default proxy (auto-discovery) |

## Dynamic IP Address

Dynamically change polling IP and port at runtime using a parameter with the `dynamic ip` option.

### Parameter Definition

```xml
<Param id="400" trending="false" save="true">
    <Name>Dynamic polling IP</Name>
    <Type options="dynamic ip 1">read</Type>
    <Interprete>
        <RawType>other</RawType>
        <LengthType>next param</LengthType>
        <Type>string</Type>
    </Interprete>
</Param>
```

### Connection Targeting

| Option | Target Connection |
|--------|-------------------|
| `dynamic ip` | First connection (connection 0) |
| `dynamic ip 0` | First connection (connection 0) |
| `dynamic ip 1` | Second connection (connection 1) |
| `dynamic ip 100` | Connection 100 |

### Parameter Value Format

```
IP:PORT
```

**Examples:**
- `10.12.0.63:4000` - Poll IP 10.12.0.63 on port 4000
- `10.12.0.63` - Poll IP 10.12.0.63 using port from element wizard
- `https://10.12.0.63:8443` - Poll using HTTPS on port 8443

### Important Notes

- `bypassProxy` setting is taken from element wizard connection settings
- Port is optional; if omitted, uses port from element wizard
- For HTTPS, must include `https://` prefix (see below)

## HTTPS Configuration

### Default Behavior

| Port | Protocol |
|------|----------|
| 443 | HTTPS (automatic) |
| Other | HTTP (default) |

### Non-Standard HTTPS Port

For HTTPS on ports other than 443, prefix the address with `https://` in the element wizard.

**Example:** To poll HTTPS on port 8443:
- Address field: `https://192.168.1.100`
- Port field: `8443`

### Dynamic IP with HTTPS

When using dynamic IP parameter for HTTPS, the `https://` prefix must be in the parameter value:

```csharp
// Correct - HTTPS
protocol.SetParameter(400, "https://10.12.0.63:8443");

// Incorrect - Will use HTTP despite port
protocol.SetParameter(400, "10.12.0.63:8443");
```

**Warning:** The `https://` prefix from element wizard port configuration is NOT applied to dynamic IP values.

### Certificate Verification

Keep certificate verification enabled and prefer a certificate trusted by the target system.

`PortSettings/SkipCertificateVerification` is available for HTTP connections from DataMiner 10.4.12 onward. Do not set its default to `true` as a generic development workaround. A target-specific bypass requires an explicit requirement, documented risk, and the narrowest possible deployment scope.

When custom C# HTTP code is unavoidable, `ServerCertificateCustomValidationCallback` must validate `SslPolicyErrors` and must never always return `true`; the SecureCoding analyzer reports unconditional acceptance as `SLC_SC0005`.

### Common Error

If HTTPS is not correctly indicated, you may see:

```
ERROR_WINHTTP_HEADER_SIZE_OVERFLOW
```

This occurs because DataMiner assumes HTTP and the secure channel response is misinterpreted.

## See Also

- [HTTP Fundamentals](http-fundamentals.md) - Session structure overview
- [HTTP Implementation](http-implementation.md) - Request/response details
- [HTTP Examples](http-examples.md) - Complete implementation examples
