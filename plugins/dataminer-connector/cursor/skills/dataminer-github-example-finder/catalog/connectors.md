# Connector Examples (SLC-C-Example_*)

## Repository

Name: SLC-C-Example_Polling-Manager

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Polling-Manager

Category:
Example Repository

Tags:
- polling
- backend
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 155394fdd15461bc40f758626483a26088e85d3a
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Polling Manager pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
ECS

Description:
This is an example implementation of a polling manager for a connector. It demonstrates how to structure the qaction that polls external APIs, handles responses, and manages state.

Why Use It:
Demonstrates the recommended project structure, dependency injection patterns, configuration handling, and API setup.

Typical Use Cases:
- System connectors that require polling external APIs
- Need fine control over polling intervals

Related Repositories:

---

## Repository

Name: SLC-C-Example_SNMP-Base

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_SNMP-Base

Category:
Example Repository

Tags:
- connector
- snmp
- interfaces
- rates
- csharp

Status:
Approved
Recommendation: Eligible
Verified Commit: 4a4418f417bcd436f3b1d7c3af9217a7f746199b
Verified Date: 2026-09-16
Default Branch: Main
Compatibility: Classic connector/QAction reference; Dev.Protocol 10.2.0.25, Rates.Protocol 1.0.0.4, Protocol.Extension 1.0.0.4; verify against the requested DataMiner target.
Package Baseline: Dev.Protocol 10.2.0.25; Skyline.DataMiner.Utils.Rates.Protocol 1.0.0.4; Skyline.DataMiner.Utils.Protocol.Extension 1.0.0.4; Skyline.DataMiner.Utils.SecureCoding 2.2.3.
Modeled Pattern: SNMP connector structure, interfaces tables, precompile QActions, and rate calculations.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Foundational example connector that retrieves the common SNMP System parameters and Interfaces tables (IfTable/IfXTable) present on virtually every device. Modern SDK-style solution (.slnx) with Catalog integration (catalog.yml), a Skyline Device Simulator setup under Documentation, and rate-calculation QActions.

Why Use It:
The recommended starting point for any SNMP connector — models the standard SNMP parameter/table layout, interface bitrate calculation via QActions, precompile QActions, and the modern connector project structure (Directory.Build.props, Catalog CI/CD workflows).

Typical Use Cases:
- Starting a new SNMP-based device connector
- Reference for the standard interfaces tables and interface rate calculations

Related Repositories: SLC-C-Example_Rates-SNMP, SLC-C-Example_Polling-Manager

---

## Repository

Name: SLC-C-Example_HTTP

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_HTTP

Category:
Example Repository

Tags:
- connector
- http
- communication
- csharp

Status:
Approved
Recommendation: Eligible
Verified Commit: 7772246bd2e2637ccd876183f7d5d37753a04e47
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Classic connector/QAction reference; Dev.Protocol 10.1.0.6 on a legacy .NET Framework project; verify against the requested DataMiner target.
Package Baseline: Dev.Protocol 10.1.0.6; StyleCop.Analyzers 1.1.118.
Modeled Pattern: HTTP request/response structure and payload-to-parameter/table mapping.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector that demonstrates HTTP communication from a DataMiner connector, showing how to structure HTTP requests/responses and parse the results into parameters and tables.

Why Use It:
Canonical reference for the HTTP communication pattern in connectors — request construction, response handling, and mapping payloads into the protocol model. Pairs directly with the dataminer-http-communication guidance.

Typical Use Cases:
- Building a connector that polls or controls a device/service over HTTP/REST
- Reference for parsing HTTP/JSON responses into DataMiner parameters

Related Repositories: SLC-C-Example_Polling-Manager

---

## Repository

Name: SLC-C-Example_ConnectivityFramework

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_ConnectivityFramework

Category:
Example Repository

Tags:
- connector
- dcf
- connectivity
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 879576352e837d78b140cbc60edb796624a2006f
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: DCF interface and connection modeling described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing the use of Skyline.DataMiner.Core.ConnectivityFramework to model DataMiner Connectivity Framework (DCF) connections within a connector (previously the Skyline SDF DCF example).

