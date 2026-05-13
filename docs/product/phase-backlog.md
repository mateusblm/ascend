# Phase Backlog

## Purpose

Translate the high-level project phases into concrete workstreams and checkpoints that can be executed across future sessions without losing sequence.

This document is downstream from:
- `docs/product/requirements-baseline.md`
- `docs/product/project-plan.md`
- `docs/product/execution-tracker.md`

## Status Keys

- `done`: implemented and validated enough to stop treating it as active delivery work
- `partial`: implemented in some form, but still blocks phase exit
- `pending`: not implemented or not validated enough to count

## Phase 1 - Core authority and trust

### Current audit summary

The repo already has strong Phase 1 movement:
- active-session repository and conflict handling exist
- backend callables exist for profile settings, attribute allocation, personal quest completion, competitive verification, and weekly boss claim
- profile and quest repositories already prefer callable-backed authority
- Firestore rules are locked down to read-only from the client for authority-sensitive collections
- release environments and trust-surface docs already exist
- the account surface already exposes account identity, privacy, terms, support, and deletion direction

What still blocks a clean Phase 1 exit:
- support is now configurable at build time, but still defaults to the placeholder inbox until a real monitored channel is set for release
- real-device smoke validation is documented but not recorded as completed
- rules/emulator validation now exists, but the completion still needs to be referenced in the phase-exit note
- there is not yet one explicit Phase 1 completion review tying all of the above together

Current handling decision:
- product work is allowed to continue in `Phase 2`
- the items above remain explicit carried debt and cannot silently disappear
- treat them as required closure before Phase 3 release-readiness work

### Workstreams

#### Workstream 1.1 - Session authority

Status: `partial`

Completed:
- device session id generation and callable registration
- conflict detection path in auth/session flows
- central sign-out on active-session conflict
- unit coverage for conflict classification

Still required:
- explicit integration or smoke evidence that second-device conflict handling behaves correctly end-to-end
- tracker note recording the actual validation result

#### Workstream 1.2 - Backend-authoritative profile path

Status: `partial`

Completed:
- `profile/current` read model wiring in the client
- callable-backed profile sync and profile settings updates
- attribute allocation routed through backend callables
- repository-level tests covering missing-remote upload policy and profile parsing

Still required:
- one explicit phase-exit note confirming client snapshots are no longer treated as normal reward authority
- smoke validation on second-device restore and cache convergence

#### Workstream 1.3 - Backend-authoritative quest path

Status: `partial`

Completed:
- callable-backed personal quest completion and revocation
- callable-backed competitive quest verification
- quest inventory sync callable path
- callable tests for competitive authority and audited metadata
- repository-level tests covering quest sync parsing and upload policy
- Firestore rules emulator coverage now verifies:
  - public weekly boss reads
  - self-only account reads
  - direct client writes blocked on profile, quests, session, claims, season, integrity, and competitive session docs

Still required:
- phase-exit record confirming duplicate-grant and direct-write risks are acceptably controlled

#### Workstream 1.4 - Trust surfaces

Status: `partial`

Completed:
- account screen exists
- privacy and terms summaries are accessible in-app
- support/deletion direction is documented
- widget coverage now protects account rendering and logout entry
- support channel is now configurable through `ASCEND_SUPPORT_EMAIL`

Still required:
- set a real monitored support contact for the target release
- align the public operational policy with the actual support owner and response expectation

#### Workstream 1.5 - Release environment clarity

Status: `partial`

Completed:
- Android production/staging identities defined
- release signing path documented
- iOS production identity documented
- release checklist exists
- shared Firebase policy for the current validation phase is now explicit

Still required:
- record real-device validation for staging and production login/install flows
- close the open iOS staging/operational readiness gap if it is required before broader testing

### Phase 1 exit checklist

- a real support channel replaces the placeholder
- the real-device smoke log in `docs/product/phase1-smoke-log.md` has at least one completed pass
- real-device smoke pass is recorded for:
  - login
  - onboarding restore or first-run path
  - personal quest completion
  - competitive quest verification
  - account access
  - logout
  - session restore
- one completion note is written into `execution-tracker.md`

## Phase 2 - Core loops and retention

### Goal

Make the first-week and daily-return loop obvious, reliable, and test-protected.

### Activation status

Status: `completed_with_accepted_debt`

Activation note:
- this phase started with tracked operational debt still open from Phase 1
- allowed because the remaining debt is release-facing rather than a blocker for loop clarity work
- do not treat this as permission to skip the pending support and real-device smoke items permanently

### Workstreams

#### Workstream 2.1 - First-week path

Status: `completed_with_manual_validation_debt`

Completed:
- first-week guidance is visible inside `Quests`
- the first-week panel now exposes a direct creation CTA instead of only descriptive copy
- onboarding now routes directly into `Quests` after starter-kit confirmation
- onboarding now names the first recommended Base quest instead of ending at a generic confirmation step
- automated journey coverage now verifies onboarding focus selection, starter-kit confirmation, navigation into `Quests`, actionable starter quests, and first personal quest completion from an empty local quest cache

