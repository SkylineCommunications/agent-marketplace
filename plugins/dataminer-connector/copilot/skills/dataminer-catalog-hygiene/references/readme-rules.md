# Catalog item README validation rules

> **Provenance** — Paraphrased from `SkylineCommunications/dataminer-docs`, `develop/best_practices/Catalog_Items/Best_Practices_When_Documenting_Catalog_Items.md`. Extracted at commit `c94dcf5` and verified byte-identical to `main` on 2026-08-04. Human-readable source: <https://aka.dataminer.services/best-practices-when-documenting-catalog-items>. The published page is authoritative if the two ever disagree.

Applies to `CatalogInformation/README.md` — and to no other README. A repository-root or per-project README serves a different audience and must not be judged against these rules.

Guiding principle: the description must be **attractive and clearly present the value** of the item. Keep it concise; push technical depth to an external link via `documentation_url`.

## Expected structure

Sections in this order. **About is always required.** Key Features and Use Cases are alternatives — at least one of the two must be present, and a small item may fold Use Cases into Key Features or vice versa. Prerequisites is expected; Technical Reference is optional.

| # | Section | Required |
|---|---------|----------|
| 1 | About | Yes |
| 2 | Key Features | One of Key Features / Use Cases required |
| 3 | Use Cases | One of Key Features / Use Cases required |
| 4 | Prerequisites | Expected — not marked optional upstream |
| 5 | Technical Reference | Optional |

### About

**Purpose:** Summarize what makes the item valuable and why users should deploy it — the problems it solves and its primary benefits.

**[ERROR]** MUST be present. MUST summarize what makes the item valuable, why users should deploy it, and what problems it solves.

**[WARNING]** SHOULD use accessible language for both technical and non-technical readers, highlight important points with bold text, and keep the tone professional. MUST NOT include excessive technical detail, generic DataMiner capabilities, or duplicate Key Features content.

**Do:** keep to the essentials, split over a few paragraphs only when it aids clarity; organize from broad benefits to specific features to practical applications; use alerts where they earn their place.

**Don't:** use jargon or overly complex language; include excessive amounts of bold text or many alerts (they stop drawing attention); mention generic DataMiner benefits such as alarming and trending.

### Key Features

**Purpose:** Product-centric. The main features that distinguish this item.

**[ERROR]** At least one of **Key Features** or **Use Cases** MUST be present. When Key Features is the section used, it MUST contain a maximum of **5 features**, using direct, benefit-oriented language with action verbs ("Monitor", "Track", "Detect", "Automate").

**[WARNING]** MUST NOT describe generic DataMiner capabilities, and MUST NOT use vague descriptors ("high-performance") without specific context.

**Do:** tie every feature to specific user value; prioritize what differentiates the item.

**Don't:** go into excessive detail; mention features that are really DataMiner platform features.

### Use Cases

**Purpose:** User-centric. Real-world scenarios where the item delivers value.

**[ERROR]** At least one of **Key Features** or **Use Cases** MUST be present.

**[WARNING]** When included, Use Cases SHOULD demonstrate practical real-world scenarios using specific, non-hypothetical examples relevant to the typical user base. MUST NOT duplicate Key Features content.

**Do:** connect to common challenges (remote connectivity, high data usage); use relatable examples such as "Monitor remote satellite terminals in real time"; optionally link to a use case on [DataMiner Dojo](https://community.dataminer.services/use-cases/).

**Don't:** mention hypothetical scenarios with no relevance to the typical user base.

### Prerequisites

**Purpose:** Essential technical requirements for deployment. Concise bullet points only.

**[WARNING]** When included, SHOULD make the minimum DataMiner version discoverable — either stated inline or via an explicit link to release notes or versioned documentation. Any DataMiner version prerequisite is sufficient; do not flag a README for stating only one release track. SHOULD also list required licenses, soft-launch options, and component dependencies. MUST NOT include complex installation or configuration steps — link to documentation instead.

**Applicable requirements**, when they apply:

- **Minimum/maximum DataMiner version** — only mention a minimum if it is a currently
  supported version. If the **Web** or **Cube** requirement differs from the server version, state it separately.
- **Minimum/maximum DxM version**
- **Licenses** (for example DOM, SRM)
- **Soft-launch options**
- Other **Catalog items**
- Requirements for components included in the package

Prerequisites in the description target the **default deployment**. Version-specific prerequisites belong in that version's description.

**Don't:** list every small technical dependency — essentials only.

### Technical Reference

**Purpose:** Links to detailed technical documentation. The Catalog stays high-level.

**[WARNING]** When included, SHOULD link to detailed external documentation using the `documentation_url` manifest field. MUST NOT duplicate content available elsewhere, and MUST NOT document UI details that change frequently. When documentation is external, include a concise equipment/connector list (supported devices, protocols) — this list MUST NOT be removed.

**Do:** use consistent naming ("Installing ...", "Working with ..."); use public links; as a Skyline employee linking to docs.dataminer.services, use `aka` redirect links so targets survive restructuring.

**Don't:** include procedures the user should not follow or redundant information.

## Visuals

**Purpose:** Support About, Key Features, and Use Cases with images that show the value.

**[ERROR]** Image paths MUST use `./Images/filename.png` — relative, capital `I`. Paths
using a `~/images/` prefix are invalid on catalog.dataminer.services and MUST be corrected. Images MUST NOT be removed when fixing paths; only the path format changes.

**[WARNING]** When included, visuals SHOULD live in the `Images` folder (correct casing), be limited to a maximum of **3**, and be clear and high quality. GIFs SHOULD run at most **10 seconds** and focus on one specific feature.

**[WARNING]** Visuals MUST NOT be blurry, show sensitive data, display unnecessary open panels, or contain unnecessary blank space.

### Placeholder images — the one removable image

**[WARNING]** A **`wip.png`** ("work in progress") placeholder MAY be removed, along with the markdown that references it. It conveys nothing to a Catalog visitor and is left behind from scaffolding rather than authored.

This is a **named exception, not a category.** It applies to `wip.png` and nothing else. Do not extend it to any other image on the reasoning that it also looks like a placeholder — that judgement is exactly what the preservation rule exists to prevent, and a screenshot that reads as low-value to you may be the only visual evidence of the item working. If an image is uninformative but is not `wip.png`, report it and leave it in place.

Removing `wip.png` does not substitute for the underlying finding: a README carrying only a title and a placeholder still fails About and Key Features/Use Cases. Fix those in the same pass, so the result is documentation rather than an emptier stub.

**Do:** hide irrelevant table columns; use high resolution; leave enough time between clicks in a GIF that the viewer can follow it. Blur sensitive data but keep non-sensitive data visible so the image stays useful.

**Don't:** show DataMiner card tabs unless they aid understanding, unnecessary open panels such as the Alarm Console, or blank space that a resized capture window would remove.

## Contact and support

**[ERROR]** MUST NOT include support contacts or team email addresses. Instead, direct users to the [DataMiner Support team](https://aka.dataminer.services/contacting-tech-support).
Owner email addresses belong in `manifest.yml`, not in the documentation.

## Comments

**[WARNING]** The text must not include HTML comments, as these will not be rendered correctly. 
