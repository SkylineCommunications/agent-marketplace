# HTTP Authentication Patterns

Reference for API key, Basic authentication, bearer/OAuth2 token, secret-handling, and TLS certificate-validation patterns in HTTP connectors.

> **Parent skill**: `dataminer-xml-authoring/SKILL.md` - return there for core authoring rules.
> **Schema authority**: `dataminer-protocol-xml-reference/references/protocol-http.md` and `protocol-http-headers.md`.
> **Runtime security authority**: `dataminer-nugets/references/skyline-dataminer-utils-securecoding.md`.

---

## Mandatory Secret Rules

- Every request `<Header>` has a required `key` attribute. `pid` is optional and supplies the header value.
- Never use a keyless `<Header pid="..."/>`; it is invalid against the Protocol schema.
- Never put a password, token, API key, cookie, or complete Authorization value in `DefaultValue`, a URL, source code, or a log message.
- Store user-provided secrets in password-masked parameters or an approved credential store.
- Log only a stable session/endpoint label, HTTP status, and sanitized error category. Never log complete request headers or sensitive response bodies.
- Keep certificate verification enabled. A target-specific exception must be explicitly requested, risk-accepted, and narrowly scoped.

## API Key Header

Use a masked parameter for the value and retain the header name in `Header@key`:

```xml
<Param id="50" trending="false" save="true">
	<Name>apiKey</Name>
	<Description>API Key</Description>
	<Information>
		<Subtext>API key supplied by the operator.</Subtext>
	</Information>
	<Type>write</Type>
	<Interprete>
		<RawType>other</RawType>
		<Type>string</Type>
		<LengthType>next param</LengthType>
	</Interprete>
	<Display>
		<RTDisplay>true</RTDisplay>
	</Display>
	<Measurement>
		<Type options="password">string</Type>
	</Measurement>
</Param>
```

```xml
<Session id="1" name="Get Status">
	<Connection id="1">
		<Request verb="GET" url="/api/v1/status">
			<Headers>
				<Header key="Accept">application/json</Header>
				<Header key="X-API-Key" pid="50" />
			</Headers>
		</Request>
		<Response statusCode="100">
			<Content pid="101" />
		</Response>
	</Connection>
</Session>
```

`HttpRequestHeader` accepts documented standard names and custom strings. A validator may still report finding 8.3.1 for a vendor-specific name that is outside its standard-header allowlist. When the external API genuinely requires that name, retain the schema-valid key and add a narrow suppression with the vendor requirement:

```xml
<!-- SuppressValidator 8.3.1 X-API-Key is required by the Example API -->
<Header key="X-API-Key" pid="50" />
<!-- /SuppressValidator 8.3.1 -->
```

Do not work around the validator by removing `Header@key` or putting `"X-API-Key: <hard-coded-secret>"` into the parameter.

## Basic Authentication

Prefer the native session credential attributes. The values are parameter IDs, not literal credentials:

```xml
<Session id="1" name="Authenticated Request" loginMethod="credentials" userName="40" password="42">
	<Connection id="1">
		<Request verb="GET" url="/api/v1/status">
			<Headers>
				<Header key="Accept">application/json</Header>
			</Headers>
		</Request>
		<Response statusCode="100">
			<Content pid="101" />
		</Response>
	</Connection>
</Session>
```

Parameter 42 must be a password-masked input and must not have a source-controlled secret default.

When the target API specifically requires an explicit Basic Authorization header, construct the value at runtime, store it in a non-displayed parameter, and reference it with:

```xml
<Header key="Authorization" pid="51" />
```

Never log the constructed header or either credential.

## Bearer/OAuth2

1. Create a login session to obtain a token:

   ```xml
   <Session id="100" name="Login">
       <Connection id="1">
           <Request verb="POST" url="/auth/token">
               <Headers>
                   <Header key="Content-Type">application/json</Header>
               </Headers>
               <Data pid="60" />
           </Request>
           <Response statusCode="200">
               <Content pid="61" />
           </Response>
       </Connection>
   </Session>
   ```

2. Parse the response through the approved secure deserialization API.
3. Store the token in a non-displayed, non-logged runtime parameter.
4. Reference the complete bearer value from subsequent sessions:

   ```xml
   <Header key="Authorization" pid="62" />
   ```

Do not persist a refresh/access token unless the target's lifecycle explicitly requires persistence and the storage mechanism is approved.

## TLS Certificate Verification

DataMiner verifies HTTPS certificates by default. Prefer a trusted certificate and keep verification enabled.

`PortSettings/SkipCertificateVerification` is available only for HTTP connections from DataMiner 10.4.12 onward. Do not set its default to `true` as a generic development workaround. If an isolated target requires bypassing certificate checks, obtain an explicit requirement, document the risk, and prevent broader reuse.

For custom .NET HTTP code, `ServerCertificateCustomValidationCallback` must never always return `true`. Accept only `SslPolicyErrors.None` or apply a separately approved validation policy. The SecureCoding analyzer reports unconditional acceptance as `SLC_SC0005`.
