# Execution Tracker

## Purpose

Keep phase progress explicit so future sessions do not have to reconstruct project state from scattered commits, chat history, or memory.

Update this file:
- at the end of every phase
- at any major milestone inside the active phase
- when the allowed next focus changes

## Current State

- Current date baseline: `2026-07-14`
- Active plan: `docs/product/project-plan.md`
- Active requirements baseline: `docs/product/requirements-baseline.md`
- Active phase: `Phase 3 - Product reliability and release readiness`
- Active stabilization package: `Documentation and control-plane cleanup`
- Active product focus override: `Competitive Verification V1` remains the next implementation track after the control plane is coherent
- Previous phase status: `Phase 1 advanced with accepted operational debt`
- Active backlog: `docs/product/phase-backlog.md`
- Active smoke log: `docs/product/phase1-smoke-log.md`
- Active source-of-truth map: `docs/ai/source-of-truth.md`

## Phase Table

| Phase | Status | Entry condition | Exit condition |
| --- | --- | --- | --- |
| Phase 0 - Baseline and control plane | `completed` | project needs operational discipline | requirements, plan, gates, and tracker are published |
| Phase 1 - Core authority and trust | `completed_with_accepted_debt` | Phase 0 completed | authority, sync, rules, and trust baseline are reliable |
| Phase 2 - Core loops and retention | `completed_with_accepted_debt` | Phase 1 complete or explicitly advanced with tracked debt | personal and competitive loops are clear and protected |
| Phase 3 - Product reliability and release readiness | `in_progress` | Phase 2 complete | release candidate can be validated and distributed safely |
| Phase 4 - Differentiation and guided growth | `planned` | Phase 3 complete | deeper guidance and payoff improve retention without weakening trust |

## Completion Log

### Phase 0 - Baseline and control plane

Status: `completed`
Completed on: `2026-04-23`

Completed:
- published the requirements baseline
- published the project plan for phases 0-4
- published quality gates for future work
- created a tracker for phase completion notes and next-focus control
- linked process docs to the new control plane

Why this phase matters:
- future work can now be accepted or rejected against a documented baseline
- the project no longer depends on reconstructing intent from chat memory

Next allowed focus:
- Phase 1 only
- prioritize authority, sync, session, rules, trust surfaces, and release-risk reduction

### Phase 1 - Core authority and trust

Status: `completed_with_accepted_debt`

Progress note recorded on: `2026-04-23`

Implemented and evidenced:
- active-session authority path exists in code
- backend-authoritative callable paths exist for profile and quest mutations
- account trust surface exists in-app
- release environment strategy is documented
- shared Firebase policy for the current validation phase is now explicit
- Firestore rules already block direct client writes on authority-sensitive collections
- automated validation now covers:
  - active session conflict classification
  - account screen trust-surface rendering and logout entry
  - player profile sync parsing and missing-remote upload protection
  - quest sync parsing and missing-remote upload protection
  - backend callable authority tests for profile sync and competitive quest verification
  - Firestore rules emulator checks for read/write boundaries on authority-sensitive collections

Accepted debt carried forward:
- support now comes from release config, but still defaults to placeholder `support@ascend.app` until a real monitored channel is set
- no recorded real-device smoke pass yet for the full trust-critical flow

Why Phase 2 was allowed to start anyway:
- the remaining gaps are operational and release-facing, not architectural blockers for core-loop product work
- the authority, rules, sync, and trust baseline is strong enough to continue product shaping while the remaining release debt stays visible
- the debt must still be closed before any broader external distribution or Phase 3 release-readiness signoff

Reference:
- see `docs/product/phase-backlog.md` for the current workstream status and exit checklist
- see `docs/product/phase1-smoke-log.md` for the required device validation record

Planned completion note:
- record which backend-authoritative paths are in place
- record which sync risks were removed
- record which trust/account/release surfaces are now safe enough for external testing
- record which smoke path still remains

### Phase 2 - Core loops and retention

