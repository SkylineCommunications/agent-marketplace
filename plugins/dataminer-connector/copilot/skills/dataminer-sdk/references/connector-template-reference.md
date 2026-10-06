# Connector Template Reference

Complete reference for scaffolding new DataMiner connector solutions with the official `dataminer-connector-solution` template.

> **Parent**: `dataminer-sdk/SKILL.md` — SDK-first rule, validation cadence, packaging, troubleshooting.
> **Companion**: load `dataminer-connector-core` for naming, ID, and XML conventions.

---

## Pre-flight Checks

1. **Refresh templates**: run `dotnet new update` to pick up the latest `Skyline.DataMiner.VisualStudioTemplates` release before scaffolding.
2. **Verify template**: `dotnet new dataminer-connector-solution --help` should list current options. If it errors, install with `dotnet new install Skyline.DataMiner.VisualStudioTemplates`.
3. **Post-scaffold build**: immediately run `dotnet build` on the new solution. A clean baseline build is mandatory before any XML or QAction work begins.

---

## All Template Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `ConnectorName` | **Yes** | `Connector1` | Name of the connector (file names, XML `<Name>`, solution name) |
| `VendorName` | **Yes** | _(empty)_ | The vendor/manufacturer name |
| `VendorOid` | **Yes** | `1.3.6.1.4.1.8813.2.` | Skyline-assigned connector OID matching `1.3.6.1.4.1.8813.2.<number>`, without a trailing dot. |
| `DeviceOid` | **Yes** | _(empty)_ | Device-specific OID **suffix number only** (e.g. `1`, `42`). |
| `ProviderName` | **Recommended** | _(empty)_ | Always pass `"Skyline Communications"` |
| `IntegrationId` | **Recommended** | `DMS-DRV-` | Skyline integration ID (format: `DMS-DRV-NNNN`). Use `DMS-DRV-` as placeholder. |
| `ElementType` | **Recommended** | _(empty)_ | Category label (e.g., `Switch`, `Router`, `Encoder`, `Decoder`, `Probe`) |
| `ConnectionType` | No | `virtual` | Main connection type (see choices below) |
| `SecondConnectionType` | No | `none` | Optional second connection type |
| `Author` | No | _(empty)_ | Developer name |

---

## ConnectionType Choices

| Value | Description |
|-------|-------------|
| `virtual` | No physical connection (scripts/API/virtual elements) |
| `snmp` | SNMPv1 |
| `snmpv2` | SNMPv2c (most common for SNMP) |
| `snmpv3` | SNMPv3 (authentication/encryption) |
| `http` | HTTP/HTTPS REST or SOAP |
| `serial` | Serial (RS-232/RS-485, TCP, UDP) |
| `serial single` | Dedicated serial connection |
| `smart-serial` | Smart serial (asynchronous, unsolicited) |
| `smart-serial single` | Dedicated smart serial |
| `gpib` | GPIB/IEEE-488 instrument bus |
| `websockets` | Real-time bidirectional (streaming APIs, DataMiner 10+) |
| `service` | DataMiner service element |
| `sla` | DataMiner SLA element |

---

## OID Conventions

- **VendorOid**: Must be a Skyline-assigned connector OID matching `1.3.6.1.4.1.8813.2.<number>`, without a trailing dot. The value is written directly to `<VendorOID>`.
  - Example: `1.3.6.1.4.1.8813.2.1`
  - If the assigned value is unknown, ask the user; do not invent a placeholder.
- **DeviceOid**: Device-specific **suffix number only** (e.g. `1`, `42`, `2957`).
  - Example: `VendorOid=1.3.6.1.4.1.8813.2.12345` + `DeviceOid=2957` → `<VendorOID>1.3.6.1.4.1.8813.2.12345</VendorOID>` and `<DeviceOID>2957</DeviceOID>`

## Integration ID Format

`DMS-DRV-NNNN` — a unique 4-digit tracker ID from Skyline project tracking. Use `DMS-DRV-` as placeholder during development.

---

## Example Commands

