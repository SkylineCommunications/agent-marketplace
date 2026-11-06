# DMSScript 1.1.10 Closed-World Reference

This is the authoritative structural contract for DataMiner Automation `DMSScript` XML in this repository. It is a closed-world transcription of the pinned XSD: if an element, attribute, value enum, or structure is not admitted below, do not author it.

> **Parent skill:** `dataminer-automation-xml/SKILL.md`.
> **Structural authority:** [automation-1.1.10.xsd](automation-1.1.10.xsd) beside this reference. The XSD wins if any prose or example conflicts with it.
> **Runtime boundary:** `dataminer-automation-core/references/invocation-and-entry-points.md` and `security-permissions-credentials.md` own invocation, identity, output, lock, and secret-flow behavior; this file owns XML structure only.

## Provenance and currentness

| Item | Value |
|---|---|
| NuGet package | `Skyline.DataMiner.XmlSchemas.Automation` 1.1.10 |
| Package SHA-256 | `c164064bdfe6a99c8f13fd9563106d30715c6496da9b137ac0176aeef387826f` |
| XSD package path | `content/Skyline/XSD/automation.xsd` |
| Vendored XSD | `references/automation-1.1.10.xsd` in the Automation XML skill |
| XSD SHA-256 | `b7c17c970dd5847ed9f4bd33e08c0e7c8acf546094a38a14a35fabaea2d461ea` |
| Source commit | `d7b5c9ac6865f3e56804bf95e536d460b5e50e36` |
| Closed-world transcription reviewed | 2026-09-14 |

This contract is current for the pin above, not for an unpinned future package. A package update requires a new schema comparison, provenance update, and coordinated contract/validation review.

## Schema-wide rules and simple types

- The one global document element is `DMSScript` in the exact namespace `http://www.skyline.be/automation`.
- The schema has `elementFormDefault="qualified"`. Every element described here is in that namespace. Attributes are unqualified because the schema does not set `attributeFormDefault="qualified"`.
- No `xs:any` or `xs:anyAttribute` extension point exists. Unknown children and attributes are invalid.
- Unless stated otherwise, an element declaration with omitted occurrence bounds is exactly once (`minOccurs="1"`, `maxOccurs="1"`).
- `xs:string` permits the empty string.
- `NonEmptyStringType` is `xs:string` with `minLength="1"`. It does not trim or collapse whitespace.
- `xs:positiveInteger` permits integral values greater than zero.
- `xs:unsignedInt` permits `0` through `4294967295`.
- `EnumTrueFalse` permits only uppercase `TRUE` and `FALSE`.
- `EnumTrueFalseLowerCase` permits only lowercase `true` and `false`.

The XSD includes documentation about intended runtime use, but it does not encode every semantic relationship. In particular, it does not validate which `Exe` children belong with which action, reference existence, flag combinations, project existence, or library behavior. Instance fragments below assume the default Automation namespace inherited from their documented parent; the complete `DMSScript` examples include it explicitly.

## `DMSScript` root

The root content model is `xs:all`. Consequently, the top-level children may appear in **any order**. Examples use a readable conventional order only.

Exactly one of every child in the following table is required except `Interactivity`, which is optional and limited to one:

| Child | Occurrence | XSD value/content contract |
|---|---:|---|
| `Name` | exactly 1 | Anonymous restriction of `xs:string`; details below. |
| `Description` | exactly 1 | `xs:string`; empty is valid. |
| `Type` | exactly 1 | `NonEmptyStringType`, fixed to `Automation`. |
| `Author` | exactly 1 | `xs:string`; the XSD declares default `SKYLINE2\`. The default does not make the element optional. |
| `CheckSets` | exactly 1 | `EnumTrueFalse`: `TRUE` or `FALSE`. |
| `Folder` | exactly 1 | Empty or a string satisfying the folder pattern; details below. |
| `Protocols` | exactly 1 | Zero or more `Protocol` declarations. |
| `Memory` | exactly 1 | Zero or more `File` declarations. |
| `Parameters` | exactly 1 | Zero or more `ScriptParameter` declarations. |
| `Script` | exactly 1 | Zero or more `Exe` actions. |
| `Interactivity` | 0 or 1 | `Auto`, `Never`, `Optional`, or `Always`. |

The XSD documents `CheckSets` as controlling verification that a set reached the read parameter; it also notes that Cube disregards this setting while protocol/script launches can use it.

### `Name` and `Folder` lexical facets

`Name` must be nonempty, must not start or end with whitespace, permits interior ordinary spaces, and rejects `/`, `:`, `*`, `?`, `"`, `<`, `>`, `|`, `°`, and `;`. The XSD pattern also prevents tabs/newlines as interior whitespace. The schema documentation states that the script name must be unique.

