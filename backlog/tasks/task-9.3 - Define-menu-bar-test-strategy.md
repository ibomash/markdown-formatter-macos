---
id: task-9.3
title: Define menu bar test strategy
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
Document local-only or opt-in automation for menu bar extra interactions; decide whether to use AX or XCUITest.

Proposed strategy:
- Keep menu bar tests local-only (opt-in) to avoid CI flakiness.
- Prefer AX-based scripts if XCUITest cannot reliably locate menu bar extras.
- Use accessibility identifiers on menu items to stabilize selectors.
<!-- SECTION:DESCRIPTION:END -->
