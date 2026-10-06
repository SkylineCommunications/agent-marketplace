---
name: dataminer-connector-debugging
description: Read-only DataMiner connector runtime investigation and performance guidance. Separates protocol code, device/communication, and DataMiner environment causes and routes evidence gathering through supported diagnostic tools.
argument-hint: 'Describe the connector symptom: e.g. "RTE with pending calls", "SNMP table is slow", "smart-serial server queue grows", or "QAction is not receiving data"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-16 | Initial runtime investigation, SNMP performance, smart-serial, Swarming, TLS, and evidence-routing guidance. |

# DataMiner Connector Debugging

Use this skill for read-only diagnosis of an existing connector when the symptom is runtime behavior, missing data, slow polling, a protocol-thread RTE, a growing communication queue, or an environment-dependent failure. Load `dataminer-connector-core`, `dataminer-validation`, and the relevant communication skill alongside this one.

This skill does not authorize code, XML, deployment, certificate, or logging-level changes. A diagnosis must identify the evidence and the owner of the next change.

## First classify the failure

| Evidence pattern | Likely owner | Prove before recommending a fix |
|---|---|---|
| Build/validator error, broken trigger chain, exception, or incorrect table mapping | Connector source | Reproduce from the checked-out XML/C# and the exact build/validator output |
| Timeouts, malformed replies, unsupported SNMP operation, TLS handshake failure, or unexpected device behavior | Device or communication path | Capture the request/response or connection evidence and compare it with the device/API contract |
| RTE, pending protocol calls, CPU/disk pressure, missing certificate on a DMA, element configuration, or version-gated behavior | DataMiner environment | Record DMA/DataMiner version, element state, target DMA, relevant logs, and the supported-version boundary |

Do not call a device or environment problem a connector defect without evidence from the corresponding owner.

## Investigation workflow

