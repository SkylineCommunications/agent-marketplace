---
name: dataminer-qaops-simulators
description: 'Device simulators for DataMiner QAOps integration tests: SNMP (Skyline Device Simulator / QADeviceSimulator), raw TCP (serial, HTTP, WebSocket), process-based simulators packaged with .dmtest, and large or per-run simulator assets supplied as QAOps supplementary files. Use when tests need real device communication instead of just checking element state. Covers QADeviceSimulator CLI, TcpDeviceSimulator in-test class, WebSocketDeviceSimulator console exe, SnmpSimulatorSession, simulator lifecycle/cleanup, baseline-controlled test design, loopback limitations on QAOps DaaS, and connector fixture patterns.'
argument-hint: 'Describe what device communication needs to be simulated: e.g. "simulate an SNMP device for my integration test", "create a WebSocket simulator for testing element creation", "add a TCP serial responder for a QAOps data-flow test"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-08-07
  version: 1.3
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.3 | 2026-08-07 | Added supplementary-file delivery for simulator assets: pass variable/large simulation XML, data, or prebuilt simulator executables with `--supplementary-file`, then resolve them through machine-level `QAOPS_SUPPLEMENTARY_FILES` in C# or PowerShell. Kept packaging as the default for small stable helpers that belong to the test artifact. |
| 1.2 | 2026-06-26 | Updated the SNMP and WebSocket usage-example tests to also carry the baseline `[TestCategory("IntegrationTest")]` (additive with the feature-specific `[TestCategory("IDmsElementCreation")]`), matching the mandatory-category rule in `dataminer-qaops-integration-testing` → `references/authoring-test-project.md`. |
| 1.1 | 2026-06-26 | Clarified at the top of "QAOps DaaS Loopback Limitations" that the DaaS target is a **Windows** DataMiner and the loopback/elevation limits are networking constraints, **not** a Linux host — Windows-only connector behavior is available; do not generalize a loopback limit into "the target is Linux". |
| 1.0 | 2026-06-15 | Initial skill: SNMP/QADeviceSimulator, in-test TcpDeviceSimulator, packaged WebSocketDeviceSimulator, SnmpSimulatorSession, lifecycle/cleanup rules, QAOps DaaS loopback limitations, baseline-controlled test design, WebSocket URL format, connector fixture patterns. Derived from a full connector IDms element-creation integration test session. |

# Device Simulators for QAOps Integration Tests

Load this skill when an integration test needs an element to exchange real data with a simulated device, not just reach the Active state. Without a simulator, the only assertion is "element became Active" — with one, the test proves the creation logic stored a working port and the connector can actually poll or receive data.

## Quick Routing

| Need | Use |
|------|-----|
| Simulate an SNMP device with static OIDs | `SnmpSimulatorSession` wrapping the Skyline Device Simulator |
| Simulate a serial request/response device | `TcpDeviceSimulator.StartSerialResponder(...)` in-test |
| Simulate a push-based smart-serial device | `TcpDeviceSimulator.StartPushOnConnect(...)` or `TryPushToElement(...)` |
| Simulate an HTTP server for an HTTP connector | `TcpDeviceSimulator.StartHttpResponder(...)` in-test |
| Simulate a WebSocket server | **Packaged console exe** — not in-test (`TcpListener`-based, included in `.dmtest`) |
| Supply large or per-run simulator XML/data/executables | QAOps supplementary files; resolve machine-level `QAOPS_SUPPLEMENTARY_FILES` |

## Supplying Simulator Assets at Run Time

Use QAOps supplementary files when simulator inputs are large, change per run, or should not be baked
into the `.dmtest`. Examples include vendor simulation data, generated configuration, firmware images,
and prebuilt simulator executables.

Pass each asset with `--supplementary-file`. In C# test code, resolve it from the machine-level
environment variable:

