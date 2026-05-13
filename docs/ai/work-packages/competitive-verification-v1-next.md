# Competitive Verification V1 Work Package

Read this only when continuing the next Competitive Verification V1 package.
This is an execution brief, not permanent architecture.

## Current Direction

The product value gap is that competitive quests need stronger evidence and
clearer backend decisions before broader release work resumes.

Do not start with real Health Connect, Strava, GPS, or AI integration. The first
slice already implemented the evidence contract, evaluator, richer quest
catalog, fake evidence, and backend gate.

Product source:
- `docs/product/competitive-verification-v1.md`

Architecture source:
- `docs/ai/architecture-map.md`

## Current Implementation State

First slice is implemented:
- Dart evidence domain/evaluator/mock evidence
- richer official catalog
- Flutter completion submits evidence payload
- backend evaluator blocks grants without accepted evidence
- evidence audit docs under `competitive_quest_evidence`
- rules/tests for read-only evidence audits

Backend duplicate protection is implemented:
- `verifyCompetitiveQuestCompletion` checks prior competitive grant records for
  the submitted `sourceActivityId` before writing a new grant.
- reused `sourceActivityId` evidence is rejected with
  `duplicateSourceActivityId`.
- the check intentionally uses backend grant history, not client state.

Competitive evidence UI feedback is implemented:
- competitive quest cards show the expected evidence requirement from the
  official template.
- local/backend evidence rejections map to user-visible completion results:
  insufficient evidence, rejected evidence, and duplicate evidence.
- Flutter still only renders feedback; backend remains the reward/rank
  authority.

Provider adapter boundary is implemented:
- `CompetitiveEvidenceProviderAdapter` defines the Flutter-side evidence source
  contract.
- `MockCompetitiveEvidenceProviderAdapter` wraps the existing deterministic mock
  evidence implementation for development/tests.
- `QuestNotifier` depends on the adapter interface instead of constructing mock
  evidence directly.

Health Connect Adapter V1 is implemented behind a feature flag:
- `HealthConnectCompetitiveEvidenceProviderAdapter` reads Android exercise
  sessions through a Flutter MethodChannel.
- Android integration follows the official Health Connect setup:
  `connect-client:1.2.0-alpha04`, Health Connect manifest permissions,
  availability checks, permission request flow, and `ExerciseSessionRecord` /
  `DistanceRecord` reads.
- Backend and Flutter accept `healthConnect` evidence for running and workout
  templates only.
- The app still defaults to mock evidence unless
  `--dart-define=ASCEND_USE_HEALTH_CONNECT=true` is supplied.
- Android native compilation and real-device smoke are still pending because the
  current workstation has no Android SDK configured.

AI Reading Quiz Contract V1 is implemented without a real AI provider:
- backend can issue deterministic reading quiz attempts through
  `startReadingQuizAttempt`.
- competitive reading evidence now needs a backend-owned quiz attempt/evaluation
  before reward/rank progress is accepted.
- quiz attempts are readable by the owner but cannot be written directly by the
  client.
- real AI generation remains future adapter work; the contract now defines the
  authority boundary first.

Flutter reading quiz flow is implemented:
- reading-comprehension competitive quests request a backend quiz attempt before
  completion.
- Flutter collects ordered answers and submits `quizId` plus `answers` with the
  evidence payload.
- local pre-validation is skipped only for backend-owned quiz submissions; the
  backend still decides score, reward, and rank progress.

Do not reimplement this from scratch. Continue from the current code.

## Next Package

Continue `Competitive Verification V1`:

1. Configure Android SDK locally and run a staging debug APK build.
2. Run real-device Health Connect smoke with
   `--dart-define=ASCEND_USE_HEALTH_CONNECT=true`.
3. Add real AI generation only after the deterministic contract flow is stable.

## Likely Files

Start by reading:
- `lib/features/quests/domain/competitive_quest_template.dart`
- `lib/features/quests/domain/competitive_quest_evidence.dart`
- `lib/features/quests/data/competitive_evidence_provider_adapter.dart`
- `lib/features/quests/domain/quest_model.dart`
- `lib/features/quests/presentation/quest_controller.dart`
- `lib/features/quests/presentation/quests_screen.dart`
- `lib/features/quests/presentation/widgets/quest_card.dart`
- `functions/src/index.ts`
- `functions/test/`
- `firestore.rules`
- `test/features/quests/`
- `docs/product/competitive-verification-v1.md`
- `docs/ai/architecture-map.md`
- `docs/ai/testing-strategy.md`

## Rules

- Backend owns reward and rank-bearing decisions.
- Flutter may submit evidence and render state, but not grant competitive authority.
- Isar is cache, not source of truth.
- If Isar models change, regenerate generated files; never edit generated files manually.
- Avoid copy-fragile tests. Prefer state, keys, decisions, and backend contract.
- Keep docs updated when behavior changes.
- Existing mock evidence provider is for development/tests only; do not treat it as production anti-cheat.

## Validation

If Dart only:
- `rtk dart format <changed dart files>`
- `rtk flutter analyze`
- `rtk flutter test`

If Functions changed:
- `rtk npm --prefix functions test -- --test-reporter=spec`
- `rtk npm --prefix functions run test:rules`

If Isar schema changed:
- `rtk dart run build_runner build --delete-conflicting-outputs`
