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

Do not reimplement this from scratch. Continue from the current code.

## Next Package

Continue `Competitive Verification V1`:

1. Add visible evidence decision details in competitive quest UI.
2. Add provider adapter boundary interfaces.
3. Add Health Connect or Strava only after adapter tests exist.
4. Add AI reading quiz only after quiz contract is backend-owned.

## Likely Files

Start by reading:
- `lib/features/quests/domain/competitive_quest_template.dart`
- `lib/features/quests/domain/competitive_quest_evidence.dart`
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
