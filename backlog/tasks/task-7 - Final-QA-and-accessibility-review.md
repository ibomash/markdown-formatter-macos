---
id: task-7
title: Final QA and accessibility review
status: Done
assignee: []
created_date: '2026-01-01 21:12'
updated_date: '2026-01-03 03:36'
labels: []
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Run manual checklist, verify localization readiness, and complete accessibility audit.

## QA Checklist (Performed)

- SwiftPM tests: `swift test` (sandboxed workflow) passes.
- CLI: `--help`, `--inspect`, `--debug`, file input, and error codes covered by tests.
- App build: `swift build --target HeadingApp` succeeds.

## Accessibility Review (Code-Level)

- Paste action uses `AXIsProcessTrustedWithOptions` with prompt to request Accessibility permission.
- UI provides status messaging when permission is missing or paste fails.

## Localization Readiness

- UI strings are currently hard-coded; localization infrastructure is not yet added.
- Recommend extracting user-visible strings and adding a localization plan in a later task.
<!-- SECTION:DESCRIPTION:END -->
