# iOS Test Readiness

## Current iOS Identity

- bundle id: `com.ascend.mobile`
- Firebase iOS app id: `1:331143433117:ios:65993f0a204bbbaded3d74`
- Firebase project: `ascend-b7c20`

## Current Repository State

The repo now includes:

- production iOS bundle identifier aligned with Android production identity
- `ios/Runner/GoogleService-Info.plist`
- Google Sign-In URL scheme in `ios/Runner/Info.plist`

This is enough to build a production-signed iOS test build once Apple signing is configured in Xcode.

## Still Required On The Mac

Before sending to a tester, open `ios/Runner.xcworkspace` in Xcode and configure:

1. `Runner` -> `Signing & Capabilities`
2. choose the Apple Team
3. confirm `Bundle Identifier = com.ascend.mobile`
4. let Xcode create/update the provisioning profile

## Build Paths

### Local device build

```bash
flutter build ios --release
```

### Archive for TestFlight/manual distribution

1. open `ios/Runner.xcworkspace`
2. select `Any iOS Device (arm64)`
3. `Product` -> `Archive`

## Staging Note

A staging iOS Firebase app also exists:

- bundle id: `com.ascend.mobile.staging`
- Firebase iOS app id: `1:331143433117:ios:cd028de6003f9e65ed3d74`

The repo is currently wired for production iOS only. If staging iOS becomes necessary, add a second iOS target/scheme or an xcconfig-driven plist swap before using that app id.
