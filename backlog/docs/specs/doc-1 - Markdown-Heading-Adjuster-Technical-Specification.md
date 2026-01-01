---
id: doc-1
title: Markdown Heading Adjuster Technical Specification
type: other
created_date: '2026-01-01 21:11'
---

# Markdown Heading Adjuster Technical Specification

## Overview
This document translates the PDD for the Markdown Heading Adjuster into a concrete technical plan. It defines the target architecture, modules, interfaces, and an implementation sequence that supports a testable core, a CLI surface, and a macOS app UI.

## Architecture Summary
Adopt a three-target structure with a pure core, a CLI wrapper, and a macOS app.

- `HeadingCore` (pure Swift module)
  - Markdown heading parsing and rebasing.
  - Deterministic, side-effect free.
- `HeadingCLI` (SwiftPM executable target)
  - Reads input from stdin or file, calls `HeadingCore`, writes to stdout.
  - Emits machine-readable inspection/debug output.
- `HeadingApp` (macOS app target, AppKit or SwiftUI)
  - Menu bar extra + floating palette.
  - Clipboard monitoring, preference storage, and paste automation.

Organize app source under `App/` per repo guidance.

## Data Model
Define core types in `HeadingCore`:

- `HeadingMatch`
  - `lineIndex: Int`
  - `columnIndex: Int`
  - `level: Int` (1-6)
  - `rawLine: String`
  - `title: String`
- `HeadingParseResult`
  - `headings: [HeadingMatch]`
  - `minLevel: Int?`
  - `maxLevel: Int?`
- `HeadingRebaseOptions`
  - `baseLevel: Int` (1-6)
  - `capLevel: Int` (default 6)
- `HeadingInspectSummary`
  - `minLevel: Int?`
  - `maxLevel: Int?`
  - `headings: [HeadingMatchSummary]`

`HeadingMatchSummary` is a lightweight, JSON-friendly struct with `line`, `level`, and `title`.

## Core Algorithms

### Heading Parsing
Input: full Markdown text as a `String`.

- Split into lines, preserving line order.
- For each line, apply regex `^(#{1,6})\\s+(.*)$`.
- On match:
  - `level = count(#)`
  - `title = trimmed capture group`
  - Record line and column index (column is the 0-based index of the first `#`).
- Return `HeadingParseResult` with min/max level.

Non-headings are left untouched and ignored in the parse result.

### Heading Rebase
Input: Markdown text, parse result, and `baseLevel`.

1. If no headings exist, return input unchanged.
2. Compute `offset = baseLevel - minLevel`.
3. For each heading line, compute `newLevel = min(max(level + offset, 1), capLevel)`.
4. Rewrite the heading line with `newLevel` hashes and the original title.
5. Reassemble lines with original newline separators.

### Inspect Output
`--inspect` returns a JSON object containing:

```
{
  "minLevel": 2,
  "maxLevel": 4,
  "headings": [
    { "line": 1, "level": 2, "title": "Intro" }
  ]
}
```

All numbers and strings should be deterministic and stable for automated tooling.

## CLI Specification

### Command
`heading-cli`

### Inputs
- `--input <path>` optional file path; if omitted or `-`, read stdin.
- `--base-level <1-6>` required for rebase mode.
- `--inspect` optional; emits JSON summary to stdout and exits 0.
- `--debug` optional; emits JSON lines describing parse and rebase steps to stderr (or a dedicated flag `--debug-output`).
- `--version` and `--help`.

### Behavior
- If `--inspect` is set, do not mutate output; only summary.
- For rebase:
  - Read input, parse, apply rebase, output to stdout.
- Exit codes:
  - `0` success.
  - `2` for invalid arguments.
  - `3` for input errors (file not found, unreadable).

## App Behavior

### Clipboard Monitoring
- Poll `NSPasteboard` change count on a small interval or use `NSPasteboard.PasteboardType.string` change observation.
- When new clipboard content is detected:
  - If text is Markdown with headings, update menu bar and palette state.
  - If not, show “No headings found” and disable actions.

### Menu Bar Extra
- `NSStatusItem` with a menu of base levels 1-6.
- Show detected levels (e.g., `H2, H3`).
- Selecting a level rebases and performs the user’s default action (copy/paste).

### Floating Palette
- `NSPanel` with a histogram, heading-level picker, and Copy/Paste actions.
- Opens when new valid Markdown is detected.
- Supports click vs shift-click behavior for copy vs paste.

### Paste Behavior
- Prefer `NSApp.sendAction(#selector(NSText.insertText(_:)))` for the frontmost app.
- If accessibility permission is missing, show a clear error and fall back to copy only.

### Preferences
Persist in `UserDefaults`:
- `lastBaseLevel`
- `defaultAction` (copy vs paste)
- `surfacePreference` (menu bar, palette, both)
- `launchPaletteOnStart` (bool)

## File/Module Layout

```
App/
  HeadingApp/
    AppDelegate.swift
    MenuBar/
    Palette/
    Clipboard/
  HeadingCore/
    Sources/
    Tests/
  HeadingCLI/
    Sources/
```

`HeadingCore` should be platform-agnostic and shared by CLI + app.

## Testing Strategy

- Unit tests (HeadingCore)
  - Parse tests: typical headings, Unicode titles, mixed content.
  - Rebase tests: all base levels 1-6, cap at 6, no headings.
- Golden tests
  - Inputs/outputs for representative Markdown files.
- Integration tests (CLI)
  - `swift run heading-cli` against fixtures.
  - Validate `--inspect` JSON schema.
- Manual tests (App)
  - Menu bar workflow.
  - Palette workflow.
  - Permission denied flows.

## Performance Targets
- Parse/rebase for <= 50kB input should complete < 50 ms.
- Clipboard polling should be low-overhead and not visible in Activity Monitor for typical use.

## Implementation Plan

1. Project scaffolding
   - Create SwiftPM package with targets `HeadingCore` and `HeadingCLI`.
   - Add `DEVELOPMENT.md` with standard commands.
2. HeadingCore
   - Implement parsing and rebasing.
   - Add unit and golden tests.
3. HeadingCLI
   - Implement CLI arguments and I/O.
   - Add `--inspect` and `--debug`.
4. App foundation
   - Create macOS app target under `App/HeadingApp`.
   - Add clipboard monitoring service.
5. UI surfaces
   - Menu bar extra with base-level actions.
   - Floating palette UI and behavior.
6. Paste integration and permissions
   - Accessibility permission checks.
   - Fallback messaging.
7. Final QA
   - Manual test checklist.
   - Accessibility and localization readiness.

## Resolved Decisions
- Clamp heading rebasing at level 1 (no base levels below 1).
- Support only ATX `#` headings; do not parse Setext headings.
- Emit `--debug` output to stderr by default.
- Floating palette auto-dismisses after actions.
- Global shortcut defaults to opening the picker (not repeating last action).

## Open Questions
- None.
