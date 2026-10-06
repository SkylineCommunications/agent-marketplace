# Authoring the MSTestV2 Integration Test Project

> **Part of the `dataminer-qaops-integration-testing` skill.** Load that `SKILL.md` first for the high-level workflow, the authoring-vs-migrating decision, the System State Preflight, and the Failure-Diagnostics rules. **Verifying anything on a real DataMiner always goes through QAOps** (`dataminer-qaops` -> `dataminer-qaops-test-runs`); never local `dotnet test`, and never a local `C:\Skyline DataMiner` install.

## Integration Test Project Naming

New integration test project names must clearly be integration tests. Choose names that satisfy this check:

```bash
[[ "$project" != *"tests"* || "$project" == *"integrationtests"* || "$project" == *"integration.tests"* ]]
```

Practical rule: include the lowercase token `integrationtests` or `integration.tests` in the project name unless the repository has a stricter existing convention.

Examples:

- `MyConnector.integrationtests`
- `MyConnector.qaops.integrationtests`
- `Company.Product.integration.tests`

## Create the MSTestV2 Project

Prefer the existing solution's target framework and package management style. For a new MSTest project:

```bash
dotnet new mstest -n "MyConnector.integrationtests" -o "MyConnector.integrationtests"
dotnet sln "<solution-path>" add "MyConnector.integrationtests/MyConnector.integrationtests.csproj"
```

If the repository uses `.slnx`, use the solution tooling supported by that repository.

> `dotnet new mstest` targets the newest .NET TFM (e.g. `net10.0`). Retarget the project to `net48` with `<PlatformTarget>x86</PlatformTarget>` (next section) **immediately after creation** — the DataMiner packages and the QAOps runtime require it.
>
> When retargeting, **leave the `MSTest` metapackage reference exactly as the template generated it** (a single `<PackageReference Include="MSTest" ... />`). Do not split it into `MSTest.TestAdapter`/`MSTest.TestFramework` — that drops `Microsoft.NET.Test.Sdk` and breaks net48 binding redirects (see "Required `.csproj` Settings").

## Required `.csproj` Settings

Add x86 platform target:

```xml
<PropertyGroup>
  <PlatformTarget>x86</PlatformTarget>
</PropertyGroup>
```

Add these packages:

```xml
<ItemGroup>
  <PackageReference Include="Skyline.DataMiner.Core.DataMinerSystem.Common" />
  <PackageReference Include="Skyline.DataMiner.Files.SLNetTypes" />
  <PackageReference Include="Skyline.DataMiner.CICD.Tools.WinEncryptedKeys.Lib" />
</ItemGroup>
```

`Skyline.DataMiner.Files.SLNetTypes` provides the `Skyline.DataMiner.Net` connection types (`Connection`, `ConnectionSettings`, ...) used by the setup template at compile time; the matching runtime assemblies are present on the QAOps DataMiner.

Package facts (verified — do not rediscover):

- `Skyline.DataMiner.Net` is **not** a NuGet package; `dotnet add package Skyline.DataMiner.Net` always fails. Use `Skyline.DataMiner.Files.SLNetTypes` instead.
- Never reference or reflection-load DLLs from a local `C:\Skyline DataMiner\Files` installation — that causes assembly-identity conflicts and is not portable to QAOps.
- Both `Skyline.DataMiner.Core.DataMinerSystem.Common` and `Skyline.DataMiner.Net` define a `ConnectionSettings` type. Fully qualify `Skyline.DataMiner.Net.ConnectionSettings.GetConnection(...)` to avoid CS0104 ambiguity.

For the test framework, always add the **single `MSTest` metapackage** — never split it. The `MSTest` metapackage transitively pulls everything a net48 VSTest integration test project needs: `Microsoft.NET.Test.Sdk`, `MSTest.TestAdapter`, `MSTest.TestFramework`, and the analyzers.

```xml
<ItemGroup>
  <PackageReference Include="MSTest" />
</ItemGroup>
```