Why Use It:
The reference implementation for DCF interfaces and connections — how to define, create, and maintain connectivity (nodes, interfaces, connections) programmatically from QActions. Pairs with the dataminer-dcf guidance.

Typical Use Cases:
- Connectors that expose physical/logical connectivity (matrices, routers, signal flows)
- Reference for creating and updating DCF connections from code

Related Repositories: SLC-C-Example_Matrix

---

## Repository

Name: SLC-C-Example_Rates-SNMP

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Rates-SNMP

Category:
Example Repository

Tags:
- connector
- snmp
- rates
- bitrates
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: b62ea52bdb64bec6b07fa00df0b2c87948382cd1
Verified Date: 2026-09-16
Default Branch: 1.0.1.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: SNMP counter-to-rate calculation described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to calculate bitrates and other rates from counters polled over an SNMP connection (e.g. the standard SNMP Interfaces table), using the Skyline rates helper utilities.

Why Use It:
Demonstrates the recommended pattern for turning monotonically increasing SNMP counters into per-second rates, including counter wrap handling and time-delta calculations.

Typical Use Cases:
- Adding interface throughput/bitrate calculations to an SNMP connector
- Reference for SNMP counter-to-rate conversion

Related Repositories: SLC-C-Example_Rates-Custom, SLC-C-Example_SNMP-Base

---

## Repository

Name: SLC-C-Example_Rates-Custom

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Rates-Custom

Category:
Example Repository

Tags:
- connector
- rates
- bitrates
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 09a8da09e8a0317a8e4ba495e7ddfaa188b4e71d
Verified Date: 2026-09-16
Default Branch: 1.0.1.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Non-SNMP rate calculation described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to calculate bitrates and other rates on any changing numeric data (not tied to SNMP), using the Skyline rates helper utilities.

Why Use It:
The generic counterpart to the SNMP rates example — apply rate calculations to counters obtained from any communication type (HTTP, serial, custom), with correct time-delta and wrap handling.

Typical Use Cases:
- Calculating rates from non-SNMP counters (HTTP/REST, serial, custom sources)
- Reference for generic rate/bitrate computation helpers

Related Repositories: SLC-C-Example_Rates-SNMP

---

## Repository

Name: SLC-C-Example_InterAppCalls

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_InterAppCalls

Category:
Example Repository

Tags:
- connector
- interapp
- interapp-calls
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: f3706b39f53ce8839b4e59a3edd4b9f0cc61a668
Verified Date: 2026-09-16
Default Branch: 4.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Connector-side InterApp request/response messaging described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector demonstrating use of the Skyline.DataMiner.Core.InterApp library to send and receive InterApp messages between elements. Part of a complete InterApp trio with a companion Automation Script example and a solution that shows how to package the connector API as a NuGet.

Why Use It:
The canonical reference for the InterApp pattern on the connector side — message class definitions, handler dispatch, request/response model, and element-to-element communication.

Typical Use Cases:
- Connector that needs to receive commands or data from Automation scripts or other connectors
- Starting point for building an InterApp-enabled connector

Related Repositories: SLC-AS-Example_InterAppCalls, SLC-S-Example_InterAppCalls, SLC-C-Example_InterAppCalls-Context-Menu

---

## Repository

Name: SLC-C-Example_InterAppCalls-Context-Menu

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_InterAppCalls-Context-Menu

Category:
Example Repository

Tags:
- connector
- interapp
- context-menu
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 5dd0d1e3ced2f576d07fdc3a86331e158e73722f
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: InterApp context-menu pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to add a table context menu that triggers Automation scripts via InterApp calls using the Skyline.DataMiner.Core.InterAppCalls library.

Why Use It:
Reference for the context-menu-to-InterApp pattern — how to define context menu buttons in protocol.xml and invoke an Automation Script that sends an InterApp message back to the element.

