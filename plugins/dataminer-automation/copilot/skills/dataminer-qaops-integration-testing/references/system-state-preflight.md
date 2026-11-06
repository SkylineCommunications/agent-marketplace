# System State Preflight and Failure Diagnostics

Canonical Arrange-phase validation for QAOps integration tests: snapshot what is on the DataMiner, isolate your fixture, classify pre-existing artifacts, assert protocol versions, and pack the evidence into every assertion message.

Verified baseline fact: **QAOps DaaS systems always contain a pre-installed Microsoft Platform element and connector**, typically in a different version range than a Catalog-installed one. Treat "the system already contains elements of my protocol" as the default, not the exception.

## Empty-System Contract (Mandatory)

The baseline fact above is an environment detail, **not** something a test may depend on. The same `.dmtest` must pass on an empty DataMiner that contains only what the Test Package itself installs (connectors via `CatalogReferences.xml`, same-solution scripts, ...). Concretely:

- Arrange must never hard-require pre-existing elements (e.g. `Assert.IsNotNull(firstElementOfProtocol, "No element found")` as a precondition is a contract violation).
- Implement **both** Arrange branches: *system empty* → create the fixture (or `Duplicate` — see Fixture Isolation — when plain creation is unsupported for the connector); *baseline present* → still create/duplicate a test-owned fixture and classify the baseline via the Interference Policy.
- When element creation is blocked by the IDms serial-connector gap (packages ≤1.2.0.x — `dataminer-idms` cheatsheet → "Creating Elements") **and** the system is empty, fail fast with a message naming that gap and the consumed package version — surface the limitation, never paper over it by silently requiring baseline content.

## Why This Exists (Measured Failure Mode)

A session testing a script that exports "the first Microsoft Platform element" burned **eight full QAOps runs plus two token-failed submissions** on a problem that proper Arrange validation would have surfaced in run one. The script bound to the **pre-existing baseline element** instead of the test-created one; its PID map was built from a different connector version, so parameter reads threw deep inside `GetValue()`. The test never caught it because:

- Arrange only checked *"do elements of the protocol exist?"* — and **skipped fixture creation when they did**, silently adopting baseline content as the fixture.
- No assertion reported *which* element (identity) or *which* protocol version was actually in play.
- Failure messages carried no system state, so every rerun produced the same opaque "file was not created" and invited another guess.

With the preflight below, run one fails with: *"the script will select element 'Microsoft Platform' (pre-existing baseline, version 1.1.4.x), but this test's data was built from version 1.1.3.x"* — root cause named immediately.

## Snapshot Helpers

```csharp
public sealed class ProtocolElementSnapshot
{
    public string ElementName { get; set; }
    public DmsElementId ElementId { get; set; }
    public string ProtocolName { get; set; }
    public string ProtocolVersion { get; set; }
    public ElementState State { get; set; }

    public override string ToString() =>
        $"'{ElementName}' ({ElementId.AgentId}/{ElementId.ElementId}) protocol '{ProtocolName}' version '{ProtocolVersion}' state {State}";
}

public static class SystemState
{
    public static List<ProtocolElementSnapshot> SnapshotProtocolElements(IDms dms, string protocolName)
    {
        return dms.GetElements()
            .Where(e => String.Equals(e.Protocol.Name, protocolName, StringComparison.OrdinalIgnoreCase))
            .Select(e => new ProtocolElementSnapshot
            {
                ElementName = e.Name,
                ElementId = e.DmsElementId,
                ProtocolName = e.Protocol.Name,
                ProtocolVersion = e.Protocol.Version,
                State = e.State,
            })
            .ToList();
    }

    public static string Describe(string label, IReadOnlyCollection<ProtocolElementSnapshot> snapshot)
    {
        if (snapshot.Count == 0)
        {
            return label + ": none";
        }

        return label + ":" + Environment.NewLine + "  " + String.Join(Environment.NewLine + "  ", snapshot);
    }
}
```

Usage at the very start of Arrange — log it *and* keep the string for assertion messages:

```csharp
List<ProtocolElementSnapshot> preExisting = SystemState.SnapshotProtocolElements(dms, ProtocolName);
string stateReport = SystemState.Describe($"Pre-existing '{ProtocolName}' elements", preExisting);
Console.WriteLine(stateReport); // lands in the TRX
```

## Fixture Isolation (Always Create, Target by Identity)

