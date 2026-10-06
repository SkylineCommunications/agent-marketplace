# Connector Authority Boundaries

This map is the routing contract for Connector work. Agents describe workflow, evidence, and
handoffs; they do not copy normative schema, API, validator, performance, or lifecycle facts into
their own prompts.

| Concern | Sole authority | Consumers should do |
|---|---|---|
| Protocol XML elements, attributes, enums, namespaces, and schema validity | `dataminer-protocol-xml-reference` plus its area-specific references | Load the reference; do not infer or extend XML grammar from an agent |
| Validator findings, severities, suppressions, and prevention rules | `dataminer-protocol-validator-prevention` | Use the prevention rule and review checklist; keep suppression rationale local to the affected XML |
| Connector runtime flow, IDs, timers, groups, conditions, and package routing | `dataminer-connector-core` and its `logic-*`/NuGet references | Use the router and load the smallest relevant reference |
| QAction API ownership, threading, bulk calls, logging, and generated helpers | `dataminer-qaction` and `dataminer-nugets` | Use the API/reference examples; do not duplicate method contracts in agents |
| Runtime investigation, RTEs, pending calls, Stream Viewer, SNMP performance, smart-serial, Swarming, and TLS | `dataminer-connector-debugging` and communication references | Classify code/device/environment causes and report evidence |
| DIS XML/C# authoring, comparer, and Automation Inject | `dataminer-dis` and its Automation workflow reference | Use DIS only as the supported interactive workflow; retain CLI/XSD/QAOps gates |
| Help pages, Catalog metadata, packaging, QAOps, publication, deployment, and rollback | `dataminer-connector-help`, `dataminer-catalog-hygiene`, `dataminer-dmprotocol-packaging`, `dataminer-qaops-*`, and `dataminer-sdk` | Keep lifecycle stages separate and record immutable artifact evidence |

When two sources disagree, prefer the pinned schema/package evidence and record the conflict in the
owning reference. An agent may summarize a rule, but its summary must point to the owner and must
not introduce a second default.