Status: `completed_with_accepted_debt`

Activation note recorded on: `2026-04-23`

Current focus:
- tighten first-week and daily-return clarity
- verify top-level surface ownership and next-action readability
- expand regression protection for loop-facing UI and quest/payoff flows

Carried debt from Phase 1:
- real support email is still pending
- real-device trust-critical smoke pass is still pending
- these remain blockers for Phase 3-style release confidence even while Phase 2 work continues

Progress note recorded on: `2026-04-23`

Implemented and evidenced:
- top-level UI ownership is now documented and reviewable through the UI surface audit
- UI smoke checklist now exists and records automated desk-pass validation separately from device validation
- `Quests` regained an always-visible creation path:
  - inline creation CTA in the weekly-priority block
  - inline creation CTA in the first-week panel
  - floating action button lifted above the shared bottom dock instead of hiding behind it
- onboarding now sends the user straight into `Quests` after starter-kit confirmation instead of dropping them back into a generic tab default
- onboarding now highlights the first recommended Base quest before exit, so the starter kit explains what to do first instead of only listing quests
- `Quests` now uses a compact `+` floating action button positioned above the shared dock instead of an extended button that still collided visually with navigation chrome
- attribute allocation in `Build` now updates immediately on tap instead of waiting for a tab change or later rebuild to reveal the new value
- `Home` now exposes a compact return-motivation signal tying tomorrow's return, weekly pressure, and next payoff into one visible loop cue
- `Quests` now exposes a compact return-loop cue tying today's first action, tomorrow's return, and weekly/rank pressure into the action surface
- the automated suite was cleaned to reduce stale local-flow assumptions and decorative copy assertions:
  - widget tests now anchor on critical actions, state surfaces, and stable keys
  - domain tests now prefer progress/state assertions over brittle wording where possible
- regression coverage now protects:
  - Home critical rendering
  - Arena critical rendering
  - Plano weekly-read ownership
  - quest-card rendering after the border/fill regression fix
  - onboarding -> Quests -> first personal quest handoff without relying on an old local quest cache
  - first-week journey state transitions for personal-first, competitive-next, and early-rank deactivation
  - return-motivation state for tomorrow/streak, weekly pressure, and payoff visibility
  - Quests return-loop surface visibility inside the onboarding-to-first-quest journey
  - optimistic attribute allocation with rollback on backend failure

Completion note recorded on: `2026-04-24`

Phase 2 closure:
- the first useful action is protected from onboarding into the first personal quest
- `Home` and `Quests` now expose return motivation instead of leaving tomorrow/weekly pressure implicit
- top-level loop surfaces have ownership and critical rendering coverage
- core loop regression coverage is focused on state, actions, and stable keys rather than ornamental copy

Accepted debt carried forward:
- real-device visual and scroll-density pass is still pending
- manual first-week smoke path on small and large screens is still pending
- carried Phase 1 operational debt remains open:
  - real support email
  - trust-critical real-device smoke pass

Why Phase 3 is allowed to start:
- remaining Phase 2 gaps are validation and release-confidence work, not missing core-loop product behavior
- Phase 3 is the right phase to close manual device evidence, release-candidate discipline, support ownership, and operational readiness

### Phase 3 - Product reliability and release readiness

Status: `in_progress`

Activation note recorded on: `2026-04-24`

Current focus:
- close real-device smoke evidence
- close support/release ownership gaps
- validate release-candidate build discipline
- keep Phase 1 and Phase 2 accepted debt visible until resolved

Progress note recorded on: `2026-04-25`

Implemented and evidenced:
- `RC-internal-2026-04-25` recorded in `docs/product/release-candidate-log.md`
- Android APK artifacts built successfully:
  - `build/app/outputs/flutter-apk/app-staging-debug.apk`
  - `build/app/outputs/flutter-apk/app-production-debug.apk`
  - `build/app/outputs/flutter-apk/app-production-release.apk`
