# PortSettings And Connections Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `/Protocol/Type`, `/Protocol/Connections`, `/Protocol/PortSettings`, and `/Protocol/Ports/PortSettings` branches listed here. Unlisted connection descendants and setting names MUST NOT be authored.

## Protocol/Type

`/Protocol/Type` uses `EnumProtocolType`; values and attributes are listed in `protocol-types-and-enums.md`.

## Connections Model

`/Protocol/Connections`:

- Optional root child.
- Contains `Connection` one or more times.

`Connections/Connection`:

- Required attributes: `id` `xs:unsignedInt`, `name` `TypeNonEmptyString`.
- Content is a choice of exactly one family: `Virtual`, `Snmp`, `SnmpV2`, `SnmpV3`, `Http`, `Serial`, `SmartSerial`, `Gpib`, `Opc`.

Unless stated otherwise, connection-family `CommunicationOptions` and `UserSettings` children are optional and occur at most once.

## Connection Families

`Connection/Virtual`:

- Empty element; no attributes, children, `CommunicationOptions`, or `UserSettings`.

`Connection/Snmp` and `Connection/SnmpV2`:

- Optional `CommunicationOptions`; optional `UserSettings`.
- `CommunicationOptions` children: `RedundantPolling` `EnumTrueFalse`.
- `UserSettings` children: `BusAddress`, `GetCommunity`, `IPport`, `Retries`, `SetCommunity`, `TimeoutTime`.

`Connection/SnmpV3`:

- Optional `CommunicationOptions`; optional `UserSettings`.
- `CommunicationOptions` children: `DynamicContextID` string, `DynamicContextName` string, `RedundantPolling` `EnumTrueFalse`.
- `UserSettings` children: `AuthenticationAlgorithm`, `AuthenticationPassword`, `BusAddress`, `EncryptionAlgorithm`, `EncryptionPassword`, `IPport`, `Retries`, `SecurityLevel`, `TimeoutTime`, `UserName`.

`Connection/Http`:

- Optional `CommunicationOptions`; optional `UserSettings`.
- `CommunicationOptions` children: `MakeCommandByProtocol` `EnumTrueFalse`, `NotifyConnectionPIDs`, `RedundantPolling` `EnumTrueFalse`, `WebSocket` `EnumTrueFalse`, `WebSocketHandshake` unsigned integer.
- `NotifyConnectionPIDs`: optional `Connections`, optional `Disconnections`; both `TypeParamId`.
- `WebSocket`: `EnumTrueFalse`; `WebSocketHandshake`: unsigned HTTP session ID.
- `UserSettings` children: `BusAddress`, `IPport`, `Retries`, `TimeoutTime`.

`Connection/Serial`:

- Optional `@single` `EnumTrueFalse`.
- Optional `CommunicationOptions`; optional `UserSettings`.
- `CommunicationOptions` children: `ChunkedHTML` `EnumTrueFalse`, `CloseConnectionOnResponse` `EnumTrueFalse`, `KexAlgorithms`, `MakeCommandByProtocol` `EnumTrueFalse`, `RedundantPolling` `EnumTrueFalse`.
- `KexAlgorithms/KexAlgorithm`: one or more; values `diffie-hellman-group1-sha1`, `diffie-hellman-group-exchange-sha1`, `diffie-hellman-group14-sha1`, `ecdh-sha2-nistp256`.
- `UserSettings` children: `Baudrate`, `BusAddress`, `Databits`, `Flowcontrol`, `IPport`, `LocalIPport`, `Parity`, `PortTypeIP`, `PortTypeSerial`, `PortTypeUDP`, `Retries`, `SslTlsEnabled`, `Stopbits`, `TimeoutTime`, `Type`.

`Connection/SmartSerial`:

- Optional `@single` `EnumTrueFalse`.
- Optional `CommunicationOptions`; optional `UserSettings`.
- `CommunicationOptions` children: `MakeCommandByProtocol` `EnumTrueFalse`, `MaxConcurrentConnections` unsigned integer, `MaxReceiveBuffer` unsigned integer, `NotifyConnectionPIDs`, `PacketInfo`, `RedundantPolling` `EnumTrueFalse`, `SmartIPHeader` `EnumTrueFalse`.
- `PacketInfo` children: `LengthIdentifierOffset`, `LengthIdentifierLength`, `IncludeLengthIdentifier`, `LittleEndian`.
- `UserSettings` children: `AllowedIPAddresses`, `BusAddress`, `IPport`, `PortTypeIP`, `PortTypeUDP`, `Retries`, `SslTlsEnabled`, `TimeoutTime`, `Type`.

`Connection/Gpib`:

- Optional empty `CommunicationOptions`; optional `UserSettings`.
- `UserSettings` children: `DeviceAddress`, `Retries`, `TimeoutTime`.

`Connection/Opc`:

- Optional `CommunicationOptions`; optional empty `UserSettings`.
- `CommunicationOptions` child: `ProgID` string.

## Connection User Setting Shapes

