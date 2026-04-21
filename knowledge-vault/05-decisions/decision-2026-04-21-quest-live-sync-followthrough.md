---
type: decision
status: active
created_at: 2026-04-21T00:00:00-03:00
tags:
  - decision
  - quests
  - rank
  - ux
---
# Decision: Quest Live Sync Follow-Through

## Context

After competitive quest authority was introduced, two UX issues became visible:

- the elapsed-time helper in Quests could freeze because the screen had no live clock trigger
- rank refresh after a verified competitive completion could feel delayed because it still leaned on navigation-level debounce

There was also a perception issue:

- completed competitive quests could appear both in the active competitive section and in the completed section, which looked like two quests finishing at once

## Decision

- Quests now keeps a lightweight live time provider for in-progress competitive sessions
- completed competitive quests stay only in the completed section
- verified competitive completion triggers immediate competitive sync for rank and integrity

## Why

Competitive authority is not enough by itself. The player also needs the interface to confirm that the system reacted correctly.

## Consequences

- better trust in the quest-to-rank feedback loop
- less ambiguity when validating competitive flow in smoke tests
- future changes to Quests should preserve this live feedback behavior
