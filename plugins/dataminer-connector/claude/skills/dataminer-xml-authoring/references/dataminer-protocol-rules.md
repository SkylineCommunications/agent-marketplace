---
name: dataminer-protocol-rules
description: Enforce DataMiner protocol XML validation rules from the CICD Validator (18 categories, 210 checks, 843 error messages). Load when reviewing or writing DataMiner protocol XML files.
---

# DataMiner Protocol XML Validator Rules

Rules from `Protocol/ErrorMessages.xml`. Each rule: `[Severity][CategoryId.CheckId.ErrorId]`.

Severity: `[Critical]` must fix | `[Major]` functional issue | `[Minor]` best-practice | `[Warning]` advisory

Flag every violation with its rule ID and severity when reviewing or generating protocol XML.

## 1. Protocol

### `Protocol` / CheckProtocolTag

- `[Critical]`[`1.1.1`] **MissingTag**: Missing tag '{0}'.

### `Protocol.Name` / CheckNameTag

- `[Critical]`[`1.2.1`] **MissingTag**: Missing tag '{0}'.
- `[Critical]`[`1.2.2`] **EmptyTag**: Empty tag '{0}'.
- `[Critical]`[`1.2.3`] **UntrimmedTag**: Untrimmed tag '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`1.2.4`] **InvalidChars**: Invalid chars '{2}' in tag '{0}'. Current value '{1}'.
- `[Critical]`[`1.2.5`] **InvalidPrefix**: Invalid prefix '{1}' in 'Protocol/Name' tag. Current value '{0}'. *(autofix)*
- `[Critical]`[`1.2.6`] **UpdatedValue**: Protocol Name '{0}' changed into '{1}'.

### `Protocol.Provider` / CheckProviderTag

- `[Critical]`[`1.3.1`] **MissingTag**: Missing tag '{0}'. *(autofix)*
- `[Critical]`[`1.3.2`] **EmptyTag**: Empty tag '{0}'.
- `[Critical]`[`1.3.3`] **InvalidTag**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'.

### `Protocol.SNMP` / CheckSnmpTag

- `[Critical]`[`1.4.1`] **MissingTag**: Missing tag '{0}'. *(autofix)*
- `[Critical]`[`1.4.2`] **EmptyTag**: Empty tag '{0}'. *(autofix)*
- `[Critical]`[`1.4.3`] **InvalidValue**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'. *(autofix)*

### `Protocol.SNMP` / CheckIncludepagesAttribute

- `[Critical]`[`1.5.1`] **MissingAttribute**: Missing attribute '{0}'. *(autofix)*
- `[Critical]`[`1.5.2`] **EmptyAttribute**: Empty attribute '{0}'. *(autofix)*
- `[Critical]`[`1.5.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. Possible values '{2}'. *(autofix)*

### `Protocol.Version` / CheckVersionTag

- `[Critical]`[`1.6.1`] **MissingTag**: Missing tag '{0}'. *(autofix)*
- `[Critical]`[`1.6.2`] **EmptyTag**: Empty tag '{0}'. *(autofix)*
- `[Critical]`[`1.6.3`] **UntrimmedTag**: Untrimmed tag '{0}'. Current value '{1}'. *(autofix)*

### `Protocol.ElementType` / CheckElementTypeTag

- `[Critical]`[`1.7.1`] **MissingTag**: Missing tag '{0}'.
- `[Critical]`[`1.7.2`] **EmptyTag**: Empty tag '{0}'.

### `Protocol.Type` / CheckTypeTag

- `[Critical]`[`1.8.1`] **MissingTag**: Missing tag '{0}'.
- `[Critical]`[`1.8.2`] **EmptyTag**: Empty tag '{0}'.
- `[Critical]`[`1.8.3`] **InvalidValue**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'.

### `Protocol.Type` / CheckOptionsAttribute

- `[Critical]`[`1.9.2`] **UpdatedDveExportProtocolName**: DVE Protocol with Name '{0}' for Table '{1}' was changed into '{2}'.
- `[Critical]`[`1.9.3`] **RemovedDveExportProtocolName**: DVE Protocol with Name '{0}' for Table '{1}' was removed.
- `[Critical]`[`1.9.4`] **AddedNoElementPrefix**: NoElementPrefix option was added to DVE Protocol with Name '{0}' for Table '{1}'.
- `[Critical]`[`1.9.5`] **RemovedNoElementPrefix**: NoElementPrefix option was removed from DVE Protocol with Name '{0}' for Table '{1}'.
- `[Major]`[`1.9.6`] **AddedUnicode**: Unicode option on protocol was added.
- `[Major]`[`1.9.7`] **RemovedUnicode**: Unicode option on protocol was removed.
- `[Warning]`[`1.9.8`] **EmptyAttribute**: Empty attribute '{0}'. *(autofix)*
- `[Major]`[`1.9.9`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Major]`[`1.9.11`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`1.9.12`] **ReferencedParamWrongType**: Invalid DVE Param Type '{0}'. Expected Type 'array'. Param ID '{1}'.
- `[Major]`[`1.9.13`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on DVE Table. Table PID '{0}'.

### `Protocol.DVEs.DVEProtocols.DVEProtocol` / CheckNameAttribute

- `[Critical]`[`1.10.1`] **UpdatedValue**: DVE Protocol with Name '{0}' for Table '{1}' was changed into '{2}'.
- `[Critical]`[`1.10.2`] **RemovedItem**: DVE Protocol with Name '{0}' for Table '{1}' was removed.

### `Protocol.Type` / CheckAdvancedAttribute

- `[Warning]`[`1.11.4`] **EmptyAttribute**: Empty attribute '{0}'. *(autofix)*
- `[Warning]`[`1.11.5`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Warning]`[`1.11.6`] **UntrimmedValueInAttribute_Sub**: Untrimmed value '{0}' in attribute '{1}'.
- `[Major]`[`1.11.7`] **UnknownConnection**: Unknown connection type '{0}' in Connection '{1}'.

### `Protocol.DVEs.DVEProtocols.DVEProtocol.ElementPrefix` / CheckElementPrefixTag

- `[Critical]`[`1.16.1`] **AddedElementPrefix**: ElementPrefix was added to DVE Protocol with Name '{0}' for Table '{1}'.
- `[Critical]`[`1.16.2`] **RemovedElementPrefix**: ElementPrefix was removed from DVE Protocol with Name '{0}' for Table '{1}'.

### `Protocol.Type` / CheckDatabaseOptionsAttribute

- `[Major]`[`1.17.1`] **EnabledPartitionedTrending**: Partitioned trending was enabled on protocol.

### `Protocol` / CheckXMLDeclaration

- `[Major]`[`1.18.1`] **InvalidDeclaration**: Invalid XML encoding '{0}'. Possible values '{1}'. *(autofix)*

### `Protocol.Display` / CheckDefaultPageAttribute

- `[Minor]`[`1.21.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Minor]`[`1.21.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Major]`[`1.21.3`] **UnexistingPage**: The specified defaultPage '{0}' does not exist.
- `[Warning]`[`1.21.4`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Warning]`[`1.21.5`] **InvalidDefaultPage**: The default page should be a page with name 'General'.
- `[Warning]`[`1.21.6`] **UnsupportedPage**: Unsupported popup page '{0}' in defaultPage attribute.

### `Protocol.Display` / CheckPageOrderAttribute

