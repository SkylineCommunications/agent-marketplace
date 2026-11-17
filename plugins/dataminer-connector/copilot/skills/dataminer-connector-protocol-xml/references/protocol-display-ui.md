# Display And UI Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `/Protocol/Display`, `Param/Display`, positions, units, trending, measurement UI type placement, icon placement, and matrix/tree-control schema locations listed here. Unlisted display descendants MUST NOT be authored.

## Protocol/Display

`/Protocol/Display` is optional and uses `xs:all`:

- Optional child: `Pages`.
- Optional attributes: `defaultPage`, `pageOptions`, `pageOrder`, `type`, `wideColumnPages`.
- `type` values are `element manager` or `spectrum analyzer`.

`Display/Pages`:

- Contains `Page` zero or more times.

`Display/Pages/Page`:

- Required child: `Name`.
- Optional child: `Visibility`.

`Display/Pages/Page/Visibility`:

- Required attributes: `default`, `overridePID`, `value`.
- `default`: `EnumTrueFalse`.
- `overridePID`: must reference an existing `Params/Param@id`.

## Param/Display

Parameter display XML belongs under `Param/Display`, not directly under `Param`.

Allowed `Param/Display` children:

- `DynamicUnits`, `Decimals`, `ParametersView`, `Positions`, `Range`, `RTDisplay`, `Steps`, `Trending`, `Units`.

`Param/Display/Positions`:

- Contains `Position` zero or more times.

`Param/Display/Positions/Position`:

- Required children: `Page`, `Column`, `Row`.
- `Page@measType` optional; values use `EnumParamMeasurementType`.

`Param/Display` scalar children:

- `RTDisplay`: `EnumTrueFalse`; optional `@onAppLevel`.
- `Units`: union of `TypeNonEmptyString` and `UOM`; known UOM values are in `protocol-uom.md`.
- `DynamicUnits/Unit`: one or more; value is `UOM`; optional `@decimals`.
- `Decimals`: `xs:unsignedInt`, default `0`.
- `Range`: optional `Low`, optional `High`.
- `Steps`: `xs:decimal`, default `0`.
- `ParametersView`: optional complex element for charts; required `@type`; optional `@options`; optional child `Parameters`.
- `ParametersView@type` values: `column`, `pie`, `row`, `stackedarea`.
- `ParametersView/Parameters/Parameter`: zero or more; required `@id`; optional `@options`, `@tableIndex`.
- `Trending`: optional `@logarithmic`; optional child `Type`.
- `Trending/Type`: values are `average`, `max`, `min`, `last`, `sum`; optional `@operations`.

## Measurement And Icon Placement

- UI component type values are `Param/Measurement/Type` enum values listed in `protocol-types-and-enums.md`.
- `Param/Icon` uses text content with optional `@ref`; `Icon@ref` values are in `protocol-icons.md`.
- Do not place `Trending`, `Units`, `Decimals`, or `Positions` directly under `Param`.

## Matrix And TreeControls

Matrix XML belongs under `Param/Matrix`:

- Required children: `Inputs`, `Outputs`, `MatrixOptions`.
- `Inputs@tablePid` required; `Inputs/Mappings/Mapping` occurs at least four times with required `@type`, `@name`.
- `Outputs@tablePid` required; `Outputs/Mappings/Mapping` occurs at least five times with required `@type`, `@name`.
- `MatrixOptions/MatrixOption` occurs one or more times with required `@type`, `@name`.
- Matrix enum values are in `protocol-types-and-enums.md`.

Tree-control XML belongs under `/Protocol/TreeControls`; structure is listed in `protocol-advanced-features.md`.
