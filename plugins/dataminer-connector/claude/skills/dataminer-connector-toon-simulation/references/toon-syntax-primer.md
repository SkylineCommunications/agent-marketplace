# TOON Syntax Primer

Compact encoding reference for generating valid TOON output. TOON is a line-oriented, indentation-based data format with JSON's data model.

> **Spec version**: v3.3 (2026-05-20)
> **File extension**: `.toon`
> **Media type**: `text/toon`

## Encoding Requirements

- **Encoding**: UTF-8 only
- **Line endings**: LF (`\n`) only — never CRLF
- **Indentation**: 2 spaces per level, consistent throughout. No tabs in indentation
- **No trailing spaces** on any line
- **No trailing newline** at end of file

## Objects

One field per line. Key followed by colon and one space, then value:

```toon
id: 123
name: Ada
active: true
```

### Nested Objects

Key ends with `:` alone (no value on same line). Children indented one level deeper:

```toon
user:
  id: 123
  name: Ada
  address:
    city: Brussels
    country: Belgium
```

### Empty Objects

Nested empty object: `key:` alone with no children at the next indent level.

## Primitives

| Type | Encoding |
|------|----------|
| String (safe) | Unquoted: `name: Ada` |
| String (needs quoting) | Quoted: `version: "123"` |
| Number | Canonical decimal: `count: 42`, `rate: 3.14` |
| Boolean | Lowercase: `active: true`, `enabled: false` |
| Null | Lowercase: `value: null` |

### Number Rules

- Canonical decimal for values in `[1e-6, 1e21)` or zero
- Exponent form permitted outside that range
- `-0` → `0`
- `NaN`, `Infinity`, `-Infinity` → `null`

## Quoting Rules

A string MUST be quoted if:

- It is empty (`""`)
- It has leading or trailing whitespace
- It equals `true`, `false`, or `null` (case-sensitive)
- It looks like a number (e.g., `"42"`, `"-3.14"`, `"1e-6"`, `"05"`)
- It contains: `:`, `"`, `\`, `[`, `]`, `{`, `}`, or any control character U+0000–U+001F
- It contains the active delimiter (comma by default inside arrays, comma for object field values)
- It equals `"-"` or starts with `"-"` followed by any character

Otherwise strings are unquoted. Unicode, emoji, and internal spaces are safe unquoted.

## Escape Sequences

Only these six are valid inside quoted strings:

| Character | Escape |
|-----------|--------|
| Backslash (`\`) | `\\` |
| Double quote (`"`) | `\"` |
| Newline (U+000A) | `\n` |
| Carriage return (U+000D) | `\r` |
| Tab (U+0009) | `\t` |
| Other U+0000–U+001F | `\uXXXX` |

All other escape forms (e.g., `\x`, `\0`, `\b`) are INVALID.

## Arrays

### Primitive Arrays (Inline)

Array of primitives on one line. Header declares length `[N]`:

```toon
tags[3]: admin,ops,dev
ports[4]: 80,443,8080,8443
```

### Tabular Arrays (Arrays of Uniform Objects)

When all objects share the same primitive-valued keys, use tabular format. Header declares length, delimiter, and field names:

```toon
items[3]{sku,qty,price}:
  A1,2,9.99
  B2,1,14.5
  C3,5,3.25
```

Rules:
- `[N]` MUST match actual row count
- `{field1,field2,...}` declares column names in order
- Each row has values comma-separated in same order as fields
- Values follow same quoting rules (quote if contains comma, looks like literal, etc.)
- Rows are indented one level deeper than the header

### List Arrays (Mixed/Non-Uniform)

When objects have different keys or contain nested structures, use hyphen-prefixed list items:

```toon
items[3]:
  - 1
  - name: Ada
    role: admin
  - text
```

### Objects as List Items

Object list items start with `- ` then first field on same line:

```toon
sessions[2]:
  - id: 1
    name: GetStatus
    url: /api/status
  - id: 2
    name: GetInterfaces
    url: /api/interfaces
```

### Empty Arrays

```toon
items: []
```

## Delimiter

Default delimiter is comma (`,`). Inside an array scope, only the active delimiter triggers quoting — other characters are literal data.

For simulation files, always use the default comma delimiter.

## Complete Example

```toon
meta:
  connector: Acme - Router X1000
  version: 1.0.0.1
  type: snmp
  generated: 2026-07-08T12:00:00Z
snmp:
  scalars[3]{oid,type,value}:
    1.3.6.1.2.1.1.1.0,OctetString,Linux router 5.15.0-generic
    1.3.6.1.2.1.1.3.0,TimeTicks,1234567
    1.3.6.1.2.1.1.5.0,OctetString,router-core-01
  tables[1]:
    - name: ifTable
      baseOid: 1.3.6.1.2.1.2.2.1
      columns[3]{subOid,type,name}:
        2,OctetString,ifDescr
        5,Gauge32,ifSpeed
        8,Integer32,ifOperStatus
      rows[3]{index,2,5,8}:
        1,GigabitEthernet0/0,1000000000,1
        2,GigabitEthernet0/1,1000000000,2
        3,Loopback0,0,1
```
