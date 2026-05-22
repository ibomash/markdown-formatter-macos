# Agent Guide

- This repository currently focuses on planning documents for a macOS Markdown heading formatter app.
- Feature and planning specifications live under the `specs/` directory; consult its `AGENTS.md` for scope-specific notes.
- No code exists yet; when adding implementations, organize macOS app source under a dedicated directory (e.g., `App/`).
- Use Markdown (`.md`) for documentation unless otherwise specified.
- Use `DEVELOPMENT.md` as the single source of truth for build/test commands and workflows; when running tasks autonomously, read it first and follow its guidance instead of duplicating commands in task notes.
- For sandboxed test runs, use the dedicated command in `DEVELOPMENT.md` and keep any environment/setup steps aligned with that file.
- For a map of the codebase and how the pieces fit together, read `backlog/docs/doc-2 - Code-Overview.md` before making structural changes.
- Keep a tight testing loop: add tests with each change, run them immediately, and don’t leave failing tests behind.
- When starting a new task from Backlog, confirm it is sufficiently specified; if not, edit the task and/or create sub-tasks (parent-child) to outline the work, and keep task statuses updated as you work and complete items.
