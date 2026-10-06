# DataMiner Connector Glossary

Authoritative terminology for DataMiner connector development.
**If a term is not defined here or in the official docs, do NOT invent it.**

Docs reference: https://aka.dataminer.services/getting-started-with-data-source-integrations

---

## Platform Terms

**DataMiner Agent (DMA)**
A server running the DataMiner software stack. Multiple DMAs form a DataMiner System (DMS).

**Element**
A running instance of a connector monitoring a specific device or service. Elements are created in the DataMiner client by selecting a connector and providing the device IP/credentials.

**Protocol / Connector / Driver**
These three names refer to the same artifact: an XML + C# package (DPML format) that teaches DataMiner how to communicate with and monitor a specific device or API. `protocol.xml` is the file name.

**DPML (DataMiner Protocol Markup Language)**
The XML dialect used to write connectors. Schema: https://aka.dataminer.services/protocol

---

## DataMiner Processes

**SLDataMiner**
The core DataMiner service. Manages alarms, trending, and element lifecycle.

**SLProtocol**
The Windows service that runs connector elements and their protocol threads.

**SLScripting**
A 32-bit process that executes QAction C# code. QActions run inside SLScripting, NOT inside SLProtocol. Each `SLProtocol.xxx()` call from a QAction is inter-process communication (IPC) — minimize calls to avoid performance overhead.

**SLElement**
Stores current parameter values and handles subscriptions.

**SLNet**
Internal messaging bus between DataMiner processes.

---

## Connector Building Blocks

**Parameter**
A named data slot within a connector. Every data point (sensor reading, control, table, internal flag) is a parameter. Parameters have an integer ID, a Name, a Description, and a Type.

*Parameter types:*

- `read` — a value received from the device or computed
- `write` — a value the operator can set on the device
- `read/write` or `dummy` — special internal parameters
- `array` — a table (multi-row, multi-column structure)
- `group` — (deprecated, do not use in new connectors)

**Interprete**
The XML block inside `<Param>` that defines how raw device data is interpreted: `<RawType>`, `<Type>` (double/string/high nibble double/etc.), `<LengthType>`.

**Measurement**
The XML block that controls how a parameter value is *displayed* in the DataMiner UI: `number`, `string`, `discreet`, `togglebutton`, `table`, `pagebutton`, `button`, etc.

**RTDisplay**
`<Display><RTDisplay>true</RTDisplay></Display>` — marks a parameter as visible on a UI page. Parameters without `RTDisplay=true` are internal and not shown in the DataMiner UI or accessible via external subscriptions unless explicitly configured.

**Positions**
The XML block inside `<Display>` that places a parameter on a UI page at a specific row and column.

**NamingFormat**
The `options` attribute value on `<ArrayOptions>` that defines the display key for table rows (e.g., `options=";naming=/1001,1002"`). This replaces the deprecated `displayColumn` approach. Display keys must be unique per row.

**displayColumn** *(deprecated)*
An old attribute on `<ArrayOptions>` that set the display key. **Do NOT use in new connectors** — use `NamingFormat` instead.

**ArrayOptions**
The XML block inside a `<Param type="array">` that defines table structure: `index` attribute (zero-based column that is the primary key), `NamingFormat` for display keys, and `<ColumnOption>` children.

**ColumnOption**
Defines one column of a table inside `<ArrayOptions>`: `idx` (zero-based column index), `pid` (parameter ID of the column parameter), `type` (snmp / retrieved / custom / state), and `options` (e.g., display options such as `;disableHeaderSum;disableHeatmap;disableHistogram`, or explicitly justified persistence/foreign-key options). Automatically polled `type="snmp"` columns must not use `;save`; saved retrieved/custom/state columns remain valid when runtime behavior requires it.

**ColumnOption type values:**

