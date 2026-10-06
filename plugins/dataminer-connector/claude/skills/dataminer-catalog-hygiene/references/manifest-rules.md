# Catalog item metadata rules (`manifest.yml`)

> **Provenance** — Paraphrased from `SkylineCommunications/dataminer-docs`, `develop/best_practices/Catalog_Items/Best_Practices_When_Creating_Catalog_Items.md`. Extracted at commit `c94dcf5` and verified byte-identical to `main` on 2026-08-04. Human-readable source: <https://aka.dataminer.services/best-practices-creating-catalog-items>. The published page is authoritative if the two ever disagree.

Applies to `CatalogInformation/manifest.yml`.

## Name

**[ERROR]** MUST be present.

**[WARNING]** SHOULD be a user-friendly name — one that reads like a product, and lets someone browsing the Catalog tell whether the item solves their problem. Avoid technical terms that only the author understands.

**[WARNING]** SHOULD NOT be the repository, solution, or project name. Flag `title` when it matches or closely resembles any of:

- the repository name (`SLC-AS-LCAChangesOverview`)
- the `.csproj` / `.sln` filename (`SLC-GQIDS-GetApplicationInfo`)
- the `SLC-` prefix convention generally — `SLC-AS-`, `SLC-GQIDS-`, `SLC-C-` and similar

Those names are scaffolding defaults, and a `title` still carrying one is near-proof that the field was never filled in deliberately. They encode an internal type prefix and a repository slug — meaningful to the developer, opaque to the user deciding whether to deploy the item.

The README's H1 heading is subject to the same rule and SHOULD match `title`. In practice both get left at the scaffolded value together, so check them as a pair.

**Report the name, do not rewrite it.** Propose a candidate grounded in what the repository shows the item actually does, for example: "`title` is `SLC-GQIDS-GetApplicationInfo`, the project name. Consider something user-facing such as 'Application Info Data Source'."

Leave the choice to the author. The name is how users find and refer to the item; picking one is a product decision, and inventing a plausible product name is the same failure as inventing a version number.

## Type

**[ERROR]** MUST be present.

**[ERROR]** MUST be one of the Catalog's defined type names. Fetch the current list from `GET https://global.dataminer.services/api/public-catalog/v2-0/catalogs/categories` (the `types[].name` values across all categories). If that call isn't possible, fall back to this list: Connector, Ad Hoc Data Source, Data Transformer, Automation, User-Defined API, Dashboard, Visual Overview, ChatOps Extension, Product Solution, Standard Solution, Custom Solution, Learning & Sample, DevTool, System Health. A `type` outside this list is invalid on its own, independent of the checks below.

**[WARNING]** SHOULD be the correct type for the item. `Custom Solution` in particular is a catch-all that hides the item from meaningful browsing.

**Flag and hint only — never change the `type` value.** Report the mismatch, name the evidence, and leave the decision to the author.

A manifest describes the package as a whole, not one project inside it, so type cannot be judged from a single `.csproj`. Run the `project-type-identification` skill, scoped to this Catalog item, to build that inventory before judging `type`. That skill's resolved types are project-level labels (e.g., `Automation script`, `Interactive automation script`, `ChatOps operator`) and don't always match a Catalog type name verbatim — map each one to its closest Catalog type (e.g., both automation script variants → `Automation`, `ChatOps operator` → `ChatOps Extension`) before comparing.

- **One Catalog type across the whole inventory** → `type` should match it. A mismatch, including `Custom Solution`, is a strong finding — name the projects backing it.
- **Mixed types in the inventory** → the package genuinely combines components; a broad type such as `Custom Solution` is likely correct. Only flag it if no broad solution type (`Standard Solution`, `Custom Solution`, `Product Solution`, `Learning & Sample`) fits.
- **Exactly one project, not itself a `Package`/solution project** → `type` should match that project's mapped Catalog type directly.

