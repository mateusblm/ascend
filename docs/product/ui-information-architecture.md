# UI Information Architecture

## Purpose

Define what each main surface in Ascend should own so the same information does not get repeated across multiple tabs.

This document is downstream from `docs/product/ux-positioning.md`.

## Main Navigation Roles

## Final Navigation Labels

The intended player-facing labels are:
- `Base`
- `Quests`

These labels follow two goals:
- concise, scan-friendly top-level navigation
- language that frames Ascend as progression software instead of a generic to-do list

Secondary surfaces:
- `Conta`, opened from `Base`
- planning/recommendation details, opened from `Base` when needed
- `Arena`, hidden in V1 and reserved for a future competitive expansion

### `BASE`

This is the emotional and operational snapshot of the account right now.

It should prioritize:
- who the player is right now
- XP and current momentum
- focus and build identity
- immediate weekly signal
- personal weekly boss
- one-screen clarity
- access to deeper build detail through tap

It should avoid:
- deep competitive explanation
- long historical summaries
- becoming a full planning dashboard

Always visible:
- player identity
- XP and momentum
- build radar
- short weekly signal
- personal weekly boss progress
- account access

Tap to open:
- detailed attributes
- attribute allocation
- streak breakdown
- activity history
- advanced build interpretation
- account and trust controls

### `QUESTS`

This is the execution surface.

It should prioritize:
- what can be done now
- casual mission action
- suggested next actions
- completion flow

It should avoid:
- re-explaining account progress already visible in `BASE`
- exposing competitive systems in the V1 casual-first release

Always visible:
- actionable quest lists
- recommended next actions
- immediate state of each quest

Tap to open:
- quest detail
- edit or advanced quest controls
- reflection detail
- full reward breakdown

### `ARENA`

Hidden in V1. Keep this section as the future ownership target when competitive
systems return.

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

Always visible:
- current arena status
- maintenance pressure
- promotion or reconquest state
- current weekly competitive event

Tap to open:
- full leaderboard
- season reward breakdown
- legacy archive
- integrity detail

### `PLANO` Detail

This is no longer a top-level tab. The best planning content should appear as a
compact recommendation or detail launched from `BASE`.

It should prioritize:
- cadence
- weekly trend
- recovery or push plan
- actionable build management

It should avoid:
- reprinting the same weekly boss block from `ARENA`
- reprinting the same build visualization from `BASE`
- acting like a second home screen

Always visible:
- none as a top-level destination

Tap to open:
- historical trend
- deeper build allocation detail
- longer coaching or explanation
- past week breakdown

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
- `BASE` may show a compact signal.
- planning detail may show interpretation only after the player asks for it.
- `ARENA` may show the competitive consequence of the same metric.
- In V1, competitive metrics should not appear in top-level surfaces.
- If two tabs show the same number in the same presentation style, that is usually a design mistake.

## Visual Differentiation Rules

- Do not use the same `panel + title + body + bar` composition for every major block.
- Each main surface should have a recognizable visual rhythm.
- `BASE` should feel punchy and identity-driven.
- `QUESTS` should feel action-driven.
- `ARENA`, when re-enabled, should feel high-pressure and competitive.
- planning detail should feel quieter and more diagnostic.
- `CONTA` should feel stable and trust-oriented.

## Practical Design Guardrails

- If a new card is added, ask which existing surface already owns that concept.
- Prefer moving or reframing information instead of duplicating it.
- Prefer one strong hero block per screen instead of many equivalent blocks.
- Prefer varied component shapes and emphasis levels over uniform card repetition.