```csharp
string? supplementaryFilesPath = Environment.GetEnvironmentVariable(
    "QAOPS_SUPPLEMENTARY_FILES",
    EnvironmentVariableTarget.Machine);

if (String.IsNullOrWhiteSpace(supplementaryFilesPath) || !Directory.Exists(supplementaryFilesPath))
{
    Assert.Fail("This simulator requires QAOps supplementary files, but none are available.");
}

string simulationPath = Path.Combine(supplementaryFilesPath, "Simulations", "device.xml");
```

PowerShell setup/pipeline code uses the same machine-level value:

```powershell
$supplementaryFilesPath = [Environment]::GetEnvironmentVariable(
    'QAOPS_SUPPLEMENTARY_FILES',
    [EnvironmentVariableTarget]::Machine)
```

Relative upload paths preserve folders, so submit `.\Simulations\device.xml` when the test expects the
`Simulations` subdirectory. Absolute paths are stored by file name only.

Keep small, stable simulator helpers packaged in the `.dmtest` when they are part of the test's
versioned implementation. Supplementary files are better for independently changing runtime data and
do not require a Test Package rebuild when only the supplied file changes. Never use them for secrets.
See `dataminer-qaops/references/supplementary-files.md` for full upload, lifecycle, compatibility, and
security rules.

## The Skyline Device Simulator (QADeviceSimulator)

DataMiner ships a device simulator tool on every DMA since 10.1.5:

```text
C:\Skyline DataMiner\Tools\QADeviceSimulator\QADeviceSimulator.exe
```

It supports **SNMP (SNMPv1) and HTTP** simulation. Serial/smart-serial/WebSocket are **not** supported — use `TcpDeviceSimulator` or a packaged console exe for those.

**Headless CLI usage:**

```text
QADeviceSimulator.exe "<simulation-file.xml>" /d
```

- Simulation file must be placed in `C:\QASNMPSimulations` (created automatically on first start).
- `/d` disables logging for headless/unattended use.
- The exe requires elevation (requireAdministrator manifest). If elevation fails on a DaaS machine, the test must report `Assert.Inconclusive(...)` rather than failing.

**Simulation file format:**

```xml
<?xml version="1.0" encoding="utf-8" ?>
<Simulation>
  <Agents>
    <Agent ip="127.0.0.1" MacAddress="" SNMPVersion="1" Name="MySim" Port="50000" AutoBuildVersion="1.3" />
  </Agents>
  <DefaultDefinitionAttributes LogOutput="" Comment="" Delay="false" Save="false" SkipOID="false" />
  <Definitions>
    <Definition OID="1.3.6.1.2.1.1.1.0" Type="OctetString" ReturnValue="My Simulated Device" />
    <Definition OID="1.3.6.1.2.1.1.3.0" Type="OctetString" ReturnValue="12345" />
  </Definitions>
</Simulation>
```

### `SnmpSimulatorSession` Pattern

A disposable wrapper that generates the XML, starts the process, and cleans up on Dispose:

```csharp
string failureReason;
SnmpSimulatorSession simulator = SnmpSimulatorSession.TryStart(
    "IDmsTestSim_" + DateTime.UtcNow.Ticks,
    udpPort,
    new Dictionary<string, string>
    {
        ["1.3.6.1.2.1.1.1.0"] = "My Test Device",
        ["1.3.6.1.2.1.1.3.0"] = "12345",
    },
    out failureReason);

if (simulator == null)
{
    Assert.Inconclusive($"SNMP simulator could not start: {failureReason}");
}

using (simulator)
{
    // create element, assert PID polled sysDescr
}
```

Key rules for `SnmpSimulatorSession`:
- Always call `TryStart`, never construct directly — elevation failures return `null`.
- Always `Assert.Inconclusive(...)` when `TryStart` returns `null` — never `Assert.Fail`. The QAOps DaaS agent may not allow elevation.
- Always dispose (even on test failure) — leaked simulator processes hold UDP ports.
- Generate a unique simulation file name each time (e.g. append `DateTime.UtcNow.Ticks`) to avoid collisions between parallel runs.
- Reserve a free UDP port with a `UdpClient(new IPEndPoint(IPAddress.Loopback, 0))` probe, then close it before starting the simulator.

## In-Test `TcpDeviceSimulator`

