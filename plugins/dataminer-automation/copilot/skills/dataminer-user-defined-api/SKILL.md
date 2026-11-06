---
name: dataminer-user-defined-api
description: 'Author and review DataMiner User-Defined API Automation scripts: OnApiTrigger contracts, routes, version-gated request/response features, external provisioning, security, and HTTPS validation.'
argument-hint: 'Describe the API: e.g. "create an OnApiTrigger endpoint", "adapt an existing script", or "validate a route and response contract".'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-15
  version: 1.0
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-09-15 | Initial release for User-Defined API script contracts, setup boundaries, and version-aware validation. |

# DataMiner User-Defined API scripts

Load `dataminer-automation-core` first, then route this contract here when an
Automation script is invoked through a DataMiner User-Defined API. A dedicated
API script is not required to expose normal `Run(IEngine)`.

## Choose the script mode

**New or adapted endpoint (recommended):**

```csharp
[AutomationEntryPoint(AutomationEntryPointType.Types.OnApiTrigger)]
public ApiTriggerOutput Handle(IEngine engine, ApiTriggerInput input)
{
    // Validate the documented input, perform the operation, and return a
    // documented HTTP response.
}
```

The exact attribute/type availability must be verified in the selected
Automation package. A dedicated `OnApiTrigger` script does not require `Run`.

**Existing script compatibility:** an existing script can be exposed through
`Run`, but this gives less request/response control and less useful errors.
Choose that legacy mode only when explicitly required and document the tradeoff.
Do not treat a `Run`-only script as equivalent to a dedicated API contract.

## Scaffold and baseline

- Use the official template short name
  `dataminer-user-defined-api-project`, create a solution, and build before
  authoring logic.
- The observed project shape is `DataMinerType=UserDefinedApi`, `net48`, and a
  `Skyline.DataMiner.Dev.Automation` package reference. Verify the current
  template output and package version.
- Record the current/latest documented DataMiner release/CU/build baseline.
  User-Defined APIs are generally available from DataMiner 10.3.6/10.4.0
  (10.3.5 was preview) when Storage as a Service or a self-managed indexing
  database is present.

## Input and output contract

`ApiTriggerInput` can provide the HTTP method, route, raw body, configured
parsed dictionary parameters, `ApiTriggerContext`, query parameters, and route
parameters. Query parameters are version-gated from 10.4.1/10.5.0; route
parameters are version-gated from 10.6.8/10.7.0. Use only properties present in
the selected package and configured API definition.

Return `ApiTriggerOutput` with an HTTP status code and string body. A byte-array
body is version-gated from 10.6.1/10.7.0, and response headers from
10.5.12/10.6.0. Validate content type/body/status intentionally. HTTP failure
responses are not Automation `ExitFail` calls.

The official sources describe GET/PUT/POST/DELETE request methods, while the
endpoint documentation lists PATCH support from 10.6.8/10.7.0. This mismatch
is an explicit verification gap: check the selected enum/package before
generating PATCH handling.

## Routes, setup, and identity

- Routes are below `/api/custom/`. Store the route without a leading or
  trailing slash. Routes are unique and case-insensitive; validate documented
  dynamic-segment precedence, conflicts, allowed characters, and length.
- Keep script identity, route, HTTP method, input type, output status/body, API
  definition, token, and endpoint configuration in the plan. A source/package
  deployment alone does not deploy the API definition or token.
- Treat three setup surfaces separately: create the script; create API
  definitions/tokens in Cube/System Center or code; configure
  `UserDefinableApiEndpoint` where required. Do not assume the endpoint host is
  the Agent that executes the script.
- Code-based definition/token creation is an operational option only for this
  release. Do not add a repository manifest, install script, permission model,
  or secret persistence mechanism that the official sources do not define.
  Provisioning and secrets remain external.

## Security and runtime boundaries

- Use HTTPS and bearer tokens. Never embed a bearer token in browser/client
  code, commit it, or place it in chat. Tokens are at least 32 characters, are
  stored non-reversibly, and cannot be recovered after creation.
- Do not assume CORS response headers are available. Treat browser access as
  a server-side integration boundary.
- Requests can be handled in parallel subject to a DataMiner-controlled
  limit. Token rate limiting is per token/endpoint and can return HTTP 429
  before the script executes.
- Response body size is approximately 29 MB. Historical request-size limits
  differ by DataMiner version; use the selected target version rather than a
  universal constant. Apply the documented cloud 29-second limit where it
  applies.
- API definitions/tokens are stored in indexing data and are not part of an
  ordinary DataMiner backup. Record external provisioning and recovery
  ownership.

## Validation

1. Build the solution with the official template/package and Skyline analyzers.
2. Static-check the attribute, input/output types, route shape, supported
   methods, explicit body/parameter validation, status mapping, and
   version-gated features.
3. On an approved compatible DMA/QAOps endpoint, test an authenticated valid
   request, malformed input, wrong method, route conflict/precedence,
   response body and headers, target-version size limits, rate limiting when
   supported, and token/endpoint/DxM configuration.
4. Keep secrets outside the repository and test logs. If endpoint credentials
   or a compatible host are unavailable, report runtime validation as pending.

## References

- [User-Defined API contract](references/user-defined-api-contract.md)
- [User-Defined APIs overview](https://aka.dataminer.services/UDA)
- [Defining a new API](https://aka.dataminer.services/ud-ap-is-defining-a-new-api)
- [API definitions and actions](https://aka.dataminer.services/ud-ap-is-api-definition)
- [API tokens and rate limits](https://aka.dataminer.services/apitoken-object)
- [Using existing scripts](https://aka.dataminer.services/ud-ap-is-using-existing-scripts)
- [Triggering an API and request limits](https://aka.dataminer.services/ud-ap-is-triggering-an-api)
- [UserDefinableApiEndpoint](https://aka.dataminer.services/UserDefinableApiEndpoint-DxM)
- [Creating definitions and tokens in code](https://aka.dataminer.services/ud-ap-is-creating-in-code)
