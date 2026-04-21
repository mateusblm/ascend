# Release Environments

## Purpose

Define how Ascend should identify Android builds and how Firebase should be targeted before public distribution.

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

## Why This Policy Exists

- production should stop shipping with placeholder package identity
- staging should be installable alongside production
- Firebase should know which Android app is hitting the backend
- Google Sign-In should have explicit Android app registrations per flavor

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
```

## Current Constraints

- release build is still signing with the debug signing config until a real release keystore is introduced
- the current Firebase project is shared by staging and production for now
- before public store launch, decide whether production should stay in this Firebase project or move to a dedicated production project
- before public store launch, register the real release SHA certificates for the production Android app

## Required Next Steps Before Store Submission

1. introduce a real release keystore and stop shipping `release` with debug signing
2. register release SHA-1 and SHA-256 on the production Firebase Android app
3. decide whether Firebase remains shared or splits into dedicated `staging` and `prod` projects
4. verify install, update, login, and Google Sign-In on real staging and production builds