Typical Use Cases:
- Connectors where the operator triggers element actions via right-click context menus
- Combining context menus with InterApp-based script execution

Related Repositories: SLC-C-Example_InterAppCalls

---

## Repository

Name: SLC-C-Example_Matrix

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Matrix

Category:
Example Repository

Tags:
- connector
- matrix
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 3e192b48c57e52731ef51d4fbb77f7718c6ad168
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Matrix connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector demonstrating how to implement a matrix (crosspoint) in DataMiner, including parameter definitions, QAction logic for setting crosspoints, and the associated UI layout.

Why Use It:
The reference implementation for matrix connectors — correct parameter structure, crosspoint set/get logic, and how DataMiner renders matrices in the UI.

Typical Use Cases:
- Building a connector for any device that exposes a routing matrix (video routers, audio matrices, patching systems)
- Reference for matrix parameter definitions and crosspoint QActions

Related Repositories: SLC-C-Example_ConnectivityFramework

---

## Repository

Name: SLC-C-Example_QActions-CachingAndSharingData

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_QActions-CachingAndSharingData

Category:
Example Repository

Tags:
- connector
- qaction
- caching
- state-management
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: c649dcf80936e29147be19d5821a474f760cec6f
Verified Date: 2026-09-16
Default Branch: master
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: QAction caching and shared-data pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to cache and share data across multiple QAction runs within a given element, avoiding redundant retrieval and improving performance.

Why Use It:
Reference for QAction-level state management — how to persist objects between QAction invocations using static fields or shared memory, and when this is safe versus risky in a multi-trigger connector.

Typical Use Cases:
- Connectors where expensive lookups (parsed configs, resolved references) should survive across QAction triggers
- Reference for QAction inter-run data sharing patterns

Related Repositories:

---

## Repository

Name: SLC-C-Example_ExportImport

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_ExportImport

Category:
Example Repository

Tags:
- connector
- export
- import
- csv
- xml
- json
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 0a6f6db3ad227def14d0c7bb9d340120979259b9
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Export/import connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to export data to and import data from CSV, XML, and JSON files within a DataMiner connector.

Why Use It:
Reference for file-based data exchange in connectors — correct file paths, serialization/deserialization approaches, and triggering export/import operations from QActions.

Typical Use Cases:
- Connectors that need to persist configuration or snapshot data to file
- Import of external data sets into DataMiner parameters or tables

Related Repositories:

---

## Repository

Name: SLC-C-Example_EmberPlus

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_EmberPlus

Category:
Example Repository

Tags:
- connector
- ember-plus
- communication
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 011e79bb779a1b8b8b80ce41170628d8cda5ae58
Verified Date: 2026-09-16
Default Branch: 10.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Ember+ connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector demonstrating how to implement the EmberPlus protocol in a DataMiner connector for device communication and control.

Why Use It:
Reference for EmberPlus-based connector development — device discovery, node tree traversal, parameter get/set, and handling EmberPlus subscriptions.

Typical Use Cases:
- Connectors for broadcast devices that expose EmberPlus (audio mixers, routing systems, signal processors)

Related Repositories:

---

## Repository

Name: SLC-C-Example_OpenConfig

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_OpenConfig

Category:
Example Repository

Tags:
- connector
- openconfig
- gnmi
- network
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 5a6ac4bd3e10d44066891d90650576eed54dc49f
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: OpenConfig connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to use the OpenConfig API (gNMI) for communication with network devices that support the OpenConfig data model.

Why Use It:
Reference for OpenConfig/gNMI-based connector development — subscription setup, path definitions, and mapping OpenConfig leaves to DataMiner parameters.

Typical Use Cases:
- Connectors for network equipment (switches, routers) that expose OpenConfig/gNMI interfaces

Related Repositories:

---

## Repository

Name: SLC-C-Example_Serial-Response-Matching

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Serial-Response-Matching

Category:
Example Repository