```csharp
// Always create — never reuse a pre-existing element as the fixture,
// and never skip creation because elements of the protocol already exist.
//
// VERSION-BOUND DATA (PID maps, page layouts): create from the SPECIFIC version your Test Package
// installed, NOT "Production". On QAOps DaaS, "Production" resolves to the pre-existing baseline's
// version (verified: Microsoft Platform 7.0.0.1-Prerelease004), which differs from your
// CatalogReferences version (e.g. 1.1.3.20). Both coexist — a "Production" fixture binds to the
// wrong version and every PID read then fails. Assert the version you need is installed, then pin it:
const string SupportedVersion = "1.1.3.20";
Assert.IsTrue(
    dms.GetProtocols().Any(p => string.Equals(p.Name, ProtocolName, StringComparison.OrdinalIgnoreCase)
        && string.Equals(p.Version, SupportedVersion, StringComparison.OrdinalIgnoreCase)),
    $"Protocol '{ProtocolName}' version '{SupportedVersion}' is not installed — the Test Package's CatalogReferences did not install it.");
IDmsProtocol protocol = dms.GetProtocol(ProtocolName, SupportedVersion); // NOT "Production"
string fixtureName = $"IntegrationTest {ProtocolName} {Guid.NewGuid():N}";
DmsElementId fixtureId = dms.GetAgents().First().CreateElement(new ElementConfiguration(dms, fixtureName, protocol));

// Poll-wait until Active + IsStartupComplete(), then ALWAYS act on fixtureId — never on
// "the first element of protocol X". CAUTION (verified): right after CreateElement,
// dms.GetElement(fixtureId) throws ElementNotFoundException transiently — catch it inside the
// poll loop and treat as "not ready yet" (see dataminer-idms cheatsheet → "Creating Elements").
IDmsElement fixture = dms.GetElement(fixtureId);
```

Record `fixture.Protocol.Version` in the state report. Delete the fixture in `finally`/`[TestCleanup]`, even on failure.

Serial-connector caveat (verified; **applies to Core.DataMinerSystem packages ≤1.2.0.x** — newer versions derive valid defaults from `protocol.ConnectionInfo`, see `dataminer-idms`): on affected versions, for serial connectors such as Microsoft Platform the `ElementConfiguration` constructor throws `IncorrectDataException: Invalid connection type provided at index 0` for **every** connection variant (default virtual, `SerialConnection()`, `SerialConnection(new Tcp())`). Fall back to `existing.Duplicate(uniqueName, agent)` when an element of the protocol exists (the duplicate is test-owned — delete it in cleanup); on an empty system, fail fast naming the library version + gap. Full strategy: `dataminer-idms` cheatsheet → "Creating Elements". Do not debug this one variant per QAOps run — batch all variants into one run.

## Interference Policy

Decide per test what pre-existing artifacts mean. **Existence alone is never a failure** — items that cannot interfere with the test logic are allowed and ignored (beyond logging).

| Logic under test | Pre-existing elements of the protocol are | Action |
|------------------|-------------------------------------------|--------|
| Targets the fixture by identity (element ID or exact name passed in) | **Benign** | Allow and ignore; record them in the state report only |
| Selects elements globally (first/all of a protocol, name patterns) | **Interfering** | Mirror the exact selection logic in the test, then assert the selected element is supported (below) — or fail fast with the snapshot |
| Operates on version-bound data (PID maps, page layouts from a specific protocol.xml) | **Interfering when versions differ** | Assert the target's `Protocol.Version` is in the supported range before Act |

Mirror-selection pattern for scripts with global selection — reproduce the *same ordering the script uses*, then validate what it will pick:

```csharp
ProtocolElementSnapshot willBeSelected = SystemState.SnapshotProtocolElements(dms, ProtocolName)
    .OrderByDescending(s => s.State == ElementState.Active)
    .ThenBy(s => s.ElementId.AgentId)
    .ThenBy(s => s.ElementId.ElementId)
    .First();

Assert.IsTrue(
    willBeSelected.ProtocolVersion.StartsWith(SupportedVersionPrefix, StringComparison.Ordinal),
    $"The script under test will select {willBeSelected}, but this test's data was built from protocol version " +
    $"'{SupportedVersionPrefix}*'. A pre-existing baseline element interferes with the script's global selection logic." +
    Environment.NewLine + stateReport);
```

## Version Assertions

Test data derived from a specific `protocol.xml` (PID→name maps, page layouts) is version-bound. Assert before Act:

```csharp
private const string SupportedVersionPrefix = "1.1.3."; // the protocol.xml the PID map came from

Assert.IsTrue(
    fixture.Protocol.Version.StartsWith(SupportedVersionPrefix, StringComparison.Ordinal),
    $"Fixture protocol version '{fixture.Protocol.Version}' is outside the supported range '{SupportedVersionPrefix}*'. " +
    "The Test Package may have installed a different connector version than the one the test data was derived from." +
    Environment.NewLine + stateReport);
```

`Protocol.Version` can be the literal string `"Production"` (verified) — numeric prefix checks silently fail for production-flagged elements. Resolve the concrete version via `dms.GetProtocol(name, "Production").ReferencedVersion` before comparing, or design the data path to degrade per field (catch `ParameterNotFoundException` per PID, report `IsAvailable=false` + reason) instead of hard-failing on version.

