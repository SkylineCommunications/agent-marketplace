# Protocol Types And Enums

Authority scope: authored from `protocol.xsd` 1.1.10 and included `uom.xsd`. Enum values are exact strings; preserve casing, spaces, and punctuation.
Coverage: complete for enum/simple-type values explicitly listed in this file. Values not listed here or in a dedicated enum file MUST NOT be authored.

## Protocol Type

`/Protocol/Type` values:

- `gpib`
- `http`
- `opc`
- `serial`
- `serial single`
- `service`
- `sla`
- `smart-serial`
- `smart-serial single`
- `snmp`
- `snmpv2`
- `snmpv3`
- `virtual`

Allowed `/Protocol/Type` attributes:

- `advanced`: `xs:string`.
- `communicationOptions`: `xs:string`.
- `databaseOptions`: `xs:string`.
- `options`: `xs:string`.
- `overrideTimeoutDVE`: `EnumTrueFalse`.
- `relativeTimers`: `EnumProtocolTypeRelativeTimers` values `true` or `true with reset`.

## Param Type

`/Protocol/Params/Param/Type` values:

- `array`
- `bus`
- `crc`
- `dataminer info`
- `discreet info`
- `dummy`
- `elementdmaid`
- `elementid`
- `elementname`
- `fixed`
- `group`
- `header`
- `ip`
- `length`
- `matrix`
- `pollingip`
- `read`
- `read bit`
- `response`
- `trailer`
- `write`
- `write bit`

Allowed `Param/Type` attributes are defined on the element in `protocol-params.md`.

## Interpretation Enums

`EnumParamInformationInclude` values:

- `range`
- `steps`
- `time`
- `units`

`EnumParamInterpretAlignment` values:

- `left`
- `right`

`EnumInterpretTypeTrim` values:

- `left`
- `right`
- `left;right`

`EnumParamInterpretEndian` values:

- `big`
- `little`

`Interprete/RawType` values:

- `bcd`
- `double`
- `numeric text`
- `only others`
- `other`
- `signed number`
- `text`
- `unsigned number`

`Interprete/Type` values:

- `double`
- `high nibble`
- `string`

`Interprete/LengthType` values:

- `fixed`
- `last next param`
- `next param`
- `other param`

## Measurement Type

`Measurement/Type` values:

- `analog`
- `button`
- `chart`
- `digital threshold`
- `discreet`
- `matrix`
- `number`
- `pagebutton`
- `progress`
- `string`
- `table`
- `title`
- `togglebutton`

`EnumParamMeasurementTypeCase` values:

- `upper`
- `lower`

`EnumDiscreteValue` values:

- `dll`
- `open`
- `setvar`

## Column Option Type

`ArrayOptions/ColumnOption@type` values:

- `autoincrement`
- `concatenation`
- `custom`
- `displaykey`
- `index`
- `retrieved`
- `snmp`
- `state`
- `viewTableKey`

Neither `foreignKey` nor `foreignkey` is a `ColumnOption@type` value in this schema version.

## SNMP Enums

`SNMP/Type` values:

- `counter32`
- `counter64`
- `counter64String`
- `gauge32`
- `integer`
- `integer32`
- `ipaddress`
- `nsapaddress`
- `null`
- `objectid`
- `octetstring`
- `octetstringhex`
- `octetstringascii`
- `octetstringutf8`
- `octetstringdecimal`
- `oid`
- `opaque`
- `timeticks`
- `uinteger32`

`OID@type` and `TrapOID@type` values:

- `auto`
- `complete`
- `composed`
- `wildcard`

`id` is not an `OID@type` value; it is an attribute.

Top-level `/Protocol/SNMP`, when present, has fixed content `auto` and required fixed `SNMP@includepages="true"`.

`EnumSNMP` values:

- `auto`
- `false`

## HTTP Enums

`Request@verb` values:

- `DELETE`
- `GET`
- `HEAD`
- `OPTIONS`
- `PATCH`
- `POST`
- `PUT`
- `TRACE`
- `COPY`
- `LOCK`
- `MKCOL`
- `PROPFIND`
- `PROPPATCH`
- `UNLOCK`
- `TRACK`

`CONNECT` is not in `EnumHttpRequestVerb`.

`Session@loginMethod` values:

- `credentials`
- `certificate`

## Execution Enums

`Group/Type` values:

- `action`
- `poll`
- `poll action`
- `poll trigger`
- `trigger`

`Trigger/On` values:

- `command`
- `communication`
- `group`
- `pair`
- `parameter`
- `protocol`
- `response`
- `session`
- `timer`

`Trigger/Time` schema enum values:

- `after`
- `after startup`
- `before`
- `change`
- `change after response`
- `link file change`
- `succeeded`
- `timeout`
- `timeout after retries`

`Trigger/Time` type is a union of `EnumTriggerTime` and `xs:string`. The enum values above are the schema-known values. Other string values are schema-valid through the free-text branch, but require an explicit connector/runtime requirement before authoring.

`Trigger/Type` values:

- `action`
- `trigger`

`Action/On` values:

- `command`
- `group`
- `pair`
- `parameter`
- `protocol`
- `response`
- `timer`

`Action/Type` values:

