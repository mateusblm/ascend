# External Test Distribution Plan

## Purpose

Define how Ascend should move from an internal release candidate to controlled external testing without environment confusion.

## Current Status

Status: `not_ready_for_external_beta`

Current internal candidate:
- `RC-internal-2026-04-25`

Current blockers:
- real-device smoke is not recorded
- real-device UI/scroll-density pass is not recorded
- support email is intentionally ignored for now by operator decision, but remains a blocker before real external beta
- only Linux desktop is available in the current Codex environment, so mobile smoke cannot be completed here

## Distribution Stages

### Stage 0 - Internal RC

Audience:
- developer/operator only

Allowed artifact:
- `build/app/outputs/flutter-apk/app-production-release.apk`

Required before moving on:
- automated validation passes
- artifact path recorded
- known blockers documented

Current status:
- `completed` for `RC-internal-2026-04-25`

### Stage 1 - Controlled Device Smoke

Audience:
- developer/operator with real Android device

Required:
- install production release APK
- execute `docs/product/phase3-smoke-runbook.md`
- record `docs/product/phase1-smoke-log.md`
- record `docs/product/ui-smoke-checklist.md`
- confirm no unexpected Crashlytics fatal/non-fatal issues

Current status:
- `pending`

### Stage 2 - Closed External Test

Audience:
- small trusted tester group

Required before start:
- Stage 1 passes
- support channel is real and monitored
- operational owner and backup are named
- release notes tell testers this is a controlled validation build
- rollback path in `docs/product/live-risk-response.md` is understood

Current status:
- `blocked`

### Stage 3 - Broader External Beta

Required before start:
- no unresolved critical smoke issues
- support/deletion response expectation is published
- Firebase shared-project policy is explicitly accepted or split-project migration is completed
- screenshots/listing copy are ready if using a store-managed testing track

Current status:
- `blocked`

## Tester Instructions Template

Use for Stage 2 only after blockers are cleared:

```text
Ascend external validation build

Goal:
- validate login, first quest loop, competitive quest flow, and account/support surfaces.

Please test:
1. login
2. onboarding or restored account
3. create and complete one personal quest
4. start one competitive quest
5. open Base, Quests, Arena, Plano, Conta
6. logout and reopen the app

Report:
- device model
- Android version
- account used
- step that failed
- screenshot/video if possible
- whether the issue blocks continued testing
```

