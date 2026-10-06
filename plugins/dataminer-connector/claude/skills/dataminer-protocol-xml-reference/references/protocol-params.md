# Params And Param Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `/Protocol/Params`, `/Protocol/Params/Param`, and nested `Param` branches listed here. Unlisted `Param` children and attributes MUST NOT be authored.

## Params And Param

- `/Protocol/Params` is optional and contains `Param` zero or more times.
- `/Protocol/Params/Param` uses `xs:all`; each direct child occurs at most once unless this file says otherwise.
- Required `Param@id`: `TypeParamId`.
- Required direct children: `Name`, `Type`.
- `Param/Name`: `TypeNonEmptyString`; unique under `/Protocol/Params`.
- `Param@id`: unique under `/Protocol/Params`.

Allowed `Param` attributes:

- `confirmPopup`, `duplicateAs`, `export`, `historySet`, `id`, `level`, `options`, `pollingInterval`, `save`, `saveInterval`, `setter`, `snapshot`, `snmpSetAndGet`, `trending`, `verificationTimeout`.

Allowed direct `Param` children:

- `Alarm`, `ArrayOptions`, `CRC`, `CrossDriverOptions`, `Dashboard`, `Database`, `Dependencies`, `Description`, `Display`, `HyperLinks`, `Icon`, `Information`, `Interprete`, `Length`, `Matrix`, `Measurement`, `Mediation`, `Message`, `Name`, `Replication`, `SNMP`, `Type`.

Any other direct child under `Param` is invalid.

## Param/Type

- Required; content type `EnumParamType`; values are in `protocol-types-and-enums.md`.
- Optional attributes: `alarmRegistration`, `distribution`, `dynamicSnmpGet`, `id`, `options`, `relativeTimers`, `times`, `virtual`.

## Param/Interprete

- Optional; content model `xs:all`.
- Optional children: `Alignment`, `Base`, `Bits`, `ByteOffset`, `Decimals`, `DefaultValue`, `Endian`, `Exceptions`, `Factor`, `Length`, `LengthType`, `NbrOfBits`, `OffSet`, `Others`, `Range`, `RawType`, `Rounding`, `Scale`, `Sequence`, `StartPosition`, `Type`, `Value`.
- Enum-backed children: `Alignment`, `Endian`, `LengthType`, `RawType`, `Type`; values are in `protocol-types-and-enums.md`.
- `LengthType`: optional attributes `id`, `times`.
- `OffSet`: unsigned integer content; optional `@id`.
- `Range`: optional `Low`, optional `High`.
- `Rounding`: values are in `protocol-types-and-enums.md`.
- `Scale`: required attributes `lowData`, `highData`, `low`, `high`.
- `Sequence`: text content; optional attributes `loop`, `noset`.
- `Type`: optional attributes `filter`, `trim`; `trim` values are in `protocol-types-and-enums.md`.
- `Exceptions/Exception`: zero or more; required attributes `id`, `value`; required children `Display`, `Value`; `Display@state` optional.
- `Others/Other`: zero or more; required `@id`; required children `Display`, `Value`; `Display@state` optional.

## Param/Display

- Optional; content model `xs:all`.
- Optional children: `DynamicUnits`, `Decimals`, `ParametersView`, `Positions`, `Range`, `RTDisplay`, `Steps`, `Trending`, `Units`.
- `DynamicUnits/Unit`: one or more; value is `UOM`; optional `@decimals`.
- `Decimals`: `xs:unsignedInt`, default `0`.
- `ParametersView`: optional complex element; required `@type`; optional `@options`; optional child `Parameters`.
- `ParametersView@type` values are in `protocol-types-and-enums.md`.
- `ParametersView/Parameters/Parameter`: zero or more; required `@id`; optional `@options`, `@tableIndex`.
- `Positions/Position`: zero or more; required children `Page`, `Column`, `Row`; `Page@measType` optional and uses `EnumParamMeasurementType`.
- `Range`: optional `Low`, optional `High`.
- `RTDisplay`: `EnumTrueFalse`; optional `@onAppLevel`.
- `Steps`: `xs:decimal`, default `0`.
- `Trending`: optional `@logarithmic`; optional child `Type`.
- `Trending/Type`: `EnumTrendingType`; optional `@operations`.
- `Units`: union of `TypeNonEmptyString` and `UOM`; known UOM values are in `protocol-uom.md`.

## Param/Measurement

- Optional; content model `xs:all`.
- Required when `Measurement` exists: `Type`.
- Optional children: `Discreets`, `Threshold`.
- `Type`: `EnumParamMeasurementType`; optional attributes `case`, `continuous`, `hex`, `lines`, `link`, `number`, `options`, `scientificNotation`, `verificationDeviation`, `width`; `scientificNotation` values are `universal`, `scientific`.
- `Discreets`: optional attributes `dependencyId`, `matrixLayout`; `matrixLayout` values are `InputLeftOutputTop`, `InputTopOutputLeft`.
- `Discreets/Discreet`: zero or more; required children `Display`, `Value`; optional child `Tooltip`; optional attributes `dependencyValues`, `displayIconAndLabel`, `export`, `iconRef`, `options`.
- `Discreet/Display@state`: optional `EnumDisplayState`.
- `Discreet/Value`: optional attributes `location`, `type`; value type allows ordinary values plus `dll`, `open`, `setvar` from `EnumDiscreteValue`.