Backlog:
- manually verify onboarding -> starter kit -> first quest path on small and large screens
- record manual first-week smoke path

#### Workstream 2.2 - Core surface hierarchy

Status: `completed_with_manual_validation_debt`

Current state:
- Home, Quests, Arena, and Plano already have redesign direction
- ownership audit and UI smoke checklist now exist
- `Quests` no longer depends on a dock-obscured floating action button as the only top-level creation entry
- `Home` and `Quests` now expose distinct return-loop cues without turning either surface into a duplicated dashboard

Still required:
- device-size validation for the redesigned surfaces
- real-device confirmation that each top-level tab owns a distinct concept and does not duplicate metrics without purpose

#### Workstream 2.3 - Loop protection tests

Status: `done`

Completed:
- broad progression/rank/quest coverage already exists
- Home, Rank, onboarding, account, and player tracking tests exist
- stats screen ownership coverage exists
- quest card coverage now protects the recent visual regression fix
- first-week journey coverage now protects the expected next-action progression across the early loop
- onboarding-to-quests journey coverage now protects the Phase 2 handoff without decorative copy assertions
- attribute allocation now has controller-level coverage for instant UI feedback and rollback on authority failure
- Home return-motivation coverage protects tomorrow/streak, weekly pressure, and payoff state
- Quests return-loop coverage is anchored in the onboarding-to-first-quest journey
- widget coverage was trimmed away from decorative copy and stale local assumptions toward action/state contracts and authority-aware behavior

Still required:
- add visual/behavioral regression protection only when future loop changes introduce new risk

#### Workstream 2.4 - Return motivation

Status: `done`

Completed:
- `Home` now shows a compact return-motivation cue that connects tomorrow's return, weekly pressure, and the next payoff
- `Quests` now shows a compact action-surface cue that connects today's first action, tomorrow's return, and weekly/rank pressure
- automated coverage protects the return-motivation state contract and the Home surface key
- onboarding-to-quests journey coverage protects that the `Quests` return-loop cue is present before the first personal quest action

Backlog:
- verify on device that streak, payoff, rank pressure, and weekly guidance remain readable without crowding

### Phase 2 exit checklist

- first useful action is obvious from onboarding through the first week: `met by automated journey coverage`
- Home and Quests make the next step clear: `met in app surfaces and widget coverage`
- the core quest/progression loop is protected by automated tests: `met`
- critical loop copy is production-quality Portuguese: `met for changed loop-critical surfaces; continue reviewing during release polish`
- carried Phase 1 debt is still visible and not forgotten: `met`
- manual/device-size validation: `accepted debt carried into Phase 3 release readiness`

## Phase 3 - Product reliability and release readiness

### Goal

Turn the validated build into a releasable candidate for external testers.

### Current stabilization package

Status: `done_with_dependency_followup`

Purpose:
- make the repo understandable again before more implementation work
- remove stale operational instructions
- identify the small set of docs that future AI sessions should trust first
- keep historical memory available without letting it override code or curated docs

Completed on `2026-05-11`:
- stale Android package guidance in `README.md` was corrected
- validation blockers were recorded in `docs/product/execution-tracker.md`
- `docs/ai/source-of-truth.md` was introduced as the entry map for future AI work
- `docs/product/roadmap.md` was compacted into current strategy and six-month direction
- `docs/ai/architecture-map.md` was compacted into current architecture, boundaries, risks, and refactor priorities
- `docs/ai/competitive-verification-next-agent.md` was reclassified as `docs/ai/work-packages/competitive-verification-v1-next.md`
- local validation prerequisites were resolved by the operator:
  - Windows Developer Mode / symlink support
  - Java on `PATH`
  - Node 20 for Functions validation parity
- `npm audit fix` was applied without `--force`, updating safe transitive dependencies in `functions/package-lock.json`

Still required:
- evaluate remaining `npm audit --force` recommendations in a dedicated dependency-upgrade pass rather than applying breaking changes blindly

### Product focus override

Status: `active`

Decision:
- broader external-release work is paused by operator choice
- support email and real-device smoke remain known debt
- the next implementation package should improve competitive quest value and anti-fraud before depending on device APIs

Reference:
- `docs/product/competitive-verification-v1.md`
- `docs/ai/work-packages/competitive-verification-v1-next.md`

Implementation target:
- add an evidence-based competitive verification contract
- add richer official competitive quest templates
- add a pure evaluator and fake/test evidence provider
- keep backend authority over reward and rank-bearing decisions

Completed in the first implementation slice:
- evidence domain and evaluator in Flutter
- mock evidence provider for non-device tests
- running, focus, reading, workout, and study official templates
- backend evidence evaluator before competitive reward grant
- backend evidence audit collection
- Firestore rule/test coverage for evidence audit read-only access

Backend hardening completed on `2026-05-12`:
- Functions code was reorganized without intentional product-rule changes.
- shared validation/date helpers, competitive evidence, competitive rank helpers,
  competitive season helpers, profile progression, and quest inventory now have
  module homes outside `functions/src/index.ts`.
