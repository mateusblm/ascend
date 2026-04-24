# Execution Tracker

## Purpose

Keep phase progress explicit so future sessions do not have to reconstruct project state from scattered commits, chat history, or memory.

Update this file:
- at the end of every phase
- at any major milestone inside the active phase
- when the allowed next focus changes

## Current State

- Current date baseline: `2026-04-23`
- Active plan: `docs/product/project-plan.md`
- Active requirements baseline: `docs/product/requirements-baseline.md`
- Active phase: `Phase 1 - Core authority and trust`
- Previous phase status: `Phase 0 completed`
- Active backlog: `docs/product/phase-backlog.md`
- Active smoke log: `docs/product/phase1-smoke-log.md`

## Phase Table

| Phase | Status | Entry condition | Exit condition |
| --- | --- | --- | --- |
| Phase 0 - Baseline and control plane | `completed` | project needs operational discipline | requirements, plan, gates, and tracker are published |
| Phase 1 - Core authority and trust | `in_progress` | Phase 0 completed | authority, sync, rules, and trust baseline are reliable |
| Phase 2 - Core loops and retention | `planned` | Phase 1 complete | personal and competitive loops are clear and protected |
| Phase 3 - Product reliability and release readiness | `planned` | Phase 2 complete | release candidate can be validated and distributed safely |
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

Status: `in_progress`

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

Current blockers before phase exit:
- support now comes from release config, but still defaults to placeholder `support@ascend.app` until a real monitored channel is set
- no recorded real-device smoke pass yet for the full trust-critical flow

Reference:
- see `docs/product/phase-backlog.md` for the current workstream status and exit checklist
- see `docs/product/phase1-smoke-log.md` for the required device validation record

Planned completion note:
- record which backend-authoritative paths are in place
- record which sync risks were removed
- record which trust/account/release surfaces are now safe enough for external testing
- record which smoke path still remains

Allowed focus while active:
- account/session authority
- canonical profile and quest continuity
- Firebase rules hardening
- trust/support/account surfaces
- release-environment clarity

Do not drift into:
- cosmetic expansion
- broad UI exploration
- new progression systems without direct risk reduction

### Phase 2 - Core loops and retention

Status: `planned`

Planned completion note:
- record how the first-week loop improved
- record how Home, Quests, and Rank now show the next useful action
- record which loop regressions are covered by tests

### Phase 3 - Product reliability and release readiness

Status: `planned`

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