> **CRITICAL (verified — omitting `Microsoft.NET.Test.Sdk` cost ~5 QAOps runs):** `dotnet new mstest` already ships the `MSTest` metapackage — **keep it as-is**. Do **not** "tidy" it into explicit `MSTest.TestAdapter` + `MSTest.TestFramework` references, because that silently drops `Microsoft.NET.Test.Sdk`. On net48, `Microsoft.NET.Test.Sdk` is what enables `AutoGenerateBindingRedirects` and emits the `<TestProject>.dll.config` containing the assembly **binding redirects** the VSTest host needs. Without it, no `.dll.config` is generated, and at runtime `Skyline.DataMiner.CICD.Tools.WinEncryptedKeys.Lib` (which references `System.Security.Cryptography.ProtectedData, Version=9.0.0.0`) cannot bind to the actual shipped `ProtectedData` assembly (e.g. `9.0.0.6`). `AssemblyInitialize` then throws `System.IO.FileLoadException: ... manifest definition does not match the assembly reference (0x80131040)` at the first `Keys.TryRetrieveKey(...)` call, and every QAOps run fails before any test runs.
>
> Fingerprint check after building: confirm `bin\<config>\net48\<TestProject>.dll.config` exists and contains a `System.Security.Cryptography.ProtectedData` `bindingRedirect`. Its absence means `Microsoft.NET.Test.Sdk` is missing — re-add the single `MSTest` metapackage. (If the repo uses the `MSTest.Sdk` project SDK instead, that is also fine and self-contained; the rule is only: do not hand-assemble a partial classic package set.)

Keep versioning consistent with the repository. If central package management is used, add versions there rather than inline. Add packages with `dotnet add package <name>` — hand-written `<PackageReference>` entries without a `Version` attribute fail restore with `NU1015` (verified).

## MSTestV2 Test Identity Checklist

For MSTestV2 integration projects, make the test identities explicit before packaging:

- Verify the project references the single `MSTest` metapackage (or the `MSTest.Sdk` project SDK). On net48, a hand-split package set that omits `Microsoft.NET.Test.Sdk` silently drops binding-redirect generation and breaks `AssemblyInitialize` at runtime (see "Required `.csproj` Settings").
- Verify every new test class/method has the MSTest attributes required for discovery, typically `[TestClass]` and `[TestMethod]`.
- **Categorize every integration test with `[TestCategory("IntegrationTest")]`** (mandatory for connector integration tests). Apply it at the test **class** so all `[TestMethod]`s inherit it — MSTest aggregates class-level and method-level categories. This lets QAOps/CI select the integration tests with `--filter TestCategory=IntegrationTest`, and lets a local **unit-test** run exclude them (`--filter TestCategory!=IntegrationTest`) so tests that need a real DataMiner do not run — and fail — outside QAOps. Feature-specific categories (e.g. `[TestCategory("IDmsElementCreation")]`) are **additive**, never a replacement for `IntegrationTest`.
- Record the expected class/method display names or fully qualified names for every newly added or changed test. The QAOps run is not valid until those names are discoverable from the assembly extracted out of the exact `.dmtest`.

## Real DataMiner Setup

Use `IDms` from `Skyline.DataMiner.Core.DataMinerSystem.Common` to manipulate localhost DataMiner in QAOps.

Required setup:

- Host: `localhost`
- Connection timeout: `120000`
- `ClientApplicationName`: `VSTEST.CONSOLE.EXE`
- Username key: `QAOpsDataMinerUser`
- Password key: `QAOpsDataMinerPassword`
- Clear subscriptions using a stable subscription set ID such as `IntegrationTests`

Use the full template in `dataminer-qaops-integration-testing/references/dms-test-setup.md`.

Official API docs:

```text
https://docs.dataminer.services/develop/api/types/Skyline.DataMiner.Core.DataMinerSystem.Common.html
```

## Writing Tests

Use `DmsTestSetup.Dms` from test methods to inspect or manipulate the local DataMiner.

Common operations (all verified against the official API docs):

