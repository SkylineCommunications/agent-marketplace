# QAction XML Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `/Protocol/QActions/QAction` attributes, direct children, mixed content, and XSD-patterned option tokens listed here. Unlisted QAction descendants/options MUST NOT be authored.

## QActions

`/Protocol/QActions` contains `QAction` zero or more times.

QAction IDs and names are unique within `/Protocol/QActions`. This is a separate key space from parameters, commands, responses, pairs, groups, timers, triggers, and actions.

## QAction

`QAction`:

- Mixed content: script text/CDATA is allowed.
- Required attributes: `id` `TypeObjectId`, `name` `TypeNonEmptyString`.
- Optional attributes: `dllImport`, `encoding`, `entryPoint`, `include`, `inputParameters`, `options`, `row`, `triggers`.
- Optional child: `Condition`.

Attribute types:

- `encoding`: values `jscript`, `vbscript`, `csharp`.
- `dllImport`: `TypeDllImport`, semicolon-separated DLL-name pattern.
- `inputParameters`: `TypeSemicolonSeparatedNumbers`.
- `options`: `TypeQActionOptions`; tokens/patterns are `binary`, `debug`, `group`, `precompile`, `queued`, `dllName=<value>`.
- `row`: `EnumTrueFalse`.
- `triggers`: `TypeSemicolonSeparatedNumbers`.

Do not add child elements under `QAction` other than mixed content and `Condition`.
