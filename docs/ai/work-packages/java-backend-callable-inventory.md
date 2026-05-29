# Java Backend Callable Inventory

## Purpose

Inventory the current Firebase Functions TypeScript callable surface before
starting the Java/Spring Boot migration.

Reference plan:
- `docs/ai/work-packages/java-backend-migration-plan.md`

Current backend source:
- `functions/src/index.ts`

Current backend tests:
- `functions/test/account-authority.test.js`
- `functions/test/competitive-quest-authority.test.js`
- `functions/test/competitive-sync-payload.test.js`
- `functions/test/firestore-rules.test.js`

## Migration Rule

Do not port a callable to Java until its contract is explicitly frozen:
- request payload
- response payload
- error cases
- Firestore reads and writes
- Flutter caller
- tests required
- rollback path

## Summary

Total exported callables found:
- 20

Risk distribution:
- Low: 2
- Medium: 8
- High: 10

Recommended first Java candidate:
- `getSeasonBracketLeaderboard`

Reason:
- read-only
- authenticated
- useful to validate Cloud Run, Firebase Auth, Firestore reads, DTOs, and
  Flutter routing without changing rewards or progression

## Callable Inventory

### registerActiveSession

Domain:
- account/session

Current TS callable:
- `registerActiveSession`

Known Flutter callers:
- `lib/features/auth/data/active_session_repository.dart`

Request:
- `deviceSessionId`
- `deviceLabel`

Response:
- `status: registered`
- `expiresAt`

Firestore:
- writes `users/{uid}/session/active`

Behavior:
- requires Firebase Auth
- creates or renews active device lease
- rejects if another unexpired device session owns the account

Risk:
- high

Java migration priority:
- later, after read endpoint and Java auth are proven

Tests required before migration:
- missing auth
- valid registration
- same session renewal
- different active session conflict
- expired previous session replacement

Rollback:
- keep Flutter using current callable until all session-sensitive endpoints have
  equivalent Java behavior

### releaseActiveSession

Domain:
- account/session

Current TS callable:
- `releaseActiveSession`

Known Flutter callers:
- `lib/features/auth/data/active_session_repository.dart`
- logout flow

Request:
- `deviceSessionId`
- `deviceLabel`

Response:
- `status: released`

Firestore:
- deletes `users/{uid}/session/active` only if the session id matches

Behavior:
- requires Firebase Auth
- safely ignores non-matching release requests

Risk:
- medium

Java migration priority:
- migrate with `registerActiveSession`, not independently

Tests required:
- missing auth
- release own session
- ignore non-current session
- idempotent release

### updateProfileSettings

Domain:
- profile/account

Current TS callable:
- `updateProfileSettings`

Known Flutter callers:
- `lib/features/profile/data/player_profile_repository.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `name`
- `primaryFocus`
- `hasCompletedOnboarding`
- `lastResetDate`

Response:
- `status: updated`
- `profile`

Firestore:
- reads/writes `users/{uid}/profile/current`
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- updates profile identity/onboarding settings
- recalculates streak when reset date indicates a gap

Risk:
- medium

Java migration priority:
- after session migration

Tests required:
- missing auth
- active session conflict
- invalid name
- invalid focus
- onboarding transition
- streak reset behavior

### allocateAttributePoint

Domain:
- profile/progression

Current TS callable:
- `allocateAttributePoint`

Known Flutter callers:
- `lib/features/profile/data/player_profile_repository.dart`
- `lib/features/profile/presentation/player_controller.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `attribute`

Response:
- `status: allocated`
- `profile`

Firestore:
- reads/writes `users/{uid}/profile/current`
- writes `users/{uid}/attribute_allocations/{docId}`
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- rejects when no stat points are available
- increments exactly one attribute
- decrements available stat points

Risk:
- high

Java migration priority:
- after personal quest authority, because personal quests create stat points
  through level-up

Tests required:
- no points available
- each attribute allocation
- active session conflict
- allocation audit record
- no negative stat points

### completePersonalQuest

Domain:
- quests/profile authority

Current TS callable:
- `completePersonalQuest`