A `TcpListener`-based TCP server that runs **inside the test process** on the QAOps DataMiner machine. No external process, no elevation, no URL ACL. Supports serial, HTTP, and push-on-connect patterns.

```csharp
/// <summary>
/// Serial: responds with <paramref name="reply"/> when the accumulated received bytes contain
/// <paramref name="expectedCommand"/>. Pass a specific <paramref name="port"/> to bind a known port.
/// </summary>
public static TcpDeviceSimulator StartSerialResponder(string expectedCommand, string reply, int port = 0);

/// <summary>HTTP: responds 200 OK with <paramref name="body"/> to any complete HTTP request.</summary>
public static TcpDeviceSimulator StartHttpResponder(string body);

/// <summary>Push: immediately sends <paramref name="payload"/> on every accepted connection.</summary>
public static TcpDeviceSimulator StartPushOnConnect(byte[] payload);

/// <summary>Utility: reserves a free TCP port on loopback.</summary>
public static int GetFreeTcpPort();

/// <summary>
/// Connects to 127.0.0.1:<paramref name="port"/> and pushes <paramref name="payload"/> as a device.
/// Use for smart-serial elements in server mode (loopback polling address).
/// </summary>
public static bool TryPushToElement(int port, byte[] payload, TimeSpan timeout, out string detail);
```

Always dispose `TcpDeviceSimulator` — leaked listeners hold ports:

```csharp
using (TcpDeviceSimulator simulator = TcpDeviceSimulator.StartSerialResponder("PING", "PONG"))
{
    // create element pointing to 127.0.0.1:simulator.Port
    // assert simulator.ReceivedText.Contains("PING")
}
```

### HTTP Simulator Body Gotcha

When using `StartHttpResponder` with an HTTP connector that deserializes the response with `XmlSerializer`, every XML attribute name must match the C# model's `[XmlAttributeAttribute]` **exactly** (case-sensitive, no hyphens unless the attribute specifies a name).

Example failure: DataMiner log shows `System.NullReferenceException at QAction.CheckTemperatureUnit(Server server)` — root cause was `temp-unit="C"` in the simulated body when the model expected `tempunit="C"` (no hyphen). Always inspect the fixture QAction's deserialization model before composing the simulator body.

## WebSocket Device Simulator

DataMiner WebSocket ports use WinHTTP upgrade: the element connects TO a server at the polling address/port/path. When the polling address is loopback, DataMiner enters **server mode** (listening) — but WebSocket ports remain **client mode** even on loopback: the element dials out.

This means a `TcpDeviceSimulator` class (which accepts inbound connections) works as a WebSocket server — but `HttpListener` does **not** work on QAOps DaaS because URL ACL registration requires elevation.

**Solution: package a standalone `net48` console exe** (`WebSocketDeviceSimulator.exe`) that uses raw `TcpListener` for the WebSocket handshake and frame exchange, and copy it into `tests.generated` alongside the integration tests.

### Packaging the Simulator Exe

Packaging is the default for a small stable helper that belongs to the tests. A large, prebuilt, or
per-run simulator executable may instead be supplied with `--supplementary-file` and started from the
machine-level `QAOPS_SUPPLEMENTARY_FILES` directory.