| Operation | API |
|-----------|-----|
| Run an Automation script | `dms.GetScript(name).Execute(paramValues, dummyValues, new DmsAutomationScriptRunOptions())` |
| Find elements by protocol | `dms.GetElements()` filtered on `element.Protocol.Name` |
| Assert element state | `element.State` against `ElementState` (`Active`, `Paused`, `Stopped`, `Error`, ...) |
| Start/stop an element | `element.Start()` / `element.Stop()` |
| Create a test element | `agent.CreateElement(new ElementConfiguration(dms, name, protocol))` |
| Read parameters/tables | `element.GetStandaloneParameter<T>(pid)` / `element.GetTable(pid)` |

> **Canonical example**: `dataminer-qaops-integration-testing/references/example-automation-script-test.md` — full worked test that runs an Automation script and asserts all elements of a protocol are stopped, including test-element creation, the mandatory poll-wait pattern for asynchronous state changes, and cleanup. Follow it for any script/element behavior test.

Rules:

- **Tag every integration test `[TestCategory("IntegrationTest")]`** — put it on the test class so all methods inherit it (see "MSTestV2 Test Identity Checklist"). Add feature-specific `[TestCategory]`s on top for scoped `-TestFilter` runs.
- Keep tests deterministic and independent.
- Element/script operations are asynchronous — never assert immediately; poll with a timeout (see the canonical example).
- Clean up DataMiner state that the test creates.
- Prefer explicit assertions on DataMiner state over only checking that operations did not throw.
- **Never assume a clean system** — start every test with the System State Preflight (master `SKILL.md` → "System State Preflight", helpers in `references/system-state-preflight.md`).
- **Never require a populated system either** — the same `.dmtest` must pass on an empty DataMiner that contains only what the Test Package installs. Arrange must create (or duplicate) its fixture when nothing exists; pre-existing baseline elements are never a precondition (Empty-System Contract — see the master `SKILL.md` → "System State Preflight").
- Assertions must assert the current system state, not just the operation outcome: include which element (identity), which protocol version, and what else exists in every failure message.
- Use SLNet calls only when `IDms` does not expose the needed functionality.
- Do not invent `IDms` members — load `dataminer-idms` for the verified API cheatsheet; verify anything beyond it against the official API docs.
- Do not hardcode QAOps credentials. They are retrieved through encrypted keys during setup.
- **Never use local `dotnet test` as the verification step.** The QAOps credentials (`QAOpsDataMinerUser`/`QAOpsDataMinerPassword`) only exist inside the QAOps-provisioned environment; locally the connection fails with authentication errors by design. Validate locally with a build only, then run via QAOps.
- **One behavior per test, self-explanatory name.** QAOps shows one result row per test — a single combined test hides what was actually verified. Split scenario families into small named tests (e.g. `Create_DefaultSerialConnection_ReturnsExpectedConnectionType` per connection family) and share Arrange via helpers. A common method-name prefix or `[TestCategory]` also makes scoped `-TestFilter` runs trivial (user-requested convention, applied in a real session).
- **Flaky tests get a permanent `[Ignore("Flaky on QAOps: <symptom>")]`** once the same unrelated failure reproduces across targets (e.g. on RC, Main, AND Feature). Do not let a known-flaky test invalidate future runs; record the reason in the attribute message so the `NotExecuted` row in QAOps is self-explanatory. Ask the user before ignoring anything that might be a real regression.

MSTest v4 gotchas (verified in a real session — these cost build-fix round-trips):

- `Assert.ThrowsException<T>` no longer exists — use `Assert.ThrowsExactly<T>(...)` (or `Assert.Throws<T>` for subclass-tolerant checks).
- `ElementState` may be ambiguous between `Skyline.DataMiner.Core.DataMinerSystem.Common` and SLNetTypes namespaces — add an alias: `using ElementState = Skyline.DataMiner.Core.DataMinerSystem.Common.ElementState;`.
- On `MSTest.Sdk` projects, plain `dotnet build <proj>` / `dotnet test <proj>` work, but some classic flags (`-v:q` placement, `--minimum-expected-tests`) behave differently — keep local validation to a plain build.

