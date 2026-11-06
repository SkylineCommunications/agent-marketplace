# Automation Unit Test Patterns

Worked examples for testing Automation script C#. `IEngine` is an interface → mock with Moq. Favor extracting pure logic.

> **Parent skill**: `dataminer-automation-unit-testing/SKILL.md`.

---

## 1. Testable design (extract pure logic)

Refactor input normalization and decisions into `static` methods:

```csharp
public static class ScriptLogic
{
	public static string Normalize(string raw)
		=> raw?.Trim().TrimStart('[', '"').TrimEnd('"', ']') ?? String.Empty;

	public static bool TryParseParameterId(string raw, out int id)
		=> Int32.TryParse(Normalize(raw), out id);
}
```

Tests (no engine needed):

```csharp
[Theory]
[InlineData("[\"42\"]", true, 42)]
[InlineData("[\"\"]", false, 0)]
[InlineData("abc", false, 0)]
public void TryParseParameterId_Works(string input, bool expected, int expectedId)
{
	bool ok = ScriptLogic.TryParseParameterId(input, out int id);
	ok.Should().Be(expected);
	if (expected) id.Should().Be(expectedId);
}
```

## 2. Keep SDK input access behind an application seam

The SDK-owned `ScriptParam` type is not a test DTO. Keep its use in a production adapter and test plain strings:

```csharp
public interface IScriptInputReader
{
	string Read(int id);
}

public sealed class EngineScriptInputReader : IScriptInputReader
{
	private readonly IEngine _engine;

	public EngineScriptInputReader(IEngine engine)
	{
		_engine = engine;
	}

	public string Read(int id)
	{
		return _engine.GetScriptParam(id).Value;
	}
}
```

```csharp
[Theory]
[InlineData("[\"42\"]", true, 42)]
[InlineData("[\"\"]", false, 0)]
[InlineData("abc", false, 0)]
public void ParseParameterId_Works(string input, bool expected, int expectedId)
{
	bool ok = ScriptLogic.TryParseParameterId(input, out int id);
	ok.Should().Be(expected);
	if (expected) id.Should().Be(expectedId);
}
```

## 3. Mock IEngine for the orchestration path

```csharp
[Fact]
public void Run_ValidInputs_SetsParameter()
{
	var engine = new Mock<IEngine>();
	var input = new Mock<IScriptInputReader>();
	input.Setup(reader => reader.Read(10)).Returns("[\"My Element\"]");
	input.Setup(reader => reader.Read(11)).Returns("[\"100\"]");
	input.Setup(reader => reader.Read(12)).Returns("[\"5\"]");

	// FindElement returns a concrete Element — wrap element access behind a seam you can substitute,
	// or assert at the boundary by capturing the (pid, value) your code intends to set.

	// Invoke the application-owned seam and assert the intended set.
}
```

## 3. Assert exit states

```csharp
[Fact]
public void Run_ElementNotFound_ExitsFail()
{
	var engine = new Mock<IEngine>();
	var input = new Mock<IScriptInputReader>();
	input.Setup(reader => reader.Read(It.IsAny<int>())).Returns("[\"Ghost\"]");
	engine.Setup(e => e.FindElement("Ghost")).Returns((Element)null);
	engine.Setup(e => e.ExitFail(It.IsAny<string>())).Throws(new ScriptAbortException("fail"));

	Action act = () => new ScriptLogic(input.Object, engine.Object).Run();

	act.Should().Throw<ScriptAbortException>();
	engine.Verify(e => e.ExitFail(It.Is<string>(s => s.Contains("not found"))), Times.Once);
}
```

---

## Notes

- Adapt the production adapter to the exact `IEngine` members your DataMiner target exposes. Tests mock `IScriptInputReader` and must not construct `ScriptParam`.
- If a test changes global Engine/DMS state, disable test parallelization with the selected framework's supported mechanism; otherwise prefer dependency injection.
- `ExitSuccess`/`ExitFail` throw `ScriptAbortException` — set the mock to throw and assert it.
- FluentAssertions ≤ 7.2.0; Moq for mocking; xUnit/NUnit/MSTest all fine.
