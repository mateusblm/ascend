# UI Density Audit

## Purpose

Turn the Ascend System UI direction into concrete screen-level cuts and
implementation decisions.

This document is downstream from:
- `docs/product/game-system-design-plan.md`
- `docs/product/ui-information-architecture.md`
- `docs/product/ui-redesign-phases.md`
- `docs/product/ui-surface-audit.md`

Last updated: `2026-06-21`

## Audit Rule

For every top-level screen, ask:
- what is the one decision the player must make first?
- which repeated metrics can become badges?
- which explanations can move to sheets or details?
- which blocks should disappear from the first fold?
- which visual pattern makes the screen feel like Ascend instead of a task app?

## Priority

1. `Quests`
2. `Base`
3. `Arena`

`Quests` goes first because it is the execution surface and has the highest risk
of looking like a generic task list.

## Quests Audit

### Current Role

`Quests` should answer:

> O que eu faco agora?

Current structure:
- terminal hero
- command deck
- return loop panel
- first-week panel, when active
- board selector
- suggestions/templates panel
- active list
- completed list

### Main Problem

The screen is directionally correct, but the first fold still behaves like a
stack of status panels before the player reaches the mission list.

This creates three mobile problems:
- the action surface starts too low
- counts appear in multiple places
- completed and suggested content can compete with active missions

### Keep

- `Quests` as a mission terminal.
- `Arena`, `Base`, and `Feitas` as board concepts.
- one visible add/create path.
- reward and verification signals on each quest.
- official competitive templates as a safe way to start Arena quests.

### Cut Or Move

#### Hero

Keep:
- terminal identity
- player or week signal
- active mission count
- one recommended next action

Cut or move:
- four equal summary tiles in the hero.
- completed count as a hero-level metric.
- secondary weekly/boss signal when it is not changing the next action.

Decision:
- hero should become `TerminalCommandHeader`.
- it should show one primary recommendation and two compact badges at most.

#### Command Deck

Current issue:
- repeats board counts already shown in hero and board selector.
- consumes vertical space before the actual missions.

Decision:
- remove as a standalone panel.
- move its CTA into the hero or into a compact command bar below the board
  selector.

#### Return Loop

Current issue:
- useful, but not needed before the player chooses or executes a quest.
- overlaps with `Base` and `Plano` ownership.

Decision:
- move below active list or into a `Sinais da semana` sheet.
- keep only one compact badge in the first fold when the weekly state is urgent.

#### First Week Panel

Current issue:
- important for onboarding, but it can become another status panel above the
  action surface.

Decision:
- keep only the next first-week step as hero recommendation.
- move the full checklist to a sheet opened by a small `Primeira semana` badge.

#### Board Selector

Current issue:
- useful, but it arrives after too many panels.

Decision:
- move directly under the hero.
- keep it compact and visually stable.
- counts stay here, not repeated in the hero and command deck.

#### Suggestions And Templates

Current issue:
- suggestions/templates can push active missions down.

Decision:
- show suggestions only when the selected board is empty or when the player taps
  `Nova quest`.
- competitive templates should open from `Abrir contrato de arena`, not sit as a
  full panel before existing Arena missions.

#### Quest Cards

Current issue:
- active cards are visually stronger, but still carry helper text inline.
- completed quests use the same card structure as active quests.

Decision:
- active `MissionCard` should show:
  - mission type badge
  - title
  - reward badges
  - current state
  - one primary CTA
- helper text should move to a details sheet or info action.
- completed quests should render as compact archive rows, not full mission cards.

#### Add Action

Current issue:
- the add action must never sit under or compete with bottom navigation.

Decision:
- no floating add button near the bottom nav.
- use a hero command or sticky-safe command bar above content.
- `Nova quest` opens a sheet with:
  - `Missao de base`
  - `Contrato de arena`
  - `Sugestoes`

### Quests Implementation Proposal

#### Step 1 - Terminal Header

Replace hero + command deck with:
- terminal label
- next action headline
- board counts as two or three small badges
- primary CTA: `Nova quest`, `Abrir primeira quest`, or `Continuar arena`

