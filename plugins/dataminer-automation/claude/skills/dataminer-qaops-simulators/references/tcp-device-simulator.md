# TcpDeviceSimulator Reference

In-test TCP device simulator using `TcpListener` on a dynamic port. No external process, no elevation, no `HttpListener` URL ACL. Drop this file into `IntegrationTests/TestingUtilities/`.

## Full Implementation

```csharp
namespace IntegrationTests.TestingUtilities
{
    using System;
    using System.IO;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;
    using System.Threading;
    using System.Threading.Tasks;

    /// <summary>
    /// Lightweight in-test TCP device simulator. Runs on a dynamic loopback port.
    /// Supports serial request/response, push-on-connect, and raw HTTP responder modes.
    /// Always dispose — leaked listeners hold ports.
    /// </summary>
    internal sealed class TcpDeviceSimulator : IDisposable
    {
        private readonly TcpListener _listener;
        private readonly CancellationTokenSource _cts = new CancellationTokenSource();
        private readonly StringBuilder _receivedLog = new StringBuilder();
        private Task _acceptLoop;

        public int Port => ((IPEndPoint)_listener.LocalEndpoint).Port;

        public string ReceivedText
        {
            get { lock (_receivedLog) return _receivedLog.ToString(); }
        }

        private TcpDeviceSimulator(TcpListener listener)
        {
            _listener = listener;
            _listener.Start();
        }

        public void Dispose()
        {
            _cts.Cancel();
            _listener.Stop();
            try { _acceptLoop?.Wait(TimeSpan.FromSeconds(5)); } catch { /* best-effort */ }
        }

        // ──────────────────────────────────────────────────────────
        // Factory methods
        // ──────────────────────────────────────────────────────────

        /// <summary>
        /// Serial responder: replies with <paramref name="reply"/> whenever received data
        /// contains <paramref name="expectedCommand"/>.
        /// </summary>
        public static TcpDeviceSimulator StartSerialResponder(string expectedCommand, string reply, int port = 0)
        {
            var sim = new TcpDeviceSimulator(new TcpListener(IPAddress.Loopback, port));
            sim._acceptLoop = sim.SerialResponderLoop(expectedCommand, reply, sim._cts.Token);
            return sim;
        }

        /// <summary>
        /// HTTP responder: replies with a minimal 200 OK response for any complete HTTP request.
        /// </summary>
        public static TcpDeviceSimulator StartHttpResponder(string body, string contentType = "application/xml")
        {
            var sim = new TcpDeviceSimulator(new TcpListener(IPAddress.Loopback, 0));
            sim._acceptLoop = sim.HttpResponderLoop(body, contentType, sim._cts.Token);
            return sim;
        }

        /// <summary>
        /// Push-on-connect: immediately sends <paramref name="payload"/> to every accepted connection.
        /// </summary>
        public static TcpDeviceSimulator StartPushOnConnect(byte[] payload)
        {
            var sim = new TcpDeviceSimulator(new TcpListener(IPAddress.Loopback, 0));
            sim._acceptLoop = sim.PushOnConnectLoop(payload, sim._cts.Token);
            return sim;
        }

        /// <summary>Returns a free loopback TCP port.</summary>
        public static int GetFreeTcpPort()
        {
            var listener = new TcpListener(IPAddress.Loopback, 0);
            listener.Start();
            int port = ((IPEndPoint)listener.LocalEndpoint).Port;
            listener.Stop();
            return port;
        }

        /// <summary>
        /// Connects to 127.0.0.1:<paramref name="port"/> and sends <paramref name="payload"/> as if
        /// we are a remote device. Use for smart-serial elements in server mode (loopback polling IP).
        /// Returns false with a reason string if the connection cannot be made within <paramref name="timeout"/>.
        /// </summary>
        public static bool TryPushToElement(int port, byte[] payload, TimeSpan timeout, out string detail)
        {
            try
            {
                using (var client = new TcpClient())
                {
                    if (!client.ConnectAsync(IPAddress.Loopback, port).Wait((int)timeout.TotalMilliseconds))
                    {
                        detail = $"Connection to 127.0.0.1:{port} timed out after {timeout.TotalSeconds}s";
                        return false;
                    }

                    using (NetworkStream ns = client.GetStream())
                    {
                        ns.Write(payload, 0, payload.Length);
                    }

                    detail = $"Pushed {payload.Length} bytes to 127.0.0.1:{port}";
                    return true;
                }
            }
            catch (Exception ex)
            {
                detail = $"Push to 127.0.0.1:{port} failed: {ex.Message}";
                return false;
            }
        }

        // ──────────────────────────────────────────────────────────
        // Background accept loops
        // ──────────────────────────────────────────────────────────

        private async Task SerialResponderLoop(string command, string reply, CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                TcpClient client;
                try { client = await _listener.AcceptTcpClientAsync(); }
                catch { return; }

#pragma warning disable CS4014
                Task.Run(async () =>
                {
                    using (client)
                    {
                        NetworkStream ns = client.GetStream();
                        byte[] buf = new byte[4096];
                        StringBuilder received = new StringBuilder();
                        while (!ct.IsCancellationRequested)
                        {
                            int n;
                            try { n = await ns.ReadAsync(buf, 0, buf.Length, ct); }
                            catch { return; }
                            if (n == 0) return;
                            string chunk = Encoding.ASCII.GetString(buf, 0, n);
                            received.Append(chunk);
                            lock (_receivedLog) _receivedLog.Append(chunk);
                            if (received.ToString().Contains(command))
                            {
                                byte[] r = Encoding.ASCII.GetBytes(reply);
                                await ns.WriteAsync(r, 0, r.Length, ct);
                            }
                        }
                    }
                });
#pragma warning restore CS4014
            }
        }

        private async Task HttpResponderLoop(string body, string contentType, CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                TcpClient client;
                try { client = await _listener.AcceptTcpClientAsync(); }
                catch { return; }

#pragma warning disable CS4014
                Task.Run(async () =>
                {
                    using (client)
                    {
                        NetworkStream ns = client.GetStream();
                        byte[] buf = new byte[4096];
                        StringBuilder headerBuf = new StringBuilder();
                        while (!headerBuf.ToString().Contains("\r\n\r\n"))
                        {
                            int n;
                            try { n = await ns.ReadAsync(buf, 0, buf.Length); }
                            catch { return; }
                            if (n == 0) return;
                            string chunk = Encoding.ASCII.GetString(buf, 0, n);
                            headerBuf.Append(chunk);
                            lock (_receivedLog) _receivedLog.Append(chunk);
                        }

                        byte[] bodyBytes = Encoding.UTF8.GetBytes(body);
                        string responseHeaders =
                            "HTTP/1.1 200 OK\r\n" +
                            $"Content-Type: {contentType}\r\n" +
                            $"Content-Length: {bodyBytes.Length}\r\n" +
                            "Connection: close\r\n\r\n";
                        byte[] headBytes = Encoding.ASCII.GetBytes(responseHeaders);
                        await ns.WriteAsync(headBytes, 0, headBytes.Length);
                        await ns.WriteAsync(bodyBytes, 0, bodyBytes.Length);
                    }
                });
#pragma warning restore CS4014
            }
        }

        private async Task PushOnConnectLoop(byte[] payload, CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                TcpClient client;
                try { client = await _listener.AcceptTcpClientAsync(); }
                catch { return; }

#pragma warning disable CS4014
                Task.Run(async () =>
                {
                    using (client)
                    {
                        NetworkStream ns = client.GetStream();
                        await ns.WriteAsync(payload, 0, payload.Length, ct);
                        byte[] buf = new byte[512];
                        try
                        {
                            while (!ct.IsCancellationRequested)
                            {
                                int n = await ns.ReadAsync(buf, 0, buf.Length, ct);
                                if (n == 0) break;
                                lock (_receivedLog)
                                    _receivedLog.Append(Encoding.ASCII.GetString(buf, 0, n));
                            }
                        }
                        catch { /* connection closed */ }
                    }
                });
#pragma warning restore CS4014
            }
        }
    }
}
```

