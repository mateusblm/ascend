# Execution Tracker

## Purpose

Keep phase progress explicit so future sessions do not have to reconstruct project state from scattered commits, chat history, or memory.

Update this file:
- at the end of every phase
- at any major milestone inside the active phase
- when the allowed next focus changes

## Current State

- Current date baseline: `2026-04-24`
- Active plan: `docs/product/project-plan.md`
- Active requirements baseline: `docs/product/requirements-baseline.md`
- Active phase: `Phase 3 - Product reliability and release readiness`
- Active product focus override: `Competitive Verification V1` before more external-release work
- Previous phase status: `Phase 1 advanced with accepted operational debt`
- Active backlog: `docs/product/phase-backlog.md`
- Active smoke log: `docs/product/phase1-smoke-log.md`

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
- next-agent brief in `docs/ai/competitive-verification-next-agent.md`

Why:
- the core product value depends on Arena progress being evidence-based
- current competitive verification is too narrow for running, reading, workout, and study quests
- a pure evaluator, richer official templates, and fake evidence provider can be built and tested before Health Connect, Strava, GPS, or AI integrations

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
