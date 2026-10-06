---
name: dataminer-http-communication
description: 'HTTP/HTTPS communication for DataMiner connectors: session and connection structure, request/response handling, authentication, HTTPS, dynamic configuration, and JSON response parsing. Use when implementing or modifying HTTP communication in connectors.'
argument-hint: 'Describe the HTTP task: e.g. "add HTTP session for REST API", "configure HTTPS with certificate", "parse JSON response"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-14
  version: 1.3
---

# DataMiner HTTP Communication

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.3 | 2026-09-14 | Corrected the HTTP read-versus-dummy rationale independently of optional generated helper output. |
| 1.2 | 2026-09-11 | Corrected keyed authentication headers, secret handling, secure JSON deserialization, and certificate-validation guidance. |

This skill provides guidance for implementing HTTP/HTTPS communication in DataMiner connectors.

## Purpose

HTTP is a common protocol for device communication, REST APIs, and web services. This skill covers:
- Session and connection structure
- Request/response handling
- Authentication and HTTPS
- Dynamic configuration
- JSON response parsing

## Reference Files

| File | Contents | Use Case |
|------|----------|----------|
| `http-fundamentals.md` | Overview, sessions, authentication, status codes | Understanding HTTP in DataMiner |
| `http-implementation.md` | Requests, headers, body, responses | Building HTTP sessions |
| `http-configuration.md` | Element config, dynamic IP, HTTPS, proxy | Runtime configuration |
| `http-parsing.md` | Secure JSON parsing with the SecureCoding runtime and analyzer packages | Processing API responses |
| `http-examples.md` | Complete examples, patterns, internal flow | Implementation reference |

## Parameter Type Rules for HTTP Connectors

HTTP response parameters **MUST** use `<Type>read</Type>` — **NEVER** `<Type>dummy</Type>`.

| Parameter Purpose | `<Type>` | `<RTDisplay>` | Notes |
|-------------------|----------|---------------|-------|
| HTTP status code (e.g. PID 100) | `read` | `false` | Internal value for QAction error checking |
| HTTP response body (e.g. PID 101) | `read` | `false` | Intermediate — parsed by QAction |
| Parsed scalar (user-facing) | `read` | `true` | Displayed on element page |
| Parsed scalar (internal) | `read` | `false` | Used by other QActions, not operator-facing |
| AfterStartup / QAction trigger | `dummy` | `false` | Carries no data — exists only to trigger a QAction |

**Why not `dummy`?** — This is a runtime/data-model rule, not a generated-helper limitation. A dummy parameter is intended as an internal trigger and does not represent stored response data. Generated helper versions can expose a dummy `SLProtocolExt` property, but response status/body values must still use `read` parameters.

## When to Load

| Task | Load These Files |
|------|------------------|
| New HTTP connector | All files |
| Adding HTTP session | `http-fundamentals.md` + `http-implementation.md` |
| Dynamic IP/HTTPS setup | `http-configuration.md` |
| Parsing JSON responses | `http-parsing.md` |
| Need examples | `http-examples.md` |

## Documentation

Online docs: `https://aka.dataminer.services/http-connections`

## Related Skills

- [Protocol Schema Reference](../dataminer-connector-core/SKILL.md) - XML schema for HTTP elements
- [QActions](../dataminer-connector-core/references/logic-qactions.md) - Processing HTTP responses
- [Execution Flow](../dataminer-connector-core/references/logic-execution-flow.md) - How sessions execute
