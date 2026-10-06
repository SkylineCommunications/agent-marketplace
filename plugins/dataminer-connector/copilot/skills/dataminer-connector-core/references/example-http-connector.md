# Canonical HTTP REST Connector Example

This is the **authoritative reference pattern** for a minimal HTTP REST connector.
**Always follow this exact structure.** Do NOT invent XML elements not present here.

Schema: https://aka.dataminer.services/protocol
Dev guide: https://aka.dataminer.services/http-connections
Validated complete example: [`examples/http-rest-protocol.xml`](examples/http-rest-protocol.xml)

---

## What This Example Covers

- Protocol metadata for HTTP connector
- HTTP session (GET request to REST endpoint)
- Status code and response body parameters
- Poll group referencing the HTTP session
- 30-second timer with an immediate first poll
- After-startup trigger chain for one-time initialization (not for polling timer data)
- QAction triggered by the response body to parse JSON

---

## Parameter ID Plan

| ID  | Name               | Type          | Purpose                                      |
|-----|--------------------|---------------|----------------------------------------------|
| 1   | afterStartup       | dummy         | After-startup initialization trigger         |
| 100 | statusCodeDevices  | read          | HTTP status line for /api/v1/devices (stored as string) |
| 101 | responseDevices    | read          | HTTP response body for /api/v1/devices (JSON string) |
| 102 | systemName         | read          | Device system name parsed from response      |
| 103 | systemStatus       | read          | Device system status parsed from response    |
| 1000 | devices           | array         | Devices table                                |
| 1001 | devicesIndex      | read          | Table index column                           |
| 1002 | devicesName       | read          | Device name column                           |
| 1003 | devicesStatus     | read          | Device status column                         |

---

## Protocol Header

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Copyright notice -->
<Protocol xmlns="http://www.skyline.be/protocol">
	<Name>Vendor Device HTTP</Name>
	<Description>Vendor Device HTTP DataMiner Driver</Description>
	<Version>1.0.0.1</Version>
	<IntegrationID>DMS-DRV-1235</IntegrationID>
	<Provider>Skyline Communications</Provider>
	<Vendor>Vendor Inc</Vendor>
	<VendorOID>1.3.6.1.4.1.8813.2.1235</VendorOID>
	<DeviceOID>2</DeviceOID>
	<SNMP includepages="true">auto</SNMP>
	<ElementType>Application Server</ElementType>
	<Type relativeTimers="true">http</Type>
	<Display defaultPage="General" pageOrder="General;Devices;-----;Webinterface#http://[Polling Ip]/" wideColumnPages="" />
	<Compliancies>
		<CassandraReady>true</CassandraReady>
		<MinimumRequiredVersion>10.4.0.0 - 14003</MinimumRequiredVersion>
	</Compliancies>
```

> `<Type>http</Type>` for HTTP connectors (not `snmpv2`).
> The protocol-level `<SNMP includepages="true">auto</SNMP>` marker is required by the current template/schema for every connector type, including HTTP. HTTP parameters do not use per-parameter SNMP polling blocks.

---

## Parameters

### Parameter 1 — After-Startup Dummy

```xml
	<Params>
		<Param id="1" trending="false" save="false">
			<Name>afterStartup</Name>
			<Description>After Startup</Description>
			<Information>
				<Subtext>Internal trigger parameter for after-startup initialization. Not displayed.</Subtext>
			</Information>
			<Type>dummy</Type>
			<Display>
				<RTDisplay>false</RTDisplay>
			</Display>
		</Param>
```

### HTTP Status Code Parameter

```xml
		<Param id="100" trending="false">
			<Name>statusCodeDevices</Name>
			<Description>Status Code Devices</Description>
			<Information>
				<Subtext>HTTP status line received from the /api/v1/devices endpoint (e.g. "HTTP/1.1 200 OK").</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>false</RTDisplay>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
		</Param>
```

> The `statusCode` attribute on `<Response>` stores the **HTTP status line** (e.g., "HTTP/1.1 200 OK") into this parameter.
> Keep it as `RTDisplay=false` — it is an internal value used for QAction error checking.

### HTTP Response Body Parameter

```xml
		<Param id="101" trending="false">
			<Name>responseDevices</Name>
			<Description>Response Devices</Description>
			<Information>
				<Subtext>Raw JSON response body from the /api/v1/devices endpoint. Parsed by QAction 1.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>false</RTDisplay>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
		</Param>