### Minimal (virtual)
```bash
dotnet new dataminer-connector-solution \
  --connector-name "Vendor Device Name" \
  --provider-name "Skyline Communications" \
  --vendor-name "Vendor Inc" \
  --vendor-oid "1.3.6.1.4.1.XXXXX" \
  --device-oid "YY" \
  --integration-id "DMS-DRV-XXXX" \
  --element-type "Switch"
```

### SNMPv2
```bash
dotnet new dataminer-connector-solution \
  --connector-name "Cisco Catalyst 9300" \
  --provider-name "Skyline Communications" \
  --vendor-name "Cisco" \
  --vendor-oid "1.3.6.1.4.1.9" \
  --device-oid "2957" \
  --integration-id "DMS-DRV-1234" \
  --element-type "Switch" \
  --connection-type "snmpv2" \
  --param:author "Your Name" \
  -o "Cisco Catalyst 9300"
```

### HTTP
```bash
dotnet new dataminer-connector-solution \
  --connector-name "Vendor Device REST API" \
  --provider-name "Skyline Communications" \
  --vendor-name "Vendor" \
  --vendor-oid "1.3.6.1.4.1.99999" \
  --device-oid "1" \
  --integration-id "DMS-DRV-5678" \
  --element-type "Encoder" \
  --connection-type "http" \
  --param:author "Your Name" \
  -o "Vendor Device REST API"
```

### Dual-connection (HTTP + SNMPv2)
```bash
dotnet new dataminer-connector-solution \
  --connector-name "Vendor Device Dual" \
  --provider-name "Skyline Communications" \
  --vendor-name "Vendor" \
  --vendor-oid "1.3.6.1.4.1.99999" \
  --device-oid "2" \
  --integration-id "DMS-DRV-5678" \
  --element-type "Encoder" \
  --connection-type "http" \
  --second-connection-type "snmpv2" \
  --param:author "Your Name" \
  -o "Vendor Device Dual"
```

---

## Generated Solution Structure

### File system layout

```
<ConnectorName>/
├── <ConnectorName>.sln
├── protocol.xml                  # Main connector XML (DPML)
├── Directory.Build.props         # Shared build settings (StyleCop, constants)
├── DefaultTemplates/             # Alarm/trending/info templates placeholder
├── Dlls/                         # DLLs for ProtocolScripts/
├── Documentation/                # Additional docs
├── Internal/
│   ├── .editorconfig
│   └── Code Analysis/
│       ├── qaction-debug.ruleset
│       ├── qaction-release.ruleset
│       └── stylecop.json
├── QAction_1/                    # First QAction project
│   ├── QAction_1.cs
│   └── QAction_1.csproj
└── QAction_Helper/               # Generated convenience project included by the template
    ├── QAction_Helper.cs
    ├── QAction_Helper.csproj
    └── Directory.Build.props
```

> **Solution file format**: the pinned template 2.8.14 generates a classic `.sln` by default. A `.slnx` can be produced from it at any time via `dotnet sln <ConnectorName>.sln migrate` (requires a `.slnx`-capable SDK, e.g. .NET 9+) if the team prefers the newer format. Downstream tooling — the official `dataminer-validator` CLI and `dotnet build` — was verified to work identically against either format, so both are safe to use throughout the connector flow.

### Solution Explorer view (Visual Studio)

QAction projects are nested under a **`QActions` solution folder**. For the default `.sln` format, add projects with:

```bash
dotnet sln add --solution-folder QActions QAction_N/QAction_N.csproj
```

If the solution has been migrated to `.slnx`, the same folder appears as XML instead:

```xml
<Folder Name="/QActions/">
  <Project Path="QAction_1/QAction_1.csproj" />
  <Project Path="QAction_Helper/QAction_Helper.csproj" />
</Folder>
```

> **Adding a new QAction project**: use `dotnet sln add --solution-folder QActions QAction_N/QAction_N.csproj` for `.sln` files, or manually add a `<Project Path="QAction_N/QAction_N.csproj" />` line inside the existing `<Folder Name="/QActions/">` element in the `.slnx` file.

