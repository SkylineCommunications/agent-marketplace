# SNMP Simulator Session Reference

`SnmpSimulatorSession` wraps the Skyline QADeviceSimulator to simulate an SNMPv1 device on a dynamic UDP port. Drop this into `IntegrationTests/TestingUtilities/`.

## Full Implementation

```csharp
namespace IntegrationTests.TestingUtilities
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.IO;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;
    using System.Threading;

    /// <summary>
    /// Wraps the Skyline QADeviceSimulator for headless SNMPv1 simulation inside a QAOps test.
    /// Requires elevation; if elevation is denied, <see cref="TryStart"/> returns null and the
    /// caller must call <see cref="Microsoft.VisualStudio.TestTools.UnitTesting.Assert.Inconclusive"/>.
    /// Always dispose — the simulation file is removed and the process is killed on Dispose.
    /// </summary>
    internal sealed class SnmpSimulatorSession : IDisposable
    {
        private const string SimulatorDir = @"C:\QASNMPSimulations";
        private const string SimulatorExe = @"C:\Skyline DataMiner\Tools\QADeviceSimulator\QADeviceSimulator.exe";

        private readonly string _simFile;
        private readonly Process _process;

        public int UdpPort { get; }

        private SnmpSimulatorSession(int udpPort, string simFile, Process process)
        {
            UdpPort = udpPort;
            _simFile = simFile;
            _process = process;
        }

        /// <summary>
        /// Tries to start a QADeviceSimulator session.
        /// Returns null if the simulator exe is missing, elevation is denied, or startup fails.
        /// Sets <paramref name="failureReason"/> with a human-readable explanation.
        /// </summary>
        public static SnmpSimulatorSession TryStart(
            string simulationName,
            int udpPort,
            Dictionary<string, string> oidValues,
            out string failureReason)
        {
            failureReason = null;

            if (!File.Exists(SimulatorExe))
            {
                failureReason = $"QADeviceSimulator not found at '{SimulatorExe}'.";
                return null;
            }

            if (!Directory.Exists(SimulatorDir))
            {
                try { Directory.CreateDirectory(SimulatorDir); }
                catch (Exception ex)
                {
                    failureReason = $"Cannot create simulation dir '{SimulatorDir}': {ex.Message}";
                    return null;
                }
            }

            string simFile = Path.Combine(SimulatorDir, simulationName + ".xml");
            try
            {
                File.WriteAllText(simFile, BuildSimXml(udpPort, oidValues), Encoding.UTF8);
            }
            catch (Exception ex)
            {
                failureReason = $"Cannot write simulation file '{simFile}': {ex.Message}";
                return null;
            }

            var psi = new ProcessStartInfo
            {
                FileName = SimulatorExe,
                Arguments = $"\"{simFile}\" /d",
                UseShellExecute = true,
                Verb = "runas",
                CreateNoWindow = true,
            };

            Process proc;
            try
            {
                proc = Process.Start(psi);
            }
            catch (Exception ex)
            {
                File.Delete(simFile);
                failureReason = $"Could not start QADeviceSimulator (elevation denied?): {ex.Message}";
                return null;
            }

            // Give the simulator a moment to bind the UDP port
            Thread.Sleep(1500);

            if (proc.HasExited)
            {
                File.Delete(simFile);
                failureReason = $"QADeviceSimulator exited immediately with code {proc.ExitCode}.";
                return null;
            }

            return new SnmpSimulatorSession(udpPort, simFile, proc);
        }

        public void Dispose()
        {
            try
            {
                if (!_process.HasExited)
                {
                    _process.Kill();
                    _process.WaitForExit(5000);
                }
            }
            catch { /* best effort */ }

            try { File.Delete(_simFile); } catch { /* best effort */ }
        }

        // ──────────────────────────────────────────────────────────────
        // Helpers
        // ──────────────────────────────────────────────────────────────

        private static string BuildSimXml(int port, Dictionary<string, string> oidValues)
        {
            var sb = new StringBuilder();
            sb.AppendLine("<?xml version=\"1.0\" encoding=\"utf-8\" ?>");
            sb.AppendLine("<Simulation>");
            sb.AppendLine("  <Agents>");
            sb.AppendLine($"    <Agent ip=\"127.0.0.1\" MacAddress=\"\" SNMPVersion=\"1\" Name=\"IDmsTestSim\" Port=\"{port}\" AutoBuildVersion=\"1.3\" />");
            sb.AppendLine("  </Agents>");
            sb.AppendLine("  <DefaultDefinitionAttributes LogOutput=\"\" Comment=\"\" Delay=\"false\" Save=\"false\" SkipOID=\"false\" />");
            sb.AppendLine("  <Definitions>");
            foreach (var kv in oidValues)
                sb.AppendLine($"    <Definition OID=\"{kv.Key}\" Type=\"OctetString\" ReturnValue=\"{kv.Value}\" />");
            sb.AppendLine("  </Definitions>");
            sb.AppendLine("</Simulation>");
            return sb.ToString();
        }

        /// <summary>Picks a free UDP port on loopback (best-effort).</summary>
        public static int GetFreeUdpPort()
        {
            using (var client = new UdpClient(new IPEndPoint(IPAddress.Loopback, 0)))
            {
                return ((IPEndPoint)client.Client.LocalEndPoint).Port;
            }
        }
    }
}
```

