# Ascend Architecture Map

## Purpose

Describe the current architecture and the boundaries future work must preserve.
This file is not a changelog. Historical implementation notes belong in
`docs/product/execution-tracker.md`, `docs/product/phase-backlog.md`, or
archived decision notes.

Start with:
- `docs/ai/source-of-truth.md`
- `AGENTS.md`
- `docs/product/progression-architecture.md`
- `docs/product/release-environments.md`

## Current Shape

Ascend is a Flutter app with Firebase-backed account authority and local Isar
cache/offline support.

```text
lib/
|-- core/
|   |-- analytics/
|   |-- config/
|   |-- crash/
|   |-- database/
|   |-- navigation/
|   |-- theme/
|   `-- widgets/
|-- features/
|   |-- auth/
|   |-- profile/
|   |-- quests/
|   |-- weekly_boss/
|   `-- main_navigation_screen.dart
`-- main.dart

functions/
|-- src/
`-- test/
```

State management:
- Riverpod with `StateNotifierProvider`

Persistence and backend:
- Isar for local cache/offline support
- Firebase Auth for identity
- Firestore for account data, read models, and audit records
- Cloud Functions for reward-bearing and authority-sensitive commands

Observability:
- centralized analytics wrapper in `lib/core/analytics/analytics_service.dart`
- centralized crash wrapper in `lib/core/crash/crash_reporting_service.dart`

## Runtime Entry

`lib/main.dart` owns:
- Flutter binding initialization
- Firebase initialization
- crash reporter initialization
- Isar open with `PlayerSchema` and `QuestSchema`
- ProviderScope overrides for Isar and crash reporting
- app-level crash hooks
- Material app routing based on `authProvider`

Do not add feature-specific SDK calls directly into `main.dart` unless they are
cross-cutting platform initialization.

## Release Identity

Android:
- production: `com.ascend.mobile`
- staging: `com.ascend.mobile.staging`
- legacy Firebase registration: `com.example.ascend`

iOS:
- production: `com.ascend.mobile`
- staging Firebase app exists, but the repo is currently wired production-only

Reference:
- `docs/product/release-environments.md`

Do not change package IDs, bundle IDs, flavors, Firebase app registrations, or
signing paths casually. Release identity changes must be one explicit workstream.

## Authority Model

The production direction is command -> backend fact -> backend aggregate/read
model -> client cache/render.

Flutter may:
- collect user intent
- render optimistic or pending UI where safe
- submit source payloads and evidence
- cache backend-authored results in Isar

Flutter must not:
- be the final authority for reward-bearing progression
- mint competitive rank progress from local state
- directly write sensitive read models
- reintroduce client-owned profile snapshots as the normal production path

Backend owns:
- profile aggregate updates
- personal quest completion and revocation outcomes
- attribute allocation outcomes
- competitive quest verification outcomes
- weekly boss claims
- promotion and season reward authority
- competitive integrity and audit read models

Firestore rules should keep authority-sensitive collections read-only or
backend-written from the client perspective.

## Core Boundaries

### Auth And Session

Primary files:
- `lib/features/auth/presentation/auth_controller.dart`
- `lib/features/auth/data/active_session_repository.dart`
- `lib/features/auth/domain/auth_state.dart`
- `functions/src/index.ts`

Rules:
- auth state must expose enough identity for account surfaces
- active-session registration/refresh is backend-backed
- active-session conflicts should fail safely and return the user to login
- account and logout controls belong to the dedicated account surface, not
  scattered through unrelated tabs

### Player Profile And Progression

Primary files:
- `lib/features/profile/domain/player_model.dart`
- `lib/features/profile/presentation/player_controller.dart`
- `lib/features/profile/data/player_profile_repository.dart`
- `functions/src/index.ts`
- `firestore.rules`

Rules:
- `users/{uid}/profile/current` is the account aggregate
- Isar player records are local cache/offline state
- `syncPlayerProfileFromSource` is migration/repair tooling, not normal reward
  authority
- attribute allocation should use backend callables
- profile settings updates should use backend callables
- XP, level, streak, and stat rules need tests when changed

Current risk:
- `player_controller.dart` still mixes local persistence, remote sync, fallback,
  and UI-facing state transitions. Refactor carefully behind existing tests.

### Quests

Primary files:
- `lib/features/quests/domain/quest_model.dart`
- `lib/features/quests/domain/competitive_quest_template.dart`
- `lib/features/quests/domain/competitive_quest_evidence.dart`
- `lib/features/quests/presentation/quest_controller.dart`
- `lib/features/quests/data/quest_sync_repository.dart`
- `lib/features/quests/data/competitive_quest_authority_repository.dart`

Rules:
- personal quests stay low-friction and can grant account XP through backend
  commands
- competitive quests must come from official templates or controlled sources
- competitive progress must depend on backend verification
- `syncQuestInventoryFromSource` is migration/repair tooling, not normal
  authority
