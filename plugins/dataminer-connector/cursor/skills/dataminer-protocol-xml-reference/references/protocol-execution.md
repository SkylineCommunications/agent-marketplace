# Execution Elements Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `/Protocol/Commands`, `/Protocol/Responses`, `/Protocol/Pairs`, `/Protocol/Groups`, `/Protocol/Timers`, `/Protocol/Triggers`, and `/Protocol/Actions` branches listed here. Unlisted children/attributes MUST NOT be authored.

## Commands

`/Protocol/Commands` contains `Command` zero or more times.

`Command`:

- Required `@id`: `TypeNonLeadingZeroUnsignedInt`.
- Optional `@ascii`: `TypeTrueOrSemicolonSeparatedNumbers`; value is `true` or semicolon-separated parameter IDs.
- Required child: `Content`.
- Optional children: `Description`, `Name`, `WebSocketMessageType`.
- `Content/Param`: zero or more, `TypeParamId`.
- `WebSocketMessageType` values: `binary`, `text`.
- Unique within commands: `Command@id`; `Command/Name` when present.

## Responses

`/Protocol/Responses` contains `Response` zero or more times.

`Response`:

- Required `@id`: `TypeNonLeadingZeroUnsignedInt`.
- Optional `@options`: `xs:string`.
- Required children: `Content`, `Name`.
- Optional child: `Description`.
- `Content@optional`: optional `xs:string`.
- `Content/Param`: zero or more, `TypeParamId`.
- Unique within responses: `Response@id`; `Response/Name`.

## Pairs

`/Protocol/Pairs` contains `Pair` zero or more times.

`Pair`:

- Required `@id`: `TypeNonLeadingZeroUnsignedInt`.
- Optional attributes: `options`, `ping`, `timeout`.
- Required children: `Content`, `Name`.
- Optional children: `Condition`, `Description`.
- `Content` sequence: required `Command`; zero or more `Response`; zero or more `ResponseOnBadCommand`.
- `Content/Command`, `Response`, `ResponseOnBadCommand`: unsigned integer references.
- Unique within pairs: `Pair@id`.

## Groups

`/Protocol/Groups` contains `Group` zero or more times.

`Group`:

- Required `@id`: `TypeObjectId`.
- Optional attributes: `connection` default `0`, `connectionPID`, `ping`, `threadId` default `-1`.
- Optional children: `Condition`, `Content`, `Description`, `Name`, `Type`.
- `Type` values are in `protocol-types-and-enums.md`.
- Unique within groups: `Group@id`; `Group/Name` when present.

`Group/Content`:

- Optional `@multipleGet`: `EnumTrueFalse`.
- Content is an `xs:choice`; use only one homogeneous item type in a group.
- Allowed item types: `Action`, `Pair`, `Param`, `Session`, `Trigger`.
- `Action`: `TypeObjectId`; optional `@next`.
- `Pair`: `TypeNonLeadingZeroUnsignedInt`; optional `@next`.
- `Param`: `TypeGroupParamId`; optional `@next`.
- `Session`: `TypeNonLeadingZeroUnsignedInt`; optional `@connection`, `@next`.
- `Trigger`: `TypeObjectId`; optional `@next`.
- Root keyrefs require `Pair`, `Action`, `Session`, and `Trigger` content values to reference existing IDs.

## Timers

`/Protocol/Timers` contains `Timer` zero or more times.

`Timers` optional attribute:

- `relativeTimers`: `EnumTrueFalse`.

`Timer`:

- Required `@id`: `TypeObjectId`.
- Optional attributes: `fixedTimer`, `options`.
- Required children: `Content`, `Interval`, `Time`.
- Optional children: `Condition`, `Name`.
- `Content/Group`: zero or more; value is unsigned integer or `col:<number>:<number>`.
- `Interval`: `xs:unsignedInt`.
- `Time`: value `loop` or integer `1..2073600000`; optional attributes `dataDisplay`, `initial`.
- `Time@initial`: `xs:string`; documented schema-compatible forms include `true`, `false`, `random=<start>:<end>`.
- Unique within timers: `Timer@id`; `Timer/Name` when present.

## Triggers

`/Protocol/Triggers` contains `Trigger` zero or more times.

`Trigger`:

- Required `@id`: `TypeObjectId`.
- Required children: `Content`, `Type`.
- Optional children: `Condition`, `Name`, `On`, `Time`.
- `Content/Id`: zero or more unsigned integers; optional `Id@else` `EnumTrueFalse`.
- `On`: values are in `protocol-types-and-enums.md`; optional `@id` using `TypeTriggerOnId`.
- `Time`: default `change`; enum values are in `protocol-types-and-enums.md`; optional attributes `case`, `id`, `nr`, `value`.
- `Type`: values `action`, `trigger`.
- Unique within triggers: `Trigger@id`; `Trigger/Name` when present.

## Actions

`/Protocol/Actions` contains `Action` zero or more times.

`Action`:

- Required `@id`: `TypeObjectId`.
- Required children: `On`, `Type`.
- Optional children: `Condition`, `Name`.
- Unique within actions: `Action@id`; `Action/Name` when present.

`Action/On`:

- Values are in `protocol-types-and-enums.md`.
- Optional attributes: `id` `TypeSemicolonSeparatedNumbers`, `nr` `xs:string`.

`Action/Type`:

- Values are in `protocol-types-and-enums.md`.
- Optional attributes: `allowed`, `arguments`, `endoffset`, `id`, `nr`, `options`, `reschedule`, `returnValue`, `regex`, `scale`, `script`, `sequence`, `startoffset`, `value`.
- `reschedule` uses `EnumTrueFalse`; `endoffset`, `id`, and `startoffset` are unsigned integer attributes.
