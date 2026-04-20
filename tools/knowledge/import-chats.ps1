param(
  [string]$ConfigPath = "tools/knowledge/config.json"
)

$ErrorActionPreference = "Stop"

function Ensure-Directory {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Write-TextFile {
  param(
    [string]$Path,
    [string[]]$Lines
  )

  $directory = Split-Path -Parent $Path
  if (-not [string]::IsNullOrWhiteSpace($directory)) {
    Ensure-Directory $directory
  }

  if ($null -eq $Lines) {
    $Lines = @()
  }

  $safeLines = @(
    foreach ($line in $Lines) {
    if ($null -eq $line) { "" } else { [string]$line }
  }
  )

  $content = [string]::Join([System.Environment]::NewLine, $safeLines)
  $encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $content, $encoding)
}

function Get-Slug {
  param([string]$Value)

  $slug = $Value.ToLowerInvariant() -replace "[^a-z0-9]+", "-"
  $slug = $slug.Trim("-")
  if ([string]::IsNullOrWhiteSpace($slug)) {
    return "note"
  }
  return $slug
}

function Get-ChatText {
  param([string]$FilePath)

  $extension = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
  if ($extension -ne ".json") {
    return Get-Content $FilePath -Raw
  }

  try {
    $json = Get-Content $FilePath -Raw | ConvertFrom-Json -Depth 32
    $strings = New-Object System.Collections.Generic.List[string]

    function Read-Node {
      param([object]$Node)

      if ($null -eq $Node) {
        return
      }

      if ($Node -is [string]) {
        if (-not [string]::IsNullOrWhiteSpace($Node)) {
          $strings.Add($Node)
        }
        return
      }

      if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
        foreach ($item in $Node) {
          Read-Node $item
        }
        return
      }

      foreach ($property in $Node.PSObject.Properties) {
        Read-Node $property.Value
      }
    }

    Read-Node $json

    if ($strings.Count -eq 0) {
      return Get-Content $FilePath -Raw
    }

    return ($strings | Select-Object -Unique) -join "`r`n"
  } catch {
    return Get-Content $FilePath -Raw
  }
}

function Get-Tags {
  param([string]$Content)

  $rules = @{
    architecture = @("architecture", "refactor", "provider", "repository")
    auth         = @("firebase", "auth", "google sign", "login")
    quests       = @("quest", "daily reset", "streak")
    player       = @("level", "xp", "attribute", "player")
    performance  = @("performance", "rebuild", "optimize", "slow")
    testing      = @("test", "coverage", "widget test", "unit test")
    roadmap      = @("roadmap", "vision", "mvp", "premium")
    bug          = @("bug", "error", "crash", "regression")
  }

  $found = New-Object System.Collections.Generic.List[string]
  $lower = $Content.ToLowerInvariant()

  foreach ($tag in $rules.Keys) {
    foreach ($term in $rules[$tag]) {
      if ($lower.Contains($term)) {
        $found.Add($tag)
        break
      }
    }
  }

  return $found | Sort-Object -Unique
}