Tags:
- connector
- serial
- communication
- response-matching
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 1c6721fdd92a8365e2bb4ccbb2ddafc3a575fbdc
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Serial response matching pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector demonstrating the different ways to handle and match responses from devices communicating over a serial connection, using the DataMiner serial XML tags.

Why Use It:
Reference for serial response matching strategies — fixed-length, delimiter-based, and regex-based matching approaches defined in protocol.xml.

Typical Use Cases:
- Connectors for legacy or industrial devices that communicate over serial (RS-232/RS-485)
- Reference for choosing the right serial response-matching strategy

Related Repositories: SLC-C-Example_Smart-Serial

---

## Repository

Name: SLC-C-Example_Smart-Serial

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Smart-Serial

Category:
Example Repository

Tags:
- connector
- serial
- smart-serial
- communication
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 40c2dd467636514a771b1bf46b3ccd5351845c61
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Smart-serial connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to use the DataMiner smart-serial feature to receive unsolicited (pushed) messages from devices over a serial connection.

Why Use It:
Reference for the smart-serial pattern — how to configure protocol.xml for unsolicited data, handle incoming messages in QActions, and avoid polling when the device pushes data proactively.

Typical Use Cases:
- Devices that push status updates or traps over serial without a request-response cycle

Related Repositories: SLC-C-Example_Serial-Response-Matching

---

## Repository

Name: SLC-C-Example_SNMP-Stand-Alone

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_SNMP-Stand-Alone

Category:
Example Repository

Tags:
- connector
- snmp
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 3dfb0b1bf8c8ab35b77131bc92971a1a476037cc
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Standalone SNMP connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to create individual parameters that retrieve information from devices via SNMP in a standalone (non-table) fashion.

Why Use It:
Focused reference for basic SNMP GET operations on scalar OIDs — useful when you only need a handful of SNMP scalars and don't need the full SLC-C-Example_SNMP-Base layout.

Typical Use Cases:
- Simple SNMP connectors polling a small set of scalar OIDs
- Learning SNMP parameter definitions without the full interfaces table scaffold

Related Repositories: SLC-C-Example_SNMP-Base, SLC-C-Example_SNMP-3-Connections

---

## Repository

Name: SLC-C-Example_SNMP-3-Connections

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_SNMP-3-Connections

Category:
Example Repository

Tags:
- connector
- snmp
- multiple-connections
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 2cb585e1234243c374263c96f82a09c34c1172ad
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Multiple SNMP connection pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to use multiple simultaneous SNMP connections (up to 3) within a single DataMiner connector.

Why Use It:
Reference for multi-connection SNMP connectors — how to define and distinguish multiple SNMP connections in protocol.xml and route polling to the correct connection.

Typical Use Cases:
- Devices that require polling across multiple management interfaces or SNMP contexts
- Connectors that poll both in-band and out-of-band management planes

Related Repositories: SLC-C-Example_SNMP-Base, SLC-C-Example_SNMP-Stand-Alone

---

## Repository

Name: SLC-C-Example_Table-Context-Menu

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Table-Context-Menu

Category:
Example Repository

Tags:
- connector
- table
- context-menu
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 185d80e17079cf8cd781aab1087d35f167318233
Verified Date: 2026-09-16
Default Branch: 1.0.0.X
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Table context-menu pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to add a right-click context menu to a table in a DataMiner connector, including menu item definitions in protocol.xml and QAction handling.

Why Use It:
Reference for table context menus — how to declare menu items, pass selected row keys to QActions, and trigger actions on individual table rows from the DataMiner UI.

Typical Use Cases:
- Tables where the operator needs per-row actions (delete, acknowledge, push configuration, etc.)

Related Repositories: SLC-C-Example_Table, SLC-C-Example_InterAppCalls-Context-Menu

---

## Repository

Name: SLC-C-Example_Flow-Engineering

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Flow-Engineering

Category:
Example Repository

