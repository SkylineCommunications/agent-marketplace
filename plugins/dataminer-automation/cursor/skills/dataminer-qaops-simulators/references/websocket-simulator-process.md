# WebSocketSimulatorProcess — MSTest Wrapper

Test-helper class that starts, monitors, and cleans up the packaged `WebSocketDeviceSimulator.exe` from within an MSTest test. Drop this into `IntegrationTests/TestingUtilities/`.

## Full Implementation

```csharp
namespace IntegrationTests.TestingUtilities
{
    using System;
    using System.Diagnostics;
    using System.IO;
    using System.Text;
    using System.Threading;

    /// <summary>
    /// Manages the lifecycle of the packaged WebSocketDeviceSimulator.exe process.
    /// Always dispose — the process is killed on Dispose even when the test fails.
    /// </summary>
    internal sealed class WebSocketSimulatorProcess : IDisposable
    {
        private readonly Process _process;
        private readonly StringBuilder _outputLog = new StringBuilder();
        private bool _disposed;

        public int Port { get; }

        private WebSocketSimulatorProcess(Process process, int port)
        {
            _process = process;
            Port = port;
        }

        /// <summary>
        /// Starts the packaged simulator on the specified <paramref name="port"/> (0 = dynamic).
        /// Waits up to <paramref name="startupTimeout"/> for the "READY" stdout marker.
        /// Throws if the simulator exe is not found or does not become ready in time.
        /// </summary>
        public static WebSocketSimulatorProcess Start(
            int port = 0,
            string replyMessage = "PONG",
            TimeSpan? startupTimeout = null)
        {
            TimeSpan timeout = startupTimeout ?? TimeSpan.FromSeconds(15);

            string simulatorPath = Path.Combine(
                AppContext.BaseDirectory,
                "Simulators", "WebSocketDeviceSimulator", "WebSocketDeviceSimulator.exe");

            if (!File.Exists(simulatorPath))
                throw new FileNotFoundException(
                    $"WebSocketDeviceSimulator.exe not found at '{simulatorPath}'. " +
                    "Ensure the simulator project is included as a build-order ProjectReference " +
                    "and the post-build copy target runs before TestPackage harvesting.",
                    simulatorPath);

            var psi = new ProcessStartInfo
            {
                FileName = simulatorPath,
                Arguments = $"--port {port} --reply \"{replyMessage}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
            };

            var process = new Process { StartInfo = psi };

            // Buffer all output so WaitForLine can search it
            var readyEvent = new ManualResetEventSlim(false);
            int boundPort = port;
            var outputBuffer = new StringBuilder();

            process.OutputDataReceived += (_, e) =>
            {
                if (e.Data == null) return;
                Console.WriteLine($"[WsSim] {e.Data}");
                lock (outputBuffer) outputBuffer.AppendLine(e.Data);

                if (e.Data.StartsWith("READY:", StringComparison.Ordinal))
                {
                    string portStr = e.Data.Substring("READY:".Length).Trim();
                    if (int.TryParse(portStr, out int p)) boundPort = p;
                    readyEvent.Set();
                }
            };
            process.ErrorDataReceived += (_, e) =>
            {
                if (e.Data != null) Console.Error.WriteLine($"[WsSim err] {e.Data}");
            };

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();

            bool ready = readyEvent.Wait(timeout);
            if (!ready)
            {
                try { process.Kill(); } catch { /* best effort */ }
                throw new TimeoutException(
                    $"WebSocketDeviceSimulator did not emit READY within {timeout.TotalSeconds}s. " +
                    $"Output so far: {outputBuffer}");
            }

            var wrapper = new WebSocketSimulatorProcess(process, boundPort);
            wrapper._outputLog.Append(outputBuffer);
            return wrapper;
        }

        /// <summary>
        /// Blocks until a stdout line matching <paramref name="predicate"/> appears,
        /// or <paramref name="timeout"/> elapses.
        /// </summary>
        public bool WaitForLine(Func<string, bool> predicate, TimeSpan timeout)
        {
            var deadline = DateTime.UtcNow + timeout;
            while (DateTime.UtcNow < deadline)
            {
                lock (_outputLog)
                {
                    string[] lines = _outputLog.ToString().Split('\n');
                    foreach (string line in lines)
                    {
                        if (predicate(line.Trim()))
                            return true;
                    }
                }

                if (_process.HasExited) return false;
                Thread.Sleep(200);

                // Flush new output from the async reader into _outputLog
                // (OutputDataReceived appends directly; no additional action needed)
            }
            return false;
        }

        /// <summary>Returns a snapshot of all simulator stdout output so far.</summary>
        public string GetOutputSnapshot()
        {
            lock (_outputLog) return _outputLog.ToString();
        }

        public void Dispose()
        {
            if (_disposed) return;
            _disposed = true;
            try
            {
                if (!_process.HasExited)
                {
                    _process.Kill();
                    _process.WaitForExit(5000);
                }
            }
            catch { /* best effort */ }
        }
    }
}
```