- `[Minor]`[`1.22.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Minor]`[`1.22.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`1.22.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Warning]`[`1.22.4`] **UnsupportedPage**: Unsupported popup page '{0}' in 'Protocol/Display@pageOrder' attribute. *(autofix)*
- `[Warning]`[`1.22.5`] **MissingPage**: Missing page '{0}' on 'Protocol/Display@pageOrder' attribute.
- `[Warning]`[`1.22.6`] **MissingWebPage**: Missing WebInterface page.
- `[Warning]`[`1.22.7`] **WrongWebPagePosition**: Web page '{0}' should be defined after all regular pages and the first web page should be preceded by a separator.
- `[Major]`[`1.22.8`] **UnexistingPage**: The specified page '{0}' does not exist.
- `[Warning]`[`1.22.9`] **DuplicateEntries**: Page '{0}' has been added more than once to the pageOrder attribute. *(autofix)*
- `[Warning]`[`1.22.10`] **MissingPage_Sub**: Param with ID '{0}' is positioned on page '{1}' which is not ordered via 'Protocol/Display@pageOrder' attribute.
- `[Major]`[`1.22.11`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`1.22.12`] **ReferencedParamRTDisplayExpected**: RTDisplay(true) expected on Param '{0}' referenced by the 'Protocol/Display@pageOrder' attribute.

### `Protocol` / CheckConnections

- `[Major]`[`1.23.1`] **MismatchingNames**: Connection {0} has mismatching names: {1}.
- `[Major]`[`1.23.2`] **InvalidConnectionName**: Invalid connection name '{0}' for a '{1}' connection. Connection ID '{2}'.
- `[Minor]`[`1.23.3`] **DuplicateConnectionName**: Duplicated {0} {1} '{2}'.
- `[Minor]`[`1.23.4`] **DuplicateConnectionName_Sub**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Major]`[`1.23.5`] **InvalidConnectionCount**: Connection count in 'Protocol/Type' tag '{0}' does not match with PortSettings count '{1}'.
- `[Critical]`[`1.23.6`] **InvalidCombinationOfSyntax1And2**: Connections can not be defined simultaneously via 'Protocol/Type' and 'Protocol/Connections'.
- `[Minor]`[`1.23.7`] **UnrecommendedSyntax2**: Unrecommended use of the 'Protocol/Connections' syntax.
- `[Major]`[`1.23.8`] **ConnectionsOrderChanged**: Order of connections changed from '{0}' to '{1}'.
- `[Major]`[`1.23.9`] **ConnectionTypeChanged**: {0} Connection '{1}' with name '{2}' was changed into '{3}'.
- `[Major]`[`1.23.10`] **ConnectionAdded**: {0} Connection '{1}' with name '{2}' was added.

### `Protocol` / CheckEndlessLoop

- `[Critical]`[`1.24.1`] **EndlessLoop**: Endless loop detected. Involved items '{0}'
- `[Critical]`[`1.24.2`] **PotentialEndlessLoop**: Potential endless loop detected. Involved items '{0}'

### `Protocol.Compliancies.MinimumRequiredVersion` / CheckMinimumRequiredVersionTag

- `[Critical]`[`1.25.1`] **MinVersionTooLow**: Minimum required version '{0}' too low. Expected value '{1}'. *(autofix)*
- `[Critical]`[`1.25.2`] **MinVersionTooLow_Sub**: '{0}' : '{1}'
- `[Critical]`[`1.25.3`] **MinVersionFeatureUsedInItemWithId_Sub**: Feature used in '{0}' with '{1}' '{2}'.
- `[Critical]`[`1.25.4`] **MinVersionFeatureUsedInItem_Sub**: Feature used in '{0}'.
- `[Warning]`[`1.25.5`] **UntrimmedTag**: Untrimmed tag '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`1.25.6`] **MinVersionIncreased**: Minimum DataMiner required version increased from '{0}' to '{1}'. *(autofix)*
- `[Minor]`[`1.25.7`] **MissingTag**: Missing tag '{0}'. *(autofix)*
- `[Minor]`[`1.25.8`] **EmptyTag**: Empty tag '{0}'. *(autofix)*
- `[Warning]`[`1.25.9`] **BelowMinimumSupportedVersion**: Protocol minimum required DM version '{0}' is lower than the Skyline minimum supported DM version '{1}'. *(autofix)*
- `[Minor]`[`1.25.10`] **InvalidValue**: Invalid value '{1}' in tag '{0}'.

### `Protocol` / CheckConnectionPingGroups

- `[Major]`[`1.26.1`] **InvalidPingGroupType**: Ping group for '{0}' connection is not a '{0}' poll group. Group ID '{1}'.
- `[Major]`[`1.26.2`] **PingSerialPairHasNoResponse**: Ping pair for '{0}' connection contains no response. Pair ID '{1}'.
- `[Major]`[`1.26.3`] **MultiplePingPairsForConnection**: Multiple ping pairs for connection with name '{0}' and type '{1}'. Connection ID '{2}'.
- `[Major]`[`1.26.4`] **MultiplePingPairsForConnection_Sub**: Multiple ping pairs for connection '{0}'. Pair '{1}'.

### `Protocol.Display.Pages.Page.Visibility` / CheckOverridePidAttribute

- `[Major]`[`1.27.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`1.27.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`1.27.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`1.27.4`] **NonExistingParam**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`1.27.5`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on Param '{0}' used as page visibility condition. Page name '{1}'.

### `Protocol.Display` / CheckDisplayTag

- `[Minor]`[`1.28.1`] **MissingTag**: Missing tag '{0}'.

### `Protocol.Display` / CheckWideColumnPagesAttribute

- `[Warning]`[`1.29.1`] **EmptyAttribute**: Empty attribute '{0}'. *(autofix)*
- `[Warning]`[`1.29.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Minor]`[`1.29.3`] **UnexistingPage**: The page '{0}' specified in 'Protocol/Display@wideColumnPages' does not exist.

### `Protocol` / CheckBaseForAttribute

- `[Critical]`[`1.30.1`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'.

### `Protocol` / CheckDuplicateTags

- `[Critical]`[`1.31.1`] **DuplicateRawTypeTag**: Duplicate '{0}' tag found. {1} {2} '{3}'.

## 2. Param

### `Protocol.Params.Param` / CheckIdAttribute

- `[Critical]`[`2.1.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`2.1.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Critical]`[`2.1.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`2.1.5`] **OutOfRangeId**: Out of range {0} ID '{1}'.
- `[Critical]`[`2.1.6`] **InvalidUseOfSpectrumIdRange**: Invalid use of Spectrum ID range for Param with ID '{0}'.
- `[Critical]`[`2.1.7`] **InvalidUseOfMediationIdRange**: Invalid use of Mediation ID range for Param with ID '{0}'.
- `[Critical]`[`2.1.8`] **InvalidUseOfDataMinerModulesIdRange**: Invalid use of DataMiner Modules ID range for Param with ID '{0}'.
- `[Critical]`[`2.1.9`] **InvalidUseOfEnhancedServiceIdRange**: Invalid use of Enhanced Service ID range for Param with ID '{0}'.
- `[Critical]`[`2.1.10`] **InvalidUseOfSlaIdRange**: Invalid use of SLA ID range for Param with ID '{0}'.
- `[Critical]`[`2.1.11`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.
- `[Critical]`[`2.1.12`] **MissingParam**: Missing displayed Param. Param Name '{0}'. Param Type '{1}'. Param ID '{2}'.
- `[Warning]`[`2.1.13`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Major]`[`2.1.14`] **RTDisplayExpectedOnSpectrumParam**: RTDisplay(true) expected on Spectrum Params. Param ID '{0}'.

### `Protocol.Params.Param.Name` / CheckNameTag

- `[Critical]`[`2.2.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Critical]`[`2.2.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.2.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Critical]`[`2.2.4`] **InvalidChars**: Invalid chars '{2}' in tag '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`2.2.5`] **RestrictedName**: Invalid Param Name '{1}'. Param ID '{0}'. The Param Name is reserved by DataMiner for internal use.
- `[Critical]`[`2.2.6`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Warning]`[`2.2.7`] **UnrecommendedChars**: Unrecommended chars '{2}' in tag '{0}'. Current value '{1}'. *(autofix)*
- `[Warning]`[`2.2.8`] **UnrecommendedStartChars**: Unrecommended start chars '{2}' in tag '{0}'. Current value '{1}'.
- `[Major]`[`2.2.9`] **LoggerTableColumnNameChanged**: Logger table column name '{0}' for column PID '{1}' on table '{2}' was changed into '{3}'.
- `[Major]`[`2.2.10`] **RTDisplayExpectedOnContextMenu**: RTDisplay(true) expected on Param '{0}' used as context menu for table.
- `[Major]`[`2.2.11`] **RTDisplayExpectedOnQActionFeedback**: RTDisplay(true) expected on Param '{0}' used for QAction feedback.

### `Protocol.Params.Param.Information.Subtext` / CheckSubtextTag

- `[Minor]`[`2.4.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.4.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.

### `Protocol.Params.Param.Alarm` / CheckAlarmTag

- `[Minor]`[`2.5.1`] **MissingDefaultThreshold**: Missing default thresholds on monitored parameter. Param ID '{0}'.

### `Protocol.Params.Param.Display.RTDisplay` / CheckRTDisplayTag

- `[Minor]`[`2.7.1`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.7.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Minor]`[`2.7.3`] **InvalidValue**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'. {3} {4} '{5}'.
- `[Major]`[`2.7.4`] **RTDisplayExpected**: RTDisplay(true) expected on Param '{0}'.
- `[Minor]`[`2.7.5`] **RTDisplayUnexpected**: Unexpected RTDisplay(true) on Param '{0}'.

### `Protocol.Params.Param` / CheckTrendingAttribute

- `[Major]`[`2.8.1`] **DisabledTrending**: Trending on Param '{0}' was disabled.
- `[Warning]`[`2.8.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.8.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.8.4`] **RTDisplayExpected**: RTDisplay(true) expected on trended parameters. Param ID '{0}'.

### `Protocol.Params.Param.Display.Units` / CheckUnitsTag

- `[Minor]`[`2.9.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.9.3`] **OutdatedValue**: Obsolete unit '{0}'. New syntax '{1}'. Param ID '{2}'. *(autofix)*
- `[Minor]`[`2.9.4`] **InvalidTag**: Unknown unit '{0}'. Param ID '{1}'.
- `[Major]`[`2.9.5`] **UnsupportedTag**: Unsupported '{0}' tag for '{1}' Param with ID '{2}'.
- `[Minor]`[`2.9.6`] **ExcessiveTag**: Excessive tag '{0}' because of {1}. Param ID '{2}'.
- `[Minor]`[`2.9.7`] **MissingTag**: Missing '{0}' tag for '{1}' Param with ID '{2}'.
- `[Minor]`[`2.9.8`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

### `Protocol.Params.Param.Measurement.Type` / CheckWidthAttribute

- `[Minor]`[`2.10.1`] **MissingAttribute**: Missing (page)button width attribute. Param '{0}'. *(autofix)*
- `[Minor]`[`2.10.2`] **EmptyWidth**: Empty (page)button width attribute. Param '{0}'. *(autofix)*
- `[Minor]`[`2.10.3`] **UntrimmedWidth**: Untrimmed (page)button width attribute '{0}'. Param '{1}'. *(autofix)*
- `[Minor]`[`2.10.4`] **InvalidWidth**: Invalid (page)button width attribute '{0}'. Param '{1}'. *(autofix)*
- `[Minor]`[`2.10.5`] **InconsistentWidth**: Inconsistent (page)buttons width on page '{0}'. PIDs '{1}' - Widths '{2}'.
- `[Warning]`[`2.10.6`] **UnsupportedAttribute**: The width attribute is not supported for '{0}'. Param '{1}'.
- `[Minor]`[`2.10.7`] **UnrecommendedWidth**: Unrecommended (page)button width '{0}'. Param '{1}'. *(autofix)*

### `Protocol.Params.Param.Display.Range` / CheckRangeTag

- `[Minor]`[`2.11.1`] **MissingTag**: Missing '{0}' tag for '{1}' Param with ID '{2}'.
- `[Warning]`[`2.11.2`] **UnsupportedTag**: Unsupported '{0}' tag for '{1}' Param with ID '{2}'.
- `[Warning]`[`2.11.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`2.11.4`] **LowShouldBeSmallerThanHigh**: Range/Low '{0}' should be smaller than Range/High '{1}'. Param ID '{2}'.

### `Protocol.Params.Param.Measurement.Discreets.Discreet.Value` / CheckValueTag

- `[Critical]`[`2.12.1`] **UpdatedValue**: Discreet value tag with display '{0}' on Param '{1}' was changed from '{2}' into '{3}'.
- `[Major]`[`2.12.2`] **RemovedItem**: Discreet tag with value '{0}' on Param '{1}' was removed.

### `Protocol.Params.Param.Measurement.Discreets.Discreet.Display` / CheckDisplayTag

- `[Major]`[`2.13.1`] **UpdatedValue**: Discreet display tag with value '{0}' on Param '{1}' was changed from '{2}' into '{3}'.
- `[Minor]`[`2.13.2`] **InvalidPagebuttonCaption**: Invalid pagebutton caption format '{0}'. Suggested fix '{1}'. Param ID '{2}'. *(autofix)*
- `[Major]`[`2.13.3`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.13.4`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.13.5`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.13.6`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Minor]`[`2.13.7`] **WrongCasing_Sub**: Current value '{0}'. Expected value '{1}'. {2} {3} '{4}'. *(autofix)*
- `[Minor]`[`2.13.8`] **WrongCasing**: '{0}' values do not follow {1} rules.

### `Protocol.Params.Param.Description` / CheckDescriptionTag

- `[Major]`[`2.14.1`] **UpdatedValue**: Description tag on Param '{0}' was changed from '{1}' into '{2}'.
- `[Major]`[`2.14.2`] **RemovedItem**: Description tag with value '{0}' on Param '{1}' was removed.
- `[Major]`[`2.14.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Critical]`[`2.14.4`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Critical]`[`2.14.5`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Critical]`[`2.14.6`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Minor]`[`2.14.7`] **WrongCasing_Sub**: Current value '{0}'. Expected value '{1}'. {2} {3} '{4}'. *(autofix)*
- `[Minor]`[`2.14.8`] **WrongCasing**: '{0}' values do not follow {1} rules.

### `Protocol.Params.Param.ArrayOptions` / CheckArrayOptionsTag

- `[Major]`[`2.15.1`] **DisplayColumnChangedToNaming**: DisplayColumn attribute with column idx '{0}' on table '{1}' was changed into naming options: '{2}'.
- `[Major]`[`2.15.2`] **DisplayColumnChangeToNamingFormat**: DisplayColumn attribute with column idx '{0}' on table '{1}' was changed into NamingFormat: '{2}'.

### `Protocol.Params.Param.ArrayOptions` / CheckDisplayColumnAttribute

- `[Major]`[`2.16.1`] **DisplayColumnRemoved**: DisplayColumn attribute with column idx '{0}' on table '{1}' was removed.
- `[Major]`[`2.16.2`] **DisplayColumnAdded**: DisplayColumn attribute with column idx '{0}' on table '{1}' was added.
- `[Major]`[`2.16.3`] **DisplayColumnContentChanged**: DisplayColumn attribute with column idx '{0}' on table '{1}' was changed to idx '{2}'.

### `Protocol.Params.Param.ArrayOptions` / CheckOptionsAttribute

- `[Warning]`[`2.17.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.17.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.17.3`] **NamingEmpty**: Empty option '{0}' in attribute '{1}'. {2} {3} '{4}'.
- `[Major]`[`2.17.4`] **NamingRefersToNonExistingParam**: Option '{0}' in attribute '{1}' references a non-existing '{2}' with {3} '{4}'. {5} {6} '{7}'.
- `[Major]`[`2.17.5`] **RemovedLoggerTableDatabaseLink**: Database link for logger table '{0}' was removed.
- `[Minor]`[`2.17.6`] **PreserveStateShouldBeAvoided**: Unrecommended use of the "preserve state" option on table '{0}'.
- `[]`[`2.17.7`] **ViewTableInvalidReference**: Table view option '{0}' must refer to an existing table excluding the view table itself. View table PID '{1}'.
- `[Major]`[`2.17.8`] **ViewTableFilterChangeInvalidColumns**: Column '{0}' specified in the filterChange option must refer to a column of the view table '{1}'.
- `[Major]`[`2.17.9`] **ViewTableDirectViewInvalidColumn**: Column '{0}' specified in the directView option of view table '{1}' must refer to a column of another table.

### `Protocol.Params.Param.Interprete.Type` / CheckTypeTag

- `[Major]`[`2.20.1`] **UpdatedValue**: Interprete type on Param '{0}' has been changed from '{1}' to '{2}'.
- `[Major]`[`2.20.2`] **RemovedTag**: Interprete type on Param '{0}' has been removed.
- `[Major]`[`2.20.3`] **AddedTag**: New Type tag '{0}' for interprete in Param '{1}' was added.

### `Protocol.Params.Param.Type` / CheckOptionsAttribute

- `[Major]`[`2.21.2`] **MatrixDimensionsChanged**: Matrix Dimensions on Param '{0}' was changed from '{1}' to '{2}'.
- `[Major]`[`2.21.3`] **MatrixDimensionsRemoved**: Matrix Dimensions '{0}' on Param '{1}' were removed.
- `[Critical]`[`2.21.4`] **MissingHeaderTrailerLinkOptions**: HeaderTrailerLink option should be defined on {0} with PID '{1}'.
- `[Critical]`[`2.21.5`] **InvalidHeaderTrailerLinkOptions**: HeaderTrailerLink option is wrongly defined on {0} with PID '{1}'.
- `[Warning]`[`2.21.6`] **ExcessiveHeaderTrailerLinkOptions**: HeaderTrailerLink option should not be defined on Param '{0}' as it is nor a header nor a trailer. *(autofix)*
- `[Critical]`[`2.21.7`] **DuplicateHeaderTrailerLinkOptions**: HeaderTrailerLink with ID '{0}' defined on more than 1 {1}. PIDs {2}.
- `[Major]`[`2.21.8`] **InconsistentColumnTypeDimensions**: Matrix option '{0}' not inline with option '{1}'. Matrix PID '{2}'.
- `[Major]`[`2.21.9`] **InvalidColumnTypeParamRawType**: Invalid Interprete/RawType '{0}' for 'Matrix ColumnType Param'. ColumnType PID '{1}'. Matrix PID '{2}'. Possible values 'numeric text, unsigned number'.
- `[Major]`[`2.21.11`] **MissingMatrixOptions**: Missing '{0}' option for matrix. Param ID '{1}'.
- `[Major]`[`2.21.12`] **MissingAttributeForMatrix**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Major]`[`2.21.13`] **InvalidMatrixParamType**: Invalid Param Type '{0}' on matrix. Matrix PID '{1}'.
- `[Major]`[`2.21.14`] **InvalidMatrixOption**: Invalid syntax for the '{0}' option. Matrix PID '{1}'.
- `[Major]`[`2.21.15`] **InvalidColumnTypeParamLengthType**: Invalid Interprete/LengthType '{0}' for 'Matrix ColumnType Param'. ColumnType PID '{1}'. Matrix PID '{2}'. Possible values 'next param, fixed'.
- `[Major]`[`2.21.16`] **InvalidColumnTypeParamType**: Invalid Interprete/Type '{0}' for 'Matrix ColumnType Param'. ColumnType PID '{1}'. Matrix PID '{2}'. Possible values 'double'.
- `[Major]`[`2.21.17`] **MissingColumnTypeParam**: Missing 'columntypes' Param with ID '{0}' for matrix Param with ID '{1}'. *(autofix)*
- `[Major]`[`2.21.18`] **MissingColumnTypeParamInterprete**: Missing 'Interprete' Tag on matrix ColumnType Param with ID '{0}' for matrix Param with ID '{1}'. *(autofix)*
- `[Major]`[`2.21.19`] **InvalidColumnTypeParamInterprete**: Invalid Interprete for 'Matrix ColumnType Param'. ColumnType PID '{0}'. Matrix PID '{1}'.
- `[Minor]`[`2.21.20`] **UnrecommendedSshOptions**: Unrecommended option '{0}' in Param '{1}'
- `[Major]`[`2.21.21`] **InvalidMixOfSshOptionsAndPortSettings**: Mixing option {0} and PortSettings SSH is invalid. Param ID '{1}'.
- `[Major]`[`2.21.22`] **HeaderTrailerLinkShouldHaveConnection**: Connection option should be defined on {0} with PID '{1}'.
- `[Minor]`[`2.21.23`] **HeaderTrailerConnectionShouldBeValid**: The connection '{0}' needs to be a valid connection type when used on a {1} with PID '{2}'.

### `Protocol.Params.Param.Display.Positions.Position.Page` / CheckPageTag

- `[Major]`[`2.22.1`] **RemovedFromPage**: Param '{0}' was removed from page '{1}'.
- `[Major]`[`2.22.2`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.22.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.22.4`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.22.5`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Minor]`[`2.22.6`] **WrongCasing_Sub**: Current value '{0}'. Expected value '{1}'. {2} {3} '{4}'. *(autofix)*
- `[Minor]`[`2.22.7`] **WrongCasing**: '{0}' values do not follow {1} rules.

### `Protocol.Params.Param.Alarm` / CheckTypeAttribute

- `[Major]`[`2.23.1`] **RemovedNormalizationAlarmType**: Normalization with Alarm type '{0}' on Param '{1}' was removed.
- `[Major]`[`2.23.2`] **UpdatedNormalizationAlarmType**: Normalization with Alarm type '{0}' on Param '{1}' was changed into '{2}'.
- `[Major]`[`2.23.3`] **AddedNormalizationAlarmType**: Normalization with Alarm type '{0}' on Param '{1}' was added.

### `Protocol.Params.Param.Alarm.Monitored` / CheckMonitoredTag

- `[Major]`[`2.24.1`] **RemovedAlarming**: Alarming for Param '{0}' was removed.
- `[Major]`[`2.24.2`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.24.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`2.24.4`] **InvalidTag**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'. {3} {4} '{5}'.
- `[Minor]`[`2.24.5`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.24.6`] **RTDisplayExpected**: RTDisplay(true) expected on alarmed (monitored) parameters. Param ID '{0}'.

### `Protocol.Params.Param.ArrayOptions.ColumnOption` / CheckIdxAttribute

- `[Major]`[`2.25.1`] **UpdatedIdxValue**: Column with PID '{0}' had its SLProtocol position changed from '{1}' into '{2}'. Table PID '{3}'.
- `[Major]`[`2.25.2`] **UpdatedIdxValue_Parent**: Some columns have their SLProtocol position changed. Table PID '{0}'.

### `Protocol.Params.Param.ArrayOptions` / CheckPartialAttribute

- `[Major]`[`2.26.1`] **EnabledPartial**: Partial Table option was enabled on table '{0}'.

### `Protocol.Params.Param.ArrayOptions` / CheckLoggerTable

- `[Major]`[`2.27.1`] **RemovedLoggerColumn**: Column with PID '{0}' was removed from logger table '{1}'.

### `Protocol.Params.Param.Database.ColumnDefinition` / CheckColumnDefinitionTag

- `[Major]`[`2.28.1`] **ChangedLoggerDataType**: Database type '{0}' for columns on table '{1}' was changed into '{2}'.

### `Protocol.Params.Param` / CheckHistorySetAttribute

- `[Major]`[`2.29.1`] **EnabledHistorySet**: HistorySet attribute was enabled on Param '{0}'.

### `Protocol.Params.Param.Display.Trending.Type` / CheckTypeTag

- `[Major]`[`2.30.1`] **UpdatedTrendType**: Trend Type '{0}' on Param '{1}' was changed into '{2}'.

### `Protocol.Params.Param.Measurement.Type` / CheckOptionsAttribute

- `[Major]`[`2.31.1`] **ColumnOrderChanged**: Displayed column order with PID's '{0}' in table '{1}' was changed to '{2}'.
- `[Major]`[`2.31.2`] **MissingPriorityForSortedColumns**: Missing column sorting priorities on table '{0}'.
- `[Major]`[`2.31.3`] **InvalidConnectedMatrixPoints**: '{0}': Invalid '{1}' number of connections for one {2} for matrix '{3}'.
- `[Major]`[`2.31.4`] **InvalidColumnDimensionsToOutputCount**: Matrix Param '{0}' Measurement/Type@options - matrix:outputCount of '{1}' does not match Param/Type@options - dimensions: columnCount of '{2}'. *(autofix)*
- `[Major]`[`2.31.5`] **InvalidMatrixDimensionsToInputCount**: Matrix Param '{0}' Measurement/Type@options - matrix:inputCount of '{1}' does not match Param/Type@options - dimensions: rowCount of '{2}'. *(autofix)*
- `[Major]`[`2.31.6`] **InvalidMatrixOption**: Invalid syntax for the '{0}' option. Matrix PID '{1}'.
- `[Major]`[`2.31.7`] **MissingMatrixOption**: Missing '{0}' option for matrix Param. Matrix PID '{1}'.
- `[Major]`[`2.31.8`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Minor]`[`2.31.9`] **MissingSortingOnDateTimeColumn**: Table not mainly sorted on one of its date(time) column(s). Table PID '{0}'. Date(time) column PIDs '{1}'.
- `[Major]`[`2.31.10`] **ReferencedParamRTDisplayExpected**: RTDisplay(true) expected on Param '{0}' displayed as table column. Table PID '{1}'.

### `Protocol.Params.Param.Display.Range.Low` / CheckLowTag

- `[Major]`[`2.32.1`] **UpdatedLowRange**: Low range '{0}' in Param '{1}' increased to '{2}'.
- `[Major]`[`2.32.2`] **AddedLowRange**: Low range '{0}' in Param '{1}' was added.
- `[Minor]`[`2.32.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.32.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Warning]`[`2.32.5`] **UntrimmedValue**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.32.6`] **LogarithmicLowerOrEqualToZero**: Range/Low '{0}' should be bigger than zero due to Trending@logarithmic 'true'. Param ID '{1}'.
- `[Minor]`[`2.32.7`] **WriteDifferentThanRead**: Range/Low on write Param '{0}' is different than the one on read Param '{1}'. Write PID '{2}'.

### `Protocol.Params.Param.Display.Range.High` / CheckHighTag

- `[Major]`[`2.33.1`] **UpdatedHighRange**: High range '{0}' in Param '{1}' decreased to '{2}'.
- `[Major]`[`2.33.2`] **AddedHighRange**: High range '{0}' in Param '{1}' was added.
- `[Minor]`[`2.33.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.33.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Warning]`[`2.33.5`] **UntrimmedValue**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.33.6`] **LogarithmicLowerOrEqualToZero**: Range/High '{0}' should be bigger than zero due to Trending@logarithmic 'true'. Param ID '{1}'.
- `[Minor]`[`2.33.7`] **WriteDifferentThanRead**: Range/High on write Param '{0}' is different than the one on read Param '{1}'. Write PID '{2}'.

### `Protocol.Params.Param.Alarm` / CheckOptionsAttribute

- `[Major]`[`2.34.1`] **UpdatedThresholdAlarmType**: Threshold with value '{0}' on Param '{1}' was changed into '{2}'.
- `[Major]`[`2.34.2`] **AddedThresholdAlarmType**: Threshold with value '{0}' was added to Param '{1}'.
- `[Major]`[`2.34.3`] **RemovedThresholdAlarmType**: Threshold with value '{0}' was removed from Param '{1}'.
- `[Warning]`[`2.34.4`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.34.5`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.34.6`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.34.7`] **ReferencedParamRTDisplayExpected**: RTDisplay(true) expected on Param '{0}' referenced by a 'Alarm@option' attribute. Param ID '{1}'.

### `Protocol.Params.Param.ArrayOptions.ColumnOption` / CheckColumnOptionTag

- `[Major]`[`2.35.1`] **RemovedColumnOptionTag**: Column with PID '{0}' was removed from table '{1}'.

### `Protocol.Params.Param.Interprete.Exceptions` / CheckExceptionsTag

- `[Major]`[`2.36.1`] **UpdatedExceptionValueTag**: Exception value tag for exception with id '{0}' on Param '{1}' was changed from '{2}' to '{3}'.
- `[Major]`[`2.36.2`] **RemovedException**: Exception with id '{0}' was removed from Param '{1}'.
- `[Major]`[`2.36.3`] **AddedException**: Exception with id '{0}' was added to Param '{1}'.
- `[Minor]`[`2.36.4`] **ExceptionIncompatibleWithParamType**: Interprete/Exceptions is incompatible with Param/Type '{0}'. Param ID '{1}'.

### `Protocol.Params.Param.Measurement.Type` / CheckTypeTag

- `[Minor]`[`2.37.1`] **TogglebuttonRecommended**: Measurement/Type 'togglebutton' is recommended for Param with ID '{0}'. *(autofix)*
- `[Major]`[`2.37.2`] **MatrixInvalidInterpreteRawType**: Invalid RawType '{0}' for matrix Param '{1}'. Expected RawType 'other'.
- `[Major]`[`2.37.3`] **MatrixInvalidInterpreteType**: Invalid Interprete/Type '{0}' for matrix Param '{1}'. Expected Type '{2}'.
- `[Major]`[`2.37.4`] **MatrixInvalidInterpreteLengthType**: Invalid LengthType '{0}' for matrix Param '{1}'. Expected LengthType 'next param'.
- `[Major]`[`2.37.5`] **MatrixAlarmingDisabled**: {0} Param '{1}' should be alarmed. *(autofix)*
- `[Major]`[`2.37.6`] **MatrixTrendingEnabled**: {0} Param '{1}' should not be trended. *(autofix)*
- `[Major]`[`2.37.7`] **MatrixSetterOnWrite**: Unsupported attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.37.8`] **MatrixInvalidInterprete**: Invalid Interprete for matrix Param '{0}'. *(autofix)*
- `[Major]`[`2.37.9`] **InvalidParamType**: Invalid value '{0}' in '{1}' for '{2}'. {3} {4} '{5}'.
- `[Major]`[`2.37.10`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`2.37.11`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Warning]`[`2.37.12`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Minor]`[`2.37.13`] **DeepPageButtonNesting**: Deep pageButton nesting: {0} levels deep (max recommended: 2). PageButton PID '{1}'.

### `Protocol.Params.Param.ArrayOptions.ColumnOption` / CheckOptionsAttribute

- `[Major]`[`2.38.1`] **ViewInvalidSyntax**: Invalid syntax on view option of column with IDX '{0}'. View table '{1}'.
- `[]`[`2.38.2`] **ViewInvalidColumnReference**: Column view option '{0}' must refer to an existing column of another table. View table PID '{1}'.
- `[Major]`[`2.38.3`] **ViewInvalidCombinationFilterChange**: Invalid combination of view table filterChange option with column view option. View table PID '{0}'.
- `[Major]`[`2.38.4`] **ForeignKeyMissingRelation**: Missing Relation between table '{0}' and table '{1}' due to foreignKey on column '{2}'.
- `[Major]`[`2.38.5`] **ColumnOptionExpectingRTDisplay**: RTDisplay(true) expected on column Param '{0}' due to '{1}' in 'ColumnOption@options' attribute. Table PID '{2}'.
- `[Major]`[`2.38.6`] **ForeignKeyTargetExpectingRTDisplayOnPK**: RTDisplay(true) expected on PK column Param '{0}' due to '{1}' in 'ColumnOption@options' attribute. Table PID '{2}'.
- `[Major]`[`2.38.7`] **ForeignKeyColumnInvalidInterpreteType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.38.8`] **ForeignKeyColumnInvalidMeasurementType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.38.9`] **ForeignKeyColumnInvalidType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param.ArrayOptions` / CheckDisplayKey

- `[Warning]`[`2.39.1`] **DuplicateDisplayKeyDefinition**: Table with ID '{0}' has multiple display key definitions. *(autofix)*
- `[Minor]`[`2.39.2`] **DisplayColumnSameAsPK**: DisplayColumn is the same as the primary key. Table PID '{0}'. *(autofix)*
- `[Minor]`[`2.39.3`] **DisplayColumnUnrecommended**: Unrecommended use of displayColumn. Table PID '{0}'.
- `[Major]`[`2.39.4`] **FormatChanged**: Table display key was changed from {0} '{1}' to {2} '{3}'. Table PID '{4}'.
- `[Major]`[`2.39.5`] **FormatRemoved**: Table display key previously defined via '{0}' was removed. Table PID '{1}'.
- `[Major]`[`2.39.6`] **DisplayKeyColumnInvalidInterpreteType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.39.7`] **DisplayKeyColumnInvalidMeasurementType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.39.8`] **DisplayKeyColumnInvalidType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Minor]`[`2.39.9`] **DisplayKeyColumnMissing**: Missing column with ColumnOption@type="displaykey". Table PID {0}.
- `[Minor]`[`2.39.10`] **UnexpectedIdxSuffix**: Unexpected [IDX] suffix on Param/Description. Column Pid {0}.
- `[Major]`[`2.39.11`] **DuplicateDisplayKeyColumn**: Table has multiple ColumnOption tags with value 'displaykey' in type attribute. Table Pid {0}.

### `Protocol.Params.Param.Interprete.Exceptions.Exception.Display` / CheckDisplayTag

- `[Minor]`[`2.40.1`] **UnrecommendedNADisplayValue**: Unrecommended use of Exception Display '{0}' on Param '{1}'. Possible values '{2}'. *(autofix)*
- `[Major]`[`2.40.2`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.40.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.40.4`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.40.5`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Minor]`[`2.40.6`] **WrongCasing_Sub**: Current value '{0}'. Expected value '{1}'. {2} {3} '{4}'. *(autofix)*
- `[Minor]`[`2.40.7`] **WrongCasing**: '{0}' values do not follow {1} rules.

