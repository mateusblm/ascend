# Source Of Truth Map

## Purpose

Define which files future AI sessions and contributors should trust first.
This file exists because the repository has useful documentation, but some of it
is historical, cumulative, or generated for memory retrieval.

## Trust Order

1. Current code and tests.
2. `AGENTS.md`.
3. Active control docs listed in this file.
4. Product and architecture reference docs.
5. `knowledge-vault/` memory notes.
6. Raw or normalized chat history.

If these sources disagree, trust the higher item in the order and update the
lower source only when the mismatch affects future work.

## Start Here

Read these for most tasks:
- `AGENTS.md`
- `docs/product/execution-tracker.md`
- `docs/product/phase-backlog.md`
- `docs/product/project-plan.md`
- `docs/ai/quality-gates.md`

For release or production-readiness work, also read:
- `docs/product/release-environments.md`
- `docs/product/release-checklist.md`
- `docs/product/phase3-smoke-runbook.md`
- `docs/product/phase1-smoke-log.md`
- `docs/product/ui-smoke-checklist.md`

For progression, reward, quest, or competitive authority work, also read:
- `docs/product/progression-architecture.md`
- `docs/product/competitive-verification-v1.md`
- `docs/ai/architecture-map.md`
- `docs/ai/testing-strategy.md`

For UI/navigation/surface ownership work, also read:
- `docs/product/ux-positioning.md`
- `docs/product/ui-information-architecture.md`
- `docs/product/ui-surface-audit.md`
- `docs/product/ui-redesign-phases.md`

## Current Reference Docs

These documents are current and useful, but they are not execution trackers:
- `docs/product/roadmap.md`
- `docs/ai/architecture-map.md`

Use them for direction and boundaries. Use `execution-tracker.md` and
`phase-backlog.md` for active status.

## Process And Memory References

These are useful, but they are not the fastest operational entry point:
- `docs/ai/development-charter.md`
- `docs/ai/token-efficiency.md`
- `docs/ai/prompt-templates.md`
- `docs/ai/retrieval-workflow.md`
- `docs/ai/knowledge-memory-system.md`
- `docs/ai/obsidian-vault-operations.md`

Current handling:
- prefer adding current-state facts to `execution-tracker.md` or
  `phase-backlog.md` instead of duplicating them across many docs

## Work Package Briefs

These documents are useful for a specific work package and should be archived,
deleted, or folded into durable docs once their package is complete:
- `docs/ai/work-packages/competitive-verification-v1-next.md`
- `docs/ai/work-packages/java-backend-migration-plan.md`
- `docs/ai/work-packages/java-backend-callable-inventory.md`

Do not treat work-package briefs as permanent architecture. The Java migration
briefs are now historical/post-migration references; current backend authority
is documented in `docs/ai/architecture-map.md`,
`docs/product/progression-architecture.md`, and `backend/README.md`.

## Knowledge Vault Policy

`knowledge-vault/` is retrieval memory, not source of truth.

Use it to recover context or find related files, but verify claims against:
- current source files
- current tests
- the active control docs above

Generated codebase notes under `knowledge-vault/02-codebase/` and entity notes
under `knowledge-vault/04-entities/` can become stale whenever code changes.

## Current Active State

As of `2026-06-07`:
- Java/Spring Boot on Cloud Run is the authoritative backend for active product
  behavior.
- The local TypeScript Firebase Functions project was removed.
- Flutter no longer uses `cloud_functions` or TypeScript fallback paths.
- remaining post-migration cleanup:
  - delete/decommission any remotely deployed Firebase Functions if they still
    exist in the Firebase project
  - run a final staging smoke after remote cleanup
  - keep release docs aligned with Java/Cloud Run operations
- external beta still requires the normal release-readiness evidence:
  - real support channel ownership
  - recorded real-device smoke pass
  - operational owner and backup assignment