### QAction `.csproj` (SDK-style)

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net48</TargetFramework>
    <GenerateDocumentationFile>True</GenerateDocumentationFile>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\QAction_Helper\QAction_Helper.csproj" />
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="Skyline.DataMiner.CICD.CSharpAnalysis.Analyzer" Version="...">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
    <PackageReference Include="Skyline.DataMiner.Dev.Protocol" Version="..." />
    <PackageReference Include="Skyline.DataMiner.Utils.SecureCoding.Analyzers" Version="...">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
  </ItemGroup>
  <ProjectExtensions>
    <VisualStudio>
      <UserProperties DisLinkId="1" DisProjectType="qactionProject" DisLinkedXmlFile="..\protocol.xml" />
    </VisualStudio>
  </ProjectExtensions>
</Project>
```

**Key points:**
- `Skyline.DataMiner.Dev.Protocol`: NuGet package providing the base `SLProtocol` API — replaces old DLL references.
- `Skyline.DataMiner.Utils.SecureCoding.Analyzers`: **Required in every QAction project.** Analyzer-only reference.
- `QAction_Helper`: Generated connector-specific `Parameter`, `SLProtocolExt`, table, and row types. Do not edit manually.
- `<ProjectExtensions>`: DIS metadata linking to `<QAction id="N">` via `DisLinkId`. Required.
- `Directory.Build.props` (root): Applies StyleCop.Analyzers, SonarAnalyzer rulesets, constants (`DCFv1`, `DBInfo`, `ALARM_SQUASHING`).

The official template includes the helper project/reference by default. Preserve it when QAction or test source consumes generated types. A helper-free QAction project is also valid: omit the `ProjectReference`, keep IDs in descriptive local constants, and call built-in methods directly on `SLProtocol`. Do not introduce or regenerate a helper solely as a completion gate.

---

## Connection Types Reference

### Defining Connections

```xml
<!-- Single connection -->
<Type relativeTimers="true">snmpv2</Type>

<!-- Multiple connections -->
<Type relativeTimers="true" advanced="smart-serial:Serial Connection;http:REST Connection">http</Type>
```

Connection IDs: main = `0`, first advanced = `1`, second = `2`, etc.

### SNMP (snmp / snmpv2 / snmpv3)

```xml
<Type relativeTimers="true">snmpv2</Type>
<PortSettings name="SNMP Connection">
  <BusAddress><Disabled>true</Disabled></BusAddress>
  <IPport><DefaultValue>161</DefaultValue></IPport>
  <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
</PortSettings>
```

Parameters need `<SNMP>` block with `<OID type="complete">`. Docs: https://aka.dataminer.services/connections-snmp

### HTTP/HTTPS

```xml
<Type relativeTimers="true">http</Type>
<PortSettings name="HTTP Connection">
  <BusAddress>
    <DefaultValue>bypassProxy</DefaultValue>
  </BusAddress>
  <IPport><DefaultValue>80</DefaultValue></IPport>
  <Type><DefaultValue>ip</DefaultValue></Type>
  <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
  <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
</PortSettings>
```

Sessions in `<HTTP>` -> `<Session>`. Docs: https://aka.dataminer.services/http-connections

### Serial

```xml
<Type relativeTimers="true">serial</Type>
<PortSettings name="Serial Connection">
  <Type><DefaultValue>serial</DefaultValue></Type>
  <BusAddress><Disabled>true</Disabled></BusAddress>
  <Baudrate><DefaultValue>9600</DefaultValue></Baudrate>
  <Databits><DefaultValue>8</DefaultValue></Databits>
  <Stopbits><DefaultValue>1</DefaultValue></Stopbits>
  <Parity><DefaultValue>No</DefaultValue></Parity>
  <Flowcontrol><DefaultValue>No</DefaultValue></Flowcontrol>
  <IPport><DefaultValue>4001</DefaultValue></IPport>
  <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
