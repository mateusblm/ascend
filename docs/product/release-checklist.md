# Release Checklist

## Purpose

Use this checklist before every meaningful production release.

The goal is simple:

- avoid shipping broken progression
- avoid shipping unreadable operational data
- make rollback and review easier

## Pre-Release

### Product

- confirm the target scope of the release in one sentence
- confirm which user-facing flows changed:
  - onboarding
  - quests
  - rank
  - weekly boss
  - season reward
- confirm whether copy, visuals, or behavior changed in any production-critical path

### Code

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- `cd functions && npm run build`

### Firebase

- deploy Firestore rules if the data model or authority boundary changed
- deploy Functions if callables or remote validation changed
- confirm the app is pointing to the correct Firebase project

### Production Signals

- confirm product analytics events still exist for the changed flow
- confirm Crashlytics remains wired at startup
- confirm new recoverable remote failures use the centralized crash boundary instead of silent swallow

### Competitive Safety

- confirm competitive quests still require backend validation
- confirm weekly boss claim stays backend-only
- confirm promotion and season reward flows still prefer callables
- confirm rank/integrity sync still uses source-based backend evaluation

## Release-Day Smoke Test

Run these on a real authenticated build whenever the release touches progression:

1. login
2. onboarding or focus selection path if changed
3. create one personal quest
4. start one competitive quest
5. complete one competitive quest
6. open Home, Rank, Quests, Stats
7. trigger weekly boss panel if available
8. confirm no obvious Crashlytics-worthy failure appears in flow

## Post-Release Review

Check within the first hours after deploy:

- Crashlytics fatal issues
- Crashlytics non-fatal groups:
  - `competitive_remote:*`
  - `weekly_boss_remote:*`
  - `competitive_quest_authority:*`
  - `riverpod:*`
- Analytics first-week funnel
- competitive quest blocked reasons

## Questions To Answer After Release

- did onboarding completion move?
- did competitive quest starts move?
- did competitive quest completions move?
- did non-fatal remote failures increase?
- did the release improve the intended metric without increasing trust risk?