- automated validation passed:
  - `rtk flutter analyze`
  - `rtk flutter test`
  - `rtk npm --prefix functions test -- --test-reporter=spec`
  - `rtk npm --prefix functions run test:rules`

Still blocking external beta:
- placeholder support email remains configured for the internal candidate
- real-device trust-critical smoke pass remains unrecorded
- real-device visual/scroll-density pass remains unrecorded

Progress note recorded on: `2026-04-25`

Implemented and evidenced:
- Phase 3 smoke runbook added for real-device execution against `RC-internal-2026-04-25`
- external test distribution plan added with Stage 0-3 gates and tester instructions
- live-risk response path added for stop-distribution, backend hotfix, mobile hotfix, and future kill-switch direction
- Firebase operations dashboard now records the controlled external testing review cadence and owner placeholder
- real-device smoke blocker is explicit:
  - current environment reports only `Linux (desktop)` from `rtk flutter devices`

Still blocking external beta, ignoring support email by operator decision for now:
- real-device trust-critical smoke pass remains unrecorded
- real-device visual/scroll-density pass remains unrecorded
- named operational owner and backup remain placeholders

Product focus override recorded on: `2026-04-25`

Decision:
- pause broader release-readiness work until competitive quests are more valuable and harder to fake
- keep support email and real-device smoke as known debt, but do not spend the next package on them
- continue implementation without requiring device APIs first

Next implementation focus:
- `Competitive Verification V1`, documented in `docs/product/competitive-verification-v1.md`
- work-package brief in `docs/ai/work-packages/competitive-verification-v1-next.md`

Why:
- the core product value depends on Arena progress being evidence-based
- current competitive verification is too narrow for running, reading, workout, and study quests
- a pure evaluator, richer official templates, and fake evidence provider can be built and tested before Health Connect, Strava, GPS, or AI integrations

Progress note recorded on: `2026-04-25`

Implemented and evidenced:
- `Competitive Verification V1` foundation added without requiring a real device
- Dart domain now has evidence types, providers, verification requirements, decisions, risk flags, pure evaluator, and deterministic mock evidence
- official competitive catalog now includes running, focus, reading comprehension, workout, and study recall templates
- Flutter competitive completion now builds evidence from the official template requirement before calling backend authority
- backend competitive verification now evaluates submitted evidence before granting reward/rank-facing progress
- backend writes evidence audit records under `users/{uid}/competitive_quest_evidence/{attemptId}`
- Firestore rules allow users to read their own evidence audits but block direct client writes
- automated validation passed for Flutter, Functions, and Firestore rules

Remaining for later adapters:
- Health Connect / Strava provider integration
- AI reading quiz generation
- source activity reuse checks across provider history
- richer visible evidence detail UI

Progress note recorded on: `2026-05-11`

Control-plane audit:
- `README.md` was stale and still described Android as `com.example.ascend`, while the current Gradle configuration uses `com.ascend.mobile` with `staging` and `production` flavors.
- `roadmap.md` and `architecture-map.md` remain useful but too cumulative; treat them as context until they are compacted, not as the fastest entry point for current work.
- `knowledge-vault/` remains retrieval memory only and must not override current code or curated docs.
- the active release blockers are still support ownership, real-device smoke evidence, and operational owner/backup assignment.

Validation observed on `2026-05-11`:
- `rtk flutter analyze`: passed with no issues.
- `rtk npm test` in `functions`: passed, 14 tests.
- `rtk flutter test`: blocked by Windows Developer Mode / symlink support not being enabled.
- `rtk npm run test:rules`: blocked because Java is not available on `PATH`.
- `rtk npm ci`: completed, but reported Node engine mismatch because the environment used Node `v24.15.0` while `functions/package.json` requires Node `20`; it also reported npm audit vulnerabilities that need a separate dependency/security pass.

Current stabilization outcome:
- documentation cleanup is now the immediate next package before more product implementation.
- do not start new feature breadth until the docs tell a single operational story again.