- completed competitive quests should not appear as both active and completed

Current risk:
- `quest_controller.dart` still combines Isar writes, cloud sync, personal
  completion, competitive verification, and UI flow decisions. Future refactors
  should split behavior without changing contracts.

### Competitive Systems

Primary files:
- `lib/features/profile/domain/rank_progression.dart`
- `lib/features/profile/domain/promotion_exam.dart`
- `lib/features/profile/domain/rank_season.dart`
- `lib/features/profile/domain/rank_season_leaderboard.dart`
- `lib/features/profile/domain/season_reward_snapshot.dart`
- `lib/features/profile/domain/competitive_integrity.dart`
- `lib/features/profile/data/rank_progression_repository.dart`
- `lib/features/profile/presentation/rank_progression_provider.dart`
- `functions/src/index.ts`

Rules:
- level defines eligibility, not automatic rank ascent
- promotion/reconquest requires formal proof
- weekly maintenance can preserve or reduce rank
- competitive integrity is currently a soft signal, not a hard block
- seasonal rewards and legacy records should come from backend authority

Current risk:
- competitive domain logic is broad and functions code is concentrated in one
  large file. Extract pure services/modules before adding more complexity.

### Weekly Boss

Primary files:
- `lib/features/weekly_boss/`
- `lib/features/profile/domain/weekly_boss.dart`
- `functions/src/index.ts`

Rules:
- weekly boss claim is backend-authoritative
- competitive activity should be preferred for rank-facing boss progress
- local fallback must not create duplicate reward authority

### UI Surfaces

Current surface ownership:
- Base/Home: player identity, momentum, next payoff
- Quests: execution and quest state
- Arena/Rank: competitive systems, risk, season, legacy
- Stats/Plan: numbers, planning support, review
- Account: identity, session, support, privacy, logout

Rules:
- avoid turning Ascend into a generic task manager
- avoid duplicating the same metrics across tabs without surface-specific meaning
- prefer progressive disclosure over long same-weight dashboard stacks
- keep business and reward logic out of widgets
- use shared theme tokens from `core/theme`

Current risk:
- `home_screen.dart`, `rank_screen.dart`, and `quests_screen.dart` are large.
  Split them into local sections/widgets when touching adjacent behavior.

## Backend Shape

Current Functions file:
- `functions/src/index.ts`

Important callable groups:
- session: `registerActiveSession`, `releaseActiveSession`
- profile: `updateProfileSettings`, `allocateAttributePoint`,
  `syncPlayerProfileFromSource`
- personal quests: `completePersonalQuest`, `revokePersonalQuestCompletion`,
  `syncQuestInventoryFromSource`
- competitive quests: `startCompetitiveQuestSession`,
  `verifyCompetitiveQuestCompletion`
- competitive read models: `syncCompetitiveStateFromSource`,
  `syncCompetitiveIntegrityFromSource`
- promotion/season: `startPromotionExam`, `confirmPromotion`,
  `claimSeasonReward`, `getSeasonBracketLeaderboard`
- weekly boss: `claimWeeklyBoss`

Current risk:
- `functions/src/index.ts` is too large for long-term maintenance. The next
  backend hardening step should extract modules by domain while preserving
  callable contracts and tests.

## Competitive Verification V1

Current state:
- evidence domain and evaluator exist in Flutter
- official templates include running, focus, reading, workout, and study
- backend evaluates evidence before granting competitive reward
- backend writes evidence audit records
- mock evidence is for development/tests only

Next architecture targets:
- duplicate `sourceActivityId` checks
- visible backend decision details in UI
- provider adapter interfaces
- Health Connect / Strava only after adapter tests
- AI reading quiz only after backend-owned quiz contract

Reference:
- `docs/product/competitive-verification-v1.md`

## Refactor Priorities

Do these in small, test-protected slices:
- compact and modularize `functions/src/index.ts`
- split large screens into local sections/widgets
- reduce synchronous Isar work in UI-driven paths
- make remote sync failures observable instead of silently swallowed
- keep repositories as the boundary for persistence and backend calls
- add tests before changing progression, quest, rank, or evidence rules

Do not:
- perform broad directory reshuffles without updating imports and docs
- edit generated Isar files manually
- add dependencies without clear production value
- move backend authority into Flutter for convenience
- add real provider integrations before the evidence contract is stable

## Validation Expectations

Flutter changes:
- `flutter analyze`
- `flutter test`

Functions changes:
- `npm test` in `functions`
- `npm run test:rules` when rules or Firestore authority are touched

Isar schema changes:
- `dart run build_runner build --delete-conflicting-outputs`

Release-facing changes:
- run the release checklist
- record real-device smoke status or the blocker
- call out staging/production environment assumptions

Current local environment blockers are tracked in:
- `docs/product/execution-tracker.md`
- `docs/product/phase-backlog.md`