- `autoincrement` — automatically creates a unique value; only applicable for primary key columns. Not supported for logger tables with indexing databases or STaaS.
- `concatenation` — joins multiple column values into one (SNMP tables only). `value` attribute holds a comma-separated list of source column indexes; use `options=";separator=X"` to specify a separator.
- `custom` — column content is managed in the protocol (QAction). Prefer `retrieved` over `custom` where possible.
- `displaykey` — SLElement auto-fills this column with the display key of each row (composed via NamingFormat or the `naming` option). Must be the last column defined. Trending/alarming not possible; cannot be read via NT_GET_TABLE_COLUMNS.
- `index` — contains the row number; used when retrieving SNMP or WMI tables.
- `retrieved` — column is populated by a QAction via FillArray / FillArrayNoDelete / FillArrayWithColumn, or by a merge/aggregate/swap action.
- `snmp` — represents an SNMP column. From DM 10.3.8+, `retrieved` columns can be interspersed with `snmp` columns (primary key column must still be `snmp`).
- `state` — tracks per-row state during SNMP/WMI polling: Updated (1), Equal (2), New (3), Deleted (4), Recreated (5). Add `options=";delete"` to auto-remove deleted rows.
- `viewTableKey` — used in direct-view tables; prepends a `DataMinerAgentID_ElementID_` prefix to primary keys to ensure uniqueness across source elements.

---

## Communication Elements

**Group**
A batch of same-type items (parameters, pairs, sessions, actions, triggers) that are executed together on the protocol thread. Groups are the unit of work in the execution queue.

*Group types:*
- `poll` — sends requests and waits for responses (serial, SNMP, HTTP sessions)
- `poll action` — like poll but also executes actions
- `poll trigger` — like poll but fires triggers after response
- `action` — executes a list of actions (no device communication)
- `trigger` — fires a list of triggers

**Timer**
A background thread that runs every N milliseconds and adds groups to the execution queue. Timers contain references to groups. NEVER put the same group in multiple timers — it causes duplicate polling.

**Trigger**
An event handler: WHEN `<On>` something happens → WHAT `<Type>` to do (execute one or more actions). Triggers are the reactive logic layer.

*Common trigger On values:*
- `parameter` — fires when a specific parameter changes
- `group` — fires when a group finishes executing
- `communication` — fires after a device communication event
- `after startup` — fires once after the element starts

**Action**
An atomic operation. Common action types:
- `execute` / `execute next` / `execute one top` — run a group
- `set` / `set with wait` — write a value to a parameter
- `run QActions [all matching conditions]` — invoke QAction(s)
- `copy` — copy a value from one parameter to another
- `increment` / `normalize` — arithmetic on parameters
- `start` / `stop` — timer control
- `add to execute` — queue a group

**Pair**
A serial `<Command>` + `<Response>` matched together. Used only in serial/smart-serial connectors. Not used in SNMP, HTTP, or virtual connectors.

**Session**
An HTTP session (XML `<Session>` inside `<HTTP>`). Contains one or more `<Connection>` elements, each with a `<Request>` and `<Response>`. The `statusCode` attribute on `<Response>` is the **parameter ID** that receives the HTTP status line (e.g., "HTTP/1.1 200 OK").

---

## SNMP-Specific Terms

**OID (Object Identifier)**
A dotted-integer path identifying an SNMP object (e.g., `1.3.6.1.2.1.1.1.0` = sysDescr). Always include the `.0` suffix for scalar OIDs.

**MIB (Management Information Base)**
A vendor-provided definition file mapping OID paths to human-readable names, types, and descriptions.

**VendorOID**
The Skyline-assigned connector OID used in `protocol.xml`. It must match `1.3.6.1.4.1.8813.2.<number>` (for example, `1.3.6.1.4.1.8813.2.1`). It is not the device vendor's IANA enterprise or sysObjectID OID.

**DeviceOID**
A single integer identifying the specific device model within the vendor's OID subtree. **Must be a plain integer** (e.g., `1`, `42`) — not a dotted OID string.