```

> Set `RTDisplay=false` on the raw response body — it is an intermediate value, not operator-facing.
> The QAction triggered on this parameter parses it and fills `systemName`, `systemStatus`, and the `devices` table.

### Parsed Scalar Parameters

```xml
		<Param id="102" trending="false">
			<Name>systemName</Name>
			<Description>System Name</Description>
			<Information>
				<Subtext>Device system name parsed from the /api/v1/devices response.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>General</Page>
						<Row>0</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
		</Param>
		<Param id="103" trending="false">
			<Name>systemStatus</Name>
			<Description>System Status</Description>
			<Information>
				<Subtext>Device operational status parsed from the /api/v1/devices response. 1 = Online, 2 = Degraded, 3 = Offline.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>numeric text</RawType>
				<Type>double</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>General</Page>
						<Row>1</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Alarm>
				<Monitored>true</Monitored>
				<Normal>1</Normal>
				<MaH>2</MaH>
				<CH>3</CH>
			</Alarm>
			<Measurement>
				<Type>discreet</Type>
				<Discreets>
					<Discreet>
						<Display>Online</Display>
						<Value>1</Value>
					</Discreet>
					<Discreet>
						<Display>Degraded</Display>
						<Value>2</Value>
					</Discreet>
					<Discreet>
						<Display>Offline</Display>
						<Value>3</Value>
					</Discreet>
				</Discreets>
			</Measurement>
		</Param>
```

### Devices Table (Filled by QAction)

```xml
		<Param id="1000" trending="false">
			<Name>devices</Name>
			<Description>Devices</Description>
			<Information>
				<Subtext>Table of devices retrieved from the /api/v1/devices endpoint.</Subtext>
			</Information>
			<Type>array</Type>
			<ArrayOptions index="0">
				<NamingFormat>,1001</NamingFormat>
				<ColumnOption idx="0" pid="1001" type="retrieved" options="" />
				<ColumnOption idx="1" pid="1002" type="retrieved" options="" />
				<ColumnOption idx="2" pid="1003" type="retrieved" options=";disableHeaderSum;disableHeatmap;disableHistogram" />
			</ArrayOptions>
			<Display>
				<RTDisplay>true</RTDisplay>
				<Positions>
					<Position>
						<Page>Devices</Page>
						<Row>0</Row>
						<Column>0</Column>
					</Position>
				</Positions>
			</Display>
			<Measurement>
				<Type options="tab=columns:1001|0-1002|1-1003|2,lines:25,width:100-180-120,sort:STRING-STRING-INT,filter:true">table</Type>
			</Measurement>
		</Param>
		<Param id="1001" trending="false">
			<Name>devicesIndex</Name>
			<Description>Index</Description>
			<Information>
				<Subtext>Unique primary key for this device row (device ID from the API).</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
		</Param>
		<Param id="1002" trending="false">
			<Name>devicesName</Name>
			<Description>Name</Description>
			<Information>
				<Subtext>Human-readable name of this device from the API.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>other</RawType>
				<Type>string</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
			</Display>
			<Measurement>
				<Type>string</Type>
			</Measurement>
		</Param>
		<Param id="1003" trending="false">
			<Name>devicesStatus</Name>
			<Description>Status</Description>
			<Information>
				<Subtext>Operational status of this device. 1 = Online, 2 = Degraded, 3 = Offline.</Subtext>
			</Information>
			<Type>read</Type>
			<Interprete>
				<RawType>numeric text</RawType>
				<Type>double</Type>
				<LengthType>next param</LengthType>
			</Interprete>
			<Display>
				<RTDisplay>true</RTDisplay>
			</Display>
			<Alarm>
				<Monitored>true</Monitored>
				<Normal>1</Normal>
				<MaH>2</MaH>
				<CH>3</CH>
			</Alarm>
			<Measurement>
				<Type>discreet</Type>
				<Discreets>
					<Discreet>
						<Display>Online</Display>
						<Value>1</Value>
					</Discreet>
					<Discreet>
						<Display>Degraded</Display>
						<Value>2</Value>
					</Discreet>
					<Discreet>
						<Display>Offline</Display>
						<Value>3</Value>
					</Discreet>
				</Discreets>
			</Measurement>
		</Param>
	</Params>
```

> Tables filled by QAction use `type="retrieved"` on `<ColumnOption>` (not `type="snmp"`).

> This example does not persist retrieved columns because no persistence requirement was specified. Add `;save` to a non-SNMP column only when restart persistence is explicitly required.
> The display key column (`DevicesIndex`) must use `<Interprete><Type>string</Type>` (not `double`) — this is a common mistake that causes display key issues.
> Only add `;volatile;` when there is no alarm monitoring, `save` column, foreign key, DCF usage, or DVE usage. If high row churn requires `volatile` but an incompatible behavior is also required, redesign or split the table rather than combining both.

---

## HTTP Section

```xml
	<HTTP>
		<Session id="1" name="GetDevices">
			<Connection id="1" name="GetDevices">
				<Request verb="GET" url="/api/v1/devices">
					<Headers>
						<Header key="Accept">application/json</Header>
					</Headers>
				</Request>
				<Response statusCode="100">
					<Content pid="101" />
				</Response>
			</Connection>
		</Session>
	</HTTP>
