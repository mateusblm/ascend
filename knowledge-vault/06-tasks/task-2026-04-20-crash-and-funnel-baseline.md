# Task: Crash And Funnel Baseline

## Goal

Make the app production-readable by combining:

- centralized product analytics
- centralized crash reporting
- an explicit first-week funnel

## Scope

- add Crashlytics wrapper
- wire fatal, async, and provider failures
- attach user context through auth
- document the first-week funnel for product review

## Follow-up

- add dashboard or reporting notes for the first-week funnel
- review early production errors against onboarding and competitive flows
- add targeted non-fatal reporting where we detect recoverable remote failures
