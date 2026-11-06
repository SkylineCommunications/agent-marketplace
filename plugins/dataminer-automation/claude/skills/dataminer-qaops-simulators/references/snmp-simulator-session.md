# SNMP Simulator Session Reference

`SnmpSimulatorSession` wraps the Skyline QADeviceSimulator to simulate an SNMP device (v1, v2c or v3) on a dynamic UDP port. Drop this into `IntegrationTests/TestingUtilities/`.

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
    /// Wraps the Skyline QADeviceSimulator for headless SNMP simulation inside a QAOps test.
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
                // Bare file name only: a full or quoted path matches no simulation entry and silently
                // starts zero simulations. Do not pass /d (it only disables logging).
                Arguments = Path.GetFileName(simFile),
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

            // A live process is not a health signal: wait for the UDP port to actually be bound.
            bool bound = PollUntil(
                () => proc.HasExited || IsUdpPortBound(udpPort),
                TimeSpan.FromSeconds(30));

            if (proc.HasExited || !bound)
            {
                string reason = proc.HasExited
                    ? $"QADeviceSimulator exited with code {proc.ExitCode}."
                    : $"UDP port {udpPort} was not bound within 30 s.";
                try { if (!proc.HasExited) proc.Kill(); } catch { /* best effort */ }
                File.Delete(simFile);
                failureReason = reason + $" See {SimulatorDir}\\Logging\\Log.txt.";
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

        private static bool IsUdpPortBound(int port)
        {
            foreach (IPEndPoint ep in System.Net.NetworkInformation.IPGlobalProperties
                .GetIPGlobalProperties().GetActiveUdpListeners())
            {
                if (ep.Port == port)
                {
                    return true;
                }
            }

            return false;
        }

        private static bool PollUntil(Func<bool> condition, TimeSpan timeout)
        {
            DateTime deadline = DateTime.UtcNow + timeout;
            while (DateTime.UtcNow < deadline)
            {
                if (condition())
                {
                    return true;
                }

                Thread.Sleep(250);
            }

            return condition();
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
- The simulator supports SNMP v1, v2c and v3 (including GetBulk). A real captured walk with `SNMPVersion="2"` answers v1 and v2c GETs unmodified, so no downgrade step is needed. Use an `SnmpV1Connection`/`SnmpV2Connection`/`SnmpV3Connection` element that matches the connector.
- Never use "process is running" as readiness. A wrong launch argument leaves the process alive with no UDP port bound (symptom: the element is Active but parameters stay empty, and a raw SNMP GET fails with `SocketException: An existing connection was forcibly closed`). `TryStart` therefore polls `GetActiveUdpListeners()` and fails fast.
- Keep logging enabled (no `/d`): `C:\QASNMPSimulations\Logging\Log.txt` records `Simulation started ... Listening for <ip>:<port>` and is the only diagnostic channel.
- On QAOps DaaS the test host is already elevated, so `Verb = "runas"` starts silently. Local runs show a UAC prompt.

## Raw-wire probe (before creating any element)

To split the fault domain in half, send an SNMP GET to the simulator with a client library (for example `Lextm.SharpSnmpLib`) before creating the DataMiner element. If it times out, the simulator is not listening (launch argument, file placement, port conflict). If it answers, investigate the connector or element instead.
- The DaaS QAOps DataMiner machine ships the Skyline Device Simulator with DataMiner 10.1.5+. If a specific DataMiner version below 10.1.5 is targeted, always `Inconclusive` instead of `Fail`.
