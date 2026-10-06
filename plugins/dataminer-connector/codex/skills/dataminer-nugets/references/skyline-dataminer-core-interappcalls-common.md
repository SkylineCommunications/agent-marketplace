# Skyline.DataMiner.Core.InterAppCalls.Common

## Purpose

`Skyline.DataMiner.Core.InterAppCalls.Common` provides the DataMiner InterApp framework: a C# message and response architecture for communication between DataMiner elements, Automation scripts, and applications that can reach a DataMiner System.

Use this reference for the full InterApp lifecycle: NuGet selection, connector XML setup, message API design, executor implementation, receiver QAction implementation, sender implementation, replies, known types, broker behavior, and verification.

Official docs:

| Topic | URL |
|-------|-----|
| Introduction and requirements | https://aka.dataminer.services/InterApp |
| Getting started lifecycle | https://aka.dataminer.services/inter-app-calls-getting-started |
| Creating an API | https://aka.dataminer.services/inter-app-calls-getting-started-creating-api |
| Creating an executor | https://aka.dataminer.services/inter-app-calls-getting-started-creatin-433a8acd |
| Receiving a call | https://aka.dataminer.services/inter-app-calls-getting-started-receiving-call |
| Sending a call | https://aka.dataminer.services/InterAppCalls_GettingStarted_SendingCall |
| Known types | https://aka.dataminer.services/inter-app-calls-known-types |
| Customizations | https://aka.dataminer.services/inter-app-calls-customizations |
| Examples | https://aka.dataminer.services/inter-app-calls-examples |
| API docs | https://aka.dataminer.services/skyline-data-miner-core-inter-app-calls-common |
| NuGet | https://www.nuget.org/packages/Skyline.DataMiner.Core.InterAppCalls.Common |

---

## When To Use

| Use case | Decision |
|----------|----------|
| Element-to-element command, query, or response workflow | Use InterApp. |
| Automation script sends a command to an element and optionally waits for a response | Use InterApp. |
| Application on the same server sends a command to an element and optionally waits for a response | Use InterApp when it can reach the DataMiner System and has the required connection context. |
| Connector API package with shared request and response message classes | Use InterApp message classes. |
| Bulk operation requiring many messages in one call | Use `IInterAppCall.Messages`. |
| Simple local helper method inside one QAction only | Do not use InterApp. |
| Communication with a device or external API | Use connector communication mechanisms such as HTTP, SNMP, serial, smart-serial, WebSocket, or SSH, not InterApp. |

InterApp is mainly intended for larger projects where you control both sides of the communication channel and can adjust source and destination code to create, serialize, parse, execute, and reply to messages.

---

## Package Facts

| Item | Value |
|------|-------|
| Current observed version | `1.1.1.1` |
| Target framework | `.NET Framework 4.6.2+` |
| DataMiner range | `1.0.x` requires DataMiner 10.1.0+, `1.1.x` requires DataMiner 10.4.0+ |
| Recommended DataMiner version | DataMiner 10.3.12+ for broker-based replies and improved scalability/performance |
| GQI compatibility | Use `1.1.1.1` or higher for 64-bit GQI environments |
| Package type | Standard NuGet package, not a Dev Pack |

## Common PackageReference

Add this package anywhere InterApp message DTOs, executors, receiver logic, or sender logic are compiled.

```xml
<PackageReference Include="Skyline.DataMiner.Core.InterAppCalls.Common" Version="1.1.1.1" />
```

For connector QActions, also use the normal connector Dev Pack (`Skyline.DataMiner.Dev.Protocol`) instead of manual DataMiner DLL references.

---

## Full Lifecycle

Follow this order when designing or implementing InterApp in DataMiner:

