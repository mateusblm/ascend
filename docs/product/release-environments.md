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

## Current Constraints

- the current Firebase project is shared by staging and production for now
- before public store launch, decide whether production should stay in this Firebase project or move to a dedicated production project
- before public store launch, register the real release SHA certificates for the production Android app if the keystore changes again
- iOS still depends on Xcode signing/provisioning being configured on the Mac that performs the archive

## Required Next Steps Before Store Submission

1. decide whether Firebase remains shared or splits into dedicated `staging` and `prod` projects
2. verify install, update, login, and Google Sign-In on real staging and production builds
3. configure iOS signing/provisioning in Xcode for `com.ascend.mobile`
4. move the keystore backup and password escrow to the final operational owner before store submission

## Operational Requirement

The keystore file and the credentials stored in `android/key.properties` must be backed up outside the repository before store submission.
