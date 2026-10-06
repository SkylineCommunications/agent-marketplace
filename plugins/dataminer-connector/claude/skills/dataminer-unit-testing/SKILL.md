---
name: dataminer-unit-testing
description: 'Unit testing for DataMiner connector QActions using SLProtocolMock: test project setup, Arrange/Act/Assert patterns, SLProtocolMock and SLProtocolMock<T>, IAsserter interface, table assertions, parameter verification, Moq integration, and Fluent Assertions. Use when writing or setting up unit tests for connector QActions.'
argument-hint: 'Describe what to test: e.g. "write tests for QAction 100 JSON parsing", "set up test project for my connector"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-02
  version: 1.5
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this distribution: `dataminer-automation-unit-testing`. If the task needs one, report the missing prerequisite and obtain it or explicitly narrow the task; do not claim the unsupported route is complete.
> - `dataminer-automation-unit-testing`: Scope boundary; mocked IEngine tests for Automation scripts route to dataminer-automation-unit-testing.

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.5 | 2026-10-02 | Corrected the package ID to `Skyline.DataMiner.Utils.UnitTestingFramework.Protocol` and documented its GitHub Packages source, version pinning, `extern alias` for several QActions, the optional `protocol.xml` path, and the CI NuGet-source caveat. |
| 1.4 | 2026-09-14 | Added helper-free SLProtocolMock setup and made generated helper references conditional. |
| 1.3 | 2026-06-10 | Added scope boundary: real DataMiner/QAOps integration tests route to `dataminer-qaops-integration-testing`. |
| 1.2 | 2026-03-28 | Initial release. |

# DataMiner Connector Unit Testing

Covers writing unit tests for QActions using the `Skyline.DataMiner.Utils.UnitTestingFramework`. Load `dataminer-connector-core` and `dataminer-qaction` alongside for conventions and API reference.

> **Scope boundary**: this skill is for **local, mocked connector QAction** tests only, and the `.Protocol` package mocks `SLProtocol`, so it applies to connectors and nothing else. For **Automation scripts** (mocked `IEngine` with Moq) load `dataminer-automation-unit-testing`. There is no unit-test framework for solutions or packages: validate them and test them on a real DataMiner. For tests that must run on a **real DataMiner** — Automation script behavior, element/service state, end-to-end regression tests, anything QAOps — load `dataminer-qaops` and `dataminer-qaops-integration-testing` instead. SLProtocolMock cannot test Automation scripts or live elements.

> **Paired agent**: `dataminer-test-writer` — owns workflow, test coverage strategy, and output format. This skill owns SLProtocolMock API, test patterns, and assertion examples. Keep shared concepts (Arrange/Act/Assert, mock setup) in sync.

## Reference Files

| Topic | Reference File |
|-------|---------------|
| IAsserter API, Arrange/Act/Assert examples, Fluent Assertions, Moq integration | `dataminer-unit-testing/references/test-patterns.md` |

---

## Framework Overview

- **NuGet**: `Skyline.DataMiner.Utils.UnitTestingFramework.Protocol`, published to the Skyline **GitHub Packages** registry (`https://nuget.pkg.github.com/SkylineCommunications/index.json`), not nuget.org
- **Namespace**: `Skyline.DataMiner.Utils.UnitTestingFramework.Protocols`
- **GitHub**: https://github.com/SkylineCommunications/Skyline.DataMiner.Utils.UnitTestingFramework
- **Foundation**: Built on Moq's `Mock<T>` — the mock stores parameter and table data internally
- **Philosophy**: Behavior-driven — test outputs (resulting data state), not implementation details (specific method calls)

---

## Test Project Setup

### 1. Create the Test Project

Add an MSTest project to the connector solution:

```bash
dotnet new mstest -n "QAction_Tests" -o QAction_Tests
dotnet sln add --solution-folder Tests QAction_Tests/QAction_Tests.csproj
```

