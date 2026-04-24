# Release Environments

## Purpose

Define how Ascend should identify mobile builds and how Firebase should be targeted before public distribution.

## Current Policy

Ascend now uses one Firebase project for the current validation phase:

- Firebase project: `ascend-b7c20`

Inside that project, Android identities are now separated by flavor:

- `production`
  - application id: `com.ascend.mobile`
  - app label: `Ascend`
  - Firebase Android app id: `1:331143433117:android:71c7404432cda669ed3d74`
- `staging`
  - application id: `com.ascend.mobile.staging`
  - app label: `Ascend Staging`
  - Firebase Android app id: `1:331143433117:android:097ed08659aeb9f3ed3d74`

The legacy package `com.example.ascend` should now be treated as old local/dev identity, not as the long-term release identity.

For iOS, the current production identity is:

- bundle id: `com.ascend.mobile`
- Firebase iOS app id: `1:331143433117:ios:65993f0a204bbbaded3d74`

An iOS staging Firebase app also exists for future use:

- bundle id: `com.ascend.mobile.staging`
- Firebase iOS app id: `1:331143433117:ios:cd028de6003f9e65ed3d74`

The iOS repo wiring is currently production-only. There is no separate staging target/scheme yet.

## Explicit Environment Decision

Decision recorded on: `2026-04-23`

Phase 1 and current validation policy:
- Ascend will keep one shared Firebase project (`ascend-b7c20`) for the current controlled validation phase
- Android flavor separation remains the primary environment boundary right now
- this shared-project policy is acceptable for `Phase 1 - Core authority and trust`

Future boundary:
- before public store launch or broad external distribution, re-evaluate whether production must move to a dedicated Firebase project
- treat that re-evaluation as a `Phase 3 - Product reliability and release readiness` gate, not as an open `Phase 1` decision

## Current Release Signing State

Android release signing now supports a real keystore path through:

- local config file: `android/key.properties`
- example template: `android/key.properties.example`
- keystore path: `android/app/keystore/ascend-release.jks`
- key alias: `ascend-release`

The current production Firebase Android app now has the generated release fingerprints registered:

- SHA-1: `C1:23:A0:E6:97:2A:62:38:45:8B:D8:4E:46:A3:E5:B0:5C:85:FA:4B`
- SHA-256: `26:6C:C7:77:82:0B:C5:17:4D:A8:BE:3A:28:AF:53:3E:C0:D1:D2:0E:DE:72:42:AD:21:22:83:99:09:04:C8:CC`

## Why This Policy Exists

- production should stop shipping with placeholder package identity
- staging should be installable alongside production
- Firebase should know which Android app is hitting the backend
- Google Sign-In should have explicit Android app registrations per flavor
- iOS should stop shipping with the placeholder `com.example.ascend` bundle id
- iOS production should carry a real Firebase app registration and `GoogleService-Info.plist`

## Build Commands

Use explicit flavor commands from now on:

```powershell
# Run staging
flutter run --flavor staging

# Run production identity locally
flutter run --flavor production

# Build debug APKs
flutter build apk --debug --flavor staging
flutter build apk --debug --flavor production

# Build release APKs
flutter build apk --release --flavor production

# Build iOS release
flutter build ios --release
```

Support channel for release builds can also be provided through compile-time defines:

```powershell
flutter run --flavor staging --dart-define=ASCEND_SUPPORT_EMAIL=support@your-domain.com --dart-define=ASCEND_SUPPORT_LABEL="Email de suporte"
```

If no define is provided, the app falls back to the placeholder `support@ascend.app`.

## Current Constraints

- the current Firebase project is shared by staging and production by explicit decision for the current validation phase
- before public store launch, confirm whether the shared project remains acceptable or whether production moves to a dedicated project
- before public store launch, register the real release SHA certificates for the production Android app if the keystore changes again
- iOS still depends on Xcode signing/provisioning being configured on the Mac that performs the archive

## Required Next Steps Before Store Submission

1. confirm whether the shared Firebase project remains acceptable or splits into dedicated `staging` and `prod` projects before public launch
2. verify install, update, login, and Google Sign-In on real staging and production builds
3. configure iOS signing/provisioning in Xcode for `com.ascend.mobile`
4. move the keystore backup and password escrow to the final operational owner before store submission

## Operational Requirement

The keystore file and the credentials stored in `android/key.properties` must be backed up outside the repository before store submission.