Acceptance:
- on a small phone, the player sees the main CTA and board selector without a
  long scroll.

#### Step 2 - Board Selector First

Move the selector immediately after the header.

Acceptance:
- switching between `Base`, `Arena`, and `Feitas` is available before any
  secondary panel.

#### Step 3 - Active Mission List

For selected board:
- show active missions first.
- show suggestions/templates only when empty or when explicitly requested.
- use compact empty states with direct CTA.

Acceptance:
- active missions are the dominant visual object on the screen.

#### Step 4 - Mission Card V2

Reduce each active card:
- no inline helper paragraph by default.
- reward and verification as badges.
- detail available by tap or info button.

Acceptance:
- each card fits title, reward, state, and CTA without feeling like a paragraph
  block.

#### Step 5 - Completed Archive

For `Feitas`:
- render compact archive rows.
- show date/status/reward if available.
- avoid full CTA-heavy cards.

Acceptance:
- completed quests feel like history, not another active mission list.

## Base Audit

### Current Role

`Base` should answer:

> Como esta meu personagem agora?

### Current Risk

The redesign already moved in the right direction, but the detail directory can
still grow into many equal-weight panels.

### Cuts

- Keep the first fold focused on level, XP, build, and next payoff.
- Move long build interpretations to `Abrir build`.
- Keep competitive pulse as one badge or short row, not a second Arena.
- Weekly boss can stay as a compact signal unless reward claim is available.

### Implementation Direction

- keep `System Header + Progress Core + Build Preview`.
- convert secondary reads to badges or detail entries.
- audit whether `Momento atual` still acts like a second hero.

## Arena Audit

### Current Role

`Arena` should answer:

> Estou seguro, em risco ou pronto para subir?

### Current Risk

Arena has many legitimate systems: rank, exam, maintenance, season, leaderboard,
legacy, integrity, boss. The risk is explaining all of them at once.

### Cuts

- make threat state the dominant first signal.
- keep leaderboard compact until opened.
- move integrity detail behind a detail entry unless it blocks an action.
- show legacy as archive, not as another main competition panel.

### Implementation Direction

- create/refine `Threat Meter`.
- express promotion/reconquest as a state, not a paragraph.
- reduce repeated rank labels across hero and cards.

## Plano Audit

### Current Role

`Plano` is no longer a top-level tab. Its useful content should answer, from a
secondary detail:

> Qual ajuste melhora minha semana?

### Current Risk

Plano can easily become another analytics dashboard, especially when it repeats
week score, active days, boss pressure, and build interpretation.

### Cuts

- one recommendation first.
- one weekly read second.
- no full boss replay from Arena.
- no full build replay from Base.
- deeper trend/history behind details.

### Implementation Direction

- expose only a compact `Recomendacao do sistema` from `Base` if needed.
- keep account access and attribute allocation in `Base`.
- collapse score/grade/delta into details rather than a top-level screen.

## Cross-Screen Decisions

- `Base` owns character state.
- `Quests` owns execution.
- `Arena` owns competitive consequence.
- planning detail owns interpretation and adjustment only on demand.
- `Conta` remains operational and calmer.

Repeated metrics are allowed only when the role changes:
- `Base`: compact signal.
- `Quests`: execution relevance.
- `Arena`: consequence.
- planning detail: interpretation.

## Next Implementation Batch

Title:
- Compactar Quests como terminal de missoes

Files:
- `lib/features/quests/presentation/quests_screen.dart`
- `lib/features/quests/presentation/widgets/quest_card.dart`
- tests under `test/features/quests/`

Scope:
- merge hero and command deck.
- move board selector up.
- move return loop and first-week checklist out of the first fold.
- make suggestions/templates demand-driven.
- introduce compact completed rows.

Non-goals:
- no backend change.
- no reward rule change.
- no new quest type.
- no full motion pass yet.

Validation:
- `flutter analyze`
- focused quest widget tests
- full `flutter test`
- Android smoke on small emulator viewport
