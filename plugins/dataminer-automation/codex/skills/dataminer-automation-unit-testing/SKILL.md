---
name: dataminer-automation-unit-testing
description: 'Unit testing DataMiner Automation scripts: testable script design, mocking the IEngine interface with Moq, asserting exit states and side effects, and test-project setup with xUnit/NUnit/MSTest and FluentAssertions. Load when writing or setting up tests for an automation script.'
argument-hint: 'Describe what to test: e.g. "test input validation", "test the parse helper", "verify ExitFail on missing element", "set up a test project for my script"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 1.2
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.2 | 2026-09-16 | Added explicit routing between pure unit, build/XSD, QAOps integration, host-specific UI, and post-deploy regression tests. |
| 1.1 | 2026-09-15 | Removed direct ScriptParam construction guidance and added application-owned input seams plus deterministic test-parallelism rules. |
| 1.0 | 2026-06-27 | Initial release. Automation-script counterpart of `dataminer-unit-testing`. |

You write unit tests for the C# logic of an Automation script.

> **Skill authorities**: load `dataminer-automation-core` first and `dataminer-automation-scripting` for the code under test. `IEngine` is an **interface**, so it is mockable with **Moq**; there is no SLProtocolMock equivalent for automation.

## Testing strategy (most → least valuable)

1. **Extract pure logic into testable methods.** Parsing, validation, mapping, and decision logic should be `static` methods that take plain inputs and return plain outputs — no `IEngine`. These are trivial to test and cover most real bugs.
2. **Mock `IEngine` with Moq** for the orchestration path (input reading, element resolution, exit states). Assert the script calls the right Engine members and exits correctly.
3. **Keep `Element` interactions thin.** `Element` is a concrete class and awkward to mock — wrap element access behind your own small method/interface you can substitute, or assert at the boundary (which parameter id/value would be set).

### SDK-owned input types are not test seams

`Skyline.DataMiner.Automation.ScriptParam` is SDK-owned and is not an application input model. Do not instantiate or initialize that SDK type in tests, and do not make tests depend on its constructor/property shape.

Keep SDK access in a production-only adapter and expose plain values to application logic:

```csharp
public interface IScriptInputReader
{
    string Read(int id);
}

public sealed class EngineScriptInputReader(IEngine engine) : IScriptInputReader
{
    public string Read(int id) => engine.GetScriptParam(id).Value;
}
```

Test parsing and decisions with plain strings. For orchestration tests, mock the application-owned `IScriptInputReader` and `IEngine` boundaries separately; do not mock or instantiate `ScriptParam`.

If a test changes process-global/application-global state such as an `OverrideGetDms` hook, disable test parallelization with the selected framework's supported setting (`[DoNotParallelize]`, xUnit collection behavior, or NUnit's non-parallel fixture). Prefer dependency injection over global overrides.

## Test project setup

1. Add a standard test project (xUnit / NUnit / MSTest) next to the script project, e.g. `My-Script.Tests`.
2. Add a `<ProjectReference>` to the script project (the `Script` class and helpers are `public`).
3. Add `Moq` and `FluentAssertions` (use **FluentAssertions ≤ 7.2.0** — v8+ needs a commercial license).
4. `dotnet test` to run.

## Mocking IEngine (pattern)

```csharp
using FluentAssertions;
using Moq;
using Skyline.DataMiner.Automation;
using Xunit;

public class ScriptTests
{
	[Fact]
	public void Run_MissingElementIdentifier_ExitsFail()
	{
		// Arrange
		var engine = new Mock<IEngine>();
		var input = new Mock<IScriptInputReader>();
		input.Setup(reader => reader.Read(10)).Returns("[\"\"]");
		// ExitFail throws ScriptAbortException by contract:
		engine.Setup(e => e.ExitFail(It.IsAny<string>())).Throws(new ScriptAbortException("fail"));

		// Act
		Action act = () => new ScriptLogic(input.Object, engine.Object).Run();

		// Assert
		act.Should().Throw<ScriptAbortException>();
		engine.Verify(e => e.ExitFail(It.Is<string>(s => s.Contains("Identifier"))), Times.Once);
	}
}
```

The production adapter may call the verified `IEngine.GetScriptParam(int)` member, but tests should not construct `ScriptParam` or rely on its shape. Adapt mocks to the application-owned seam and the exact Engine members exposed by the selected target package.

## Constraints

- Mock the **`IEngine` interface** with Moq; never instantiate the real engine.
- Never construct `Skyline.DataMiner.Automation.ScriptParam` in tests; mock an application-owned input seam and test plain strings.
- **Assert outcomes** (exit state, the value that would be set) rather than incidental call order.
- Remember `engine.ExitSuccess` / `engine.ExitFail` raise `ScriptAbortException` — set the mock to throw and assert the throw.
- Test naming: `Method_Scenario_ExpectedResult` (e.g. `Run_InvalidParameterId_ExitsFail`).
- Fresh mocks per test — tests must be independent.
- Prefer many small tests on extracted pure methods over a few brittle full-`Run` tests.

## Reference Files

| File | Contents | Load When |
|------|----------|-----------|
| `references/test-patterns.md` | Worked examples: pure-method tests, IEngine mock setups, exit-state assertions | Writing tests for a specific scenario |
| `references/integration-testing-routing.md` | Test-goal matrix separating unit, build/XSD, QAOps, IAS-host, and post-deploy regression routes | Choosing the correct Automation test route |