</PortSettings>
```

Requires `<Commands>`, `<Responses>`, `<Pairs>`. Docs: https://aka.dataminer.services/connections-serial

### Smart Serial

```xml
<Type relativeTimers="true">smart-serial</Type>
<PortSettings name="Smart Serial Connection">
  <Type><DefaultValue>ip</DefaultValue></Type>
  <BusAddress><Disabled>true</Disabled></BusAddress>
  <IPport><DefaultValue>50000</DefaultValue></IPport>
  <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
</PortSettings>
```

Docs: https://aka.dataminer.services/Smart-Serial-Connection-Info

### Virtual

```xml
<Type>virtual</Type>
```

No port settings required.

### Port Type Compatibility

| Connection Type | TCP/IP | UDP/IP | Serial |
|----------------|--------|--------|--------|
| virtual | — | — | — |
| snmp / snmpv2 / snmpv3 | ✔ | ✔ | — |
| serial / serial single | ✔ | ✔ | ✔ |
| smart-serial / smart-serial single | ✔ | ✔ | — |
| http | ✔ | — | — |
| gpib | ✔ | — | — |

### Port Settings Template

```xml
<PortSettings name="Connection Name">
  <IPport><DefaultValue>443</DefaultValue></IPport>
  <BusAddress>
    <DefaultValue>bypassProxy</DefaultValue>
    <Disabled>false</Disabled>
  </BusAddress>
  <PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>
  <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
  <TimeoutTime><DefaultValue>5000</DefaultValue></TimeoutTime>
  <Retries><DefaultValue>3</DefaultValue></Retries>
</PortSettings>

<!-- Additional connections -->
<Ports>
  <PortSettings name="SNMP Trap Connection">
    <BusAddress><Disabled>true</Disabled></BusAddress>
    <IPport><DefaultValue>162</DefaultValue></IPport>
    <PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>
  </PortSettings>
</Ports>
```

---

## Post-Scaffold Setup

### Evaluate QAction_Helper Refresh

The template already contains a helper generated for its initial `protocol.xml`; a second unconditional post-scaffold generation is unnecessary.

After later XML changes, load `dataminer-qaction-helper-generator` only when existing source consumes generated members affected by those changes, or when the user explicitly requests a refresh. If the solution is intentionally helper-free, preserve that architecture.

### Common NuGet Packages

After scaffolding, consider adding these packages to QAction projects:

```bash
# For HTTP/JSON connectors
dotnet add QAction_1/QAction_1.csproj package Newtonsoft.Json

# For SNMP helpers
dotnet add QAction_1/QAction_1.csproj package Skyline.DataMiner.Utils.SNMP

# For context menu handling
dotnet add QAction_1/QAction_1.csproj package Skyline.DataMiner.Utils.Table.ContextMenu

# For rate calculations (counters -> rates)
dotnet add QAction_1/QAction_1.csproj package Skyline.DataMiner.Utils.Rates.Protocol
```

### Unit Test Project

Add a test project for QAction unit testing:

```bash
dotnet new mstest -n "QAction_Tests" -o QAction_Tests
dotnet sln add --solution-folder Tests QAction_Tests/QAction_Tests.csproj
dotnet add QAction_Tests/QAction_Tests.csproj package Skyline.DataMiner.Utils.UnitTestingFramework
dotnet add QAction_Tests/QAction_Tests.csproj package FluentAssertions --version 7.2.0
dotnet add QAction_Tests/QAction_Tests.csproj reference QAction_1/QAction_1.csproj
```

Add the `QAction_Helper` project reference only when tests use generated `SLProtocolExt`, `ConcreteSLProtocolExt`, table, row, or `Parameter` types. Non-generic `SLProtocolMock` tests do not require it.

> For `.slnx` solutions: add `<Project Path="QAction_Tests/QAction_Tests.csproj" />` inside a `<Folder Name="/Tests/">` element instead of running `dotnet sln add`.

Ensure `protocol.xml` is copied to the test output:
```xml
<!-- In QAction_Tests.csproj -->
<ItemGroup>
  <None Include="..\protocol.xml" CopyToOutputDirectory="PreserveNewest" Link="protocol.xml" />
</ItemGroup>
```
