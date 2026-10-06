# DCF Helper Class

> **Parent skill**: `dataminer-dcf/SKILL.md`

The DCF Helper class provides a higher-level abstraction for managing DCF connections in connectors. It is distributed as a NuGet package and is the recommended approach for DCF operations.

Reference: https://aka.dataminer.services/advanced-dcf-helper

---

## NuGet Package

**Package**: `Skyline.DataMiner.Core.ConnectivityFramework.Protocol`
**Current version**: 1.0.4 (released February 2024)
**Dependency**: `Skyline.DataMiner.Dev.Protocol` (>= 10.1.1)

NuGet: https://www.nuget.org/packages/Skyline.DataMiner.Core.ConnectivityFramework.Protocol

### Installation

**dotnet CLI:**
```
dotnet add package Skyline.DataMiner.Core.ConnectivityFramework.Protocol
```

**PackageReference (in .csproj):**
```xml
<PackageReference Include="Skyline.DataMiner.Core.ConnectivityFramework.Protocol" Version="1.0.4" />
```

---

## When to Use

| Scenario | Recommended Approach |
|----------|---------------------|
| Creating/updating internal connections in a QAction | DCF Helper class |
| Bulk connection management | DCF Helper class |
| Simple single-connection operations | Raw SLProtocol API (`ConnectivityInterface.AddConnection`) is acceptable |
| External connections between elements | Manager elements, automation scripts, DataMiner IDP, or manual configuration |

### Why Use the Helper Over Raw API

- Handles SLNet communication details
- Provides a cleaner abstraction for common DCF patterns
- Reduces boilerplate for connection creation and property management
- Follows Skyline's recommended implementation patterns

---

## SLManagedAutomation Classes

For Automation scripts (not QActions), DCF operations are available through the `SLManagedAutomation` DLL:

| Class | Description |
|-------|-------------|
| `Element` | Represents a DataMiner element with DCF access |
| `Interface` | Represents a DCF interface on an element |

These classes are used when managing DCF from Automation scripts rather than from within connector QActions.
