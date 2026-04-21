# Decision: First Week Guidance And Promotion Authority Should Move Together

Date: 2026-04-20

## Context

Ascend already had onboarding and competitive systems, but the product still had two gaps:

- the first week after onboarding was not guided enough inside the actual tabs
- promotion still leaned too hard on client-driven writes even though the project now has Blaze available

## Decision

We now treat these as one product track:

- Home and Quests surface a compact first-week loop after onboarding
- Home shows a compact payoff summary for next level, next rank, and current season
- promotion exam start and promotion confirmation now prefer callable backend paths before local fallback
- competitive Firestore collections move toward backend-written read models instead of client-owned documents

## Why

This makes the product easier to understand while also making the competitive layer harder to spoof in its most valuable steps.

## Files

- `lib/features/profile/domain/first_week_journey.dart`
- `lib/features/profile/domain/progress_payoff.dart`
- `lib/features/profile/presentation/home_screen.dart`
- `lib/features/quests/presentation/quests_screen.dart`
- `lib/features/profile/data/rank_progression_repository.dart`
- `functions/src/index.ts`
