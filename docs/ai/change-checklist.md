# AI Change Checklist

## Purpose

Use this checklist before, during, and after any AI-assisted code change in Ascend.

## Before Editing

- Confirm the feature area being changed.
- Read the relevant model, controller, and screen files.
- Read `AGENTS.md` and any related file in `docs/ai/` or `docs/product/` if the change affects architecture or behavior.
- For progression/account changes, read `docs/product/progression-architecture.md` before deciding where the rule should live.
- For navigation, labels, or major UI hierarchy, read:
  - `docs/product/ux-positioning.md`
  - `docs/product/ui-information-architecture.md`
- Identify whether the change touches a critical system:
  - progression logic
  - quest completion
  - daily reset
  - auth
  - persistence
  - release identity or Firebase environment
- Prefer the smallest safe implementation that solves the request.

## During Editing

- Keep edits scoped to the request.
- Avoid broad cleanup unless it directly reduces risk in the touched code.
- Preserve behavior unless the user explicitly asked for behavior change.
- Keep naming and file placement consistent with the current architecture.
- Avoid adding dependencies unless clearly justified.
- If the change introduces or changes a reward-bearing rule, ask whether that rule belongs in the backend instead of Flutter.
- Prefer storing canonical facts and backend-authored aggregates rather than trusting client snapshots for account progression.
- If changing an Isar model, treat it as a schema change and call it out explicitly.
- If changing Android identifiers or Firebase-related setup, verify the configuration impact before proceeding.
- If changing release-readiness surfaces, check whether the work also needs updates to:
  - `docs/product/release-checklist.md`
  - `docs/product/firebase-operations-dashboard.md`
  - `docs/product/roadmap.md`
- If changing major UI surfaces, check whether the work also needs updates to:
  - `docs/product/ux-positioning.md`
  - `docs/product/ui-information-architecture.md`
  - `docs/ai/architecture-map.md`

## Before Finishing

- Review for hidden behavior changes.
- Check whether docs need to be updated:
  - `AGENTS.md`
  - `docs/ai/architecture-map.md`
  - `docs/ai/testing-strategy.md`
  - `docs/product/vision.md`
  - `docs/product/roadmap.md`
- Check whether the change increases information redundancy across tabs or repeats the same panel pattern without a clear reason.
- Check whether the change makes the app feel more like a generic productivity tool instead of a progression product.
- Check whether tests should be added or updated.
- Note any validation step that could not be run.
- If the work affects production readiness, state:
  - what was validated automatically
  - what still needs real-device smoke validation
  - what environment/release assumptions were made

## High-Risk Change Flags

Pause and review more carefully if the change includes:
- level or XP formula changes
- stat allocation changes
- quest reset behavior changes
- reward or entitlement rules implemented only in frontend state/controllers
- auth flow changes
- Isar schema changes
- package identifier changes
- Firebase project/environment changes
- account/session-management changes
- new animation-heavy UI
- new dependencies

## Change Summary Standard

Every substantial AI change should be summarized with:
- what changed
- why it changed
- what risk area it touched
- what was validated
- what still needs validation
