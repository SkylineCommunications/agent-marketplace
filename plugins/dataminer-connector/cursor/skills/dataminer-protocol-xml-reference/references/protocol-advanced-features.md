# Advanced Feature Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for the advanced/root feature branches listed here. Unlisted advanced-feature children and attributes MUST NOT be authored.

## Simple Top-Level Branches

- `Advanced`: optional root child; optional attributes `ignoreEqualResponse` `EnumTrueFalse`, `stuffing` `xs:string`.
- `App`: optional root child; optional `@type` `TypeNonEmptyString`.
- `Mib`: optional root child; `TypeNonEmptyString`.
- `SystemOptions`: optional root child; optional `RunInSeparateInstance` `EnumTrueFalse`.
- `NoTimeouts`: optional root child; `NoTimeout` zero or more, `xs:string`.
- `InternalLicenses`: optional; `InternalLicense` one or more; required `@type` value `solution`.

## Swarming

`/Protocol/Swarming` is optional and uses this structure:

- `BypassChecks`: optional.
- `BypassChecks/Check`: `Check` one or more times when `BypassChecks` exists.
- `Check` uses `EnumSwarmingBypassCheck`; its exact values are owned by `protocol-types-and-enums.md`.

The schema annotation introduces this branch for DataMiner 10.6.6/10.7.0 and later. Do not emit it for an older target. Runtime suitability and the decision to bypass a check are separate from schema validity.

## Options

`/Protocol/Options` is optional and uses `xs:all`:

- `DataBaseOptions`: optional.
- `DisableViewRefresh`: optional, `EnumTrueFalse`.
- `Encoding`: optional, values `ascii`, `unicode`.
- `ForceDefaultAlarming`: optional, `EnumTrueFalse`.
- `GenerateMIB`: optional; content uses `EnumSNMP` values `auto`, `false`; required `@includePages` `EnumTrueFalse`.
- `Icon`: optional `Icon` complex type; `@ref` values are in `protocol-icons.md`.
- `NoTimeouts`: optional; `NoTimeout` zero or more, `xs:string`.
- `OverrideTimeoutDVE`: optional, `xs:string`.
- `PostPonePortInitialisation`: optional, `EnumTrueFalse`.
- `UseAgentBinding`: optional, `EnumTrueFalse`.

`Options/DataBaseOptions`:

- Optional children: `CustomDataIDs`, `PartitionedTrending`.
- Both children use `EnumTrueFalse`.

## ParameterGroups

`/Protocol/ParameterGroups`:

- Contains `Group` zero or more times.

`ParameterGroups/Group`:

- Required attributes: `id`, `type`.
- Optional attributes: `calculateAlarmState`, `dynamicId`, `dynamicIndex`, `dynamicUsePK`, `isInternal`, `name`.
- `id`: unsigned integer `1..99999`; unique within `ParameterGroups`.
- `type` values: `in`, `inout`, `out`.
- Optional child: `Params`.

`Group/Params/Param`:

- Zero or more.
- Required `@id`: `TypeParamId`; must reference an existing `/Protocol/Params/Param@id`.
- Optional `@index`: `xs:string`.
- `Param@id` is unique within one parameter group.

## Relations And SeverityBubbleUp

`/Protocol/Relations`:

- Contains `Relation` zero or more times.
- `Relation` required `@path`: `TypeSemicolonSeparatedNumbers`.
- `Relation` optional attributes: `name`, `options`.

`/Protocol/SeverityBubbleUp`:

- Contains `Path` zero or more times.
- `Path` text: `TypeSemicolonSeparatedNumbers`.
- `Path@statePid`: optional unsigned integer.

## TreeControls

`/Protocol/TreeControls`:

- Contains `TreeControl` one or more times when present.

`TreeControl`:

- Required `@parameterId`: `TypeParamId`.
- Optional `@readOnly`: `EnumTrueFalse`.
- Optional children: `ExtraDetails`, `ExtraTabs`, `HiddenColumns`, `Hierarchy`, `OverrideDisplayColumns`, `OverrideIconColumns`, `ReadonlyColumns`.

`TreeControl/ExtraDetails/LinkedDetails`:

- Zero or more.
- Optional attributes: `detailsTableId`, `discreetColumnId`, `value`.
- `detailsTableId` and `discreetColumnId` use `TypeParamId`.

`TreeControl/ExtraTabs/Tab`:

- Zero or more.
- Optional attributes: `parameter`, `tableId`, `title`, `type`.
- `tableId` uses `TypeParamId`.

`TreeControl/Hierarchy`:

- Contains `Table` zero or more.
- `Table@id`: required unsigned integer.
- `Table@parent`, `Table@condition`: optional.
- `Table@path`: optional `TypeCommaSeparatedNumbers`.

`HiddenColumns`, `ReadonlyColumns`, `OverrideDisplayColumns`, and `OverrideIconColumns` contain `xs:string`.

## DVEs And ExportRules

`/Protocol/DVEs` uses `xs:all` with optional `DVEProtocols` and optional `ExportRules`.

`DVEs/DVEProtocols/DVEProtocol`:

- Zero or more.
- Required attributes: `name`, `tablePID`.
- Optional child: `ElementPrefix` `EnumTrueFalse`.
- `tablePID`: `TypeParamId`.

`/Protocol/ExportRules` and `DVEs/ExportRules` use the same structure:

- `ExportRule` zero or more.
- Required attributes: `table`, `tag`, `value`.
- Optional attributes: `attribute`, `name`, `regex`, `whereAttribute`, `whereTag`, `whereValue`.
- `table`: wildcard-or-number type; `tag` and `attribute` use `TypeNonEmptyString`.
- `where` is not an effective `ExportRule` attribute in this schema version; use only `whereAttribute`, `whereTag`, and `whereValue`.