**GetNext / GetBulk**
SNMP operations for walking table rows. DataMiner handles this automatically when a table parameter has SNMP columns — you do NOT need to write QActions for standard SNMP table retrieval.

---

## QAction-Specific Terms

**QAction**
A C# code block that runs inside `SLScripting` when triggered by one or more parameter change events. Defined in XML with `<QAction id="N" name="..." encoding="csharp" triggers="paramId1;paramId2">`.

**precompile**
A QAction option (`options="precompile"`) that compiles the QAction into a shared DLL loaded once per element. Use for QAction 1 that contains shared helper classes used by other QActions.

**inputParameters**
Comma-separated parameter IDs passed as local copies to the QAction at trigger time. Read those snapshots from additional entry-point arguments or `protocol.GetInputParameter(index)`. `protocol.GetParameter(pid)` still reads the current live value.

**SLProtocol (C# interface)**
The parameter used in `Run(SLProtocol protocol)` — provides access to DataMiner parameters, tables, logging, and element metadata. Note: this is the IPC bridge, not a direct in-process call.

**SLProtocolExt**
An optional connector-specific interface generated in `QAction_Helper`. It inherits `SLProtocol` and adds named scalar properties plus generated table properties. Cast only when using those generated members; base table methods do not require it.

**Protocol.Extension**
The optional `Skyline.DataMiner.Utils.Protocol.Extension` package. It adds methods such as `GetColumns` and `SetColumns` to `SLProtocol`; these are not generated helper members.

**FillArray**
Replaces the entire table with a new dataset. Rows not in the new dataset are deleted. Use when you have the full current state from the device.

**FillArrayNoDelete**
Updates existing rows and adds new ones, but does NOT delete rows absent from the new dataset. Use when you have a partial update.

**FillArrayWithColumn**
Updates a single column in the table. Other columns are untouched. Use when only one column's data changes.

**Clear sentinel**
The `protocol.Clear` value that clears a cell when a table API overload has cell actions enabled. Do NOT confuse it with `protocol.Leave`.

**Leave sentinel**
A special value that tells DataMiner to keep the existing cell value unchanged during a fill operation. Do NOT use `null` for this — use the correct `Leave` constant.

**HistorySet**
`historySet="true"` on a column or parameter allows setting parameter values with a historical timestamp. Required for timestamp-aware fill calls.

---

## ID Management

**Parameter ID**
A unique integer identifying a parameter within a connector. Ranges:

- 1–99: Protocol metadata
- 100–999: Standalone scalars (read and write)
- 1000+: Table array and column parameters
- 64,000–64,299: DataMiner module communication (only specific assigned IDs)
- 64,300–69,999: Reserved by DataMiner (general parameters)
- 70,000–79,999: Mediation/base protocols only
- 80,000–99,999: DataMiner module communication (only specific assigned IDs)
- 100,000–999,999: Reserved by DataMiner
- 1,000,000–9,989,999: Overflow (if 1–63,999 exhausted)
- 9,990,000–9,999,999: Reserved for Flow Engineering
- 10,000,000–10,999,999: Reserved for Data API

**Write offset**
Write parameters must use a fixed offset from their read ID. Preferred: +50. Also acceptable: +100. The offset must NEVER exceed 100.

**Group / Timer / Trigger / Action IDs**
These ID namespaces are independent of each other and of parameter IDs. You can have a Group 1, Timer 1, Trigger 1, and Action 1 without conflict.

---

## Compliance

**CassandraReady**
Must be `true` in `<Compliancies>` for all modern connectors. Indicates the connector does not use features incompatible with Cassandra-based DataMiner systems.

**MinimumRequiredVersion**
The oldest DataMiner version that supports all features used by the connector. Format: `Major.Minor.CU.Build - InternalBuild`.

**Connector Version**
Uses `Branch.System.Major.Minor` format (e.g., `1.0.0.1`). The Branch is almost always `1`. System is `0` unless the connector requires a specific DMA system version. Initial version is `1.0.0.1`.
