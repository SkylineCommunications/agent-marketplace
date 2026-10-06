# Serial And Smart-Serial Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for serial/smart-serial protocol type values, message-structure containers, framing-related parameter type values, and `WebSocketMessageType` values listed here.

## Protocol Types

Serial-family protocol type values in `EnumProtocolType`:

- `serial`
- `serial single`
- `smart-serial`
- `smart-serial single`

## Message Structure Containers

The XSD message-framing containers are:

- `/Protocol/Commands`
- `/Protocol/Responses`
- `/Protocol/Pairs`
- `/Protocol/Groups`
- `/Protocol/Triggers`
- `/Protocol/Actions`
- `/Protocol/Timers`

Their schema structure is listed in `protocol-execution.md`.

## Framing Parameter Types

Serial/smart-serial framing uses parameter type values from `EnumParamType`, including:

- `header`
- `trailer`
- `fixed`
- `length`
- `crc`
- `read`
- `write`
- `response`
- `read bit`
- `write bit`
- `group`

Use `protocol-params.md` for the allowed `Param` child/attribute vocabulary.

## WebSocket Message Type

`Command/WebSocketMessageType` uses `EnumWebSocketMessageType` values:

- `binary`
- `text`

This tag exists under `Command` in the XSD and is not limited by schema to `/Protocol/Type=websocket`; runtime usage is covered in logic files.

## Swarming And Smart-Serial Server Mode

For the version-gated Swarming override associated with a smart-serial connection in server mode, load `protocol-root.md` for the element structure and `protocol-types-and-enums.md` for the allowed bypass-check value. This file does not independently authorize that root branch.
