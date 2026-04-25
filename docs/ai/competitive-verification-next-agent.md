# Competitive Verification Next-Agent Brief

Read this when continuing after Phase 3 release work was paused for deeper product value.

## Current Direction

User wants implementation before device dependency. Main value gap: competitive quests are not attractive enough and anti-fraud is weak.

Do not start with real Health Connect, Strava, GPS, or AI integration. First slice already implemented the evidence contract, evaluator, richer quest catalog, fake evidence, and backend gate.

Product source:
- `docs/product/competitive-verification-v1.md`

## Current Implementation State

First slice is implemented:
- Dart evidence domain/evaluator/mock evidence
- richer official catalog
- Flutter completion submits evidence payload
- backend evaluator blocks grants without accepted evidence
- evidence audit docs under `competitive_quest_evidence`
- rules/tests for read-only evidence audits

Do not reimplement this from scratch. Continue from these files.

## Next Package

Continue `Competitive Verification V1`:

1. Add historical duplicate `sourceActivityId` checks for evidence.
2. Add visible evidence decision details in competitive quest UI.
3. Add provider adapter boundary interfaces.
4. Add Health Connect or Strava only after adapter tests exist.
5. Add AI reading quiz only after quiz contract is backend-owned.

## Likely Files

Start by reading:
- `lib/features/quests/domain/competitive_quest_template.dart`
- `lib/features/quests/domain/quest_model.dart`
- `lib/features/quests/presentation/quest_controller.dart`
- `lib/features/quests/presentation/quests_screen.dart`
- `lib/features/quests/presentation/widgets/quest_card.dart`
- `functions/src/index.ts`
- `functions/test/`
- `firestore.rules`
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
- Existing evidence provider is mock-only by design; do not treat it as production anti-cheat.

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
