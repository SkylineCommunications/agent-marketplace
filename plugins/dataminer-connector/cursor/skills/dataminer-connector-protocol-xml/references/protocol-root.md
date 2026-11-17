# Protocol Root Schema

Authority scope: authored from `protocol.xsd` 1.1.10 and included `uom.xsd`.
Coverage: complete for `/Protocol` direct children, root attributes, required root children, root identity constraints, `VersionHistory`, and ID/simple-type gates listed here. Unlisted root children and root attributes MUST NOT be authored.

## Root Element

- Root element: `Protocol`.
- Target namespace: `http://www.skyline.be/protocol`.
- Root attribute: `baseFor` optional, `xs:string`.
- Root content model: `xs:all`; each listed top-level child occurs at most once unless its branch says otherwise.

## Required Top-Level Children

These direct children are required under `/Protocol`:

- `Compliancies`
- `Description`
- `DeviceOID`
- `IntegrationID`
- `Name`
- `Provider`
- `Type`
- `Vendor`
- `VendorOID`
- `Version`

## Allowed Top-Level Children

Only these direct children are allowed under `/Protocol`:

- `Actions`, `Advanced`, `AlarmLevelLinks`, `App`, `Chains`, `Commands`, `Compliancies`, `Connections`, `Description`, `DeviceOID`, `Display`, `DVEs`, `ElementOptions`, `ElementType`, `ExportRules`, `GeneralParameters`, `Groups`, `HTTP`, `Icon`, `IntegrationID`, `InternalLicenses`, `Mib`, `Name`, `NoTimeouts`, `Options`, `Ownership`, `Pairs`, `ParameterGroups`, `Params`, `Ports`, `PortSettings`, `ProcessAutomation`, `Provider`, `QActions`, `RCA`, `Relations`, `Responses`, `SNMP`, `SeverityBubbleUp`, `Swarming`, `SystemOptions`, `Threads`, `Timers`, `Topology`, `Topologies`, `TreeControls`, `Triggers`, `Type`, `Vendor`, `VendorOID`, `Version`, `VersionHistory`.

Any other direct child of `/Protocol` is invalid.

## Root Metadata Types

- `Name`, `Vendor`, `Version`: `TypeNonEmptyString`.
- `Description`: `xs:string`.
- `DeviceOID`: `xs:unsignedInt`.
- `IntegrationID`: required pattern `^DMS-DRV-[0-9]+$`.
- `Provider`: non-empty provider text.
- `Type`: required root child; `EnumProtocolType`; attributes are listed in `protocol-types-and-enums.md`.
- `VendorOID`: `TypeVendorOID`, pattern `1\.3\.6\.1\.4\.1\.8813\.2\.\d+(\.\d+)*`.
- `ElementType`, `Icon`, `Mib`: optional metadata branches; `Mib` is `TypeNonEmptyString`.

## Compliancies

`Compliancies` is required and uses `xs:all`:

- `CassandraReady`: required, `EnumTrueFalse`.
- `CassandraRequired`: optional, `EnumTrueFalse`.
- `MinimumRequiredVersion`: optional, `TypeDataMinerVersion`; accepted values/pattern are in `protocol-dataminer-versions.md`.
- `MaximumSupportedVersion`: optional, `TypeDataMinerVersion`; accepted values/pattern are in `protocol-dataminer-versions.md`.

## VersionHistory

`VersionHistory` is optional and uses this closed structure:

- `Branches`: required exactly once.
- `Branches/Branch`: required one or more; required `@id` unsigned integer greater than `0`; required `Comment`; optional `Features`; required `SystemVersions`.
- `Branch/Features/Feature`: required one or more when `Features` exists, `xs:string`.
- `Branch/SystemVersions/SystemVersion`: required one or more; required `@id` unsigned integer; optional `Comment`; required `MajorVersions`; optional `SupportedVersions`.
- `SystemVersion/MajorVersions/MajorVersion`: required one or more; required `@id` unsigned integer; optional `Changes`; required `MinorVersions`.
- `MajorVersion/Changes/Change`: required one or more when `Changes` exists; required `Impact`; optional `ActionsToTake`; optional `@coversMajorChanges` using validator-ID semicolon pattern.
- `ActionsToTake/ActionToTake`: required one or more when `ActionsToTake` exists.
- `MajorVersion/MinorVersions/MinorVersion`: required one or more; required `@id` unsigned integer greater than `0`; optional `@basedOn` `TypeProtocolVersion`; required `Changes`, `Date`, and `Provider`; optional `References` and `Suppressions`.
- `MinorVersion/Changes`: required choice with one or more `Fix`, `Change`, or `NewFeature` text elements.
- `Fix@introducedIn`: optional `TypeProtocolVersion`; identifies the connector version in which the corrected defect was introduced.
- `MinorVersion/Date`: `xs:date`.
- `MinorVersion/Provider`: required `Company` and `Author`, both `TypeNonEmptyString`.
- `MinorVersion/References`: choice of one or more `TaskId` unsigned integers or one or more `Reference` values; `Reference@type` optional.
- `MinorVersion/Suppressions/Suppression`: required one or more when `Suppressions` exists; required children `Reason`, `Location`, `ResultId`; required `@type` value `MajorChange`; optional `@taskId`.
- `SystemVersion/SupportedVersions/Version`: required one or more when `SupportedVersions` exists; text `xs:string`; optional `@min`, `@max`.

`VersionHistory` uniqueness constraints: `Branch@id` unique; `SystemVersion@id` unique per branch; `MajorVersion@id` unique per system version; `MinorVersion@id` unique per major version.

## Swarming

`/Protocol/Swarming` is an optional root child introduced for DataMiner 10.6.6/10.7.0 and later.

- `BypassChecks`: optional; contains disabled checks that no longer prevent an element from swarming.
- `Check` one or more times under `BypassChecks` when that container exists; type `EnumSwarmingBypassCheck`.
- The currently defined `Check` value is listed in `protocol-types-and-enums.md`.

## Root Identity Constraints

These references MUST resolve:

- `Groups/Group/Content/Pair` -> existing `Pairs/Pair@id`.
- `Groups/Group/Content/Action` -> existing `Actions/Action@id`.
- `Groups/Group/Content/Session` -> existing `HTTP/Session@id`.
- `Groups/Group/Content/Trigger` -> existing `Triggers/Trigger@id`.
- `ParameterGroups/Group/Params/Param@id` -> existing `Params/Param@id`.
- `Display/Pages/Page/Visibility@overridePID` -> existing `Params/Param@id`.
- `PortSettings/SSH/Credentials/Username@pid`, `PortSettings/SSH/Credentials/Password@pid`, and `PortSettings/SSH/Identity@pid` -> existing `Params/Param@id`.
- `Ports/PortSettings/SSH/Credentials/Username@pid`, `Ports/PortSettings/SSH/Credentials/Password@pid`, and `Ports/PortSettings/SSH/Identity@pid` -> existing `Params/Param@id`.
- `Params/Param/Replication/Parameter@dynamic` -> existing `Params/Param@id`.
- `Params/Param/Replication/Element@dynamic` -> existing `Params/Param@id`.

## ID And Pattern Types

- `TypeParamId`: `0..64299`, `70000..99999`, or `1000000..9999999`; no leading zero except `0`.
- `TypeObjectId`: `1..64299`, `70000..99999`, or `1000000..9999999`; no leading zero.
- `TypeNonLeadingZeroUnsignedInt`: `0` or unsigned integer without leading zero.
- `TypeGroupParamId`: `0..64500`, `70000..99999`, or `1000000..9999999` via pattern `([0-9]{1,4}|[1-5][0-9]{4}|6[0-3][0-9]{3}|64[0-4][0-9]{2}|64500|[7-9][0-9]{4}|[1-9][0-9]{6})` plus optional suffix `:single`, `:table`, `:instance`, `:getnext`, or `:tablev2`.
- `TypeTriggerOnId`: unsigned integer or literal `each`.
- `TypeSemicolonSeparatedNumbers`: `\d+(;\d+)*;?`.
- `TypeCommaSeparatedNumbers`: `\d+(,\d+)*,?`.
- `TypeTrueOrSemicolonSeparatedNumbers`: `true` or `\d+(;\d+)*;?`.
- `TypeNonEmptyString`: string with minimum length `1`.
- `TypeProtocolVersion`: `[1-9][0-9]*\.[0-9]+\.[0-9]+\.[1-9][0-9]*`.
