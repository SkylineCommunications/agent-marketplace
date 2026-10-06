---
name: dataminer-qaction-rules
description: Enforce DataMiner QAction C# validation rules from the CICD Validator (44 checks, 118 error messages). Load when reviewing or writing DataMiner QAction C# code or QAction XML attributes.
---

# DataMiner QAction (C#) Validator Rules

Rules from `Protocol/ErrorMessages.xml` Category 3. Each rule: `[Severity][3.CheckId.ErrorId]`.

Severity: `[Critical]` must fix | `[Major]` functional issue | `[Minor]` best-practice | `[Warning]` advisory

Flag every violation with its rule ID and severity when reviewing or generating QAction C# code or `<QAction>` XML elements.

### `Protocol.QActions.QAction` / CheckNameAttribute

- `[Warning]`[`3.1.1`] **DuplicatedValue**: Duplicated {0} {1} '{2}'. {0} IDs '{3}'.

### `Protocol.QActions.QAction` / CheckTriggersAttribute

- `[Major]`[`3.2.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`3.2.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`3.2.3`] **InvalidAttribute**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Major]`[`3.2.4`] **NonExistingParam**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`3.2.5`] **NonExistingGroup**: Attribute '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Major]`[`3.2.6`] **DuplicateId**: Duplicate value '{0}' in attribute '{1}'. {2} {3} '{4}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolCheckTrigger

- `[Major]`[`3.3.1`] **NonExistingTrigger**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.

### `Protocol.QActions.QAction` / CSharpQActionCompilation

- `[Critical]`[`3.4.1`] **CompilationFailure**: C# compilation errors. QAction ID '{0}'.
- `[Critical]`[`3.4.2`] **CompilationFailure_Sub**: {0}
- `[Warning]`[`3.4.3`] **NoCSharpCodeAnalysisPerformed**: No C# QAction code analysis was performed due to unsupported C# version '{0}' in Visual Studio version '{1}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolTriggerAction

- `[Major]`[`3.5.1`] **NonExistingActionId**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolGetParameter

- `[Major]`[`3.6.1`] **NonExistingParam**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Warning]`[`3.6.2`] **HardCodedPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolSetParameter

- `[Major]`[`3.7.1`] **NonExistingParam**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Warning]`[`3.7.2`] **HardCodedPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Major]`[`3.7.3`] **ParamMissingHistorySet**: {0} overload with '{1}' argument requires '{2}'. {3} {4} '{5}'. *(autofix)*

### `Protocol.QActions.QAction` / CSharpSLProtocolSetRow

- `[Major]`[`3.8.1`] **NonExistingParam**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Warning]`[`3.8.2`] **HardCodedPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Major]`[`3.8.3`] **ParamMissingHistorySet**: {0} overload with '{1}' argument requires '{2}'. {3} {4} '{5}'. *(autofix)*

### `Protocol.QActions.QAction` / CSharpSLProtocolFillArray

- `[Major]`[`3.9.1`] **NonExistingParam**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Major]`[`3.9.2`] **ParamMissingHistorySet**: {0} overload with '{1}' argument requires '{2}'. {3} {4} '{5}'. *(autofix)*
- `[Warning]`[`3.9.3`] **HardCodedPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolFillArrayNoDelete

- `[Major]`[`3.10.1`] **NonExistingParam**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Major]`[`3.10.2`] **ParamMissingHistorySet**: {0} overload with '{1}' argument requires '{2}'. {3} {4} '{5}'. *(autofix)*
- `[Warning]`[`3.10.3`] **HardCodedPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolFillArrayWithColumn

- `[Major]`[`3.11.1`] **NonExistingTable**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Major]`[`3.11.2`] **NonExistingColumn**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Major]`[`3.11.3`] **ParamMissingHistorySet**: {0} overload with '{1}' argument requires '{2}'. {3} {4} '{5}'. *(autofix)*
- `[Warning]`[`3.11.4`] **HardCodedTablePid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Warning]`[`3.11.5`] **HardCodedColumnPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Major]`[`3.11.6`] **ColumnManagedByDataMiner**: Unsupported {0} on {1} '{2}' with '{3}' containing '{4}'.
- `[Major]`[`3.11.7`] **ColumnManagedByProtocolItem**: Unsupported {0} on {1} '{2}' managed by {3} '{4}' with '{5}' containing '{6}'.
- `[Minor]`[`3.11.8`] **UnrecommendedSetOnSnmpParam**: Unrecommended {0} on {1} '{2}' with '{3}' containing '{4}'.

### `Protocol.QActions.QAction` / CSharpCheckEntryPoints

- `[Major]`[`3.12.1`] **MissingEntryPoint**: Entry point '{0}.{1}' not found in QAction. QAction ID {2}.
- `[Major]`[`3.12.2`] **UnexpectedAccessModifierForEntryPointMethod**: Entry point method '{0}.{1}' has unexpected access modifier '{2}'. QAction ID {3}.
- `[Major]`[`3.12.3`] **UnexpectedAccessModifierForEntryPointClass**: Entry point class '{0}' has unexpected access modifier '{1}'. QAction ID {2}.
- `[Major]`[`3.12.4`] **UnexpectedArg0TypeForEntryPointMethod**: Entry point method '{0}.{1}' has a first argument with unexpected type '{2}'. QAction ID {3}.

### `Protocol.QActions.QAction` / CSharpCheckPreprocessorDirective

- `[Minor]`[`3.13.1`] **ObsoleteDcfV1**: Obsolete preprocessor directive '{0}' used in QAction. QAction ID '{1}'.

### `Protocol.QActions.QAction` / CSharpCheckUnrecommendedMethod

- `[Minor]`[`3.15.1`] **UnrecommendedThreadAbort**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.2`] **UnrecommendedSlProtocolGetParameterIndex**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.3`] **UnrecommendedSlProtocolSetParameterIndex**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.4`] **UnrecommendedSlProtocolSetParametersIndex**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.5`] **UnrecommendedNotifyDataMinerNTGetRemoteTrend**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.6`] **UnrecommendedNotifyDataMinerNTGetRemoteTrendAvg**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.7`] **UnrecommendedNotifyProtocolNTDeleteRow**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.8`] **UnrecommendedNotifyProtocolNTAddRow**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.9`] **UnrecommendedNotifyProtocolNT_CHECK_TRIGGER**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.10`] **UnrecommendedNotifyProtocolNT_GET_DATA**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.11`] **UnrecommendedNotifyProtocolNT_GET_KEY_POSITION**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.12`] **UnrecommendedNotifyProtocolNT_GET_PARAMETER**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.13`] **UnrecommendedNotifyProtocolNT_GET_PARAMETER_BY_DATA**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.14`] **UnrecommendedNotifyProtocolNT_GET_PARAMETER_BY_NAME**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.15`] **UnrecommendedNotifyProtocolNT_GET_DESCRIPTION**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.16`] **UnrecommendedNotifyProtocolNT_GET_PARAMETER_INDEX**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.17`] **UnrecommendedNotifyProtocolNT_GET_ITEM_DATA**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.18`] **UnrecommendedNotifyProtocolNT_GET_ROW**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.19`] **UnrecommendedNotifyProtocolNT_ARRAY_ROW_COUNT**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.20`] **UnrecommendedNotifyProtocolNT_NOTIFY_DISPLAY**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.21`] **UnrecommendedNotifyProtocolNT_SET_PARAMETER_WITH_HISTORY**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.22`] **UnrecommendedNotifyProtocolNT_SET_PARAMETER_BY_DATA**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.23`] **UnrecommendedNotifyProtocolNT_SET_PARAMETER_BY_NAME**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.24`] **UnrecommendedNotifyProtocolNT_SET_DESCRIPTION**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.25`] **UnrecommendedNotifyProtocolNT_SET_ITEM_DATA**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Minor]`[`3.15.26`] **UnrecommendedNotifyProtocolNT_SET_ROW**: Method '{0}.{1}' is unrecommended. QAction ID '{2}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTSetElementState

- `[Major]`[`3.16.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTSetAlarmState

- `[Major]`[`3.17.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTGetParameter

- `[Major]`[`3.18.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTAssignAlarmTemplate

- `[Major]`[`3.19.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTUpdatePortsXml

- `[Major]`[`3.20.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTEditProperty

- `[Major]`[`3.21.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTTrendingAssignTemplate

- `[Major]`[`3.22.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTUpdateDescriptionXml

- `[Major]`[`3.23.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTAssignSimulation

- `[Major]`[`3.24.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTGetValue

- `[Major]`[`3.25.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTGetAlarmInfo

- `[Major]`[`3.26.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTGetElementName

- `[Major]`[`3.27.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyDataMinerNTServiceSetVdx

- `[Major]`[`3.28.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyProtocolNTSnmpSet

- `[Major]`[`3.29.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyProtocolNTSnmpGet

- `[Major]`[`3.30.1`] **DeltIncompatible**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CheckIdAttribute

- `[Critical]`[`3.31.1`] **MissingAttribute**: Missing attribute '{0}'.
- `[Critical]`[`3.31.2`] **EmptyAttribute**: Empty attribute '{0}'.
- `[Warning]`[`3.31.3`] **UntrimmedAttribute**: Untrimmed attribute '{0}'. Current value '{1}'. *(autofix)*
- `[Critical]`[`3.31.4`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Critical]`[`3.31.5`] **DuplicatedId**: More than one {0} with same ID '{1}'. {0} Names '{2}'.

### `Protocol.QActions.QAction` / CSharpSLProtocolGetParameters

- `[BubbleUp]`[`3.33.1`] **UnexpectedImplementation**: Method '{0}' with arguments '{1}' is not implemented as expected. QAction ID '{2}'.
- `[Major]`[`3.33.2`] **NonExistingParam**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Warning]`[`3.33.3`] **HardCodedPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Major]`[`3.33.4`] **UnsupportedArgumentTypeForIds**: Invocation of method '{0}' has an invalid type '{1}' for the argument '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CSharpNotifyProtocolNtFillArrayWithColumn

- `[BubbleUp]`[`3.34.1`] **UnexpectedImplementation**: Method '{0}' with arguments '{1}' is not implemented as expected. QAction ID '{2}'.
- `[Major]`[`3.34.2`] **NonExistingTable**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Major]`[`3.34.3`] **NonExistingColumn**: Method '{0}' references a non-existing '{1}' with {2} '{3}'. QAction ID '{4}'.
- `[Major]`[`3.34.4`] **ColumnMissingHistorySet**: NotifyProtocol(220/*NT_FILL_ARRAY_WITH_COLUMN*/, ...) method with one or more DateTime(s) given to it requires 'Param@historySet=true' on column with PID '{0}'. *(autofix)*
- `[Warning]`[`3.34.5`] **HardCodedTablePid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Warning]`[`3.34.6`] **HardCodedColumnPid**: Unrecommended use of magic number '{0}', use '{1}' {2} instead. QAction ID '{3}'.
- `[Major]`[`3.34.7`] **ColumnManagedByDataMiner**: Unsupported {0} on {1} '{2}' with '{3}' containing '{4}'.
- `[Major]`[`3.34.8`] **ColumnManagedByProtocolItem**: Unsupported {0} on {1} '{2}' managed by {3} '{4}' with '{5}' containing '{6}'.
- `[Minor]`[`3.34.9`] **UnrecommendedSetOnSnmpParam**: Unrecommended {0} on {1} '{2}' with '{3}' containing '{4}'.

### `Protocol.QActions.QAction.Condition` / CheckConditionTag

- `[Major]`[`3.35.1`] **InvalidCondition**: Invalid condition '{0}'. Reason '{1}'. {2} {3} '{4}'.
- `[Major]`[`3.35.2`] **NonExistingId**: Tag '{0}' references a non-existing '{1}' with {2} '{3}'. {4} {5} '{6}'.
- `[Warning]`[`3.35.3`] **ConditionCanBeSimplified**: Condition '{0}' can be simplified. {1} {2} '{3}'.

### `Protocol.QActions.QAction` / CSharpCheckUnrecommendedConstructor

- `[Critical]`[`3.36.1`] **UnrecommendedXmlSerializerConstructor**: Constructor '{0}' ('{1}') is unrecommended. QAction ID '{2}'.

### `Protocol.QActions.QAction` / CSharpCheckUnrecommendedPropertySet

- `[Major]`[`3.37.1`] **UnrecommendedCultureInfoDefaultThreadCurrentCulture**: Setting property '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Major]`[`3.37.2`] **UnrecommendedThreadCurrentThreadCurrentCulture**: Setting property '{0}.{1}' is unrecommended. QAction ID '{2}'.
- `[Major]`[`3.37.3`] **UnrecommendedThreadCurrentThreadCurrentUICulture**: Setting property '{0}.{1}' is unrecommended. QAction ID '{2}'.

### `Protocol.QActions` / CheckAssemblies

- `[Major]`[`3.38.1`] **UnconsolidatedPackageReference**: Package '{0}' has multiple versions across different QActions.
- `[Major]`[`3.38.2`] **UnconsolidatedPackageReference_Sub**: QAction '{0}' has package '{1}' with version '{2}'.
- `[Critical]`[`3.38.3`] **MissingSecureCoding**: Missing Skyline.DataMiner.Utils.SecureCoding.Analyzers NuGet package. QAction ID '{0}'.

### `Protocol.QActions.QAction` / CSharpCoreInterAppBrokerSupport

- `[Critical]`[`3.39.1`] **InvalidInterAppReplyLogic**: Invocation of method '{0}.{1}' is not compatible with '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CheckFileEncoding

- `[Minor]`[`3.40.1`] **InvalidFileEncoding**: Invalid file encoding '{0}' detected in file '{1}'. QAction ID '{2}'. *(autofix)*

### `Protocol.QActions.QAction` / CSharpCheckUnrecommendedFinalizer

- `[Critical]`[`3.41.1`] **UnrecommendedFinalizer**: Finalizer '{0}' is unrecommended. QAction ID '{1}'.

### `Protocol.QActions.QAction` / CheckDataMinerDependency

- `[Major]`[`3.42.1`] **MismatchDevPack**: Package '{0}' version '{1}' has a higher version than the version specified in the MinimumRequiredVersion tag '{2}'. QAction ID '{3}'.

### `Protocol.QActions.QAction` / CheckDeprecatedDllReferences

- `[Critical]`[`3.44.1`] **DeprecatedDll**: Deprecated DLL '{0}' referenced. QAction '{1}'.

### `Protocol.QActions.QAction` / CheckEncodingAttribute

- `[Major]`[`3.45.1`] **MissingAttribute**: Missing attribute '{0}' in {1} '{2}'.
- `[Major]`[`3.45.2`] **EmptyAttribute**: Empty attribute '{0}' in {1} '{2}'.
- `[Major]`[`3.45.3`] **InvalidValue**: Invalid value '{1}' in attribute '{0}'. {2} {4} '{3}'.
- `[Warning]`[`3.45.4`] **UntrimmedAttribute**: Untrimmed attribute '{0}' in {1} '{2}'. Current value '{3}'. *(autofix)*
- `[Critical]`[`3.45.5`] **UnsupportedValue**: Unsupported value '{0}' in encoding attribute. QAction ID '{1}'.

