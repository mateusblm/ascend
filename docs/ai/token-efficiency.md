# Token Efficiency Guide

## Purpose

Use AI aggressively, but do it with disciplined context management.

The goal is not to minimize tokens at all costs. The goal is to spend tokens where they improve correctness, speed, and decision quality.

## Core Rule

Prefer targeted context over broad context.

Bad:
- loading the whole repo for a small feature
- repeating the same architecture explanation in every prompt
- pasting long files when only one function matters

Good:
- read only the affected files first
- summarize stable project rules in docs and reference them
- expand context only when the task proves it is necessary

## Repo Strategy

Ascend should use a layered context model:

1. `AGENTS.md` for quick repo orientation
2. `docs/ai/` for stable rules and architecture
3. feature files for task-local implementation details
4. test files for behavior expectations

This keeps repeated instructions out of the chat and inside the repo.

## Practical Rules For AI Sessions

### Read Narrow, Then Expand

Start with:
- the active file
- directly related model, controller, and screen
- one relevant doc if the task affects product or architecture

Expand only if:
- behavior crosses feature boundaries
- persistence or auth is involved
- the first-pass context reveals hidden coupling

### Prefer References Over Repetition

Do not restate the whole product vision or architecture in every prompt.

Instead, reference:
- `docs/product/vision.md`
- `docs/product/roadmap.md`
- `docs/ai/development-charter.md`
- `docs/ai/architecture-map.md`

### Keep Outputs High Signal

Prefer:
- short plans
- concrete next steps
- concise diffs
- explicit risks

Avoid:
- long generic explanations
- repeated summaries of unchanged code
- file-by-file narration when grouped explanation is enough

### Create Stable Docs For Repeated Decisions

If the same instruction would be repeated across multiple AI sessions, move it into a repo document.

Good candidates:
- architecture constraints
- test priorities
- migration rules
- release checklists
- product principles

### Use Checklists For Repetitive Work

Checklists reduce tokens by replacing repeated reasoning with reusable guardrails.

Use:
- `docs/ai/change-checklist.md`
- `docs/ai/testing-strategy.md`

## When To Spend More Tokens

Spend extra tokens when:
- changing progression logic
- changing persistence behavior
- changing auth flow
- planning a multi-file refactor
- making product tradeoff decisions

These are high-leverage or high-risk areas where cheap context often causes expensive mistakes.

## Anti-Patterns

- asking AI to "improve the project" without scope
- pasting entire files when line-level context is enough
- mixing product strategy, implementation, and bug fixing in one large prompt
- using one session to cover unrelated features

## Recommended Prompt Shape

Use prompts with this structure:

1. objective
2. affected files or feature
3. constraints
4. validation expectation

Example:

```text
Add streak tracking to the quests feature.
Touch only the player and quests domain/presentation layers unless necessary.
Preserve current XP and level-up behavior.
Update docs if architecture changes and add tests for streak rollover logic.
```

## Project Rule

Optimize for total delivery efficiency, not raw token minimization.

A small amount of extra context is worth it when it prevents:
- broken behavior
- unsafe schema changes
- unstable architecture
- repeated rework
