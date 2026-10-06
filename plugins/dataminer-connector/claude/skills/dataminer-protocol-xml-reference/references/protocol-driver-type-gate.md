# Connection Family Schema Gate

Authority scope: authored from `protocol.xsd` 1.1.10. This file maps connection-family XML vocabulary.
Coverage: complete for the connection-family top-level vocabulary listed here. Descendant structures are authorized by `protocol-portsettings-connections.md`, `protocol-http.md`, `protocol-snmp.md`, and `protocol-execution.md`.

## Main Type

`/Protocol/Type` must be one of the `EnumProtocolType` values listed in `protocol-types-and-enums.md`.

`/Protocol/Type@advanced` is `xs:string`; the schema does not enumerate its semicolon-separated content.

## Family-Specific Top-Level Containers

The schema permits these top-level containers regardless of the value of `/Protocol/Type`; family correctness beyond schema vocabulary is a runtime/validator concern.

Schema vocabulary by family:

- HTTP sessions: `/Protocol/HTTP` -> `Session`.
- SNMP protocol marker: `/Protocol/SNMP` fixed `auto`, `@includepages="true"`.
- SNMP parameter settings: `/Protocol/Params/Param/SNMP`.
- Serial/smart-serial/WebSocket message framing: `/Protocol/Commands`, `/Protocol/Responses`, `/Protocol/Pairs`.
- Legacy port settings: `/Protocol/PortSettings`, `/Protocol/Ports/PortSettings`.
- Newer connection model: `/Protocol/Connections/Connection` with one schema-defined family element.

This schema reference tells which tags exist. Runtime and validator references decide whether a connector uses a family.
