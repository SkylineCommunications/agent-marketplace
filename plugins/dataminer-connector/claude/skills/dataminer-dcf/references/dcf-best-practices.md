# DCF Best Practices

> **Parent skill**: `dataminer-dcf/SKILL.md`

Operational and development guidelines for reliable DCF implementations.

Reference: https://aka.dataminer.services/advanced-dcf-best-practices

---

## Stability

### Never Remove Connections Accidentally

Unintended connection removal causes service outages and breaks signal path visibility. Always implement explicit removal logic with clear intent.

❌ Removing all connections on every poll cycle and re-creating:
```csharp
// WRONG: clears all connections then rebuilds — any failure leaves gaps
var connections = protocol.GetConnectivityConnections();
foreach (var conn in connections.Values)
{
    conn.Delete(protocol);
}
// ... re-create connections
```

✅ Comparing current state and updating only what changed:
```csharp
// CORRECT: only modify connections that actually changed
var existing = protocol.GetConnectivityConnections();
foreach (var desired in desiredConnections)
{
    var match = FindMatchingConnection(existing, desired);
    if (match == null)
    {
        // Create new connection
        sourceInterface.AddConnection(protocol, desired.Name, destInterface, true);
    }
    else
    {
        // Update if changed, otherwise leave in place
        if (HasChanged(match, desired))
        {
            match.UpdateDestination(protocol, desired.DstDmaId, desired.DstEleId, desired.DstIfId);
        }
    }
}
```

---

## Interface Tables

### RTDisplay

DCF interface source tables should have `RTDisplay` enabled so interface data is visible in the UI.

### State Columns

Include a column in the source table for interface state/status. Link this column to the interface via `<Params>` for alarm propagation.

### Removal Logic

When a row is removed from a dynamic interface source table, the corresponding interface and its connections are automatically removed. Ensure this is the intended behavior — if the interface should persist even when the row is temporarily absent, use a separate management mechanism.

---

## Performance

### Avoid QActions on DCF Table Changes

❌ Triggering a QAction when DCF system tables change:
```xml
<!-- WRONG: triggers on DCF system table — deadlock risk -->
<Trigger id="1">
  <On id="65049">change</On>
  <Time>change</Time>
</Trigger>
<Action id="1">
  <On id="1">trigger</On>
  <Type>run actions</Type>
</Action>
```

QActions triggered by changes to DCF system table parameters (65049–65102) create deadlock risk because DCF updates go through SLNet, and the triggered QAction may try to communicate back to SLNet in the same transaction.

✅ Use a custom intermediary table:
If you need to react to connectivity changes, poll or maintain a separate custom table that tracks the state you care about, and trigger QActions on that table instead.

### Large SNMP Tables

For protocols that poll large SNMP tables used as DCF interface sources:
- Use custom tables to preprocess/filter the SNMP data
- Map the filtered results to DCF interfaces
- Avoid directly linking massive SNMP tables as DCF sources

---

## Alarm Monitoring

### High-Frequency Tables

DCF alarm state calculation on large or frequently-updated tables consumes significant resources.

✅ Disable alarm state calculation when not needed:
```xml
<Group id="1" name="Input" type="in" dynamicId="1000" dynamicIndex="*" calculateAlarmState="false" />
```

Use `calculateAlarmState="false"` when:
- The interface source table updates very frequently (>7 changes/min)
- Interface alarm state is not required for the use case
- Performance is more critical than alarm-level visibility

---

## Connection Management Approaches

### Internal Connections

Created programmatically within the connector. Recommended approaches:

| Method | When to Use |
|--------|-------------|
| **DCF Helper class** (NuGet) | Default choice — clean API, handles SLNet details |
| **Raw SLProtocol API** | Simple single-connection operations |
| **Automation script** | When connection logic lives outside the connector |

### External Connections

Created between different elements. These are typically **not** managed by the connector itself:

| Method | Description |
|--------|-------------|
| **Manager element** | A dedicated element that orchestrates connectivity across the system |
| **Automation script** | Scheduled or event-driven scripts that manage cross-element connections |
| **Manual configuration** | User creates connections via DataMiner Cube UI |
| **Element-to-element** | One element creates a connection to another element's interface |
| **Skyline Generic Provisioning** | Automated provisioning solution |
| **DataMiner IDP** | Infrastructure Discovery and Provisioning module |

---

## Volatile Tables

**Never** use `volatile="true"` on tables that serve as DCF dynamic interface sources. Volatile tables lose their data on element restart, which means:
- All dynamic interfaces disappear
- All connections to those interfaces are lost
- DCF topology is broken until the table is repopulated

This applies to `options=";volatile"` in `<ArrayOptions>` as well.

---

## Checklist

Before finalizing a DCF implementation, verify:

- [ ] Interface source tables are **not** volatile
- [ ] Internal connections flow input → output
- [ ] No QAction triggers on DCF system tables (65049–65102)
- [ ] `calculateAlarmState="false"` set where alarm state is not needed
- [ ] Connection removal logic is explicit, not accidental
- [ ] DCF Helper NuGet package installed if using helper class
- [ ] Interface names are descriptive and match physical port labels
- [ ] Properties use consistent naming conventions across the connector