Progress note recorded on: `2026-05-11`

Control-plane cleanup follow-through:
- `docs/product/roadmap.md` is now a current strategy document instead of an accumulated changelog.
- `docs/ai/architecture-map.md` is now a current architecture boundary map instead of a long historical implementation log.
- the six-month direction now lives in the roadmap, while execution status remains in this tracker and `docs/product/phase-backlog.md`.
- the remaining documentation cleanup is narrower:
  - archive, delete, or fold work-package briefs into durable docs after their package is complete
  - keep `roadmap.md` and `architecture-map.md` from becoming changelogs again
  - resolve local validation environment blockers

Progress note recorded on: `2026-05-11`

Work-package cleanup:
- `docs/ai/competitive-verification-next-agent.md` was moved out of the root AI docs.
- the active Competitive Verification V1 brief now lives at `docs/ai/work-packages/competitive-verification-v1-next.md`.
- `docs/ai/work-packages/README.md` defines that these briefs are temporary execution aids, not permanent architecture.

Progress note recorded on: `2026-05-11`

Environment validation closure:
- operator confirmed the local environment blockers are resolved:
  - Windows Developer Mode / symlink support for Flutter plugin tests
  - Java on `PATH` for Firestore rules emulator tests
  - Node 20 for Functions validation parity
- operator confirmed the previously blocked validation commands now run successfully locally.
- `npm audit fix` was applied without `--force`, reducing the Functions audit from 17 vulnerabilities to 11.
- remaining audit findings require `npm audit fix --force`, which would introduce breaking dependency changes around Firebase packages/tooling; defer those to a dedicated dependency-upgrade pass instead of treating them as a blind month-1 environment fix.

Progress note recorded on: `2026-05-11`

