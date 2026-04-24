# UI Redesign Phases

## Purpose

Track the UI redesign as a phased workstream so future sessions can continue without re-auditing the whole app.

This document is downstream from:
- `docs/product/ux-positioning.md`
- `docs/product/ui-information-architecture.md`

When an AI agent changes major UI surfaces, read this file first.

## Active Visual Direction

Ascend should feel clear, calm, and progression-first.

The new shared pattern is:
- one dominant hero or summary per top-level screen
- fewer same-weight cards competing on screen
- lighter surfaces and borders instead of constant glow-heavy panels
- readable body typography first, expressive display typography only for short emphasis
- sentence-case copy for most headings, buttons, and helper text
- progressive disclosure through sheets or child screens instead of long explanation stacks

Avoid reintroducing:
- Orbitron-style display typography across all body copy
- all-caps labels everywhere
- repeated `panel + title + paragraph + metrics` blocks with the same visual weight
- decorative gradients or glows that carry more visual weight than the content
- long explanatory copy on top-level tabs when the next action can be shown directly

## Shared Implementation Pattern

Current implementation anchors:
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`

Rules for future UI work:
- use `AppTheme.dark()` as the source of truth for body typography, field styling, button shape, and snack bars
- add new tokens to `app_colors.dart` before scattering raw colors through feature screens
- treat bright accent colors as directional emphasis, not as default card fill
- prefer neutral surfaces (`surface`, `surfaceMuted`, `surfaceStrong`) for most containers
- only use display fonts for short titles, hero numbers, or momentary payoff states

## Phase Tracker

### Phase 0 - Audit and direction

Status: `completed`

Completed:
- audited `Base`, `Quests`, `Arena`, `Plano`, login, navigation, and shared theme
- compared current implementation with product docs and external HIG/usability guidance
- defined the redesign sequence before broad editing

### Phase 1 - Foundation visual

Status: `completed`

Completed:
- replaced the global display-heavy font approach with a readable app-wide theme
- introduced calmer color tokens for surfaces, borders, text hierarchy, and screen accents
- centralized the current visual foundation in `app_theme.dart`
- standardized default button, sheet, field, and snack-bar styling

Follow-up:
- migrate remaining top-level screens away from old heavy inline styles
- reduce repeated glow usage in navigation and detail screens

### Phase 2 - Quests redesign

Status: `completed`

Completed:
- rebuilt the `Quests` top-level screen around a clearer hero and action-first structure
- replaced the old heavy command deck with a lighter weekly-priority summary
- simplified section headers and list rhythm for `Arena`, `Base`, and `Concluidas`
- redesigned `QuestCard` to reduce chip noise and make the main action more obvious
- redesigned `AddQuestModal` to follow the same calmer pattern
- updated quest-reflection flow to match the new sheet styling

Follow-up:
- test the new list rhythm on small phones and larger devices
- tune copy if quest categories still feel too abstract in real usage

### Phase 3 - Base redesign

Status: `completed`

Completed:
- rebuilt `Base` around one identity/progression hero instead of multiple same-weight top-level panels
- moved payoff, competitive pulse, rivalry, streak, and weekly-event reads into a detail directory with sheets
- kept XP, focus, weekly signal, and build preview visible without reprinting the whole account story on the main scroll
- reduced arena-style emphasis bleed in the top-level `Base` surface

Follow-up:
- test hero metric wrapping and radar density on smaller phones
- tune the wording of `Momento atual` after real usage to keep it punchy without sounding abstract

### Phase 4 - Plano redesign

Status: `completed`

Completed:
- rebuilt `Plano` around a shorter header, one weekly-read block, and one next-step block
- reduced competitive bleed by removing rank-heavy emphasis from the top-level surface
- pushed broader diagnostics into quieter detail entries instead of repeating equal-weight panels
- softened local panel styling so `Plano` reads as reflective and operational instead of high-pressure

Follow-up:
- test the new top-level rhythm on shorter screens to confirm the two main panels remain above the fold when possible
- tune whether `Visao geral` and `Semana detalhada` still feel too close in real usage

### Phase 5 - Arena redesign

Status: `completed`

Completed:
- rebuilt `Arena` around one dominant summary hero instead of stacking another same-weight status panel under it
- clarified the split between `Agora`, `Temporada`, and `Legado` with simpler entry points and calmer card treatment
- made current risk, weekly objective, and next gate readable in the hero before opening a detail screen
- reduced accent overload in arena metrics and reusable cards so consequence still reads without glow-heavy chrome

Follow-up:
- test the new hero density on smaller phones when the current rank and gate copy both run long
- tune the exact wording of the hero summary after live usage so it stays tense without sounding abstract

### Phase 6 - Navigation and cross-screen cleanup

Status: `completed`

Completed:
- simplified the bottom navigation dock and moved it closer to the calmer shared surface system
- reduced ambient glow competition in the navigation shell
- rebuilt `DetailShellScreen` to match the lighter surface, border, and header pattern used by the redesigned top-level tabs

Follow-up:
- verify dock readability over extreme content contrast and keyboard transitions on smaller devices
- continue removing any leftover meta or implementation-facing UI copy that slipped into production strings

### Phase 7 - Login and onboarding cleanup

Status: `completed`

Completed:
- shortened the login surface so the main promise and the Google sign-in action are visible without a long explanatory stack
- moved onboarding toward one clear first decision: choose a focus, preview the starter kit, and begin
- kept onboarding contextual by replacing long setup explanation with a compact starter-kit preview and a persistent CTA
- aligned login and onboarding surfaces with the calmer shared theme instead of the older glow-heavy style

Follow-up:
- test first-session conversion on smaller phones to confirm the sticky onboarding CTA never feels cramped
- tune focus and starter-kit wording after real usage so the first week feels concrete without reading like setup text

## Continuation Protocol For AI

Before continuing this redesign:
1. read `docs/product/ux-positioning.md`
2. read `docs/product/ui-information-architecture.md`
3. read this file
4. inspect `lib/core/theme/app_theme.dart`
5. inspect the last completed phase before editing the next one

When finishing a redesign phase:
- update this file
- update `docs/ai/architecture-map.md` if the shared UI system changed
- update `docs/product/ui-surface-audit.md` if ownership changed
- update `docs/product/ui-smoke-checklist.md` if the manual path changed
- note what is complete vs what still needs tuning