> For `.slnx` solutions: add `<Project Path="QAction_Tests/QAction_Tests.csproj" />` inside a `<Folder Name="/Tests/">` element (create the folder element if it doesn't exist yet).

### 2. Add NuGet References

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net48</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Skyline.DataMiner.Utils.UnitTestingFramework.Protocol" Version="1.0.4" />
    <PackageReference Include="Skyline.DataMiner.Dev.Protocol" Version="10.4.*" />
    <PackageReference Include="MSTest.TestAdapter" Version="3.6.4" />
    <PackageReference Include="MSTest.TestFramework" Version="3.6.4" />
    <PackageReference Include="FluentAssertions" Version="7.2.0" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\QAction_1\QAction_1.csproj" />
    <!-- Add references to all QAction projects under test -->
  </ItemGroup>
</Project>
```

Add `<ProjectReference Include="..\QAction_Helper\QAction_Helper.csproj" />` only when the QAction/tests consume generated helper types.

**Package details**

- The ID is exactly `Skyline.DataMiner.Utils.UnitTestingFramework.Protocol`. Pin a stable release (1.0.4 at the time of writing) and avoid prerelease builds (`-prerelease` tags).
- It is not on nuget.org. Configure the GitHub Packages source at **user level** (`dotnet nuget add source`), not in a repository `nuget.config`. CI normally injects its own authenticated source, and a second declaration of the same source can fail the "Setup NuGet sources" step with "source already added". Check the CI workflow before adding a `nuget.config`.
- MSTest 4.x is not recognized by FluentAssertions 7.2.0. Keep MSTest on the 3.x line (for example 3.6.4) while staying on FluentAssertions 7.2.0.
- Every QAction declares `public static class QAction` in the global namespace. When one test project references several QAction projects, give each `ProjectReference` an `<Aliases>` value and use `extern alias` in the test files to avoid the type collision.
- `new SLProtocolMock()` locates `protocol.xml` itself. Pass the path (`new SLProtocolMock(path)`) when the file is not next to the test output.
- The project may need to opt out of repository-wide analyzers or rulesets (for example `RunAnalyzers` set to `false`) if the QAction projects use a strict ruleset the test project should not inherit.

### 3. Ensure protocol.xml is Accessible

`SLProtocolMock` auto-locates and parses `protocol.xml` during initialization. The file must be present relative to the test project output directory. If needed, add a copy step:

```xml
<ItemGroup>
  <None Include="..\protocol.xml" CopyToOutputDirectory="PreserveNewest" Link="protocol.xml" />
</ItemGroup>
```

> **Important**: Use `FluentAssertions` version 7.2.0 or earlier for free commercial use (v8.0.0+ requires a commercial license).

---

## Core Classes

### SLProtocolMock (Non-Generic)

Basic mock providing `SLProtocol` interface:

```csharp
using Skyline.DataMiner.Utils.UnitTestingFramework.Protocols;

var mock = new SLProtocolMock();
SLProtocol protocol = mock.Object;
```

- `mock.Object` exposes the `SLProtocol` instance — all standard protocol methods work (GetParameter, SetParameter, FillArray, etc.)
- Data is stored in internal structures (not on a real DataMiner Agent)
- Automatically parses `protocol.xml` to understand parameter and table definitions

### SLProtocolMock\<T\> (Generic)

For typed access via generated `SLProtocolExt`:

```csharp
using Skyline.DataMiner.Scripting;
using Skyline.DataMiner.Utils.UnitTestingFramework.Protocols;

var mock = new SLProtocolMock<ConcreteSLProtocolExt>();
SLProtocolExt protocol = (SLProtocolExt)mock.Object;
```

- `T` must implement `SLProtocol` — use generated `ConcreteSLProtocolExt` only when the helper project is present and current
- Enables typed property access (e.g., `protocol.Devicename`, `protocol.channelstable`)
- Same internal storage and assertion capabilities as non-generic version

---

## IAsserter & Test Patterns

Access `mock.Assert()` for fluent validation: `.Parameter(pid)` for scalar values, `.Table(tablePid).AllRows()` for table contents, `.Table(tablePid).Row<T>(key)` for typed rows. Follow the Arrange/Act/Assert pattern with a fresh `SLProtocolMock` per test.

> **Full reference**: `dataminer-unit-testing/references/test-patterns.md` — IAsserter API methods, 5 complete Arrange/Act/Assert examples (parameter, table fill, typed row, empty/error response, pre-populated table), Fluent Assertions integration, and Moq integration.

---

## Test Organization

### File Structure

```
QAction_Tests/
├── QAction_Tests.csproj
├── QAction100Tests.cs       # Tests for QAction 100
├── QAction200Tests.cs       # Tests for QAction 200
├── TestData/
│   ├── valid_response.json  # Sample test data files
│   └── error_response.json
└── Helpers/
    └── TestDataHelper.cs    # Shared test setup utilities
```

### Naming Convention

```csharp
[TestMethod]
public void MethodName_Scenario_ExpectedResult()
{
    // e.g., Run_ValidJsonResponse_FillsTableWith3Rows
    // e.g., Run_EmptyResponse_ClearsTable
    // e.g., Run_MalformedJson_LogsErrorAndReturns
}
```

### Shared Test Data

```csharp
internal static class TestDataHelper
{
    internal static string LoadTestData(string fileName)
    {
        string path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "TestData", fileName);
        return File.ReadAllText(path);
    }
}
```

---

## Running Tests

```bash
dotnet test --project QAction_Tests/QAction_Tests.csproj
```

Or with verbosity and filtering:

```bash
dotnet test --project QAction_Tests/QAction_Tests.csproj --verbosity normal --filter "FullyQualifiedName~QAction100"
```

---

## Best Practices

- **Test every QAction entry point** — at minimum: valid input, empty input, malformed input.
- **Test table operations**: verify row count, key presence, column values after FillArray/FillArrayNoDelete.
- **Test edge cases**: empty tables, single row, max row scenarios, null values.
- **Keep tests independent** — create a fresh `SLProtocolMock` in each test method.
- **Use test data files** for large JSON/XML payloads rather than inline strings.
- **Assert outputs, not calls** — verify the resulting parameter/table state, not which protocol methods were invoked.
- Refresh `QAction_Helper` before tests only when the tests or target code consume generated members affected by the XML change.
