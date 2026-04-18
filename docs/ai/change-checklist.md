# AI Change Checklist

## Purpose

Use this checklist before, during, and after any AI-assisted code change in Ascend.

## Before Editing

- Confirm the feature area being changed.
- Read the relevant model, controller, and screen files.
- Read `AGENTS.md` and any related file in `docs/ai/` or `docs/product/` if the change affects architecture or behavior.
- Identify whether the change touches a critical system:
  - progression logic
  - quest completion
  - daily reset
  - auth
  - persistence
- Prefer the smallest safe implementation that solves the request.

## During Editing

- Keep edits scoped to the request.
- Avoid broad cleanup unless it directly reduces risk in the touched code.
- Preserve behavior unless the user explicitly asked for behavior change.
- Keep naming and file placement consistent with the current architecture.
- Avoid adding dependencies unless clearly justified.
- If changing an Isar model, treat it as a schema change and call it out explicitly.
- If changing Android identifiers or Firebase-related setup, verify the configuration impact before proceeding.

## Before Finishing

- Review for hidden behavior changes.
- Check whether docs need to be updated:
  - `AGENTS.md`
  - `docs/ai/architecture-map.md`
  - `docs/product/vision.md`
  - `docs/product/roadmap.md`
- Check whether tests should be added or updated.
- Note any validation step that could not be run.

## High-Risk Change Flags

Pause and review more carefully if the change includes:
- level or XP formula changes
- stat allocation changes
- quest reset behavior changes
- auth flow changes
- Isar schema changes
- package identifier changes
- new animation-heavy UI
- new dependencies

## Change Summary Standard

Every substantial AI change should be summarized with:
- what changed
- why it changed
- what risk area it touched
- what was validated
- what still needs validation