Month 2 backend hardening started:
- first safe extraction slice completed in Functions.
- generic validation, timestamp parsing, sanitization, and safe coercion helpers moved from `functions/src/index.ts` to `functions/src/shared/validation.ts`.
- callable exports and the public test import for `parseTimestampInput` remain compatible through a re-export from `index.ts`.
- no behavior change intended.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening follow-up:
- Competitive Verification V1 evidence validation, attempt-day helpers, session-start resolution, and completion verification were extracted from `functions/src/index.ts` into `functions/src/competitive/evidence.ts`.
- the shared local-day key helper moved to `functions/src/shared/date.ts`.
- `index.ts` remains the callable entrypoint and keeps compatibility re-exports for existing Functions tests.
- no behavior change intended.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening follow-up:
- pure competitive rank helpers were extracted from `functions/src/index.ts` into `functions/src/competitive/rank.ts`.
- the extracted helpers cover rank ordering, adjacent-rank transitions, level-to-rank mapping, peak-rank comparison, and rank maintenance requirements.
- no callable contract or transaction behavior changed.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening follow-up:
- a dedicated Month 2 backend hardening work-package checklist was added at `docs/ai/work-packages/month-2-backend-hardening.md`.
- profile/progression helpers were extracted from `functions/src/index.ts` into `functions/src/profile/progression.ts`.
- shared date helpers now include local-day parsing and unique timestamp-by-day projection in `functions/src/shared/date.ts`.
- `index.ts` remains the callable entrypoint and keeps compatibility re-exports for existing Functions tests.
- no callable contract or transaction behavior changed.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening follow-up:
- quest inventory validation and write shaping were extracted from `functions/src/index.ts` into `functions/src/quests/inventory.ts`.
- the extracted module now owns quest category/template/status validation, single/stored quest validation, `buildQuestInventorySyncWrites`, and `buildQuestDocData`.
- official competitive catalog ownership stayed in `index.ts`; the catalog is passed into the quest module explicitly to avoid circular coupling.
- no Isar, Flutter repository, callable contract, or transaction behavior changed.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening follow-up:
- competitive season helpers were extracted from `functions/src/index.ts` into `functions/src/competitive/season.ts`.
- the extracted module now owns week-key/current-week helpers, exam resolution, season reward calculation, legacy reward payload shaping, profile reward payload shaping, and cosmetic labels.
- existing week-key format and Monday week-start behavior were preserved.
- no leaderboard read, reward claim, callable contract, or transaction behavior changed.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening follow-up:
- callable wiring cleanup centralized the Functions region options and repeated Firestore user reference helpers in `functions/src/index.ts`.
- repeated refs for profile, quests, quest metadata, completions, weekly boss claims, attribute allocations, competitive progression, promotion exams, season rewards, season profile, integrity docs, and competitive quest session/grant/evidence docs now go through named helpers.
- no transaction body, callable contract, reward calculation, or validation behavior changed.
- validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-12`

Month 2 backend hardening exit review:
- Month 2 backend hardening is complete as a behavior-preserving refactor package.
- no product rules were intentionally changed:
  - XP/progression math unchanged
  - rank maintenance and promotion rules unchanged
  - competitive evidence acceptance/rejection rules unchanged
  - season reward rules unchanged
  - callable contracts unchanged
  - Firestore rules unchanged
- `functions/src/index.ts` is now primarily callable wiring plus remaining competitive integrity/rank evaluation that can be considered in a future pass if needed.
- durable module homes now exist for shared validation/date helpers, competitive evidence, competitive rank helpers, competitive season helpers, profile progression, and quest inventory.
- remaining audit/security dependency follow-up is still separate from this refactor: do not run `npm audit fix --force` blindly; handle Firebase package/tooling upgrades in a dedicated dependency-upgrade pass.
- final validation passed:
  - `npm test` in `functions`: 14 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed
  - `flutter analyze`: no issues found
  - `flutter test`: 73 tests passed
- next implementation track: Competitive Verification V1 product depth, unless release-readiness debt is intentionally pulled forward first.

Progress note recorded on: `2026-05-12`

Competitive Verification V1 product-depth follow-up:
- backend competitive completion now rejects reused evidence `sourceActivityId` values before writing a new competitive grant.
- the duplicate check reads backend-owned `competitive_quest_grants` history and ignores only the current attempt ids, keeping Flutter out of reward authority.
- resolver/test coverage now protects `duplicateSourceActivityId` rejection.
- validation passed:
  - `npm test` in `functions`: 15 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-13`

Competitive Verification V1 UI feedback follow-up:
- competitive quest cards now show evidence requirements derived from the official quest template.
- Flutter maps local/backend competitive verification failures into visible results for insufficient evidence, rejected evidence, and duplicate evidence.
- no reward, rank, or authority rules were moved to Flutter.
- validation passed:
  - `flutter analyze`: no issues found
  - `flutter test`: 75 tests passed

Progress note recorded on: `2026-05-13`

Competitive Verification V1 provider-boundary follow-up:
- Flutter now has a `CompetitiveEvidenceProviderAdapter` interface for evidence sources.
- the current mock evidence implementation is behind the adapter and remains development/test-only.
- `QuestNotifier` no longer constructs mock evidence directly.
- validation passed:
  - `flutter analyze`: no issues found
  - `flutter test`: 76 tests passed

Progress note recorded on: `2026-05-13`

Competitive Verification V1 Health Connect Adapter V1:
- Android Health Connect integration was added behind `ASCEND_USE_HEALTH_CONNECT=true`.
- Flutter can map Health Connect exercise sessions into `QuestEvidence` with duration, distance, and source session id.
- backend verification accepts `healthConnect` evidence for running/workout templates while keeping reward/rank authority server-side.
- validation passed:
  - `flutter analyze`: no issues found
  - `flutter test`: 79 tests passed
  - `npm test` in `functions`: 16 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed
- unresolved validation gap:
  - Android native build could not run because this workstation has no Android SDK configured.
  - run staging debug APK build and real-device Health Connect smoke before enabling the flag for release.