Known Flutter callers:
- `lib/features/quests/data/quest_sync_repository.dart`
- `lib/features/quests/presentation/quest_controller.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `questId`
- `quest`

Response:
- `status: completed | already_completed`
- `profile`
- `questId`
- `quest`

Firestore:
- reads/writes `users/{uid}/profile/current`
- reads/writes `users/{uid}/quests/{questId}`
- reads/writes `users/{uid}/quest_completions/{questId}`
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- only accepts personal quests
- grants XP once
- increments the quest reward attribute once
- records pre-reward snapshot for safe revoke
- updates streak and activity history
- is idempotent for already completed quests

Risk:
- high

Java migration priority:
- after quest inventory sync

Tests required:
- first completion grants XP
- duplicate completion does not double-grant
- level-up boundary
- attribute increment
- pre-reward snapshot
- rejects competitive quest
- active session conflict

### revokePersonalQuestCompletion

Domain:
- quests/profile authority

Current TS callable:
- `revokePersonalQuestCompletion`

Known Flutter callers:
- `lib/features/quests/data/quest_sync_repository.dart`
- `lib/features/quests/presentation/quest_controller.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `questId`
- `quest`

Response:
- `status: revoked | already_pending`
- `profile`
- `questId`
- `quest`

Firestore:
- reads/writes `users/{uid}/profile/current`
- reads/writes `users/{uid}/quests/{questId}`
- reads/deletes `users/{uid}/quest_completions/{questId}`
- reads all `users/{uid}/quest_completions`
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- only accepts personal quests
- restores profile from pre-reward snapshot where available
- rebuilds activity history and streak from remaining completion records
- clears quest completion and verification state

Risk:
- high

Java migration priority:
- migrate with `completePersonalQuest`

Tests required:
- successful revoke
- revoke already pending quest
- profile restore
- history rebuild
- streak rebuild
- active session conflict

### syncPlayerProfileFromSource

Domain:
- profile migration/repair

Current TS callable:
- `syncPlayerProfileFromSource`

Known Flutter callers:
- `lib/features/profile/data/player_profile_repository.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `source`

Response:
- `status`
- `profile`

Firestore:
- writes `users/{uid}/profile/current`
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- validates source payload
- writes backend-normalized profile state

Risk:
- medium

Java migration priority:
- after authoritative profile operations

Migration note:
- this should remain repair/migration tooling, not the preferred reward path

Tests required:
- valid source sync
- invalid profile payload
- active session conflict
- preserved backend metadata

### syncQuestInventoryFromSource

Domain:
- quests inventory

Current TS callable:
- `syncQuestInventoryFromSource`

Java endpoint:
- `POST /api/v1/quests/inventory:sync`

Known Flutter callers:
- `lib/features/quests/data/quest_sync_repository.dart`
- `lib/features/quests/presentation/quest_controller.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `source.quests`

Response:
- `status: synced`
- `questCount`

Firestore:
- reads/writes `users/{uid}/quests/{questId}`
- writes `users/{uid}/quests_meta/current`
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- validates quest ids, enum values, XP, verification fields, and inventory shape
- writes normalized quest documents
- marks inventory as initialized
- rejects duplicated active competitive templates by `templateType`

Risk:
- medium

Java migration priority:
- completed locally as the first write endpoint after read-only migration

Tests required:
- valid inventory: covered
- empty inventory: covered through service/controller path
- invalid quest ids: still needs explicit fixture
- invalid enum values: still needs explicit fixture
- invalid XP: covered through personal XP normalization, still needs rejection fixture
- initialized metadata write: covered
- active session conflict: covered
- duplicate active competitive template: covered

Rollback:
- Flutter falls back to the current TypeScript callable when the Java backend
  URL is omitted or a non-session Java error occurs.

### claimWeeklyBoss

Domain:
- weekly boss/profile authority

Current TS callable:
- `claimWeeklyBoss`

