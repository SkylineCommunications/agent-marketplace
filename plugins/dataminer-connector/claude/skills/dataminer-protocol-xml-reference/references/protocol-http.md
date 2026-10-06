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
- `verb` values are listed in `protocol-types-and-enums.md`.
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
- Do not invent HTTP child wrappers not present in the `Request` or `Response` XSD branches.
- Do not add `HTTP` child elements other than `Session` under `/Protocol/HTTP`.