Progress note recorded on: `2026-05-13`

Competitive Verification V1 AI Reading Quiz Contract V1:
- backend now owns deterministic reading quiz attempt issuance and evaluation.
- competitive reading-comprehension evidence must include a backend-issued quiz attempt before it can grant reward/rank progress.
- Firestore rules allow users to read their own quiz attempts but block direct client writes.
- real AI generation remains intentionally unbound; it can be added later behind the contract.
- validation passed:
  - `npm test` in `functions`: 18 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed

Progress note recorded on: `2026-05-13`

Competitive Verification V1 Flutter reading quiz flow:
- Flutter now requests a backend-owned reading quiz attempt before completing
  reading-comprehension competitive quests.
- the quest screen collects ordered answers and submits `quizId` plus `answers`
  with the evidence payload.
- local Flutter pre-validation no longer requires a client `quizScore` for
  backend-owned reading quiz submissions; backend evaluation remains the only
  reward/rank authority.
- validation passed:
  - `flutter analyze`: no issues found
  - `flutter test`: 81 tests passed

Progress note recorded on: `2026-05-14`

Competitive Verification V1 reading quiz AI adapter boundary:
- backend reading quiz generation now depends on a `ReadingQuizGenerator`
  interface instead of calling the deterministic builder directly from the
  callable.
- deterministic generation remains the default provider and keeps the Flutter
  contract unchanged.
- `AiReadingQuizGenerator` supports provider-backed question generation behind
  `ASCEND_READING_QUIZ_GENERATOR=ai`, but fails closed when no real provider is
  supplied.
- Gemini is now the concrete provider implementation, using REST
  `generateContent`, structured JSON output, `GEMINI_API_KEY`, and default model
  `gemini-2.5-flash-lite`.
- `startReadingQuizAttempt` returns non-secret generator metadata for smoke and
  debugging.
- validation passed:
  - `npm run build` in `functions`: passed
  - `npm test` in `functions`: 23 tests passed
  - `npm run test:rules` in `functions`: 7 tests passed
- deployed:
  - `firebase deploy --only functions:startReadingQuizAttempt --project ascend-b7c20`
  - Firebase loaded `functions/.env.ascend-b7c20` and updated
    `startReadingQuizAttempt(southamerica-east1)`
- follow-up:
  - deploy warned that Cloud Functions Node.js 20 runtime was deprecated on
    `2026-04-30` and is scheduled for decommission on `2026-10-30`; plan a
    runtime upgrade pass before release.

Progress note recorded on: `2026-06-07`

Java backend migration completed for local project code:
- Java/Spring Boot on Cloud Run is now the authoritative backend for active
  product behavior.
- Flutter no longer imports `cloud_functions`, `FirebaseFunctions`, or
  `httpsCallable`.
- the local TypeScript `functions/` project was removed.
- `firebase.json` no longer declares a Functions source.
- TypeScript fallback paths were removed from Flutter repositories.
- documentation was updated so active architecture docs point to Java/Cloud Run
  instead of Cloud Functions/callables.
- validation passed during decommission:
  - `flutter analyze`
  - `flutter test`
  - `cd backend && mvn test package`
  - `flutter build apk --flavor staging --debug --dart-define=ASCEND_JAVA_BACKEND_URL=...`
- remaining operational cleanup:
  - delete/decommission any remotely deployed Firebase Functions if they still
    exist in the Firebase project.
  - run final staging smoke after remote cleanup.

Progress note recorded on: `2026-07-13`

V1 scope reduction started:
- first public version is now casual-first.
- `Arena` and competitive quests are hidden from the visible V1 product
  surface, while the Java/backend/domain implementation remains in the repo for
  future expansion.
- onboarding starter kit now starts with casual quests only.
- add-quest modal now creates casual quests only.
- weekly boss is being reframed as a personal weekly boss based on general
  active days, without leaderboard or rank pressure in the V1 surface.
