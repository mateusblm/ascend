param(
  [string]$ProjectId = "ascend-b7c20",
  [int]$Port = 8080,
  [switch]$Login
)

$ErrorActionPreference = "Stop"

$env:GOOGLE_CLOUD_PROJECT = $ProjectId
$env:ASCEND_BACKEND_PORT = "$Port"

if ($Login) {
  Write-Host "Iniciando login do Google Cloud dentro do Docker..."
  Write-Host "Projeto Google Cloud: $ProjectId"
  Write-Host "Abra a URL exibida pelo gcloud, conclua o login e cole o codigo no terminal."

  docker compose --profile auth run --rm gcloud-auth
}

Write-Host "Subindo Ascend Java Backend em Docker..."
Write-Host "Projeto Google Cloud: $ProjectId"
Write-Host "Porta local: $Port"
Write-Host "Health check: http://localhost:$Port/health"
Write-Host "Se for a primeira vez nesta maquina, rode com: .\tools\backend\start-local-docker.ps1 -Login"

docker compose up ascend-backend
