---
name: dataminer-docs-house-style
description: Applies general DataMiner documentation spelling, grammar, and terminology rules that apply regardless of context. Use whenever creating, editing, or reviewing DataMiner documentation.
argument-hint: N/A — loaded automatically when creating, editing, or reviewing DataMiner documentation
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-02
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-02 | Initial release. |

# DataMiner Documentation House Style

This skill defines general spelling, grammar, punctuation, and terminology rules for DataMiner documentation that apply regardless of context. Apply these rules whenever creating, editing, or reviewing DataMiner documentation, in addition to any repository-specific style guides.

## General

- Use US English.

## Capitalization

- When referring to a specific instance of an automation script, correlation rule, dashboard, low-code app, or user-defined API, do not use capitalization except where required by sentence context, for example, at the beginning of a sentence. Use the capitalized forms "Automation", "Correlation", "Dashboards", "Low-Code Apps", and "User-Defined APIs" when referring to the respective DataMiner module names, not to specific instances created with those modules.
- When referring to a DataMiner Agent (also known as a DataMiner node), always capitalize "Agent". This differentiates DataMiner Agents from other types of agents, which are not capitalized.
- When referring to a DataMiner System (i.e., one or more DataMiner Agents working together as a cohesive unit), always capitalize "System". Do not capitalize generic, unrelated uses of the word "system", such as "system tray" or "system requirements".
- When referring to the DataMiner Failover feature, always capitalize "Failover". This differentiates the feature from generic uses of the word "failover", which are not capitalized.

## Punctuation

- Use single quotation marks for quoted material within a quotation (i.e., a nested quote); otherwise, use double quotation marks.
- Use `e.g.,` and `i.e.,`.
- Avoid em dashes, except in marketing content such as connector marketing pages, where they can be used sparingly.
- When referring to a UI menu option that ends with an ellipsis (`...`), omit the ellipsis.

## Spelling House Rules

- Write the following compound words as one word: dataset, frontend, backend, runtime (except when explicitly referring to the duration of an execution), lifecycle, dropdown, checkbox, scrollbar, livestream, multithreaded, and username.
- An exception is a direct reference to UI text. In this case, ask whether the UI can be updated to use the correct spelling, but tolerate the existing spelling until it is updated.

## Terminology

- Avoid using `dropdown` as a noun; instead, use "dropdown menu" or "dropdown list" to provide clarity.
- Avoid using `popup` as a noun; instead, use "pop-up window" or "dialog" to provide clarity.
- Use "lower-right", "lower-left", "upper-right", and "upper-left" to refer to corners consistently.

## Procedure Formatting

- Write procedures as numbered lists.
- Use one logical action per numbered step.- An exception to the above is procedures consisting of a single step, which do not require numbering.
- Keep instruction lines short and easy to scan.
- Put any additional information about a step in a separate, indented paragraph below that step.
- Put the result of a step in an indented paragraph below that step, and use future tense (e.g., "A new window will open" instead of "A new window opens").
- If a step contains an image, indent it correctly so that list numbering does not restart.

## AI-Friendly Writing

- Use descriptive alt text for images.
- Structure text logically, with meaningful headers that clearly indicate what each subsection covers.
- Make content as future-proof as possible, for example, by adding DataMiner version information where relevant or rephrasing new feature content that would otherwise become outdated quickly.
- A bulleted list or regular text is preferred over a table when either is equally clear, as tables can be harder to interpret correctly. Use a table only when it is clearly the most user-friendly option.

## Repository-Specific Style Guides

- If style guides in a specific repository, for example, `dataminer-docs`, conflict with this skill, those repository-specific style guides supersede these guidelines.