Tags:
- connector
- flow-engineering
- fle
- mediaops
- interapp
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 08ccd4c0ee4ba9dd0576a6a81b6c4df6c41e8ef5
Verified Date: 2026-09-16
Default Branch: main
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Flow Engineering connector pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector showing how to implement the generic Flow Engineering (FLE) tables via InterApp messages. Creates a mediation layer with standardized incoming/outgoing flow tables (multicast, SDI, ASI, etc.) that MediaOps uses to show the as-is signal path through devices.

Why Use It:
Reference for the FLE table pattern required by the MediaOps solution — table structure, InterApp population, and how device-sourced data combines with flow engineering metadata.

Typical Use Cases:
- Connectors for broadcast/media devices that participate in MediaOps flow engineering
- Implementing standardized flow/path visibility in a connector

Related Repositories:

---

## Repository

Name: SLC-C-Example_Table

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Table

Category:
Example Repository

Tags:
- connector
- table
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: a9ecdf0a894fce8b7fdde3448849b73d0aa9ff08
Verified Date: 2026-09-16
Default Branch: master
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Table authoring pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Connector used in the official Skyline training video "Driver Development – Table basics". Demonstrates how to define and populate basic tables in a DataMiner connector protocol.xml.

Why Use It:
Simplest possible table connector — ideal starting point for learning table parameter definitions, column types, and display keys before moving on to more advanced table patterns.

Typical Use Cases:
- Learning table fundamentals in DataMiner connector development
- Quick reference for basic table parameter definitions

Related Repositories: SLC-C-Example_Table-QAction, SLC-C-Example_Table-Context-Menu, SLC-C-Example_Table-Cleanup

---

## Repository

Name: SLC-C-Example_Table-QAction

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Table-QAction

Category:
Example Repository

Tags:
- connector
- table
- qaction
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: a35cfb67bf2de6affdd96e60fda51460ed10eed7
Verified Date: 2026-09-16
Default Branch: master
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Table QAction pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Connector used in the official Skyline training video "Driver Development – Manipulating tables via code". Demonstrates how to add, update, and delete table rows programmatically from a QAction.

Why Use It:
Reference for table manipulation in QActions — row CRUD operations (SetParameterIndex, FillArray, DeleteRow) with correct key handling.

Typical Use Cases:
- Learning how to programmatically control table contents from a QAction
- Reference for SetParameterIndex vs FillArray vs DeleteRow

Related Repositories: SLC-C-Example_Table, SLC-C-Example_Table-Context-Menu, SLC-C-Example_Table-Cleanup

---

## Repository

Name: SLC-C-Example_SCTE-Logging

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_SCTE-Logging

Category:
Example Repository

Tags:
- connector
- logging
- scte
- csharp

Status:
Pending
Recommendation: Conditional
Verified Commit: 9f821f38ef2263910cd50921fa9f39eb89645cb3
Verified Date: 2026-09-16
Default Branch: master
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: SCTE logging pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector demonstrating SCTE logging patterns in DataMiner connectors. No public description or README available — review the repository directly before use.

Why Use It:
May serve as a reference for SCTE event logging in connector development.

Typical Use Cases:
- Connectors for cable/broadcast devices requiring SCTE-104/SCTE-224 event logging

Related Repositories:

---

## Repository

Name: SLC-C-Example_Table-Cleanup

GitHub:
https://github.com/SkylineCommunications/SLC-C-Example_Table-Cleanup

Category:
Example Repository

Tags:
- connector
- table
- cleanup
- csharp

Status:
Pending
Recommendation: Conditional
Verified Commit: 3b34948e56f6f0671b5bb9a3ba8c2059069f4160
Verified Date: 2026-09-16
Default Branch: master
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Table cleanup pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example connector demonstrating table row cleanup/expiry patterns in DataMiner connectors. No public description or README available — review the repository directly before use.

Why Use It:
May serve as a reference for automatic table cleanup (removing stale rows based on TTL or state).

Typical Use Cases:
- Connectors where discovered/polled tables need automatic stale-row removal

Related Repositories: SLC-C-Example_Table, SLC-C-Example_Table-QAction
