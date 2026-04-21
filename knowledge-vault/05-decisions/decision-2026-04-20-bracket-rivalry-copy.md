# Decision: Global Bracket Data Should Feel Like Rivalry, Not Just a Table

Date: 2026-04-20

## Context

Ascend already had seasonal score, global bracket standings, and podium data. The remaining UX problem was that the player could still read the system as a dashboard instead of a living dispute.

## Decision

We now translate bracket standings into a compact rivalry read-model:

- Home surfaces a short pressure card
- Rank season surfaces chase and pressure inside the seasonal layer
- the player sees who is ahead, who is threatening their spot, or whether they opened the race

## Why

This raises tension and retention without adding more raw system text or a heavier leaderboard wall.

## Files

- `lib/features/profile/domain/rank_rivalry.dart`
- `lib/features/profile/presentation/home_screen.dart`
- `lib/features/profile/presentation/rank_screen.dart`