- `BusAddress` and `DeviceAddress`: optional `DefaultValue` string, optional `Disabled`, optional `Range`, optional `Values/Value` list.
- `IPport` and `LocalIPport`: optional `DefaultValue` `TypePortNumber`, optional `Disabled`.
- `TimeoutTime` and `Retries`: optional `DefaultValue` unsigned integer, optional `Disabled`; in `Connection/Gpib/UserSettings`, `DefaultValue` is `xs:string`.
- `GetCommunity` and `SetCommunity`: optional `DefaultValue` string, optional `Disabled`.
- `SecurityLevel`, `AuthenticationAlgorithm`, `EncryptionAlgorithm`, `UserName`, `AuthenticationPassword`, `EncryptionPassword`: SNMPv3-only settings; each has required `DefaultValue` string when the setting element exists.
- `Baudrate`: optional `DefaultValue` unsigned integer, optional `Disabled`, optional `Range`, optional `Values` with zero or more string `Value` entries.
- `Databits`: optional `DefaultValue` string, optional `Disabled`, optional `Range`, optional `Values` with one or more unsigned integer `Value` entries.
- `Flowcontrol`: optional `DefaultValue`, optional `Disabled`, optional `Range`, required `Values` with one or more `EnumPortSettingsFlowControl` `Value` entries.
- `Parity`: optional `DefaultValue`, optional `Disabled`, optional `Range`, required `Values` with zero or more `EnumPortSettingsParity` `Value` entries.
- `Stopbits`: optional `DefaultValue`, optional `Disabled`, optional `Values` with one or more `EnumPortSettingsStopBits` `Value` entries.
- `Type`: optional `DefaultValue` `EnumPortTypes`.
- `AllowedIPAddresses`: optional `Disabled` `EnumTrueFalse`.
- `PortTypeIP`, `PortTypeSerial`, `PortTypeUDP`: optional `Disabled` `EnumTrueFalse`.
- `SslTlsEnabled`: optional `DefaultValue` `EnumTrueFalse`, optional `Disabled` `EnumTrueFalse`.

## Legacy Port Settings

Legacy/main connection model uses:

- `/Protocol/PortSettings`: optional root child, type `PortSettingsMain`, required `@name`.
- `/Protocol/Ports/PortSettings`: zero or more additional port settings, type `PortSettings`, required `@name`, optional `@visibleInUi`.

`PortSettingsMain` allowed child settings:

- `Baudrate`, `BusAddress`, `Databits`, `Flowcontrol`, `FlushPerDatagram`, `GetCommunity`, `IPport`, `LocalIPport`, `Parity`, `PingInterval`, `PortTypeIP`, `PortTypeSerial`, `PortTypeUDP`, `Retries`, `SetCommunity`, `SkipCertificateVerification`, `SlowPoll`, `SlowPollBase`, `SSH`, `Stopbits`, `TimeoutTime`, `TimeoutTimeElement`, `Type`.

`Ports/PortSettings` allowed child settings:

- Same as `PortSettingsMain` except `SlowPoll` and `SlowPollBase` are not allowed.

## Legacy Port Setting Shapes

Legacy `/Protocol/PortSettings` and `/Protocol/Ports/PortSettings` setting elements use direct repeated `Value` children where values are supported:

- `Baudrate`: optional `DefaultValue` unsigned integer, optional `Disabled`, optional `Range`, zero or more direct `Value` strings.
- `BusAddress`: optional `DefaultValue` string, optional `Disabled`, optional `Range`, zero or more direct `Value` strings.
- `Databits`: optional `DefaultValue` string, optional `Disabled`, optional `Range`, zero or more direct unsigned integer `Value` entries.
- `Flowcontrol`: optional `DefaultValue`, optional `Disabled`, optional `Range`, zero or more direct `Value` entries; values use `EnumPortSettingsFlowControl`.
- `Parity`: optional `DefaultValue`, optional `Disabled`, optional `Range`, zero or more direct `Value` entries; values use `EnumPortSettingsParity`.
- `Stopbits`: optional `DefaultValue`, optional `Disabled`, zero or more direct `Value` entries; values use `EnumPortSettingsStopBits`.
- `IPport` and `LocalIPport`: optional `DefaultValue` `TypePortNumber`; optional `Disabled`.
- `Retries`: optional `DefaultValue` `TypePortRetryCount`; optional `Disabled`.
- `TimeoutTime`: optional `DefaultValue` unsigned integer constrained to `10..120000`; optional `Disabled` `EnumTrueFalse`.
- `Type`: optional `DefaultValue` using `EnumPortTypes`.
- `SlowPollBase`: optional `DefaultValue` using `EnumTypePortSlowPollBase`; optional `Disabled`.
- `PortTypeIP`, `PortTypeSerial`, `PortTypeUDP`: optional `Disabled` `EnumTrueFalse`.
- `PingInterval`: optional `DefaultValue` `TypePingInterval`; optional `Disabled` `EnumTrueFalse`.
- `SlowPoll`: optional `DefaultValue` `TypePortSlowPoll`; optional `Disabled` `EnumTrueFalse`.
- `TimeoutTimeElement`: optional `DefaultValue` unsigned integer constrained to `1000..120000` and pattern `^\d+000$`; optional `Disabled` `EnumTrueFalse`.
- `SSH/Credentials/Username@pid`, `SSH/Credentials/Password@pid`, and `SSH/Identity@pid`: required PID attributes referencing existing params.
- `FlushPerDatagram` uses `EnumTrueFalse` text content.
- `SkipCertificateVerification`: optional `DefaultValue` `EnumTrueFalse`; optional `Disabled` `EnumTrueFalse`.

Connection-family `UserSettings` use `Values/Value` wrappers for value lists where the family-specific setting defines allowed values. Legacy `PortSettings` uses direct `Value` children. Do not copy one setting shape into the other.

Do not add old/removed setting names such as `PortNumber`.
