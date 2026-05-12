# Month 2 Backend Hardening Work Package

This is the execution checklist for the Month 2 backend hardening track.
It is temporary execution guidance; durable architecture belongs in
`docs/ai/architecture-map.md` and current status belongs in
`docs/product/execution-tracker.md`.

## Goal

Make reward-bearing backend flows easier to trust, test, audit, and change
without reintroducing client authority.

## Exit Criteria

- `functions/src/index.ts` is mostly callable wiring, not the primary domain file.
- reward, profile, quest, competitive, and season logic have clear module homes.
- callable contracts remain compatible or have explicit migration notes.
- duplicate grant and direct-write risks stay covered by tests.
- `npm test` and `npm run test:rules` pass from `functions`.
- carried release debt remains visible instead of being hidden by refactors.

## Completed Slices

1. Shared validation extraction.
   - moved generic validation, timestamp parsing, sanitization, and safe coercion
     helpers to `functions/src/shared/validation.ts`.
   - kept `parseTimestampInput` re-exported from `index.ts` for test/import
     compatibility.

2. Competitive evidence extraction.
   - moved evidence validation, evidence evaluator, attempt-day helpers,
     session-start resolution, and completion verification to
     `functions/src/competitive/evidence.ts`.
   - moved local day key generation to `functions/src/shared/date.ts`.

3. Competitive rank helper extraction.
   - moved pure rank ordering, adjacent-rank transitions, level-to-rank mapping,
     peak-rank comparison, and rank requirement helpers to
     `functions/src/competitive/rank.ts`.

4. Profile progression module extraction.
   - moved profile/progression helpers to `functions/src/profile/progression.ts`.
   - promoted local-day parsing and unique timestamp-by-day projection into
     `functions/src/shared/date.ts`.
   - kept callable transaction bodies in `index.ts`.

5. Quest inventory module extraction.
   - moved quest source validation, single/stored quest validation, quest
     document write shaping, and quest inventory sync write shaping into
     `functions/src/quests/inventory.ts`.
   - kept the official competitive catalog in `index.ts` and passed it into the
     quest module as an explicit dependency.
   - did not alter Isar models, Flutter repositories, callable contracts, or
     transaction behavior.

6. Competitive season module extraction.
   - moved week-key helpers, current-week projection, exam resolution, season
     reward calculation, season legacy payload shaping, profile reward payload
     shaping, and cosmetic labels into `functions/src/competitive/season.ts`.
   - preserved the existing week-key format and Monday week-start behavior.
   - did not change leaderboard reads, reward claim behavior, callable
     contracts, or transaction behavior.

## Remaining Slices

### Slice 2.7 - Callable Wiring Cleanup

After the domain modules exist, reduce callable bodies only where it improves
clarity without changing behavior.

Candidate scope:
- shared Firestore reference helpers
- active-session assertion location
- small service functions for repeated transaction write projections

Avoid broad transaction rewrites unless a test first captures the behavior.

Validation:
- `npm test`
- `npm run test:rules`
- `flutter analyze` if Flutter-facing contracts or generated client assumptions
  changed

### Slice 2.8 - Month 2 Exit Review

Close the Month 2 backend hardening track.

Required output:
- update `docs/product/execution-tracker.md`
- update `docs/product/phase-backlog.md` if statuses changed
- record remaining audit/security dependency follow-up separately from the
  refactor
- confirm whether the next track is UI maintainability or Competitive
  Verification V1 product depth

Validation:
- `npm test`
- `npm run test:rules`
- `flutter analyze`
- `flutter test` if the environment supports the full suite

## Guardrails

- Keep backend authority over rewards and rank-bearing outcomes.
- Keep Flutter as command/evidence submission plus rendering, not reward source.
- Prefer small extractions with commits after passing validation.
- Do not mix dependency upgrades with behavior-preserving refactors.
- Do not treat the remaining `npm audit --force` path as completed until it is a
  deliberate Firebase dependency upgrade pass.
