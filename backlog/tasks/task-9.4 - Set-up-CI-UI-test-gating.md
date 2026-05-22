---
id: task-9.4
title: Set up CI UI test gating
status: Next
assignee: []
created_date: '2026-01-03 21:08'
updated_date: '2026-01-04 03:38'
labels: []
dependencies: []
parent_task_id: task-9
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Decide when palette UI tests run in CI vs local; document required environment and skip conditions.

Proposed gating:
- Default CI runs unit/integration tests only.
- Palette UI tests run when RUN_UI_TESTS=1 and Xcode is available.
- Menu bar tests remain local-only.
<!-- SECTION:DESCRIPTION:END -->
