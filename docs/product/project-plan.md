# Project Plan

## Purpose

Convert the roadmap into an execution plan with ordered phases, explicit gates, and clear stop conditions.

This document is the operational companion to:
- `docs/product/requirements-baseline.md`
- `docs/product/roadmap.md`
- `docs/ai/quality-gates.md`
- `docs/product/execution-tracker.md`

## Execution Rules

- Do not start a new phase because the current one feels "mostly done."
- Do not pull future-phase polish forward if the current phase still has `P0` gaps.
- If a task does not strengthen the active phase objective, defer it unless it removes direct risk.
- Every phase ends with:
  - an exit review
  - a validation summary
  - a tracker update in `docs/product/execution-tracker.md`

## Phase Map

### Phase 0 - Baseline and control plane

Status: `completed`

Goal:
- replace ad hoc execution with a controlled project baseline

Completed in this phase:
- requirements baseline
- project-plan document
- quality-gates document
- execution tracker
- references from process docs into the new control documents

Deliverables:
- `docs/product/requirements-baseline.md`
- `docs/product/project-plan.md`
- `docs/ai/quality-gates.md`
- `docs/product/execution-tracker.md`

Exit criteria:
- the active phase is explicit
- future work can be rejected or accepted against documented scope
- completion notes have a home so the project does not lose context between sessions

### Phase 1 - Core authority and trust

Status: `in_progress`

Goal:
- make account, progression, and competitive actions safe enough to trust

In scope:
- backend-authoritative command path for reward-bearing actions
- profile and quest continuity across devices
- session authority and conflict handling
- Firebase rules hardening and validation discipline
- trust/account surfaces required for external testing

Out of scope:
- new progression systems
- broad cosmetic expansion
- UI-only polish that does not reduce risk

Primary deliverables:
- authoritative profile/current aggregate as normal production read
- audited command path for personal completion, revocation, attribute allocation, competitive verification, and weekly boss claim
- user-scoped cache behavior and restore protection
- privacy/support/account-readiness minimums
- release environment clarity for staging and production

Primary risks:
- reward duplication
- stale local truth overriding remote truth
- account/session confusion across devices
- permissive rules or wrong-environment deployment

Validation required:
- automated coverage for progression/auth/sync critical paths
- rules/emulator validation where applicable
- real-device smoke path for login, onboarding, personal completion, competitive verification, account access, logout, session restore

Exit criteria:
- client-side reward math is not the final authority
- second-device continuity is trustworthy
- rules and command paths are unambiguous
- market-facing trust gaps are closed to baseline level

### Phase 2 - Core loops and retention

Status: `planned`

Goal:
- make the product's daily and weekly return loop reliable and legible

In scope:
- personal quest loop quality
- competitive quest loop quality
- onboarding-to-first-week coherence
- Home and Quests next-action clarity
- streak, payoff, and weekly pressure readability

Out of scope:
- advanced social features
- deep seasonal economy expansion
- broad design exploration not tied to the core loop

Primary deliverables:
- polished first-week path
- clear hero and action hierarchy on top-level tabs
- bounded and test-protected XP/streak/reward behavior
- strong widget coverage for core surfaces

Primary risks:
- app feels decorative instead of useful
- users cannot tell what to do next
- competitive and personal loops blur into one exploitable system

Validation required:
- progression and quest unit tests
- widget coverage for Home, Quests, Rank, onboarding, and account states
- manual smoke path focused on first-session and first-week flow

Exit criteria:
- the user can install, onboard, complete quests, and understand why they should return tomorrow
- retention loops are visible without reading long explanatory copy
- critical loop regressions are covered by automated tests

### Phase 3 - Product reliability and release readiness

Status: `planned`

Goal:
- make the app releasable to strangers, not just workable for internal use

In scope:
- release identity and artifact discipline
- observability
- operational dashboards/checklists
- feature-flag or kill-switch direction for risky live behavior
- store/trust package and smoke-test cadence

Out of scope:
- new gameplay systems without direct release value
- speculative growth features

Primary deliverables:
- repeatable release path
- smoke-test matrix and release-candidate checklist discipline
- operational alert expectations
- store-ready screenshots, metadata, and support paths

Primary risks:
- shipping the wrong environment
- silent regressions in auth or competitive flows
- external testers hitting trust gaps before product issues

Validation required:
- release-candidate smoke pass
- environment verification
- analytics/crash hooks sanity check
- staged external test readiness review

Exit criteria:
- release candidate can be built, identified, validated, and distributed with confidence
- the app has minimum market trust posture
- operational response to live failures is possible without emergency refactors

### Phase 4 - Differentiation and guided growth

Status: `planned`

Goal:
- deepen product value only after the baseline is stable

In scope:
- guided growth systems
- better weekly planning and review
- AI-assisted quest suggestion where it strengthens the loop
- richer payoff around identity, titles, rivalries, and medium-term journeys

Out of scope:
- uncontrolled feature sprawl
- broad AI additions with unclear retention value
- social systems that exceed current authority and moderation capacity

Primary deliverables:
- structured weekly guidance
- smarter suggestions tied to focus and recent behavior
- clearer medium-term goals such as 7/30/90-day arcs
- deeper but still safe identity payoff

Primary risks:
- adding breadth before the product earns it
- AI features obscuring the core loop instead of reinforcing it
- new guidance systems increasing surface area without improving retention

Validation required:
- product acceptance against retention and clarity goals
- analytics instrumentation for suggestion usage and completion impact
- UX validation on whether users act faster and return more often

Exit criteria:
- guided growth improves action clarity and retention, not just novelty
- deeper progression does not undermine authority, trust, or simplicity

## Dependency Order

Dependencies are strict:

1. Phase 0 before all others
2. Phase 1 before meaningful new reward-bearing breadth
3. Phase 2 before heavy release push
4. Phase 3 before broad external validation
5. Phase 4 only after the product baseline is stable

## How To Use This Plan

Before starting work:
- identify the active phase
- map the task to requirements in `requirements-baseline.md`
- apply the gates in `docs/ai/quality-gates.md`

When finishing work:
- record what changed
- record what was validated
- update the current phase note in `docs/product/execution-tracker.md`
