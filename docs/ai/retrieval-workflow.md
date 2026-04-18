# Retrieval Workflow

## Purpose

Use small, task-shaped context bundles instead of loading large parts of the repo.

## Inputs

The resolver uses:
- task type
- optional query
- codebase index
- entity catalog
- task manifest

## Supported Task Types

- `bug-fix`
- `feature-work`
- `refactor`

## Resolve Context

Example:

```powershell
powershell -ExecutionPolicy Bypass -File tools/knowledge/resolve-context.ps1 -TaskType feature-work -Query "streak quests player"
```

The script returns:
- base docs to read
- candidate code notes
- candidate entities

## Recommended Usage

1. resolve context for the task
2. read the base docs
3. read only the top-ranked code notes and entities
4. expand to source files only after that

## Rule

Do not load the whole vault by default.

The resolver exists to build a narrow starting context, not a complete world model.
