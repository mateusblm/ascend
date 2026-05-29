param(
  [string]$ProjectId = "ascend-b7c20",
  [string]$Region = "southamerica-east1",
  [string]$ServiceName = "ascend-backend-staging",
  [string]$GcloudCommand = "gcloud",
  [string]$MavenCommand = "mvn",
  [string]$ServiceAccountName = "ascend-backend-staging-runner",
  [switch]$ConfigureIam
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Command {
  param([string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command '$Name' was not found on PATH."
  }
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$backendDir = Join-Path $repoRoot "backend"
$serviceAccountEmail = "$ServiceAccountName@$ProjectId.iam.gserviceaccount.com"

Require-Command $GcloudCommand
Require-Command $MavenCommand

Push-Location $backendDir
try {
  & $MavenCommand test
  & $MavenCommand package

  if ($ConfigureIam) {
    & $GcloudCommand services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com firestore.googleapis.com `
      --project $ProjectId

    $existingAccount = & $GcloudCommand iam service-accounts list `
      --project $ProjectId `
      --filter "email=$serviceAccountEmail" `
      --format "value(email)" 2>$null

    if (-not $existingAccount) {
      & $GcloudCommand iam service-accounts create $ServiceAccountName `
        --project $ProjectId `
        --display-name "Ascend Java backend staging runtime"
    }

    & $GcloudCommand projects add-iam-policy-binding $ProjectId `
      --member "serviceAccount:$serviceAccountEmail" `
      --role "roles/datastore.user"
  }

  & $GcloudCommand run deploy $ServiceName `
    --project $ProjectId `
    --region $Region `
    --source . `
    --service-account $serviceAccountEmail `
    --allow-unauthenticated `
    --set-env-vars "ASCEND_ENV=staging,GOOGLE_CLOUD_PROJECT=$ProjectId"

  $serviceUrl = & $GcloudCommand run services describe $ServiceName `
    --project $ProjectId `
    --region $Region `
    --format "value(status.url)"

  Write-Host "Cloud Run staging URL: $serviceUrl"
  Write-Host "Smoke health: Invoke-RestMethod '$serviceUrl/health'"
  Write-Host "Smoke auth: call '$serviceUrl/api/v1/me' with Authorization: Bearer <Firebase ID token>"
  Write-Host "Smoke leaderboard: call '$serviceUrl/api/v1/season-leaderboard?seasonKey=<key>&rankBracket=E' with the same token"
} finally {
  Pop-Location
}
