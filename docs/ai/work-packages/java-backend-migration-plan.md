# Java Backend Migration Plan

## Purpose

Guide future AI sessions through a controlled migration from the current
Firebase Functions TypeScript backend to a Java backend using Maven,
Spring Boot, and Cloud Run.

This is a migration plan, not an active architecture change. Until a step is
explicitly completed and validated, the current TypeScript backend remains the
production source of truth.

## Decision

Target backend stack:
- Language: Java 21
- Dependency/build tool: Maven
- Framework: Spring Boot
- Runtime/deploy target: Google Cloud Run
- Auth: Firebase Auth ID token validation in the Java service
- Database: Firestore remains the canonical database
- Secrets: Google Secret Manager
- Existing backend: Firebase Functions TypeScript remains active during the
  migration

Do not start a new Ascend project. Keep:
- Flutter app
- Firebase project
- Firestore data model unless a migration is explicitly approved
- existing docs, tests, and product direction
- TypeScript Functions as the behavioral reference until Java reaches parity

## Non-Goals

Do not use this migration to:
- redesign the product
- change XP, rank, quest, evidence, or reward rules without a separate product
  decision
- move reward-bearing authority back into Flutter
- replace Firebase Auth or Firestore
- remove TypeScript Functions before Java parity is proven
- rewrite all backend code in one large step

## Migration Principles

1. Preserve behavior before improving behavior.
2. Migrate one callable or endpoint at a time.
3. Keep rollback available for every migrated endpoint.
4. Add tests before switching Flutter to the Java endpoint.
5. Document every contract before implementation.
6. Treat XP, rank, rewards, evidence, sessions, and account state as sensitive.
7. Prefer small Java services/classes with clear names over clever abstractions.
8. Keep TypeScript and Java results comparable during the transition.

## Current Backend Reference

Current backend location:
- `functions/src/`
- `functions/test/`

Important current callable groups:
- account/session authority
- player profile authority
- quest inventory sync
- personal quest completion and revoke
- competitive rank progression
- competitive integrity
- competitive evidence verification
- promotion exams
- season rewards
- leaderboard reads
- reading quiz generation

Before migrating any function, inspect the current TypeScript implementation
and tests for that exact behavior.

## Target Repository Layout

Create the Java backend under:

```text
backend/
  pom.xml
  Dockerfile
  README.md
  src/
    main/
      java/
        app/ascend/backend/
          AscendBackendApplication.java
          auth/
          config/
          firestore/
          quests/
          progression/
          evidence/
          ai/
          shared/
    test/
      java/
        app/ascend/backend/
          quests/
          progression/
          evidence/
          ai/
```

Suggested package responsibilities:

```text
auth/
  FirebaseAuthTokenVerifier
  AuthenticatedUser
  AuthFilter or HandlerMethodArgumentResolver

config/
  FirebaseAdminConfig
  FirestoreConfig
  SecretManagerConfig

firestore/
  FirestorePaths
  FirestoreTimestampMapper
  FirestoreRepositorySupport

quests/
  QuestController
  QuestService
  QuestRepository
  QuestDtos
  PersonalQuestService
  QuestInventorySyncService

progression/
  ProgressionController
  RankProgressionService
  CompetitiveIntegrityService
  PromotionExamService
  SeasonRewardService

evidence/
  EvidenceController
  EvidenceEvaluator
  EvidenceDtos
  DuplicateEvidenceGuard

ai/
  ReadingQuizController
  ReadingQuizService
  AiQuizProvider
  GeminiQuizProvider
  MockQuizProvider

shared/
  ApiError
  ApiExceptionHandler
  ClockProvider
  Validation
  Json
```

## Maven Baseline

Use Maven, not Gradle, for the Java backend.

Initial `pom.xml` should include only the minimum required dependencies:

```xml
<dependencies>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>

  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
  </dependency>

  <dependency>
    <groupId>com.google.firebase</groupId>
    <artifactId>firebase-admin</artifactId>
  </dependency>

  <dependency>
    <groupId>com.google.cloud</groupId>
    <artifactId>google-cloud-secretmanager</artifactId>
  </dependency>

  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
  </dependency>
</dependencies>
```