1. Confirm the target DataMiner version and choose a compatible InterApp NuGet version.
2. Add `Skyline.DataMiner.Core.InterAppCalls.Common` to every project/QAction/API library that compiles InterApp types or logic.
3. Add the InterApp receiver and return parameters to every receiving connector.
4. Trigger a receiver QAction on `interApp_receive`.
5. Define the shared message API: request and response DTO classes inheriting from `Message`.
6. Define and maintain one complete `knownTypes` list for the API.
7. Implement destination-specific executors that translate message data into connector behavior.
8. Implement receiving logic: read raw payload, deserialize to `IInterAppCall`, execute messages, and reply when required.
9. Implement sending logic: create `IInterAppCall`, add messages, send to destination `interApp_receive`, and optionally wait for replies.
10. Handle timeout, invalid message, missing executor, reply, and broker/return-address edge cases.
11. Build the affected projects and run connector validation when connector code/XML changed.

---

## Connector XML Setup

Protocols that receive InterApp calls must include and process the reserved receiver and return parameters. Use `dataminer-protocol-xml-reference` when authoring the exact `protocol.xml` structure.

| PID | Name | Purpose |
|-----|------|---------|
| `9000000` | `interApp_receive` | Raw serialized InterApp call or message sent from an external source to the element. |
| `9000001` | `interApp_return` | Raw serialized reply message sent back to an external source. |

Required parameter characteristics from the official docs:

- `Type` is `read`.
- `Interprete/RawType` is `other`.
- `Interprete/LengthType` is `next param`.
- `Interprete/Type` is `string`.
- `Measurement/Type` is `string`.
- `trending="false"`.
- `RTDisplay onAppLevel="true"` is set to `true`.

Canonical connector parameters:

```xml
<Param id="9000000" trending="false">
   <Name>interApp_receive</Name>
   <Description>Inter App Receiver</Description>
   <Information>
      <Subtext>Contains the raw serialized InterApp Command (InterAppCall or Message) sent from an external source.</Subtext>
   </Information>
   <Type>read</Type>
   <Interprete>
      <RawType>other</RawType>
      <LengthType>next param</LengthType>
      <Type>string</Type>
   </Interprete>
   <Display>
      <RTDisplay onAppLevel="true">true</RTDisplay>
   </Display>
   <Measurement>
      <Type>string</Type>
   </Measurement>
</Param>
<Param id="9000001" trending="false">
   <Name>interApp_return</Name>
   <Description>Inter App Return</Description>
   <Information>
      <Subtext>Contains the raw serialized Message that serves as a response to an external source.</Subtext>
   </Information>
   <Type>read</Type>
   <Interprete>
      <RawType>other</RawType>
      <LengthType>next param</LengthType>
      <Type>string</Type>
   </Interprete>
   <Display>
      <RTDisplay onAppLevel="true">true</RTDisplay>
   </Display>
   <Measurement>
      <Type>string</Type>
   </Measurement>
</Param>
```

Custom receiver/return parameters are allowed only when the project controls every involved protocol and Automation script. They can reduce system traffic when many external sources require responses from one element, but the reserved parameters must still be present and processed.

Receiver QAction rules:

- Trigger a QAction on `interApp_receive` (`9000000`).
- The QAction reads the raw triggered parameter value.
- The QAction deserializes and executes a bulk InterApp call.
- Do not receive both single `Message` payloads and bulk `IInterAppCall` payloads on the same parameter. Prefer bulk `IInterAppCall` consistently.

---

## Core Namespaces

| Namespace | Common types |
|-----------|--------------|
| `Skyline.DataMiner.Core.InterAppCalls.Common.CallBulk` | `IInterAppCall`, `InterAppCallFactory`, `Messages` |
| `Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle` | `Message`, `MessageFactory` |
| `Skyline.DataMiner.Core.InterAppCalls.Common.MessageExecution` | `MessageExecutor<T>`, `SimpleMessageExecutor<T>`, `IMessageExecutor`, `ISimpleMessageExecutor` |
| `Skyline.DataMiner.Core.InterAppCalls.Common.Shared` | `ReturnAddress`, `Source` |
| `Skyline.DataMiner.Core.InterAppCalls.Common.Serializing` | `ISerializer`, `SerializerFactory` |

## Core Classes And Members

