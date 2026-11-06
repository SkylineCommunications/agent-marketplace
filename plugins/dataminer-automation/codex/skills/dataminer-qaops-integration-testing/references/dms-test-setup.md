# Real DataMiner MSTest Setup

Use this template in an MSTestV2 integration test project that runs on QAOps. Adapt the namespace and nullable annotations to match the target project.

```csharp
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Skyline.DataMiner.CICD.Tools.WinEncryptedKeys.Lib;
using Skyline.DataMiner.Core.DataMinerSystem.Common;
using Skyline.DataMiner.Net;

[TestClass]
public static class DmsTestSetup
{
    private const string Host = "localhost";
    private const int ConnectionTimeout = 120000;
    private const string SubscriptionSetId = "IntegrationTests";

    private static Connection connection;
    private static bool subscriptionsInitialized;

    public static IDms Dms { get; private set; }

    [AssemblyInitialize]
    public static void AssemblyInitialize(TestContext context)
    {
        try
        {
            connection = Skyline.DataMiner.Net.ConnectionSettings.GetConnection(Host);
            connection.ClientApplicationName = "VSTEST.CONSOLE.EXE";
            connection.PollingRequestTimeout = ConnectionTimeout;
            connection.ConnectTimeoutTime = ConnectionTimeout;
            connection.AuthenticateMessageTimeout = ConnectionTimeout;

            if (!Keys.TryRetrieveKey("QAOpsDataMinerUser", out string userName) || String.IsNullOrWhiteSpace(userName))
            {
                throw new InvalidOperationException("Could not retrieve 'QAOpsDataMinerUser'.");
            }

            if (!Keys.TryRetrieveKey("QAOpsDataMinerPassword", out string password) || String.IsNullOrWhiteSpace(password))
            {
                throw new InvalidOperationException("Could not retrieve 'QAOpsDataMinerPassword'.");
            }

            connection.Authenticate(userName, password);
            connection.Subscribe();
            connection.ClearSubscriptions(SubscriptionSetId);
            subscriptionsInitialized = true;

            Dms = connection.GetDms();
        }
        catch
        {
            // CRITICAL: DisposeConnection must NEVER throw here. If cleanup throws it REPLACES
            // the real AssemblyInitialize failure (e.g. a FileLoadException from a dependency, or
            // an InvalidOperationException from a missing key) with a misleading cleanup exception,
            // or causes the test host to abort with no per-test row at all. See the masking note below.
            DisposeConnection();
            throw;
        }
    }

    [AssemblyCleanup]
    public static void AssemblyCleanup()
    {
        DisposeConnection();
    }

    private static void DisposeConnection()
    {
        Dms = null;

        if (connection == null)
        {
            return;
        }

        try
        {
            // Only clear subscriptions when they were actually established. Calling
            // ClearSubscriptions (or Close) on a connection that never authenticated throws
            // DataMinerSecurityException ("Attempt to use an unauthenticated connection"),
            // which — when DisposeConnection runs from the catch in AssemblyInitialize —
            // masks the original failure.
            if (subscriptionsInitialized)
            {
                connection.ClearSubscriptions(SubscriptionSetId);
            }

            connection.Close();
        }
        catch (Exception ex)
        {
            // Cleanup must never mask the original test/initialize failure. Swallow and log only.
            Console.WriteLine("DmsTestSetup cleanup error (suppressed): " + ex);
        }
        finally
        {
            connection.Dispose();
            connection = null;
            subscriptionsInitialized = false;
        }
    }
}
```

## Notes

- `Connection` and `ConnectionSettings` (namespace `Skyline.DataMiner.Net`) come from the **`Skyline.DataMiner.Files.SLNetTypes`** NuGet package. `Skyline.DataMiner.Net` itself is not a NuGet package, and DLLs from a local DataMiner install must never be referenced.
- `ConnectionSettings.GetConnection` must be fully qualified as `Skyline.DataMiner.Net.ConnectionSettings.GetConnection` because `Skyline.DataMiner.Core.DataMinerSystem.Common` also defines a `ConnectionSettings` type (CS0104 otherwise).
- `QAOpsDataMinerUser` and `QAOpsDataMinerPassword` are retrieved from encrypted keys. Do not put credentials in source code.
- These encrypted keys only exist on the QAOps-provisioned DataMiner. Running this setup locally fails with authentication errors by design — do not try to make local `dotnet test` work; verify through a QAOps run instead.
- Keep `ClientApplicationName` as `VSTEST.CONSOLE.EXE` for QAOps test execution.
- Keep the connection timeout high enough for clean DaaS startup and real DataMiner operations.
- If nullable reference types are enabled, make `connection` and `Dms` nullable or initialize them according to the project style.
- Tests should use `DmsTestSetup.Dms` and should clean up any DataMiner state they create.

## Cleanup Must Never Mask the AssemblyInitialize Failure (Verified — Cost 3 QAOps Runs)

The most important property of this template is that **cleanup-on-failure must never throw over the real failure**. A measured session lost **three QAOps runs** to an earlier version of this template that called `connection.ClearSubscriptions(...)` / `connection.Close()` unconditionally from the failure path:

- The real failure was a `FileLoadException` thrown by `Keys.TryRetrieveKey(...)` (a dependency-binding problem — see the QAOps integration-testing skill's troubleshooting).
- `AssemblyInitialize`'s `catch` called `DisposeConnection()`, which called `ClearSubscriptions` on a connection that had **never authenticated** → `DataMinerSecurityException: Attempt to use an unauthenticated connection`.
- That cleanup exception **replaced** the original `FileLoadException`. Every QAOps run reported the misleading `DataMinerSecurityException` (or, on some iterations, **no per-test row at all** — just `FINISHED FAIL [CompletedWithFailures]`), so the agent chased a phantom auth/cleanup problem instead of the real dependency error.

Rules baked into the template above:

- Track whether subscriptions were actually established (`subscriptionsInitialized`); only clear them in that case.
- Wrap all cleanup in `try { ... } catch (Exception) { /* log only */ }` so it can never propagate over the original failure.
- Reset state in `finally`.

## Diagnostics That Actually Reach the Agent

When an integration test fails on QAOps, the only diagnostics the agent's `-rf` JSON / `LOG_LINES` channel receives are the **per-test assertion/exception messages** the publishing helper extracts from the TRX. Consequences for this setup:

- **`Console.WriteLine(...)` tracing in `AssemblyInitialize`/tests does NOT reach `LOG_LINES`** — it goes into the TRX test detail, visible only in the QAOps UI (`BUILD_URL`), which the agent cannot authenticate to. Do not rely on `Console.WriteLine` to diagnose a QAOps run; put the diagnostic in the thrown exception message or the assertion message.
- A `FINISHED FAIL [CompletedWithFailures]` run with **no per-test row** means no per-test result was produced or published: `AssemblyInitialize` threw, the test host aborted before writing a usable TRX, or the pipeline **bypassed or gated** `Invoke-DotNetTestAndPublishResults`. First make cleanup non-masking (above) **and confirm the pipeline reaches the helper un-gated** (`dataminer-qaops-integration-testing/references/test-package-pipeline.md` → "Pipeline Integrity — Never Gate the Publishing Helper"). Only if rows are still missing, add an **additive, non-throwing** `dotnet test "<assembly>" --logger "console;verbosity=detailed"` step that runs **after** the helper and publishes a short truncated tail as its own `Push-TestCaseResult` row — **never** as a `throw`/`exit` placed *before* the helper. A failing test makes `dotnet test` exit non-zero, so a gating `if ($LASTEXITCODE){ throw }` suppresses every per-test row and is a known multi-run dead end.
