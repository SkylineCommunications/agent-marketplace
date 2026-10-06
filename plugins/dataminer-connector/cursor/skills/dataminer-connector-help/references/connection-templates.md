# Connection Documentation Templates

Use the appropriate template for each connection type when writing the Configuration section of a connector help page.

> **Parent skill**: `dataminer-connector-help/SKILL.md` — return there for page structure, DVE documentation, and formatting rules.

---

## SNMP

| Setting | Value |
|---------|-------|
| **IP address/host** | The polling IP of the device |
| **IP port** | The IP port of the device (default: *161*) |
| **Bus address** | Not required |

For SNMPv3, add:

| Setting | Value |
|---------|-------|
| **Security level and protocol** | The SNMPv3 security level and protocol |
| **User name** | The SNMPv3 user name |

## HTTP

| Setting | Value |
|---------|-------|
| **IP address/host** | The polling IP or URL of the API |
| **IP port** | The IP port of the destination (default: *443*) |
| **Bus address** | *bypassProxy* |

## Serial / Smart-Serial

| Setting | Value |
|---------|-------|
| **IP address/host** | The polling IP of the device |
| **IP port** | The IP port of the device |
| **Bus address** | The bus address of the device (if applicable) |

## Virtual

| Setting | Value |
|---------|-------|
| **IP address/host** | Not required |
| **IP port** | Not required |
| **Bus address** | Not required |