Known Flutter callers:
- `lib/features/weekly_boss/data/weekly_boss_repository.dart`
- `lib/features/profile/presentation/home_screen.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `bossId`
- `displayName`
- `photoUrl`
- `rankAtCompletion`

Response:
- expected claim status/profile/boss reward payload

Firestore:
- reads weekly boss definition
- reads/writes profile
- writes weekly boss claim/completion records
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- grants boss reward once
- prevents duplicate weekly claim

Risk:
- high

Java migration priority:
- after personal quest and competitive state are stable

Tests required:
- valid claim
- duplicate claim
- missing boss
- insufficient progress
- reward write
- active session conflict

### startCompetitiveQuestSession

Domain:
- competitive quest authority

Current TS callable:
- `startCompetitiveQuestSession`

Known Flutter callers:
- `lib/features/quests/data/competitive_quest_authority_repository.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `questId`
- `templateCatalogId`
- quest metadata fields
- `verificationStartedAt`

Response:
- session start status
- normalized quest

Firestore:
- reads/writes `users/{uid}/quests/{questId}`
- writes competitive attempt/session data
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- validates competitive template and quest metadata
- starts a timed verification session

Risk:
- high

Java migration priority:
- migrate with competitive evidence flow

Tests required:
- valid start
- invalid template
- duplicate/in-progress session
- non-competitive quest rejected
- active session conflict

### startReadingQuizAttempt

Domain:
- AI/evidence

Current TS callable:
- `startReadingQuizAttempt`

Known Flutter callers:
- `lib/features/quests/data/competitive_quest_authority_repository.dart`
- `lib/features/quests/presentation/quest_controller.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `questId`
- `templateCatalogId`
- `topic`

Response:
- `quizId`
- questions
- minimum score
- generator metadata

Firestore:
- writes reading quiz attempt data
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- generates or builds deterministic reading quiz attempt
- currently may use Gemini through backend provider boundary

Risk:
- medium

Java migration priority:
- after core quest/evidence authority

Tests required:
- deterministic provider
- AI provider disabled/fallback
- invalid topic
- active session conflict
- response shape compatible with Flutter

### verifyCompetitiveQuestCompletion

Domain:
- competitive quest authority/profile authority/evidence

Current TS callable:
- `verifyCompetitiveQuestCompletion`

Known Flutter callers:
- `lib/features/quests/data/competitive_quest_authority_repository.dart`
- `lib/features/quests/presentation/quest_controller.dart`

Request:
- `deviceSessionId`
- `deviceLabel`
- `questId`
- `templateCatalogId`
- quest metadata fields
- `reflectionAnswer`
- `evidence`

Response:
- completion status
- verification decision
- profile
- quest

Firestore:
- reads/writes profile
- reads/writes quest
- writes competitive grant/completion records
- writes evidence audit records
- reads active session

Behavior:
- requires Firebase Auth
- requires active session
- validates evidence
- rejects unsafe evidence
- blocks duplicate `sourceActivityId`
- grants competitive XP once
- updates competitive activity history
- records decision details for UI

Risk:
- high

Java migration priority:
- after rank/integrity parity tests exist

Tests required:
- accepted evidence
- rejected evidence
- duplicate evidence
- stale evidence
- impossible pace
- reading quiz required
- idempotency
- active session conflict
- profile and quest writes

### syncCompetitiveStateFromSource

Domain:
- competitive progression

Current TS callable:
- `syncCompetitiveStateFromSource`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`

Request:
- `source.playerLevel`
- `source.activityHistory`
- `source.competitiveActivityHistory`

Response:
- `status: synced`
- `snapshot`
- `exam`
- `seasonReward`

Firestore:
- reads/writes `users/{uid}/progression/current`
- writes progression history
- reads/writes promotion exam
- reads/writes season reward/current and history
- reads competitive grants

Behavior:
- requires Firebase Auth
- prefers authoritative competitive grants over client source history
- computes current rank snapshot
- resolves promotion exam state
- computes season reward

Risk:
- high

Java migration priority:
- after personal/competitive quest write behavior is stable

Tests required:
- no grants fallback
- grants override source history
- promotion ready
- demotion strike
- season reward generation
- schema version preserved
- read model writes

### syncCompetitiveIntegrityFromSource

Domain:
- competitive integrity