Use Spring Boot dependency management instead of manually pinning every
transitive dependency unless there is a security reason.

Do not add:
- Lombok initially
- database ORMs
- GraphQL
- reactive stack
- broad utility libraries
- AI SDKs before the AI migration phase

Keep the first backend boring and reviewable.

## API Style

Use REST-style HTTP endpoints on Cloud Run.

Recommended base path:

```text
/api/v1
```

Examples:

```text
GET  /health
GET  /api/v1/season-leaderboard
POST /api/v1/quests/inventory:sync
POST /api/v1/quests/personal:complete
POST /api/v1/quests/personal:revoke
POST /api/v1/competitive/state:sync
POST /api/v1/competitive/integrity:sync
POST /api/v1/reading-quiz:attempt
```

Every protected endpoint must:
- require `Authorization: Bearer <Firebase ID token>`
- validate the token server-side
- derive `uid` from the token, not from client payload
- reject unauthenticated requests with `401`
- reject invalid payloads with `400`
- reject business preconditions with `409` or `412`
- avoid leaking internal stack traces

## Contract Documentation Template

Before migrating an endpoint, create or update a contract section with:

```text
Endpoint:
Current TS callable:
Java endpoint:
Auth:
Request:
Response:
Errors:
Firestore reads:
Firestore writes:
Business rules:
Tests required:
Rollback path:
Flutter switch point:
```

## Phase 0 - Preparation And Inventory

Goal:
- make the migration auditable before adding Java code.

Steps:
1. List every exported TypeScript callable in `functions/src/index.ts`.
2. Group each callable by domain:
   - account
   - profile
   - quests
   - competitive
   - evidence
   - AI
   - reads/leaderboards
3. For each callable, record:
   - name
   - input fields
   - output fields
   - Firestore paths touched
   - tests that currently cover it
   - whether Flutter currently calls it
   - risk level: low, medium, high
4. Mark migration order.
5. Do not implement Java until this inventory exists.

Exit criteria:
- this plan has a completed callable inventory appendix or a linked inventory
  document
- high-risk functions are clearly identified
- first migration candidate is chosen

Recommended first candidate:
- a read-only endpoint such as season/bracket leaderboard

## Phase 1 - Java Backend Skeleton

Goal:
- create a deployable Java service without moving business logic yet.

Steps:
1. Create `backend/`.
2. Add `pom.xml`.
3. Add Spring Boot application class.
4. Add `/health` endpoint.
5. Add Maven test setup.
6. Add `Dockerfile`.
7. Add local README with run/test/deploy commands.
8. Add `.gitignore` entries if needed for Java build output.

Required commands:

```powershell
cd backend
mvn test
mvn package
```

Expected local endpoint:

```text
GET /health -> 200 {"status":"ok"}
```

Exit criteria:
- `mvn test` passes
- `mvn package` passes
- container builds locally or in Cloud Build
- `/health` works locally

## Phase 2 - Cloud Run Staging Deployment

Goal:
- deploy the empty Java service safely.

Steps:
1. Create or select the Cloud Run service name:
   - `ascend-backend-staging`
2. Configure region:
   - prefer the same region family as current Functions where practical
3. Configure service account with minimal permissions.
4. Grant Firestore access only when needed.
5. Configure environment variables:
   - `ASCEND_ENV=staging`
   - `GOOGLE_CLOUD_PROJECT=ascend-b7c20`
6. Deploy `/health`.
7. Record Cloud Run URL in an ignored local env file or documented staging
   config.

Exit criteria:
- Cloud Run `/health` returns 200
- logs are visible
- service account is known
- no Flutter production traffic points to Java yet

## Phase 3 - Firebase Auth Validation

Goal:
- prove the Java service can authenticate the same users as Firebase Functions.

Steps:
1. Add Firebase Admin SDK initialization.
2. Add token verifier.
3. Add protected endpoint:

```text
GET /api/v1/me
```

Response:

```json
{
  "uid": "firebase-user-id",
  "email": "user@example.com"
}
```

4. Add tests for:
   - missing token
   - invalid token
   - valid token verifier path with test double