- new operational plan:
  - `docs/product/v1-casual-first-launch-plan.md`

Progress note recorded on `2026-07-14`

Renewal foundation started:
- the product baseline now advances toward personal `Jornadas`, as defined in
  `docs/product/plano-projeto-ascend.md`;
- PostgreSQL migration V4 introduces the authoritative `jornadas` aggregate;
- Java exposes authenticated list, creation and pause operations;
- Flutter exposes the new `Jornadas` navigation surface with creation, loading,
  recoverable error and empty states;
- the next slice is chapters, milestones and the first mission-to-Jornada link.

Progress note recorded on `2026-07-14`

Mission-to-Journey link delivered:
- a personal quest can now be attached to an active Journey at creation time;
- the reference is persisted in Isar and PostgreSQL, and preserved through
  inventory synchronization and authoritative completion/revocation;
- migration V5 also creates the chapter persistence boundary for the next
  Journey slice;
- focused tests now cover Journey service rules and local quest-link retention.

Progress note recorded on `2026-07-14`

Chapter milestones delivered:
- PostgreSQL now persists ordered chapter milestones, optionally linked to a
  personal mission in the same authenticated Journey;
- authenticated endpoints list and create chapter milestones, and complete
  manual milestones idempotently;
- a paused Journey cannot receive new milestones, and a mission-linked
  milestone is advanced only by the authoritative mission completion state;
- the Flutter chapter detail now renders milestones as a compact vertical route
  and lets the player add either a manual stage or a same-Journey mission link;
- validation passed:
  - `flutter analyze`: no issues found
  - `flutter test`: passed
  - `cd backend && mvn test`: 33 tests passed

Progress note recorded on `2026-07-14`

Staging mobile follow-up:
- mission and Journey creation controls now stay above the internal navigation
  dock and Android system navigation area;
- remote failures during personal mission completion no longer escape the
  interaction handler or alter local rewards;
- operational follow-up remains to verify Railway has
  `FIREBASE_SERVICE_ACCOUNT_JSON` from the same Firebase project as the
  staging APK, because anonymous test users must be accepted by the
  authoritative backend too;
- validation passed:
  - `flutter analyze`: no issues found
  - `flutter test`: passed

Progress note recorded on `2026-07-14`

Journey completion slice:
- a chapter can be closed only after every milestone in its route is complete;
- an active Journey can be concluded only after all of its chapters;
- Flutter exposes the chapter-closing action from its route detail;
- validation passed: `flutter analyze` and `cd backend && mvn test` (35 tests).

Progress note recorded on `2026-07-14`

Journey legacy completion:
- closing a Journey now records an idempotent durable Legacy entry in PostgreSQL;
- the Journey surface exposes its completion action and preserves the completed state;
- validation passed: `flutter analyze`, `flutter test`, and `cd backend && mvn test` (36 tests).

Progress note recorded on `2026-07-14`

Journey legacy read-model:
- authenticated `GET /api/v1/journeys/legacy` returns the player's completed Journeys in deterministic chronological order;
- the Jornada surface renders those permanent records as a compact Legacy section;
- validation passed: `flutter analyze`, `flutter test`, and `cd backend && mvn test` (36 tests).

Progress note recorded on `2026-07-14`

Daily completion payoff:
- personal mission completion now displays compact XP, attribute, and Journey-route feedback;
- the next authoritative recommendation refreshes immediately after a mission mutation;
- validation passed: `flutter analyze` and `flutter test`.

Planned completion note:
- record release identity/environment readiness
- record smoke-test and operational validation state
- record trust/store-readiness status

### Phase 4 - Differentiation and guided growth

Status: `planned`

Planned completion note:
- record which guided systems improved action clarity
- record which analytics prove value or need rollback
- record which features stayed out because they were breadth-only

## Update Protocol

When a phase finishes:
1. mark the phase `completed`
2. write what actually shipped
3. write what was validated
4. write unresolved risks
5. set the next active phase explicitly