## Threads

`/Protocol/Threads`:

- Contains `Thread` zero or more times.
- `Thread@connection`: required `TypeCommaSeparatedNumbers`.
- `Thread@id`: optional `TypeNonLeadingZeroUnsignedInt`; unique when present.
- `Thread@name`: optional `TypeNonEmptyString`.

## Topology And Topologies

`/Protocol/Topology`:

- Optional legacy single topology; optional `@name`.
- Contains `Cell` zero or more times.

`/Protocol/Topologies`:

- Contains `Topology` zero or more times.
- `Topology@name`: optional.
- `Topology/Cell`: zero or more.

`Topology/Cell`:

- Required attributes: `name`, `table`.
- Optional attributes: `detailColumns`, `listColumns`, `options`.
- `Link` zero or more; `Link@source` and `Link@dest` required unsigned integers.
- In the multi-topology branch, `Cell` may also include `Exposer` and `LinkedIds`.
- `Exposer@enabled`: required `EnumTrueFalse` when `Exposer` exists.
- `LinkedIds/LinkedId`: one or more when `LinkedIds` exists; text `xs:int`; optional `@columnPid` `xs:int`.

## Chains

`/Protocol/Chains`:

- Optional `@filters`: `horizontal` or `vertical`.
- Choice of `Chain` and `SearchChain` entries, zero or more.
- Chain/SearchChain names are unique in the container.

`Chains/Chain`:

- Required child: `Display`.
- Optional child: `Field` zero or more.
- Required `@name`.
- Optional attributes: `defaultSelectionField`, `groupingName`, `options`, `topology`.

`Chains/Chain/Field`:

- Required attributes: `name`, `pid`.
- Optional attributes: `displayTable`, `options`.
- Optional children: `DiagramPids`, `DiagramSorting`, `DiagramTitleFormat`, `Display`.
- `DiagramPids`: `TypeCommaSeparatedNumbers`.
- `DiagramSorting`: `TypeNonEmptyString`.

`Chains/Chain/Field/Display`:

- Optional child: `Selection`.
- `Selection/Visibility`: required when `Selection` exists.
- `Visibility@default`: optional `EnumTrueFalse`.
- `Visibility/Standalone`: one or more; required `@pid` `TypeParamId`; required `Value` one or more.

`Chains/SearchChain`:

- Optional child: `Display`.
- Optional child: `Tabs`.
- Required `@name`.

`SearchChain/Tabs/Tab`:

- One or more when `Tabs` exists.
- Required `@tablePid`; optional `@name`.
- Optional `Display`; required `Fields`.
- `Fields/Field`: zero or more.
- Tab names are unique within one search chain; field names are unique within one tab.

`SearchChain/Tabs/Tab/Fields/Field`:

- Required attributes: `columnPid`, `name`.
- Optional children: `Display`, `Substitutions`, `Validation`.
- `Display/Visibility`: required when `Display` exists.
- `Visibility@default`: optional `EnumTrueFalse`.
- `Visibility/Standalone`: one or more; required `@pid` `TypeParamId`; required `Value` one or more.
- `Substitutions/Substitution`: one or more; optional `Regex`.
- `Substitution/Regex`: required `Input`, required `Output`.
- `Validation`: optional `ErrorMessage`; optional `Regex`.

## RCA And AlarmLevelLinks

`/Protocol/RCA`:

- Optional child: `Protocol`.
- `Protocol/Link`: zero or more.
- `Link` optional attributes: `distribute`, `path`, `valueFilter`.

`/Protocol/AlarmLevelLinks/AlarmLevelLink`:

- Zero or more.
- Required attributes: `id`, `destination`, `remoteElement`.
- Optional `@filters`.
- `id` is unique within `AlarmLevelLinks`.

## ElementOptions And GeneralParameters

`/Protocol/ElementOptions/UserSettings`:

- Optional children: `PingInterval`, `SlowPoll`, `SlowPollBase`, `TimeoutTimeElement`.

`/Protocol/GeneralParameters/GeneralParameter`:

- Zero or more.
- Required attributes: `group`, `enabled`.
- `group` values: `communication`, `dcf`, `replication`, `verification`.
- `enabled`: `EnumTrueFalse`.
- `GeneralParameter@group` is unique in `GeneralParameters`.

## Ownership

`/Protocol/Ownership` uses optional `Elements`, `Views`, `Services`, and `RedundancyGroups` branches.

Ownership branch shapes:

- `Elements/Element`: one or more when `Elements` exists; required `Protocol`; optional `Description`, `AlarmTemplate`, `TrendTemplate`, `Properties`.
- `Views/View`: one or more when `Views` exists; required `Properties`.
- `Services/Service`: one or more when `Services` exists; optional `Description`, `Properties`.
- `RedundancyGroups/RedundancyGroup`: one or more when present; optional `Description`, `Maintenance`, `Switching`.
- `Properties/Property`: one or more; required `Name`, `AccessType`.
- Ownership `AccessType` values: `read-only`, `read-write`.

## ProcessAutomation

`/Protocol/ProcessAutomation`:

- Required child: `ProcessAutomationOptions`.
- `ProcessAutomationOptions/ProcessAutomationOption`: zero or more.
- `ProcessAutomationOption` required attributes: `name`, `pid`.
- Known `name` enum values: `QueueSize`, `QueueSizeMax`; the schema also permits strings, but this skill authorizes only the known enum values unless another loaded non-schema authority owns a custom value.
- `pid`: `TypeNonLeadingZeroUnsignedInt`.

## Matrix

Matrix-specific XML appears under `Param/Matrix`; structure is listed in `protocol-display-ui.md` and enum values are in `protocol-types-and-enums.md`.
