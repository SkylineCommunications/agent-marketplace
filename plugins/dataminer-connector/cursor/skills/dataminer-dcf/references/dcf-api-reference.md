# DCF API Reference

> **Parent skill**: `dataminer-dcf/SKILL.md`

C# API classes for DCF operations in QActions. All classes are in the `Skyline.DataMiner.Scripting` namespace (SLManagedScripting DLL).

Reference: https://aka.dataminer.services/advanced-dcf-data-miner-class-library

---

## SLProtocol DCF Members

The `SLProtocol` interface (available as `protocol` in QAction entry points) provides these DCF-related members:

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `ConnectivityConnections` | `Dictionary<int, ConnectivityConnection>` | All connections on the element, keyed by connection ID |
| `ConnectivityInterfaces` | `Dictionary<int, ConnectivityInterface>` | All interfaces on the element, keyed by interface ID |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `GetConnectivityConnection(int connectionId)` | `ConnectivityConnection` | Get a single connection by ID |
| `GetConnectivityConnections()` | `Dictionary<int, ConnectivityConnection>` | Get all connections |
| `GetConnectivityInterface(int interfaceId)` | `ConnectivityInterface` | Get a single interface by ID |
| `GetConnectivityInterfaces()` | `Dictionary<int, ConnectivityInterface>` | Get all interfaces |
| `DeleteConnectivityConnection(int connectionId)` | `bool` | Delete a connection by ID |

Reference: https://aka.dataminer.services/skyline-data-miner-scripting-sl-protocol

---

## ConnectivityConnection Class

Represents a DCF connection between two interfaces.

Reference: https://aka.dataminer.services/skyline-data-miner-scripting-connectivi-07e77f96

### Constructors

```csharp
// Parameterless
new ConnectivityConnection()

// Full constructor
new ConnectivityConnection(
    int dataminerId,
    int elementId,
    int connectionId,
    string connectionName,
    int sourceInterfaceId,
    int destDataMinerId,
    int destElementId,
    int destInterfaceId,
    string connectionFilter,
    bool isInternal
)
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `ConnectionId` | `int` | Unique connection identifier |
| `ConnectionName` | `string` | Display name |
| `ConnectionFilter` | `string` | Optional filter/category value |
| `ConnectionProperties` | `Dictionary<int, ConnectivityConnectionProperty>` | Properties on this connection |
| `SourceDataMinerId` | `int` | Source DMA ID |
| `SourceElementId` | `int` | Source element ID |
| `SourceInterfaceId` | `int` | Source interface ID |
| `DestDataMinerId` | `int` | Destination DMA ID |
| `DestElementId` | `int` | Destination element ID |
| `DestInterfaceId` | `int` | Destination interface ID |
| `IsInternal` | `bool` | `true` for internal connections (within element) |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `Delete(SLProtocol protocol)` | `bool` | Delete this connection |
| `Update(SLProtocol protocol)` | `bool` | Save all changes |
| `UpdateName(SLProtocol protocol, string name)` | `bool` | Change connection name |
| `UpdateInterfaces(SLProtocol protocol, int srcIfId, int dstDmaId, int dstEleId, int dstIfId)` | `bool` | Change connected interfaces |
| `UpdateDestination(SLProtocol protocol, int dstDmaId, int dstEleId, int dstIfId)` | `bool` | Change destination only |
| `UpdateFilter(SLProtocol protocol, string filter)` | `bool` | Change connection filter |
| `AddProperty(SLProtocol protocol, string name, string type, string value)` | `ConnectivityConnectionProperty` | Add a property |
| `UpdateProperty(SLProtocol protocol, int propertyId, string name, string type, string value)` | `bool` | Update a property |
| `DeleteProperty(SLProtocol protocol, int propertyId)` | `bool` | Delete a property |
| `GetPropertyById(int propertyId)` | `ConnectivityConnectionProperty` | Get property by ID |
| `GetPropertyByName(string name)` | `ConnectivityConnectionProperty` | Get property by name |

---

## ConnectivityInterface Class

Represents a DCF interface on an element.

Reference: https://aka.dataminer.services/skyline-data-miner-scripting-connectivi-d8f814e1

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `DataMinerId` | `int` | DMA ID of the element owning this interface |
| `ElementId` | `int` | Element ID |
| `ElementKey` | `string` | Combined DMA/Element key |
| `InterfaceId` | `int` | Unique interface identifier |
| `InterfaceName` | `string` | Display name |
| `InterfaceCustomName` | `string` | User-defined custom name |
| `InterfaceTypeInfo` | `ConnectivityInterface.InterfaceType` | Direction: `In`, `Out`, or `InOut` |
| `IsInternal` | `bool` | `true` if hidden from external visibility |
| `InterfaceParameters` | `List<ConnectivityInterfaceParameter>` | Parameters linked for alarm state |
| `InterfaceProperties` | `Dictionary<int, ConnectivityInterfaceProperty>` | Properties on this interface |
| `DynamicLink` | `string` | For dynamic interfaces: link to source table row |
| `DynamicPK` | `string` | For dynamic interfaces: primary key of source row |

### Connection Methods

The `ConnectivityInterface` class provides 24+ overloaded `AddConnection` methods for creating connections. The most common signatures:

```csharp
// Create internal connection (input → output within same element)
ConnectivityConnection AddConnection(
    SLProtocol protocol,
    string connectionName,
    ConnectivityInterface destinationInterface,
    bool isInternal
);

