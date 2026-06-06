param(
  [string]$ProjectId = "ascend-b7c20",
  [int]$Port = 8080,
  [switch]$Login
)

$ErrorActionPreference = "Stop"

$env:GOOGLE_CLOUD_PROJECT = $ProjectId
$env:ASCEND_BACKEND_PORT = "$Port"

function Test-GcloudApplicationDefaultCredentials {
  docker compose --profile auth run --rm --entrypoint sh gcloud-auth -lc `
    "test -f /root/.config/gcloud/application_default_credentials.json"
  return $LASTEXITCODE -eq 0
}

function Start-GcloudLogin {
  Write-Host "Iniciando login do Google Cloud dentro do Docker..."
  Write-Host "Projeto Google Cloud: $ProjectId"
  Write-Host "Abra a URL exibida pelo gcloud, conclua o login e cole o codigo no terminal."

  docker compose --profile auth run --rm gcloud-auth
  if ($LASTEXITCODE -ne 0) {
    throw "Login do Google Cloud nao foi concluido."
  }
}

if ($Login -or -not (Test-GcloudApplicationDefaultCredentials)) {
  Start-GcloudLogin
}

if (-not (Test-GcloudApplicationDefaultCredentials)) {
  throw "Credencial do Google Cloud nao encontrada no volume Docker apos o login."
}

Write-Host "Subindo Ascend Java Backend em Docker..."
Write-Host "Projeto Google Cloud: $ProjectId"
Write-Host "Porta local: $Port"
Write-Host "Health check: http://localhost:$Port/health"

docker compose up ascend-backend
