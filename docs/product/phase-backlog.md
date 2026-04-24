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

### Workstreams

#### Workstream 2.1 - First-week path

Status: `pending`

Backlog:
- verify onboarding -> starter kit -> first quest path on small and large screens
- tighten first-week copy until the next action is obvious without reading multiple panels
- record manual first-week smoke path

#### Workstream 2.2 - Core surface hierarchy

Status: `partial`

Current state:
- Home, Quests, Arena, and Plano already have redesign direction

Still required:
- device-size validation for the redesigned surfaces
- cleanup of remaining production-facing copy quality issues
- confirmation that each top-level tab owns a distinct concept and does not duplicate metrics without purpose

#### Workstream 2.3 - Loop protection tests

Status: `partial`

Completed:
- broad progression/rank/quest coverage already exists
- Home, Rank, onboarding, account, and player tracking tests exist

Still required:
- Quests screen widget coverage
- explicit tests for the first-week flow as a user journey
- visual/behavioral regression protection for key loop surfaces where useful

#### Workstream 2.4 - Return motivation

Status: `pending`

Backlog:
- verify that streak, payoff, rank pressure, and weekly guidance all remain visible from the main loops
- ensure users can tell why to return tomorrow and this week
- reject additions that add surface area without improving return clarity

### Phase 2 exit checklist

- first useful action is obvious from onboarding through the first week
- Home and Quests make the next step clear
- the core quest/progression loop is protected by automated tests
- critical loop copy is production-quality Portuguese

## Phase 3 - Product reliability and release readiness

### Goal

Turn the validated build into a releasable candidate for external testers.

### Workstreams

#### Workstream 3.1 - Release candidate discipline

Status: `partial`

Completed:
- release checklist exists
- environment doc exists
- Android identities are documented

Still required:
- record an actual release-candidate checklist pass
- capture the exact release artifact path used for testing

#### Workstream 3.2 - Operational observability

Status: `partial`

Completed:
- analytics and crash boundaries exist centrally

Still required:
- verify event and non-fatal coverage on current critical flows
- document who watches operational signals and how often during external testing

#### Workstream 3.3 - Store and trust package

Status: `partial`

Completed:
- privacy, terms, support, and deletion docs exist

Still required:
- screenshots
- listing copy
- support ownership
- external test distribution plan

#### Workstream 3.4 - Live-risk response

Status: `pending`

Backlog:
- define remote-config/feature-flag/kill-switch direction for risky competitive behavior
- document the rollback response path for bad live regressions

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