5. Add Flutter-side experimental client only if needed for smoke testing.

Exit criteria:
- unauthenticated request returns 401
- authenticated request returns current Firebase uid
- no business endpoint exists without auth unless intentionally public

## Phase 4 - Contract Freeze For First Endpoint

Goal:
- choose one endpoint and document exact parity requirements.

Recommended first endpoint:
- `getSeasonBracketLeaderboard`

Why:
- read-only
- low risk
- useful for proving Cloud Run/Firestore/Auth integration

Steps:
1. Document the TypeScript callable input.
2. Document the TypeScript callable output.
3. Document all error cases.
4. Add or confirm TS tests around the behavior.
5. Create Java DTOs.
6. Create Java service tests before wiring Flutter.

Exit criteria:
- Java has tests proving expected behavior
- contract is documented
- Flutter has not switched yet

## Phase 5 - First Read Endpoint Migration

Goal:
- migrate one read-only endpoint end-to-end.

Steps:
1. Implement Java controller.
2. Implement Java service.
3. Implement Firestore repository.
4. Add unit tests for service logic.
5. Add controller tests for request/response and auth.
6. Deploy to Cloud Run staging.
7. Add a Flutter feature flag or environment config for Java backend URL.
8. Switch only staging/debug to Java endpoint.
9. Compare Java response against current TS response.
10. Keep TS callable active.

Exit criteria:
- staging Flutter can call Java endpoint
- UI behavior remains unchanged
- rollback is one config change back to TS
- no write behavior migrated yet

## Phase 6 - Quest Inventory Migration

Goal:
- migrate quest inventory sync without changing quest rules.

Current state:
- implemented locally in Java as `POST /api/v1/quests/inventory:sync`
- Flutter can route `QuestSyncRepository.replaceQuests` to Java when
  `ASCEND_JAVA_BACKEND_URL` is provided
- Firebase Functions remain the default and fallback path
- Cloud Run staging deploy for this endpoint is complete
- authenticated local Docker smoke passed on 2026-06-06
- authenticated Cloud Run staging smoke passed on 2026-06-06

Candidates:
- `syncQuestInventoryFromSource`

Steps:
1. Freeze contract.
2. Port validation logic from TypeScript to Java.
3. Preserve session authority behavior.
4. Preserve Firestore write paths:
   - `users/{uid}/quests/{questId}`
   - `users/{uid}/quests_meta/current`
5. Add tests for:
   - valid inventory
   - invalid quest id
   - invalid XP range
   - invalid enum values
   - duplicate quest ids
   - active session conflict
   - Firestore writes generated
6. Run TS and Java against equivalent fixtures.
7. Switch staging only.

Exit criteria:
- local quest cache still syncs: completed
- remote inventory remains readable by Flutter: completed
- no XP/reward is granted by this endpoint: completed

## Phase 7 - Personal Quest Authority Migration

Goal:
- migrate personal quest completion and revoke flows.

Candidates:
- `completePersonalQuest`
- `revokePersonalQuestCompletion`

Risk:
- high, because these affect XP, profile, completion state, and undo.

Steps:
1. Freeze contracts: completed.
2. Create shared Java domain model for:
   - Player
   - Quest
   - AttributeType
   - completion snapshot: completed locally in Java.
3. Port XP grant logic exactly: completed for personal quests.
4. Port pre-reward snapshot handling exactly: completed locally in Java.
5. Port revoke behavior exactly: completed and manually validated in staging.
6. Preserve active session conflict behavior: completed.
7. Add tests for:
   - first completion grants XP: completed
   - duplicate completion does not double-grant: completed
   - revoke restores pre-reward snapshot: completed
   - revoke without completion is safe: pending
   - level-up boundaries: completed through first-completion level-up fixture
   - attribute changes: completed
   - active session conflict: completed
8. Run staging with a test account: completed for personal quest completion,
   XP, attribute reward, and revoke rollback on 2026-06-06.
9. Compare Firestore documents before and after: completed through manual
   staging revoke rollback smoke on 2026-06-06.

Exit criteria:
- personal quest loop works from Flutter through Java: completion validated on
  staging for normal quests on 2026-06-06
