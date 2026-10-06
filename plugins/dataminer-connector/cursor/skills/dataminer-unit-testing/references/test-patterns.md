# Test Patterns & Assertion API

Reference for IAsserter interface, Arrange/Act/Assert examples, Fluent Assertions integration, and Moq integration.

> **Parent skill**: `dataminer-unit-testing/SKILL.md` — return there for framework overview, project setup, and best practices.

---

## IAsserter Interface

Access via `mock.Assert()` for fluent validation:

```csharp
IAsserter asserter = mock.Assert();
```

### Key Methods

| Method | Description |
|--------|-------------|
| `asserter.Parameter(pid)` | Get the stored value of a parameter |
| `asserter.Table(tablePid)` | Get table data for assertions |
| `asserter.AllRows()` | Get all rows from a table |
| `asserter.Row<T>(primaryKey)` | Get a typed row by primary key |

### Example Usage

```csharp
// Assert a parameter value was set
var result = asserter.Parameter(Parameter.devicestatus);
Assert.AreEqual("Online", Convert.ToString(result));

// Assert table contents
var rows = asserter.Table(Parameter.Channelstable.tablePid).AllRows();
Assert.AreEqual(3, rows.Count);
```

---

## Arrange / Act / Assert Pattern

### Basic Parameter Test

```csharp
[TestClass]
public class QAction100Tests
{
    [TestMethod]
    public void Run_ValidResponse_SetsDeviceName()
    {
        // Arrange
        var mock = new SLProtocolMock();
        mock.Object.SetParameter(Parameter.rawresponse, "{\"name\": \"Device1\"}");

        // Act
        QAction.Run(mock.Object);

        // Assert
        var name = mock.Assert().Parameter(Parameter.devicename);
        Assert.AreEqual("Device1", Convert.ToString(name));
    }
}
```

### Table Fill Test

```csharp
[TestMethod]
public void Run_JsonWithItems_FillsTable()
{
    // Arrange
    var mock = new SLProtocolMock();
    string json = "[{\"id\":\"1\",\"name\":\"Alpha\"},{\"id\":\"2\",\"name\":\"Beta\"}]";
    mock.Object.SetParameter(Parameter.rawresponse, json);

    // Act
    QAction.Run(mock.Object);

    // Assert
    var rows = mock.Assert().Table(Parameter.Itemstable.tablePid).AllRows();
    Assert.AreEqual(2, rows.Count);
}
```

### Typed Row Assertion

```csharp
[TestMethod]
public void Run_ValidData_CorrectRowValues()
{
    // Arrange
    var mock = new SLProtocolMock<ConcreteSLProtocolExt>();
    mock.Object.SetParameter(Parameter.rawresponse, sampleJson);

    // Act
    QAction.Run((SLProtocolExt)mock.Object);

    // Assert
    var row = mock.Assert()
        .Table(Parameter.Channelstable.tablePid)
        .Row<ChannelstableQActionRow>("1");

    Assert.AreEqual("CH1", Convert.ToString(row.Channelname));
    Assert.AreEqual(100.0, Convert.ToDouble(row.Channelactivepower));
}
```

### Empty/Error Response Test

```csharp
[TestMethod]
public void Run_EmptyResponse_DoesNotThrow()
{
    // Arrange
    var mock = new SLProtocolMock();
    mock.Object.SetParameter(Parameter.rawresponse, String.Empty);

    // Act & Assert — should not throw
    QAction.Run(mock.Object);
}

[TestMethod]
public void Run_InvalidJson_DoesNotThrow()
{
    // Arrange
    var mock = new SLProtocolMock();
    mock.Object.SetParameter(Parameter.rawresponse, "not valid json");

    // Act & Assert — QAction should handle gracefully (try/catch)
    QAction.Run(mock.Object);
}
```

### Pre-Populated Table Test

```csharp
[TestMethod]
public void Run_ExistingRows_ReplacedByNewData()
{
    // Arrange
    var mock = new SLProtocolMock();

    // Pre-populate table with old data
    mock.Object.AddRow(Parameter.Itemstable.tablePid, new object[] { "old1", "OldName" });

    // Set new response
    mock.Object.SetParameter(Parameter.rawresponse, newDataJson);

    // Act
    QAction.Run(mock.Object);

    // Assert — old rows should be gone (FillArray replaces)
    var rows = mock.Assert().Table(Parameter.Itemstable.tablePid).AllRows();
    Assert.IsFalse(rows.Any(r => Convert.ToString(r[0]) == "old1"));
}
```

---

## Integration with Fluent Assertions

For more readable assertions:

```csharp
using FluentAssertions;

[TestMethod]
public void Run_ValidResponse_SetsCorrectStatus()
{
    var mock = new SLProtocolMock();
    mock.Object.SetParameter(Parameter.rawresponse, validJson);

    QAction.Run(mock.Object);

    var status = Convert.ToString(mock.Assert().Parameter(Parameter.devicestatus));
    status.Should().Be("Online");

    var rows = mock.Assert().Table(Parameter.Itemstable.tablePid).AllRows();
    rows.Should().HaveCount(5);
    rows.First()[1].Should().Be("Alpha");
}
```

---

## Integration with Moq

Since `SLProtocolMock` extends Moq's `Mock<T>`, you can use Moq features for advanced scenarios:

```csharp
using Moq;

[TestMethod]
public void Run_SetsParameter_CalledOnce()
{
    var mock = new SLProtocolMock();
    mock.Object.SetParameter(Parameter.rawresponse, validJson);

    QAction.Run(mock.Object);

    // Verify a specific method was called (use sparingly — prefer output assertions)
    mock.Verify(p => p.SetParameter(Parameter.devicestatus, It.IsAny<object>()), Times.Once);
}
```

> Prefer asserting output state (via `IAsserter`) over verifying method calls. Method-call verification makes tests brittle to implementation changes.
