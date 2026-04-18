param(
  [ValidateSet("bug-fix", "feature-work", "refactor")]
  [string]$TaskType = "feature-work",
  [string]$Query = "",
  [string]$ConfigPath = "tools/knowledge/config.json"
)

$ErrorActionPreference = "Stop"

function Get-Score {
  param(
    [string]$Text,
    [string[]]$Terms
  )

  if ([string]::IsNullOrWhiteSpace($Text) -or $Terms.Count -eq 0) {
    return 0
  }

  $score = 0
  $lower = $Text.ToLowerInvariant()
  foreach ($term in $Terms) {
    if ([string]::IsNullOrWhiteSpace($term)) {
      continue
    }
    if ($lower.Contains($term)) {
      $score += 1
    }
  }
  return $score
}

$repoRoot = (Resolve-Path ".").Path
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$vaultRoot = Join-Path $repoRoot $config.vaultRoot
$manifestPath = Join-Path $vaultRoot (Join-Path $config.contextManifestsDir "$TaskType.json")
$codeIndexPath = Join-Path $vaultRoot $config.codeIndexPath
$entityCatalogPath = Join-Path $vaultRoot $config.entityCatalogPath

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$codeIndex = Get-Content $codeIndexPath -Raw | ConvertFrom-Json
$entityCatalog = Get-Content $entityCatalogPath -Raw | ConvertFrom-Json

$terms = $Query.ToLowerInvariant().Split(@(" ", ",", ".", ";", ":", "/", "\"), [System.StringSplitOptions]::RemoveEmptyEntries)

$selectedDocs = @()
foreach ($doc in $manifest.documents) {
  $selectedDocs += [pscustomobject]@{
    type = "document"
    path = $doc
  }
}

$selectedCode = @()
if ($manifest.includeCodeNotes) {
  $selectedCode = $codeIndex |
    Select-Object *, @{ Name = "score"; Expression = { (Get-Score -Text (($_.path + " " + ($_.feature) + " " + (($_.symbols -join " ")))) -Terms $terms) } } |
    Sort-Object -Property @{ Expression = "score"; Descending = $true }, @{ Expression = "path"; Descending = $false } |
    Select-Object -First $manifest.maxCodeNotes
}

$selectedEntities = @()
if ($manifest.includeEntities) {
  $selectedEntities = $entityCatalog |
    Select-Object *, @{ Name = "score"; Expression = { (Get-Score -Text (($_.name + " " + (($_.aliases -join " ")))) -Terms $terms) } } |
    Sort-Object -Property @{ Expression = "score"; Descending = $true }, @{ Expression = "name"; Descending = $false } |
    Select-Object -First $manifest.maxEntities
}

$codeNotesOutput = @(
  $selectedCode | ForEach-Object {
    [pscustomobject]@{
      path    = $_.path
      note    = "[[$($_.noteSlug)]]"
      feature = $_.feature
      score   = $_.score
    }
  }
)

$entitiesOutput = @(
  $selectedEntities | Where-Object { $_.score -gt 0 } | ForEach-Object {
    [pscustomobject]@{
      name  = $_.name
      note  = $_.note
      score = $_.score
    }
  }
)

$output = [pscustomobject]@{
  taskType = $TaskType
  query = $Query
  documents = $selectedDocs
  codeNotes = $codeNotesOutput
  entities = $entitiesOutput
}

$output | ConvertTo-Json -Depth 10
