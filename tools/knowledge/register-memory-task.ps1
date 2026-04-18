param(
  [string]$TaskName = "AscendMemoryPipeline",
  [int]$IntervalMinutes = 60
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$scriptPath = Join-Path $repoRoot "tools\knowledge\run-memory-pipeline.ps1"
$powershellExe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$startTime = (Get-Date).AddMinutes(2).ToString("HH:mm")
$arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""

schtasks /Create `
  /TN $TaskName `
  /SC MINUTE `
  /MO $IntervalMinutes `
  /TR "`"$powershellExe`" $arguments" `
  /ST $startTime `
  /F | Out-Null

Write-Host "Scheduled task '$TaskName' created to run every $IntervalMinutes minute(s)."