| Type | Key members | Use |
|------|-------------|-----|
| `Message` | `Guid`, `ReturnAddress`, `BrokerReturnAddress`, `Source`, `ExpectsReply` | Base class for a single request or response. Custom messages inherit from this. |
| `Message` | `Send(...)`, `Reply(...)`, `TryExecute(...)`, `Serialize(...)` | Send, reply, execute mapped executor logic, or serialize. |
| `IInterAppCall` | `Guid`, `Messages`, `ReturnAddress`, `Source`, `ExpectsReply` | Bulk call containing multiple messages. |
| `IInterAppCall` | `Send(...)` | Send a bulk call, optionally waiting for replies. |
| `InterAppCallFactory` | `CreateNew()` | Create a blank bulk call. |
| `InterAppCallFactory` | `CreateFromRaw(...)`, `CreateFromRawAndAcceptMessage(...)` | Deserialize raw InterApp payloads. |
| `InterAppCallFactory` | `CreateFromRemote(...)`, `CreateFromRemoteAndAcceptMessage(...)` | Create a call from a remote parameter value. |
| `MessageFactory` | `CreateNew()`, `CreateFromRaw(...)`, `CreateFromRemote(...)` | Single-message factory. |
| `MessageExecutor<T>` | `DataGets`, `Parse`, `Validate`, `Modify`, `DataSets`, `CreateReturnMessage` | Template Method executor for structured processing. |
| `SimpleMessageExecutor<T>` | `TryExecute(object, object, out Message)` | Compact executor for simple message handling. |
| `ReturnAddress` | `AgentId`, `ElementId`, `ParameterId` | Parameter location monitored for replies when broker is not used. |
| `Source` | `Name`, `AgentId`, `ElementId` | Identifies where the message came from. |
| `InterAppCommunication` | `MaxMessageSize` | Broker message size limit information. |

---

## Message API Design

Create an API with the request and response classes that represent the messages you want to exchange. Every message class inherits from `Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle.Message`. The `SetInputRequest` and `SetInputResponse` classes below are user-defined DTO examples, not framework-provided classes.

```csharp
using Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle;

public class SetInputRequest : Message
{
    public string PrimaryKey { get; set; }

    public int TargetState { get; set; }
}

public class SetInputResponse : Message
{
    public string PrimaryKey { get; set; }

    public bool Success { get; set; }

    public string Error { get; set; }
}
```

API rules:

- Keep message classes data-only. Do not put connector logic, business execution logic, `SLProtocol`, `IEngine`, database handles, external resources, or methods in message classes.
- Use the exact same namespace on the sender and receiver side.
- Prefer copying message class definitions into the consuming scripts/connectors when assembly resolution would otherwise be fragile.
- A separate shared API NuGet can be used when packaging and assembly resolution are controlled.
- Add version comments at the top of copied API blocks so copied DTOs can be compared across connectors/scripts.
- The default serializer is designed to handle custom classes, inheritance, abstraction, interfaces, private fields, public properties, and objects. Do not design DTOs around JSON-specific attributes unless a custom serializer requires it.

---

## Known Types

InterApp must know every type that can appear in a serialized message graph. Keep one complete known-types list for the API and use equivalent lists on every sender and receiver.

```csharp
public static readonly List<Type> KnownTypes = new List<Type>
{
    typeof(SetInputRequest),
    typeof(SetInputResponse),
    typeof(MyNestedDto),
    typeof(List<MyNestedDto>),
};
```

Known-types rules:

- Include every custom request message, response message, nested DTO, subclass, interface implementation, and generic collection type that may be serialized or deserialized.
- Keep known-types lists equivalent at sender and receiver. It is not supported to serialize with `(Type1, Type2, Type3)` and deserialize with only `(Type1, Type2)`.
- Keep namespaces identical across source and destination. Mismatched known types can result in serialized type names that do not match the deserializer expectation.
- Prefer a public static known-types list in the shared/copyable API block to avoid drift.

---

## Creating An Executor