- no double rewards: covered by Java service test; pending manual duplicate
  completion smoke if desired
- revoke remains safe: implemented, covered by Java service test, and manually
  validated in staging on 2026-06-06
- TS rollback still available: completed via Firebase Functions fallback when
  `ASCEND_JAVA_BACKEND_URL` is omitted or non-session Java errors occur

Competitive quest completion remains out of scope for Phase 7 validation. It is
tracked separately because current behavior was not considered reliable enough
in the TypeScript path to use as a clean migration parity target.

## Phase 8 - Competitive State And Integrity Migration

Goal:
- migrate competitive read models and integrity calculations.

Candidates:
- `syncCompetitiveStateFromSource`
- `syncCompetitiveIntegrityFromSource`

Risk:
- high, because these influence rank trust and competitive feedback.

Steps:
1. Freeze contracts: started from current TypeScript callables and Flutter
   read-model contracts.
2. Create fixture set from TS tests: started locally in Java service tests.
3. Port rank evaluation logic: started in Java with pure domain calculator.
4. Port integrity evaluation logic: started in Java with pure domain
   calculator.
5. Add golden parity tests: started with rank promotion, demotion, and
   integrity suspicious-pattern fixtures.

```text
given fixture A
TS expected snapshot X
Java must return snapshot X
```

6. Preserve `syncSchemaVersion`.
7. Preserve `syncSource`.
8. Preserve demotion/promotion flags.
9. Preserve trust labels and risk details.
10. Run Java in shadow mode if possible:
    - Flutter still uses TS result
    - Java result is logged/compared manually

Exit criteria:
- Java and TS produce the same snapshots for known cases
- staging UI rank/integrity does not regress
- no competitive authority switches without parity

Current status:
- Java package `app.ascend.backend.competitivo` now contains a side-effect-free
  competitive state calculator for rank and integrity snapshots.
- The first Phase 8 slice intentionally does not expose an endpoint, write
  Firestore, grant XP, or switch Flutter authority.
- Local Java validation passed with `mvn test` and `mvn package` on 2026-06-06.

## Phase 9 - Competitive Evidence Migration

Goal:
- migrate evidence validation while preserving backend authority.

Candidates:
- evidence submission/verification logic
- duplicate `sourceActivityId` checks
- accepted/rejected/duplicate decision details

Steps:
1. Freeze evidence contract.
2. Port evidence DTOs.
3. Port accepted/rejected reason codes.
4. Port duplicate source guard.
5. Port stale/impossible evidence checks.
6. Add tests for:
   - valid mock evidence
   - valid Health Connect evidence
   - duplicate source activity id
   - impossible pace
   - stale session
   - missing reading quiz
   - rejected evidence details returned to Flutter
7. Switch staging only.

Exit criteria:
- competitive quest UI still shows clear decision feedback
- backend remains final decision maker
- mock evidence remains non-production-safe and clearly flagged

## Phase 10 - Promotion And Season Rewards Migration

Goal:
- migrate higher-stakes rank advancement and seasonal reward flows.

Candidates:
- promotion exam start/confirm
- season reward claim
- legacy reward records

Steps:
1. Freeze contracts.
2. Port promotion mode logic.
3. Port season reward logic.
4. Preserve idempotency.
5. Add tests for:
   - promotion available
   - promotion unavailable
   - reconquest mode
   - ascension mode
   - duplicate reward claim
   - legacy reward write
6. Stage with test account.

Exit criteria:
- no duplicate claims
- no invalid promotion
- history/read models remain compatible with Flutter

## Phase 11 - AI Reading Quiz Migration

Goal:
- migrate quiz generation to Java after core authority flows are stable.

Candidates:
- `startReadingQuizAttempt`

Steps:
1. Keep current AI provider decision documented.
2. Add AI abstraction:
   - `AiQuizProvider`
   - `GeminiQuizProvider`
   - `MockQuizProvider`
3. Load API key from Secret Manager.
4. Preserve safe topic handling.
5. Preserve structured quiz response.
6. Add tests with mock provider.
7. Add failure fallback.
8. Stage with non-sensitive topic only.

