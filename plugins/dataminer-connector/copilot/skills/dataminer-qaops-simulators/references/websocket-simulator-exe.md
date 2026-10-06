# WebSocket Device Simulator — Console Exe

A standalone `net48` console application that acts as an RFC-6455 WebSocket server over raw `TcpListener`. Used as a packaged external process started from MSTest rather than an in-test class, because `HttpListener` requires URL ACL elevation that is not available on QAOps DaaS.

## Project Setup

### `WebSocketDeviceSimulator.csproj`

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net48</TargetFramework>
    <!-- Ensure the exe can be started from tests.generated without .NET installer constraints -->
  </PropertyGroup>
</Project>
```

Place at: `IntegrationTests/Simulators/WebSocketDeviceSimulator/WebSocketDeviceSimulator.csproj`

### Wire Into IntegrationTests

In `IntegrationTests.csproj`:

```xml
<!-- Exclude from SDK compilation of IntegrationTests itself -->
<ItemGroup>
  <Compile Remove="Simulators\**" />
  <Content Remove="Simulators\**" />
  <None Remove="Simulators\**" />
</ItemGroup>

<!-- Build-order dependency: simulator always builds before IntegrationTests -->
<ItemGroup>
  <ProjectReference
    Include="Simulators\WebSocketDeviceSimulator\WebSocketDeviceSimulator.csproj"
    ReferenceOutputAssembly="false" />
</ItemGroup>

<!-- Copy simulator output into bin so the harvesting step picks it up -->
<Target Name="CopyWebSocketSimulatorToOutput" AfterTargets="Build"
        BeforeTargets="CopyBinToQaOpsHarvestingTestsGenerated">
  <ItemGroup>
    <_SimulatorOutput Include="$(MSBuildThisFileDirectory)Simulators\WebSocketDeviceSimulator\bin\$(Configuration)\net48\**\*.*" />
  </ItemGroup>
  <Copy SourceFiles="@(_SimulatorOutput)"
        DestinationFiles="@(_SimulatorOutput->'$(TargetDir)Simulators\WebSocketDeviceSimulator\%(RecursiveDir)%(Filename)%(Extension)')"
        SkipUnchangedFiles="true" />
</Target>
```

## `Program.cs` — Full Implementation

```csharp
namespace WebSocketDeviceSimulator
{
    using System;
    using System.Net;
    using System.Net.Sockets;
    using System.Security.Cryptography;
    using System.Text;

