---
name: dataminer-connector-help
description: 'Guidelines for writing DataMiner connector help/documentation pages: page structure, required sections, parameter documentation, connection info, version ranges, DVE documentation, and markdown formatting. Use when creating or reviewing connector documentation.'
argument-hint: 'Describe the documentation task: e.g. "create help page for this connector", "document the connection settings"'
license: LicenseRef-Skyline-Agent-Marketplace
metadata:
  updated: 2026-09-16
  version: 2.1
---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.1 | 2026-09-16 | Added front matter, repository/TOC, conditional Web Interface and Redundancy, and documentation validation gates. |
| 2.0 | 2026-04-13 | Extracted Connection Documentation Templates into `references/connection-templates.md`. |
| 1.1 | 2026-03-27 | Initial release. |

# DataMiner Connector Help Page Documentation

Guidelines for creating connector documentation pages following Skyline Communications standards.

> **Paired agent**: `dataminer-help-writer` — owns workflow, extraction logic, and output format. This skill owns page structure templates, section requirements, and formatting rules. Keep shared concepts (page types, required sections) in sync.

---

## Page Types

### Marketing Page (Required)

The primary documentation page visible in the DataMiner Catalog. Focuses on demonstrating the connector's value.

- **Purpose**: Explain what the connector monitors and why it matters.
- **Tone**: User-facing, non-technical.
- **Content**: High-level capabilities, supported firmware versions, key metrics.
- **File name**: `Connector_Name.md` (exact Catalog name, underscores replacing spaces).

### Technical Page (Optional)

A separate detailed page for connectors requiring extensive setup documentation.

- **Purpose**: Step-by-step configuration and usage guidance.
- **File name**: `Connector_Name_Technical.md`
- **When needed**: Complex setup, multiple connections, provisioning workflows, or DCF configuration. If the connector is straightforward with well-written parameter tooltips, a technical page is often unnecessary.

## Metadata and Repository Wiring

Connector help is published from the `dataminer-docs-connectors` repository, not from the connector source repository. A documentation change is incomplete until the page and its TOC entry are in the same pull request.

