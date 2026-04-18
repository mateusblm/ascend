param(
  [string]$ConfigPath = "tools/knowledge/config.json"
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $scriptRoot "build-codebase-map.ps1") -ConfigPath $ConfigPath
& (Join-Path $scriptRoot "import-chats.ps1") -ConfigPath $ConfigPath

Write-Host "Memory pipeline completed."
