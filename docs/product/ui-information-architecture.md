# UI Information Architecture

## Purpose

Define what each main surface in Ascend should own so the same information does not get repeated across multiple tabs.

## Main Navigation Roles

### `HOJE`

This is the emotional and operational snapshot of the account right now.

It should prioritize:
- who the player is right now
- XP and current momentum
- focus and build identity
- immediate weekly signal
- one-screen clarity

It should avoid:
- deep competitive explanation
- long historical summaries
- repeating the full analytical view from `ANALISE`

### `QUESTS`

This is the execution surface.

It should prioritize:
- what can be done now
- personal vs competitive action
- suggested next actions
- completion flow

It should avoid:
- re-explaining account progress already visible in `HOJE`
- deep rank analysis already owned by `RANK`

### `RANK`

This is the competitive command center.

It should prioritize:
- current competitive state
- maintenance pressure
- promotion or reconquest
- seasonal race
- weekly boss and competitive arena

It should avoid:
- generic profile summaries
- repeated player-build explanation unless it directly changes rank eligibility

### `ANALISE`

This is the reflective and planning surface.

It should prioritize:
- cadence
- weekly trend
- recovery or push plan
- actionable build management

It should avoid:
- reprinting the same weekly boss block from `RANK`
- reprinting the same build visualization from `HOJE`
- acting like a second home screen

### `CONTA`

This is the trust and settings surface.

It should prioritize:
- identity
- session
- support
- privacy
- profile settings

It should avoid:
- gameplay analytics
- rank explanation

## Duplication Rules

- A metric can appear in more than one place only if the role is different.
- `HOJE` may show a compact signal.
- `ANALISE` may show interpretation and planning.
- `RANK` may show the competitive consequence of the same metric.
- If two tabs show the same number in the same presentation style, that is usually a design mistake.

## Visual Differentiation Rules

- Do not use the same `panel + title + body + bar` composition for every major block.
- Each main surface should have a recognizable visual rhythm.
- `HOJE` should feel punchy and identity-driven.
- `QUESTS` should feel action-driven.
- `RANK` should feel high-pressure and competitive.
- `ANALISE` should feel quieter and more diagnostic.
- `CONTA` should feel stable and trust-oriented.

## Practical Design Guardrails

- If a new card is added, ask which existing surface already owns that concept.
- Prefer moving or reframing information instead of duplicating it.
- Prefer one strong hero block per screen instead of many equivalent blocks.
- Prefer varied component shapes and emphasis levels over uniform card repetition.