## Usage Example

```csharp
[TestMethod]
[TestCategory("IntegrationTest")]
[TestCategory("IDmsElementCreation")]
public void Create_SnmpElement_PollsSimulatedSysDescr()
{
    int udpPort = SnmpSimulatorSession.GetFreeUdpPort();
    var oids = new Dictionary<string, string>
    {
        ["1.3.6.1.2.1.1.1.0"] = "Simulated Device",
        ["1.3.6.1.2.1.1.3.0"] = "99",
    };

    string failureReason;
    SnmpSimulatorSession simulator = SnmpSimulatorSession.TryStart(
        "IDmsTest_" + DateTime.UtcNow.Ticks, udpPort, oids, out failureReason);

    if (simulator == null)
    {
        Assert.Inconclusive($"SNMP simulator unavailable: {failureReason}");
    }

    using (simulator)
    {
        IDmsProtocol protocol = dms.GetProtocol(Settings.ProtocolNameSlcSdfSnmp, "Production");
        var config = new ElementConfiguration(dms, "IDmsTest_Snmp_" + DateTime.UtcNow.Ticks, protocol);
        config.Connections[0] = new SnmpV1Connection(new Udp("127.0.0.1", udpPort));
        IDmsElement element = dms.GetAgent(agentId).CreateElement(config);
        try
        {
            DmsElementState state = WaitForState(element, ElementState.Active, TimeSpan.FromSeconds(60));
            Assert.AreEqual(ElementState.Active, state, "Element did not reach Active state.");

            string sysDescr = WaitForParameterValue(element, 100 /*sysDescr PID*/, "Simulated Device", TimeSpan.FromSeconds(30));
            Assert.AreEqual("Simulated Device", sysDescr,
                $"PID 100 expected 'Simulated Device' but got '{sysDescr}'. SimPort={udpPort}");
        }
        finally { element.Delete(); }
    }
}
```

## Important Notes

- `TryStart` uses `UseShellExecute = true; Verb = "runas"` — this is required for elevation but means stdout/stderr from the process are not capturable from code.
- Always use unique simulation file names (`simulationName + DateTime.UtcNow.Ticks`) to avoid collisions if a previous test leaked a file.
- The simulator writes SNMPv1 responses only. For SNMPv2c/v3 tests use an `SnmpV2Connection`/`SnmpV3Connection` element that polls the same simulator (the simulator responds to any version request on the bound port, though the response community/auth is simulator-default).
- The DaaS QAOps DataMiner machine ships the Skyline Device Simulator with DataMiner 10.1.5+. If a specific DataMiner version below 10.1.5 is targeted, always `Inconclusive` instead of `Fail`.
