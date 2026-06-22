# UI Surface Audit

## Purpose

Record the ownership audit for the main Ascend surfaces so future UI work does not reintroduce duplicated state across tabs.

This document is downstream from:
- `docs/product/ux-positioning.md`
- `docs/product/ui-information-architecture.md`
- `docs/product/game-system-design-plan.md`
- `docs/product/ui-redesign-phases.md`

Last updated: `2026-06-21`

## Current Ownership Map

### `Base`

Owns:
- player identity
- XP and immediate momentum
- build preview
- short weekly signal

Must not own:
- full competitive explanation
- seasonal leaderboard reading
- deep planning analytics

Current status:
- top-level ownership is correct
- arena-related reads are now kept in the detail directory instead of competing with the hero

Residual watch item:
- `Momento atual` should stay operational and compact, not drift into a second hero block
- remaining explanatory copy should move to sheet/detail when it does not change the immediate decision

### `Quests`

Owns:
- what can be done now
- active quest inventory
- action priority
- completion and validation flow

Must not own:
- account-progress recap already visible in `Base`
- competitive-system explanation already owned by `Arena`

Current status:
- hero owns counts and immediate execution state
- weekly-priority block now interprets the queue instead of reprinting the same counters
- current redesign direction reframes this surface as a mission terminal, not a task list

Resolved in this pass:
- removed duplicate command-deck counters that repeated the hero totals

Residual watch item:
- avoid turning suggestion and template panels into another analytics layer
- review CTA placement and list density so the create/add action never competes with bottom navigation
- completed quests should not dominate the main execution surface

### `Arena`

Owns:
- current competitive state
- maintenance pressure
- promotion or reconquest
- season race and legacy access

Must not own:
- generic profile summary
- build explanation unless it directly changes rank eligibility

Current status:
- hero owns current rank and weekly pressure
- detail directory owns `Agora`, `Temporada`, and `Legado`

Resolved in this pass:
- removed repeated rank emphasis between hero title, hero metrics, and legacy entry

Residual watch item:
- keep hero density under control on smaller devices when gate copy grows
- pressure, promotion, and reconquest should be readable without long rule explanations

### `Plano`

Owns:
- cadence
- weekly interpretation
- next-step planning
- deeper account diagnostics through detail views

Must not own:
- the same competitive pressure block from `Arena`
- the same build preview from `Base`
- duplicate weekly metrics in multiple top-level blocks

Current status:
- header is now lighter and leaves score/grade ownership to the weekly-read panel
- detail directory still cleanly separates overview, build, and week detail

Resolved in this pass:
- removed duplicated `Score` and `Grau` from the top header

Residual watch item:
- `Visao geral` and `Semana detalhada` remain semantically close and should be reviewed after device usage
- next pass should make `Plano` feel like a mentor recommendation, not another analytics dashboard

### `Conta`

Owns:
- player identity settings
- connected account visibility
- privacy, support, deletion, and logout

Must not own:
- gameplay analytics
- rank explanation
- progression dashboards

Current status:
- ownership is correct
- no major duplication issue found in this pass

Residual watch item:
- continue moving trust copy toward sentence case and calmer hierarchy as trust surfaces evolve

## Cross-Screen Findings

### Resolved now

- `Arena` no longer repeats the current rank in four same-weight places.
- `Quests` no longer reprints hero counters inside the weekly-priority block.
- `Plano` no longer repeats `Score` and `Grau` in both the header and the weekly-read block.
- `QuestCard` no longer crashes from mixed border colors with rounded corners.

### Still allowed by design

- `Base` may show a compact competitive pulse while `Arena` owns the competitive system in depth.
- `Plano` may reference competitive consequences only when explaining planning tradeoffs.
- `Quests` may reference rank impact only inside quest-execution context.

### Smells to reject in review

- the same number shown in two tabs with the same visual weight
- a top-level screen repeating another screen's hero in smaller cards
- action surfaces drifting into explanation surfaces
- diagnostic surfaces drifting into dashboard recap
- mission surfaces drifting back into generic to-do list cards
- body text explaining a state that could be expressed as a badge, CTA, or progress core

## Review Protocol

Before adding or changing a major card:
1. state which surface owns the concept
2. state whether the same concept already appears in another top-level tab
3. decide whether this surface is showing:
   - raw state
   - interpretation
   - action
4. reject the card if it only repeats a nearby block without changing meaning
5. check the density rules in `game-system-design-plan.md` before adding helper copy