Current TS callable:
- `syncCompetitiveIntegrityFromSource`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`

Request:
- `source.activityHistory`
- `source.competitiveActivityHistory`
- `source.quests`

Response:
- `status: synced`
- `integrity`

Firestore:
- reads competitive grants
- writes `users/{uid}/competitive_integrity/current`
- writes integrity history

Behavior:
- requires Firebase Auth
- prefers authoritative competitive grant history
- evaluates trust score/band and suspicious patterns

Risk:
- medium

Java migration priority:
- migrate with competitive state

Tests required:
- stable trust
- low trust/suspicious pattern
- grants override source history
- history write
- schema version preserved

### upsertCompetitiveProgression

Domain:
- competitive migration/repair

Current TS callable:
- `upsertCompetitiveProgression`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`

Request:
- `snapshot`
- optional `exam`
- optional `seasonReward`

Response:
- `status: synced`
- `weekKey`
- `wroteExam`
- `wroteSeasonReward`

Firestore:
- writes progression current/history
- writes promotion exam
- writes season reward current/history

Behavior:
- requires Firebase Auth
- validates payloads
- upserts read models

Risk:
- medium

Java migration priority:
- late or deprecate if no longer needed

Migration note:
- this path is less authoritative than `syncCompetitiveStateFromSource`
- consider removing usage after Java backend becomes authoritative

Tests required:
- snapshot write
- exam write
- season reward write
- invalid payload rejection

### upsertCompetitiveIntegrity

Domain:
- competitive migration/repair

Current TS callable:
- `upsertCompetitiveIntegrity`

Known Flutter callers:
- no current Flutter caller found in `lib/`

Request:
- `integrity`

Response:
- `status: synced`
- `weekKey`
- `trustBand`
- `trustScore`

Firestore:
- writes integrity current/history

Behavior:
- requires Firebase Auth
- validates integrity payload
- upserts read models

Risk:
- low

Java migration priority:
- late or deprecate

Tests required:
- valid write
- invalid payload rejection
- auth required

### startPromotionExam

Domain:
- competitive promotion

Current TS callable:
- `startPromotionExam`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`
- `lib/features/profile/presentation/rank_screen.dart`

Request:
- `snapshot`

Response:
- `status: started | already_in_progress`
- `targetRank`

Firestore:
- reads/writes `users/{uid}/promotion_exam/current`

Behavior:
- requires Firebase Auth
- requires snapshot promotion readiness
- creates timed promotion exam
- uses rank requirements

Risk:
- high

Java migration priority:
- after competitive state parity

Tests required:
- promotion not ready
- start exam
- already in progress
- ascension mode
- reconquest mode
- required boss/level fields

### confirmPromotion

Domain:
- competitive promotion

Current TS callable:
- `confirmPromotion`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`

Request:
- `snapshot`

Response:
- `status: promoted | already_promoted`
- `currentRank`

Firestore:
- reads/writes progression current/history
- reads/writes promotion exam

Behavior:
- requires Firebase Auth
- requires active passed exam
- rejects stale snapshot
- promotes current rank
- updates peak rank and next target

Risk:
- high

Java migration priority:
- after `startPromotionExam`

Tests required:
- no exam
- exam not passed
- stale snapshot
- already promoted
- promotion success
- next rank target

### getSeasonBracketLeaderboard

Domain:
- competitive read/leaderboard