Exit criteria:
- Java can generate a quiz attempt
- Flutter quiz flow remains unchanged
- provider failures do not crash quest flow

## Phase 12 - Flutter Routing And Backend Client Cleanup

Goal:
- make Flutter backend selection explicit and maintainable.

Steps:
1. Add a Java backend client abstraction in Flutter.
2. Keep TS callable clients available until migration ends.
3. Route per feature, not globally all at once.
4. Use staging/debug flags first.
5. Document environment variables or build-time config.
6. Remove TS client paths only after production parity.

Exit criteria:
- developers can see which backend serves each feature
- rollback is possible per feature
- no hidden mixed authority paths

## Phase 13 - TypeScript Decommission

Goal:
- remove TypeScript Functions only when Java is fully authoritative.

Steps:
1. Confirm no Flutter code calls migrated TS functions.
2. Confirm no scheduled/event functions remain needed.
3. Keep TS deployed for a rollback window.
4. Monitor:
   - Cloud Run errors
   - Firebase Crashlytics
   - callable failures
   - support reports
5. Remove TS functions one group at a time.
6. Update docs:
   - `docs/ai/architecture-map.md`
   - `docs/product/progression-architecture.md`
   - `docs/product/release-environments.md`
   - `docs/ai/source-of-truth.md`

Exit criteria:
- Java backend is the documented source of authority
- TypeScript Functions no longer serve active product behavior
- rollback plan is archived

## Validation Gates

Every migration phase must pass:

```powershell
# Flutter
rtk flutter analyze
rtk flutter test
rtk flutter build apk --flavor staging --debug

# TypeScript while it exists
cd functions
npm test
npm run build

# Java after backend/ exists
cd backend
mvn test
mvn package
```

For backend-sensitive phases, also require:
- Firestore rules tests if rules changed
- staging deploy smoke
- real-device or emulator smoke
- test account walkthrough

## Rollback Requirements

Each migrated endpoint must have:
- old TS callable still deployed
- Flutter config or feature flag to switch back
- no irreversible Firestore schema change
- documented rollback command or config change

If a Java endpoint causes production instability:
1. switch Flutter/API routing back to TS
2. keep logs
3. do not hotfix blindly
4. reproduce with a fixture
5. add a regression test
6. redeploy Java only after test passes

## Data Migration Policy

Avoid Firestore schema migrations during the language migration.

Allowed:
- adding compatible fields
- writing the same fields as TS
- adding Java-only logs/metadata outside user-facing documents

Not allowed without a separate migration plan:
- renaming collections
- deleting fields
- changing enum strings
- changing quest ids
- changing rank keys
- changing profile document structure

## Security Policy

The Java backend must:
- validate Firebase Auth token on every protected request
- never trust `uid` from request body
- validate all DTO fields
- reject unknown or invalid enum values
- keep secrets out of git
- use least-privilege service accounts
- keep Firestore direct client writes blocked for sensitive models

## Suggested Timeline

This migration should not block immediate product stabilization.

Recommended sequencing:

```text
Week 1:
  Phase 0, Phase 1

Week 2:
  Phase 2, Phase 3

Week 3:
  Phase 4, Phase 5

Weeks 4-5:
  Phase 6, Phase 7

Weeks 6-7:
  Phase 8, Phase 9

Week 8:
  Phase 10

Week 9:
  Phase 11

Week 10:
  Phase 12, Phase 13 planning
```

The timeline can expand if product release work has higher priority.

## AI Working Instructions

When a future AI session works on this migration:

1. Read this file first.
2. Read `AGENTS.md`.
3. Read:
   - `docs/ai/source-of-truth.md`
   - `docs/ai/architecture-map.md`
   - `docs/product/progression-architecture.md`
   - `docs/product/competitive-verification-v1.md`
   - `docs/ai/java-backend-coding-standard.md`
4. Inspect the current TypeScript function before writing Java.
5. Add tests before switching Flutter.
6. Keep changes small enough for a Java reviewer to understand.
7. Explain business rules in Portuguese in the final response.
8. Do not delete TypeScript code unless the decommission phase is explicitly
   active.

