# Quality Gates

## Purpose

Define the minimum discipline required before work starts, while it is in progress, and before it is called done.

Use this file together with:
- `docs/product/requirements-baseline.md`
- `docs/product/project-plan.md`
- `docs/ai/testing-strategy.md`
- `docs/ai/change-checklist.md`

## Gate Model

Every meaningful change must pass four gates:
- `Scope gate`: does this belong to the active phase?
- `Architecture gate`: does the source-of-truth boundary stay correct?
- `Safety gate`: does the change avoid obvious security, sync, or regression risk?
- `Validation gate`: is the proof of correctness appropriate to the risk tier?

If any answer is "no" or "unknown," the work is not done.

## Risk Tiers

### Tier A - Critical

Includes:
- auth
- session management
- reward-bearing progression
- competitive verification
- profile or quest authority/sync
- Firebase rules
- release environment or package identity

Minimum requirements:
- explicit requirement mapping
- explicit architecture note
- automated coverage added or updated when feasible
- validation run and recorded
- remaining real-device or config risk called out

### Tier B - Important

Includes:
- onboarding
- account surface
- Home, Quests, Rank, and Stats user-critical states
- analytics/crash hooks
- release-facing copy and trust surfaces

Minimum requirements:
- requirement mapping
- regression review
- widget or manual validation depending on scope
- docs updated if product behavior changed

### Tier C - Local

Includes:
- isolated presentation polish
- non-critical copy cleanup
- visual rhythm and spacing changes
- internal refactors with no behavior change

Minimum requirements:
- local behavior check
- touched docs updated if user-facing meaning changed

## Definition Of Ready

Do not start implementation until all of the following are true:
- the active phase is known
- the task maps to a requirement or risk in the baseline
- the touched feature area is identified
- the likely source-of-truth boundary is understood
- validation expectations are known in advance

For Tier A work, also require:
- backend versus client authority is explicitly decided
- environment or migration impact is identified
- fallback behavior on remote failure is understood

## Architecture Gate

Reject the change or redesign it if it causes any of the following:
- reward-bearing truth moves into Flutter controllers as final authority
- widgets gain business logic that belongs in repositories/use-cases/backends
- local cache starts behaving like canonical account state
- multiple screens duplicate the same concept with conflicting ownership
- new dependencies add complexity without clear safety or product value

## Safety Gate

Before finishing, confirm:
- no obvious privilege or authorization regression was introduced
- no double-grant path was introduced for rewards
- no signed-out or partially restored invalid UI state was introduced
- no environment ambiguity was introduced
- failure handling remains visible and safe

For Tier A work, also confirm:
- client failure cannot silently mint or preserve trust-bearing rewards
- sync remains user-scoped
- overlapping Firebase rules do not accidentally widen access

## Validation Gate

### Tier A validation minimum

- run the relevant automated tests when tooling allows
- run targeted static validation such as `flutter analyze` when relevant
- verify environment/rules assumptions explicitly
- record exact manual smoke path still required if not performed

### Tier B validation minimum

- run relevant widget/unit tests where affected
- perform local behavior verification
- record remaining manual checks if the surface is release-facing

### Tier C validation minimum

- local verification of the touched surface
- note if no automated test was appropriate

## Documentation Gate

Update docs when the change affects:
- product behavior
- architecture or source-of-truth boundaries
- release readiness
- validation expectations
- phase scope or progress

The minimum update set should be:
- baseline or roadmap if scope changed
- architecture map if responsibility boundaries changed
- testing strategy if validation requirements changed
- execution tracker if the phase state changed

## Definition Of Done

Work is not done unless:
- the change belongs to the active phase
- the requirement or risk it serves is clear
- source-of-truth boundaries still make sense
- the appropriate validation was run or explicitly queued
- docs remain aligned
- remaining risk is stated in plain language

## Release-Facing Gate

For release-facing work, additionally require:
- target environment is unambiguous
- support, privacy, and account implications are reviewed
- smoke path is explicit
- unresolved assumptions are written down before calling the work production-ready

## Tracker Rule

At the end of each phase or major milestone:
- update `docs/product/execution-tracker.md`
- record what was completed
- record what remains blocked
- record the next allowed focus
