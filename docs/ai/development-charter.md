# AI Development Charter

## Purpose

This project is intentionally developed with AI assistance. The goal is to move fast without sacrificing safety, stability, or performance.

This document defines how AI agents should work in the Ascend repository.

## Non-Negotiables

AI contributions must protect:
- correctness of progression logic
- persistence safety for local data
- authentication stability
- predictable UI behavior
- mobile performance on mid-range devices

AI must not:
- make broad speculative refactors without a clear reason
- change progression rules silently
- rewrite architecture during unrelated feature work
- introduce new dependencies without justification
- change generated files manually unless the workflow explicitly requires it

## Source of Truth

Before changing code, use these files as the primary guides:
- `AGENTS.md`
- `docs/product/vision.md`
- `docs/product/roadmap.md`
- `docs/ai/architecture-map.md`
- `analysis_options.yaml`

## Required Workflow For AI Changes

1. Understand the user request and affected feature area.
2. Read the relevant controller, model, and screen files before editing.
3. Prefer the smallest safe change that solves the problem.
4. Preserve existing behavior unless the requested change explicitly alters it.
5. If business rules change, update tests or add them.
6. If architecture changes, update `AGENTS.md` and `docs/ai/architecture-map.md`.
7. If Isar models change, regenerate code through the supported workflow.

## Safety Rules

### Persistence
- Do not change Isar schemas casually.
- Treat saved player progression as user value that must not be lost.
- Any migration-sensitive model change must be documented in the change summary.

### Authentication
- Do not modify login flow or Firebase initialization without validating the impact on Android setup.
- Do not change package identifiers unless Firebase config is updated in the same change.

### Progression Logic
- Leveling, XP, stat distribution, and daily reset are product-critical systems.
- Changes in these rules must be explicit and reviewed as behavior changes, not "cleanup".

### UI Stability
- Do not introduce nested scrolling, rebuild-heavy charts, or expensive animations without reason.
- Prefer straightforward widget trees over clever abstractions.

## Performance Rules

- Minimize avoidable rebuilds in frequently updated screens.
- Keep database access predictable and localized.
- Avoid synchronous heavy work during frame-critical interactions.
- Prefer lazy rendering patterns for growing lists and stats.
- Be conservative with animation count and duration.

## Dependency Policy

Before adding a package, justify:
- why the feature is needed now
- whether Flutter SDK or current dependencies already solve it
- what runtime and maintenance cost it adds

Prefer no new dependency unless it clearly improves product value or engineering safety.

## Definition of Done For AI Work

A change is not done unless:
- the behavior is clear
- the touched architecture still makes sense
- the relevant docs stay aligned
- there is no obvious safety regression
- any required validation steps are called out if they could not be run