`Folder` may be empty. A nonempty value rejects `\`, `:`, `;`, `*`, `?`, `>`, `<`, `|`, `°`, and `"`. These are lexical schema facts; operational folder behavior is managed by DataMiner/Cube.

### Required `options` attribute

`DMSScript@options` is required and is `xs:positiveInteger`; therefore `0` is not schema-valid. Its XSD documentation lists these bit flags:

| Hex flag | Documented meaning |
|---:|---|
| `0x000` | None (documented, although decimal `0` conflicts with the positive-integer facet) |
| `0x008` | Debug Mode |
| `0x010` | AllowUndef |
| `0x020` | RequireInteractive |
| `0x040` | SupportsBackForward |
| `0x080` | SkipElementChecks |
| `0x100` | SavedFromCube |
| `0x200` | SkipInfoEventsSet |
| `0x400` | HasFindInteractiveClient |

The XSD constrains only the resulting value to a positive integer; it does **not** constrain legal flag combinations. Its annotation describes Cube value `472` as one default, while SDK/templates may generate another value. Preserve the value produced by the selected tool unless a reviewed behavior/configuration needs an exact value. Do not prescribe one universal number.

### `Interactivity`

The schema enum is closed to `Auto`, `Never`, `Optional`, and `Always`. Availability is also target-gated operationally:

| Value | Supported-target intent |
|---|---|
| `Never` | No UI. |
| `Optional` | UI only when needed. |
| `Always` | Always UI; preferred for operator-facing low-code IAS. |
| `Auto` | Deliberate legacy string-detection compatibility, not a universal default. |

Explicit `Interactivity` is supported from DataMiner feature release 10.5.9 and main release 10.6.0. Omit the element on earlier targets; do not write an enum merely because the pinned XSD accepts it.

## `Protocols` / `Protocol`

`Protocols` has an `xs:sequence` containing `Protocol` zero or more times. Each `Protocol` has:

- required unqualified `id` of type `xs:positiveInteger`; and
- this exact child sequence, with every child required exactly once:

| Position | Child | Type/facet | XSD-documented purpose |
|---:|---|---|---|
| 1 | `Description` | `NonEmptyStringType` | Dummy variable name/description. |
| 2 | `Name` | `NonEmptyStringType` | Protocol name. |
| 3 | `Version` | `NonEmptyStringType` | Protocol version. |
| 4 | `DefaultElement` | Either empty or pattern `^[0-9]+/[0-9]+$` | Default agent ID/element ID, for example `200/160`. |

Child order inside `Protocol` **is** constrained by its `xs:sequence`; this does not imply an order for root children.

## `Memory` / `File`

`Memory`'s repeated choice admits zero or more `File` children. Each `File` contains exactly one child:

| Child | Occurrence | Type |
|---|---:|---|
| `Description` | exactly 1 | `NonEmptyStringType` |

Each `File` has both required unqualified attributes:

| Attribute | Type/values |
|---|---|
| `id` | `xs:positiveInteger` |
| `volatile` | `EnumTrueFalseLowerCase`: exactly `true` or `false` |

The XSD documentation defines `volatile="true"` as a memory file created within the script and `volatile="false"` as a permanent memory file. `Description` is the memory-file name. No other `File` child or attribute is admitted.

## `Parameters` / `ScriptParameter`

