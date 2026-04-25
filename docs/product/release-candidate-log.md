# Release Candidate Log

## Purpose

Record release-candidate build attempts, exact artifact paths, validation results, and unresolved release blockers.

This log complements:
- `docs/product/release-checklist.md`
- `docs/product/release-environments.md`
- `docs/product/phase1-smoke-log.md`
- `docs/product/ui-smoke-checklist.md`

## Current Status

Latest candidate: `RC-internal-2026-04-25`

Status: `internal_validation_only`

Reason:
- Android staging/debug, production/debug, and production/release artifacts build successfully.
- Automated Flutter, Functions, and Firestore rules validation passes.
- Real-device smoke has not been recorded yet.
- `ASCEND_SUPPORT_EMAIL` still points to the placeholder `support@ascend.app` for this candidate.

## RC-internal-2026-04-25

Scope:
- internal release-readiness validation after Phase 2 loop-readiness closure
- no backend or Firestore rules behavior changed in this package
- support channel intentionally left as placeholder to keep the build blocked from external distribution

Build commands:
- `rtk flutter build apk --debug --flavor staging --dart-define=ASCEND_SUPPORT_EMAIL=support@ascend.app`
- `rtk flutter build apk --debug --flavor production --dart-define=ASCEND_SUPPORT_EMAIL=support@ascend.app`
- `rtk flutter build apk --release --flavor production --dart-define=ASCEND_SUPPORT_EMAIL=support@ascend.app`

Artifacts:
- staging debug: `build/app/outputs/flutter-apk/app-staging-debug.apk`
- production debug: `build/app/outputs/flutter-apk/app-production-debug.apk`
- production release: `build/app/outputs/flutter-apk/app-production-release.apk`

Automated validation:
- `rtk flutter analyze` - passed
- `rtk flutter test` - passed
- `rtk npm --prefix functions test -- --test-reporter=spec` - passed
- `rtk npm --prefix functions run test:rules` - passed

Environment notes:
- Android staging application id: `com.ascend.mobile.staging`
- Android production application id: `com.ascend.mobile`
- Firebase policy remains one shared project, `ascend-b7c20`, for controlled validation.
- Public/broad external distribution still requires a decision on whether production remains in the shared Firebase project or moves to a dedicated project.

Open blockers before external beta:
- replace `support@ascend.app` with a real monitored support channel through `ASCEND_SUPPORT_EMAIL`
- record real-device trust-critical smoke in `docs/product/phase1-smoke-log.md`
- record real-device visual/scroll-density smoke in `docs/product/ui-smoke-checklist.md`
- run the release candidate on a real authenticated build and record install, login, quest, account, logout, and session restore results

