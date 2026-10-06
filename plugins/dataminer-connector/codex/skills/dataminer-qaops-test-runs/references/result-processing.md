# QAOps Result Processing

Use this reference after `dataminer-qaops test-run-and-wait` completes and a result file was written with `-rf`.

## Rules

- Read the JSON file from the exact `-rf` path used in the command.
- Do not assume a stable schema; inspect the actual top-level properties.
- Prefer explicit result fields from the JSON over command-line text.
- If the JSON contains run IDs, UI links, package identifiers, failed test names, durations, or error messages, include those in the summary.
- If the process exits non-zero but the JSON exists, parse both the process output and JSON. The JSON may contain the actionable test failure.
- If the JSON cannot be parsed, report that clearly and keep the file path available for manual review.
- For runs that are supposed to validate newly added tests, grep the `LOG_LINES` array for the expected new test names: each published test appears as `TestName - Ok`, `TestName - NotExecuted: <reason>`, or `TestName - Fail: <message>`. Require explicit `Ok` rows; absence means the package was stale or per-test publishing was bypassed.
- If the new test names are absent from all available evidence, treat the run as invalid for those tests: rebuild a fresh bumped-version `.dmtest`, re-verify packaged discovery, and resubmit.
- **An overall `OK` / `PASSED` / `FINISHED OK` run with NO per-test rows (and no `pipeline_2.TestPackageExecution` row) is invalid evidence, not a pass.** It means the test runner matched/executed **zero** tests, or the publishing helper was bypassed — most often a packaging/discovery defect (the tests were not actually discoverable in the `.dmtest`; a byte-scan "discovery" hides this — see `dataminer-qaops-integration-testing` → `references/test-package-wiring.md` "Packaged MSTest Discovery Gate"). Do not report success. Fix discovery (run a real `dotnet vstest "<dll>" --ListTests` against the extracted assembly), rebuild a fresh bumped-version `.dmtest`, and resubmit.

## Pointing the User to the QAOps UI

Some diagnostics live **only** in the QAOps UI, not in the `-rf` JSON — in particular, the **Message** text of custom `Push-TestCaseResult` rows is frequently absent from `LOG_LINES` (which carries only the row name + outcome). When you need the user to read something from the UI:

- **Give them the exact deep link from the result JSON's `BUILD_URL` field.** It opens directly on the run. Do **not** send the user to the generic app URL (`https://qaops-skyline.on.dataminer.services/app/<id>`) with "go to Runs and find the run tagged …" instructions — that leaves users unable to locate the run (a real session ended with the user replying "I cannot find the run").
- Read `BUILD_URL` from the JSON (`(Get-Content "<result>.json" -Raw | ConvertFrom-Json).BUILD_URL`) and paste the full value. Also include the `-tags` value, the package version, and the run timestamp as a fallback in case the link needs authentication.
- Prefer not to depend on the UI at all: the durable fix is to make diagnostics reach the session automatically — richer **assertion messages inside the test** (which the un-gated publishing helper prints as `TestName - Fail: <message>`), not custom pipeline rows whose messages may never appear in `LOG_LINES`.

## Suggested Processing Flow

1. Confirm the result file exists.
2. Parse JSON.
3. Identify the overall run outcome/status.
4. Identify per-package and per-test outcomes when present.
5. Extract failure messages, stack traces, or log links when present.
6. For new-test verification runs, verify the `LOG_LINES` per-test rows name the new tests with `Ok` outcomes; never settle for the packaged-discovery gate alone when the run completed.
7. Report the target configuration (RC/Main/Feature), tag, packages, and result path.
8. For failures, suggest the next diagnostic step based only on actual result content.

## Reporting Format

Use a compact final report:

```text
QAOps <target> run <passed|failed|inconclusive>.
Packages: <package list>
Result file: <path>
Failures: <failed tests or "none">
New tests: <names with Ok/Fail rows from LOG_LINES, or "absent - run invalid for new tests">
Details: <run ID/link/messages if present>
```

Do not print the QAOps token.