Executors live at the destination of a message. They are not shared between connectors or Automation scripts because they translate a message into destination-specific behavior.

Use an executor to:

- Translate message content into a serial, SNMP, HTTP, WebSocket, SSH, or device command.
- Read or write connector parameters based on message content.
- Fill or update tables.
- Create Automation script feedback.
- Return a response message to the sender.

### Template Executor

Use `MessageExecutor<T>` when the standard processing phases add clarity.

```csharp
using System;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle;
using Skyline.DataMiner.Core.InterAppCalls.Common.MessageExecution;
using Skyline.DataMiner.Scripting;

public class SetInputRequestExecutor : MessageExecutor<SetInputRequest>
{
    public SetInputRequestExecutor(SetInputRequest message) : base(message)
    {
    }

    public override bool Validate()
    {
        return !String.IsNullOrWhiteSpace(Message.PrimaryKey);
    }

    public override void DataSets(object dataDestination)
    {
        var protocol = (SLProtocol)dataDestination;
        protocol.SetParameterIndexByKey(Parameter.Inputs.tablePid, Message.PrimaryKey, Parameter.Inputs.Idx.inputsstate + 1, Message.TargetState);
    }

    public override Message CreateReturnMessage()
    {
        return new SetInputResponse { Guid = Message.Guid, PrimaryKey = Message.PrimaryKey, Success = true };
    }
}
```

The framework executes `MessageExecutor<T>` phases in this order:

1. `DataGets(dataSource)` always.
2. `Parse()` always.
3. `Validate()` always.
4. `Modify()` only when validation returns `true`.
5. `DataSets(dataDestination)` only when validation returns `true`.
6. `CreateReturnMessage()` always.

Default flow:

```csharp
executor.DataGets(dataSource);
executor.Parse();

bool result = executor.Validate();

if (result)
{
    executor.Modify();
    executor.DataSets(dataDestination);
}

optionalReturnMessage = executor.CreateReturnMessage();

return result;
```

### Simple Executor

Use `SimpleMessageExecutor<T>` when one method is enough and the Template Method phases would add bloat.

```csharp
using Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle;
using Skyline.DataMiner.Core.InterAppCalls.Common.MessageExecution;

public class SetInputSimpleExecutor : SimpleMessageExecutor<SetInputRequest>
{
    public SetInputSimpleExecutor(SetInputRequest message) : base(message)
    {
    }

    public override bool TryExecute(object dataSource, object dataDestination, out Message optionalReturnMessage)
    {
        optionalReturnMessage = new SetInputResponse { Guid = Message.Guid, PrimaryKey = Message.PrimaryKey, Success = true };
        return true;
    }
}
```

Executor rules:

- Cast `dataSource` and `dataDestination` to `SLProtocol`, `IEngine`, or a custom context type inside the executor.
- Do not store runtime objects in the message DTO.
- `CreateReturnMessage` or `TryExecute` can return `null` when no reply content is needed.
- Return messages can also be used internally to pass structured data between classes, methods, or QActions; they do not always have to be sent externally.

---

## Receiving A Bulk Call

Trigger a QAction on `interApp_receive`, read the raw triggered parameter, deserialize with the known types, and execute each message through the message-to-executor map.

### Without Reply

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallBulk;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle;
using Skyline.DataMiner.Scripting;

public class QAction
{
    private static readonly List<Type> KnownTypes = new List<Type>
    {
        typeof(SetInputRequest),
        typeof(SetInputResponse),
    };

    private static readonly Dictionary<Type, Type> MessageToExecutor = new Dictionary<Type, Type>
    {
        { typeof(SetInputRequest), typeof(SetInputRequestExecutor) },
    };

