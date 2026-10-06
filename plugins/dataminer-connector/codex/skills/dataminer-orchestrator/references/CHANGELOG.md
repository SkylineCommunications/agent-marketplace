# dataminer-connector-orchestrator — Archived Changelog (v1.1–v2.9)

Versions v3.0 and later are in `agents/dataminer-connector-orchestrator.agent.md`.

| Version | Date | Changes |
|---------|------|---------|
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
