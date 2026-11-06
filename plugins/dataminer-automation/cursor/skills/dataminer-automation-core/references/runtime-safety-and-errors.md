# Automation Runtime Safety, Errors, and Diagnostics

Canonical runtime contract for DataMiner Automation scripts. These rules apply to Automation script code and to every object obtained through `IEngine`/`Engine`; they are not a broad ban on asynchronous programming in unrelated client applications.

> **Parent skill**: `dataminer-automation-core/SKILL.md`. API map: `references/engine-api-overview.md`. C# authoring rules: `dataminer-automation-scripting`.

---

## 1. Keep Automation work on the `Run` thread

DataMiner Automation executes the script on a single thread. The entry point is synchronous:

```csharp
public void Run(IEngine engine)
```

The following are prohibited in Automation scripts:

- Do not define an `async` Automation entry point;
- Do not define `async void` methods;
- Do not use `Task.Run`;
- Do not use `Parallel.For` or `Parallel.ForEach`;
- Do not use manually started threads, including `new Thread(...).Start()`.

`IEngine`/`Engine` is not thread-safe. Keep all Automation and DataMiner interaction on the original `Run` thread. Never capture, pass, access, or continue using any of these from a worker thread:

- `IEngine` or `Engine`;
- an `Element` returned by `FindElement`, `FindElementByKey`, or `FindElementsByProtocol`;
- a `ScriptDummy` returned by `GetDummy`;
- a `ScriptParam`, memory object, sub-script object, or any other value obtained through the engine;
- `IDms`, `IDmsElement`, `IDmsTable`, or other DataMinerSystem objects obtained through `engine.GetDms()`;
- any other Automation/DataMiner object reached through one of those objects.

Do not move an Engine-derived object to another thread and then marshal it back. Obtain and use it only on the `Run` thread.

### Calling an external async library

A genuinely external library operation may expose only an async API. Consume that operation synchronously on the `Run` thread, and pass it only detached, non-DataMiner inputs. The returned value must be plain detached data. Resume every Engine/DataMiner operation on the same `Run` thread.

```csharp
private static string ReadExternalText(System.Net.Http.HttpClient client, System.Uri endpoint)
{
    return client.GetStringAsync(endpoint).GetAwaiter().GetResult();
}

private static void RunSafe(IEngine engine, System.Net.Http.HttpClient client, System.Uri endpoint)
{
    string externalText = ReadExternalText(client, endpoint);

    // This Engine call remains on the Run thread. Do not pass engine or Element to the client.
    Element element = engine.FindElement("Target Element");
    if (element == null)
    {
        engine.ExitFail("The requested element was not found.");
        return;
    }

    if (!element.IsActive)
    {
        engine.ExitFail("The requested element is not active.");
        return;
    }

    element.SetParameter(100, externalText);
}
```

Do not pass or capture `engine`, an `Element`, a dummy, script parameter/memory object, an `IDms` object, or a callback that uses one in the external async call. Do not log raw external payloads or sensitive inputs.

---

## 2. Canonical entry-point error wrapper

Use this wrapper. IAS code must retain the `InteractiveUserDetachedException` catch. It is also safe for a shared scaffold to retain that catch in non-interactive code.

```csharp
public void Run(IEngine engine)
{
    try
    {
        RunSafe(engine);
    }
    catch (ScriptAbortException)
    {
        throw;
    }
    catch (ScriptForceAbortException)
    {
        throw;
    }
    catch (ScriptTimeoutException)
    {
        throw;
    }
    catch (InteractiveUserDetachedException)
    {
        throw;
    }
    catch (Exception ex)
    {
        engine.Log("Run|Unexpected exception: " + ex.ToString());
        engine.ExitFail("Runtime operation failed.");
    }
}
```

Why:

- `ExitSuccess` and `ExitFail` terminate through `ScriptAbortException`; rethrowing preserves the requested exit state.
- Force-abort, timeout, and IAS detach exceptions are runtime control flow and must not be converted into a generic failure.
- Unexpected exception diagnostics belong only in `engine.Log`.
- The user-facing `ExitFail` text is concise, stable, and non-secret.

For expected validation or lookup failures, use a similarly stable message such as `"Element identifier is required."` or `"The requested element was not found."`. Do not echo raw input unless it is demonstrably non-sensitive and required by the user contract.

Never put exception text, `Exception.Message`, stack traces, credentials, tokens, raw payloads, or sensitive inputs in `ExitFail`. Do not construct exception messages that contain secrets, and do not log credentials, tokens, raw payloads, or sensitive inputs.

Natural return from `Run` remains valid successful completion. Use `ExitSuccess` only when an explicit success message or result is required.

---

## 3. Information events versus diagnostic logging

`engine.GenerateInformation(string)` creates an end-user-visible information event. Use it only for a meaningful audit event, for example a material lifecycle/CRUD change or an operator action that should remain visible in operational history.

```csharp
engine.GenerateInformation("Provision|Element configuration changed.");
```

Do **not** use `GenerateInformation` for:

- tracing, debugging, progress chatter, or routine result output;
- expected/emitted counts, missing keys, or per-row/per-item loop messages;
- exception details, raw payloads, or secrets.

Use `engine.Log(string)` sparingly for non-sensitive trace and diagnostic detail, with a `MethodName|` prefix. The canonical unexpected-exception wrapper logs `ex.ToString()` and exposes only the stable `ExitFail` message. Keep all logs free of credentials, tokens, raw payloads, and sensitive inputs.

---

## 4. Pinned public API facts

The following facts were verified against `Skyline.DataMiner.Dev.Automation` 10.6.9.1 and its `Skyline.DataMiner.Files.SLManagedAutomation` 10.6.9.1 dependency. Select the package compatible with the task target; do not automatically upgrade to this evidence version.

### Verified present

- `GetScriptParam(int)` and `GetScriptParam(string)`
- `GetMemory(int)` and `GetMemory(string)`
- `GenerateInformation(string)`
- `Log(string)` and the documented `Log` overloads
- `ExitFail(string)` and `ExitSuccess(string)`
- `ShowUI(UIBuilder)`, `ShowUI(string)`, and `ShowUI(string, bool)`
- `SendSLNetMessage(DMSMessage)`
- `FindElement`, `FindElementByKey`, `FindElementsByProtocol`, `GetDummy`, and `PrepareSubScript`

`SendSLNetMessage(DMSMessage)` is public, but raw SLNet messages are version-fragile. Do not use them when a typed API exists; when unavoidable, verify the exact target-version message contract.

### Verified absent

- `GetScriptParamValue<T>`
- `SendMessage(DMSMessage)`
- parameterless `ShowUI()`

Do not use absent members in active code or examples. Do not replace a typed API with reflection or runtime probing.

---

## 5. Review checklist

- [ ] Entry point is synchronous `public void Run(IEngine engine)`.
- [ ] The script must not have an `async` entry point, `async void`, `Task.Run`, `Parallel.For`/`Parallel.ForEach`, or a manually started thread.
- [ ] Engine-derived and DataMiner objects never leave the `Run` thread.
- [ ] External async-only calls are synchronously consumed and exchange only detached plain data.
- [ ] All four runtime/detach exceptions are re-thrown where applicable.
- [ ] Unexpected exceptions use the exact diagnostic-log/stable-failure pattern.
- [ ] `ExitFail` and ordinary logs expose no exception detail, secret, token, raw payload, or sensitive input.
- [ ] `GenerateInformation` is limited to meaningful end-user audit events.
- [ ] Active API calls exist for the selected Automation Dev Pack version.
