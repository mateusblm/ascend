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
- backend command validation for reward-bearing actions
- aggregate updates after canonical fact writes

### Tier 2: Important Flows

- login state transitions
- account screen rendering and session visibility
- local profile edits such as player name updates
- cloud profile migration and account restore behavior
- active-session conflict handling between devices
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

Widget tests should prefer:
- critical actions and navigation entry points
- stable `Key` anchors for panels, CTAs, and stateful surfaces
- dynamic data that is part of the contract

Widget tests should avoid:
- decorative headlines and non-critical copy
- asserting the same metric wording across multiple tabs
- re-testing domain logic that already has unit coverage

### Integration Tests

Use sparingly for:
- startup flow
- auth flow
- account/session restore flow
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
32. promotion authority should keep Java backend behavior without requiring
    TypeScript fallback
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
44. quest UX should protect:
    - live elapsed-time helper during competitive sessions
    - no duplicate rendering of completed competitive quests
    - immediate rank/integrity refresh after verified competitive completion
45. account screen should protect:
    - connected-account visibility
    - player-name update
    - focus-change entry
    - logout CTA behavior
46. auth/session flow should protect:
    - logout -> return to login screen
    - restored session after app restart
    - account surface does not strand the user in an invalid signed-out UI state
47. pre-release smoke validation should protect the market-facing critical path:
    - login
    - onboarding
    - personal quest completion
    - competitive quest start and verification
    - rank/integrity refresh
    - account access
    - logout
    - session restore
48. release identity changes should be validated with extra care:
    - package identifier
    - Firebase environment selection
    - install/update behavior on a real device
49. account-backed player profile continuity should protect:
    - first login migration from local cache to remote profile
    - no automatic upload of an empty fresh profile
    - restored level/xp/streak/focus/onboarding on a second device
    - local cache remaining scoped to the signed-in uid instead of one shared device record
    - server-derived profile recomputation from quests does not drift after quest completion, undo, or weekly boss claim
50. account-backed quest continuity should protect:
    - first login migration from local quest cache to remote quest inventory
    - intentionally empty remote quests do not get repopulated from stale cache
    - starter kit and manual quest creation keep syncing across devices
    - local quest cache stays scoped to the signed-in uid
51. session and authority hardening should protect:
    - second device login is rejected while another active session is still valid
    - heartbeat/session refresh keeps the active device lease alive
    - profile sync uses the Java backend path instead of trusting client `level/xp/streak/history`
    - quest sync uses the audited Java backend path instead of direct client writes
    - competitive quest templates remain validated against official backend definitions during quest inventory sync
52. final progression architecture should protect:
    - frontend commands do not become the final authority for account progression
    - backend facts and aggregates stay aligned after personal quest completion
    - backend facts and aggregates stay aligned after personal quest revocation
    - backend facts and aggregates stay aligned after competitive quest verification
    - backend facts and aggregates stay aligned after weekly boss claim
    - attribute allocation updates the authoritative profile instead of only local UI state
    - Java backend responses are applied back into the local cache instead of local reward math running in parallel
    - full recomputation remains a repair/migration path, not the default production write path

## AI Test Rules

- If a change alters business rules, add or update tests in the same task when feasible.
- If tests cannot be added yet, state the exact missing coverage.
- Do not add shallow tests that only mirror implementation details.
- Prefer tests that describe expected behavior from the product perspective.
- When widget coverage is needed, prefer state/action assertions over decorative text checks.
- When backend authority replaces old local ownership, migrate tests toward domain, repository, rules, and authority boundaries instead of preserving stale local-flow assumptions.
- When a task touches release readiness, include both automated coverage and the exact manual smoke path still required.

## Validation Minimum For Critical Changes

For changes involving progression, quests, persistence, or auth:
- run relevant automated tests when environment allows
- confirm no known migration or config issue was introduced
- document unverified areas explicitly if tooling is unavailable

For changes involving account, release identity, Firebase environment, or live-service behavior:
- run relevant automated tests when environment allows
- run or explicitly queue real-device smoke validation
- confirm deployment/config target is unambiguous
- document exactly what is still unverified before calling the work production-ready