`Parameters` has an `xs:sequence` containing `ScriptParameter` zero or more times. Each `ScriptParameter` contains exactly one `Description` child of `NonEmptyStringType` and has all three required unqualified attributes:

| Attribute | Type/values |
|---|---|
| `id` | `xs:unsignedInt` (`0` through `4294967295`) |
| `type` | Closed enum whose sole value is `string` |
| `values` | `xs:string`; empty is valid, but the attribute is still required |

The XSD documents `Description` as the script-variable name and `values` as the memory-file name that supplies choices; an empty `values` means values are unrestricted. The schema does not validate that a nonempty value resolves to a declared file. There are no other `ScriptParameter@type` values in schema 1.1.10. `<Parameter>` is not a valid substitute, and an omitted `values` attribute is invalid.

## `Script` / `Exe`

`Script` has an `xs:sequence` containing `Exe` zero or more times. Each `Exe` has:

| Attribute | Required? | Type/values |
|---|---:|---|
| `id` | yes | `xs:positiveInteger` |
| `type` | yes | Closed action enum listed below |
| `destvar` | no | `xs:string` |

### Complete `Exe@type` enum

The only permitted action values, with the XSD documentation summarized, are:

| Value | Documented action |
|---|---|
| `assign` | Assign a value. |
| `assigndummy` | Assign a dummy to an element using a variable or value. |
| `assigntemplate` | Assign an alarm or trend template to a dummy. |
| `changestate` | Set a dummy's state. |
| `clearmemory` | Clear an Automation memory file. |
| `comment` | Add a script comment. |
| `csharp` | Execute a C# block. |
| `else` | Start an `else` clause. |
| `endif` | End an `if`/`else` statement. |
| `exit` | Terminate the script without delay. |
| `get` | Get a parameter or memory value. |
| `goto` | Jump to a label. |
| `findinteractiveclient` | Ask an interactive user to attach. |
| `if` | Start a conditional block. |
| `information` | Generate an information event. |
| `label` | Define a target for `goto`. |
| `logmessage` | Write a message to `SLAutomation.txt`. |
| `notification` | Send email or SMS. |
| `report` | Upload a report to FTP or a shared folder. |
| `script` | Run another Automation script. |
| `set` | Set a parameter, memory position, or variable. |
| `sleep` | Pause for a period. |
| `ui` | Configure a dialog requesting user input. |
| `wait` | Wait for a positive result. |

These values include schema-valid legacy action blocks. Greenfield/new SDK-first authoring normally emits a `csharp` action linked to a project; review, read-only investigation, and explicitly targeted maintenance of an existing legacy artifact must still understand its other values.

### Complete `Exe` child content model

The `Exe` content model is literally `xs:choice minOccurs="0" maxOccurs="unbounded"`. Each choice occurrence selects one of the child particles below. This has three important consequences:

1. `Exe` may have no children at all according to the XSD.
2. Child occurrences may be interleaved in any order; there is no `Exe` child sequence.
3. A branch declared locally with `maxOccurs="1"` can be selected again in another outer-choice occurrence. The XSD therefore does not establish a global one-per-`Exe` cap for those names. Likewise, `Message minOccurs="1"` means one element when that branch is selected; it does not make `Message` mandatory for the whole `Exe`.

The literal particles and content types are:

| Child | Local occurrence in selected branch | Content type | XSD-documented purpose |
|---|---:|---|---|
| `Condition` | 0..unbounded | `xs:string` simple content plus optional attributes | Boolean-expression condition/value. |
| `Destination` | 0..1 | `xs:string` simple content plus attributes; `type` is required | Notification/report destination. |
| `Include` | 0..1 | `xs:string` simple content plus optional `params` | Item to include. |
| `MemoryPos` | 0..1 | `xs:string` | Memory position to get/set. |
| `Message` | exactly 1 | `xs:string` simple content plus optional `ref` | Action message. |
| `Param` | 0..unbounded | `xs:string` simple content plus optional attributes | Action parameter. |
| `Protocol` | 0..1 | `xs:positiveInteger` | Dummy-variable reference. |
| `Script` | 0..1 | `NonEmptyStringType` | Referenced script name. |
| `ScriptSuccess` | 0..1 | `EnumTrueFalse`: `TRUE` or `FALSE` | Whether execution is considered successful. |
| `Template` | 0..1 | `NonEmptyStringType` | Template name. |
| `Timeout` | 0..1 | `xs:positiveInteger` | Timeout value. |
| `Type` | 0..1 | Closed state/value enum listed below | State/value mode. |
| `Value` | 0..1 | `xs:string` simple content plus optional attributes | Action value. |

