param(
  [string]$ConfigPath = "tools/knowledge/config.json"
)

$ErrorActionPreference = "Stop"

function Get-Slug {
  param([string]$Value)

  $slug = $Value.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
  $slug = $slug.Trim('-')
  if ([string]::IsNullOrWhiteSpace($slug)) {
    return "note"
  }
  return $slug
}

function Ensure-Directory {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Get-RelativePath {
  param(
    [string]$BasePath,
    [string]$TargetPath
  )

  $baseUri = [System.Uri]((Resolve-Path $BasePath).Path + [System.IO.Path]::DirectorySeparatorChar)
  $targetUri = [System.Uri](Resolve-Path $TargetPath).Path
  return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', '\')
}

function Resolve-ImportTarget {
  param(
    [string]$ImportValue,
    [string]$FilePath,
    [string]$RepoRoot
  )

  if ($ImportValue.StartsWith("package:ascend/")) {
    $relative = $ImportValue.Replace("package:ascend/", "lib/")
    return $relative
  }

  if ($ImportValue.StartsWith("package:")) {
    return $ImportValue
  }

  $sourceDir = Split-Path -Parent $FilePath
  $joined = [System.IO.Path]::GetFullPath((Join-Path $sourceDir $ImportValue))

  if ($joined.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    return Get-RelativePath -BasePath $RepoRoot -TargetPath $joined
  }

  return $ImportValue
}

$repoRoot = (Resolve-Path ".").Path
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$vaultRoot = Join-Path $repoRoot $config.vaultRoot
$codeNotesRoot = Join-Path $vaultRoot $config.codeNotesDir
$entityNotesRoot = Join-Path $vaultRoot $config.entityNotesDir
$systemIndexesRoot = Join-Path $vaultRoot "_system/indexes"

Ensure-Directory $vaultRoot
Ensure-Directory $codeNotesRoot
Ensure-Directory $entityNotesRoot
Ensure-Directory $systemIndexesRoot

$files = Get-ChildItem -Path (Join-Path $repoRoot "lib") -Filter *.dart -Recurse | Sort-Object FullName
$edges = New-Object System.Collections.Generic.List[object]
$catalog = New-Object System.Collections.Generic.List[object]
$codeIndex = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
  $relativePath = Get-RelativePath -BasePath $repoRoot -TargetPath $file.FullName
  $content = Get-Content $file.FullName -Raw

  $imports = [regex]::Matches($content, "(?m)^\s*import\s+'([^']+)';") | ForEach-Object { $_.Groups[1].Value }
  $classes = [regex]::Matches($content, "(?m)^\s*class\s+([A-Za-z0-9_]+)") | ForEach-Object { $_.Groups[1].Value }
  $enums = [regex]::Matches($content, "(?m)^\s*enum\s+([A-Za-z0-9_]+)") | ForEach-Object { $_.Groups[1].Value }
  $providers = [regex]::Matches($content, "(?m)^\s*final\s+([A-Za-z0-9_]*Provider)\s*=") | ForEach-Object { $_.Groups[1].Value }
  $symbols = @($classes + $enums + $providers) | Sort-Object -Unique

  $segments = $relativePath.Split('\')
  $feature = if ($segments.Length -gt 2 -and $segments[0] -eq 'lib' -and $segments[1] -eq 'features') { $segments[2] } else { 'core' }
  $slug = Get-Slug $relativePath.Replace('\', '-').Replace('.', '-')
  $notePath = Join-Path $codeNotesRoot "$slug.md"

  $resolvedImports = foreach ($importValue in $imports) {
    Resolve-ImportTarget -ImportValue $importValue -FilePath $file.FullName -RepoRoot $repoRoot
  }

  $noteLines = @(
    "---"
    "type: code-file"
    "path: $relativePath"
    "feature: $feature"
    "symbol_count: $($symbols.Count)"
    "import_count: $($resolvedImports.Count)"
    "---"
    "# $relativePath"
    ""
    "## Summary"
    ""
    "- feature: $feature"
    "- imports: $($resolvedImports.Count)"
    "- symbols: $($symbols.Count)"
    ""
    "## Symbols"
    ""
  )

  if ($symbols.Count -gt 0) {
    $noteLines += $symbols | ForEach-Object { "- $_" }
  } else {
    $noteLines += "- none"
  }

  $noteLines += @(
    "",
    "## Imports",
    ""
  )

  if ($resolvedImports.Count -gt 0) {
    $noteLines += $resolvedImports | ForEach-Object { "- $_" }
  } else {
    $noteLines += "- none"
  }

  Set-Content -Path $notePath -Value ($noteLines -join "`r`n")

  foreach ($importTarget in $resolvedImports) {
    $edges.Add([pscustomobject]@{
      source = $relativePath
      target = $importTarget
      type   = "imports"
    })
  }

  foreach ($symbol in $symbols) {
    $entitySlug = Get-Slug $symbol
    $entityPath = Join-Path $entityNotesRoot "$entitySlug.md"
    $entityLines = @(
      "---"
      "type: code-entity"
      "name: $symbol"
      "defined_in: $relativePath"
      "feature: $feature"
      "---"
      "# $symbol"
      ""
      "- defined in: [[${slug}]]"
      "- feature: $feature"
    )

    Set-Content -Path $entityPath -Value ($entityLines -join "`r`n")

    $catalog.Add([pscustomobject]@{
      name     = $symbol
      aliases  = @($symbol)
      note     = "[[$symbol]]"
      category = "code-entity"
      source   = $relativePath
    })

    $edges.Add([pscustomobject]@{
      source = $relativePath
      target = $symbol
      type   = "defines"
    })
  }

  $codeIndex.Add([pscustomobject]@{
    path     = $relativePath
    feature  = $feature
    symbols  = $symbols
    imports  = $resolvedImports
    noteSlug = $slug
  })

  $catalog.Add([pscustomobject]@{
    name     = $relativePath
    aliases  = @($relativePath, $file.BaseName)
    note     = "[[$slug]]"
    category = "code-file"
    source   = $relativePath
  })
}

$catalog | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $vaultRoot $config.entityCatalogPath)
$edges | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $vaultRoot $config.graphEdgesPath)
$codeIndex | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $vaultRoot $config.codeIndexPath)

$indexLines = @(
  "# Codebase Index",
  "",
  "- generated_at: $(Get-Date -Format o)",
  "- file_count: $($files.Count)",
  "",
  "## Files",
  ""
)

$indexLines += $codeIndex | ForEach-Object { "- [[{0}]] ({1})" -f $_.noteSlug, $_.path }
Set-Content -Path (Join-Path $vaultRoot "02-codebase/index.md") -Value ($indexLines -join "`r`n")

Write-Host "Codebase map generated for $($files.Count) files."
