---
id: doc-2
title: Code Overview
type: other
created_date: '2026-01-02 14:19'
---

# Code Overview

## Purpose
This repository contains a macOS Markdown heading formatter with three main surfaces:
1) A pure core library for parsing and rebasing headings.
2) A command-line tool that wraps the core.
3) A macOS app (menu bar + palette) that operates on clipboard text.

## Key Directories
- `Sources/HeadingCore`: Pure Swift module that parses headings, inspects heading metadata, and rebases heading levels.
- `Sources/HeadingCLI`: SwiftPM executable target for the CLI entry point and argument handling.
- `Tests/HeadingCoreTests`: Unit and golden fixture tests for the core.
- `App/HeadingApp`: macOS app target code (SwiftUI entry point, UI, clipboard monitoring, paste integration).
- `backlog/`: Planning docs, tasks, and decisions. See `backlog/tasks/` for current work items.
- `specs/`: Product and technical specs. Read `specs/AGENTS.md` for formatting rules.

## How It Works (High Level)
- `HeadingCore` exposes:
  - `parseHeadings` to scan Markdown text for ATX-style headings.
  - `inspectHeadings` to summarize heading levels and titles (JSON-friendly summaries).
  - `rebaseHeadings` to normalize heading levels to a new base.
- `HeadingCLI`:
  - Reads input from stdin or a file, then calls into `HeadingCore`.
  - Supports `--inspect` (JSON summary), `--debug` (JSON lines to stderr), and `--base-level` for rebasing.
- `HeadingApp`:
  - Uses a shared `AppModel` that monitors the clipboard and updates a `HeadingInspectSummary`.
  - Provides a menu bar extra to copy/paste rebased output at a chosen base level.
  - Provides a floating palette with a heading histogram, base-level picker, and clipboard preview.
  - Uses Accessibility permission checks for paste actions and falls back to copy if permission is missing.

## Where To Start
- For build/test/run commands and sandbox-safe workflows, use `DEVELOPMENT.md`.
- For the core APIs, start with `Sources/HeadingCore/HeadingCore.swift`.
- For the CLI surface, start with `Sources/HeadingCLI/main.swift`.
- For the app, start with `App/HeadingApp/HeadingApp.swift` and follow the `AppModel` and UI views.