// Create connection with filter
ConnectivityConnection AddConnection(
    SLProtocol protocol,
    string connectionName,
    ConnectivityInterface destinationInterface,
    string connectionFilter,
    bool isInternal
);

// Create connection with properties
ConnectivityConnection AddConnection(
    SLProtocol protocol,
    string connectionName,
    ConnectivityInterface destinationInterface,
    Dictionary<string, ConnectivityConnectionProperty> connectionProperties,
    bool isInternal
);
```

### Other Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `AddProperty(SLProtocol protocol, string name, string type, string value)` | `ConnectivityInterfaceProperty` | Add interface property |
| `UpdateProperty(SLProtocol protocol, int propertyId, string name, string type, string value)` | `bool` | Update interface property |
| `DeleteProperty(SLProtocol protocol, int propertyId)` | `bool` | Delete interface property |
| `DeleteConnection(SLProtocol protocol, int connectionId)` | `bool` | Delete a connection from this interface |
| `GetConnectionById(int connectionId)` | `ConnectivityConnection` | Get connection by ID |
| `GetConnectionByName(string name)` | `ConnectivityConnection` | Get connection by name |
| `GetConnections()` | `Dictionary<int, ConnectivityConnection>` | Get all connections on this interface |
| `UpdateConnection(SLProtocol protocol, ConnectivityConnection connection)` | `bool` | Update an existing connection |
| `UpdateConnectionDestination(SLProtocol protocol, int connectionId, int dstDmaId, int dstEleId, int dstIfId)` | `bool` | Change connection destination |
| `UpdateConnectionFilter(SLProtocol protocol, int connectionId, string filter)` | `bool` | Change connection filter |
| `UpdateConnectionName(SLProtocol protocol, int connectionId, string name)` | `bool` | Change connection name |

---

## ConnectivityConnectionProperty Class

Represents a key-value property on a connection.

Reference: https://aka.dataminer.services/skyline-data-miner-scripting-connectivi-7a29f7e4

### Constructors

```csharp
new ConnectivityConnectionProperty()

new ConnectivityConnectionProperty(
    int propertyId,
    string propertyName,
    string propertyType,
    string propertyValue
)

new ConnectivityConnectionProperty(
    int propertyId,
    string propertyName,
    string propertyType,
    string propertyValue,
    ConnectivityConnection parentConnection
)
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `ConnectionPropertyId` | `int` | Unique property ID |
| `ConnectionPropertyName` | `string` | Property name/key |
| `ConnectionPropertyType` | `string` | Property type/category |
| `ConnectionPropertyValue` | `string` | Property value |
| `Connection` | `ConnectivityConnection` | Parent connection reference |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `Update(SLProtocol protocol)` | `bool` | Save changes to this property |
| `Delete(SLProtocol protocol)` | `bool` | Delete this property |

---

## ConnectivityInterfaceProperty Class

Represents a key-value property on an interface.

Reference: https://aka.dataminer.services/skyline-data-miner-scripting-connectivi-d26e4c7c

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `InterfacePropertyId` | `int` | Unique property ID |
| `InterfacePropertyName` | `string` | Property name/key |
| `InterfacePropertyType` | `string` | Property type/category |
| `InterfacePropertyValue` | `string` | Property value |
| `Interface` | `ConnectivityInterface` | Parent interface reference |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `Update(SLProtocol protocol)` | `bool` | Save changes to this property |
| `Delete(SLProtocol protocol)` | `bool` | Delete this property |

---

## ConnectivityInterface.InterfaceType Enum

| Value | Description |
|-------|-------------|
| `In` | Input interface |
| `Out` | Output interface |
| `InOut` | Bidirectional / virtual interface |

---

## QAction Setup

### QAction Example: Create Internal Connection

```csharp
using Skyline.DataMiner.Scripting;

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        var interfaces = protocol.GetConnectivityInterfaces();

        ConnectivityInterface inputInterface = null;
        ConnectivityInterface outputInterface = null;

        foreach (var kvp in interfaces)
        {
            if (kvp.Value.InterfaceName == "Input 1")
                inputInterface = kvp.Value;
            else if (kvp.Value.InterfaceName == "Output 1")
                outputInterface = kvp.Value;
        }

        if (inputInterface != null && outputInterface != null)
        {
            inputInterface.AddConnection(
                protocol,
                "Route 1",
                outputInterface,
                true  // isInternal = true
            );
        }
    }
}
```

### QAction Example: Add Interface Property

```csharp
using Skyline.DataMiner.Scripting;

public class QAction
{
    public static void Run(SLProtocol protocol)
    {
        var interfaces = protocol.GetConnectivityInterfaces();

        foreach (var kvp in interfaces)
        {
            if (kvp.Value.InterfaceName == "Input 1")
            {
                kvp.Value.AddProperty(
                    protocol,
                    "SignalFormat",
                    "string",
                    "SDI"
                );
                break;
            }
        }
    }
}
```
