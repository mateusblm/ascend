# Decision: First Session Should Teach Through Action

Date: 2026-04-20

## Context

Ascend already has strong progression systems, but the app was still feeling too much like an advanced MVP during the first session. New users had to infer too much:

- what is level
- what is rank
- what counts for competition
- what the first week will actually look like

## Decision

The first-session flow should teach the system through the starter week, not through dense explanation.

That means:

- onboarding previews the starter kit before confirmation
- onboarding explains level vs rank in simple language
- login reinforces the product loop in three short points
- focus changes preview the kind of quests the player will be nudged toward

## Why

This reduces product friction without weakening the deeper RPG systems.

## Files

- `lib/features/profile/presentation/awakening_onboarding_screen.dart`
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/profile/presentation/focus_selection_sheet.dart`
- `lib/features/quests/presentation/quest_controller.dart`
