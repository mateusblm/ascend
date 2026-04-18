# Prompt Templates

## Purpose

Use short, structured prompts that rely on repo memory instead of repeating the whole project context.

These templates are designed to work with:
- `AGENTS.md`
- `docs/ai/`
- `docs/product/`
- `knowledge-vault/`

## New Feature

```text
Implement [feature] in Ascend.
Focus on [feature area or files].
Preserve [existing behavior that must not change].
Follow AGENTS.md and docs/ai/*. Update docs if architecture changes and add tests for affected business rules.
```

## Bug Fix

```text
Fix [bug] in Ascend.
Start from [active file or feature area].
Keep the fix scoped and avoid unrelated refactors.
Call out the root cause, touched risk area, and what still needs validation if tooling is unavailable.
```

## Refactor

```text
Refactor [target area] to improve [goal].
Do not change product behavior unless explicitly required.
Keep the change incremental, update architecture docs if needed, and add tests if business rules become easier to protect.
```

## Performance Work

```text
Improve performance for [screen/flow].
Measure or reason about rebuilds, expensive work, and persistence access patterns.
Avoid premature abstraction. Keep behavior unchanged unless required.
```

## Schema Or Persistence Change

```text
Change [model/schema/persistence flow] in Ascend.
Treat progression and saved user data as sensitive.
Document migration risk, regenerate supported code artifacts, and update tests or validation notes.
```

## Product Planning

```text
Plan [feature or roadmap slice] for Ascend.
Use docs/product/vision.md and docs/product/roadmap.md as source of truth.
Return a proposal focused on retention, differentiation, or monetization impact.
```

## Retrieval-Friendly Prompt Shape

Prefer this shape:

1. objective
2. scope
3. guardrails
4. validation

Example:

```text
Add weekly streak tracking to quests.
Touch only player and quests layers unless necessary.
Preserve XP, level-up, and daily reset behavior.
Update docs if architecture changes and add tests for streak rollover logic.
```