```

> `statusCode="100"` means "store the HTTP status line into parameter 100".
> `<Content pid="101" />` means "store the response body into parameter 101".
> The session URL `/api/v1/devices` is relative — the base URL comes from the element's IP/port connection settings.
> HTTP connectors do NOT use `<Commands>`, `<Responses>`, or `<Pairs>` — those are for serial connectors only.

---

## QAction

```xml
	<QActions>
		<QAction id="1" name="ParseDevicesResponse" encoding="csharp" triggers="101">
		<![CDATA[
// QAction C# code lives in QAction_1/QAction_1.cs (separate .csproj)
		]]>
		</QAction>
	</QActions>
```

> QAction `triggers="101"` fires when parameter 101 (the response body) changes.
> See `dataminer-qaction` skill and `example-json-table.md` for the C# implementation.

---

## Groups, Timers, Triggers, Actions

```xml
	<Groups>
		<Group id="1">
			<Name>PollDevices</Name>
			<Description>Poll Devices</Description>
			<Type>poll</Type>
			<Content>
				<Session>1</Session>
			</Content>
		</Group>
		<Group id="2">
			<Name>After Startup</Name>
			<Description>After Startup initialization group</Description>
			<Type>poll action</Type>
			<Content>
				<Action>2</Action>
			</Content>
		</Group>
	</Groups>
	<Triggers>
		<Trigger id="1">
			<Name>After Startup</Name>
			<On>protocol</On>
			<Time>after startup</Time>
			<Type>action</Type>
			<Content>
				<Id>1</Id>
			</Content>
		</Trigger>
	</Triggers>
	<Actions>
		<Action id="1">
			<Name>After Startup Group</Name>
			<On id="2">group</On>
			<Type>execute</Type>
		</Action>
		<Action id="2">
			<Name>After Startup QAction</Name>
			<On id="1">parameter</On>
			<Type>run actions</Type>
		</Action>
	</Actions>
	<Timers>
		<Timer id="1">
			<Name>PollTimer</Name>
			<Time initial="true">30000</Time>
			<Interval>75</Interval>
			<Content>
				<Group>1</Group>
			</Content>
		</Timer>
	</Timers>
```

> **After-Startup vs. Timer Polling Pattern**:
> - The after-startup chain/sequence can still be used whenever one-time initialization is needed (e.g. running an initialization QAction like `QAction 2` or initializing internal state).
> - However, **never use the after-startup trigger to poll data at the start of an element if that same data will be retrieved through a timer**.
> - Routine polling groups (like `Group 1` `PollDevices`) belong exclusively on their timer (`PollTimer`). If an immediate first poll is desired on element startup, configure `<Time initial="true">` on the timer itself — do not re-enqueue those timer groups from an after-startup trigger.

> HTTP groups reference `<Session>N</Session>` (not `<Param>`).
> SNMP groups reference `<Param>N</Param>`.
> This is a critical difference — mixing them is a common mistake.

---

### PortSettings

Configure connection defaults and disable non-applicable port types for HTTP:

```xml
	<PortSettings name="HTTP Connection">
		<BusAddress>
			<DefaultValue>bypassProxy</DefaultValue>
		</BusAddress>
		<IPport>
			<DefaultValue>80</DefaultValue>
		</IPport>
		<Type>
			<DefaultValue>ip</DefaultValue>
		</Type>
		<PortTypeUDP>
			<Disabled>true</Disabled>
		</PortTypeUDP>
		<PortTypeSerial>
			<Disabled>true</Disabled>
		</PortTypeSerial>
	</PortSettings>
```

> Key rules:
> - `<BusAddress><DefaultValue>bypassProxy</DefaultValue></BusAddress>`: Defaults to bypassing proxy for direct API communication; operators can clear or override if proxy routing is required.
> - `<IPport><DefaultValue>80</DefaultValue></IPport>`: Standard HTTP port (use `443` for HTTPS).
> - `<Type><DefaultValue>ip</DefaultValue></Type>`: HTTP uses TCP/IP.
> - `<PortTypeUDP><Disabled>true</Disabled></PortTypeUDP>`: Disables UDP.
> - `<PortTypeSerial><Disabled>true</Disabled></PortTypeSerial>`: Disables serial COM ports.

---

## Common Mistakes to Avoid

| Wrong | Correct |
|-------|---------|
| `<Type>snmpv2</Type>` for HTTP connector | `<Type>http</Type>` |
| Missing protocol-level `<SNMP>` marker in an HTTP connector | Add `<SNMP includepages="true">auto</SNMP>`; do not add per-parameter SNMP blocks |
| `<Content><Param>1</Param>` in HTTP group | `<Content><Session>1</Session>` |
| `<Response statusCode="200">` (confusing with HTTP 200) | `statusCode` is a param ID, not the expected HTTP status code |
| `type="snmp"` on table columns filled by QAction | `type="retrieved"` for QAction-filled columns |
| `volatile` combined with alarm monitoring or persistence features | Redesign or split the table; those behaviors are incompatible |
| String index column with `<Type>double</Type>` | `<Type>string</Type>` for the display key column |
