---
type: project-note
status: active
created_at: 2026-04-19T21:33:03.7642405-03:00
tags:
  - product
  - quests
  - competitive
  - anti-fraud
---
# Competitive Quest Integrity

## Why This Exists

Ascend now separates the quest system into two tracks so the app can stay easy to use without letting the competitive layer turn into self-reported rank inflation.

## Core Rule

- personal quests keep the habit loop flexible and fast
- competitive quests use official templates and lightweight verification before they affect rank-facing systems
- personal quests may still increase `Level`
- competitive systems only read validated competitive activity
- personal quests stay in a lighter XP lane so they help motivation without becoming the dominant path to power

## Current Verification Layer

Competitive quests currently support:

- `timer`
- `timerWithReflection`

This keeps the first anti-fraud layer useful without forcing photo proof, location, or health integrations into every flow.

## Silent Trust Layer

Ascend now also computes a silent competitive integrity read-model.

It tracks:

- trust score
- trust band
- weekly active days
- weekly competitive days
- personal completions and XP today
- competitive completions and XP today
- suspicious pattern count

The current v1 is intentionally soft:

- it informs Home and Rank
- it does not hard-block progression yet
- it gives the team a calibration layer before stronger restrictions are introduced

## Competitive Systems That Depend On Verified Quests

- weekly boss progress
- rank maintenance pressure
- seasonal competitive standing
- rank promotion and reconquest eligibility

## Implementation Notes

- `QuestCategory.personal` continues to grant XP and attribute rewards
- `QuestCategory.competitive` must be verified before it counts toward competitive history
- player state now tracks:
  - `competitiveActivityHistory`
  - `lastCompetitiveQuestCompletionDate`
- weekly boss, rank maintenance, promotion, and rank arena now read competitive history directly
- integrity is evaluated separately and mirrored remotely so future season/ranking rules can use it safely

## Related Notes

- [[decision-2026-04-19-competitive-quest-split]]
- [[task-2026-04-19-competitive-quest-hardening]]
- [[lib-features-quests-domain-quest-model-dart]]
- [[lib-features-quests-presentation-quest-controller-dart]]