1. Record the symptom, expected behavior, affected element/protocol version, DataMiner version, DMA, connection type, time window, and whether the issue is reproducible.
2. Read `protocol.xml`, the complete affected QAction source, and the solution/project files. Trace the full parameter → group/timer → trigger/action/QAction → response path.
3. Check the applicable communication reference:
   - SNMP tables: `dataminer-xml-authoring/references/advanced-connectivity.md` and the official [SNMP table retrieval guide](https://aka.dataminer.services/connections-snmp-retrieving-tables).
   - Serial or smart-serial: `dataminer-xml-authoring/references/serial-connections.md`.
   - HTTP/REST: `dataminer-http-communication`.
4. Gather runtime evidence without changing production behavior:
   - DataMiner/Cube logs and the Watchdog log for the first RTE (`count = 1`).
   - SLNetClientTest protocol pending calls while the RTE is active; use the no-lock diagnostic only when the element is fully stuck.
   - Stream Viewer for the affected element to correlate requests, responses, groups, connections, and pairs.
   - DIS Inject only when Visual Studio and an exact same-protocol test element are available; attach the debugger only after the QAction project is linked and the impact is understood.
5. Compare the evidence with the source trace. State whether the break is in connector logic, device/transport behavior, or the DataMiner environment.
6. Run the narrowest safe build and validator checks. Do not alter files during an investigation.

### Supported diagnostic references

- [Investigating a protocol thread RTE](https://aka.dataminer.services/Investigating-a-protocol-thread-RTE)
- [Retrieving protocol pending calls](https://aka.dataminer.services/how-to-retrieve-protocol-pending-calls)
- [Connecting to an element using Stream Viewer](https://aka.dataminer.services/Connecting_to_an_element_using_Stream_Viewer)
- [DIS Inject](https://aka.dataminer.services/dis-inject-tool-window)
- [DataMiner logging](https://aka.dataminer.services/data-miner-logging)

## RTE and pending-call diagnosis

- Treat the documented 15-minute protocol-thread RTE threshold as a diagnostic signal, not a target runtime. A half-open RTE can surface at 7.5 minutes.
- Find the first RTE in the Watchdog log, then request pending calls while the alarm is active. The longest-running group or linked logic is evidence of the blocking component.
- Trace linked logic and break long cascades into separate groups in a later change plan. Do not infer the root cause from the RTE alarm alone.
- Check for a third-party process, device, or network dependency that can block retrieval before blaming QAction code.
- Existing connector performance gates remain useful evidence: avoid protocol calls in loops, keep `GetColumns` below 120 K cells per call, sets below 20 K cells, `FillArray` below 1000 rows per call, and avoid actions that can approach the RTE threshold. Treat these as review limits, not a substitute for measurements.

## SNMP table performance and compatibility

Use the official retrieval guide as the authority for the table's `options` and target-version behavior:

1. Start with `multipleGetBulk` when the device supports SNMPv2 or later and the table can be retrieved reliably.
2. For SNMPv1, use `multipleGetNext`; GetBulk is not available.
3. If the device cannot handle `multipleGetNext` because of memory or processing limits, evaluate `bulk` (GetNext + MultipleGet, column-based) and reduce the number of cells requested.
4. Prefer row-complete methods (`multipleGet`, `multipleGetNext`, or `multipleGetBulk`) when indexes can shift during polling. Avoid plain `GetNext` unless its compatibility tradeoff is intentional.
5. Choose `multipleGetBulk:<max-repetitions>` using packet captures and device behavior. The docs use 10 as the default when omitted, but the safe value is device/path-dependent.
6. Check path MTU: the docs recommend keeping typical Ethernet SNMP responses below 1472 bytes of payload to avoid fragmentation, but do not treat 1472 as universal for every path.
7. Record table row/cell volume, response size, request count, poll duration, device CPU/memory symptoms, and DataMiner resource impact before changing retrieval options.

Do not label an SNMP table "slow" without identifying the retrieval method, requested cell volume, response size, and whether the device or DataMiner is the bottleneck.

## Logging and resource load

Use the DataMiner logging page to raise only the relevant module and only for the required capture window. Higher log levels consume DMA CPU and disk resources. Save the before/after level, target module, timestamps, and the restoration step in the investigation record.

For smart-serial server queues, check `SLErrorsInProtocol.txt` and the element's communication rate. From DataMiner 10.6.6/10.7.0 onward, the documented queue thresholds are 200 MB for a notice and 300 MB for an error; at the maximum, incoming messages are rejected and data can be lost. Treat repeated thresholds as evidence of source rate, connector processing, or DMA resource pressure.

## Smart-serial server, Swarming, and TLS edge cases

- A smart-serial server listens when its IP is `any`; record the port, client count, allowed-IP configuration, and whether replies must return to the initiating client.
- Server-mode Swarming is disabled by default. From DataMiner 10.6.6/10.7.0, it can be enabled with the documented `<Swarming><BypassChecks><Check>smartSerialAsServer</Check></BypassChecks></Swarming>` only when startup logic can tell the data source where to send data.
- TLS server configuration requires the PKCS12 certificate on every DMA that can host the element, `ConfigureTLSMessage` through SLNetClientTest, and a restart of affected elements after certificate replacement. TLS and non-TLS elements cannot share a TCP/IP port.
- Record the exact DataMiner version before applying any version-gated conclusion.

## Output contract

Report:

1. **Symptom and scope** — element, protocol/version, DataMiner/DMA version, connection, and time window.
2. **Data-flow trace** — the expected chain and the first observed break.
3. **Evidence** — file/line, log name/time, pending-call item, Stream Viewer observation, packet capture, or environment setting.
4. **Owner classification** — connector, device/communication, or DataMiner environment.
5. **Recommended next step** — a bounded change or additional evidence request; do not apply it in read-only mode.
6. **Confidence and unknowns** — explicitly list missing evidence and questions.

## Run coordination

If a manifest path or log directory is provided, load `dataminer-manifest` and `dataminer-logging`, update only the investigator-owned entry, and append structured events. Skip silently when neither is provided.
