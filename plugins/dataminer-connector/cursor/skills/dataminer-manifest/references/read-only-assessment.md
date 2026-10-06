# Read-only assessment boundary

REVIEW, INVESTIGATION, and the report-only validator collect evidence; approval of their
plans does not authorize repairs, suppressions, reformatting, helper generation, migration,
deployment, or changes on a live system. Finish with findings and explicit evidence gaps.
A failing diagnostic is not permission to enter an implementation repair loop.

## Diagnostics

Read source in place. If a build, validator, or test can write files, use a disposable copy
outside the reviewed repository and external output directories. Do not copy credentials or
reuse deployment targets. Inspect build/test hooks before execution; a disposable copy does
not authorize external side effects. Do not run live integration tests during assessment.
If safe execution is unavailable, report the relevant evidence as `UNVERIFIED` or `BLOCKED`.

Verify that the reviewed tree is unchanged, including untracked and generated files.
Do not discard pre-existing changes to obtain a clean baseline.

## Coordination

Manifest/log support remains opt-in. During read-only work, write only to explicitly supplied
paths outside the reviewed repository. Resolve paths and links before deciding they are
external; a symlink or junction into the repository is not an external path. Reject an
in-repository or ambiguous destination visibly, return coordination results in the response,
and continue safe source inspection. Never silently redirect output or create a new manifest.

## Transition to fixes

Return a recommended owner and verification step for each finding. The orchestrator or user
must approve a separate implementation transition before any writer changes source. Preserve
the original assessment and distinguish review completion from implementation or release readiness.
