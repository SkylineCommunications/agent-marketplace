<#
.SYNOPSIS
    Validates one or more DataMiner Automation DMSScript XML files against the pinned
    automation-1.1.10.xsd schema and checks document-wide descendant @id uniqueness.

.DESCRIPTION
    `dotnet build` on a Skyline.DataMiner.Sdk AutomationScript project compiles C# and runs
    Roslyn analyzers, but does not validate the DMSScript .xml file against automation.xsd or
    check descendant @id uniqueness. Running this script catches schema errors and overlapping
    @id values across <Protocol>, <File>, <ScriptParameter>, <Exe>, and any other descendant
    carrying @id, and prints the complete descendant @id inventory plus the next available
    document-wide ID.

.PARAMETER Path
    Path to a DMSScript .xml file, or a directory to search recursively for DMSScript .xml
    files. Defaults to the current working directory.

.PARAMETER SchemaPath
    Path to the pinned automation-1.1.10.xsd schema file. Defaults to
    ../references/automation-1.1.10.xsd relative to this script.

.PARAMETER Json
    Emit a machine-readable JSON result object instead of human-readable text.

.EXAMPLE
    pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -File skills/dataminer-automation-xml/scripts/validate-dmsscript-xml.ps1 -Path MyScript/MyScript.xml
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [Parameter()]
    [string]$SchemaPath = "",

    [Parameter()]
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
}
else {
    Split-Path -Parent $MyInvocation.MyCommand.Definition
}
if ([string]::IsNullOrWhiteSpace($SchemaPath)) {
    $SchemaPath = Join-Path (Join-Path $scriptDir "..") "references\automation-1.1.10.xsd"
}

Add-Type -AssemblyName System.Xml
Add-Type -AssemblyName System.Xml.Linq
Add-Type -AssemblyName System.Numerics

$AutomationNamespace = "http://www.skyline.be/automation"

function Get-NodeLocation {
    param([object]$Node)

    $lineInfo = $Node -as [System.Xml.IXmlLineInfo]
    if ($null -ne $lineInfo -and $lineInfo.HasLineInfo()) {
        return "line $($lineInfo.LineNumber), position $($lineInfo.LinePosition)"
    }

    return "unknown location"
}

function Test-AsciiInteger {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    return [regex]::IsMatch($Text.Trim(), '^[+-]?[0-9]+$')
}

