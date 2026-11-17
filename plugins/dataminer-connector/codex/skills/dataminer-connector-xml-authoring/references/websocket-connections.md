# WebSocket Connection Deep Dive

Complete implementation patterns for WebSocket connections in DataMiner connectors.

---

## Connection Definition

```xml
<Connection id="1" name="WebSocket Connection">
   <Http>
      <CommunicationOptions>
         <WebSocket>true</WebSocket>
         <NotifyConnectionPIDs>
            <Connections>7</Connections>
         </NotifyConnectionPIDs>
         <MakeCommandByProtocol>true</MakeCommandByProtocol>
      </CommunicationOptions>
      <UserSettings>
         <BusAddress>
            <DefaultValue>bypassProxy</DefaultValue>
         </BusAddress>
         <IPport>
            <DefaultValue>80</DefaultValue>
         </IPport>
         <TimeoutTime>
            <DefaultValue>5000</DefaultValue>
         </TimeoutTime>
      </UserSettings>
   </Http>
</Connection>
```

---

## Use Cases (Choose One)

| Use Case | Dynamic IP | Custom Handshake | Auto-Reconnect | Recommendation |
|----------|-----------|-----------------|----------------|----------------|
| 1. Normal | No | No | **No** | **Do not use** — requires element restart after disconnect |
| 2. Dynamic IP | Yes | No | **Yes** | **Recommended** — most common, handles reconnection |
| 3. Custom Handshake | No | Yes | **No** | Stable environments only |
| 4. Dynamic IP + Custom Handshake | Yes | Yes | **Yes** | Full control with resilience |

For Dynamic IP, use a parameter with `<Type options="dynamic ip">read</Type>` to set the WebSocket URL at runtime.

---

## Required Triggers & Actions

```xml
<Trigger id="30">
   <Name>Before Each Command</Name>
   <On id="each">command</On>
   <Time>before</Time>
   <Type>action</Type>
   <Content><Id>30</Id></Content>
</Trigger>
<Action id="30">
   <Name>Make Command</Name>
   <On>command</On>
   <Type>make</Type>
</Action>

<Trigger id="31">
   <Name>Before Each Response</Name>
   <On id="each">response</On>
   <Time>before</Time>
   <Type>action</Type>
   <Content><Id>31</Id></Content>
</Trigger>
<Action id="31">
   <Name>Read Response</Name>
   <On>response</On>
   <Type>read</Type>
</Action>
```

---

## WebSocket Command (Text Frame)

```xml
<Command id="1">
   <Name>WebsocketHeartbeat</Name>
   <WebSocketMessageType>text</WebSocketMessageType>
   <Content><Param>10</Param></Content>
</Command>
```

- Default sends binary frames (opcode 0x2). Add `<WebSocketMessageType>text</WebSocketMessageType>` for text (opcode 0x1).

---

## WebSocket Status Parameter

```xml
<Param id="7" trending="true">
   <Name>WebsocketStatus</Name>
   <Description>Websocket Status</Description>
   <Type>read</Type>
   <Interprete>
      <RawType>numeric text</RawType>
      <LengthType>next param</LengthType>
      <Type>double</Type>
   </Interprete>
   <Alarm>
      <Monitored>true</Monitored>
      <Normal>1</Normal>
      <CH>0</CH>
   </Alarm>
   <Display><RTDisplay>true</RTDisplay></Display>
   <Measurement>
      <Type>discreet</Type>
      <Discreets>
         <Discreet><Display>Closed</Display><Value>0</Value></Discreet>
         <Discreet><Display>Open</Display><Value>1</Value></Discreet>
      </Discreets>
   </Measurement>
</Param>
```

- The parameter ID referenced in `<NotifyConnectionPIDs><Connections>` receives `0` (closed) or `1` (open).
- Only send commands when status is Open.

---

## Custom Handshake (Use Case 3 & 4)

```xml
<HTTP>
   <Session id="1">
      <Connection id="1">
         <Request verb="GET" url="/">
            <Headers>
               <Header key="Use-Cookie" pid="80" />
            </Headers>
         </Request>
      </Connection>
   </Session>
</HTTP>
```

DataMiner automatically appends WebSocket upgrade headers (`Upgrade: websocket`, `Connection: Upgrade`, `Sec-WebSocket-Key`, `Sec-WebSocket-Version: 13`).

---

## Unicode/Binary Handling

For Unicode WebSocket protocols, use a QAction with `options="binary"`:

```xml
<QAction id="100" name="Parse WebSocket Response" encoding="csharp"
         triggers="11" inputParameters="11" options="binary">
```

Then decode in C#:

```csharp
object[] bytestream = (object[])protocol.GetData("PARAMETER", 11);
byte[] response = new byte[bytestream.Length];
for (int i = 0; i < response.Length; i++)
   response[i] = (byte)bytestream[i];
string data = System.Text.Encoding.UTF8.GetString(response);
```

---

## Rules

- Always clear the generic response parameter after processing via `protocol.CheckTrigger(clearTriggerId)`.
- When the WebSocket connection closes, the element enters timeout state.
- The `connection` attribute on Groups directs traffic to the WebSocket connection (e.g., `connection="1"`).
