# Ascend Roadmap

## Purpose

Define the product direction for Ascend without acting as a changelog.

For execution state, use:
- `docs/product/execution-tracker.md`
- `docs/product/phase-backlog.md`
- `docs/product/project-plan.md`
- `docs/ai/source-of-truth.md`

## Product Goal

Turn Ascend into a stable account-backed RPG progression product where daily
actions create visible identity, momentum, and competitive progress.

Ascend should not drift into a generic to-do list. Quests are the input; player
growth, weekly pressure, rank, and payoff are the product center.

## Current Strategy

The current strategy is production readiness before feature breadth.

Priorities:
- make account, progression, and competitive rewards trustworthy
- keep reward-bearing outcomes backend-authoritative
- make the first week and daily return loop clear
- close release, support, smoke-test, and operational ownership gaps
- deepen Competitive Verification V1 only where it improves Arena trust

Non-priorities right now:
- broad social systems
- cosmetic economy breadth
- AI features across the whole app
- new gameplay systems that increase release risk

## Current Phase

Active phase:
- `Phase 3 - Product reliability and release readiness`

Current stabilization package:
- documentation and control-plane cleanup

Next implementation track after cleanup:
- `Competitive Verification V1`

External beta remains blocked until:
- real support channel and owner are set
- real-device smoke is recorded
- staging/production build identity is validated on device
- operational owner and backup are named

## Six-Month Direction

### Month 1 - Control Plane And Validation Environment

Goal:
- make the repo understandable and validation repeatable

Deliverables:
- compact current documentation into a small trusted set
- reclassify temporal AI handoff docs as work-package briefs
- fix local validation prerequisites: `completed on 2026-05-11`
  - Windows Developer Mode or symlink support for Flutter plugin tests
  - Java on `PATH` for Firestore rules emulator tests
  - Node 20 for Functions validation parity
- run and record the full validation suite
- triage Functions dependency vulnerabilities:
  - safe `npm audit fix` applied
  - breaking `npm audit --force` path deferred to a dedicated dependency-upgrade pass

Exit criteria:
- future sessions can start from `docs/ai/source-of-truth.md`
- roadmap and architecture docs describe current state, not accumulated history
- active handoff docs live under `docs/ai/work-packages/` and are clearly temporary
- validation failures are product failures, not environment ambiguity

### Month 2 - Backend And Authority Hardening

Goal:
- make reward-bearing flows easier to trust and maintain

Deliverables:
- split large Functions implementation into domain/service modules without
  changing behavior
- keep callable contracts test-protected
- remove or instrument silent failure paths in critical sync flows
- confirm backend grant records are the long-term source for competitive credit
- keep `sync*FromSource` paths as migration/repair tooling, not normal reward
  authority

Exit criteria:
- account progression and competitive grants are auditable
- backend code can be changed safely without editing one very large file
- direct client reward authority does not reappear

### Month 3 - UI Maintainability And Core Loop Clarity

Goal:
- keep top-level surfaces clear while reducing regression risk

Deliverables:
- break oversized screens into local sections/widgets where it improves clarity
- preserve surface ownership:
  - Base/Home: identity, momentum, payoff
  - Quests: execution
  - Arena/Rank: competitive systems
  - Stats/Plan: review, numbers, planning support
  - Account: identity and trust controls
- improve evidence/status readability for competitive quests
- keep widget tests focused on state, actions, and stable keys

Exit criteria:
- core screens are easier to change without broad widget regressions
- users can understand the next action without reading long explanatory panels

### Month 4 - Release Readiness

Goal:
- make the app safe for controlled external testing

Deliverables:
- real support channel and response owner
- real-device smoke pass for auth, onboarding, quests, competitive verification,
  account, logout, restart, and session restore
- staging and production install/login verification
- Crashlytics and Analytics sanity check from a real build
- store/trust package:
  - screenshots
  - listing copy
  - privacy/support/deletion links
  - closed-test instructions

Exit criteria:
- release candidate can be built, identified, validated, and distributed without
  environment confusion

### Month 5 - Competitive Verification V1

Goal:
- make Arena progress evidence-based without pretending to have perfect anti-cheat

Deliverables:
- duplicate `sourceActivityId` checks
- visible backend decision details in competitive quest UI
- provider adapter boundaries before real Health Connect or Strava integration
- backend-owned quiz contract before AI reading quiz work
- tests for accepted, rejected, duplicate, stale, and impossible evidence

Exit criteria:
- competitive progress depends on backend decisions and auditable evidence
- mock evidence remains clearly non-production
- real provider integration can start without redesigning the contract

### Month 6 - Controlled Beta And Stabilization

Goal:
- validate the product with a small external audience

Deliverables:
- internal release candidate
- small controlled tester cohort
- weekly review of crashes, funnel events, support, and failed callables
- regression fixes before new features
- launch decision based on stability, trust, and retention signals

Exit criteria:
- Ascend is stable enough to continue toward store release or the remaining
  blockers are explicit and bounded

## Product Requirements To Protect

P0 requirements:
- account and session authority
- onboarding into a first useful action
- personal quest loop
- competitive quest loop
- visible progression and player identity
- competitive rank and weekly pressure
- trust/support/account surfaces
- release operations

P1 requirements:
- seasonal and historical reads
- planning and guidance
- performance and accessibility polish

Reference:
- `docs/product/requirements-baseline.md`

## Architecture Direction

The production direction is:
- frontend issues commands
- backend validates and writes canonical facts
- backend updates `users/{uid}/profile/current` and competitive read models
- Firestore rules block direct client writes to sensitive read models
- Isar remains local cache/offline support

Reference:
- `docs/product/progression-architecture.md`
- `docs/ai/architecture-map.md`

## Deferral Policy

Defer work that:
- adds feature breadth before release confidence
- moves reward-bearing rules back into Flutter controllers
- increases competitive stakes without stronger evidence
- expands AI before core guidance is measurable
- adds social or cosmetic systems before account, support, and smoke-test gaps close

Accept work that:
- reduces release risk
- clarifies first-week action
- improves backend authority
- improves validation coverage
- makes current screens easier to maintain without changing product behavior
