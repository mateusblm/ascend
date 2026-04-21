# Decision: Product Analytics Should Live Behind One App Service

## Context

Ascend now has enough product depth that instinct alone is not enough to guide retention and UX work.

We needed telemetry for:
- auth entry
- onboarding completion
- first-week setup
- quest creation and completion
- weekly boss claim
- promotion
- season reward claim

At the same time, we did not want Firebase Analytics calls spread across screens and widgets.

## Decision

Analytics now goes through a centralized wrapper:
- `lib/core/analytics/analytics_service.dart`

Feature code logs product-oriented events instead of talking to Firebase directly.

`main.dart` also wires the analytics navigation observer so screen-view telemetry can stay centralized.

## Why

This keeps the codebase cleaner and safer:
- feature code stays focused on product actions
- analytics vendor details stay localized
- tests can run against a no-op analytics implementation
- future event cleanup stays manageable

## Follow-up

- add crash reporting through the same boundary style
- define dashboards for the first-week funnel
- calibrate the event taxonomy after beta feedback
