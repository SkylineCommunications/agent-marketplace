# SNMP Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for top-level `/Protocol/SNMP`, `Param/SNMP`, `OID`, `TrapOID`, `TrapMappings`, `InvalidResponseHandling`, and SNMP enum placement listed here. Unlisted SNMP descendants/attributes MUST NOT be authored.

## Top-Level SNMP

`/Protocol/SNMP`:

- Optional root child.
- Fixed text content: `auto`.
- Required attribute when present: `includepages`, fixed value `true`.

## Param/SNMP

`/Protocol/Params/Param/SNMP`:

- Optional attribute: `@options` (`xs:string`).
- Content model `xs:all`.
- Allowed direct children: `Enabled`, `Factor`, `InvalidResponseHandling`, `OID`, `TrapMappings`, `TrapOID`, `Type`.

### SNMP@options

Specifies a dynamic get/set community string or a context name/ID for a particular connection.

Valid values (string format):

- `GetCommunity:N` — Parameter holds the get community string for connection N (0-based).
- `SetCommunity:N` — Parameter holds the set community string for connection N (0-based).
- `ContextName:N` — Parameter holds the context name for connection N (SNMPv3; since 10.5.6/10.6.0).
- `ContextID:N` — Parameter holds the context ID for connection N (SNMPv3; since 10.5.6/10.6.0).

Behavior notes:

- If the parameter is not initialized or empty, the default value (from the Element Wizard or empty string for context) is used.
- Community strings are changed at runtime only; values are flushed on element restart.
- For context name/ID persistence across restarts, set `save="true"` on the parameter (e.g. `<Param id="1" save="true">`).

### Enabled

`Param/SNMP/Enabled`:

- Type: `EnumTrueFalse` (values `true`, `false`).
- If `true`, DataMiner is allowed to interrogate the SNMP agent.

### Factor

`Param/SNMP/Factor`:

- Type: `unsignedInt`.
- Default factor: `1`.
- All values will be divided by the specified factor (e.g. factor `10` → value "1" becomes "0.1").
- SNMP does not natively support decimal values; this element produces decimals in DataMiner.

## OID

`Param/SNMP/OID`:

- Text content: `xs:string`.
- Optional attributes: `id`, `ipid`, `options`, `skipDynamicSNMPGet`, `type`.

### OID Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | TypeParamId | ID of parameter holding the (partial) OID |
| `ipid` | TypeParamId | ID of parameter holding the IP address for polling this SNMP parameter |
| `options` | string | Semicolon-separated options (see below) |
| `skipDynamicSNMPGet` | EnumTrueFalse | Skip evaluation if parameter must be retrieved via dynamic SNMP Get |
| `type` | EnumOIDType | How the OID is constructed |

### OID@type (EnumOIDType)

Values: `auto`, `complete`, `composed`, `wildcard`.

| Value | Resulting OID |
|-------|---------------|
| `auto` | VendorOID + DeviceOID + ParamID |
| `complete` | The SNMP/OID value itself (full OID) |
| `composed` | VendorOID + DeviceOID + SNMP/OID value |
| `wildcard` | Content of referenced parameter (via `id` attr) prepended to SNMP/OID value |

Fallback logic when no `type` attribute is specified:

- OID element is empty → acts as `auto`.
- OID value is not empty and ≤10 characters → acts as `composed`.
- OID value is not empty and >10 characters → acts as `complete`.

The `complete` type supports wildcards (`*`). Use the `id` attribute to reference a parameter whose value replaces the wildcard.

`id` is not an `OID@type` value; it is an attribute.

### OID@options

`OID@options` is `xs:string`; token values are semicolon-separated. Known runtime tokens (not schema-enumerated):

| Token | Description |
|-------|-------------|
| `bulk:N` | Number of cells retrieved per SNMP get (default 50) |
| `column` | Required when retrieving one column with `instance` + `type="complete"` |
| `instance` | Retrieve extra column containing the instance |
| `multipleGetNext` | Use multipleGetNext table retrieval method (**default for tables**) |
| `multipleGetBulk` | Use multipleGetBulk table retrieval method |
| `partialSNMP:N` | Fetch only N rows at a time (must be combined with `instance`) |
| `subtable` | Use instance filter for reduced SNMP table (requires `id` attribute) |

Default table retrieval: use `instance;multipleGetNext` on the table (array) parameter's `<OID>`. This is the standard approach for SNMP table polling.

Notes on `partialSNMP` + `multipleGetBulk` interaction:

- `partialSNMP` determines total rows per cycle; `multipleGetBulk` determines max rows per GetBulk request.
- If `multipleGetBulk` > `partialSNMP`, the `partialSNMP` value is used for both.
- From 10.4.0 CU17/10.5.0 CU5/10.5.8: both options are honored independently. Prior versions: `partialSNMP` takes precedence.
- `partialSNMP` cannot be combined with `getNext`, subtables, or filtered rows.

## TrapOID And TrapMappings

`Param/SNMP/TrapOID`:

- Text content: `xs:string` (contains an OID, possibly with wildcard `*`).
- Optional attributes: `checkBindings`, `ipid`, `mapAlarm`, `setBindings`, `type`.

### TrapOID Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `checkBindings` | string | Basic filtering on trap bindings |
| `ipid` | string | ID of parameter holding IP addresses |
| `mapAlarm` | string | Generate alarm when trap is received |
| `setBindings` | string | Set binding value as value of another parameter |
| `type` | EnumTrapOIDType | How the trap OID is constructed |

### TrapOID@type (EnumTrapOIDType)

Values: `auto`, `complete`, `composed`, `wildcard`.

| Value | Resulting OID |
|-------|---------------|
| `auto` | VendorOID + DeviceOID + ParamID |
| `complete` | The complete trap OID is specified in TrapOID |
| `composed` | VendorOID + DeviceOID + TrapOID value |
| `wildcard` | Use `*` in OID to capture all matching traps |

`Param/SNMP/TrapMappings`:

- Contains `TrapMapping` zero or more times.
- `TrapMapping` optional attributes: `bindingMatch`, `severity`, `value`.
- Use `TrapMappings` when the `mapAlarm` attribute of `TrapOID` is too limited for advanced alarm mappings.
- It is possible to combine `TrapMappings` with the `mapAlarm` attribute of `TrapOID`.

## InvalidResponseHandling

`Param/SNMP/InvalidResponseHandling`:

- Required child when present: `InfiniteLoop`.

### InfiniteLoop

`Param/SNMP/InvalidResponseHandling/InfiniteLoop`:

- Type: string restriction (enumeration).
- Allowed values: `success`, `timeout`.
- `success` — The SNMP response is accepted, and the table is updated.
- `timeout` — The SNMP response is rejected, the table is not updated, and the timeout timer of the interface is triggered.
- Default behavior (without this element): `timeout`.
- Only applicable to table parameters.
- When an infinite loop is detected, a message is always logged in the element's log file (ERROR, level 0) regardless of this setting.

## SNMP Type Placement

`Param/SNMP/Type` values are listed in `protocol-types-and-enums.md`.

The SNMP data type belongs in `SNMP/Type`, not in `Interprete/RawType` and not in `OID@type`.

Always specify an SNMP type on write parameters. Without the SNMP type, fallback behavior applies:

- Numbers are set with SNMP type Integer32.
- Text is set with SNMP type OctetString.
- A parameter with `Interprete/RawType` defined as numeric text is considered text and will be set as OctetString.
