---
name: dataminer-catalog-hygiene
description: Validation rules for DataMiner Catalog item documentation and metadata. Applies only to CatalogInformation/README.md and CatalogInformation/manifest.yml, never to root or project READMEs. Use when auditing, reviewing, or fixing Catalog item documentation — checking About, Key Features, Use Cases, Prerequisites, and Technical Reference sections, image paths, tags, owners, and publication readiness.
argument-hint: N/A — loaded automatically when auditing CatalogInformation documentation
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-08-04
  version: 1.1
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.1 | 2026-09-16 | Added the publication handoff boundary between connector help pages, CatalogInformation metadata, and deployment verification. |
| 1.0 | 2026-08-04 | Initial release. Rules extracted from dataminer-docs `develop/best_practices/Catalog_Items/` at commit `c94dcf5`, verified byte-identical to `main` on 2026-08-04. |

# DataMiner Catalog item hygiene

Criteria for judging whether a Catalog item's `CatalogInformation/README.md` and `manifest.yml` meet the published best practices for items on catalog.dataminer.services.

This skill owns **what good looks like**. It does not own workflow — the `dataminer-catalog-audit` agent owns discovery, editing, and pull request creation.

## When to Use This Skill

- Auditing a Catalog item's README or manifest against best practices
- Adding documentation to an item that has a `CatalogInformation` folder
- Reviewing a pull request that changes Catalog item documentation or metadata
- Deciding whether an item is ready to publish to the Catalog
- Fixing broken image paths, tag lists, owner entries, or missing sections

## Discovery

A Catalog item is a **project (`.csproj`) with a `CatalogInformation` folder** beside it. Nothing else qualifies.

**Only `CatalogInformation/README.md` is a Catalog item description.** Every other README in the repository is out of scope — the repository-root README, per-project READMEs, `docs/` pages, and READMEs in sample or test folders all serve different audiences and are governed by different conventions. Applying these rules to them produces false findings; editing them is out of scope entirely.

That folder typically contains:

| Path | Role |
|------|------|
| `CatalogInformation/README.md` | The Catalog item description shown to users |
| `CatalogInformation/manifest.yml` | Catalog item metadata |
| `CatalogInformation/Images/` | Optional images referenced from the README |

When the user names a specific project, audit only that project. With no such context, scan the repository for every `.csproj` that has a `CatalogInformation` sibling folder and audit all of them.

## Severity model

Every finding carries exactly one severity. Do not invent additional levels.

| Severity | Meaning |
|----------|---------|
| `[ERROR]` | Must be present or absent — blocks publication |
| `[WARNING]` | Should be present or absent — degrades quality |
| `[INFO]` | Informational guidance |

## Reference Files

Read these as needed for the current task. Do not read them all up front.

- `references/readme-rules.md` — section-by-section rules for `README.md`: About, Key Features, Use Cases, Prerequisites, Technical Reference, visuals, and contact details.
- `references/manifest-rules.md` — `manifest.yml` fields: name, type, tags, icon, owners, and the documentation/source URLs.
- `references/remediation.md` — issue → severity → fix tables, the preservation rules, and the expected reporting format.

## Related Skill

- `project-type-identification` — run this, scoped to the item under audit, before judging the manifest's `type` field. It produces a typed inventory of every project the item is built from, which is the evidence that separates "this item's `type` is genuinely wrong" from "this package legitimately combines several component types". See the Type section in `references/manifest-rules.md` for how to use the inventory.

## Publication Handoff Boundary

`CatalogInformation/README.md` and `manifest.yml` describe a Catalog item. Connector help pages under `dataminer-docs-connectors/connector/doc/` are a separate documentation surface and must use `dataminer-connector-help` instead. Do not apply CatalogInformation rules to connector help pages, and do not treat a valid connector help page as proof that Catalog metadata is valid.

Before a Catalog publication handoff, record the exact artifact/project being published and run this skill's README/manifest checks. Keep the Catalog identifier, owner decision, publication result, deployment target, and post-deploy verification as separate evidence; never infer a successful publication or deployment from documentation alone.

## Gotchas

- **These rules apply to `CatalogInformation/README.md` only.** A repository-root or per-project README is not a Catalog item description. Judging one against these criteria would generate confident, wholly invalid findings — a root README is *supposed* to carry build instructions, contribution guidance, and technical detail that would be violations here. Confirm the path before applying a single rule.

- **Never remove content to satisfy a rule.** Broken image path → fix the path, keep the image. Over-long Technical Reference → trim prose, keep the equipment/connector list. Deleting content is the most common way an automated pass causes a regression. Full list in `references/remediation.md`.

  One named exception: a **`wip.png`** placeholder may be removed with its reference. By that exact name only — do not generalize it to other images that merely look like placeholders.

- **Image paths must be `./Images/filename.png` — relative, with capital `I`.**

- **Never invent facts.** Version numbers, licenses, prerequisites, owners, and supported equipment must come from the repository. A plausible-looking invented minimum DataMiner version is worse than a reported gap, because a reviewer cannot tell it was guessed.

- **`type`, `owners[*].name`, and `title` are report-only — hint, never write.** All three assign identity, so a wrong value survives review. `type` describes the whole package, which is often built from several projects — run `project-type-identification` scoped to the item to see whether those projects agree on one type or genuinely differ before judging it. For the owner, a single-contributor repository is worth naming as a question the author can confirm. For `title`, an `SLC-` prefixed code or the repository name means the field was never filled in — flag it and propose something user-facing. Attribute every hint to its evidence and leave the decision to the author. Details in `references/manifest-rules.md`.

- **Support contacts are an `[ERROR]`, not a nicety.** Team email addresses in the README route users around DataMiner Support. Owner addresses belong in `manifest.yml`.

- **"Generic DataMiner capability" is the most frequent Key Features failure.** Alarming and trending are platform features, not item features. If a listed feature would be true of any DataMiner item, it does not belong.

- **Key Features cap at 5, tags cap at 5.** Both are hard counts and both are commonly exceeded. Tags additionally cap at three words each and must use title case.

- **The `.csproj`'s `MinimumRequiredDmVersion`** is the prerequisite DataMiner version for the **default deployment**. It should be mentioned in the README; treat the `.csproj` as the source of truth and flag a mismatch rather than telling the author to remove it.

## References

- [Best practices for Catalog items](https://aka.dataminer.services/best-practices-catalog-items)
- [Registering a Catalog item](https://aka.dataminer.services/register-catalog-item)
- [Contacting DataMiner Support](https://aka.dataminer.services/contacting-tech-support)