The action comments in the XSD describe intended associations, but the schema does not condition the choice on `Exe@type` and does not require a semantically complete set for any action. Use the target runtime/tool for semantic behavior without inventing additional XSD constraints.

### `Condition` contract

`Condition` text is `xs:string` (empty is valid). Every attribute is optional:

| Attribute | Type/closed values |
|---|---|
| `combination` | `and`, `or` |
| `compare` | `eq`, `lt`, `lte`, `noteq`, `gte`, `gt` |
| `pid` | `xs:positiveInteger` |
| `protocol` | `xs:positiveInteger` |
| `ref` | `xs:string` |
| `type` | `param`, `variable` |
| `var` | `xs:string` |

### `Destination`, `Include`, and `Message` contracts

All three use `xs:string` simple content.

- `Destination@type` is required and permits only `email` or `sms`. Optional attributes are `title` (`NonEmptyStringType`), `cc` (`xs:string`), and `bcc` (`xs:string`).
- `Include` has optional `params` of type `xs:string`.
- `Message` has optional `ref` of type `xs:string`.

### `Param` contract

`Param` text is `xs:string` and can be empty. Both attributes are optional:

| Attribute | Type/closed values |
|---|---|
| `protocol` | `xs:positiveInteger`; documented for dummy/get/set references |
| `type` | Optional closed enum detailed below |

`Param@type` is case-sensitive and permits exactly:

| Value | XSD-documented meaning/use |
|---|---|
| `CHECKSETS` | For a `script` action, check that a set reached the read parameter. |
| `debug` | Compile in debug mode. |
| `DEFER` | No documentation is supplied in the XSD. |
| `OPTIONS` | No documentation is supplied in the XSD. |
| `libraryName` | Library name; documented as supported since DataMiner 9.6.13. |
| `PARAMETER` | No documentation is supplied in the XSD. |
| `PARAMETERLINK` | No documentation is supplied in the XSD. |
| `preCompile` | Compile a C# action as a library; documentation says content is `true`/`false`, default `false`, supported since DataMiner 9.6.13. |
| `ref` | DLL references for a C# action. |
| `scriptRef` | Reference another script/library using `AutomationScriptName:LibraryName`; `[AutomationScriptName]` may denote the current Automation script. |
| `using` | Namespace references for a C# action. |

`Param` content nevertheless remains unconstrained `xs:string`; the XSD does not enforce a boolean for `preCompile`, a library-name syntax, a script-reference format, or an action/type pairing.

### Nested `Type` contract

`Exe/Type` permits only:

- template/value modes: `alarm`, `trending`, `memory`, `conditions`; and
- state values: `mask`, `pause`, `restart`, `start`, `stop`, `unmask`.

Case is exact. This nested action child is distinct from root `DMSScript/Type`, which is fixed to `Automation`.

### `Value` contract

`Value` text is `xs:string` and may be empty. Both attributes are optional:

| Attribute | Type |
|---|---|
| `ref` | `xs:string` |
| `offset` | `xs:double` |

For a C# SDK action, the operational value is the exact project token `[Project:<intended-project-name>]`. The XSD sees this only as a string and cannot verify that the project exists, that spelling/case is correct, or that it is the intended project.

### Other scalar children