    internal static class Program
    {
        private static int Main(string[] args)
        {
            int port = 0;
            string replyMessage = "PONG";

            for (int i = 0; i < args.Length; i++)
            {
                if ((args[i] == "--port" || args[i] == "-p") && i + 1 < args.Length)
                {
                    if (!int.TryParse(args[++i], out port))
                    {
                        Console.Error.WriteLine("Invalid port.");
                        return 1;
                    }
                }
                else if (args[i] == "--reply" && i + 1 < args.Length)
                {
                    replyMessage = args[++i];
                }
            }

            var listener = new TcpListener(IPAddress.Loopback, port);
            listener.Start();
            int boundPort = ((IPEndPoint)listener.LocalEndpoint).Port;
            Console.WriteLine($"READY:{boundPort}");

            while (true)
            {
                TcpClient client;
                try { client = listener.AcceptTcpClient(); }
                catch { break; }

                try
                {
                    using (client)
                    using (NetworkStream ns = client.GetStream())
                    {
                        // Read the HTTP Upgrade request
                        string upgrade = ReadHttpHeaders(ns);
                        string key = ExtractWebSocketKey(upgrade);

                        // Send 101 Switching Protocols
                        string accept = ComputeAcceptKey(key);
                        string response =
                            "HTTP/1.1 101 Switching Protocols\r\n" +
                            "Upgrade: websocket\r\n" +
                            "Connection: Upgrade\r\n" +
                            $"Sec-WebSocket-Accept: {accept}\r\n\r\n";
                        byte[] responseBytes = Encoding.ASCII.GetBytes(response);
                        ns.Write(responseBytes, 0, responseBytes.Length);
                        Console.WriteLine("HANDSHAKE");

                        // Frame exchange loop
                        while (true)
                        {
                            string received = ReadTextFrame(ns);
                            if (received == null) break;
                            Console.WriteLine($"RECEIVED:{received}");

                            byte[] reply = BuildTextFrame(replyMessage);
                            ns.Write(reply, 0, reply.Length);
                            Console.WriteLine($"SENT:{replyMessage}");
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"Connection error: {ex.Message}");
                }
            }

            return 0;
        }

        private static string ReadHttpHeaders(NetworkStream ns)
        {
            var sb = new StringBuilder();
            byte[] buf = new byte[4096];
            while (!sb.ToString().Contains("\r\n\r\n"))
            {
                int n = ns.Read(buf, 0, buf.Length);
                if (n == 0) break;
                sb.Append(Encoding.ASCII.GetString(buf, 0, n));
            }
            return sb.ToString();
        }

        private static string ExtractWebSocketKey(string headers)
        {
            const string prefix = "Sec-WebSocket-Key: ";
            int start = headers.IndexOf(prefix, StringComparison.Ordinal);
            if (start < 0) return string.Empty;
            start += prefix.Length;
            int end = headers.IndexOf("\r\n", start, StringComparison.Ordinal);
            return end < 0 ? headers.Substring(start) : headers.Substring(start, end - start);
        }

        private static string ComputeAcceptKey(string key)
        {
            const string magic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
            using (var sha1 = SHA1.Create())
            {
                byte[] combined = Encoding.ASCII.GetBytes(key + magic);
                return Convert.ToBase64String(sha1.ComputeHash(combined));
            }
        }

        /// <summary>
        /// Reads one RFC-6455 text frame. Returns null on connection close/error.
        /// Handles masking (client→server frames are always masked).
        /// </summary>
        private static string ReadTextFrame(NetworkStream ns)
        {
            byte[] header = new byte[2];
            if (!ReadFully(ns, header, 2)) return null;

            bool isMasked = (header[1] & 0x80) != 0;
            long payloadLen = header[1] & 0x7F;

            if (payloadLen == 126)
            {
                byte[] ext = new byte[2];
                if (!ReadFully(ns, ext, 2)) return null;
                payloadLen = (ext[0] << 8) | ext[1];
            }
            else if (payloadLen == 127)
            {
                byte[] ext = new byte[8];
                if (!ReadFully(ns, ext, 8)) return null;
                payloadLen = 0;
                for (int i = 0; i < 8; i++) payloadLen = (payloadLen << 8) | ext[i];
            }

            byte[] mask = new byte[4];
            if (isMasked && !ReadFully(ns, mask, 4)) return null;

            byte[] payload = new byte[payloadLen];
            if (!ReadFully(ns, payload, (int)payloadLen)) return null;

            if (isMasked)
                for (int i = 0; i < payload.Length; i++)
                    payload[i] ^= mask[i % 4];

            return Encoding.UTF8.GetString(payload);
        }

        private static byte[] BuildTextFrame(string text)
        {
            byte[] payload = Encoding.UTF8.GetBytes(text);
            int headerLen = payload.Length < 126 ? 2 : payload.Length < 65536 ? 4 : 10;
            byte[] frame = new byte[headerLen + payload.Length];
            frame[0] = 0x81; // FIN + opcode 1 (text)
            if (payload.Length < 126)
            {
                frame[1] = (byte)payload.Length; // no masking for server→client
            }
            else if (payload.Length < 65536)
            {
                frame[1] = 126;
                frame[2] = (byte)(payload.Length >> 8);
                frame[3] = (byte)(payload.Length & 0xFF);
            }
            // >65535 not needed for test use
            Array.Copy(payload, 0, frame, headerLen, payload.Length);
            return frame;
        }

        private static bool ReadFully(NetworkStream ns, byte[] buffer, int count)
        {
            int offset = 0;
            while (offset < count)
            {
                int n = ns.Read(buffer, offset, count - offset);
                if (n == 0) return false;
                offset += n;
            }
            return true;
        }
    }
}
```

## Stdout Protocol (consumed by `WebSocketSimulatorProcess`)

| Line | Meaning |
|------|---------|
| `READY:<port>` | Simulator bound successfully; port is the actual bound port (useful when started with port 0). |
| `HANDSHAKE` | WebSocket upgrade completed with a client. |
| `RECEIVED:<payload>` | A text frame was received from the client. |
| `SENT:<payload>` | The reply frame was sent. |
| Anything on stderr | Error/warning, log to test output. |

