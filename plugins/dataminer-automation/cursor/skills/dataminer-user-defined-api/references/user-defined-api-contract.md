# User-Defined API contract

> Parent skill: `dataminer-user-defined-api/SKILL.md`.

## Dedicated and legacy contracts

| Mode | Entry point | Strength | Validation boundary |
|------|-------------|----------|---------------------|
| Dedicated API script | `[AutomationEntryPoint(...OnApiTrigger)]` method accepting `IEngine` and `ApiTriggerInput`, returning `ApiTriggerOutput` | Full request/response control; a dedicated script does not require `Run`. | Build/static contract plus authenticated HTTPS endpoint test. |
| Existing-script compatibility | API definition invokes normal `Run` | Reuses an existing script, but loses request/response control and provides less useful errors. | Explicitly selected legacy mode; do not grade it as the dedicated contract. |

Verify the exact attribute enum and type members in the selected
`Skyline.DataMiner.Dev.Automation` package. Do not invent request properties or
use a normal exit-state checklist for the dedicated API response.

## Request shape

| Input | Availability/meaning |
|-------|----------------------|
| HTTP method | Use the method exposed by the selected package and API definition. Official request-method documentation lists GET/PUT/POST/DELETE. |
| Route | The custom route under `/api/custom/`; no leading/trailing slash in the definition. |
| Raw body | Available when the API action uses `InputType.RawBody`. Validate content and size before parsing. |
| Parsed parameters | Available when the API action uses `InputType.Parameters`; validate required names/types explicitly. |
| `ApiTriggerContext` | Use only the context members exposed by the selected package. |
| Query parameters | Gate from DataMiner 10.4.1/10.5.0. Verify the selected version before using them. |
| Route parameters | Gate from DataMiner 10.6.8/10.7.0. Verify dynamic-segment configuration and the selected version. |

The endpoint documentation lists PATCH from 10.6.8/10.7.0, while the request
method contract lists only GET/PUT/POST/DELETE. Treat PATCH as unresolved until
the selected package enum and endpoint version prove it.

## Response shape and limits

| Output | Gate/boundary |
|--------|---------------|
| HTTP status code + string body | Core response contract. Map validation, application, and unexpected failures to intentional HTTP responses. |
| Byte-array body | Available from DataMiner 10.6.1/10.7.0. Verify before generating binary output. |
| Response headers | Available from DataMiner 10.5.12/10.6.0. Do not assume arbitrary browser/CORS behavior. |
| Response body size | Approximately 29 MB in the documented contract. |
| Request size | Historical limits differ by DataMiner version; use the target version, not one universal constant. |
| Cloud duration | Respect the documented 29-second cloud limit where applicable. |

An HTTP error response is not the same thing as `engine.ExitFail`. A dedicated
API method returns an API response; only a separately hosted normal Automation
script has the normal exit contract.

## Route and configuration checks

- Route names are unique and case-insensitive.
- Validate documented dynamic-segment precedence, conflicts, allowed
  characters, and length.
- The modern API definition uses an Automation Script action with
  `InputType.RawBody` or `InputType.Parameters`. The legacy action is an
  Automation Script without an entry point.
- Keep script creation, API definition/token creation, and
  `UserDefinableApiEndpoint` configuration as separate setup steps.
- API definitions and tokens live in indexing data and are not part of an
  ordinary DataMiner backup. Source deployment is not complete API deployment.
- Code-based definition/token provisioning is an operational option, not a
  first-release repository implementation. Use external secret handling; do
  not create a route/token manifest or persist secrets in the repository.

## Security and endpoint test matrix

| Test | Expected evidence |
|------|-------------------|
| Authenticated valid request | Correct route, method, parsed input, status, body, and configured endpoint. |
| Malformed body/parameters | Deterministic client error; no unvalidated operation. |
| Wrong method | Rejected according to the target definition, not silently routed. |
| Route conflict/precedence | Documented route wins; ambiguous definitions are rejected or corrected. |
| Response features | Headers/bytes are tested only when the target gate is met. |
| Size/duration | Target-version request/response and cloud limits are exercised or documented. |
| Rate limit | HTTP 429 before script execution when the configured token/endpoint limit is reached. |
| Secret boundary | Token is external, never in source, chat, browser code, or test artifacts. |

Runtime tests require an approved compatible DMA/QAOps endpoint and external
credentials. Static checks cannot prove endpoint routing, token state, or
execution Agent selection.

## Official sources

- [User-Defined API prerequisites](https://aka.dataminer.services/UDA)
- [Defining a new API](https://aka.dataminer.services/ud-ap-is-defining-a-new-api)
- [API definition and action types](https://aka.dataminer.services/ud-ap-is-api-definition)
- [API token and rate-limit model](https://aka.dataminer.services/apitoken-object)
- [Using existing scripts](https://aka.dataminer.services/ud-ap-is-using-existing-scripts)
- [Creating definitions and tokens in code](https://aka.dataminer.services/ud-ap-is-creating-in-code)
- [Triggering an API and request limits](https://aka.dataminer.services/ud-ap-is-triggering-an-api)
- [UserDefinableApiEndpoint configuration](https://aka.dataminer.services/UserDefinableApiEndpoint-DxM)