1. Create a `net48` console project (e.g. `IntegrationTests\Simulators\WebSocketDeviceSimulator\`).
2. Exclude it from the integration test project's SDK compilation:
   ```xml
   <Compile Remove="Simulators\**"/>
   <Content Remove="Simulators\**"/>
   <None Remove="Simulators\**"/>
   ```
3. Add a **build-order only** `ProjectReference` from `IntegrationTests` so the simulator always builds first:
   ```xml
   <ProjectReference Include="Simulators\WebSocketDeviceSimulator\WebSocketDeviceSimulator.csproj" ReferenceOutputAssembly="false"/>
   ```
4. Copy the simulator output into the IntegrationTests `bin` **before** the tests.generated harvesting step:
   ```xml
   <Target Name="CopyWebSocketSimulatorToOutput" AfterTargets="Build" BeforeTargets="CopyBinToQaOpsHarvestingTestsGenerated">
     <Copy SourceFiles="@(_SimulatorOutputFiles)"
           DestinationFiles="@(_SimulatorOutputFiles->'$(TargetDir)Simulators/WebSocketDeviceSimulator/%(RecursiveDir)%(Filename)%(Extension)')" />
   </Target>
   ```
5. The existing `CopyBinToQaOpsHarvestingTestsGenerated` target will then copy `Simulators\WebSocketDeviceSimulator\` into `tests.generated` automatically.

### Starting the Simulator from MSTest

```csharp
internal sealed class WebSocketSimulatorProcess : IDisposable
{
    public static WebSocketSimulatorProcess Start(int port, string expectedMessage, string replyMessage)
    {
        string simulatorPath = Path.Combine(AppContext.BaseDirectory, "Simulators",
            "WebSocketDeviceSimulator", "WebSocketDeviceSimulator.exe");
        if (!File.Exists(simulatorPath))
            throw new FileNotFoundException("Simulator not packaged.", simulatorPath);
        // ... start process, wait for "READY:<port>" on stdout
    }
    
    public bool WaitForLine(Func<string, bool> predicate, TimeSpan timeout) { ... }
    
    public void Dispose() { /* Kill + WaitForExit(5000) */ }
}
```

Always kill the simulator in test cleanup (even on failure):

```csharp
using (WebSocketSimulatorProcess simulator = WebSocketSimulatorProcess.Start(port, "PING", "PONG"))
{
    // create WebSocket element, assert simulator saw handshake and PING, element PID has PONG
}
```

### WebSocket URL Format

DataMiner's WebSocket port (`CSLWebSocket`) parses the polling IP as a full URL:

- It strips `ws://` → `http://` and `wss://` → `https://` before passing to WinHTTP.
- A host-only string (e.g. `127.0.0.1`) with no scheme causes `The URL is invalid` in `HandleWebsocketConnectResult`.

**Always use a full `ws://...` URL in the polling address:**

```csharp
new WebSocketConnection(new Tcp("ws://127.0.0.1:" + port + "/ws", port))
```

The `Tcp(remoteHost, remotePort)` constructor puts `remoteHost` into `PollingIPAddress`; DataMiner uses that string as the URL when the connection family is WebSocket.

## QAOps DaaS Loopback Limitations

The QAOps DaaS target is a **Windows** DataMiner (see `dataminer-qaops` → "Platform: QAOps DataMiner Systems Run on Windows"). The limitations below are **networking/elevation** constraints of the provisioned environment — they are **not** signs of a Linux host, and they do not mean Windows-only connector behavior (WMI, registry, `.exe` tools) is unavailable. Do not generalize a loopback limitation into "the target is Linux".

Understanding what QAOps DaaS supports saves multiple wasted runs:

| Protocol | Loopback TCP on DaaS | Workaround |
|----------|---------------------|------------|
| Serial (IP) | ❌ Even known-good baseline elements cannot reach a local simulator | Baseline-controlled: Inconclusive when baseline fails too |
| Smart-serial (IP, server mode) | ❌ DataMiner listens but loopback connections from the same machine don't arrive | Same |
| HTTP | ✅ Works — `TcpDeviceSimulator.StartHttpResponder` | Direct use |
| SNMP (UDP) | ✅ Works — `SnmpSimulatorSession` | Direct use |
| WebSocket | ✅ Works — `WebSocketDeviceSimulator.exe` + `ws://127.0.0.1:port/path` | Packaged exe |

### Smart-Serial Loopback: Server Mode Explained

When the polling IP is loopback (127.0.0.1 or the DMA's own IP), DataMiner's smart-serial port enters **server mode**: it listens and waits for a remote device to connect to it. This means a `TcpDeviceSimulator` (which listens and accepts) would also be waiting; neither side dials out.

Use `TcpDeviceSimulator.TryPushToElement(port, payload, ...)` to play the role of the remote device:

```csharp
string pushDetail;
bool pushed = TcpDeviceSimulator.TryPushToElement(listenPort, frame, TimeSpan.FromSeconds(60), out pushDetail);
if (!environmentSupportsSmartSerialLoopback && !pushed)
    Assert.Inconclusive("Baseline smart-serial element also cannot accept connections on this system.");
```

## Baseline-Controlled Data-Flow Test Design

When a data-flow test might be blocked by environment limitations (serial/smart-serial loopback), design it as a controlled experiment rather than an unconditional assertion:

1. **Baseline probe**: before testing the newly created element, run the same scenario against a known-good fixture element created with a raw `AddElementMessage` (pre-installed by the test package). This fixture uses the same protocol and the same simulator port.
2. **If the baseline fails**: `Assert.Inconclusive(...)` — the environment cannot do it; the new element cannot be blamed.
3. **If the baseline succeeds but the new element fails**: `Assert.Fail(...)` — the element creation logic produced a non-working port.

```csharp
// Baseline: known-good 'Manual Serial' element on port 9000
bool environmentSupportsIt = TryRunBaseline(baseline, simulator9000);

// Created element: our new one on a dynamic port
bool newElementWorks = TryRunTest(element, simulatorDynamic);

if (!environmentSupportsIt && !newElementWorks)
    Assert.Inconclusive("Serial loopback not supported on this DaaS target.");

Assert.IsTrue(newElementWorks,
    "Baseline works but new element does not — creation produced a non-working port.");
```

Additionally, always add a **port-shape equivalence gate** against the baseline: compare `SLNet MainPort` field-by-field (`ProtocolType`, `Type`, `PollingIPAddress`, `PollingIPPort`, `Number`, `IsSslTlsEnabled`). If the stored port matches the baseline exactly (only the port number differs), the creation logic is correct even if live exchange isn't supported:

```csharp
ElementPortInfo created = SLNetUtility.SendGetElementByNameMessage(comm, created.Name).MainPort;
ElementPortInfo expected = SLNetUtility.SendGetElementByNameMessage(comm, baselineName).MainPort;
Assert.AreEqual(expected.ProtocolType, created.ProtocolType, "ProtocolType mismatch");
Assert.AreEqual(expected.Type, created.Type, "Port Type mismatch");
Assert.AreEqual(expectedPollingPort, created.PollingIPPort, "Port number mismatch");
```

## Simulator Lifecycle Rules (Mandatory)

These apply to all simulator types regardless of which QAOps target is used:

1. **Always dispose/kill in `finally` or `using`** — even when the test fails. Leaked processes hold ports and break subsequent tests.
2. **Never leave simulator processes running after AssemblyCleanup** — QAOps provisions a fresh DaaS per run, but if the process persists through the cleanup phase it may prevent element deletion.
3. **Use dynamic ports by default** (`TcpListener` port 0, or `UdpClient` port 0) — fixed ports risk collisions when multiple test classes run.
4. **Log simulator output to the test's console** (`Console.WriteLine`) — it ends up in the TRX and QAOps shows it in the failure message, which is the only diagnostic channel available remotely.
5. **Include simulator state in every assertion message**: port number, connection count, and a truncated sample of received text.

## Reference Files

| Topic | File |
|-------|------|
| Canonical `TcpDeviceSimulator` implementation | `dataminer-qaops-simulators/references/tcp-device-simulator.md` |
| Canonical `SnmpSimulatorSession` implementation | `dataminer-qaops-simulators/references/snmp-simulator-session.md` |
| Canonical `WebSocketDeviceSimulator` console exe | `dataminer-qaops-simulators/references/websocket-simulator-exe.md` |
| `WebSocketSimulatorProcess` test wrapper | `dataminer-qaops-simulators/references/websocket-simulator-process.md` |
| Supplementary simulator assets and PowerShell/C# access | `dataminer-qaops/references/supplementary-files.md` |

## Related Skills

| Task | Skill |
|------|-------|
| Authoring MSTestV2 integration tests and packaging them | `dataminer-qaops-integration-testing` |
| Running `.dmtest` packages on a real QAOps DataMiner | `dataminer-qaops-test-runs` |
| QAOps background, token handling, IDs | `dataminer-qaops` |
