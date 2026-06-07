# Ascend Java Backend

Spring Boot backend created for the planned migration from Firebase Functions
TypeScript to Java on Cloud Run.

Current status:
- Maven project skeleton exists.
- `/health` is implemented.
- Firebase Auth validation is implemented for `/api/v1/**`.
- `GET /api/v1/me` is implemented.
- `POST /api/v1/session/active:register` and
  `POST /api/v1/session/active:release` are implemented for Java-first active
  device session authority.
- `GET /api/v1/season-leaderboard` is implemented as the first read-only
  migration candidate.
- `POST /api/v1/quests/inventory:sync` is implemented as the first quest write
  migration candidate.
- `POST /api/v1/competitive/promotion/exam:start` and
  `POST /api/v1/competitive/promotion:confirm` are implemented for Java-first
  promotion exam start and promotion confirmation.
- `POST /api/v1/season-rewards/current:claim` is implemented for Java-first
  season reward claim, legacy reward write, and active season profile update.
- `POST /api/v1/reading-quiz:attempt` is implemented for Java-first reading
  quiz attempt creation, with deterministic generation by default and optional
  Gemini generation through Secret Manager or environment configuration.
- `POST /api/v1/quests/competitive:verify` now evaluates backend-owned reading
  quiz attempts in Java before granting competitive XP/rank-bearing rewards.
- `POST /api/v1/profile/settings:update` and
  `POST /api/v1/profile/attributes:allocate` are implemented for Java-first
  profile settings and attribute allocation authority.
- `POST /api/v1/weekly-boss:claim` is implemented for Java-first weekly boss
  claim authority, including profile reward, completion leaderboard, user claim
  record, and idempotent duplicate handling.
- TypeScript Functions remain deployed for fallback and unmigrated callables.

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

## Local Docker

Use Docker para subir o backend Java sem instalar Java, Maven ou gcloud na
maquina. O login do Google Cloud tambem roda em container e grava a credencial
em um volume Docker local.

Suba o backend pela raiz do repositorio:

```powershell
.\tools\backend\start-local-docker.ps1
```

Na primeira execucao, ou quando a credencial local do volume Docker nao existir,
o script roda o login do Google Cloud automaticamente. Para forcar um novo
login:

```powershell
.\tools\backend\start-local-docker.ps1 -Login
```

Isso sobe o servico em:

```text
http://localhost:8080
```

Para usar outra porta:

```powershell
.\tools\backend\start-local-docker.ps1 -Port 8081
```

Se precisar trocar o projeto Google Cloud:

```powershell
.\tools\backend\start-local-docker.ps1 -ProjectId ascend-b7c20 -Login
.\tools\backend\start-local-docker.ps1 -ProjectId ascend-b7c20
```

Com o backend local no Docker, rode o Flutter apontando para ele:

```powershell
flutter run --dart-define=ASCEND_JAVA_BACKEND_URL=http://localhost:8080
```

No Android emulator, use o host especial do emulador:

```powershell
flutter run --dart-define=ASCEND_JAVA_BACKEND_URL=http://10.0.2.2:8080
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
Invoke-RestMethod "$serviceUrl/api/v1/session/active:register" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<device session id>","deviceLabel":"android"}'
Invoke-RestMethod "$serviceUrl/api/v1/session/active:release" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<device session id>","deviceLabel":"android"}'
Invoke-RestMethod "$serviceUrl/api/v1/season-leaderboard?seasonKey=<season>&rankBracket=E" -Headers @{ Authorization = "Bearer <Firebase ID token>" }
Invoke-RestMethod "$serviceUrl/api/v1/quests/inventory:sync" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<active device session id>","source":{"quests":[]}}'
Invoke-RestMethod "$serviceUrl/api/v1/competitive/promotion/exam:start" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"snapshot":{"currentRank":"D","peakRank":"D","highestEligibleRank":"C","weekKey":"2026W0608","activeDays":5,"requiredActiveDays":4,"requiresBossClear":false,"bossCompleted":true,"status":"promotionReady","demotionStrikes":0,"promotionReady":true,"promotionTargetRank":"C","targetRequiredLevel":10,"targetLevelGateMet":true,"advancementMode":"ascension","eventType":"promotionUnlocked","summary":"Exame de promocao pronto para o rank C.","detail":"Smoke manual.","syncSchemaVersion":3,"syncSource":"backend","updatedAt":"2026-06-06T12:00:00Z"}}'
Invoke-RestMethod "$serviceUrl/api/v1/season-rewards/current:claim" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"seasonKey":"<season>"}'
Invoke-RestMethod "$serviceUrl/api/v1/reading-quiz:attempt" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<active device session id>","deviceLabel":"android","questId":"reading-20-<id>","templateCatalogId":"reading-20","topic":"leitura"}'
Invoke-RestMethod "$serviceUrl/api/v1/profile/settings:update" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<active device session id>","deviceLabel":"android","name":"Jogador","primaryFocus":"study","hasCompletedOnboarding":true,"lastResetDate":"2026-06-07T00:00:00Z"}'
Invoke-RestMethod "$serviceUrl/api/v1/profile/attributes:allocate" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<active device session id>","deviceLabel":"android","attribute":"strength"}'
Invoke-RestMethod "$serviceUrl/api/v1/weekly-boss:claim" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer <Firebase ID token>" } -Body '{"deviceSessionId":"<active device session id>","deviceLabel":"android","bossId":"<weekly boss id>","displayName":"Jogador","photoUrl":"","rankAtCompletion":"E"}'
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