- Put pages under `/connector/doc/`.
- Use the exact Catalog connector name with spaces replaced by underscores for the marketing filename; append `_Technical` for a technical page. Preserve casing and every other character.
- Start every page with DocFX front matter containing a unique `uid`, then use the exact Catalog connector name as the H1 title.
- Add the page to `/connector/toc.yml` under the correct vendor in alphabetical order using the page's `topicUid`. Nest the technical page under its marketing page when both exist.
- Use the official [connector documentation guide](https://aka.dataminer.services/connectorDocsGuidelines), [marketing template](https://aka.dataminer.services/connector-marketing-template), and [technical template](https://aka.dataminer.services/connector-technical-template) as the structure authority.

### Conditional technical sections

- Add **Web Interface** only when `protocol.xml` defines a Web Interface page, and include: "The web interface is only accessible when the client machine has network access to the product."
- Add **Redundancy** only when the connector defines redundant polling or another documented redundancy feature. Explain the required connection setup from the protocol, not from a generic template.
- Add **DataMiner Connectivity Framework**, DVE, Automation Scripts, Correlation rules, Visio Files, Report Templates, or Dashboards only when the connector source proves the feature exists.
- Keep version ranges in `protocol.xml` `<VersionHistory>`; do not copy them into a Markdown version table.

### Documentation completion gate

Before handoff, verify: exact path and filename, front matter `uid`, exact H1 title, required marketing sections, conditional technical sections, all connections and defaults, DVE child pages, alphabetical `toc.yml` placement, valid `topicUid` references, and no placeholder text. A help-page task has its own documentation gate; a successful write alone is not completion.

---

## Technical Page Structure

### 1. About

Add a short description of the connector similar to the example below.

```markdown
## About

The **Vendor Device Name** connector monitors and manages [device type] via [protocol].
It provides real-time visibility into [key capabilities].
```

### 2. Configuration

- Include the information on each connection, similar to the example below, but adjusted to the specific connections in the connector.
- If any additional information is needed on how to initialize the element, include the 'Initialization' section; otherwise, leave it out.

```markdown
## Configuration

### Connections

#### SNMP Connection — Main

This connector uses a Simple Network Management Protocol (SNMP) connection and requires the following input during element creation:

- **IP address/host**: The polling IP of the device.
- **IP port**: The IP port of the device (default: *161*).
- **Bus address**: Not required.

#### HTTP Connection — API

This connector uses an HTTP connection and requires the following input during element creation:

- **IP address/host**: The polling IP or URL of the API.
- **IP port**: The IP port of the destination (default: *443*).
- **Bus address**: *bypassProxy*.

### Initialization

Describe any post-creation setup steps:
- Credentials to enter on the Authentication page
- Polling intervals to configure
- Features to enable/disable
```

### 3. How to Use

In this section, describe the most important parameters for each page, so that users will know how to use that page and what to watch out for. The purpose of this section is not to list every parameter on each page, but to make sure that the user is aware of all important features of the connector and how to use them.

For example:
 
```markdown
## How to Use

### Interfaces Page

The Interfaces table shows all network interfaces with status, utilization, and error counters.

Use the **Interface Filter** parameter to reduce the polling scope.
```

### 4. DCF (If Applicable)

If the connector implements DCF, include this section, listing the fixed and dynamic interfaces only if applicable.

```markdown
## DataMiner Connectivity Framework

This connector supports DCF and can only be used on a DMA with **minimum version 10.1.0**.

DCF can also be implemented through the DataMiner DCF user interface and
through third-party DataMiner connectors (e.g., a]manager connector).

### Interfaces

#### Fixed Interfaces

| Interface | Type | Description |
|-----------|------|-------------|
| Input 1 | in | Main input |
| Output 1 | out | Main output |

#### Dynamic Interfaces

| Interface | Type | Associated Table |
|-----------|------|------------------|
| Inputs | in | Interfaces (1000) |
| Outputs | out | Interfaces (1000) |
```

### 5. Notes (Optional)

```markdown
## Notes

- [Any known limitations, workarounds, or special behavior]
- [Firmware-specific differences]
```

---

## Reference Files

| Topic | Reference File |
|-------|---------------|
| Connection documentation templates (SNMP, HTTP, Serial, Virtual) | `dataminer-connector-help/references/connection-templates.md` |

---

## DVE Documentation

### Parent Connector

Add this note to the parent connector's documentation when it exports child elements:

```markdown
> [!NOTE]
> Connectivity for all exported connectors is managed by this connector.
```

### Child (Exported) Connector

Each exported child connector requires a separate documentation page:

```markdown
## About

The **Vendor Device Name - Child Type** connector is automatically exported by the
[Vendor Device Name](xref:connector_Vendor_Device_Name) parent connector (version X.X.X.X+).

This connector should not be created manually.
```

---

## Formatting Rules

- Use **DocFX Flavored Markdown** (DFM).
- File names: exact Catalog name with underscores replacing spaces, matching original casing.
- No spaces in file names.
- Use `*italic*` for default values in connection tables (e.g., `*161*`).
- Use `**bold**` for setting names and important UI elements.
- Add pages to `toc.yml` in alphabetical order using `topicUid` references.
- Include `toc.yml` updates in the same pull request as new documentation files.
- Use `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]` for callouts.
- **HTML comments** are **not allowed** on the documentation pages.

---

## Rules

- **Tooltips first**: If parameter tooltips are well-written, a technical page may be unnecessary. Don't duplicate what's already visible in the element UI.
- **Version history in protocol.xml**: Range documentation belongs in `<VersionHistory>` tags, not in markdown tables. Remove outdated version tables from help pages.
- **Keep it current**: Update documentation when connector features change.
- **One page per exported connector**: Each DVE child type needs its own documentation page.

Reference: https://aka.dataminer.services/connectorDocsGuidelines
