# Decision: Operational Dashboard And Recoverable Failures

## Date

2026-04-21

## Decision

Ascend should use Firebase as the first operational console for production review.

That means:

- Firebase Analytics / GA4 for product funnel reading
- Firebase Crashlytics for fatal and non-fatal operational issues

Recoverable failures on the most sensitive remote flows should be reported as non-fatal issues instead of being swallowed silently.

Competitive quest friction should also be visible through analytics events, especially when users are blocked by:

- duplicate competitive templates
- timer not started
- timer too short
- missing reflection

## Why

The app is moving toward production readiness. At this stage, silent fallback and invisible user friction become product risks.

We need:

- a shared place to inspect the health of releases
- a way to notice remote instability before it turns into user trust loss
- a way to distinguish comprehension problems from backend problems

## Consequences

- critical remote fallbacks now emit non-fatal operational reports
- competitive quest validation friction now emits analytics signals
- Firebase remains the primary operational console until a custom admin panel is actually justified
