# Parameters Logic

Authority scope: this file explains DataMiner parameter runtime behavior. It is not the XML schema reference. For valid parameter XML structure, attributes, enum values, and ID type patterns, use `dataminer-protocol-xml-reference`.

## Parameter Roles

| Role | Runtime purpose |
|---|---|
| `read` | Holds values read from a device, calculated internally, or displayed to users. |
| `write` | Receives user/device control input. Often paired with a read parameter. |
| `fixed` | Holds a protocol constant. |
| `dummy` | Internal placeholder for triggers or logic that does not represent useful data. |
| `array` | Defines a table; columns are separate parameters. |
| `bus`, `ip`, `pollingip`, `elementid`, `elementdmaid`, `elementname`, `dataminer info` | Element or connection information supplied by DataMiner. |
| `header`, `trailer`, `length`, `crc`, `response`, `read bit`, `write bit`, `group` | Serial/smart-serial framing and parsing support. |

Element information parameters cannot be displayed directly. Copy their value to a read parameter or use a display-specific mechanism when the value must be visible.

## Change Events

When a parameter value changes, DataMiner processes linked logic in this order:

1. Triggers on parameter change.
2. SSH or dynamic IP updates when relevant options are set.
3. Save to database when persistence is enabled.
4. Setter copy from write parameter to read parameter when `setter` is used.
5. SNMP set or set/get behavior when configured.
6. QActions triggered by the parameter.
7. Data distribution when configured.
8. Dynamic SNMP get when configured.

Change events occur when:

- The parameter value actually changes.
- A write parameter is set, even to the same value.
- An action of type `run actions` runs on the parameter.
- A QAction calls `SetParameter`, even with the same value.

Change events do not occur for:

- `SetParameterBinary`.
- `NT_SET_BINARY_DATA`.

Same-value behavior depends on the source:

| Source | Same value triggers change logic? |
|---|---|
| QAction `SetParameter` | Yes. |
| Copy action | No. |
| SNMP polling | No. |
| Serial response | No. |
| HTTP response | No. |

Use a `clear` action before setting a value when repeated identical incoming values must be processed as changes.

## Internal Storage And Empty Values

- Uninitialized standalone numeric parameters return `0` through normal reads.
- Use the protocol API empty check to distinguish an actual zero from a never-set standalone value.
- Uninitialized table cells return `null`.
- `empty` and `emptystring` behave differently in conditions; test condition behavior for parameters that can be not initialized.

## Read/Write Pairs

Use separate read and write parameters for user-editable values.

- The read parameter displays or stores the current value.
- The write parameter receives user input.
- With setter behavior, writing to the write parameter automatically copies to the read parameter.
- Read/write pairs represent the same logical value and can share a name/description pattern.
- Verify device-side sets by re-reading or refreshing the value after the write, because local write handling can update DataMiner optimistically.

Buttons are an exception: a button write parameter normally invokes logic and should not be modeled as a read/write value pair unless it represents a real value.

## Parameter ID Allocation

Use a consistent parameter ID allocation model so the protocol remains readable and read/write pairs can stay adjacent in the XML.

Default connector allocation model:

| Range | Use |
|---|---|
| `1-99` | General, internal, startup, metadata-style, or low-level helper parameters. |
| `100-999` | Standalone read parameters, regardless of UI page. |
| `1000+` | Table array parameters and table column parameters. |

Rules:

- Keep standalone non-table read parameters in `100-999`.
- Do not put standalone response-body, status, or helper read parameters in the `1000+` table range.
- Use `1000+` for table array and column parameters.
- Keep related parameter IDs close together; avoid large gaps inside a feature group.
- Read/write parameter pairs should use a fixed offset from read to write.
- Prefer read `+50` for write parameters; `+100` is acceptable.
- Do not exceed a `+100` write offset.
- Do not put write parameters in a separate high-numbered range, because ascending physical order would separate them from their read parameters.
- The write parameter must be physically adjacent to its read parameter in XML, even though the logical numeric allocation uses an offset.

Schema-allowed ID ranges and reserved ranges are not the same thing. Use the XML schema reference for XSD-valid ID type ranges, and use validator/reserved-ID guidance before assigning IDs in reserved DataMiner ranges.

## Saved Parameters

Saved parameters persist across element restarts.

Use saved parameters for:

- User configuration.
- State required to continue after restart.
- DCF interface display key source columns when those keys must persist.

Avoid saving fast-changing or derived helper values unless a runtime feature requires persistence.

Automatically polled SNMP table columns are refreshed by polling and should not use column-level `;save` by default. This does not change the valid use of persistence for standalone configuration/state parameters, DCF display-key sources, or explicitly justified non-SNMP table columns.

## History Sets

History-set parameters receive historical values from QActions.

- Historical values must be set in chronological order.
- After timestamp `x` is set, older timestamps can no longer be set correctly.
- Sort recovered historical data before setting it.
- Native timeout recovery interacts badly with history sets because timeout/clear behavior acts as database sets and can close trend windows.
- If historical recovery across gaps is required, model timeout with a separate monitored read parameter and disable native include-timeout behavior for the historical parameter.
- A history-set parameter does not store its last set value in the trending database when the element restarts.

## Dynamic Units

Dynamic units allow DataMiner to adjust numeric display units for readability. Use them only when the parameter's measurement semantics support automatic unit scaling.

## Display And RTDisplay Behavior

- UI-visible parameters must be loaded into `SLElement` with real-time display behavior.
- Internal helper parameters should avoid `RTDisplay=true` unless alarms, trends, table display, external consumers, DVE, DCF, tree controls, context menus, API behavior, or another runtime feature needs the value.
- Parameters with `RTDisplay=true` have performance impact because `SLElement` tracks them.

## Alarming And Trending Behavior

- Parameters are not alarmed by default.
- Do not alarm write parameters.
- Alarmable parameters should normally be visible to users.
- Trending is supported by default for parameters loaded into `SLElement`.
- Disable trending only when that behavior is intentional and understood.
- Table column trend retrieval uses the primary key unless a display-column model changes the trend identity.
- Values used to compose table display keys should be filled before alarmed or trended values so alarms and trends receive the correct display identity.

## Tables At Runtime

- A table is represented by one array parameter and separate column parameters.
- Primary keys identify rows and should be stable, small, unique, and free of leading/trailing whitespace.
- Display keys are needed when primary keys are not user-friendly.
- Display keys must be unique per row and are tracked by `SLElement`.
- A `displaykey` column is automatically filled by `SLElement`; do not set it manually.
- Display-key columns do not support alarming or trending.
- Foreign-key values link rows across tables for relations, topology, tree controls, and DVE export patterns.
- Do not put multiple foreign links on one column; use one link column per relationship.
- Avoid foreign keys on logger-table columns unless the logger-table design specifically requires it.
- Internal tables that are never displayed or externally consumed should avoid being loaded into `SLElement`.

## SNMP Table Runtime Behavior

- SNMP tables use one array parameter plus column parameters.
- Configure one table retrieval method per table.
- For GetNext-style retrieval, the OID belongs on the table parameter rather than on columns.
- Prefer row-safe retrieval methods for shifting-index tables.
- Keep bulk retrieval response size below path MTU risk.
- Multi-part row instances require the documented instance pattern.

## Trap Parameters

- Trap receiver parameters use trap OID behavior.
- Trap reception only supports polling IP address, not hostname.
- Trap receiver `on change` triggers do not fire.
- Map trap bindings to parameters or process all-binding data through documented trap patterns.
- Trap receivers that generate alarms must be loaded into `SLElement`.
