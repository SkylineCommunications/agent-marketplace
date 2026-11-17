# Tables And ArrayOptions Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `Param/ArrayOptions`, `ArrayOptions/NamingFormat`, and `ArrayOptions/ColumnOption` direct children/attributes listed here. Unlisted table descendants MUST NOT be authored.

## Table Shape

A table is a `Param` whose `Type` value is `array` and which uses `ArrayOptions`.

`ArrayOptions` is an allowed direct child of `Param`.

## ArrayOptions

Allowed `ArrayOptions` children:

- `NamingFormat`: optional, max 1.
- `ColumnOption`: required, one or more.

Allowed `ArrayOptions` attributes:

- `deleteRow`
- `displayColumn`
- `index`: required.
- `options`
- `partial`: pattern `false` or `true` optionally followed by `:<rows>`.
- `snmpIndex`

`ColumnOptions` is not a valid wrapper in `protocol.xsd` 1.1.10; `ColumnOption` is directly under `ArrayOptions`.

## ColumnOption

Allowed `ColumnOption` attributes:

- `cpeAlignment`
- `idx`: required.
- `options`
- `pid`: required.
- `pollingRate`
- `type`: required.
- `value`

`ColumnOption@type` values are listed in `protocol-types-and-enums.md`.

Neither `foreignKey` nor `foreignkey` is a valid `ColumnOption@type` value in this schema version. Relationship tokens can only be used where another loaded non-schema authority explicitly owns them, typically in string `options` fields.

## Uniqueness

The schema defines `ColumnOption@idx` uniqueness within one `ArrayOptions` table.

Other table relationship and display-key semantics are outside this schema card; use the relevant non-schema authoring or validator authority for those behavioral rules.

## NamingFormat

- `ArrayOptions/NamingFormat` is optional.
- It is the only allowed direct child under `ArrayOptions` besides `ColumnOption`.
- Its content is schema-defined as text.
