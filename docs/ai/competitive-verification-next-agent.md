# Competitive Verification Next-Agent Brief

Read this when continuing after Phase 3 release work was paused for deeper product value.

## Current Direction

User wants implementation before device dependency. Main value gap: competitive quests are not attractive enough and anti-fraud is weak.

Do not start with real Health Connect, Strava, GPS, or AI integration. First implement the evidence contract, evaluator, richer quest catalog, and tests.

Product source:
- `docs/product/competitive-verification-v1.md`

## Next Package

Build `Competitive Verification V1`:

1. Add pure domain types for:
   - verification requirement
   - quest evidence
   - evidence provider
   - verification decision
   - risk flags
2. Add a pure evaluator:
   - accepts/rejects evidence against official template requirements
   - returns confidence score and risk flags
3. Expand official competitive templates:
   - running 2k
   - running 5k
   - focus 25m
   - reading comprehension
   - workout session
   - study recall
4. Add fake/mock evidence provider for tests.
5. Wire backend authority tests before broad UI work.
6. Add minimal UI keys/actions only when needed by tests.

## Likely Files

Start by reading:
- `lib/features/quests/domain/competitive_quest_template.dart`
- `lib/features/quests/domain/quest_model.dart`
- `lib/features/quests/presentation/quest_controller.dart`
- `lib/features/quests/presentation/quests_screen.dart`
- `lib/features/quests/presentation/widgets/quest_card.dart`
- `functions/src/index.ts`
- `functions/test/`
- `test/features/quests/`
- `docs/ai/architecture-map.md`
- `docs/ai/testing-strategy.md`

## Rules

- Backend owns reward and rank-bearing decisions.
- Flutter may submit evidence and render state, but not grant competitive authority.
- Isar is cache, not source of truth.
- If Isar models change, regenerate generated files; never edit generated files manually.
- Avoid copy-fragile tests. Prefer state, keys, decisions, and backend contract.
- Keep docs updated when behavior changes.

## Validation

If Dart only:
- `rtk dart format <changed dart files>`
- `rtk flutter analyze`
- `rtk flutter test`

If functions changed:
- `rtk npm --prefix functions test -- --test-reporter=spec`
- `rtk npm --prefix functions run test:rules`

If Isar schema changed:
- `rtk dart run build_runner build --delete-conflicting-outputs`

