# Common issues and remediation

> Severity legend: **[ERROR]** blocks publication · **[WARNING]** degrades quality · **[INFO]** informational guidance.

Use this table to turn a finding into a concrete fix. Every row is safe to apply as an edit; the "never remove" constraints in the Preservation rules below override any temptation to delete content in order to satisfy a rule.

## README findings

| Issue | Severity | Fix |
|-------|----------|-----|
| No `CatalogInformation/README.md` | ERROR | Create it with About plus Key Features or Use Cases at minimum. Never repurpose or symlink the repository-root or project README in its place |
| About section missing | ERROR | Add an About section summarizing the item's value and the problems it solves |
| Neither Key Features nor Use Cases present | ERROR | Add whichever fits the item — Key Features with up to 5 benefit-oriented specifics, or Use Cases with real-world scenarios |
| Support or contact details in documentation | ERROR | Remove them and link to the DataMiner Support team |
| Image path uses `~/images/` prefix | ERROR | Change to `./Images/filename.png` — fix the path, never remove the image |
| Key Features contains more than 5 items | WARNING | Trim to the 5 most differentiating features |
| Key Features describe generic DataMiner capabilities | WARNING | Replace with features specific to this item |
| About section contains excessive technical detail | WARNING | Move it to Technical Reference and link out instead |
| About section duplicates Key Features content | WARNING | Restructure: About gives the value overview, Key Features lists specifics |
| Use Cases missing for a non-trivial item that has Key Features | WARNING | Add specific, real-world scenarios showing the item's value |
| Prerequisites missing when dependencies exist | WARNING | Add concise prerequisites — DataMiner version for both FR and MR tracks inline, or an explicit link to release notes |
| Version information not discoverable in Prerequisites | WARNING | If there is a relevant minimum DataMiner version, state it inline, or link explicitly to release notes or versioned documentation — this only applies if the minimum DataMiner version is a currently supported version |
| README's stated version differs from the `.csproj`'s `MinimumRequiredDmVersion` (or similar) | ERROR | Correct the README to match the `.csproj` value — treat the `.csproj` as the source of truth |
| Equipment/connector list removed from Technical Reference | WARNING | Restore the list — concise supported-equipment lists must be preserved |
| Visuals missing | WARNING | Add up to 3 relevant, high-quality images or GIFs illustrating key features |
| `wip.png` placeholder present | WARNING | Remove the image and its markdown reference, and fix the README content it was standing in for. Applies to `wip.png` only |
| Visuals show sensitive or irrelevant data | WARNING | Blur sensitive data; hide irrelevant columns and close unnecessary panels |
| GIF longer than 10 seconds | WARNING | Trim or re-record to focus on one feature or action |
| More than 3 visuals | WARNING | Keep the 3 that best support the key points |

## Manifest findings

| Issue | Severity | Fix |
|-------|----------|-----|
| `manifest.yml` missing | ERROR | Create it — the item cannot be registered without metadata |
| No owner defined | ERROR | Add at least one owner |
| Owner is a team rather than an individual | WARNING | Report it. Suggest an individual only as a hint backed by repository evidence — never write an inferred name |
| Owner `name` is initials or a partial name | WARNING | Report it. If exactly one contributor matches, hint that person by name and ask the author to confirm |
| Owner `name` field contains an email address | WARNING | Move the address to the `email` field |
| No tags at all | WARNING | Add up to 5 user-centric or market-centric tags so the item surfaces in search |
| More than 5 tags | WARNING | Trim to the 5 most search-relevant tags |
| Tag repeats the item name or type | WARNING | Replace with a user-centric or market-centric tag |
| Tag is a general DataMiner term | WARNING | Replace with something that narrows the search |
| Tag is not in title case, or exceeds three words | WARNING | Rewrite in title case, at most three words |
| Type looks wrong for the item, or is `Custom Solution` | WARNING | Report only — never change `type`. Name the evidence and suggest a candidate; multi-project packages make the type unreliable to infer |
| `source_code_url` missing for a public item | WARNING | Add the public repository URL, typically the GitHub repo |
| `source_code_url` points at a private repo or 404s | WARNING | Correct it to a reachable public URL, or remove it if the source is not public |
| Item name uses technical jargon | WARNING | Report it and propose a user-facing candidate — never rewrite the name yourself |
| `title` is the repository, solution, or project name (e.g. an `SLC-` prefixed code) | WARNING | Report it as an unfilled scaffolding default. Propose a user-facing candidate grounded in what the item does, and check the README H1 for the same value |
| No `vendor_id` and no custom icon | INFO | Assign a vendor icon, or add `custom-icon` to the `Images` folder |
| Custom icon over 250 KB or not square | INFO | Resize to 96x96 or 128x128 PNG under 250 KB |

## Preservation rules

These override every other fix. Violating one turns a quality improvement into a regression, and they are the most common way an automated pass does damage.

- **Never edit a README outside `CatalogInformation/`.** Root and project READMEs are out of scope; report a problem there rather than fixing it.
- **Never delete an image** to resolve a broken path. Correct the path instead. The sole exception is a `wip.png` placeholder, which may be removed with its markdown reference — by that exact name only, never by judging another image to be "also just a placeholder".
- **Never delete the equipment/connector list** from Technical Reference while fixing an unrelated finding.
- **Never delete a section** to resolve a WARNING about its content. Rewrite the content.
- **Never invent** version numbers, licences, prerequisites, owners, or supported equipment. If a required fact is not in the repository, report the gap rather than filling it with a plausible guess.
- **Never change `type`, never write an owner name you inferred, and never rewrite the item's `title`**, unless a comment on your pull request specifically asks you to do so. For the purposes of the audit, all three are report-only. Hinting a candidate backed by named evidence is encouraged; writing it in is not. Each assigns identity — the item's type, its responsible person, the name users search for — and a wrong value in any of them is plausible enough to survive review.

## Reporting format

Group findings by severity, ERROR first. For each finding give the file, the section, the rule, and the proposed fix. Keep ERROR and WARNING fixes in the same pull request but make the severity visible in the PR description so a reviewer can triage quickly.

Report INFO findings in the PR description without changing files, unless the fix is unambiguous and the required facts are already present in the repository.

Separate **what was fixed** from **what needs a human decision**. Report-only fields (`type`, `owners[*].name`) and any gap you declined to fill belong in the second group, together with the evidence behind any hint you offered.

## Pull request naming

`Catalog hygiene: <Item Name> [dataminer-catalog-audit]`, using the human-friendly `title` from `manifest.yml`. For several items: `Catalog hygiene: <N> Catalog items [dataminer-catalog-audit]`. Branch: `catalog-hygiene/<item-slug>`.

The suffix marks the PR as machine-authored. The PR is opened with the user's credentials, so GitHub attributes it to them, and a reviewer would otherwise have no signal that the changes were generated rather than written. Open the body with an attribution line and add a `Co-authored-by: dataminer-catalog-audit <noreply@skyline.be>` commit trailer so the attribution outlives a squash merge. Full convention in the agent's step 6.
