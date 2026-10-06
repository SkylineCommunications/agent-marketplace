# Conditions Logic

Authority scope: this file explains condition expression behavior and evaluation timing. It is not the XML schema reference. For valid XML placement of `Condition` elements, use `dataminer-protocol-xml-reference`.

## Purpose

Conditions enable or skip execution based on parameter values.

They can control:

- Actions.
- Groups.
- Pairs.
- QActions.
- Timers.
- Triggers.

Prefer conditions over QActions when the logic is a straightforward value check.

## Evaluation Timing

| Context | Evaluation timing |
|---|---|
| Action | When the action executes. |
| Group | When the group executes, not when it is added to the queue. |
| Pair | When the pair executes. |
| QAction | When the QAction triggers. |
| Timer | When the timer fires. |
| Trigger | When the trigger activates. |

Group conditions can observe different values at execution time than when the group was queued.

Use group conditions instead of timer conditions when the intent is to skip work at the moment the work would execute.

## Operators

Arithmetic operators:

| Operator | Behavior |
|---|---|
| `+` | Addition or string concatenation. |
| `-` | Subtraction. |
| `*` | Multiplication. |
| `/` | Division. |

Relational operators:

| Operator | Behavior |
|---|---|
| `>` | Greater than. |
| `<` | Less than. |
| `>=` | Greater than or equal. |
| `<=` | Less than or equal. |

Equality operators:

| Operator | Behavior |
|---|---|
| `==` | Equal. |
| `!=` | Not equal. |

Bitwise operators:

| Operator | Behavior |
|---|---|
| `&` | Bitwise AND. |
| `|` | Bitwise OR. |
| `^` | Bitwise XOR. |

Logical operators:

| Operator | Behavior |
|---|---|
| `AND` | Boolean AND. |
| `OR` | Boolean OR. |

`AND` and `OR` must be surrounded by spaces.

## Operands

| Operand | Meaning |
|---|---|
| `id:X` | Parameter with ID `X`. |
| `"value"` | String literal. |
| `empty` | Empty/not initialized parameter. |
| `emptystring` | Empty string or empty parameter. |
| Number | Numeric double value. |

Rules:

- Do not put a space between `id:` and the parameter ID.
- Do not use `#` or `$` outside string literals.
- Arithmetic operands must match expected string or double behavior.
- Bitwise operands are treated as integer-like double values.

## XML Text Considerations

- Use CDATA when a condition contains `<` so XML parsing does not treat it as a tag delimiter.
- Use spaces around operators for readability and parser safety.
- Use spaces between consecutive brackets: `( (` instead of `((`.

## Empty Value Gotcha

A numeric parameter with fixed length and a fixed value can evaluate as `empty` because the value is fixed by interpretation rather than dynamically set.

Test empty checks carefully, especially when using fixed parameters, saved parameters, and startup logic.

## Common Patterns

### Enable Or Disable Polling

Use a saved configuration parameter and place the condition on the group that performs polling. The condition is evaluated when the group executes.

### Mode-Based Logic

Compare a mode/status parameter against allowed string or numeric values and use `OR` when multiple modes should execute the same path.

### Threshold Logic

Use CDATA for conditions that include both `>` and `<` comparisons.

### Not-Initialized Guard

Use explicit checks for `empty` and `emptystring` when a parameter can be uninitialized or an empty string.

## Design Rules

- Keep conditions simple.
- Prefer group conditions for polling gates.
- Avoid timer conditions unless the timer itself should be suppressed.
- Use conditions to avoid unnecessary trigger/action/QAction work.
- Do not use a QAction for a simple condition that XML logic can express.
