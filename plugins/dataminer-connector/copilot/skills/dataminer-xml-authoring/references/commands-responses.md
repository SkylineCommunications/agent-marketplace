# Commands & Responses — Full Reference

Full XML patterns for serial Commands, Responses, and Pairs.

## Serial — Basic Example

```xml
<Commands>
  <Command id="1">
    <Name>Get Status</Name>
    <Content><Param>10</Param></Content>
  </Command>
</Commands>
<Responses>
  <Response id="1">
    <Name>Status Response</Name>
    <Content>
      <Param>11</Param>
      <Param fixed="true">12</Param>
    </Content>
  </Response>
</Responses>
<Pairs>
  <Pair id="1">
    <Name>Get Status</Name>
    <Content>
      <Command>1</Command>
      <Response>1</Response>
    </Content>
  </Pair>
</Pairs>
```

For header/trailer framing, length fields, CRC checksums, SSH, code pages, smart-serial unsolicited messages, or bit manipulation, see `dataminer-xml-authoring/references/serial-connections.md`.