If the skill can't produce an inventory (no recognizable projects), fall back to weaker evidence in this order: a `<DataMinerType>` property (only when it's the sole project), then the repository/solution layout, then the `SLC-` naming prefix (weak, can be stale).

Example: "`type` is `Custom Solution`, but the inventory shows a single project resolved as Ad hoc data source — consider `Ad Hoc Data Source` if the package contains nothing else."

## Tags

Tags exist to expose the item to relevant searches. They are not a description.

**[WARNING]** At least one tag SHOULD be present. An item with no tags is discoverable only by users who already know its name, which defeats the purpose of publishing it.

**[WARNING]** MUST use at most **5 tags**, and at most **three words** per tag, in [title case](https://aka.dataminer.services/TitleCase).

**[WARNING]** Tags MUST NOT repeat the item's name, MUST NOT repeat the item's type, and MUST NOT be general DataMiner terms such as "DataMiner".

**[INFO]** User-centric or market-centric tags are preferred. Avoid uncommon abbreviations. Avoid unnecessary plurals, for example: "Source", not "Sources".

## Icon

**[INFO]** Assign a vendor icon via the `vendor_id` field to catch the user's attention.
Reach out to your technical contact if you need help setting one up.

**[INFO]** A custom icon overrules the vendor icon: place an image named `custom-icon` in the `Images` folder. The vendor name still shows in the item's sidebar. PNG is recommended; `.jpg`, `.jpeg`, `.bmp`, `.tif`, `.tiff`, and `.webp` are also supported. Use a square image of 96x96 or 128x128 pixels, of at most **250 KB**.

Images referenced from `README.md` are exempt from that 250 KB limit — it applies only to vendor logos and custom icons.

## Ownership

**[ERROR]** At least one owner MUST be present.

**[WARNING]** The owner SHOULD be an individual person, not a team.

| Field | Rule |
|-------|------|
| `name` | Full name of the owner. **MUST NOT** contain the email address. |
| `email` | Email address of the owner. Recommended, though not currently surfaced in the Catalog UI. |
| `url` | A URL associated with the owner, such as a GitHub account URL. |

Multiple owners are allowed — add further entries to the list.

### Hinting a likely owner

Never write an owner name you inferred. But when the repository points strongly at one person, say so, so the reviewer can confirm it in seconds instead of having to look it up.

Offer a hint only when the evidence is genuinely narrow:

- the repository has a single contributor, or one author holds the overwhelming majority of commits — check with `git shortlog -sne` or `gh api repos/<owner>/<repo>/contributors`
- an existing `owners` entry gives initials or a partial name that matches exactly one contributor
- a `CODEOWNERS` file names a specific individual

Present it as a question, attributed to its evidence, and never as a fix to apply: *"`owners[0].name` is `'NVC'`. The only contributor to this repository is Nejra Velic — is that the intended owner?"*

Stay silent when the repository has several active contributors, when the hint rests only on a commit that touched the manifest, or when the initials match more than one person. A wrong owner is worse than a missing one: it is plausible enough to survive review and it assigns responsibility to someone who never agreed to it.

## Documentation and source links

**[INFO]** `documentation_url` points to detailed technical documentation, keeping the Catalog description high-level. For substantial Skyline solutions this is typically under DataMiner Solutions; for smaller items, markdown pages in the public source repository.

**[INFO]** For Skyline employees, when `documentation_url` points to external documentation, an `aka.dataminer.services` link should be preferred over a direct `docs.dataminer.services` link, since shortened links can be maintained when documentation moves. Propose this as a suggestion rather than changing the URL automatically. Links can be shortened at <https://aka.dataminer.services/admin>. This does not apply to `source_code_url`, which may properly remain an absolute URL to the source repository.

**[WARNING]** `source_code_url` SHOULD be present and point to a reachable public location — typically the item's GitHub repository. Omitting it when the source is public hides a useful signal from users evaluating the item, and a link that 404s or points to a private repository is worse than none at all.