function Resolve-TargetXmlFiles {
    param([string]$TargetPath)

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        throw "Target path not found: $TargetPath"
    }

    $resolved = (Resolve-Path -LiteralPath $TargetPath).Path
    if (Test-Path -LiteralPath $resolved -PathType Leaf) {
        return @($resolved)
    }

    $resolvedPrefix = $resolved.TrimEnd('\', '/')
    $candidates = @(Get-ChildItem -LiteralPath $resolved -Recurse -File -Filter "*.xml" | Where-Object {
        $relativePath = if ($_.FullName.Length -gt $resolvedPrefix.Length) {
            $_.FullName.Substring($resolvedPrefix.Length).TrimStart('\', '/')
        }
        else {
            $_.Name
        }
        $relativePath -notmatch '(?:^|[\\/])(?:bin|obj|\.git|\.vs|node_modules|TestResults|\.packages)[\\/]'
    })

    $dmsScripts = [System.Collections.Generic.List[string]]::new()
    foreach ($candidate in $candidates) {
        try {
            $settings = [System.Xml.XmlReaderSettings]::new()
            $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
            $settings.XmlResolver = $null
            $reader = [System.Xml.XmlReader]::Create($candidate.FullName, $settings)
            try {
                while ($reader.Read()) {
                    if ($reader.NodeType -eq [System.Xml.XmlNodeType]::Element) {
                        if ($reader.LocalName -ceq "DMSScript") {
                            $dmsScripts.Add($candidate.FullName)
                        }
                        break
                    }
                }
            }
            finally {
                $reader.Dispose()
            }
        }
        catch {
            # Surface malformed, DTD-bearing, or unreadable XML files to Invoke-DmsScriptValidation so directory scans never silently skip broken scripts.
            $dmsScripts.Add($candidate.FullName)
        }
    }

    return @($dmsScripts)
}

function Invoke-DmsScriptValidation {
    param(
        [string]$XmlPath,
        [System.Xml.Schema.XmlSchemaSet]$SchemaSet
    )

    $findings = [System.Collections.Generic.List[string]]::new()
    $inventory = [ordered]@{
        Protocol        = [System.Collections.Generic.List[string]]::new()
        File            = [System.Collections.Generic.List[string]]::new()
        ScriptParameter = [System.Collections.Generic.List[string]]::new()
        Exe             = [System.Collections.Generic.List[string]]::new()
        Other           = [System.Collections.Generic.List[string]]::new()
    }
    $nextAvailableId = [System.Numerics.BigInteger]::One

    $readerSettings = [System.Xml.XmlReaderSettings]::new()
    $readerSettings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $readerSettings.XmlResolver = $null

    [System.Xml.Linq.XDocument]$document = $null
    try {
        $reader = [System.Xml.XmlReader]::Create($XmlPath, $readerSettings)
        try {
            $loadOptions = [System.Xml.Linq.LoadOptions]::PreserveWhitespace -bor [System.Xml.Linq.LoadOptions]::SetLineInfo
            $document = [System.Xml.Linq.XDocument]::Load($reader, $loadOptions)
        }
        finally {
            $reader.Dispose()
        }
    }
    catch {
        $findings.Add("XML parse error: $($_.Exception.Message)")
        return [pscustomobject]@{
            file                    = $XmlPath
            status                  = "fail"
            findings                = @($findings)
            inventory               = $inventory
            nextAvailableDocumentId = "1"
        }
    }

    $root = $document.Root
    if ($null -eq $root) {
        $findings.Add("XML document has no root element.")
        return [pscustomobject]@{
            file                    = $XmlPath
            status                  = "fail"
            findings                = @($findings)
            inventory               = $inventory
            nextAvailableDocumentId = "1"
        }
    }

    $expectedRootName = [System.Xml.Linq.XNamespace]::Get($AutomationNamespace) + "DMSScript"
    if ($root.Name -ne $expectedRootName) {
        $findings.Add("Expected root '{$AutomationNamespace}DMSScript', found '$($root.Name)' at $(Get-NodeLocation $root).")
    }

    $schemaFindings = [System.Collections.Generic.List[string]]::new()
    $validationSettings = [System.Xml.XmlReaderSettings]::new()
    $validationSettings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $validationSettings.XmlResolver = $null
    $validationSettings.ValidationType = [System.Xml.ValidationType]::Schema
    $validationSettings.Schemas = $SchemaSet
    $validationSettings.ValidationFlags =
        [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessIdentityConstraints -bor
        [System.Xml.Schema.XmlSchemaValidationFlags]::ReportValidationWarnings

    $handler = [System.Xml.Schema.ValidationEventHandler]{
        param($sender, $eventArgs)
        $ex = $eventArgs.Exception
        $loc = if ($null -ne $ex -and $ex.LineNumber -gt 0) {
            "line $($ex.LineNumber), position $($ex.LinePosition)"
        }
        else {
            "unknown location"
        }
        $severity = $eventArgs.Severity.ToString().ToLowerInvariant()
        $msg = "Schema validation $severity at ${loc}: $($eventArgs.Message)"
        if (-not $schemaFindings.Contains($msg)) {
            $schemaFindings.Add($msg)
        }
    }
    $validationSettings.add_ValidationEventHandler($handler)

    try {
        $valReader = [System.Xml.XmlReader]::Create($XmlPath, $validationSettings)
        try {
            while ($valReader.Read()) { }
        }
        finally {
            $valReader.Dispose()
        }
    }
    catch [System.Xml.Schema.XmlSchemaValidationException] {
        $ex = $_.Exception
        $loc = if ($ex.LineNumber -gt 0) { "line $($ex.LineNumber), position $($ex.LinePosition)" } else { "unknown location" }
        $msg = "Schema validation error at ${loc}: $($ex.Message)"
        if (-not $schemaFindings.Contains($msg)) {
            $schemaFindings.Add($msg)
        }
    }

    foreach ($sf in $schemaFindings) {
        $findings.Add($sf)
    }

    # Inventory all descendant @id attributes and check normalized integer collisions across all kinds.
    $numericEntries = [System.Collections.Generic.List[object]]::new()
    $maxId = [System.Numerics.BigInteger]::Zero
    $hasAnyPositiveOrZeroId = $false

    foreach ($descendant in $root.Descendants()) {
        $idAttr = $descendant.Attribute("id")
        if ($null -eq $idAttr) {
            continue
        }

        $localName = $descendant.Name.LocalName
        $rawVal = $idAttr.Value
        switch ($localName) {
            "Protocol"        { $inventory.Protocol.Add($rawVal) }
            "File"            { $inventory.File.Add($rawVal) }
            "ScriptParameter" { $inventory.ScriptParameter.Add($rawVal) }
            "Exe"             { $inventory.Exe.Add($rawVal) }
            default           { $inventory.Other.Add("$localName=$rawVal") }
        }

        if (Test-AsciiInteger -Text $rawVal) {
            $parsed = [System.Numerics.BigInteger]::Parse(
                $rawVal.Trim(),
                [System.Globalization.NumberStyles]::AllowLeadingSign,
                [System.Globalization.CultureInfo]::InvariantCulture)
            $numericEntries.Add([pscustomobject]@{
                Value     = $parsed
                RawValue  = $rawVal
                Element   = $descendant
                Attribute = $idAttr
                LocalName = $localName
                Location  = Get-NodeLocation $idAttr
            })
            if (-not $hasAnyPositiveOrZeroId -or $parsed -gt $maxId) {
                $maxId = $parsed
                $hasAnyPositiveOrZeroId = $true
            }
        }
    }

    if ($hasAnyPositiveOrZeroId -and $maxId -ge [System.Numerics.BigInteger]::Zero) {
        $nextAvailableId = $maxId + [System.Numerics.BigInteger]::One
    }

    $nextCandidateId = $nextAvailableId
    $duplicateGroups = @($numericEntries | Group-Object -Property Value | Where-Object { $_.Count -gt 1 } | Sort-Object { $_.Group[0].Value })
    foreach ($group in $duplicateGroups) {
        $normalizedValue = $group.Group[0].Value
        $occurrences = @($group.Group | ForEach-Object {
            "<$($_.LocalName) id=`"$($_.RawValue)`"> at $($_.Location)"
        })

        $exeItems = @($group.Group | Where-Object { $_.LocalName -ceq "Exe" })
        $nonExeItems = @($group.Group | Where-Object { $_.LocalName -cne "Exe" })

        $remediation = if ($exeItems.Count -gt 0 -and $nonExeItems.Count -le 1) {
            $assignedIds = [System.Collections.Generic.List[string]]::new()
            $exesToMove = if ($nonExeItems.Count -eq 1) { $exeItems } else { @($exeItems | Select-Object -Skip 1) }
            foreach ($exeItem in $exesToMove) {
                $assignedIds.Add("id=`"$nextCandidateId`"")
                $nextCandidateId = $nextCandidateId + [System.Numerics.BigInteger]::One
            }
            " Remediation: every descendant @id shares one document-wide namespace; move the colliding <Exe> element(s) to the next free document-wide ID(s) after the highest used ID ($($assignedIds -join ', '))."
        }
        else {
            $assignedIds = [System.Collections.Generic.List[string]]::new()
            $itemsToMoveCount = $group.Count - 1
            for ($i = 0; $i -lt $itemsToMoveCount; $i++) {
                $assignedIds.Add("id=`"$nextCandidateId`"")
                $nextCandidateId = $nextCandidateId + [System.Numerics.BigInteger]::One
            }
            " Remediation: every descendant @id across Protocol, File, ScriptParameter, Exe, and any other descendant shares one document-wide namespace; assign each colliding element a distinct ID ($($assignedIds -join ', ')) and place <Exe> ID(s) after the highest used parameter/dummy/memory ID."
        }

        $findings.Add("Duplicate normalized numeric @id ${normalizedValue}: $($occurrences -join '; ').$remediation")
    }

    return [pscustomobject]@{
        file                    = $XmlPath
        status                  = if ($findings.Count -eq 0) { "pass" } else { "fail" }
        findings                = @($findings)
        inventory               = [pscustomobject]@{
            Protocol        = @($inventory.Protocol)
            File            = @($inventory.File)
            ScriptParameter = @($inventory.ScriptParameter)
            Exe             = @($inventory.Exe)
            Other           = @($inventory.Other)
        }
        nextAvailableDocumentId = $nextAvailableId.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    }
}

$resolvedSchemaPath = $SchemaPath
$results = [System.Collections.Generic.List[object]]::new()
$hasFailure = $false
$fatalError = $null

try {
    if (-not (Test-Path -LiteralPath $SchemaPath -PathType Leaf)) {
        throw "Pinned Automation XSD not found at: $SchemaPath"
    }

    $resolvedSchemaPath = (Resolve-Path -LiteralPath $SchemaPath).Path
    $schemaSet = [System.Xml.Schema.XmlSchemaSet]::new()
    $schemaSet.XmlResolver = $null
    $schemaReaderSettings = [System.Xml.XmlReaderSettings]::new()
    $schemaReaderSettings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $schemaReaderSettings.XmlResolver = $null
    $schemaReader = [System.Xml.XmlReader]::Create($resolvedSchemaPath, $schemaReaderSettings)
    try {
        [void]$schemaSet.Add($AutomationNamespace, $schemaReader)
        $schemaSet.Compile()
    }
    finally {
        $schemaReader.Dispose()
    }

    $xmlFiles = @(Resolve-TargetXmlFiles -TargetPath $Path)
    if ($xmlFiles.Count -eq 0) {
        throw "No DMSScript XML files found under path: $Path"
    }

    foreach ($xmlFile in $xmlFiles) {
        $res = Invoke-DmsScriptValidation -XmlPath $xmlFile -SchemaSet $schemaSet
        $results.Add($res)
        if ($res.status -ne "pass") {
            $hasFailure = $true
        }
    }
}
catch {
    $hasFailure = $true
    $fatalError = $_.Exception.Message
}

if ($Json) {
    $payload = [ordered]@{
        status  = if ($hasFailure) { "fail" } else { "pass" }
        schema  = $resolvedSchemaPath
        results = @($results)
    }
    if ($null -ne $fatalError) {
        $payload["error"] = $fatalError
    }
    Write-Output ([pscustomobject]$payload | ConvertTo-Json -Depth 8)
    if ($hasFailure) {
        exit 1
    }
    exit 0
}

if ($null -ne $fatalError) {
    Write-Host "FAIL DMSScript XML validation: $fatalError"
    exit 1
}

foreach ($res in $results) {
    $inv = $res.inventory
    $protoIds = if ($inv.Protocol.Count -gt 0) { $inv.Protocol -join ", " } else { "none" }
    $fileIds = if ($inv.File.Count -gt 0) { $inv.File -join ", " } else { "none" }
    $paramIds = if ($inv.ScriptParameter.Count -gt 0) { $inv.ScriptParameter -join ", " } else { "none" }
    $exeIds = if ($inv.Exe.Count -gt 0) { $inv.Exe -join ", " } else { "none" }
    $otherIds = if ($inv.Other.Count -gt 0) { $inv.Other -join ", " } else { "none" }

    if ($res.status -eq "pass") {
        Write-Host "PASS DMSScript XML validation: $($res.file)"
        Write-Host "  Descendant @id inventory: Protocol=[$protoIds] | File=[$fileIds] | ScriptParameter=[$paramIds] | Exe=[$exeIds] | Other=[$otherIds]"
        Write-Host "  Next available document-wide @id: $($res.nextAvailableDocumentId)"
    }
    else {
        Write-Host "FAIL DMSScript XML validation: $($res.file)"
        Write-Host "  Descendant @id inventory: Protocol=[$protoIds] | File=[$fileIds] | ScriptParameter=[$paramIds] | Exe=[$exeIds] | Other=[$otherIds]"
        Write-Host "  Next available document-wide @id: $($res.nextAvailableDocumentId)"
        foreach ($finding in $res.findings) {
            Write-Host "  - $finding"
        }
    }
}

if ($hasFailure) {
    exit 1
}
exit 0
