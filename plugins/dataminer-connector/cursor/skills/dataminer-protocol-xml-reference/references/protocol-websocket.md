# WebSocket-Related Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for WebSocket-specific schema locations and enum values. General HTTP session/request/response structure is in `protocol-http.md`; HTTP connection-family structure is in `protocol-portsettings-connections.md`.

## Connection-Level WebSocket Tags

WebSocket connection settings are only under the HTTP connection family:

- `/Protocol/Connections/Connection/Http/CommunicationOptions/WebSocket`: optional, `EnumTrueFalse`.
- `/Protocol/Connections/Connection/Http/CommunicationOptions/WebSocketHandshake`: optional, `xs:unsignedInt`; references the HTTP session ID used as custom opening handshake.

Do not author a standalone `WebSocket` root child or a `WebSocket` child under `/Protocol/HTTP`.

## Command Message Type

`/Protocol/Commands/Command/WebSocketMessageType`:

- Optional child of `Command`.
- Values: `binary`, `text`.

No other `WebSocketMessageType` values are valid.

## HTTP Headers

WebSocket handshake headers use the ordinary HTTP header schema. The header allowlists in `protocol-http-headers.md` include `Sec-WebSocket-Key`, `Sec-WebSocket-Accept`, `Sec-WebSocket-Extensions`, `Sec-WebSocket-Protocol`, and `Sec-WebSocket-Version`.
