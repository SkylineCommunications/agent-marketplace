# Automation Security, Permissions, and Credentials

Security-sensitive Automation behavior is part of the runtime contract. Plan identity, permissions, credential access, logging, outputs, memory, and cleanup together. Never use a secret-shaped parameter or log line as a substitute for the Credentials Library or an approved deployment secret mechanism.

## Execution identity and permissions

Record the invocation context and the effective user/service identity. Verify that identity has the required Automation module permissions and access to every element, service, DOM, table, file, or Catalog/deployment operation the script performs.

- Do not assume the author, scheduler, trigger, or QAOps account is the runtime identity.
- Do not broaden permissions to hide an authorization failure; report the missing permission and target.
- Include the permission boundary in the Script Map and in live-test evidence.
- Test both the intended authorized path and the safe failure path when permissions are material to the behavior.

Authority: [DataMiner user permissions — Automation](https://aka.dataminer.services/data-miner-user-permissions).

## Credentials Library

From DataMiner 10.7.0/10.6.10 onward, a script can declare a `Credentials` entry in `DMSScript` and retrieve the configured set through the target-version `engine.GetCredential(...)` API. The script stores a reference; the secret remains in the Credentials Library.

- Use the documented Username and Password or Token credential types only when the target supports them.
- Resolve the declared credential by its verified name or ID and handle a missing result with a stable, non-secret failure.
- Never log the token, username, password, raw credential object, or request containing the secret.
- Never place a secret in a script parameter, memory file, `ExitSuccess`, `ExitFail`, information event, test output, manifest, or structured log.
- Treat a credential reference/ID as sensitive operational metadata when the surrounding workflow could reveal access.

Authority: [Using credentials in an Automation script](https://aka.dataminer.services/Automation-credentials).

## Data and output handling

- Validate external input and table keys before using them in element, DOM, file, or HTTP operations.
- Keep raw payloads and secret-bearing values out of `GenerateInformation`; use sparse `engine.Log` diagnostics only for non-sensitive details.
- Use stable failure text and log full exception diagnostics only where the approved runtime contract permits it.
- Clear or overwrite sensitive local variables as appropriate for the language/runtime, and do not persist secrets in memory files.
- For output collections, assert keys/cardinality/value invariants before success. Do not publish a success event that only proves the script returned.

## Locks, table keys, and cleanup

- Define the resource or table-key lock boundary before changing shared state. Acquire only the lock required by the operation, keep the critical section bounded, and release it on every exit path.
- Treat `NoKeyCaching` as a narrow table-mapping control, not a general consistency or concurrency switch.
- Avoid holding locks across UI waits, network calls, long polling, or subscript execution unless the target contract explicitly requires it.
- Make cleanup idempotent and safe after timeout, abort, detach, or partial completion. Never mask the original failure with cleanup exceptions.

## Security review evidence

For a security-sensitive script, the final record includes:

1. Target DataMiner and package versions.
2. Invocation identity and required permissions.
3. Credential declaration/reference and missing-credential behavior.
4. Secret-flow review for parameters, memory, logs, outputs, manifests, and test artifacts.
5. Lock/table-key boundary and cleanup behavior.
6. Build/analyzer result plus live-test evidence for the authorized and denied paths.