### `Protocol.Params.Param.Measurement.Discreets` / CheckMatrixDiscreets

- `[Major]`[`2.41.1`] **InvalidDiscreetCount**: Invalid number of Discreets '{0}' for matrix Param. Expected count '{1}'. Param ID '{2}'.
- `[Major]`[`2.41.2`] **MissingDiscreetValue**: Missing matrix Discreet values '{0}'. Param ID '{1}'.
- `[Major]`[`2.41.3`] **DiscreetsNotOneBased**: Matrix Discreet values should be one-based. Param ID '{0}'.

### `Protocol.Params.Param.Measurement.Type` / CheckLinkAttribute

- `[Major]`[`2.42.1`] **InvalidAttribute**: Invalid syntax for 'Measurement/Type@link' attribute on matrix Param. Matrix PID '{0}'.
- `[Major]`[`2.42.2`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*

### `Protocol.Params.Param.Display.Positions.Position.Row` / CheckRowTag

- `[Major]`[`2.43.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.43.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`2.43.3`] **InvalidTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Minor]`[`2.43.4`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

### `Protocol.Params.Param.Display.Positions.Position.Column` / CheckColumnTag

- `[Major]`[`2.44.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.44.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`2.44.3`] **InvalidTag**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'. {3} {4} '{5}'.
- `[Minor]`[`2.44.4`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Minor]`[`2.44.5`] **UnrecommendedValue**: Unrecommended use of more than 2 columns. Page '{0}'. Param IDs '{1}'.

### `Protocol.Params.Param.Interprete.Others` / CheckOthersTag

- `[Major]`[`2.45.1`] **UpdateOtherId**: Id attribute '{0}' has been changed to '{1}' for Other tag with Value tag '{2}'. Param ID '{3}'.
- `[Major]`[`2.45.2`] **UpdateOtherDisplay**: Display tag '{0}' has been changed to '{1}' for Other tag with Value tag '{2}'. Param ID '{3}'.
- `[Major]`[`2.45.3`] **DeletedValue**: Other with Value tag '{0}' has been deleted. Param '{1}'.
- `[Major]`[`2.45.4`] **AddedOthers**: Other with Value tag '{0}' has been added. Param '{1}'.

### `Protocol.Params.Param.ArrayOptions` / CheckIndexAttribute

- `[Major]`[`2.46.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Major]`[`2.46.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Major]`[`2.46.3`] **InvalidAttributeValue**: Unsupported attribute '{0}' in {1} '{2}'. Current value '{3}'.
- `[Major]`[`2.46.4`] **NonExistingColumn**: Reference to non-existing column with IDX '{0}' in attribute 'index'. Table ID '{1}'.
- `[Minor]`[`2.46.5`] **UnrecommendedValue**: Unrecommended value '{0}' in attribute 'index'. Recommended values '{2}'. Table ID '{1}'.
- `[Warning]`[`2.46.6`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.46.7`] **InvalidColumnInterpreteType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.46.8`] **InvalidColumnMeasurementType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.46.9`] **InvalidColumnType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param.SNMP.OID` / CheckOidTagIdAttrCombo

- `[Minor]`[`2.47.1`] **ExcessiveAttribute**: Unsupported attribute '{0}' in {1} '{2}'.
- `[Minor]`[`2.47.2`] **InvalidCombo**: Invalid combination of OID value '{0}' and SNMP/OID@id value '{1}' in Param '{2}'.

### `Protocol.Params.Param.SNMP.OID` / CheckIdAttribute

- `[Major]`[`2.48.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`2.48.2`] **InvalidAttributeValue**: Unsupported attribute '{0}' in {1} '{2}'. Current value '{3}'.
- `[Major]`[`2.48.3`] **NonExistingParam**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.48.4`] **UnsupportedParam**: Unsupported Param '{0}' reference in attribute 'SNMP/OID@id' in Param '{1}'.
- `[Warning]`[`2.48.5`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

### `Protocol.Params.Param.Message` / CheckMessageTag

- `[BubbleUp]`[`2.49.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Minor]`[`2.49.2`] **MissingTag_Sub**: Missing tag 'Param/Message' for button with caption '{0}'.

### `Protocol.Params.Param.Measurement.Discreets.Discreet` / CheckOptionsAttribute

- `[BubbleUp]`[`2.50.1`] **MisconfiguredConfirmOptions**: Misconfigured 'confirm' option(s) in 'Discreet@options' for ContextMenu. Param ID '{0}'.
- `[Minor]`[`2.50.2`] **MissingConfirmOption**: Missing value '{0}' in attribute '{1}' for {2} '{3}'. {4} {5} '{6}'.
- `[Minor]`[`2.50.3`] **EmptyConfirmOption**: Empty option '{0}' in attribute '{1}' for {2} '{3}'. {4} {5} {6}'.
- `[Warning]`[`2.50.4`] **UntrimmedConfirmOption**: Untrimmed option '{0}' in attribute '{1}' for {2} '{3}' in {4} with {5} '{6}'. Current value '{7}'. *(autofix)*

### `Protocol.Params.Param.Measurement.Discreets` / CheckDiscreetsTag

- `[Major]`[`2.51.1`] **MissingTag**: Missing '{0}' tag for '{1}' Param with ID '{2}'.

### `Protocol.Params.Param.Measurement.Discreets.Discreet` / CheckDiscreetTag

- `[Major]`[`2.52.1`] **MissingTag**: Missing 'Discreet' tag(s) in 'Measurement/Discreets' tag. Param ID '{0}'.

### `Protocol.Params.Param.Name` / CheckColumnNames

- `[Minor]`[`2.53.1`] **MissingTableNameAsPrefixes**: Missing table name '{0}' in front of column names. Table PID '{1}'.
- `[Minor]`[`2.53.2`] **MissingTableNameAsPrefix**: Missing table name '{0}' in front of column name '{1}'. Column PID '{2}'. *(autofix)*

### `Protocol.Params.Param.Measurement.Discreets` / CheckDependencyId

- `[Major]`[`2.54.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.54.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.54.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`2.54.4`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.54.5`] **ReferencedParamWrongType**: Invalid Param Type '{0}' on Param referenced by a 'Discreets@dependencyId' attribute. Param ID '{1}'.
- `[Major]`[`2.54.6`] **ReferencedParamRTDisplayExpected**: RTDisplay(true) expected on Param '{0}' referenced by a 'Discreets@dependencyId' attribute. Param ID '{1}'.

### `Protocol.Params.Param.SNMP.TrapOID` / CheckMapAlarmAttribute

- `[Major]`[`2.55.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.55.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.55.3`] **RTDisplayExpected**: RTDisplay(true) expected on Param '{0}' generating alarms based on traps.

### `Protocol.Params` / CheckLoadSequenceAttribute

- `[Warning]`[`2.56.1`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`2.56.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Major]`[`2.56.3`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`2.56.5`] **ReferencedParamSaveExpected**: Param '{0}' referenced by 'Params@loadSequence' attribute is expected to be saved.
- `[Major]`[`2.56.6`] **ReferencedParamRTDisplayExpected**: RTDisplay(true) expected on Param '{0}' referenced by 'Params@loadSequence' attribute.

### `Protocol.Params.Param.Display.Positions` / CheckPositionsTag

- `[Major]`[`2.57.1`] **EmptyTag**: Missing tag '{0}' in {1} '{2}'. *(autofix)*
- `[Major]`[`2.57.2`] **RTDisplayExpected**: RTDisplay(true) expected on Param '{0}' which is positioned.

### `Protocol.Params.Param.Type` / CheckVirtualAttribute

- `[Warning]`[`2.58.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.58.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.58.3`] **RTDisplayExpected**: RTDisplay(true) expected on parameters used as virtual source. Param ID '{0}'.

### `Protocol.Params.Param.Measurement.Discreets.Discreet` / CheckDependencyValuesAttribute

- `[Warning]`[`2.59.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.59.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.59.3`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.59.4`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on Param '{0}' referenced in 'Discreet@dependencyValues' attribute. Param ID '{1}'.

### `Protocol.Params.Param.Display` / CheckDisplayTag

- `[Warning]`[`2.60.1`] **EmptyTag**: Missing tag '{0}' in {1} '{2}'. *(autofix)*

### `Protocol.Params.Param.Type` / CheckTypeTag

- `[Major]`[`2.61.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.61.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.61.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.61.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Params.Param.Type` / CheckIdAttribute

- `[Major]`[`2.62.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.62.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.62.3`] **NonExistingParam**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.62.4`] **NonExistingResponse**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.62.5`] **NonExistingColumn**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.62.6`] **MissingAttribute**: Missing attribute '{0}' due to '{1}' '{2}'. {3} {4} '{5}'.

### `Protocol.Params.Param.ArrayOptions.ColumnOption` / CheckPidAttribute

- `[Major]`[`2.63.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`2.63.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.63.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.63.4`] **NonExistingParam**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param` / CheckColumns

- `[Major]`[`2.64.1`] **ColumnInvalidType**: Invalid value '{0}' in tag '{1}' for {2}. Possible values '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param.ArrayOptions.NamingFormat` / CheckNamingFormatTag

- `[Major]`[`2.65.1`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.65.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.65.3`] **NonExistingParam**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.65.4`] **MissingDynamicPart**: Missing dynamic part(s) in 'ArrayOptions/NamingFormat' tag. Table PID '{0}'.

### `Protocol.Params.Param.Information.Includes` / CheckIncludesTag

- `[Warning]`[`2.66.1`] **ObsoleteTag**: Obsolete tag '{0}'. {1} {2} '{3}'. *(autofix)*

### `Protocol.Params.Param.Dependencies.Id` / CheckIdTag

- `[Major]`[`2.67.1`] **EmptyTag**: Missing tag '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.67.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.67.3`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.67.4`] **RTDisplayExpected**: RTDisplay(true) expected on Param '{0}' containing 'Dependencies/Id' tag(s).
- `[Major]`[`2.67.5`] **RTDisplayExpectedOnReferencedParam**: RTDisplay(true) expected on Param '{0}' referenced by a 'Dependencies/Id' tag. Param ID '{1}'.

### `Protocol.Params.Param.Interprete.DefaultValue` / CheckDefaultValueTag

- `[Major]`[`2.68.1`] **UnsupportedTag**: Unsupported tag '{0}' in {1} '{2}'.
- `[Major]`[`2.68.2`] **NotYetSupportedTag**: Unsupported tag '{0}' in {1} '{2}'.
- `[Major]`[`2.68.3`] **ValueIncompatibleWithInterpreteType**: Interprete/DefaultValue '{0}' is incompatible with Interprete/Type '{1}'. Param ID '{2}'.

### `Protocol.Params.Param.Interprete.LengthType` / CheckIdAttribute

- `[Major]`[`2.69.1`] **MissingAttribute**: Missing attribute '{0}' due to '{1}' '{2}'. {3} {4} '{5}'.
- `[Major]`[`2.69.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.69.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.69.4`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.69.5`] **ReferencedParamWrongInterpreteType**: Invalid {0} '{1}' on {4} referenced by {2}. Expected value '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param.Interprete.Exceptions.Exception` / CheckValueAttribute

- `[Major]`[`2.70.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`2.70.2`] **ValueIncompatibleWithInterpreteType**: Incompatible '{0}' value '{1}' with '{2}' value '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param.Interprete.Exceptions.Exception.Value` / CheckValueTag

- `[Major]`[`2.71.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Warning]`[`2.71.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.71.3`] **ValueIncompatibleWithInterpreteType**: Incompatible '{0}' value '{1}' with '{2}' value '{3}'. {4} {5} '{6}'.

### `Protocol.Params.Param.Alarm.Monitored` / CheckDisabledIfAttribute

- `[Major]`[`2.72.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`2.72.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.72.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`2.72.4`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`2.72.5`] **ReferencedParamWrongType**: Invalid Param Type '{0}' on Param referenced by a 'Monitored@disabledIf' attribute. Param ID '{1}'.
- `[Major]`[`2.72.6`] **ReferencedParamRTDisplayExpected**: RTDisplay(true) expected on Param '{0}' referenced by a 'Monitored@disabledIf' attribute. Param ID '{1}'.

### `Protocol.Params.Param.Interprete.LengthType` / CheckLengthTypeTag

- `[Major]`[`2.73.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.73.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`2.73.3`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Params.Param.Interprete.Length` / CheckLengthTag

- `[Major]`[`2.74.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`2.74.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[]`[`2.74.3`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Params.Param.Interprete.Exceptions.Exception.Display` / CheckStateAttribute

- `[Warning]`[`2.75.1`] **UnrecommendedEnabledValue**: Exception with state 'enabled'. Param '{0}'. *(autofix)*
- `[Warning]`[`2.75.2`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.75.3`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.75.4`] **InvalidAttributeValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. *(autofix)*
- `[Warning]`[`2.75.5`] **UntrimmedAttributeValue**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

### `Protocol.Params.Param.SNMP.OID` / CheckOptionsAttribute

- `[Warning]`[`2.76.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Warning]`[`2.76.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`2.76.3`] **MissingInstanceOption**: Missing value '{0}' in attribute '{1}'. {2} {3} '{4}'. *(autofix)*

### `Protocol.Params.Param` / CheckSaveAttribute

- `[Minor]`[`2.77.1`] **UnrecommendedSavedReadParam**: Unrecommended use of 'save' attribute. Param ID '{0}'.

### `Protocol.Params.Param.ArrayOptions` / CheckVolatileTables

- `[Minor]`[`2.78.1`] **SuggestedVolatileOption**: Suggested '{0}' option '{1}' in {2} {3} '{4}'.
- `[Major]`[`2.78.2`] **IncompatibleVolatileTable**: Incompatible '{0}' option '{1}'. {2} {3} '{4}'.
- `[Major]`[`2.78.3`] **IncompatibleVolatileTable_ColumnOption**: Incompatible '{0}' option '{1}'. {2} {3} '{4}'.
- `[Major]`[`2.78.4`] **IncompatibleVolatileTable_ForeignKeyDestination**: Incompatible '{0}' value '{1}'. {2} {3} '{4}'.
- `[Major]`[`2.78.5`] **IncompatibleVolatileTable_Alarming**: Incompatible '{0}' value '{1}'. {2} {3} '{4}'.
- `[Major]`[`2.78.6`] **IncompatibleVolatileTable_DCF**: Incompatible '{0}' value '{1}'. {2} {3} '{4}'.

### `Protocol.Params.Param.Alarm.Info` / CheckInfoTag

- `[Minor]`[`2.79.1`] **UnrecommendedInfoTag**: Unrecommended tag '{0}' in {1} with {2} '{3}'. *(autofix)*
- `[Minor]`[`2.79.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'.
- `[Minor]`[`2.79.3`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.

## 4. Group

### `Protocol.Groups.Group.Name` / CheckNameTag

- `[Minor]`[`4.1.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Groups.Group.Content.Param` / CheckParamTag

- `[Major]`[`4.2.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`4.2.2`] **EmptyParamTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`4.2.3`] **InvalidParamTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`4.2.4`] **InvalidParamSuffix**: Invalid suffix '{0}' in 'Group/Content/Param' element. Group ID '{1}'.
- `[Major]`[`4.2.5`] **ObsoleteSuffixTable**: Suffix 'table' in 'Group/Content/Param' element is considered obsolete. Group ID '{0}'. *(autofix)*
- `[Major]`[`4.2.6`] **SuffixRequiresMultiThreadedTimer**: Suffix '{0}' in'Group/Content/Param' element requires the group to be called from a multi-threaded timer. Group ID '{1}'.

### `Protocol.Groups.Group.Content.Action` / CheckActionTag

- `[Major]`[`4.3.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`4.3.2`] **EmptyActionTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`4.3.3`] **InvalidActionTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Groups.Group.Content.Pair` / CheckPairTag

- `[Major]`[`4.4.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`4.4.2`] **EmptyPairTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`4.4.3`] **InvalidPairTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Groups.Group.Content.Session` / CheckSessionTag

- `[Major]`[`4.5.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`4.5.2`] **EmptySessionTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`4.5.3`] **InvalidSessionTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Groups.Group.Content.Trigger` / CheckTriggerTag

- `[Major]`[`4.6.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`4.6.2`] **EmptyTriggerTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`4.6.3`] **InvalidTriggerTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Groups.Group` / CheckConnectionPidAttribute

- `[Major]`[`4.7.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`4.7.2`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`4.7.3`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Groups.Group` / CheckIdAttribute

- `[Critical]`[`4.8.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`4.8.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`4.8.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`4.8.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`4.8.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.Groups.Group.Condition` / CheckConditionTag

- `[Major]`[`4.9.1`] **InvalidCondition**: Invalid condition '{0}'. Reason '{1}'. {2} {3} '{4}'.
- `[Major]`[`4.9.2`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Warning]`[`4.9.3`] **ConditionCanBeSimplified**: Condition '{0}' can be simplified. {1} {2} '{3}'.

### `Protocol.Groups.Group.Content` / CheckContentTag

- `[Major]`[`4.10.1`] **IncompatibleContentWithGroupType**: Incompatible 'Group/Content' child '{1}' with 'Group/Type' '{0}'. Group ID '{2}'.
- `[Major]`[`4.10.2`] **MixedTypes**: Unsupported mixed group content '{0}'. Group ID '{1}'.
- `[Minor]`[`4.10.3`] **MaxItemsMultipleGet**: Group with 'multipleGet' true contains more than 20 content elements. Group ID '{0}'.
- `[Minor]`[`4.10.4`] **MaxItems**: Group contains more than 10 content elements. Group ID '{0}'.
- `[Major]`[`4.10.5`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.

## 5. Trigger

### `Protocol.Triggers.Trigger.On` / CheckIdAttribute

- `[Major]`[`5.1.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Warning]`[`5.1.2`] **ExcessiveAttribute**: Excessive 'id' Attribute in tag 'On' with value '{0}'. Trigger ID '{1}'. *(autofix)*
- `[Major]`[`5.1.3`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Major]`[`5.1.4`] **MultipleIds**: Attribute 'On@id' cannot have multiple values. Trigger ID '{0}'.
- `[Major]`[`5.1.5`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. Possible values '{2}'.
- `[Major]`[`5.1.6`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Warning]`[`5.1.7`] **LeadingZeros**: Invalid use of leading zeros on 'On@id' attribute. Trigger ID '{0}'. Current value '{1}'. *(autofix)*
- `[Warning]`[`5.1.8`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*

### `Protocol.Triggers.Trigger.Time` / CheckTimeTag

- `[Warning]`[`5.3.1`] **MultipleAfterStartup**: Multiple after startup Triggers. Trigger IDs '{0}'.

### `Protocol.Triggers.Trigger.Condition` / CheckConditionTag

- `[Major]`[`5.5.1`] **InvalidCondition**: Invalid condition '{0}'. Reason '{1}'. {2} {3} '{4}'.
- `[Major]`[`5.5.2`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Warning]`[`5.5.3`] **ConditionCanBeSimplified**: Condition '{0}' can be simplified. {1} {2} '{3}'.

### `Protocol.Triggers.Trigger` / CheckOnTagTimeTagCombination

- `[Major]`[`5.6.1`] **InvalidOnTagTimeTagCombination**: The On tag value '{0}' can't be used in combination with the Time tag value '{1}'. Trigger ID '{2}'.
- `[Minor]`[`5.6.2`] **DuplicateTrigger**: Multiple triggers with same Time/On combination. Trigger IDs '{0}'.

### `Protocol.Triggers.Trigger` / CheckAfterStartupFlow

- `[Major]`[`5.7.1`] **InvalidAfterStartupTriggerCondition**: After startup Trigger can't have a Condition. Trigger ID '{0}'.
- `[Major]`[`5.7.2`] **InvalidAfterStartupActionCondition**: After startup Action can't have a Condition. Action ID '{0}'.
- `[Major]`[`5.7.3`] **InvalidAfterStartupTriggerType**: After startup Trigger must have a Type tag with value 'action'. Trigger ID '{0}'
- `[Major]`[`5.7.4`] **InvalidAfterStartupActionOn**: After startup Action must have an On tag with value 'group'. Action ID '{0}'.
- `[Major]`[`5.7.5`] **InvalidAfterStartupActionType**: After startup Action must have a Type tag with value 'execute next' or 'execute'. Action ID '{0}'.
- `[Major]`[`5.7.6`] **InvalidAfterStartupGroupType**: After startup Group must have a Type tag with value 'poll', 'poll trigger' or 'poll action'. Group ID '{0}'.

### `Protocol.Triggers.Trigger` / CheckIdAttribute

- `[Critical]`[`5.8.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`5.8.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`5.8.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`5.8.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`5.8.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.Triggers.Trigger.Name` / CheckNameTag

- `[Warning]`[`5.9.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Triggers.Trigger.Content.Id` / CheckIdTag

- `[Major]`[`5.10.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`5.10.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`5.10.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`5.10.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`5.10.5`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

## 6. Action

### `Protocol.Actions.Action.Name` / CheckNameTag

- `[Warning]`[`6.1.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Actions.Action` / CheckIdAttribute

- `[Critical]`[`6.2.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`6.2.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`6.2.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`6.2.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`6.2.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.Actions.Action.On` / CheckIdAttribute

- `[Major]`[`6.3.1`] **MissingAttribute**: Missing attribute '{0}' due to '{1}' '{2}'. {3} {4} '{5}'.
- `[Major]`[`6.3.2`] **EmptyAttibute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`6.3.3`] **UntrimmedValueInAttribute**: Untrimmed value '{0}' in attribute '{1}'. {2} {3} '{4}'. *(autofix)*
- `[Major]`[`6.3.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`6.3.5`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Actions.Action.Condition` / CheckConditionTag

- `[Major]`[`6.4.1`] **InvalidCondition**: Invalid condition '{0}'. Reason '{1}'. {2} {3} '{4}'.
- `[Major]`[`6.4.2`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Warning]`[`6.4.3`] **ConditionCanBeSimplified**: Condition '{0}' can be simplified. {1} {2} '{3}'.

### `Protocol.Actions.Action.Type` / CheckTypeTag

- `[Major]`[`6.5.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`6.5.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`6.5.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`6.5.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Actions.Action.On` / CheckOnTag

- `[Major]`[`6.6.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`6.6.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`6.6.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`6.6.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Actions.Action` / CheckActionTypes

- `[Major]`[`6.7.1`] **IncompatibleTypeVsOnTag**: Incompatible '{0}' value '{1}' with '{2}' value '{3}'. {4} {5} '{6}'.
- `[Major]`[`6.7.2`] **MissingOnIdAttribute**: Missing attribute '{0}' due to '{1}' '{2}' and '{3}' '{4}'. {5} {6} '{7}'.
- `[Major]`[`6.7.3`] **MissingTypeIdAttribute**: Missing attribute '{0}' due to '{1}' '{2}' and '{3}' '{4}'. {5} {6} '{7}'.
- `[Major]`[`6.7.4`] **MissingOnNrAttribute**: Missing attribute '{0}' due to '{1}' '{2}' and '{3}' '{4}'. {5} {6} '{7}'.
- `[Major]`[`6.7.5`] **NonExistingParamRefInTypeIdAttribute**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`6.7.6`] **MissingTypeIdOrTypeValueAttribute**: Missing attribute '{0}' due to '{1}' '{2}' and '{3}' '{4}'. {5} {6} '{7}'.
- `[Major]`[`6.7.7`] **ExcessiveTypeIdOrTypeValueAttribute**: Excessive attribute '{0}' due to '{1}' '{2}' and '{3}' '{4}'. {5} {6} '{7}'.
- `[Major]`[`6.7.8`] **NonExistingRefToPairOnTimeoutSetNext**: Attribute 'On@nr' references a non-existing 'Pair' with 1-based position '{0}' in Group '{1}'. Action ID '{2}' triggered by Trigger '{3}'.
- `[Major]`[`6.7.9`] **NonExistingConnectionRefInTypeNrAttribute**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`6.7.10`] **UnsupportedConnectionTypeDueTo**: {5}'Type@nr' attribute in action of type '{0}' on '{1}' references Connection '{2}' with wrong type '{3}'. Action ID '{4}'.
- `[Major]`[`6.7.11`] **UnsupportedGroupContentDueTo**: Attribute 'On@id' in action of type '{0}' on '{1}' references Group '{2}' which is missing 'Content/Param' tag(s). Action ID '{3}'.
- `[Major]`[`6.7.12`] **UnsupportedGroupParamType**: Attribute 'On@id' in action of type '{0}' on '{1}' references Group '{2}' which references Param '{3}' with unsupported 'Param/Type' '{4}'. Action ID '{5}'.
- `[Major]`[`6.7.13`] **UnsupportedGroupParamWithoutSnmp**: Attribute 'On@id' in action of type '{0}' on '{1}' references Group '{2}' which references Param '{3}' with unsupported 'SNMP/Enabled' '{4}'. Action ID '{5}'.
- `[Major]`[`6.7.100`] **UnsupportedAttributeOnNr**: Unsupported attribute '{0}' in combination with '{1}' '{2}' and  '{3}' '{4}'. {5} {6} '{7}'.

### `Protocol.Actions.Action.On` / CheckNrAttribute

- `[Major]`[`6.22.2`] **EmptyAttibute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`6.22.3`] **UntrimmedAttribute**: Untrimmed value '{0}' in attribute '{1}'. {2} {3} '{4}'. *(autofix)*
- `[Major]`[`6.22.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.

## 7. Timer

### `Protocol.Timers.Timer.Time` / CheckTimeTag

- `[Major]`[`7.1.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`7.1.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`7.1.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`7.1.4`] **InvalidTagValue**: Invalid value '{1}' in tag '{0}'. Possible values '{2}'.
- `[Major]`[`7.1.5`] **TimerTimeCannotBeLargerThan24Days**: Timer Tag value '{0}' is higher than the max allowed value of 24 days. Timer id '{1}'. *(autofix)*
- `[Minor]`[`7.1.6`] **DuplicateTimer**: Duplicate Timer with Time '{0}'. Timer IDs '{1}'.
- `[Minor]`[`7.1.7`] **TooFastTimer**: Too fast Timer Time '{0}'. Timer ID '{1}'.
- `[Minor]`[`7.1.8`] **TooSimilarTimers**: Timer Time values too similar. Timer IDs '{0}'. Time values '{1}'.

### `Protocol.Timers.Timer.Name` / CheckNameTag

- `[Warning]`[`7.2.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Timers.Timer` / CheckOptionsAttribute

- `[Major]`[`7.3.2`] **NonExistingIdInOption**: '{0}' option refers to a non-existing {1} '{2}'.
- `[Major]`[`7.3.3`] **InvalidValueInOption**: '{0}' option has an invalid value '{1}'.
- `[Major]`[`7.3.5`] **InvalidAttribute**: Invalid value for Timer@options attribute. Timer ID '{0}'. Current Value '{1}'.
- `[Major]`[`7.3.6`] **MissingIpOption**: Option '{0}' requires the 'ip' option in Timer@options. Timer ID '{1}'.
- `[Major]`[`7.3.7`] **InvalidIgnoreIfOption**: Invalid value for 'ignoreIf' option. Expected format: 'ignoreIf:<columnIdx>,<value>'. Current value '{0}'.
- `[Major]`[`7.3.8`] **InvalidEachOption**: Invalid value for 'each' option. Expected format: 'each:<period>'. Current value '{0}'.
- `[Major]`[`7.3.9`] **InvalidDynamicThreadPoolOption**: Invalid value for 'dynamicThreadPool' option. Expected format: 'dynamicThreadPool:<threadPoolSizeMonitorPid>'. Current value '{0}'.
- `[Major]`[`7.3.10`] **InvalidInstanceOption**: Invalid value for 'instance' option. Expected format: 'instance:<tablePid>,<columnIdx>'. Current value '{0}'.
- `[Major]`[`7.3.11`] **InvalidIpOption**: Invalid value for 'ip' option. Expected format: 'ip:<tablePid>,<columnIdx>'. Current value '{0}'.
- `[Major]`[`7.3.12`] **InvalidPollingRateOption**: Invalid value for 'pollingRate' option. Expected format: 'pollingRate:<interval>,<maxCount>,<releaseCount>'. Current value '{0}'.
- `[Major]`[`7.3.13`] **InvalidQActionOption**: Invalid value for 'qaction' option. Expected format: 'qaction:<qactionId>'. Current value '{0}'.
- `[Major]`[`7.3.14`] **InvalidQActionBeforeOption**: Invalid value for 'qactionBefore' option. Expected format: 'qactionBefore:<qactionId>'. Current value '{0}'.
- `[Major]`[`7.3.15`] **InvalidQActionAfterOption**: Invalid value for 'qactionAfter' option. Expected format: 'qactionAfter:<qactionId>'. Current value '{0}'.
- `[Major]`[`7.3.16`] **InvalidThreadPoolOption**: Invalid value for 'threadPool' option. Expected format: 'threadPool:<size>,<calculationInterval>,<usagePid>,<waitingPid>,<maxDurationPid>,<avgDurationPid>,<counterPid>,<queueSize>'. Current value '{0}'.
- `[Major]`[`7.3.17`] **MissingEachOption**: Option '{0}' requires the 'each' option in Timer@options. Timer ID '{1}'.
- `[Major]`[`7.3.18`] **MissingThreadPoolOption**: Option '{0}' requires the 'threadPool' option in Timer@options. Timer ID '{1}'.
- `[Major]`[`7.3.19`] **NonExistingIdInDynamicThreadPoolOption**: Option '{0}' references a non-existing '{1}' with {2} '{3}'.
- `[Major]`[`7.3.20`] **MissingValueInOption**: Required value '{0}' is not defined.
- `[Major]`[`7.3.21`] **InvalidPingOption**: Invalid value for 'ping' option. Current value: '{0}'.
- `[Major]`[`7.3.22`] **UnknownOption**: Unknown option '{0}' detected.
- `[Major]`[`7.3.23`] **DuplicateOption**: Duplicate option '{0}' detected.
- `[Major]`[`7.3.24`] **UnknownOptionInPingOption**: Unknown option '{0}' detected in 'ping' option.
- `[Major]`[`7.3.25`] **DuplicateOptionInPingOption**: Duplicate option '{0}' detected in 'ping' option.
- `[Warning]`[`7.3.26`] **ThreadPoolCalculationIntervalDefined**: Thread pool statistics can have a big impact on performance. Timer ID '{0}'.
- `[Warning]`[`7.3.27`] **UseOfObsoleteTimeoutPidOptionInPingOption**: The use of the timeoutPid option in the ping option is obsolete.
- `[Warning]`[`7.3.28`] **UseOfObsoleteQActionOption**: The use of the qaction option is obsolete.
- `[Major]`[`7.3.29`] **NonExistingColumnIdxInOption**: '{0}' option refers to a non-existing column {1} '{2}' in table '{3}'.
- `[Major]`[`7.3.30`] **NonExistingColumnPositionInOption**: '{0}' option refers to a non-existing column {1} '{2}' in table '{3}'.

### `Protocol.Timers.Timer.Condition` / CheckConditionTag

- `[Major]`[`7.4.1`] **InvalidCondition**: Invalid condition '{0}'. Reason '{1}'. {2} {3} '{4}'.
- `[Major]`[`7.4.2`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Minor]`[`7.4.3`] **UnrecommendedCondition**: Unrecommended condition on Timer. Timer ID '{0}'.
- `[Warning]`[`7.4.4`] **ConditionCanBeSimplified**: Condition '{0}' can be simplified. {1} {2} '{3}'.

### `Protocol.Timers.Timer.Content.Group` / CheckGroupTag

- `[Major]`[`7.5.2`] **NonExistingIdInGroup**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`7.5.3`] **EmptyGroupTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`7.5.4`] **InvalidGroupTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`7.5.5`] **InvalidTypeLastTimerGroup**: Invalid last group type '{0}' in Timer '{1}'. Group ID '{2}'.

### `Protocol.Timers.Timer` / CheckIdAttribute

- `[Critical]`[`7.6.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`7.6.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`7.6.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`7.6.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`7.6.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

## 8. HTTP

### `Protocol.HTTP.Session.Connection.Request.Headers` / CheckHeaders

- `[Minor]`[`8.1.1`] **MissingHeaderForVerb**: Missing Header '{0}' in HTTP '{1}' request. Session ID '{2}'. Connection ID '{3}'.
- `[Major]`[`8.1.2`] **DuplicateHeaderKeys**: Duplicate Header '{0}' in HTTP request. Session ID '{1}'. Connection ID '{2}'.

### `Protocol.HTTP.Session.Connection.Request.Headers.Header` / CheckHeaderTag

- `[Warning]`[`8.2.1`] **UntrimmedTag**: Untrimmed tag '{0}'. Current value '{1}'. *(autofix)*

### `Protocol.HTTP.Session.Connection.Request.Headers.Header` / CheckKeyAttribute

- `[Major]`[`8.3.1`] **UnknownHeaderKey**: Unknown Header key '{0}' for HTTP request. Session ID '{1}'. Connection ID '{2}'.
- `[Warning]`[`8.3.2`] **UntrimmedHeaderKey**: Untrimmed Header key '{0}' for HTTP request. Session ID '{1}'. Connection ID '{2}'. *(autofix)*
- `[Minor]`[`8.3.3`] **MissingKeyAttribute**: Missing key attribute. Session ID '{0}'. Connection ID '{1}'.
- `[Minor]`[`8.3.4`] **EmptyKeyAttribute**: Empty key attribute. Session ID '{0}'. Connection ID '{1}'.
- `[Major]`[`8.3.5`] **InvalidHeaderKeyForVerb**: Invalid Header key '{0}' for HTTP '{1}' request. Session ID '{2}'. Connection ID '{3}'.
- `[Warning]`[`8.3.6`] **RedundantHeaderKey**: Header key '{0}' is typically managed automatically by DataMiner. Session ID '{1}'. Connection ID '{2}'.
- `[Major]`[`8.3.7`] **UnsupportedHeaderKey**: Unsupported Header key '{0}'. Session ID '{1}'. Connection ID '{2}'.

### `Protocol.HTTP.Session` / CheckPasswordAttribute

- `[Major]`[`8.4.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.HTTP.Session` / CheckUsernameAttribute

- `[Major]`[`8.5.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.HTTP.Session` / CheckProxyServerAttribute

- `[Major]`[`8.6.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.HTTP.Session` / CheckProxyUserAttribute

- `[Major]`[`8.7.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.HTTP.Session` / CheckProxyPasswordAttribute

- `[Major]`[`8.8.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.HTTP.Session.Connection.Request` / CheckPidAttribute

- `[Major]`[`8.9.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.9.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.9.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session.Connection.Request.Data` / CheckPidAttribute

- `[Major]`[`8.10.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.10.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.10.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session.Connection.Request.Headers.Header` / CheckPidAttribute

- `[Major]`[`8.11.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.11.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.11.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session.Connection.Request.Parameters.Parameter` / CheckPidAttribute

- `[Major]`[`8.12.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.12.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.12.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session.Connection.Response` / CheckStatusCodeAttribute

- `[Major]`[`8.13.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.13.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.13.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session.Connection.Response.Content` / CheckPidAttribute

- `[Major]`[`8.14.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.14.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.14.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session.Connection.Response.Headers.Header` / CheckPidAttribute

- `[Major]`[`8.15.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'. {7} {8} '{9}'.
- `[Major]`[`8.15.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. {3} {4} '{5}'.
- `[Major]`[`8.15.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'. {5} {7} '{6}'.

### `Protocol.HTTP.Session` / CheckIdAttribute

- `[Critical]`[`8.16.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`8.16.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`8.16.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`8.16.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`8.16.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.HTTP.Session.Connection` / CheckIdAttribute

- `[Critical]`[`8.17.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Critical]`[`8.17.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Warning]`[`8.17.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Critical]`[`8.17.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`8.17.5`] **DuplicatedId**: More than one {0} with same ID '{1}' in {3} '{4}'. {0} Names '{2}'.

## 9. Pair

### `Protocol.Pairs.Pair.Name` / CheckNameTag

- `[Minor]`[`9.1.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Pairs.Pair.Content` / CheckContentTag

- `[Major]`[`9.2.1`] **MissingClearResponseRoutine**: Missing clear response routine for pair '{0}'.
- `[Major]`[`9.2.2`] **MissingClearResponseRoutine_Sub**: Missing clear response '{0}' routine after response '{1}'.

### `Protocol.Pairs.Pair` / CheckIdAttribute

- `[Critical]`[`9.3.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`9.3.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`9.3.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`9.3.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`9.3.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.Pairs.Pair.Content.Command` / CheckCommandTag

- `[Major]`[`9.4.1`] **MissingTag**: Missing tag '{0}' in {1} '{2}'.
- `[Major]`[`9.4.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`9.4.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`9.4.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`9.4.5`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Pairs.Pair.Content.Response` / CheckResponseTag

- `[Major]`[`9.5.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`9.5.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`9.5.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`9.5.5`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Pairs.Pair.Content.ResponseOnBadCommand` / CheckResponseOnBadCommandTag

- `[Major]`[`9.6.2`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Warning]`[`9.6.3`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`9.6.4`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`9.6.5`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Pairs.Pair.Condition` / CheckConditionTag

- `[Major]`[`9.7.1`] **InvalidCondition**: Invalid condition '{0}'. Reason '{1}'. {2} {3} '{4}'.
- `[Major]`[`9.7.2`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Warning]`[`9.7.3`] **ConditionCanBeSimplified**: Condition '{0}' can be simplified. {1} {2} '{3}'.

## 10. Command

### `Protocol.Commands.Command` / CheckCommandLogic

- `[Major]`[`10.1.1`] **MissingCrcCommandAction**: No '{0}' Action triggered before Command '{1}'. '{0}' Param '{2}'.

### `Protocol.Commands.Command.Name` / CheckNameTag

- `[Minor]`[`10.2.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Commands.Command.Content.Param` / CheckParamTag

- `[Major]`[`10.3.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`10.3.2`] **EmptyParamTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`10.3.3`] **InvalidParamTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Commands.Command` / CheckAsciiAttribute

- `[Major]`[`10.4.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`10.4.2`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`10.4.3`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.

### `Protocol.Commands.Command` / CheckIdAttribute

- `[Critical]`[`10.5.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`10.5.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`10.5.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`10.5.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`10.5.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

## 11. Response

### `Protocol.Responses.Response` / CheckResponseLogic

- `[Major]`[`11.1.1`] **MissingCrcResponseAction**: No '{0}' Action triggered before Response '{1}'. '{0}' Param '{2}'.
- `[Major]`[`11.1.2`] **SmartSerialResponseShouldContainHeaderTrailer**: Defined headers and trailers linked to smart-serial connection '{0}' should be used in response '{1}'.

### `Protocol.Responses.Response.Name` / CheckNameTag

- `[Minor]`[`11.2.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.Responses.Response.Content.Param` / CheckParamTag

- `[Major]`[`11.3.1`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`11.3.2`] **EmptyParamTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`11.3.3`] **InvalidParamTag**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.

### `Protocol.Responses.Response` / CheckIdAttribute

- `[Critical]`[`11.4.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`11.4.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`11.4.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`11.4.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`11.4.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

## 12. Ports

### `Protocol.Ports.PortSettings` / CheckNameAttribute

- `[Minor]`[`12.1.2`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Minor]`[`12.1.3`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Minor]`[`12.1.4`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

## 13. Relation

### `Protocol.Relations.Relation` / CheckNameAttribute

- `[Minor]`[`13.1.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'.

### `Protocol.Relations.Relation` / CheckPathAttribute

- `[Major]`[`13.2.1`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`13.2.2`] **MissingAttribute**: Missing attribute '{0}'.
- `[Major]`[`13.2.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'.
- `[Major]`[`13.2.4`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Major]`[`13.2.5`] **MissingForeignKeyForRelation**: Missing foreignKey(s) detected for relation '{0}'.
- `[Major]`[`13.2.6`] **MissingForeignKeyInTable_Sub**: Missing foreignKey between table '{0}' and table '{1}'.
- `[Major]`[`13.2.7`] **ReferencedParamWrongType**: Invalid Param Type '{0}' in relation. Expected Type 'array'. Param ID '{1}'.
- `[Major]`[`13.2.8`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on Param referenced in a relation path. Param ID '{0}'.
- `[Major]`[`13.2.9`] **DuplicateValue**: Duplicated {0} {1} '{2}'.

## 14. Topology

### `Protocol.Topologies.Topology` / CheckNameAttribute

- `[Major]`[`14.1.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'.

## 15. Chain

### `Protocol.Chains` / CheckChildNameAttributes

- `[Major]`[`15.1.1`] **DuplicatedValue**: Duplicated {0} Name '{1}'.

## 16. ParameterGroup

### `Protocol.ParameterGroups.Group` / CheckDynamicIdAttribute

- `[Major]`[`16.1.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`16.1.2`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`16.1.3`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.

### `Protocol.ParameterGroups` / CheckParameterGroupsTag

- `[Major]`[`16.2.1`] **DcfAdded**: DCF was added.

### `Protocol.ParameterGroups.Group` / CheckNameAttribute

- `[Major]`[`16.3.3`] **DcfParameterGroupNameChanged**: DCF Group name for ParameterGroup '{0}' was changed from '{1}' into '{2}'.
- `[Critical]`[`16.3.4`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Critical]`[`16.3.5`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Critical]`[`16.3.6`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.
- `[Critical]`[`16.3.7`] **InvalidChars**: Invalid chars '{2}' in attribute '{0}'. Current value '{1}'.
- `[Minor]`[`16.3.8`] **LengthyValue**: Too long ParameterGroup Name. Current value '{0}'.
- `[Critical]`[`16.3.9`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

### `Protocol.ParameterGroups.Group` / CheckTypeAttribute

- `[Major]`[`16.4.1`] **DcfParameterGroupTypeChanged**: DCF Group type for ParameterGroup '{0}' was changed from '{1}' into '{2}'.

### `Protocol.ParameterGroups.Group` / CheckGroupTag

- `[Major]`[`16.5.1`] **DcfParameterGroupRemoved**: ParameterGroup '{0}' was removed.
- `[Major]`[`16.5.3`] **IncompatibleParamReferences**: Incompatible links to parameters via 'Group@dynamicId' attribute and 'Group/Params' element. ParameterGroup ID '{0}'.

### `Protocol.ParameterGroups.Group.Params.Param` / CheckIdAttribute

- `[Critical]`[`16.6.1`] **NonExistingId**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Critical]`[`16.6.2`] **DuplicateParamInParameterGroup**: Duplicate Param '{0}' in ParameterGroup '{1}'.

### `Protocol.ParameterGroups.Group` / CheckIdAttribute

- `[Major]`[`16.7.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Major]`[`16.7.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`16.7.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Major]`[`16.7.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`16.7.5`] **OutOfRangeId**: Out of range ParameterGroup ID '{0}'.
- `[Critical]`[`16.7.6`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.ParameterGroups.Group` / CheckDynamicIndexAttribute

- `[Major]`[`16.8.1`] **MissingDynamicIdAttribute**: Filtering via 'Group@dynamicIndex' attribute requires a 'Group@dynamicId' attribute. ParameterGroup ID '{0}'.

## 17. ExportRule

### `Protocol.ExportRules.ExportRule` / CheckTableAttribute

- `[Major]`[`17.1.1`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`17.1.2`] **MissingAttribute**: Missing attribute '{0}'.
- `[Major]`[`17.1.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'.
- `[Major]`[`17.1.4`] **EmptyAttribute**: Empty attribute '{0}'.

### `Protocol.ExportRules.ExportRule` / CheckWhereValueAttribute

- `[Major]`[`17.2.1`] **MissingAttribute**: Missing attribute '{0}'.

### `Protocol.ExportRules.ExportRule` / CheckWhereAttributeAttribute

- `[Major]`[`17.3.1`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`17.3.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'.

### `Protocol.ExportRules.ExportRule` / CheckWhereTagAttribute

- `[Major]`[`17.4.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Major]`[`17.4.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`17.4.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'.

## 18. TreeControl

### `Protocol.TreeControls.TreeControl` / CheckParameterIdAttribute

- `[Major]`[`18.1.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Major]`[`18.1.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Major]`[`18.1.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Major]`[`18.1.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'.
- `[Major]`[`18.1.5`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`18.1.6`] **ReferencedParamWrongType**: Invalid TreeControl Param Type '{0}'. Expected Type 'dummy'. Param ID '{1}'.
- `[Major]`[`18.1.7`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on TreeControl Param. Param ID '{0}'.

### `Protocol.TreeControls.TreeControl.Hierarchy` / CheckPathAttribute

- `[Major]`[`18.2.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.2.2`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.2.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.2.4`] **NonExistingIdsInAttribute**: Attribute '{0}' references non-existing IDs. {1} {3} '{2}'.
- `[Major]`[`18.2.5`] **NonExistingIdsInAttribute_Sub**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`18.2.6`] **DuplicateId**: Duplicate value '{0}' in attribute '{1}'. {2} {3} '{4}'.
- `[Major]`[`18.2.7`] **UntrimmedValueInAttribute_Sub**: Untrimmed value '{0}' in attribute '{1}'.
- `[Major]`[`18.2.8`] **InvalidValueInAttribute_Sub**: Invalid value '{1}' in attribute '{0}'.
- `[Major]`[`18.2.9`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on table displayed in TreeControl Hierarchy. Table PID '{0}'.

### `Protocol.TreeControls.TreeControl.Hierarchy.Table` / CheckIdAttribute

- `[Major]`[`18.3.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.3.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.3.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.3.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.3.5`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`18.3.6`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on table displayed in TreeControl Hierarchy. Table PID '{0}'.

### `Protocol.TreeControls.TreeControl.Hierarchy.Table` / CheckParentAttribute

- `[Major]`[`18.4.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.4.2`] **ExcessiveAttribute**: Unsupported attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.4.3`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.4.4`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.4.5`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.4.6`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.

### `Protocol.TreeControls.TreeControl.Hierarchy.Table` / CheckConditionAttribute

- `[Major]`[`18.5.1`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.5.2`] **UntrimmedColumnPid**: Untrimmed value '{0}' in attribute 'Table@condition' in TreeControl '{1}'.
- `[Major]`[`18.5.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.5.4`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`18.5.5`] **InvalidValueInAttribute_Sub**: Invalid option '{0}' in attribute '{1}'. {2} {3} '{4}'. Current Value '{5}'.
- `[Major]`[`18.5.6`] **MissingValueInAttribute_Sub**: Missing value '{0}' in attribute '{1}'. {2} {3} '{4}'.
- `[Major]`[`18.5.7`] **ReferencedColumnExpectingRTDisplay**: RTDisplay(true) expected on Param '{0}' referred as condition column in 'Hierarchy/Table@condition' attribute. TreeControl PID '{1}'.

### `Protocol.TreeControls.TreeControl.ExtraDetails.LinkedDetails` / CheckDetailsTableIdAttribute

- `[Major]`[`18.6.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.6.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.6.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.6.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.6.5`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`18.6.6`] **ReferencedTableExpectingRTDisplay**: RTDisplay(true) expected on TreeControl/ExtraDetails table. Table PID '{0}'.

### `Protocol.TreeControls.TreeControl.ExtraDetails.LinkedDetails` / CheckDiscreetColumnIdAttribute

- `[Major]`[`18.7.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.7.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.7.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.7.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.7.5`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`18.7.6`] **ReferencedColumnExpectingRTDisplay**: RTDisplay(true) expected on column referenced by TreeControl 'LinkedDetails@discreetColumnId' attribute. Column PID '{0}'.

### `Protocol.TreeControls.TreeControl.ExtraTab.Tab` / CheckParameterAttribute

- `[Major]`[`18.8.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.8.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.8.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.8.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.8.5`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.
- `[Major]`[`18.8.6`] **ReferencedParamExpectingRTDisplay**: RTDisplay(true) expected on 'TreeControl/ExtraTabs/Tab@parameters' Param. Param ID '{0}'.

### `Protocol.TreeControls.TreeControl.ExtraTab.Tab` / CheckTableIdAttribute

- `[Major]`[`18.9.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.9.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`18.9.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.9.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`18.9.5`] **NonExistingId**: Attribute '{0}@{1}' references a non-existing '{2}' with {3} '{4}'.

### `Protocol.TreeControls.TreeControl.HiddenColumns` / CheckHiddenColumnsTag

- `[Major]`[`18.10.1`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`18.10.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.10.3`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`18.10.4`] **NonExistingIds**: Tag '{0}' references non-existing IDs. {1} {3} '{2}'.
- `[Major]`[`18.10.5`] **NonExistingIds_Sub**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`18.10.6`] **DuplicateId**: Duplicate value '{0}' in tag '{1}'. {2} {3} '{4}'.
- `[Major]`[`18.10.7`] **InvalidValueInTag_Sub**: Invalid value '{1}' in tag '{0}'.
- `[Major]`[`18.10.8`] **UntrimmedInTag_Sub**: Untrimmed value '{0}' in tag '{1}'.
- `[Major]`[`18.10.9`] **IrrelevantColumn**: Irrelevant column with PID '{0}' in 'TreeControl/HiddenColumns'. TreeControl ID '{1}'.

### `Protocol.TreeControls.TreeControl.OverrideDisplayColumns` / CheckOverrideDisplayColumnsTag

- `[Major]`[`18.11.1`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`18.11.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.11.3`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`18.11.4`] **NonExistingIds**: Tag '{0}' references non-existing IDs. {1} {3} '{2}'.
- `[Major]`[`18.11.5`] **NonExistingIds_Sub**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`18.11.6`] **DuplicateId**: Duplicate value '{0}' in tag '{1}'. {2} {3} '{4}'.
- `[Major]`[`18.11.7`] **DuplicateOverrideDisplayColumn**: Duplicate OverrideDisplayColumns IDs for Table '{0}'. TreeControl ID '{1}'.
- `[Major]`[`18.11.8`] **UntrimmedValueInTag_Sub**: Untrimmed value '{0}' in tag '{1}'.
- `[Major]`[`18.11.9`] **InvalidValueInTag_Sub**: Invalid value '{1}' in tag '{0}'.
- `[Major]`[`18.11.10`] **DuplicateOverrideDisplayColumns_Sub**: Duplicate OverrideDisplayColumns ID '{0}'.
- `[Major]`[`18.11.11`] **IrrelevantColumn**: Irrelevant column with PID '{0}' in 'TreeControl/OverrideDisplayColumns'. TreeControl ID '{1}'.

### `Protocol.TreeControls.TreeControl.OverrideIconColumns` / CheckOverrideIconColumnsTag

- `[Major]`[`18.12.1`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`18.12.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.12.3`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`18.12.4`] **NonExistingIds**: Tag '{0}' references non-existing IDs. {1} {3} '{2}'.
- `[Major]`[`18.12.5`] **NonExistingIds_Sub**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`18.12.6`] **DuplicateId**: Duplicate value '{0}' in tag '{1}'. {2} {3} '{4}'.
- `[Major]`[`18.12.7`] **DuplicateOverrideIconColumns**: Duplicate OverrideIconColumns IDs for Table '{0}'. TreeControl ID '{1}'.
- `[Major]`[`18.12.8`] **UntrimmedValueInTag_Sub**: Untrimmed value '{0}' in tag '{1}'.
- `[Major]`[`18.12.9`] **InvalidValueInTag_Sub**: Invalid value '{1}' in tag '{0}'.
- `[Major]`[`18.12.10`] **DuplicateOverrideIconColumns_Sub**: Duplicate OverrideIconColumns ID '{0}'.
- `[Major]`[`18.12.11`] **IrrelevantColumn**: Irrelevant column with PID '{0}' in 'TreeControl/OverrideIconColumns'. TreeControl ID '{1}'.

### `Protocol.TreeControls.TreeControl.ReadonlyColumns` / CheckReadonlyColumnsTag

- `[Major]`[`18.13.1`] **EmptyTag**: Empty tag '{0}' in {1} '{2}'.
- `[Major]`[`18.13.2`] **UntrimmedTag**: Untrimmed tag '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Major]`[`18.13.3`] **InvalidValue**: Invalid value '{0}' in tag '{1}'. {2} {4} '{3}'.
- `[Major]`[`18.13.4`] **NonExistingIds**: Tag '{0}' references non-existing IDs. {1} {3} '{2}'.
- `[Major]`[`18.13.5`] **NonExistingIds_Sub**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`18.13.6`] **DuplicateId**: Duplicate value '{0}' in tag '{1}'. {2} {3} '{4}'.
- `[Major]`[`18.13.7`] **UntrimmedValueInTag_Sub**: Untrimmed value '{0}' in tag '{1}'.
- `[Major]`[`18.13.8`] **InvalidValueInTag_Sub**: Invalid value '{1}' in tag '{0}'.
- `[Major]`[`18.13.9`] **IrrelevantColumn**: Irrelevant column with PID '{0}' in 'TreeControl/ReadonlyColumns'. TreeControl ID '{1}'.

## 19. PortSettings

### `Protocol.PortSettings` / CheckNameAttribute

- `[Minor]`[`19.1.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Minor]`[`19.1.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'. *(autofix)*
- `[Minor]`[`19.1.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*

