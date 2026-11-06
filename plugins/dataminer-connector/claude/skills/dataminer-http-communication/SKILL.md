---
name: dataminer-http-communication
description: 'HTTP/HTTPS communication for DataMiner connectors: session and connection structure, request/response handling, authentication, HTTPS, dynamic configuration, and JSON response parsing. Use when implementing or modifying HTTP communication in connectors.'
argument-hint: 'Describe the HTTP task: e.g. "add HTTP session for REST API", "configure HTTPS with certificate", "parse JSON response"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-10-27
  version: 1.8
---

# DataMiner HTTP Communication

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.8 | 2026-10-27 | Added explicit `Request@url` vs `Request@pid` rules and anti-pattern warning forbidding `[param:...]` placeholders inside `Request@url`. |
| 1.7 | 2026-10-07 | Clarified parameter resolution when reusing a session across multiple queued groups (requests are not identical using only the last set values). |
| 1.6 | 2026-10-07 | Documented status code handling (1XX-6XX) and the three code classes that always contribute to Element Timeout (4XX, 5XX, 6XX System Errors). |
| 1.5 | 2026-10-07 | Documented Element Wizard connection testing using Group ping="true" attribute. |
| 1.4 | 2026-10-07 | Added HTTP request pacing and rate limiting guidance via Timer.Interval. |
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

## Static vs Dynamic Request URLs (`url` vs `pid`)

On `<HTTP><Session><Connection><Request>`, `url`, `pid`, and `verb` (default: `GET`) are all optional schema attributes ([`Protocol.HTTP.Session.Connection.Request`](https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.HTTP.Session.Connection.Request.html)). Use `url` for a static URL or `pid` to replace `url` with a parameter value (or omit both to request the server root directory configured in the element wizard) — never specify both `url` and `pid`, and **never** put parameter placeholder tokens inside `url`:

- **Static URL (`url` attribute, `string`, optional)**: Specifies the URL of the request ([`Protocol.HTTP.Session.Connection.Request-url`](https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.HTTP.Session.Connection.Request-url.html)). If omitted (and `pid` is not specified), the root directory of the server specified in the element wizard is used. If the value does not contain `://`, it is assumed to be a relative URL and is constructed using the polling IP and port of the corresponding connection. No restrictions apply to the length of the URL path:
  ```xml
  <Request verb="GET" url="/api/v1/status">
  ```
- **Dynamic URL in a parameter (`pid` attribute, `unsignedInt`, optional)**: Replaces the `url` attribute; the value from this parameter will be used as the URL ([`Protocol.HTTP.Session.Connection.Request-pid`](https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.HTTP.Session.Connection.Request-pid.html)):
  ```xml
  <Request verb="GET" pid="105">
  ```
- **CRITICAL ANTI-PATTERN — NEVER put `[param:...]`, `{pid:...}`, or `[...]` inside `url`**:
  - ❌ `<Request verb="GET" url="[param:105]">` — **WRONG!** `Request@url` does **not** interpolate `[param:105]`; DataMiner treats it as the literal relative path `/[param:105]` (and the validator will not warn because `url` is `xs:string`).
  - ✅ `<Request verb="GET" pid="105">` — **CORRECT!** The value of parameter `105` is used as the request URL.

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
