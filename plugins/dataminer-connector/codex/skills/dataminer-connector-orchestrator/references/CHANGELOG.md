# dataminer-connector-orchestrator — Archived Changelog (v1.1–v3.20)

Versions v3.21 and later are in `agents/dataminer-connector-orchestrator.agent.md`.

| Version | Date | Changes |
|---------|------|---------|
| 3.20 | 2026-10-23 | Added Phase 1 Session & Branch Naming Gate to detect auto-generated worktree placeholder branches and rename them semantically via rename_branch and rename_session before planning or editing code. |
| 3.19 | 2026-10-23 | Added planning and delegation guidance for multi-file `QAction_1` (`precompile`) project structure, `ProjectReference`, and `dllImport` wiring. |
| 3.18 | 2026-10-22 | Enforced official `QAction_Helper.cs` generation before QAction authoring when planned QActions consume `Parameter.*`, and prohibited manual `QAction_Helper.cs` synthesis. |
| 3.17 | 2026-10-21 | Target minimum DataMiner version is optional during intake for new connectors; dynamically resolved from official Software Support Lifecycles docs. |
| 3.16 | 2026-10-20 | Streamlined upfront skill loading by deferring low-level syntax and reference manuals to specialist subagents while retaining architectural and planning knowledge; kept artifact edits behind assigned specialists. |
| 3.15 | 2026-10-16 | Enforced .NET Framework 4.8 (`net48`) and C# 7.3 for connector QActions and added a hard compilation gate forbidding non-compiling code from being returned to the user or committed/pushed to a PR. |
| 3.14 | 2026-10-12 | Added version bumping and VersionHistory synchronization rules to FEATURE, BUGFIX, and NEW connector plans, task routes, and validation gates. |
| 3.13 | 2026-10-07 | Made IntegrationID, VendorOID, and DeviceOID optional; default to DMS-DRV-XXXX, 1.3.6.1.4.1.8813.2.XX, and XX when omitted. |
| 3.12 | 2026-10-07 | Renamed subagent IDs and display names to prefix with dataminer-connector and updated skill references. |
| 3.11 | 2026-10-06 | Added QAOps support escalation guidance directing users to support.boost@skyline.be on infrastructure or execution issues. |
| 3.10 | 2026-10-05 | Mandated discrete parameters with numeric backends for pre-known values to enable alarming and trending while keeping clear operator displays. |
| 3.9 | 2026-10-02 | Streamlined orchestrator workflow by delegating lifecycle ownership, task-specific delegation, and final-gate details to task-routes reference; archived v1.1–v2.9 changelog. |
| 3.8 | 2026-10-02 | Added SNMP write/polling planning and XML gates. |
| 3.7 | 2026-09-28 | Restored readable display names with matching subagent and handoff targets; retained stable file IDs and client-aware invocation guidance. |
| 3.6 | 2026-09-27 | Enforced exclusive XML ownership, report-only review routes, and task-specific completion gates; aligned invocation names. |
| 3.5 | 2026-09-17 | Added the Connector authority-boundaries map so schema, validator, API, runtime, and lifecycle facts stay with their owners; added connector help/TOC validation and explicit lifecycle handoff evidence across build, packaging, QAOps, Catalog publication, deployment, and post-deploy verification. |
| 3.4 | 2026-09-17 | Added testing, packaging, release, deployment, and migration routes plus explicit artifact ownership, Connector Map, sequencing, retry, and final-gate contracts. |
| 3.3 | 2026-09-17 | Extended the conditional QAction helper decision to planned generated-member consumers and helper-free projects. |
| 3.2 | 2026-09-17 | Added task-specific target/version intake, source-aware VendorOID handling, conditional QAction helper generation, and the confirmed unchanged TOON policy. |
| 3.1 | 2026-09-17 | Added first-release review context collection and a structured profile/evidence handoff to `dataminer-connector-reviewer`; replaced the removed connector guide URL with the current getting-started page. |
| 3.0 | 2026-07-17 | Added a clean-XML gate: connector `protocol.xml` must not receive explanatory, TODO, debug, or design-note comments; copyright and justified `SuppressValidator` comments remain allowed. |
| 2.9 | 2026-07-02 | Build quality gate no longer hardcodes `.sln` — uses whichever solution file extension (`.sln` or `.slnx`) the connector actually has. Verified live that `dotnet build` and the validator CLI both work identically against `.slnx`. |
| 2.8 | 2026-06-28 | Integrated `dataminer-github-example-finder`: added as skill authority, added example-search step in Phase 2 (NEW) and Phase 3, added "Find Examples & Best Practices" handoff. |
| 2.7 | 2026-05-28 | Added Step 8 (Format & Order XML) to Phase 4 pipeline and "Format & Order XML" handoff to xml-author. Replaces removed `fix-xml` CLI as a final mechanical cleanup pass. |
| 2.6 | 2026-05-27 | Removed EcsAgent CLI dependency. Replaced `fix-xml` and `validate-xml` gates with agent-driven schema verification using `dataminer-protocol-xml-reference`. Replaced `fix-csharp` with prevention-only (rules in `dataminer-qaction`). Replaced `validate-build` CLI with plain `dotnet build --warnaserror`. Removed `dataminer-xml-fixer` subagent. |
| 2.5 | 2026-05-24 | Phase 5 "Validate": converted bulleted decision rules to an explicit Decision matrix (severity × finding kind → route + re-validate). |
| 2.4 | 2026-05-14 | Added `dataminer-dis` authority for code-relevant Visual Studio workflows and compare/MCC planning. |
| 2.3 | 2026-05-14 | Added `dataminer-sdk` authority and SDK-first planning/implementation rules. Deduplication: replaced 9-line Run Coordination boilerplate with compact 3-line directive pointer to `dataminer-manifest` and `dataminer-logging` skills. |
| 2.2 | 2026-04-15 | Added structural verification gate after XML authoring (Step 1b). Strengthened timeout fallback with CRITICAL severity and concrete steps. Added inline-authoring heuristic for large NEW connector tasks (3+ tables). |
| 2.1 | 2026-04-14 | Added Run Coordination section and manifest/logging integration in Phase 4 and Phase 6. |
| 2.0 | 2026-04-13 | Replaced inline Connector Map template with pointer to shared planning material. |
| 1.3 | 2026-04-09 | Added mechanical XML fix step between XML authoring and XML validation (later removed in v2.6). |
| 1.2 | 2026-03-30 | Added `agents` frontmatter for subagent delegation. Added `execute` to tools. Added handoffs with `send: true` for automatic workflow transitions. |
| 1.1 | 2026-03-27 | Initial release. |