## Param/Alarm

- Optional; content model `xs:all`.
- Optional attributes: `activeTime`, `options`, `type`.
- `activeTime`: unsigned integer matching pattern `^[1-9]+[0-9]*000\z`.
- Allowed children: `CH`, `CL`, `Info`, `MaH`, `MaL`, `MiH`, `MiL`, `Monitored`, `Normal`, `WaH`, `WaL`.
- `Monitored`: `EnumTrueFalse`; optional `@disabledIf`.
- Do not use full severity names such as `CriticalHigh`, `MajorHigh`, or `CriticalLow`.

## Param/SNMP

- Optional; content model `xs:all`.
- Optional `SNMP@options`.
- Optional children: `Enabled`, `Factor`, `InvalidResponseHandling`, `OID`, `TrapMappings`, `TrapOID`, `Type`.
- `OID`: text content; optional attributes `id`, `ipid`, `options`, `skipDynamicSNMPGet`, `type`; `type` values are in `protocol-types-and-enums.md`.
- `TrapOID`: text content; optional attributes `checkBindings`, `ipid`, `mapAlarm`, `setBindings`, `type`; `type` values are in `protocol-types-and-enums.md`; known `setBindings` enum value is `allBindingInfo`, while other strings are schema-valid through the free-text union branch.
- `TrapMappings/TrapMapping`: zero or more; optional attributes `bindingMatch`, `severity`, `value`.
- `InvalidResponseHandling/InfiniteLoop`: required when `InvalidResponseHandling` exists; values `success`, `timeout`.
- `Type`: `EnumSNMPType`; values are in `protocol-types-and-enums.md`.

## Param/Information

- Optional; content model `xs:all`.
- Optional children: `AlarmDescription`, `Category`, `CorrectiveAction`, `Includes`, `Subtext`, `Text`.
- `Includes/Include`: zero or more; value uses `EnumParamInformationInclude`.
- `Subtext` is not a direct child of `Param`; it belongs under `Param/Information`.

## Param/Database

- Optional; content model `xs:all`.
- Optional children: `ColumnDefinition`, `Connection`, `CQLOptions`, `IndexingOptions`, `Partition`.
- `ColumnDefinition@default`: optional.
- `Connection`: required child `Type` when `Connection` exists; `Type` values `DirectConnection`, `SLProtocol`.
- `CQLOptions`: optional children `Clustering`, `Finalizer`, `TableProperty`.
- `Partition`: optional `@partitionsToKeep`; values use `EnumDatabasePartition`.
- `IndexingOptions`: required `@enabled`.

## Other Param Children

- `CRC`: required children `Content`, `Type`; `Content/Param` zero or more; `Type` uses `EnumParamCRCType`; `Type` optional attributes `byteoffset`, `groupbytes`, `mod`, `off`, `options`, `totaloffset`.
- `CrossDriverOptions/CrossDriverOption`: one or more; required `@protocol`, `@remoteTablePID`; `PIDTranslation` one or more with required `@local`, `@remote`.
- `Dashboard`: optional `Type`; required `DashboardOptions`; `Type` values `button panel`, `button panel containers`, `button panel collection`.
- `DashboardOptions/DashboardOption`: one or more; unsigned integer content; required `@type` values `idx`, `pid`; required `@name` values `activeContainer`, `advancedLayout`, `container`, `css`, `height`, `panelAdvancedLayout`, `panelButtonName`, `panelButtonOperation`, `panelButtonPossibleOperations`, `panelButtonType`, `panelSelection`, `width`, `xpos`, `ypos`.
- `Dependencies/Id`: zero or more; optional `@postSet`.
- `HyperLinks/HyperLink`: zero or more; optional `@valueParsing`.
- `Icon`: text content with optional `@ref`; `@ref` values are in `protocol-icons.md`.
- `Length`: required `Content`; `Content/Param` zero or more.
- `Matrix`: required `Inputs`, `Outputs`, `MatrixOptions`; mapping enum values are in `protocol-types-and-enums.md`.
- `Mediation/LinkTo`: zero or more; optional attributes `description`, `ops`, `pid`, `protocol`; `ValueMapping` zero or more with required `@remoteValue`, `@value`.
- `Message`: `xs:string`.
- `Replication`: optional attributes `ip`, `uid`, `pwd`, `domain`; optional `Element`; optional `Parameter`; `Element@dynamic` and `Parameter@dynamic` optional.

## String Option Attributes

Many `options` attributes are `xs:string`. This skill confirms only that a string is schema-valid there; option-token semantics require a dedicated non-schema authority.
