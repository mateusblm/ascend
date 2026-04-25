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
- `flutter build apk --debug --flavor staging`
- `flutter build apk --debug --flavor production`
- `flutter build apk --release --flavor production`
- `cd functions && npm run build`
- `cd functions && npm run test:rules`

### Firebase

- deploy Firestore rules if the data model or authority boundary changed
- deploy Functions if callables or remote validation changed
- confirm the app is pointing to the correct Firebase project
- confirm the Android flavor matches the intended Firebase app identity
- confirm the production Firebase Android app has the current release SHA registered

### Production Signals

- confirm product analytics events still exist for the changed flow
- confirm Crashlytics remains wired at startup
- confirm new recoverable remote failures use the centralized crash boundary instead of silent swallow
- confirm support/privacy/deletion surfaces still reflect the current operational policy
- confirm `ASCEND_SUPPORT_EMAIL` is set to a real monitored channel for the target release when distributing beyond controlled internal validation

## Candidate Records

- `docs/product/release-candidate-log.md`

Latest recorded candidate:
- `RC-internal-2026-04-25`
- Android artifacts built successfully for staging debug, production debug, and production release
- automated validation passed
- external distribution remains blocked by placeholder support email and missing real-device smoke evidence

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
7. open Conta and verify:
   - connected account visibility
   - policy/support visibility
   - logout behavior
8. trigger weekly boss panel if available
9. confirm no obvious Crashlytics-worthy failure appears in flow

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
