# UX Positioning

## Product Stance

Ascend must not feel like a generic to-do list with RPG decoration.

Ascend is a progression app first:
- the player is the center
- quests are the input layer
- build, momentum, risk, season, and legacy are the payoff layer

The product should feel closer to:
- character progression
- weekly campaign pressure
- competitive upkeep
- build identity

It should feel less like:
- task filing
- inbox management
- neutral productivity dashboards

## Design Principles

These principles are intentionally influenced by Apple interface guidance:
- use bottom navigation only for true top-level areas
- keep labels concise and scan-friendly
- prefer progressive disclosure over infinitely long screens
- use drill-down and sheets for detail instead of showing every detail at once
- keep hierarchy obvious and stable

Primary reference patterns:
- Apple HIG: `Tab bars`
- Apple HIG: `Lists and tables`
- Apple HIG: `Sheets`
- WWDC22: `Explore navigation design for iOS`

## Core Experience

The emotional center of Ascend is not:
- task completion

The emotional center of Ascend is:
- who the player is becoming
- what shape their build is taking
- whether the week is under control
- whether the arena is safe or dangerous

## Navigation Direction

The intended top-level navigation is:
- `Base`
- `Quests`
- `Arena`
- `Plano`

Why:
- `Base` frames the player as a character, not as a list owner
- `Quests` keeps execution explicit and direct
- `Arena` frames competitive pressure as its own destination
- `Plano` frames reflection as action-oriented guidance, not just analytics

## Disclosure Strategy

Ascend should not solve information architecture by stacking more panels in one scroll.

Preferred order of disclosure:
1. show the strongest signal first
2. let the player tap for deeper breakdown
3. use a sheet for short contextual detail
4. use a child screen for dense or persistent detail

## Anti-Pattern

If a new screen or block feels interchangeable with a productivity app dashboard, stop and re-evaluate.

Questions to ask:
- does this increase the sense of progression?
- does this reinforce build, momentum, rivalry, or payoff?
- does this belong on the main surface, or should it open on tap?
- is this a game-like state read, or just task admin?
