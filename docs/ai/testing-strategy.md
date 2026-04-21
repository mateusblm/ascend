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
- home screen boss panel states
- competitive rank sync metadata
- promotion exam transitions
- season summary and rank arena reads

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

Current competitive additions to protect:

6. rank maintenance and demotion unit tests
7. promotion exam serialization and status transitions
8. season reward/readiness summaries
9. remote boss arena pressure/read model
10. rank screen widget rendering
11. home screen widget states for active and idle online boss panels
12. daily reset rule and streak maintenance
13. weekly boss reward claim guard against duplicate weekly resgate
14. promotion UI states for exam start and rank confirmation
15. season leaderboard scoring and podium read-model
16. season reward payload rendering in Rank UI
17. season reward snapshot serialization and remote-safe schema
18. season reward claim lifecycle (`locked`, `readyToClaim`, `claimed`)
19. permanent season legacy/profile serialization
20. home/rank UI states that surface active seasonal title and legacy archive
21. hybrid rank progression rules:
    - level gate for upward movement
    - weekly maintenance for rank survival
    - reconquest flow after falling below peak rank
22. rank screen section switching (`Agora`, `Temporada`, `Legado`) and primary CTA visibility
23. personal quest completion still grants XP without influencing competitive history
24. competitive quest verification gates rank-facing credit:
    - timer must be started
    - timer must reach minimum duration
    - reflection must be supplied when required
25. duplicate official competitive templates should not create stacked open quests of the same template type
26. weekly boss and rank arena should prefer competitive activity history when available
27. personal-only activity must not unlock promotion or weekly boss completion
28. competitive integrity scoring should react to suspicious personal-only bursts without blocking honest competitive activity
29. home and rank should render integrity state without breaking their primary CTA flows
30. first-week journey summary should stay coherent for newly onboarded players
31. progress payoff summary should stay readable as level, rank, and season state changes
32. promotion authority should keep backend-first behavior without breaking fallback
33. prestige summary should react softly to low competitive integrity
34. season leaderboard summary should support backend-fed bracket standings
35. boss claim should not silently fall back to client-side writes in the competitive path
36. Home and Rank should surface bracket rivalry copy without breaking primary progression CTAs
37. analytics should stay behind one app-level wrapper instead of leaking Firebase calls across features
38. auth, onboarding, quests, weekly boss, and promotion flows should keep their event hooks close to the product action they represent
39. crash reporting should stay behind one app-level wrapper instead of wiring Crashlytics directly across features
40. app bootstrap should capture framework, async, and provider-layer failures without breaking startup
41. recoverable remote failures should be visible through non-fatal reporting on the critical competitive and weekly boss paths
42. competitive quest validation friction should remain measurable through product events instead of only UI copy
43. competitive quest authority should protect:
    - server-side session start
    - server-side completion grant
    - duplicate grant prevention
    - sync behavior when authoritative grants exist

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
