# Serial Connection Deep Dive

Detailed patterns for serial, SSH, and smart-serial connections in DataMiner connectors.

---

## Parameter Types in Commands/Responses

Parameters in serial commands/responses have special `<Type>` values:

| Param Type | Purpose | LengthType | Notes |
|-----------|---------|------------|-------|
| `fixed` | Fixed-value delimiter (header, trailer, separator) | `fixed` | Value as hex (`0x0D0x0A`) or plain text |
| `read` | Variable data field | `next param` or `other param` | Receives/sends actual data |
| `length` | Length field — specifies byte count of another param | `fixed` | References target via `<Length><Content><Param>` |
| `crc` | CRC checksum field | `fixed` | Computed over specified params via `<CRC>` |
| `header` | Frame start marker | `fixed` | Identifies start of frame |
| `trailer` | Frame end marker | `fixed` | Identifies end of frame |
| `response` | Nested response container | — | Structures multi-field data |

---

## Header/Trailer Frame Example

```xml
<Param id="100">
   <Name>Header STX</Name>
   <Type>header</Type>
   <Interprete>
      <RawType>other</RawType>
      <LengthType>fixed</LengthType>
      <Length>1</Length>
      <Type>string</Type>
      <Value>0x02</Value>
   </Interprete>
</Param>

<Param id="101">
   <Name>Trailer ETX</Name>
   <Type>trailer</Type>
   <Interprete>
      <RawType>other</RawType>
      <LengthType>fixed</LengthType>
      <Length>1</Length>
      <Type>string</Type>
      <Value>0x03</Value>
   </Interprete>
</Param>
```

---

## Length Field Example

```xml
<Param id="303">
   <Name>DataLengthField</Name>
   <Type>length</Type>
   <Interprete>
      <RawType>numeric text</RawType>
      <LengthType>fixed</LengthType>
      <Length>2</Length>
      <Type>double</Type>
   </Interprete>
   <Length>
      <Content>
         <Param>304</Param>
      </Content>
   </Length>
</Param>

<Param id="304">
   <Name>VariableData</Name>
   <Type>read</Type>
   <Interprete>
      <RawType>other</RawType>
      <LengthType>other param</LengthType>
      <Length>303</Length>
      <Type>string</Type>
   </Interprete>
</Param>
```

---

## CRC Checksum Example

```xml
<Param id="3000">
   <Name>CRC</Name>
   <Type>crc</Type>
   <Interprete>
      <RawType>unsigned number</RawType>
      <LengthType>fixed</LengthType>
      <Length>1</Length>
      <Type>double</Type>
   </Interprete>
   <CRC>
      <Type mod="95" off="-32" totaloffset="32">sum</Type>
      <Content>
         <Param>0</Param>
         <Param>1</Param>
         <Param>2</Param>
      </Content>
   </CRC>
</Param>
```

CRC `<Type>` values: `sum`, `exor`. Use `<Base>16</Base>` for hex output. Requires a CRC action:

```xml
<Action id="410">
   <Name>Response CRC</Name>
   <On>response</On>
   <Type>crc</Type>
</Action>
```

---

## Variable-Length Response Triggers

Responses with `LengthType` of `next param` or `other param` require a "before response" trigger:

```xml
<Trigger id="12">
   <Name>Before Response Each</Name>
   <On id="each">response</On>
   <Time>before</Time>
   <Type>action</Type>
   <Content><Id>12</Id></Content>
</Trigger>
<Action id="12">
   <Name>Read Response</Name>
   <On>response</On>
   <Type>read</Type>
</Action>
```

Execute actions in order: **read** → **length** → **crc** (if applicable).

---

## Response Matching Rules

- Responses wait until timeout unless header+trailer are defined, all params are fixed-length, or a length field exists.
- If matching fails at a non-fixed parameter, **all** non-fixed parameters in the response are emptied.
- Use the `ping` attribute on a Pair for connection-health checking: `<Pair id="1" ping="true">`.

---

## SSH Connection

SSH connections use `serial` type with SSH-specific `<PortSettings>`:

```xml
<PortSettings name="SSH Connection">
   <IPport>
      <DefaultValue>22</DefaultValue>
   </IPport>
   <BusAddress>
      <Disabled>true</Disabled>
   </BusAddress>
   <PortTypeSerial>
      <Disabled>true</Disabled>
   </PortTypeSerial>
   <PortTypeUDP>
      <Disabled>true</Disabled>
   </PortTypeUDP>
   <SSH>
      <Credentials>
         <Username pid="1100"/>
         <Password pid="1101"/>
      </Credentials>
   </SSH>
</PortSettings>
```

**Public key authentication** (takes precedence over password when both configured):

```xml
<SSH>
   <Identity pid="1102"/>
   <Credentials>
      <Username pid="1100"/>
   </Credentials>
</SSH>
```

**Key exchange algorithm selection:**