**Fix the fixture, do not relax the assertion (verified — cost ~1 QAOps run).** Per-field degradation is a *production-script* resilience strategy; it is the wrong remedy for a *test* whose whole purpose is to verify the version-bound PID map. When the version assertion fails because the fixture was created on the wrong version, the fix is to **create the fixture from the specific installed version** (see Fixture Isolation) so the data contract is actually exercised — not to loosen the test to "accept any version / require >0 fields", which lets real version drift pass silently. Once a run has *named* the version mismatch, go straight to pinning the version; do not spend another run merely relaxing the check.

## Reading DataMiner Logs Without Locking Them

DataMiner keeps its log files (under `C:\Skyline DataMiner\Logging`) **open for writing** while the system runs. Two verified rules:

- `File.ReadAllLines` / `File.ReadAllText` throw `IOException` ("being used by another process"). Never use them on DataMiner logs.
- Open with `FileAccess.Read` + `FileShare.ReadWrite | FileShare.Delete`: this grants you a read handle **without taking any lock that blocks or disturbs the DataMiner writer**.

`SLAutomation.txt` is the verified single source for Automation-script behavior: it contains the `Started executing script: '<name>'` / `Finished executing script: '<name>' ... - FAILED -` lines, managed-assembly load lines, and full exception stack traces (stack-frame continuation lines carry no timestamp and belong to the preceding entry).

```csharp
public static class DmLogs
{
    public const string LoggingFolder = @"C:\Skyline DataMiner\Logging";
    public const string SLAutomationLog = @"C:\Skyline DataMiner\Logging\SLAutomation.txt";

    private static readonly string[] ErrorIndicators = { "|ERR|", "|EXC|", "- FAILED -", "Exception", "Something went wrong" };

    // Non-locking read of a live DataMiner log file.
    public static List<string> ReadLinesShared(string path)
    {
        var lines = new List<string>();
        if (!File.Exists(path))
        {
            return lines;
        }

        using (var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
        using (var reader = new StreamReader(stream))
        {
            string line;
            while ((line = reader.ReadLine()) != null)
            {
                lines.Add(line);
            }
        }

        return lines;
    }

    public static string Tail(string path, int maxLines)
    {
        List<string> lines = ReadLinesShared(path);
        if (lines.Count == 0)
        {
            return $"(log file '{path}' not found or empty)";
        }

        return String.Join(Environment.NewLine, lines.Skip(Math.Max(0, lines.Count - maxLines)));
    }

    // Groups log lines into entries (a new entry starts at a line whose first '|' field parses as a
    // timestamp; continuation lines such as stack frames attach to the previous entry), keeps entries
    // written at/after 'sinceLocalTime', and returns those that BOTH mention one of the test's own
    // subjects AND contain an error indicator. Errors about anything else on the system are ignored.
    public static List<string> FindConcerningEntries(string path, DateTime sinceLocalTime, params string[] subjects)
    {
        var entries = new List<List<string>>();
        bool inScope = false;

        foreach (string line in ReadLinesShared(path))
        {
            int separator = line.IndexOf('|');
            DateTime timestamp = DateTime.MinValue; // initializer required: the '&&' assignment below is conditional → CS0165 otherwise (verified build failure)
            bool startsEntry = separator > 0 && DateTime.TryParseExact(
                line.Substring(0, separator).Trim(), "yyyy/MM/dd HH:mm:ss.fff",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out timestamp);

            if (startsEntry)
            {
                inScope = timestamp >= sinceLocalTime;
                if (inScope)
                {
                    entries.Add(new List<string> { line });
                }
            }
            else if (inScope && entries.Count > 0)
            {
                entries[entries.Count - 1].Add(line); // continuation line (e.g. stack frame)
            }
        }

        return entries
            .Where(entry => entry.Any(l => subjects.Any(s => l.IndexOf(s, StringComparison.OrdinalIgnoreCase) >= 0))
                && entry.Any(l => ErrorIndicators.Any(i => l.IndexOf(i, StringComparison.OrdinalIgnoreCase) >= 0)))
            .Select(entry => String.Join(Environment.NewLine, entry))
            .ToList();
    }
}
```

Required usings for these helpers: `System`, `System.Collections.Generic`, `System.Globalization` (for `CultureInfo`), `System.IO`, `System.Linq`.

### Asserting "No Errors Concern This Test"

After Act — **also on the happy path**, not only when an outcome assertion fails — scan the log window of the test run and assert that DataMiner logged no errors about the test's own subjects:

```csharp
DateTime actStart = DateTime.Now.AddSeconds(-2); // same machine as DataMiner (localhost); small slack for clock granularity

// ... Act: run the script / manipulate the fixture ...

List<string> concerning = DmLogs.FindConcerningEntries(DmLogs.SLAutomationLog, actStart, ScriptName, fixture.Name);
Assert.AreEqual(
    0,
    concerning.Count,
    "DataMiner logged errors concerning this test:" + Environment.NewLine +
    String.Join(Environment.NewLine + "----" + Environment.NewLine, concerning) +
    Environment.NewLine + stateReport);
```

Scoping rules:

- **Subjects** = the test's own artifact names: the script under test, the fixture element name(s), and any test-specific marker strings the script logs. This is what makes pre-existing/baseline noise harmless — errors that do not mention the test's subjects must not fail the test.
- **Time window** = from just before Act. Capture `DateTime.Now` on the test side; QAOps tests run on the same machine as the DataMiner, so timestamps are comparable.
- When an outcome assertion fails, additionally append `DmLogs.Tail(DmLogs.SLAutomationLog, 60)` to that assertion's message — a plain tail, because keyword-anchored windows truncated the actual exception in practice. The script-side root cause then arrives in the same QAOps run instead of requiring another instrumented rerun.

## Putting It Together (Skeleton)

```csharp
[TestMethod]
[TestCategory("IntegrationTest")]
public void Execute_Script_ProducesExpectedOutcome()
{
    IDms dms = DmsTestSetup.Dms;
    Assert.IsNotNull(dms, "DataMiner connection was not initialized.");

    // 1. Snapshot before touching anything.
    List<ProtocolElementSnapshot> preExisting = SystemState.SnapshotProtocolElements(dms, ProtocolName);
    string stateReport = SystemState.Describe($"Pre-existing '{ProtocolName}' elements", preExisting);
    Console.WriteLine(stateReport);

    IDmsElement fixture = null;
    try
    {
        // 2. Always create and target the fixture by identity.
        fixture = CreateFixtureElement(dms); // unique name + poll-wait, as above
        stateReport += Environment.NewLine + $"Fixture: '{fixture.Name}' protocol version '{fixture.Protocol.Version}'";

        // 3. Interference policy: benign artifacts are allowed; interfering ones are
        //    mirrored into expectations or fail fast here (see Interference Policy).
        // 4. Version assertion BEFORE Act when the test data is version-bound.
        Assert.IsTrue(
            fixture.Protocol.Version.StartsWith(SupportedVersionPrefix, StringComparison.Ordinal),
            $"Unsupported fixture protocol version.{Environment.NewLine}{stateReport}");

        // Act.
        DateTime actStart = DateTime.Now.AddSeconds(-2);
        dms.GetScript(ScriptName).Execute(
            Enumerable.Empty<DmsAutomationScriptParamValue>(),
            Enumerable.Empty<DmsAutomationScriptDummyValue>(),
            new DmsAutomationScriptRunOptions());

        // Assert with poll-wait; every failure message carries the evidence.
        bool outcome = WaitFor(() => OutcomeReached(dms, fixture), TimeSpan.FromMinutes(2));
        Assert.IsTrue(
            outcome,
            "Expected outcome was not reached." + Environment.NewLine + stateReport +
            Environment.NewLine + "SLAutomation tail:" + Environment.NewLine + DmLogs.Tail(DmLogs.SLAutomationLog, 60));

        // 5. Assert DataMiner logged no errors concerning this test (happy path included).
        List<string> concerning = DmLogs.FindConcerningEntries(DmLogs.SLAutomationLog, actStart, ScriptName, fixture.Name);
        Assert.AreEqual(
            0,
            concerning.Count,
            "DataMiner logged errors concerning this test:" + Environment.NewLine +
            String.Join(Environment.NewLine + "----" + Environment.NewLine, concerning) +
            Environment.NewLine + stateReport);
    }
    finally
    {
        if (fixture != null)
        {
            fixture.Delete();
        }
    }
}
```

## Rules Recap

- Snapshot first; log it; reuse it in **every** assertion message.
- Tests pass on **empty systems**: implement create-or-duplicate; pre-existing baseline content is never a precondition.
- Always create the fixture; always act and assert by identity; clean it up in `finally`.
- Pre-existing artifacts are allowed unless they interfere with the specific logic under test — then mirror them into expectations or fail fast with the snapshot in the message.
- Version-bound test data ⇒ version assertion before Act.
- Read DataMiner logs non-locking: `FileAccess.Read` + `FileShare.ReadWrite | FileShare.Delete`; never `File.ReadAllLines`/`ReadAllText`.
- After Act, assert no logged errors concern the test's subjects (script name, fixture names) within the Act time window; unrelated errors are ignored. On outcome failure, append a plain log tail, not keyword-anchored windows.
- Never fix-and-rerun on a guess: if a failure message does not name the cause, the next build improves diagnostics, not the fix.
- One run, all variants: when an experiment needs the live system (e.g. element-creation connection types), batch every candidate variant with per-variant diagnostics into a single run instead of one run per guess.