    public static void Run(SLProtocol protocol)
    {
        try
        {
            string raw = Convert.ToString(protocol.GetParameter(protocol.GetTriggerParameter()));
            IInterAppCall call = InterAppCallFactory.CreateFromRaw(raw, KnownTypes);

            foreach (Message message in call.Messages)
            {
                message.TryExecute(protocol, protocol, MessageToExecutor, out Message optionalReturnMessage);
            }
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

### With Reply

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallBulk;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle;
using Skyline.DataMiner.Scripting;

public class QAction
{
    private static readonly List<Type> KnownTypes = new List<Type>
    {
        typeof(SetInputRequest),
        typeof(SetInputResponse),
    };

    private static readonly Dictionary<Type, Type> MessageToExecutor = new Dictionary<Type, Type>
    {
        { typeof(SetInputRequest), typeof(SetInputRequestExecutor) },
    };

    public static void Run(SLProtocol protocol)
    {
        try
        {
            string raw = Convert.ToString(protocol.GetParameter(protocol.GetTriggerParameter()));
            IInterAppCall call = InterAppCallFactory.CreateFromRaw(raw, KnownTypes);

            foreach (Message message in call.Messages)
            {
                if (message.TryExecute(protocol, protocol, MessageToExecutor, out Message response) && response != null)
                {
                    message.Reply(protocol.SLNet.RawConnection, response, KnownTypes);
                }
            }
        }
        catch (Exception ex)
        {
            protocol.Log($"QA{protocol.QActionID}|{protocol.GetTriggerParameter()}|Run|Exception thrown:{Environment.NewLine}{ex}", LogType.Error, LogLevel.NoLogging);
        }
    }
}
```

Receiver rules:

- Use `protocol.GetTriggerParameter()` so the QAction can read the parameter that triggered it.
- Use `InterAppCallFactory.CreateFromRaw(raw, knownTypes)` for bulk calls.
- Keep the message-to-executor map local to the destination connector/script implementation.
- Wrap production receiver logic in `try/catch` and log exceptions with the QAction ID and trigger parameter.
- Do not call `Reply` if no reply is expected or if no response message was created.
- Include response DTO types in `KnownTypes` when replies are possible.

---

## Sending Without Response

Create a bulk call, add one or more messages, and send the call to the destination element's InterApp receiver parameter.

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallBulk;
using Skyline.DataMiner.Scripting;

public static void SendWithoutResponse(SLProtocol protocol, int dmaId, int elementId)
{
    List<Type> knownTypes = new List<Type>
    {
        typeof(SetInputRequest),
    };

    IInterAppCall call = InterAppCallFactory.CreateNew();
    call.Messages.Add(new SetInputRequest { PrimaryKey = "1", TargetState = 1 });

    call.Send(protocol.SLNet.RawConnection, dmaId, elementId, 9000000, knownTypes);
}
```

---

## Sending With Response

When waiting for replies, set a valid return path when required, send with a timeout, and execute or inspect returned messages.

```csharp
using System;
using System.Collections.Generic;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallBulk;
using Skyline.DataMiner.Core.InterAppCalls.Common.CallSingle;
using Skyline.DataMiner.Core.InterAppCalls.Common.Shared;
using Skyline.DataMiner.Scripting;

public static void SendWithResponse(SLProtocol protocol, int dmaId, int elementId)
{
    List<Type> knownTypes = new List<Type>
    {
        typeof(SetInputRequest),
        typeof(SetInputResponse),
    };

    IInterAppCall call = InterAppCallFactory.CreateNew();
    call.ReturnAddress = new ReturnAddress(dmaId, elementId, 9000001);
    call.Messages.Add(new SetInputRequest { PrimaryKey = "1", TargetState = 1 });

    IEnumerable<Message> responses = call.Send(protocol.SLNet.RawConnection, dmaId, elementId, 9000000, TimeSpan.FromMinutes(1), knownTypes);

    foreach (Message response in responses)
    {
        var setInputResponse = response as SetInputResponse;
        if (setInputResponse == null)
        {
            continue;
        }

        // Handle the response in the sender context.
    }
}
```

Sender rules:

- Send to the destination element receiver parameter, normally `9000000`.
- Include all request and response types in `knownTypes` when waiting for replies.
- Handle `TimeoutException` when using the timeout overload.
- Use a destination-side return parameter for `ReturnAddress` when it is needed.
- Never set `ReturnAddress` to a parameter on the source element when sending from an element and waiting in the same QAction. This can deadlock because the sending QAction blocks while waiting and the response cannot be set on the source element.
- For connector QActions, use `protocol.SLNet.RawConnection`.

---

## ReturnAddress And Broker Rules

| Situation | Rule |
|-----------|------|
| DataMiner 10.3.12+ with broker allowed | `ReturnAddress` is normally optional because broker-based return addressing is used. |
| DataMiner below 10.3.12 | `ReturnAddress` is required for replies. |
| `allowBroker` is `false` | `ReturnAddress` is required because replies use SLNet subscriptions instead of broker routing. |
| `LegacyInterAppSubscriptions` soft-launch option is enabled | `ReturnAddress` is required because broker routing is disabled system-wide. |
| Sending from an element and waiting in the same QAction | Do not use a source-element return parameter. Prefer the destination element return parameter `9000001`. |

Broker notes:

- DataMiner 10.3.12+ uses the message broker for replies by default, which improves scalability and performance compared to SLNet subscriptions.
- The broker can be disabled per call by passing `allowBroker: false` to supported `Send` overloads.
- The broker can also be disabled system-wide with the `LegacyInterAppSubscriptions` soft-launch option.
- Watch `InterAppCommunication.MaxMessageSize` and `MessageTooBigException` for large broker replies.

---

## Custom Serializer

The default InterApp serializer is intentionally broad and supports complex object graphs. Only implement a custom serializer when the project has a concrete serialization requirement.

Any factory method that creates a call/message and any send method has overloads that accept an implementation of `Skyline.DataMiner.Core.InterAppCalls.Common.Serializing.ISerializer`.

Custom serializer rules:

- Implement both serialize and deserialize behavior.
- Keep the custom serializer available wherever the matching payload must be read or written.
- Do not introduce a custom serializer only to control JSON property names; InterApp normally abstracts this away.

---

## Pitfalls

| Pitfall | Correct handling |
|---------|------------------|
| Treating InterApp as device communication | Use InterApp only for DataMiner-to-DataMiner/application messaging, not device APIs. |
| Missing connector receiver/return parameters | Add and process `9000000` and `9000001` on receiving protocols. |
| Receiving single messages and bulk calls on the same parameter | Do not mix them. Prefer `IInterAppCall` bulk calls. |
| Passing `SLProtocol` or `IEngine` inside messages | Keep runtime objects outside messages. Use `dataSource` and `dataDestination` in executors. |
| Message classes contain logic | Keep message DTOs data-only; put behavior in executors. |
| Namespace drift between sender and receiver DTOs | Keep namespaces identical or deserialize will fail/misinterpret types. |
| Incomplete known types | Add all request, response, nested, subclass, and collection types to the known-types list. |
| Different known-types lists at sender and receiver | Use equivalent lists everywhere. |
| Replying to a message that does not expect a reply | Check flow design; `Reply` can throw `InvalidOperationException`. |
| Replying with `null` | Skip `Reply` when no response message was created. |
| Source-element `ReturnAddress` while waiting in the same QAction | Use a destination-side return parameter to avoid deadlock. |
| Large broker replies | Watch `MessageTooBigException` and `InterAppCommunication.MaxMessageSize`. |
| No timeout handling | Catch `TimeoutException` at the sender when waiting for replies. |
| Adding package references but not building | Run `dotnet restore` and `dotnet build` for affected projects. |

---

## Verification

For docs-only skill changes, run targeted searches to confirm stale references are gone.

For connector/package changes:

```bash
dotnet restore "<solution-or-project>"
dotnet build "<solution-or-project>"
```

For connector XML/QAction changes, also run the official validator through `dataminer-validation` and SDK guidance. Validator-relevant InterApp issues include invalid reply logic, missing package references, build failures, invalid QAction triggers, and malformed connector parameters.
