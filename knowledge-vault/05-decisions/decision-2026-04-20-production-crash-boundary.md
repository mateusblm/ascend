# Decision: Production Crash Boundary

## Date

2026-04-20

## Decision

Ascend now treats crash reporting as a centralized production boundary, not as ad-hoc logging inside features.

The app should capture:

- Flutter framework fatal errors
- uncaught async zone failures
- Riverpod provider failures

Auth should also attach the signed-in user id to the crash boundary so production issues can be correlated with real player journeys.

## Why

The product is moving from internal iteration toward real-world validation. At this stage, silent failures and startup regressions are more dangerous than missing a small UI polish opportunity.

Crash reporting needs to be:

- centralized
- low-friction to maintain
- consistent with the analytics boundary already introduced

## Consequences

- `main.dart` owns the app-level error wiring
- `core/crash/crash_reporting_service.dart` is the only Crashlytics boundary the rest of the app should know about
- auth is responsible for attaching and clearing the current user id for crash correlation
- future production work should prefer this wrapper instead of direct Crashlytics calls
