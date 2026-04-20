---
type: decision
status: active
source_note: [[competitive-quest-integrity]]
created_at: 2026-04-19T21:33:03.7642405-03:00
tags:
  - decision
  - quests
  - competitive
confidence: high
---
# Competitive Quest Split

## Decision

- separate quests into `personal` and `competitive`
- keep personal quests low-friction and XP-granting
- require official templates plus lightweight verification for quests that influence rank, boss, and season systems
- allow personal quests to grow `Level`, but never let them unlock competitive promotion by themselves
- keep personal quest XP below competitive template XP so the trustworthy path remains more rewarding

## Impact

- preserves a flexible habit loop for normal users
- protects leaderboard and rank integrity from unlimited self-reported quest spam
- gives Ascend a practical anti-fraud foundation without forcing heavy verification in v1

## Related Notes

- [[competitive-quest-integrity]]
- [[lib-features-quests-domain-quest-model-dart]]
- [[lib-features-quests-presentation-quest-controller-dart]]
- [[lib-features-profile-domain-player-model-dart]]
