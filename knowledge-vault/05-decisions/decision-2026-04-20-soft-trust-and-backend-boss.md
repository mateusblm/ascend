# Decision: Trust Should Soften Standing Before It Hard-Blocks Anything

Date: 2026-04-20

## Context

Ascend now has a silent integrity layer and a more authoritative competitive backend. The next product risk was overcorrecting too early:

- if trust stayed invisible, it would not protect the competitive layer enough
- if trust hard-blocked too early, it could punish honest users before calibration

At the same time, the weekly boss still had a local write fallback, which no longer matched the product goal of serious competition.

## Decision

We now apply trust softly before applying it harshly:

- prestige can be downgraded by weak integrity
- seasonal standing can be flagged as under review
- messaging can reflect reduced competitive weight

And on the backend side:

- weekly boss claim no longer falls back to direct client writes
- seasonal bracket leaderboard now has a backend-fed callable path

## Why

This protects the serious part of the game without adding surprise punishment too early.

## Files

- `lib/features/profile/domain/rank_prestige.dart`
- `lib/features/profile/domain/rank_season_leaderboard.dart`
- `lib/features/profile/presentation/home_screen.dart`
- `lib/features/profile/presentation/rank_screen.dart`
- `lib/features/weekly_boss/data/weekly_boss_repository.dart`
- `functions/src/index.ts`