```xml
<Connection id="1" name="SSH Connection">
   <Type>serial</Type>
   <CommunicationOptions>
      <KexAlgorithms>
         <KexAlgorithm>diffie-hellman-group1-sha1</KexAlgorithm>
         <KexAlgorithm>diffie-hellman-group-exchange-sha1</KexAlgorithm>
      </KexAlgorithms>
   </CommunicationOptions>
</Connection>
```

**SSH rules:**
- Headers are **not supported** — only trailers work.
- Do not send CR/LF (`0x0D0x0A`) in SSH commands — DataMiner handles line termination.
- Separating multiple commands with `;` or newlines in one DataMiner command is not supported.
- The first part of an SSH response echoes the sent command.
- Password parameters must use `<Measurement><Type options="password">string</Type></Measurement>`.

---

## Code Pages (Character Encoding)

By default, serial connectors use the Windows system ANSI code page (typically Windows-1252). To enable full Unicode support:

```xml
<Protocol type="serial" options="unicode">
```

When `unicode` is enabled:
- String parameters use UTF-16 encoding.
- Fixed parameter `<Length>` is in bytes (UTF-16 = 2 bytes per character).
- Use `<Command ascii="true">` to force specific commands to send as single-byte Windows code page encoding.
- Use `<Command ascii="12,34">` to convert only specific parameter IDs.
- `RawType` of `numeric text` always uses ASCII regardless of unicode setting.

---

## Smart-Serial

Smart-serial devices can send **unsolicited messages** without receiving a command first. The DMA can act as server (listening) or client (connecting).

**Key differences from serial:**
- Primarily uses **responses only** (not command-response pairs), since data arrives unsolicited.
- Commands can still be sent if needed.
- Works on TCP and UDP.
- For UDP: use only one client per socket — multiple clients sharing a socket may cause responses to route to the wrong client.

**Type declaration:**

```xml
<Type relativeTimers="true" advanced="serial:SSH Connection">smart-serial</Type>
```

**Response design rules:**
- Define responses so that data intended for one response cannot accidentally match another.
- Avoid responses consisting of only one `next param` parameter — such a response matches **everything**, starving other responses.
- Use header/trailer parameters or length fields to create unambiguous response boundaries.

### Smart-Serial Server Mode

For a smart-serial server, set the connection IP to `any` and configure the listening port. Record the maximum client count, `AllowedIPAddresses` behavior, and whether an after-response trigger is required to return a reply to the initiating client. See the [smart-serial server guide](https://aka.dataminer.services/connections-smart-serial-server).

From DataMiner 10.6.6/10.7.0 onward, incoming smart-serial messages waiting for processing are bounded at 200 MB (notice) and 300 MB (error/rejection). Repeated queue pressure requires evidence-based review of source rate, QAction processing time, and DMA resources; do not hide dropped data by merely increasing logging.

### Server-Mode Swarming

Server-mode smart-serial elements are not swarmable by default. From DataMiner 10.6.6/10.7.0, only enable the documented bypass when startup logic can tell the data source where to send data:

```xml
<Swarming>
   <BypassChecks>
      <Check>smartSerialAsServer</Check>
   </BypassChecks>
</Swarming>
```

Reference: [Enabling Swarming for smart-serial server mode](https://aka.dataminer.services/swarming-smart-serial-server-mode).

### TLS for TCP/IP Serial Server Connections

TLS is configured on every DMA that can host the server element: place the PKCS12 certificate in `C:\Skyline DataMiner\Certificates`, configure it with `ConfigureTLSMessage` in SLNetClientTest, and restart affected elements after certificate replacement. DataMiner negotiates up to TLS 1.3; TLS and non-TLS elements cannot share the same TCP/IP port, and certificates are not synchronized between DMAs.

Reference: [Enabling TLS encryption for serial communication](https://aka.dataminer.services/enabling-tls-encryption).

---

## Bit Manipulation Parameters

For serial protocols that pack multiple values into individual bytes/words, use `read bit` and `write bit` actions.

### Reading Bits from a Response

```xml
<Param id="200">
   <Name>StatusByte</Name>
   <Type>read</Type>
   <Interprete>
      <RawType>unsigned number</RawType>
      <LengthType>fixed</LengthType>
      <Length>1</Length>
      <Type>double</Type>
   </Interprete>
</Param>

<Param id="201">
   <Name>AlarmActive</Name>
   <Type>read bit</Type>
   <Interprete>
      <RawType>unsigned number</RawType>
      <LengthType>fixed</LengthType>
      <Length>1</Length>
      <Type>double</Type>
   </Interprete>
</Param>
```

Extract bits using a `read` action targeting the group parameter. The `read bit` type parameters reference their source via the response content ordering.

### Writing Bits in a Command

Use `write bit` type parameters to modify individual bits in a byte before sending a command. Combine with a `write` action of type `set`.

Reference: https://aka.dataminer.services/protocol-params-param-type