## Usage Examples

### Serial request/response

```csharp
using (var sim = TcpDeviceSimulator.StartSerialResponder("PING", "PONG"))
{
    var conn = new SerialConnection(new Tcp("127.0.0.1", sim.Port));
    IDmsElement element = dms.GetAgent(agentId).CreateElement(
        new ElementConfiguration(dms, "Test Serial", protocol) { Connections = { [0] = conn } });
    try
    {
        // Wait for element to poll
        Thread.Sleep(5000);
        Assert.IsTrue(sim.ReceivedText.Contains("PING"),
            $"Simulator on port {sim.Port} never received PING. ReceivedText: '{sim.ReceivedText}'");
    }
    finally { dms.GetElement(element.DmsElementId).Delete(); }
}
```

### HTTP request/response

```csharp
// Tip: the body must match the QAction's XmlSerializer model exactly.
// If the model has [XmlAttributeAttribute] with no explicit Name, the attribute is the C# property name.
string body = "<server tempunit=\"C\"><temp>21.5</temp></server>";

using (var sim = TcpDeviceSimulator.StartHttpResponder(body))
{
    var conn = new HttpConnection(new Tcp("127.0.0.1", sim.Port));
    // ...
}
```

### Smart-serial (server mode — element listens, test connects)

```csharp
int listenPort = 10001; // match the element's polling port
using (var element = /* create smart-serial element on port listenPort */)
{
    byte[] frame = /* protocol-specific push frame */;
    string pushDetail;
    bool pushed = TcpDeviceSimulator.TryPushToElement(
        listenPort, frame, TimeSpan.FromSeconds(60), out pushDetail);

    if (!pushed)
        Assert.Inconclusive($"Could not push to smart-serial element on this DaaS target. {pushDetail}");

    // wait for parameter update, assert PID value
}
```
