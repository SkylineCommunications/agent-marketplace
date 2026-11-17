# Monitoring, Alarming, Trending, And History Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for the monitoring, alarm, trending, history-set, and unit XML locations listed here. Unlisted monitoring descendants MUST NOT be authored.

## Alarm

`Param/Alarm` is an allowed direct child of `Param`:

- Optional attributes: `activeTime`, `options`, `type`.
- `activeTime`: unsigned integer matching pattern `^[1-9]+[0-9]*000\z`.
- Allowed children: `CH`, `CL`, `Info`, `MaH`, `MaL`, `MiH`, `MiL`, `Monitored`, `Normal`, `WaH`, `WaL`.
- `Monitored`: `EnumTrueFalse`; optional `@disabledIf`.

Do not use full names such as `CriticalHigh`, `MajorHigh`, or `CriticalLow`; they are not schema elements under `Alarm`.

## Trending

Trending-related XML appears only in these schema locations:

- `Param@trending` attribute.
- `Param/Display/Trending` child.
- `Param/Display/Trending/Type` child.

`Param/Display/Trending`:

- Optional `@logarithmic`.
- Optional child `Type`.

`Param/Display/Trending/Type`:

- Content values are `EnumTrendingType` values listed in `protocol-types-and-enums.md`.
- Optional `@operations`.

Do not add a direct `Param/Trending` child.

## History Sets

History-set schema flag:

- `Param@historySet` attribute.

No direct `Param/HistorySet` child exists.

## Units

Units belong under `Param/Display/Units`, not directly under `Param`.

`Param/Display/Units` is a union of `TypeNonEmptyString` and `UOM`. Known UOM enum values are listed in `protocol-uom.md`; an unlisted string is schema-valid only because of the free-text branch and still needs connector/runtime justification.
