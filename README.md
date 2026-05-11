# Ascend

Ascend is a Flutter mobile app that turns daily tasks into RPG progression.
Users complete quests, earn XP, level up, and build a character through
strength, intelligence, vitality, and agility.

## Current Status

The project is in production-readiness work, not feature-sprawl mode.

Current focus:
- stabilize release and validation discipline
- keep progression and competitive rewards backend-authoritative
- close real-device smoke, support, and operational ownership gaps
- continue Competitive Verification V1 only where it strengthens Arena trust

Operational source of truth:
- `AGENTS.md`
- `docs/ai/source-of-truth.md`
- `docs/product/execution-tracker.md`
- `docs/product/phase-backlog.md`
- `docs/product/release-environments.md`

## Stack

- Flutter
- Riverpod with `StateNotifierProvider`
- Isar as local cache/offline persistence
- Firebase Auth with Google Sign-In
- Firestore and Cloud Functions for account and progression authority
- Firebase Analytics and Crashlytics through project wrappers
- Google Fonts and custom dark Material theme

## Structure

```text
lib/
|-- core/
|   |-- analytics/
|   |-- config/
|   |-- crash/
|   |-- database/
|   |-- navigation/
|   |-- theme/
|   `-- widgets/
|-- features/
|   |-- auth/
|   |-- profile/
|   |-- quests/
|   |-- weekly_boss/
|   `-- main_navigation_screen.dart
`-- main.dart

functions/
|-- src/
`-- test/

docs/
|-- ai/
`-- product/

knowledge-vault/
```

## Run

Use explicit flavors for mobile builds.

```powershell
flutter pub get
flutter run --flavor staging
flutter run --flavor production
```

Useful commands:

```powershell
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs

cd functions
npm ci
npm test
npm run test:rules
```

## Release Identity

Android no longer uses `com.example.ascend` as the release identity.

Current Android identities:
- production: `com.ascend.mobile`
- staging: `com.ascend.mobile.staging`
- legacy local/dev identity retained in Firebase config: `com.example.ascend`

iOS production identity:
- `com.ascend.mobile`

See `docs/product/release-environments.md` before changing package IDs,
Firebase apps, signing, or build flavors.

## Business Rules

- Personal quests can grant account XP through backend-authoritative commands.
- Competitive quests must pass backend verification before rank-facing progress.
- Isar is local cache/offline support, not final account authority.
- Backend command paths own reward-bearing mutations and profile aggregates.
- Daily reset behavior depends on `lastResetDate`.
- Isar generated files must not be edited manually.

## Local Validation Notes

Known environment prerequisites:
- Flutter tests with plugins require Windows Developer Mode or symlink support.
- Firestore rules emulator requires Java available on `PATH`.
- Functions are configured for Node 20; avoid validating production readiness on
  a mismatched Node runtime without recording the mismatch.

If validation cannot run because of environment setup, record the blocker in the
change summary instead of treating the suite as passed.