- `MemoryPos` is `xs:string`. Its annotation describes `memory-file-ID:position` such as `2:100`, but no pattern enforces that format.
- Nested `Protocol` is a positive integer reference. It is not the root-level `Protocols/Protocol` declaration and has no `id` attribute.
- Nested `Script` and `Template` are `NonEmptyStringType`.
- `ScriptSuccess` is uppercase `TRUE` or `FALSE`.
- `Timeout` is a positive integer. The XSD annotations mention action-specific ranges, but the XSD encodes no upper bound.

Do not turn optional schema `Timeout` into a generic authoring requirement. Retain the Automation runtime's 10-minute default unless a documented, bounded operation/UX reason requires an override.

## Document-wide identity constraint

The root declares:

```xml
<xs:unique name="idUniqueInScript">
  <xs:selector xpath=".//*" />
  <xs:field xpath="@id" />
</xs:unique>
```

This places **every descendant `@id`** in one shared document-wide uniqueness domain. In 1.1.10, the schema-declared ID-bearing descendants are:

| Element | ID type |
|---|---|
| `Protocols/Protocol` | `xs:positiveInteger` |
| `Memory/File` | `xs:positiveInteger` |
| `Parameters/ScriptParameter` | `xs:unsignedInt` |
| `Script/Exe` | `xs:positiveInteger` |

Inventory all descendant `@id` values and allocate the next available ID across this entire table. Do not narrow collision checks to `ScriptParameter` and `Exe`. Attributes such as `Condition@pid`, `Condition@protocol`, `Param@protocol`, and nested `Exe/Protocol` are references/values, not `@id` fields, so they do not themselves enter the uniqueness set.

When authoring or updating a script, every descendant `@id` across the entire DMSScript document shares one document-wide namespace:
- Unless the caller explicitly requests specific non-colliding IDs (such as parameters `10, 11` with `Exe id="1"`), allocate `<Exe id>` values at `max(all Protocol, File, ScriptParameter, and other descendant @id values) + 1` (and consecutively `max + 1`, `max + 2`, … when multiple `<Exe>` blocks exist, including `if`/`else`/`endif` actions).
- Treat the `<Exe id="1">` emitted by `dotnet new dataminer-automation-project` as provisional: if any `<Protocol>`, `<File>`, or `<ScriptParameter>` uses `id="1"`, move `<Exe id>` to `max(all used descendant @id values) + 1` (for example `id="3"` when parameters `1` and `2` are declared).

## Numeric XML/C# parameter parity

For intended numeric binding in authored or reviewed code, require exact set equality:

```text
{ XML ScriptParameter @id values }
    ==
{ numeric IDs used by engine.GetScriptParam(int) }
```

Thus every XML ID has a numeric read and every numeric read has a declaration. A call to `engine.GetScriptParam("name")` is name-based and does not establish numeric ID parity; list it separately rather than matching it to an XML number. Dynamic/unresolved numeric expressions must be resolved or reported as unproven, not silently counted. Evaluate the calls in the intended C# source: the linked SDK source, or the selected C# `Exe` `<Value>` for explicitly maintained legacy inline mode. Any existing inline build mirror must match that selected `<Value>` exactly before it is used as code or build evidence.

## SDK project links, inline legacy code, and libraries

### SDK-first C# action

For every greenfield/new Automation script, use an SDK project and an exact link; never create a new inline script:

```xml
<Exe id="4" type="csharp">
  <Value><![CDATA[[Project:My-Script]]]></Value>
  <Message></Message>
</Exe>
```

Verify `My-Script` is exactly the intended project identity. The conventional template aligns script/file/project names, but the XSD itself does not enforce that relationship.

`Value` can structurally hold inline C# because it is `xs:string`. That is a schema-valid legacy representation, not a greenfield authoring option. Existing Cube-inline artifacts remain supported for review and read-only investigation. Only when the user explicitly targets maintenance, a bugfix, or a feature on that existing artifact may the selected C# `Exe` `<Value>` be preserved and edited. That selected `<Value>` is the intended C# source; any existing build mirror must match it exactly. Do not silently migrate the artifact or add `[Project:<name>]` unless migration is approved. This narrow exception does not permit generic greenfield inline authoring. Apply the same XML/C# parity, document-wide ID, XSD validation, lifecycle/interactivity, and runtime contracts in either mode.