function Get-RelatedFiles {
  param([string]$Content)

  $matches = [regex]::Matches($Content, "(lib|docs|test)[\\/][A-Za-z0-9_./\\-]+")
  return $matches | ForEach-Object { $_.Value.Replace("/", "\") } | Sort-Object -Unique
}

function Get-RelatedNotes {
  param(
    [string]$Content,
    [object[]]$Catalog
  )

  $related = New-Object System.Collections.Generic.List[string]
  $lower = $Content.ToLowerInvariant()

  foreach ($item in $Catalog) {
    foreach ($alias in $item.aliases) {
      $escaped = [regex]::Escape([string]$alias.ToLowerInvariant())
      if ($lower -match "(^|[^a-z0-9_])$escaped([^a-z0-9_]|$)") {
        $related.Add([string]$item.note)
        break
      }
    }
  }

  return $related | Sort-Object -Unique
}

function Get-Excerpt {
  param([string]$Content)

  $lines = $Content -split "(`r`n|`n)"
  $nonEmpty = $lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 40
  return ($nonEmpty -join "`r`n").Trim()
}

function Get-DecisionCandidates {
  param([string]$Content)

  $patterns = @(
    '(?im)^(?:-|\*|\d+\.)\s*(?:decid(?:e|ed|imos|imos que)|we should|should use|use |prefer |must |need to)\s+(.+)$',
    '(?im)\b(?:we should|should use|prefer|must|need to|decided to)\b([^.!?\r\n]+)'
  )

  $items = New-Object System.Collections.Generic.List[string]
  foreach ($pattern in $patterns) {
    $matches = [regex]::Matches($Content, $pattern)
    foreach ($match in $matches) {
      $value = $match.Groups[$match.Groups.Count - 1].Value.Trim(" .:-")
      if ($value.Length -ge 12) {
        $items.Add($value)
      }
    }
  }

  return $items | Select-Object -Unique | Select-Object -First 5
}

function Get-TaskCandidates {
  param([string]$Content)

  $patterns = @(
    '(?im)^(?:-|\*|\d+\.)\s*(?:todo|to do|next step|next|implement|create|add|fix|refactor|update)\s+(.+)$',
    '(?im)\b(?:need to|have to|next step is to|we should add|we should create|we should update|we should implement)\b([^.!?\r\n]+)'
  )

  $items = New-Object System.Collections.Generic.List[string]
  foreach ($pattern in $patterns) {
    $matches = [regex]::Matches($Content, $pattern)
    foreach ($match in $matches) {
      $value = $match.Groups[$match.Groups.Count - 1].Value.Trim(" .:-")
      if ($value.Length -ge 10) {
        $items.Add($value)
      }
    }
  }

  return $items | Select-Object -Unique | Select-Object -First 8
}

$repoRoot = (Resolve-Path ".").Path
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

$vaultRoot = Join-Path $repoRoot $config.vaultRoot
$sourceRoot = Join-Path $repoRoot $config.chatSourceDir
$rawRoot = Join-Path $vaultRoot $config.rawChatsDir
$normalizedRoot = Join-Path $vaultRoot $config.normalizedChatsDir
$decisionRoot = Join-Path $vaultRoot $config.decisionNotesDir
$taskRoot = Join-Path $vaultRoot $config.taskNotesDir
$statePath = Join-Path $vaultRoot $config.statePath
$catalogPath = Join-Path $vaultRoot $config.entityCatalogPath

Ensure-Directory $sourceRoot
Ensure-Directory $rawRoot
Ensure-Directory $normalizedRoot
Ensure-Directory $decisionRoot
Ensure-Directory $taskRoot
Ensure-Directory (Split-Path -Parent $statePath)

$state = $null
if (Test-Path $statePath) {
  try {
    $rawState = Get-Content $statePath -Raw
    if (-not [string]::IsNullOrWhiteSpace($rawState)) {
      $state = $rawState | ConvertFrom-Json
    }
  } catch {
    $state = $null
  }
}

if ($null -eq $state) {
  $state = [pscustomobject]@{ imports = [pscustomobject]@{} }
}

if ($null -eq $state.imports) {
  $state | Add-Member -NotePropertyName imports -NotePropertyValue ([pscustomobject]@{}) -Force
}

$catalog = if (Test-Path $catalogPath) {
  @(Get-Content $catalogPath -Raw | ConvertFrom-Json)
} else {
  @()
}

$chatFiles = Get-ChildItem -Path $sourceRoot -File -Recurse | Where-Object {
  @(".md", ".txt", ".json") -contains $_.Extension.ToLowerInvariant()
} | Sort-Object FullName

$processed = 0

foreach ($chatFile in $chatFiles) {
  $relative = $chatFile.FullName.Substring($sourceRoot.Length).TrimStart("\")
  $hash = (Get-FileHash -Path $chatFile.FullName -Algorithm SHA256).Hash

  if ($state.imports.PSObject.Properties.Name -contains $relative) {
    if (($state.imports.PSObject.Properties[$relative].Value) -eq $hash) {
      continue
    }
  }

  $content = Get-ChatText -FilePath $chatFile.FullName
  if ([string]::IsNullOrWhiteSpace($content)) {
    $state.imports | Add-Member -NotePropertyName $relative -NotePropertyValue $hash -Force
    continue
  }

  $title = ($content -split "(`r`n|`n)" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
  if ([string]::IsNullOrWhiteSpace($title)) {
    $title = $chatFile.BaseName
  }

  $slug = Get-Slug ("{0}-{1}" -f $chatFile.BaseName, $hash.Substring(0, 8).ToLowerInvariant())
  $tags = @(Get-Tags -Content $content)
  $relatedFiles = @(Get-RelatedFiles -Content $content)
  $relatedNotes = @(Get-RelatedNotes -Content $content -Catalog $catalog)
  $decisionCandidates = @(Get-DecisionCandidates -Content $content)
  $taskCandidates = @(Get-TaskCandidates -Content $content)
  $excerpt = Get-Excerpt -Content $content
  $importedAt = Get-Date -Format o

  $rawLines = @(
    "---",
    "type: raw-chat",
    "source_file: $relative",
    "imported_at: $importedAt",
    "---",
    "# $title",
    "",
    $content
  )
  Write-TextFile -Path (Join-Path $rawRoot "$slug.md") -Lines $rawLines

  $normalizedLines = New-Object System.Collections.Generic.List[string]
  $normalizedLines.Add("---")
  $normalizedLines.Add("type: chat-note")
  $normalizedLines.Add("source_file: $relative")
  $normalizedLines.Add("imported_at: $importedAt")
  $normalizedLines.Add("status: imported")
  $normalizedLines.Add("tags:")
  if ($tags.Count -gt 0) {
    foreach ($tag in $tags) {
      $normalizedLines.Add("  - $tag")
    }
  } else {
    $normalizedLines.Add("  - chat")
  }
  $normalizedLines.Add("---")
  $normalizedLines.Add("# $title")
  $normalizedLines.Add("")
  $normalizedLines.Add("## Summary")
  $normalizedLines.Add("")
  $normalizedLines.Add("- source: $relative")
  $normalizedLines.Add("- imported_at: $importedAt")
  $normalizedLines.Add("- raw_note: [[raw/$slug]]")
  $normalizedLines.Add("")
  $normalizedLines.Add("## Related Files")
  $normalizedLines.Add("")
  if ($relatedFiles.Count -gt 0) {
    foreach ($item in $relatedFiles) {
      $normalizedLines.Add("- $item")
    }
  } else {
    $normalizedLines.Add("- none")
  }
  $normalizedLines.Add("")
  $normalizedLines.Add("## Related Notes")
  $normalizedLines.Add("")
  if ($relatedNotes.Count -gt 0) {
    foreach ($item in $relatedNotes) {
      $normalizedLines.Add("- $item")
    }
  } else {
    $normalizedLines.Add("- none")
  }
  $normalizedLines.Add("")
  $normalizedLines.Add("## Excerpt")
  $normalizedLines.Add("")
  $normalizedLines.Add('```text')
  $normalizedLines.Add($excerpt)
  $normalizedLines.Add('```')

  Write-TextFile -Path (Join-Path $normalizedRoot "$slug.md") -Lines $normalizedLines

  $decisionIndex = 1
  foreach ($decision in $decisionCandidates) {
    $decisionSlug = Get-Slug ("decision-{0}-{1}" -f $slug, $decisionIndex)
    $decisionLines = @(
      "---",
      "type: decision",
      "status: active",
      "source_note: [[${slug}]]",
      "created_at: $importedAt",
      "tags:",
      "  - decision",
      "---",
      "# Decision $decisionIndex",
      "",
      "## Decision",
      "",
      "- $decision",
      "",
      "## Related Notes",
      "",
      "- [[${slug}]]"
    )
    Write-TextFile -Path (Join-Path $decisionRoot "$decisionSlug.md") -Lines $decisionLines
    $decisionIndex++
  }

  $taskIndex = 1
  foreach ($task in $taskCandidates) {
    $taskSlug = Get-Slug ("task-{0}-{1}" -f $slug, $taskIndex)
    $taskLines = @(
      "---",
      "type: task",
      "status: open",
      "source_note: [[${slug}]]",
      "created_at: $importedAt",
      "tags:",
      "  - task",
      "---",
      "# Task $taskIndex",
      "",
      "## Goal",
      "",
      "- $task",
      "",
      "## Related Notes",
      "",
      "- [[${slug}]]"
    )
    Write-TextFile -Path (Join-Path $taskRoot "$taskSlug.md") -Lines $taskLines
    $taskIndex++
  }

  $state.imports | Add-Member -NotePropertyName $relative -NotePropertyValue $hash -Force
  $processed++
}

@($state | ConvertTo-Json -Depth 20) | Write-TextFile -Path $statePath

Write-Host "Imported $processed chat file(s)."