## Usage Example

```csharp
[TestMethod]
[TestCategory("IntegrationTest")]
[TestCategory("IDmsElementCreation")]
public void Create_WebSocketElement_ConnectsToSimulatorAndExchangesTextFrame()
{
    using (var simulator = WebSocketSimulatorProcess.Start(replyMessage: "PONG"))
    {
        int port = simulator.Port;
        string elementName = "IDmsTest_WS_" + DateTime.UtcNow.Ticks;
        IDmsElement element = null;
        try
        {
            IDmsProtocol protocol = dms.GetProtocol(
                Settings.ProtocolNameSlcSdfWebSocket, "Production");

            // WebSocket polling IP must be a full ws:// URL, not just a hostname
            var conn = new WebSocketConnection(new Tcp($"ws://127.0.0.1:{port}/ws", port));
            var config = new ElementConfiguration(dms, elementName, protocol);
            config.Connections[0] = conn;

            element = dms.GetAgent(agentId).CreateElement(config);

            // Wait for Active
            ElementState state = WaitForState(element, ElementState.Active, TimeSpan.FromSeconds(60));
            Assert.AreEqual(ElementState.Active, state);

            // Verify readback
            IDmsElement readback = dms.GetElement(element.DmsElementId);
            Assert.IsInstanceOfType(readback.Connections[0], typeof(IWebSocketConnection),
                $"Readback connection was {readback.Connections[0]?.GetType().Name ?? "null"}.");

            // Simulator must have completed the WebSocket upgrade
            bool handshook = simulator.WaitForLine(
                l => l.StartsWith("HANDSHAKE", StringComparison.Ordinal),
                TimeSpan.FromSeconds(30));

            // Simulator must have received the PING command from the connector
            bool pinged = simulator.WaitForLine(
                l => l.StartsWith("RECEIVED:", StringComparison.Ordinal),
                TimeSpan.FromSeconds(30));

            string output = simulator.GetOutputSnapshot();
            Assert.IsTrue(handshook && pinged,
                $"WebSocket handshake/PING not observed within 30s. " +
                $"Simulator output: {output}");

            // Connector should have written PONG into PID 100
            string pongValue = WaitForParameterValue(element, 100, "PONG", TimeSpan.FromSeconds(20));
            Assert.AreEqual("PONG", pongValue,
                $"PID 100 expected 'PONG' but got '{pongValue}'. Simulator output: {output}");
        }
        finally
        {
            element?.Delete();
        }
    }
}
```

## Important Notes

- The `OutputDataReceived` callback runs on a background thread; always `lock(_outputLog)` before appending to and reading from `_outputLog`.
- The `WaitForLine` polling approach is sufficient because DataMiner WebSocket polling typically runs every few seconds.
- If `WebSocketDeviceSimulator.exe` is not found, the exception message calls out the build wiring requirement — this makes CI failures self-diagnosing.
- `Console.WriteLine($"[WsSim] {e.Data}")` routes simulator stdout into the MSTest test output (captured in TRX). This is the only diagnostic available in a QAOps failure, so never skip it.
- If the element fails to reach Active in time, include the simulator output in the Assert message — it shows whether the WebSocket upgrade was reached at all.
