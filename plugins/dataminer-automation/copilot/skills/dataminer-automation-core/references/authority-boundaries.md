# Automation Authority Boundaries

This map is the routing contract for Automation work. Agents own workflow and decisions; the
specialist skills own normative XML, API, runtime, host, security, test, and lifecycle facts.

| Concern | Sole authority | Consumers should do |
|---|---|---|
| DMSScript grammar, IDs, actions, project markers, and pinned XSD | `dataminer-automation-xml` and `references/dmsscript-reference.md` | Validate against the pinned XSD; do not recreate schema grammar in agents |
| Target versions, IAS lifecycle, invocation, inputs/outputs, locks, table keys, and subscripts | `dataminer-automation-core/references/version-compatibility.md` and `invocation-and-entry-points.md` | Record task-specific choices and link to the relevant rule |
| IEngine API presence/absence, Run-thread behavior, errors, information events, and diagnostics | `engine-api-overview.md` and `runtime-safety-and-errors.md` | Verify against the selected package; do not invent or copy API lists into agents |
| Identity, permissions, Credentials Library, secret flow, and cleanup | `security-permissions-credentials.md` | Keep secrets out of parameters, memory, output, logs, manifests, and tests |
| C# implementation patterns and package selection | `dataminer-automation-scripting`, `dataminer-nugets`, and `dataminer-sdk` | Load the authority before authoring; keep agent guidance procedural |
| IAS widgets and host behavior | `dataminer-interactive-automation` and `references/ias-hosts-and-lifecycle.md` | Select the host and Toolkit version before authoring or testing |
| Unit, QAOps, DIS, release, deployment, and JSON execution routes | `dataminer-automation-unit-testing`, `dataminer-qaops-integration-testing`, `dataminer-dis`, `dataminer-sdk`, and `dataminer-execute-automation-script` | Keep each verification stage separate and artifact-bound |

When sources disagree, prefer the pinned schema/package evidence and record the conflict in the
owning reference. Agents may summarize a rule, but a summary must point to the owner and must not
create a competing default.
