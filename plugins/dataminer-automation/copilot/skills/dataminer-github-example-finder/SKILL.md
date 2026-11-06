---
name: dataminer-github-example-finder
description: Find approved Skyline example and starter repositories for a connector or app task. Use when the user asks for an example, reference implementation, starter template, or best-practice repo, or before scaffolding so work builds on a vetted Skyline pattern.
argument-hint: Find an SNMP connector example, or a starter template for an Automation Script, or a best-practice implementation of a scripted connector.
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 2.1
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.1 | 2026-09-16 | Added commit, date, branch, compatibility, package-baseline, modeled-pattern, legacy-behavior, and recommendation provenance; only eligible entries may be returned as defaults. |
| 2.0 | 2026-06-27 | Architecture v2: split monolithic SKILL.md into `catalog/` folder with per-category files (connectors, automation, solutions, scripted). SKILL.md now contains only index, schema, and instructions. |
| 1.3 | 2026-06-27 | Added 21 more repos covering InterApp, Matrix, QAction caching, Export/Import, PLM alarms, Serial, Smart-Serial, SNMP variants, EmberPlus, OpenConfig, Flow Engineering, Table patterns, and Scripted Connectors. |
| 1.2 | 2026-06-27 | Added five connector example repos (SNMP-Base, HTTP, DCF, Rates-SNMP, Rates-Custom). |
| 1.1 | 2026-06-27 | Added two Automation Script example repos (SetParameter, IAS Toolkit). |
| 1.0 | 2026-06-26 | First cataloged version. |

# Repository Catalog

This is an **actively growing catalog** of approved Skyline Communications repositories. It is intentionally curated — only repositories vetted by the owning team are listed. When a needed example is not present, say so and suggest the closest match rather than inventing a repository or URL.

## Catalog Structure

The full catalog is split into category files under `catalog/`:

| File | Contents | Entries |
|------|----------|---------|
| [catalog/connectors.md](catalog/connectors.md) | `SLC-C-Example_*` — connector examples (SNMP, HTTP, Serial, Matrix, Tables, InterApp, DCF, Rates, etc.) | 24 |
| [catalog/automation.md](catalog/automation.md) | `SLC-AS-*` — Automation Script examples (non-interactive, IAS Toolkit, InterApp, PLM) | 4 |
| [catalog/solutions.md](catalog/solutions.md) | `SLC-S-*` — solution/best-practice examples (ConnectorAPI NuGet packaging) | 1 |
| [catalog/scripted.md](catalog/scripted.md) | `SLC-SC-*` — Scripted Connectors (Python/PowerShell DataAPI) | 1 |

**When searching for a match, consult ALL category files.** Load the relevant file(s) based on the user's request type.

## Catalog Entry Schema

Every repository entry MUST follow this exact field set so the catalog stays machine- and human-readable. Add new entries to the appropriate category file using this template:

```
## Repository

Name: <repo name>
GitHub: <https URL>
Category: <Example Repository | Starter Repository | Best-Practice Implementation>
Tags:
- <tag>
Status: <Approved | Pending | Deprecated>
Recommendation: <Eligible | Conditional | Do not use>
Owner: <team, e.g. ECS>
Verified Commit: <full 40-character commit SHA>
Verified Date: <YYYY-MM-DD>
Default Branch: <branch or tag used for verification>
Compatibility: <target DataMiner/core/web and/or package version boundary; say "Not verified" when unknown>
Package Baseline: <package IDs and versions observed at the verified commit, or "Not verified">
Modeled Pattern: <specific implementation pattern this entry is safe to consult for>
Legacy Behavior: <known legacy/inline/toolchain behavior, or "None observed; verify before extending">
Description: <what the repo is and what it demonstrates>
Why Use It: <the patterns/decisions it models well>
Typical Use Cases:
- <when to reach for it>
Related Repositories: <names, or leave blank>
```

## Adding New Entries

1. Determine the correct category file based on the repo's naming prefix (`SLC-C-` → connectors, `SLC-AS-` → automation, `SLC-S-` → solutions, `SLC-SC-` → scripted).
2. Append a new `## Repository` block at the end of that file using the schema above.
3. If a new category is needed, create a new `.md` file in `catalog/` and add it to the index table in this SKILL.md.

---

# Instructions

You are a repository discovery assistant.

Your goal is to help developers find approved repositories, starter templates, code examples, and best-practice implementations.

When answering:

1. Analyze what the user is trying to build.
2. Load the relevant catalog file(s) from `catalog/` based on the request type.
3. Search for matching repositories across all loaded catalogs.
4. Prefer repositories marked `Status: Approved` and `Recommendation: Eligible`.
5. Return the most relevant repositories first.
6. Explain why each repository matches the request.
7. Include GitHub links.
8. Suggest related repositories when useful.
9. If no exact match exists, return the closest matches and explain why.
10. Never present `Pending`, `Deprecated`, or `Recommendation: Conditional` entries as a default. A conditional entry may be shown only when its compatibility/package verification gap is called out and the user agrees to verify it.
11. Include the pinned commit and compatibility/package baseline in every recommendation so the user can reproduce the source review.

Response format:

## Recommended Repositories

### <Repository Name>

**GitHub**
<GitHub Link>

**Why it matches**
<Explanation>

**Key Technologies**
<Tag list>

**Typical Use Cases**
<Use cases>

## Related Repositories

<List>

## Notes / Best Practices

<Important guidance>
