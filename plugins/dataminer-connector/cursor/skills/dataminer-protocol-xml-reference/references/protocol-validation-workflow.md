# Schema Validation Workflow

Authority scope: authored from `protocol.xsd` 1.1.10 and included `uom.xsd`. This file is a bundled-schema checklist, not a validator-rule or runtime-behavior checklist.
Coverage: complete for schema workflow rules. It does not authorize any XML branch by itself; use the specific branch reference files.

## Schema Check Order

Before writing or changing XML, verify:

- The parent path exists in the loaded bundled schema references.
- The child element exists at that parent path in the loaded bundled schema references.
- The attribute exists on that exact element/type in the loaded bundled schema references.
- Required children and attributes are present.
- Repeated elements respect `minOccurs` and `maxOccurs`.
- Enum values use exact casing, spacing, and punctuation.
- Fixed values use the schema-fixed value.
- IDs match the simple-type gates in the bundled references.
- Key/keyref references point to existing schema keys.
- Option attributes are not assumed to have schema-validated tokens when their type is `xs:string`.

## Schema Validation Catches

Schema validation catches:

- Unknown elements.
- Unknown attributes.
- Wrong element or attribute casing.
- Invalid child placement.
- Missing required elements or attributes.
- Invalid enum values.
- Invalid fixed values.
- Invalid ID/simple type patterns.
- Some uniqueness violations.
- Schema-defined key/keyref violations.

## Schema Validation Does Not Catch

The schema cannot fully validate:

- Most `options` token semantics where the attribute type is `xs:string`.
- Whether an action type is meaningful for a selected target beyond the schema value list.
- Breaking-change/versioning policy.
- Validator rules that are not encoded as XSD constraints.

Use the appropriate non-schema skill for non-schema concerns.

## Anti-Invention Rule

If a tag, attribute, enum value, fixed value, or schema-patterned option cannot be found in this skill, do not write it. Request a reference expansion.
