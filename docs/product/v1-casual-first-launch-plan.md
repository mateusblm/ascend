# V1 Casual-First Launch Plan

## Purpose

Define the reduced product scope for the first public version of Ascend.

The V1 should prove the core promise before exposing competitive systems:

> Complete small real-life missions, gain XP, improve attributes, and feel your
> character evolving every day.

## Product Decision

For the first public version:
- competitive quests are not visible in the catalog
- `Arena` is not a top-level navigation destination
- competitive backend, domain, and tests stay in the repository for a future
  expansion
- casual quests, XP, level, attributes, onboarding, account trust, and daily
  return are the launch experience
- weekly boss remains in V1 as a personal weekly boss, counting general active
  days instead of competitive evidence or rank pressure

This is a scope cut, not a feature deletion.

## Evidence Behind The Direction

The launch loop should prioritize:
- fast first-session activation
- small achievable goals
- self-monitoring and visible progress
- immediate feedback after completion
- positive reinforcement
- progressive disclosure instead of feature overload

Competitive pressure, leaderboards, evidence checks, and anti-fraud flows remain
valuable later, but they create extra failure modes for a first release.

## V1 Experience Pillars

### 1. One clear daily ritual

The user should understand the loop in less than one minute:
1. open Ascend
2. see current character state
3. complete or create one casual quest
4. receive XP/attribute feedback
5. know why returning tomorrow matters

### 2. Fewer surfaces, stronger clarity

Top-level navigation for V1:
- `Base`
- `Quests`

Hidden from V1 navigation:
- `Arena`

Secondary surfaces:
- `Conta` from `Base`
- build/attribute detail from `Base`
- quest detail from `Quests`

### 3. Game-system feeling without rule overload

The interface should feel like a personal progression system, not a task list.

Use:
- character state
- level/XP payoff
- attribute growth
- mission language
- compact system panels
- first-week journey
- personal weekly boss

Avoid:
- long explanations on top-level screens
- competitive jargon in the first release
- multiple equal-weight dashboards
- showing future systems before they are useful

## Phase Tracker

### Phase V1.0 - Scope Cut

Status: `in_progress`

Scope:
- hide `Arena` from main navigation
- hide competitive quest board and official competitive templates from Quests
- remove competitive creation from the add-quest modal
- make onboarding starter kit casual-only
- keep backend and domain code intact

Acceptance:
- a new user can only create and receive casual quests
- no visible V1 path starts a competitive quest
- no backend authority code is deleted
- existing competitive tests may remain as future-expansion protection

### Phase V1.1 - First Session Activation

Status: `planned`

Scope:
- tighten onboarding copy and first action
- make the first recommended quest visually dominant
- ensure starter kit has three simple casual missions
- route the user directly into a clear first completion path

Acceptance:
- the user can complete the first useful action without reading long setup text
- the first quest is obvious on small screens
- onboarding does not mention competitive systems

### Phase V1.2 - Completion Payoff

Status: `planned`

Scope:
- improve quest completion feedback
- make XP movement, level-up, and attribute gain more visible
- guide the user to spend available attribute points after level-up
- reduce completed-list noise after the reward moment

Acceptance:
- completing a quest feels like character progression, not checkbox clearing
- level-up and stat-point moments are hard to miss
- reward feedback stays short and mobile-friendly

### Phase V1.2b - Personal Weekly Boss

Status: `in_progress`

Scope:
- keep weekly boss as a personal weekly challenge
- count general active days from casual quest completion
- remove leaderboard/ranking language from the V1 boss surface
- keep remote competitive boss infrastructure for future Arena expansion
- use `POST /api/v1/weekly-boss/personal:claim` as the backend-authoritative
  resgate path for the V1 personal boss

Acceptance:
- the user sees a weekly boss without seeing competitive rank pressure
- boss progress advances from casual activity
- the V1 surface does not mention remote clears, podium, or competitive
  evidence
- reward authority is handled by Java before external distribution

### Phase V1.3 - Daily Return Loop

Status: `planned`

Scope:
- make today's recommended mission visible
- make tomorrow's reason to return visible
- simplify streak/weekly language around casual consistency
- use the personal weekly boss as the main weekly objective
- prepare notification/reminder copy without enabling aggressive prompts

Acceptance:
- `Base` and `Quests` each show one clear next action
- repeated metrics are collapsed into badges or details
- the app does not pressure the user with competitive loss language

### Phase V1.4 - Release Readiness

Status: `planned`

Scope:
- run full casual-flow smoke on emulator/device
- update release docs and screenshots around casual-first positioning
- confirm support/contact settings
- confirm Cloud Run Java backend smoke for casual commands

Acceptance:
- onboarding, casual quest creation, completion, revoke, XP, level, attributes,
  account, logout, and restore are validated
- store-facing copy does not promise Arena or competitive quests
- known competitive systems are documented as future expansion

## Future Expansion

Re-enable competitive systems only after V1 proves:
- users complete casual quests
- Day 1 and Day 7 retention are acceptable
- completion payoff feels good
- support and backend operations are stable

Potential future release:
- `Arena` returns as a season system
- competitive templates return gradually
- evidence adapters and anti-fraud become visible only after the casual loop is
  trusted
