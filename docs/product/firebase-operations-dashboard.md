# Firebase Operations Dashboard

## Purpose

Give the team one simple place to look when validating the product in production.

Use Firebase for the first operational pass. Do not build an admin panel yet unless support, moderation, or fraud review starts demanding it.

## Where To Look

### Analytics

Use:

- Firebase Console
- Google Analytics 4 linked to the same project

Main views:

- Realtime
- DebugView
- Events
- Explorations

### Crash Reporting

Use:

- Firebase Crashlytics

Main views:

- issue list
- fatal vs non-fatal split
- affected users
- app version
- recent regressions

## First-Week Funnel

Read these events in order:

1. `auth_login_succeeded`
2. `onboarding_completed`
3. `starter_kit_applied`
4. `quest_completed`
5. `competitive_quest_started`
6. `quest_completed` with `counts_toward_rank = true`
7. `weekly_boss_claimed` or `promotion_exam_started`

Related guide:

- `docs/product/first-week-funnel.md`

## Operational Questions

Check these every time we release a meaningful onboarding, quests, or rank change:

- are users finishing onboarding?
- are users starting at least one competitive quest?
- are users completing at least one competitive quest?
- are users reaching the first weekly payoff?
- are there recoverable remote failures increasing after deploy?

## Non-Fatal Review

Watch these recoverable failure groups in Crashlytics:

- `competitive_remote:*`
- `weekly_boss_remote:*`
- `competitive_quest_authority:*`
- `riverpod:*`

These should help us spot:

- Java backend instability
- Cloud Run or Firebase integration regressions
- provider-layer regressions after release

## Suggested Weekly Review

1. Check Crashlytics for new fatal issues.
2. Check non-fatal growth in competitive and boss flows.
3. Check the first-week funnel drop-offs.
4. Compare onboarding completion against competitive quest starts.
5. Review whether remote failures correlate with any funnel drop.

## Controlled External Testing Cadence

During the first 72 hours after distributing a new RC:

- review Crashlytics daily
- review Analytics first-week funnel daily
- check tester reports daily
- stop distribution immediately for launch crashes, login failure, duplicate reward risk, or competitive authority bypass

After 72 hours:

- review twice weekly until the next RC
- review immediately after any backend deploy or mobile hotfix

Current owner:
- `product/engineering operator for the RC`

Before broader beta:
- replace the owner placeholder with a named human owner and backup
- confirm who watches support requests and who can stop distribution

Related:
- `docs/product/live-risk-response.md`
- `docs/product/phase3-smoke-runbook.md`
- `docs/product/release-candidate-log.md`