- callable wiring was cleaned up with shared callable options and Firestore ref
  helpers.
- final validation passed for Functions, Firestore rules, `flutter analyze`, and
  `flutter test`.

Competitive Verification V1 follow-up completed on `2026-05-12`:
- backend competitive completion now checks prior grant history for reused
  `sourceActivityId` values before writing a new grant.
- duplicate source activity evidence is rejected with
  `duplicateSourceActivityId`.
- Functions coverage protects the duplicate-source rejection path.

Competitive Verification V1 follow-up completed on `2026-05-13`:
- competitive quest cards now expose the expected evidence requirement from
  the official template.
- competitive completion feedback now distinguishes insufficient evidence,
  rejected evidence, and duplicate evidence instead of collapsing all of them
  into a generic invalid flow.
- Flutter remains a rendering/submission surface only; reward and rank-bearing
  decisions stay backend-owned.

Competitive Verification V1 follow-up completed on `2026-05-13`:
- Flutter now has a `CompetitiveEvidenceProviderAdapter` boundary for evidence
  sources.
- the existing deterministic mock evidence provider is wrapped behind that
  boundary instead of being constructed directly in the quest controller.
- adapter coverage exists before adding real Health Connect, Strava, or GPS
  integrations.

Competitive Verification V1 follow-up completed on `2026-05-13`:
- Health Connect Adapter V1 was added behind
  `ASCEND_USE_HEALTH_CONNECT=true`.
- Android reads exercise session duration, distance, and session id through
  Health Connect for running/workout evidence.
- backend competitive verification now accepts `healthConnect` as an allowed
  provider for running and workout templates.
- the default app path remains mock/dev evidence until Android native build and
  real-device smoke pass.

Still pending after the current slice:
- Android SDK setup and staging debug APK build for the native Health Connect code
- real-device Health Connect permission/read smoke
- AI reading quiz generation

### Workstreams

#### Workstream 3.1 - Release candidate discipline

Status: `partial`

Completed:
- release checklist exists
- environment doc exists
- Android identities are documented
- internal release-candidate log exists
- Android staging/debug, production/debug, and production/release APK artifacts have been built and recorded for `RC-internal-2026-04-25`

Still required:
- record real-device install and smoke results against the recorded artifact
- replace placeholder support contact before external beta

#### Workstream 3.2 - Operational observability

Status: `done_with_owner_placeholder`

Completed:
- analytics and crash boundaries exist centrally
- automated RC validation now includes Functions authority tests and Firestore rules emulator tests
- operational dashboard now documents the external-test review cadence and signal ownership placeholder
- live-risk response path now documents stop-distribution, backend hotfix, mobile hotfix, and future kill-switch direction

Still required:
- replace owner placeholder with named human owner and backup before broader beta
- verify live Analytics and Crashlytics signals during real-device smoke and first external test

#### Workstream 3.3 - Store and trust package

Status: `partial`

Completed:
- privacy, terms, support, and deletion docs exist
- external test distribution stages and tester instructions are documented

Still required:
- screenshots
- listing copy
- support ownership
- Stage 1 real-device smoke before closed external test

#### Workstream 3.4 - Live-risk response

Status: `done_for_controlled_validation`

Completed:
- manual stop-distribution, backend hotfix, mobile hotfix, and RC replacement paths are documented
- future Remote Config / kill-switch direction is documented without adding premature flags

Still required:
- add actual Remote Config flags only when a specific risky behavior needs live toggling

### Phase 3 exit checklist

- release candidate checklist completed
- trust surfaces aligned with real operations
- smoke validation recorded
- external distribution can happen without environment confusion

## Phase 4 - Differentiation and guided growth

### Goal

Add depth only where it improves action clarity, retention, and identity.

### Workstreams

#### Workstream 4.1 - Weekly guidance

Status: `pending`

Backlog:
- define the authoritative weekly review and planning flow
- keep planning guidance tied to focus and recent behavior
- ensure the guidance reduces user hesitation instead of adding dashboards

#### Workstream 4.2 - AI-assisted suggestions

Status: `pending`

Backlog:
- constrain AI suggestions to focus-aligned, bounded outputs
- define telemetry for suggestion acceptance and follow-through
- protect against AI breadth that weakens the core loop

#### Workstream 4.3 - Medium-term journeys

Status: `pending`

Backlog:
- define 7/30/90-day arcs or equivalent structured journeys
- connect journeys to payoff, not just planning copy
- ensure journey systems do not bypass competitive integrity boundaries

#### Workstream 4.4 - Identity payoff

Status: `partial`

Current state:
- titles, rank, season payoff, and build identity already exist in some form

Still required:
- prioritize only payoff that strengthens attachment and retention
- reject cosmetics or progression breadth that is not yet earned by the baseline

### Phase 4 exit checklist

- guided systems help the user act faster
- analytics can show whether guidance is helping
- new depth does not weaken authority, clarity, or trust
