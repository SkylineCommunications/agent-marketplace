# HTTP Schema

Authority scope: authored from `protocol.xsd` 1.1.10.
Coverage: complete for `/Protocol/HTTP`, `Session`, `Connection`, `Request`, `Response`, request data, request parameters, and request/response headers listed here. Header key enum values and header string-union rules are covered by `protocol-http-headers.md`.

## HTTP

`/Protocol/HTTP` is optional and contains zero or more `Session` elements.

## Session

`HTTP/Session`:

- Required attribute: `id`.
- Optional attributes: `ignoreTimeout`, `keepAlive`, `loginMethod`, `name`, `password`, `proxyPassword`, `proxyServer`, `proxyUser`, `timeout`, `userName`.
- Contains zero or more `Connection` elements.

XSD uniqueness constraints under `/Protocol/HTTP`:

- `Session@id` MUST be unique.
- `Session@name` MUST be unique when present.

`Session@loginMethod` values are listed in `protocol-types-and-enums.md`.

## Connection

`HTTP/Session/Connection`:

- Required attribute: `id`.
- Optional attributes: `ignoreTimeout`, `name`, `timeout`.
- Required children: `Request`, `Response`.
- `Request` and `Response` each occur exactly once and use `xs:all` ordering.

XSD uniqueness constraints under `HTTP/Session`:

- `Connection@id` MUST be unique within the session.

## Request

`Request`:

- Optional attributes: `pid`, `verb`, `url`.
- `pid`, type `xs:unsignedInt` (optional): replaces the `url` attribute; the value from the referenced parameter will be used as the request URL (`https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.HTTP.Session.Connection.Request-pid.html`).
- `url`, type `xs:string` (optional): specifies the literal URL of the request (`https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.HTTP.Session.Connection.Request-url.html`). If omitted (and `pid` is not specified), the root directory of the server specified in the element wizard is used. If the value does not contain `://`, it is assumed to be a relative URL and is constructed using the polling IP and port of the corresponding connection. No restrictions apply to the length of the URL path. Does not interpolate parameter tokens such as `[param:105]` or `{pid:105}`.
- `verb`, type `EnumHttpRequestVerb` (optional, default `GET`): specifies the HTTP verb (`https://docs.dataminer.services/develop/schemadoc/Protocol/Protocol.HTTP.Session.Connection.Request-verb.html`); values are listed in `protocol-types-and-enums.md`. `CONNECT` is not supported; all verbs except `GET` support adding data to the message body.
- Optional child model: one `xs:choice` occurrence.
- Allowed child sequences: `Headers` followed by optional `Data` or optional `Parameters`; `Data` followed by optional `Headers`; or `Parameters` followed by optional `Headers`.
- `Data` and `Parameters` MUST NOT both appear under one `Request`.

`Request/Headers`:

- Contains one or more `Header` elements.

`Request/Headers/Header`:

- Text content: `xs:string`.
- Required attribute: `key`, type `HttpRequestHeader`; enum values and string-union rule are listed in `protocol-http-headers.md`.
- Optional attribute: `pid`, type `xs:unsignedInt`.

`Request/Data`:

- Text content: `xs:string`.
- Optional attribute: `pid`, type `xs:unsignedInt`.

`Request/Parameters`:

- Contains one or more `Parameter` elements.

`Request/Parameters/Parameter`:

- Text content: `xs:string`.
- Required attribute: `key`, type `xs:string`.
- Optional attribute: `pid`, type `xs:unsignedInt`.

## Response

`Response`:

- Optional attribute: `statusCode`.
- Required child: `Content`.
- Optional child: `Headers`.

`Response/Content`:

- Required attribute: `pid`.

`Response/Headers/Header`:

- Required attributes: `key`, `pid`.
- `key` type: `HttpResponseHeader`; enum values and string-union rule are listed in `protocol-http-headers.md`.
- `pid` type: `xs:unsignedInt`.

## Anti-Invention

- Do not invent HTTP verbs; use `EnumHttpRequestVerb`.
- Do not invent parameter placeholder syntax (such as `url="[param:105]"`, `url="{pid:105}"`, or `url="[105]"`) inside `Request@url`. When a parameter contains the URL, use `Request@pid="105"` and omit `url`.
- Do not invent HTTP child wrappers not present in the `Request` or `Response` XSD branches.
- Do not add `HTTP` child elements other than `Session` under `/Protocol/HTTP`.