Current TS callable:
- `getSeasonBracketLeaderboard`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`
- `lib/features/profile/presentation/rank_progression_provider.dart`

Request:
- `seasonKey`
- `rankBracket`
- optional `limit`

Response:
- `status: ok`
- `seasonKey`
- `rankBracket`
- `entries[]`
  - `position`
  - `displayName`
  - `detail`
  - `isPlayer`

Firestore:
- collection group read: `season_rewards`

Behavior:
- requires Firebase Auth
- validates season key and rank bracket
- clamps limit from 1 to 10
- sorts by score, secure weeks, updated time
- anonymizes non-current users as `HUNTER-xxxx`

Risk:
- low

Java migration priority:
- first Java endpoint

Tests required:
- missing auth
- invalid rank
- invalid/missing season
- limit clamp
- sorting
- current user label
- malformed reward documents skipped

Rollback:
- Flutter can keep calling TS callable while Java endpoint is compared in
  staging

### claimSeasonReward

Domain:
- competitive season reward

Current TS callable:
- `claimSeasonReward`

Known Flutter callers:
- `lib/features/profile/data/rank_progression_repository.dart`

Request:
- optional `seasonKey`

Response:
- `status: claimed | already_claimed`
- `seasonKey`

Firestore:
- reads/writes `users/{uid}/season_rewards/current`
- writes `users/{uid}/season_profiles/current`

Behavior:
- requires Firebase Auth
- validates current season reward
- rejects locked reward
- prevents duplicate claim
- creates or updates permanent season profile/legacy reward data

Risk:
- high

Java migration priority:
- after competitive state and promotion flows

Tests required:
- missing reward
- invalid reward
- wrong season key
- locked reward
- already claimed
- successful claim
- legacy/profile write

## Recommended Migration Order

1. `getSeasonBracketLeaderboard`
2. `syncQuestInventoryFromSource`
3. `completePersonalQuest`
4. `revokePersonalQuestCompletion`
5. `registerActiveSession`
6. `releaseActiveSession`
7. `updateProfileSettings`
8. `allocateAttributePoint`
9. `syncCompetitiveStateFromSource`
10. `syncCompetitiveIntegrityFromSource`
11. `startCompetitiveQuestSession`
12. `verifyCompetitiveQuestCompletion`
13. `startPromotionExam`
14. `confirmPromotion`
15. `claimSeasonReward`
16. `claimWeeklyBoss`
17. `startReadingQuizAttempt`
18. `syncPlayerProfileFromSource`
19. `upsertCompetitiveProgression`
20. `upsertCompetitiveIntegrity`

## First Endpoint Contract Draft

Endpoint:
- `GET /api/v1/season-leaderboard`

Current TS callable:
- `getSeasonBracketLeaderboard`

Auth:
- required Firebase ID token

Query params:
- `seasonKey`: string, required
- `rankBracket`: string, required, one of `E`, `D`, `C`, `B`, `A`, `S`
- `limit`: integer, optional, clamp 1..10, default 5

Response:

```json
{
  "status": "ok",
  "seasonKey": "2026-05",
  "rankBracket": "E",
  "entries": [
    {
      "position": 1,
      "displayName": "VOCE",
      "detail": "Seguro | 120 pts",
      "isPlayer": true
    }
  ]
}
```

Errors:
- `401` unauthenticated
- `400` invalid rank bracket
- `400` invalid season key

Firestore reads:
- collection group `season_rewards`
- filters:
  - `seasonKey == request.seasonKey`
  - `currentRankBracket == request.rankBracket`

Firestore writes:
- none

Rollback:
- keep Flutter on TS callable until Java endpoint is deployed and compared

## Phase 0 Status

Status:
- callable inventory created
- first Java migration candidate selected
- first endpoint contract drafted
- Java auth base implemented locally
- `GET /api/v1/me` implemented locally
- `GET /api/v1/season-leaderboard` implemented locally
- Java tests and package pass locally
- Cloud Run staging deploy helper created at
  `tools/backend/deploy-cloud-run-staging.ps1`
- Cloud Run staging service deployed at
  `https://ascend-backend-staging-331143433117.southamerica-east1.run.app`
- unauthenticated smoke checks passed for `/health`, `/api/v1/me`, and
  `/api/v1/season-leaderboard`
- Flutter season leaderboard routing can opt into Java with
  `ASCEND_JAVA_BACKEND_URL`, while the default remains Firebase Functions
- `POST /api/v1/quests/inventory:sync` implemented and deployed to Cloud Run
  staging
- Flutter quest inventory sync can opt into Java with `ASCEND_JAVA_BACKEND_URL`,
  while the default remains Firebase Functions
- full Flutter test suite and Java backend test suite pass locally
- unauthenticated Cloud Run smoke checks passed for `/health`, `/api/v1/me`,
  and `/api/v1/quests/inventory:sync`

Next phase:
- run an authenticated test-account walkthrough against the Java quest inventory
  route
