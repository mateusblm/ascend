# Ascend Java Backend

Spring Boot backend created for the planned migration from Firebase Functions
TypeScript to Java on Cloud Run.

Current status:
- Maven project skeleton exists.
- `/health` is implemented.
- Firebase Auth validation is implemented for `/api/v1/**`.
- `GET /api/v1/me` is implemented.
- `GET /api/v1/season-leaderboard` is implemented as the first read-only
  migration candidate.
- `POST /api/v1/quests/inventory:sync` is implemented as the first quest write
  migration candidate.
- TypeScript Functions remain authoritative.

## Local Commands

```powershell
cd backend
mvn test
mvn package
mvn spring-boot:run
```

Health check:

```text
GET http://localhost:8080/health
```

Expected response:

```json
{"status":"ok","service":"ascend-backend"}
```

## Cloud Run Staging Deploy

The staging service target is:

```text
ascend-backend-staging
```

Current staging URL:

```text
https://ascend-backend-staging-331143433117.southamerica-east1.run.app
```

Recommended region:

```text
southamerica-east1
```

The deploy helper lives at:

```powershell
..\tools\backend\deploy-cloud-run-staging.ps1
```

From the repository root:

```powershell
.\tools\backend\deploy-cloud-run-staging.ps1
```

If the runtime service account or API bindings have not been created yet, run:

```powershell
.\tools\backend\deploy-cloud-run-staging.ps1 -ConfigureIam
```

The helper expects `gcloud` and `mvn` on `PATH`. If Maven is installed outside
`PATH`, pass it explicitly. The same applies to `gcloud`:

```powershell
.\tools\backend\deploy-cloud-run-staging.ps1 -MavenCommand "C:\path\to\mvn.cmd"
.\tools\backend\deploy-cloud-run-staging.ps1 -GcloudCommand "C:\path\to\gcloud.cmd" -MavenCommand "C:\path\to\mvn.cmd"
```

Smoke checks after deploy:

```powershell
Invoke-RestMethod "$serviceUrl/health"
Invoke-RestMethod "$serviceUrl/api/v1/me" -Headers @{ Authorization = "Bearer <Firebase ID token>" }
Invoke-RestMethod "$serviceUrl/api/v1/season-leaderboard?seasonKey=<season>&rankBracket=E" -Headers @{ Authorization = "Bearer <Firebase ID token>" }
Invoke-RestMethod "$serviceUrl/api/v1/quests/inventory:sync" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<active device session id>","source":{"quests":[]}}'
```

Keep Cloud Run public at the IAM layer for now (`--allow-unauthenticated`) so
mobile clients can reach it directly. Application endpoints under `/api/v1/**`
still require Firebase ID tokens and reject unauthenticated requests.

## Migration Rules

Before migrating any endpoint:
- read `docs/ai/work-packages/java-backend-migration-plan.md`
- read `docs/ai/work-packages/java-backend-callable-inventory.md`
- read `docs/ai/java-backend-coding-standard.md`
- inspect the current TypeScript callable
- add Java tests
- keep Flutter routing behind staging/debug config until parity is proven

## Environment

Planned runtime:
- Java 21
- Spring Boot
- Cloud Run
- Firebase Admin SDK
- Firestore
- Google Secret Manager