## Initial Backlog

Pending tasks:
- create callable inventory: `completed in java-backend-callable-inventory.md`
- create `backend/` Maven skeleton: completed
- add `/health`: completed
- validate `backend/` with Maven: completed after installing Apache Maven 3.9.16
- add Firebase Auth validation endpoint: completed locally with `GET /api/v1/me`
- choose first read-only endpoint: completed with `getSeasonBracketLeaderboard`
- document first endpoint contract: completed in `java-backend-callable-inventory.md`
- implement first Java endpoint: completed locally with
  `GET /api/v1/season-leaderboard`
- create Cloud Run staging deploy helper: completed with
  `tools/backend/deploy-cloud-run-staging.ps1`
- deploy Cloud Run staging service: completed for `ascend-backend-staging`
- run unauthenticated Cloud Run smoke checks: completed
- run authenticated Cloud Run smoke checks with a Firebase ID token
- wire Flutter staging/debug config to Java endpoint after Cloud Run deploy:
  completed for the season leaderboard and quest inventory sync, gated by
  `ASCEND_JAVA_BACKEND_URL`
- implement quest inventory sync in Java: completed locally with
  `POST /api/v1/quests/inventory:sync`
- deploy quest inventory sync to Cloud Run staging: completed
- run authenticated quest inventory sync smoke with a Firebase ID token and
  active device session

## Status

Current status:
- plan created
- callable inventory created
- Java backend skeleton created under `backend/`
- `/health` endpoint created
- Maven validation completed with Apache Maven 3.9.16
- Firebase Auth token filter created for `/api/v1/**`
- protected `/api/v1/me` endpoint created and tested
- Java `GET /api/v1/season-leaderboard` endpoint created and tested as the
  first migrated read-only endpoint
- Java `POST /api/v1/quests/inventory:sync` endpoint created and tested as the
  first migrated quest write endpoint
- Phase 6 quest inventory migration validated locally and on Cloud Run staging
  with authenticated Flutter smoke on 2026-06-06
- Phase 7 personal quest authority started locally with Java REST endpoints:
  - `POST /api/v1/quests/personal:complete`
  - `POST /api/v1/quests/personal:revoke`
- Flutter staging/debug can route personal quest complete/revoke to Java with
  `ASCEND_JAVA_BACKEND_URL`, while retaining Firebase Functions fallback on
  non-session Java errors
- Authenticated staging smoke confirmed normal personal quest completion through
  Java grants XP and attribute reward correctly on 2026-06-06
- Authenticated staging smoke confirmed normal personal quest revoke/rollback
  through Java works correctly on 2026-06-06
- Competitive quest completion is intentionally not a Phase 7 focus because its
  baseline behavior appears pre-existing outside this Java migration
- Cloud Run staging deploy helper created for `ascend-backend-staging`
- Cloud Run staging service deployed:
  - `https://ascend-backend-staging-331143433117.southamerica-east1.run.app`
- unauthenticated smoke checks passed:
  - `/health` returns `200`
  - `/api/v1/me` returns `401` without a Firebase ID token
  - `/api/v1/season-leaderboard` returns `401` without a Firebase ID token
  - `/api/v1/quests/inventory:sync` returns `401` without a Firebase ID token
- Flutter staging/debug can route the season leaderboard read to Java with:
  - `--dart-define=ASCEND_JAVA_BACKEND_URL=https://ascend-backend-staging-331143433117.southamerica-east1.run.app`
- Flutter staging/debug can route quest inventory sync to Java with the same
  `ASCEND_JAVA_BACKEND_URL`, with fallback to the TypeScript callable on
  non-session Java errors
- Flutter keeps Firebase Functions as the default when the Java URL is omitted
- local validation passed:
  - `mvn test`
  - `mvn package`
  - `flutter analyze`
  - `flutter test`
  - `flutter test test/features/profile/data/java_backend_client_test.dart`
- current blocker:
  - authenticated Cloud Run smoke requires a real Firebase ID token from a test
    user before this route should be enabled outside staging/debug validation
- current TypeScript backend remains authoritative
- Maven is the selected Java dependency/build tool