- `add to execute`
- `aggregate`
- `append`
- `append data`
- `change length`
- `clear`
- `clear length info`
- `clear on display`
- `close`
- `copy`
- `copy reverse`
- `crc`
- `create element`
- `execute`
- `execute next`
- `execute one`
- `execute one top`
- `execute one now`
- `force execute`
- `go`
- `increment`
- `length`
- `lock`
- `make`
- `merge`
- `multiply`
- `normalize`
- `open`
- `pow`
- `priority lock`
- `priority unlock`
- `read`
- `read file`
- `read stuffing`
- `replace`
- `replace data`
- `reschedule`
- `restart timer`
- `reverse`
- `run actions`
- `save`
- `set`
- `set and get with wait`
- `set info`
- `set next`
- `set with wait`
- `sleep`
- `start`
- `stop`
- `stop current group`
- `stuffing`
- `swap column`
- `timeout`
- `unlock`
- `wmi`

## QAction Enums And Option Pattern

`QAction@encoding` values:

- `jscript`
- `vbscript`
- `csharp`

`QAction@options` uses `TypeQActionOptions`. XSD-known option tokens/patterns:

- `binary`
- `debug`
- `group`
- `precompile`
- `queued`
- `dllName=<value>`

Options are semicolon-separated by the XSD pattern.

## Miscellaneous Enums

- `EnumTrueFalse`: `true`, `false`.
- `EnumOnOff`: `on`, `off`.
- `EnumEncoding`: `ascii`, `unicode`.
- `EnumDisplayType`: `element manager`, `spectrum analyzer`.
- `EnumDatabasePartition`: `hour`, `day`, `month`, `year`, `infinite`.
- `EnumGeneralParameterGroupType`: `communication`, `dcf`, `replication`, `verification`.
- `EnumParamGroupType`: `in`, `inout`, `out`.
- `EnumParametersViewType`: `column`, `pie`, `row`, `stackedarea`.
- `EnumCpeAlignment`: `left`, `center`, `right`.
- `EnumDisplayState`: `disabled`, `enabled`.
- `EnumOwnershipAccessType`: `read-only`, `read-write`.
- `EnumWebSocketMessageType`: `binary`, `text`.
- `EnumTrendingType`: `average`, `max`, `min`, `last`, `sum`.
- `EnumPortTypes`: `udp`, `ip`, `rs232`.
- `EnumPortSettingsParity`: `even`, `mark`, `no`, `odd`, `space`.
- `EnumPortSettingsStopBits`: `1`, `1.5`, `2`.
- `EnumPortSettingsFlowControl`: `no`, `cts_rts`, `cts_dtr`, `dsr_rts`, `dsr_dtr`, `xon_xoff`.
- `EnumParamConfirmPopup`: `always`, `never`, `dm`.
- `EnumChainsFilters`: `horizontal`, `vertical`.
- `EnumParamCRCType`: `2comp`, `codan`, `crc`, `crc-ccitt`, `crc16`, `exor`, `fletcher`, `lsb after subtract`, `lsb after sum`, `modbus`, `rcds`, `rest`, `subtract`, `sum`.
- `EnumRounding`: `down`, `up`, `toZero`, `toInfinity`, `halfDown`, `halfUp`, `halfToZero`, `halfToInfinity`.
- `EnumScientificNotation`: `universal`, `scientific`.
- `EnumTypePortSlowPollBase`: `number`, `time`.

## Swarming Enum

`EnumSwarmingBypassCheck` values:

- `smartSerialAsServer`

Use this value only under `/Protocol/Swarming/BypassChecks/Check`. The structure and DataMiner version gate are defined in `protocol-root.md` and `protocol-advanced-features.md`.

## Simple-Type Patterns

- `TypeParamId`: `0..64299`, `70000..99999`, or `1000000..9999999`; no leading zero except `0`.
- `TypeObjectId`: `1..64299`, `70000..99999`, or `1000000..9999999`; no leading zero.
- `TypeNonLeadingZeroUnsignedInt`: `0` or unsigned integer without leading zero.
- `TypeSemicolonSeparatedNumbers`: `\d+(;\d+)*;?`.
- `TypeCommaSeparatedNumbers`: `\d+(,\d+)*,?`.
- `TypeTrueOrSemicolonSeparatedNumbers`: `true` or `\d+(;\d+)*;?`.
- `TypeProtocolVersion`: `[1-9][0-9]*\.[0-9]+\.[0-9]+\.[1-9][0-9]*`.
- `TypeNonEmptyString`: string with minimum length `1`.

## Process Automation And Matrix Enums

`EnumProcessAutomationOptionName` values:

- `QueueSize`
- `QueueSizeMax`

Matrix enum values:

- `EnumMatrixMappingType`: `pid`.
- `EnumMatrixInputsMappingNameType`: `index`, `label`, `state`, `lock`, `page`.
- `EnumMatrixOutputsMappingNameType`: `index`, `label`, `state`, `lock`, `page`, `connectedInput`, `tooltip`, `lockOverride`.
- `EnumMatrixMatrixOptionType`: `value`.
- `EnumMatrixMatrixOptionNameType`: `matrixLayout`, `pages`, `minimumConnectedInputsPerOutput`, `maximumConnectedInputsPerOutput`, `minimumConnectedOutputsPerInput`, `maximumConnectedOutputsPerInput`.

## Dedicated Enum Files

Large enum and union-backed value sets are covered by dedicated reference files:

- `TypeDataMinerVersion` values and pattern branch: `protocol-dataminer-versions.md`.
- `UOM` values: `protocol-uom.md`.
- HTTP request, response, and common header enum values: `protocol-http-headers.md`.
- `EnumIcons` values: `protocol-icons.md`.

If an enum value is not listed in this file or the relevant dedicated enum file, it MUST NOT be authored. If a simple type has an explicit pattern branch in a dedicated file, authored values MUST match that listed pattern exactly.
