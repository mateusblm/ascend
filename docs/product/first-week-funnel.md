# First-Week Funnel

## Purpose

Track whether new players understand Ascend quickly enough to reach the first meaningful competitive loop.

This funnel is intentionally narrow. It should answer:

- do players finish onboarding?
- do they accept the starter kit?
- do they complete at least one quest?
- do they try at least one competitive quest?
- do they come back during the first week?

## Primary Funnel

1. `auth_login_succeeded`
2. `onboarding_completed`
3. `starter_kit_applied`
4. `quest_completed`
5. `competitive_quest_started`
6. `quest_completed` where `counts_toward_rank = true`
7. `weekly_boss_claimed` or `promotion_exam_started`

## First-Week Milestones

- Day 0:
  - login succeeds
  - onboarding completes
  - starter kit is applied
- Day 1:
  - first quest completed
  - first competitive quest started
- Day 3:
  - at least one competitive completion exists
  - player has returned after first session
- Day 7:
  - weekly boss claimed, promotion progress opened, or season progress clearly advanced

## Product Questions

Use the funnel to answer:

- where do new players stop?
- are players avoiding competitive quests?
- does the starter kit create action or only reading?
- are we guiding people into rank too early or too late?

## Operational Notes

- screen views should stay centralized through the analytics navigation observer
- product events should stay behind the app analytics wrapper
- crash data should be correlated with the same first-week path whenever possible
