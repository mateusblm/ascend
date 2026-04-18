# Testing Strategy

## Purpose

Protect the systems that define user trust and product value.

Ascend does not need exhaustive tests everywhere. It needs strong protection around business rules, persistence-sensitive behavior, and user-critical flows.

## Test Priorities

### Tier 1: Must Protect

These rules should have automated coverage first:
- XP gain from quest completion
- level-up thresholds and rollover XP
- stat point gain on level-up
- stat increase and rollback behavior
- daily quest reset behavior
- reward removal when unchecking a completed quest

### Tier 2: Important Flows

- login state transitions
- quest list rendering
- add quest flow
- delete quest flow
- level-up feedback flow

### Tier 3: Nice To Have

- visual regression coverage for key screens
- chart and analytics rendering
- onboarding journey setup

## Recommended Test Types

### Unit Tests

Use for:
- progression calculations
- reset rules
- attribute allocation rules
- quest completion side effects

Keep unit tests focused on deterministic business logic.

### Widget Tests

Use for:
- login screen state rendering
- quest screen interactions
- stats and progression UI states

Prefer widget tests over broad integration tests when the behavior can be validated locally.

### Integration Tests

Use sparingly for:
- startup flow
- auth flow
- persistence-sensitive journeys that cross multiple screens

## Current Recommended Test Plan

Start with:

1. player progression unit tests
2. quest completion and rollback unit tests
3. daily reset unit tests
4. login widget test
5. quests screen widget test

## AI Test Rules

- If a change alters business rules, add or update tests in the same task when feasible.
- If tests cannot be added yet, state the exact missing coverage.
- Do not add shallow tests that only mirror implementation details.
- Prefer tests that describe expected behavior from the product perspective.

## Validation Minimum For Critical Changes

For changes involving progression, quests, persistence, or auth:
- run relevant automated tests when environment allows
- confirm no known migration or config issue was introduced
- document unverified areas explicitly if tooling is unavailable
