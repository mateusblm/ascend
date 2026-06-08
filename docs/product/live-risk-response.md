# Live Risk Response

## Purpose

Define how Ascend responds if an external test build shows a serious live regression.

This is intentionally lightweight. Do not build an admin console before the first external validation needs it.

## Current Risk Posture

Current status: `manual_response_ready`

Ascend does not yet have Remote Config feature flags or a dedicated kill-switch layer.

For the current controlled validation phase, risk response relies on:
- stopping distribution of the affected APK
- reverting or hotfixing code
- deploying backend fixes for Java/Cloud Run or Firestore rules regressions
- documenting the incident and smoke result before resuming distribution

Remote Config or a kill-switch layer should be added only when a specific risky behavior needs live toggling.

## Risk Categories

### Stop Distribution Immediately

Use when:
- login is broken for normal testers
- direct client writes become possible on authority-sensitive data
- personal quest completion grants duplicate or incorrect rewards
- competitive quest completion bypasses backend validation
- account/privacy/support surfaces are inaccessible
- the app crashes on launch or on core navigation

Action:
1. stop sharing the current artifact
2. mark the RC as blocked in `docs/product/release-candidate-log.md`
3. file a fix task with exact reproduction steps
4. run automated validation after fix
5. generate a new RC artifact
6. run real-device smoke again before distribution resumes

### Backend Hotfix

Use when:
- Firestore rules are too permissive or too restrictive
- Java backend validation rejects valid requests
- Java backend validation grants incorrect state
- weekly boss or rank aggregate behavior is wrong

Action:
1. deploy only the affected backend surface
2. run `cd backend && mvn test`
3. run `rtk npm --prefix functions run test:rules`
4. smoke the affected mobile path on device
5. record the fix in the RC log

### Mobile Hotfix

Use when:
- UI blocks core progression
- navigation sends users to the wrong top-level surface
- support/trust copy is incorrect
- the app targets the wrong Android flavor identity

Action:
1. patch mobile code
2. run `rtk flutter analyze`
3. run `rtk flutter test`
4. rebuild the affected artifact
5. record the replacement artifact path
6. repeat device smoke for the affected path

## Operational Review Cadence

During controlled external testing:
- check Crashlytics daily during the first 72 hours after distributing a new RC
- check Analytics first-week funnel daily during the first 72 hours
- after 72 hours, review twice weekly until the next RC

Owner:
- current owner: `product/engineering operator for the RC`
- before broader beta: replace this with a named human owner and backup

## Signals To Watch

Crashlytics:
- new fatal issues
- non-fatal groups:
  - `competitive_remote:*`
  - `weekly_boss_remote:*`
  - `competitive_quest_authority:*`
  - `riverpod:*`

Analytics:
- `auth_login_succeeded`
- `onboarding_completed`
- `starter_kit_applied`
- `quest_created`
- `quest_completed`
- `competitive_quest_started`
- `competitive_quest_blocked`
- `weekly_boss_claimed`
- `promotion_exam_started`
- `promotion_confirmed`
- `season_reward_claimed`

Manual reports:
- support inbox reports
- tester notes from device smoke
- screenshots or recordings attached to failed smoke steps

## Future Kill-Switch Direction

Do not add flags preemptively. Candidate flags, if needed:
- disable competitive template creation
- disable competitive completion verification entry points
- hide weekly boss claim action
- hide promotion confirmation action
- force read-only account mode during a known backend incident

Any future flag must include:
- default value
- owner
- rollout scope
- rollback instruction
- automated test or manual smoke step