### Schema-valid library parameters versus operational rules

The following are structurally admitted because their `Param@type` values are in the enum:

```xml
<Param type="preCompile">true</Param>
<Param type="libraryName">MyLibrary</Param>
<Param type="scriptRef">LibraryScriptName:MyLibrary</Param>
```

For the manual/legacy library mechanism, runtime/tooling guidance requires `preCompile` set to `true`, a dots-free `libraryName`, and a matching `LibraryScriptName:LibraryName` consumer reference (the XSD annotation also documents `[AutomationScriptName]:MyCSharpAction`). Those content rules are **not XSD facets**. Prefer the official SDK library template/project references for new work and inspect the generated XML rather than hand-inventing parameters.

## Complete schema-valid declaration example

This example exercises every ID-bearing declaration kind. All IDs are unique document-wide. Its root child order is illustrative only.

```xml
<?xml version="1.0" encoding="utf-8"?>
<DMSScript options="272" xmlns="http://www.skyline.be/automation">
  <Name>My-Script</Name>
  <Description>Processes one selected target.</Description>
  <Type>Automation</Type>
  <Author>Skyline</Author>
  <CheckSets>FALSE</CheckSets>
  <Folder>Operations</Folder>
  <Interactivity>Never</Interactivity>
  <Protocols>
    <Protocol id="1">
      <Description>Target Element</Description>
      <Name>Target Protocol</Name>
      <Version>Production</Version>
      <DefaultElement>200/160</DefaultElement>
    </Protocol>
  </Protocols>
  <Memory>
    <File id="2" volatile="false">
      <Description>Allowed Values</Description>
    </File>
  </Memory>
  <Parameters>
    <ScriptParameter id="3" type="string" values="">
      <Description>Requested Value</Description>
    </ScriptParameter>
  </Parameters>
  <Script>
    <Exe id="4" type="csharp">
      <Value><![CDATA[[Project:My-Script]]]></Value>
      <Param type="debug">true</Param>
      <Message></Message>
    </Exe>
  </Script>
</DMSScript>
```

For a target before DataMiner 10.5.9/10.6.0, remove `Interactivity`; the remaining document still satisfies the XSD.

## Authoring and review checklist

- [ ] Exact default namespace is `http://www.skyline.be/automation`; all elements are qualified and attributes unqualified.
- [ ] Every required root child occurs exactly once; `Interactivity` occurs at most once; no root-order requirement was invented.
- [ ] `options` is present and positive; its generated value is preserved unless a reviewed requirement changes it.
- [ ] `Protocol` children follow their exact sequence and required facets.
- [ ] Every `File` has one nonempty description plus positive `id` and lowercase boolean `volatile`.
- [ ] Every `ScriptParameter` has one nonempty description and required `id`, `type="string"`, and `values` (which may be empty).
- [ ] Every `Exe` has required positive `id`, a permitted action type, and only admitted children/attributes/enums.
- [ ] Every descendant `@id` is unique across `Protocol`, `File`, `ScriptParameter`, `Exe`, and any other descendant carrying `@id`; any colliding scaffolded `<Exe id="1">` was moved to `max(all used descendant @id values) + 1`, and the Script Map records the next available document-wide ID.
- [ ] XML script-parameter IDs and numeric `engine.GetScriptParam(int)` IDs are exact sets in both directions; name-based calls are listed separately.
- [ ] Every greenfield/new C# action links exactly to its intended SDK project with `[Project:<name>]`; no new inline script was created. Existing inline C# is read-only for review/investigation or is edited only for explicitly targeted maintenance/bugfix/feature work; its selected C# `Exe` `<Value>` is the intended source, no unapproved project marker/migration was introduced, and any existing build mirror matches it exactly.
- [ ] `Interactivity` follows target support and intended UX; it is omitted for legacy targets.
- [ ] The XML validates against the pinned XSD and passes `scripts/validate-dmsscript-xml.ps1`. Runtime/tooling checks cover semantic relationships the XSD does not encode.
