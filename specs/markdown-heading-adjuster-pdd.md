# Markdown Heading Adjuster PDD

## Overview
A lightweight macOS utility that reformats Markdown headings on the clipboard so their hierarchy nests under a chosen base level. Targeted at writers and developers who frequently paste Markdown into documentation systems that require consistent heading levels.

## Goals
- Offer a one-click (or keyboard-first) workflow to normalize heading levels on clipboard Markdown.
- Provide clear feedback about detected heading structure before and after adjustment.
- Support output either to the clipboard or by pasting directly into the frontmost app.
- Remember the most recently used heading level and interaction surface.
- Expose core functionality through a scriptable CLI and maintain a testable, modular architecture to support automated and LLM-driven development workflows.

Secondary goal: Design the architecture so it can be safely modified and tested by automated tooling (LLM agents) via a clear CLI and strong automated tests.

## Non-Goals
- Building a full Markdown editor or previewer.
- Persisting documents or maintaining history beyond the current clipboard contents.
- Supporting non-Markdown formats (e.g., HTML, RTF).

## User Stories & Scenarios
- As a technical writer, I want to copy Markdown from another tool and quickly align its headings under `##` so that it fits within an existing document section.
- As a developer, I want to trigger the adjustment via keyboard shortcut and paste immediately into Notes without leaving the target app.
- As a product manager, I want to confirm which heading levels are present before modifying them so I can avoid unexpected changes to non-heading text.
- Edge case: Clipboard contains Markdown without headings; the app should surface a non-destructive message and leave the text untouched.

## User Experience
- **Primary surfaces**
  - *Menu bar extra*: displays detected heading levels (e.g., `H2, H3`) and offers submenu actions for levels 1-6. Selecting a level adjusts the clipboard and either copies or pastes based on user preference.
  - *Floating palette*: toggleable mini-window showing a live heading histogram, star-style level picker (`#` to `######`), and buttons for “Copy adjusted” or “Paste adjusted”. Palette auto-detects clipboard changes and updates feedback; it pops up when it detects new Markdown-formatted text on the clipboard with section headings. Click vs shift-click to copy back to clipboard vs auto-paste into frontmost window.
- **Activation & feedback**
  - Global keyboard shortcut opens level picker overlay or performs last-used action immediately (configurable).
  - Status toasts confirm copy/paste success and show the resulting base level (e.g., “Headings nested under H3”).
  - When no headings are detected, UI shows “No headings found” and disables action buttons.
- **Settings**
  - Preferences pane (minimal) allows choosing default action (copy vs paste), enabling floating palette on launch, and toggling menu bar presence.

## Functional Requirements
1. Detect clipboard updates while app is running and parse Markdown for headings `#`–`######`.
2. Compute lowest heading level and rebase all headings so the lowest becomes the selected base level, capping at level 6 (per reference algorithm).
3. Provide UI surfaces:
   - Menu bar extra with submenus for base levels 1–6, showing dynamic availability based on detected headings.
   - Floating palette with live preview and star-style picker (optional, user toggled).
4. Support actions:
   - Copy adjusted Markdown back to clipboard.
   - Paste adjusted Markdown into the frontmost app using accessibility APIs when permitted.
5. Persist user preferences (last-used level, chosen surface, default action) via `UserDefaults`.
6. Handle error states gracefully: clipboard access denied, paste permission denied, non-text clipboard content.
7. Localization-ready strings for UI labels and status messages.
8. Provide a command-line interface (CLI) that:
  * Accepts Markdown input via stdin or file.
  * Applies the same heading detection and rebasing logic as the app.
  * Outputs adjusted Markdown to stdout, with an optional `--inspect` mode that emits a machine-readable summary of detected headings.

## Non-Functional Requirements

* **Testability & determinism**

  * Core heading parsing and rebasing logic MUST be pure and deterministic (no dependence on time, locale, or external state).
  * Automated tests MUST cover:

    * Typical and edge-case Markdown inputs (including Unicode).
    * Rebase behavior for all supported base levels.
    * No-heading and max-heading inputs (as per Release Criteria).
* **Agentic & automated development**

  * The project MUST support a simple command-line dev loop (`swift test`, `swift run heading-cli …`) so automated tools and LLM agents can:

    * Modify `HeadingCore`.
    * Run tests and CLI on sample inputs.
    * Inspect behavior via structured debug output.
  * Architecture MUST keep core logic isolated from UI and system integrations to minimize change risk.
* **Performance**

  * Clipboard polling and Markdown parsing SHOULD keep CPU and memory overhead negligible on a typical Mac (e.g., no noticeable impact when running continuously).
  * Processing a typical clipboard payload (<= ~50kB of Markdown) MUST complete in under 50 ms on contemporary hardware.
* **Reliability & error handling**

  * In all error cases (no clipboard access, missing accessibility permissions, non-text clipboard content), the app MUST:

    * Avoid destructive modification of clipboard contents.
    * Present clear messages and safe defaults.
* **Security & permissions**

  * Accessibility and clipboard permissions MUST be requested only when necessary and explained clearly to the user.
  * No user content or logs are persisted or transmitted off-device.
* **Accessibility & localization**

  * All UI surfaces (menu bar extra, palette, toasts) MUST be keyboard-accessible and expose meaningful VoiceOver labels.
  * All user-facing strings MUST be localization-ready.

## Technical Notes
- Implement clipboard monitoring with `NSPasteboard` change count polling or `NSPasteboard.PasteboardType.string` observation.
- Parsing can reuse the web reference logic: identify headings via regex `^(#{1,6})\s+(.*)$` and compute offsets; ensure Unicode support.
- Implement core parsing and rebasing in a framework-free `HeadingCore` module shared by the app and CLI targets.
- Provide a `heading-cli` target that reads stdin/stdout, supports `--base-level`, and exposes `--inspect` for structured summaries.
- Optional debug mode (`--debug` or similar) SHOULD emit JSON lines describing detected headings and rebasing decisions for automated diagnosis.
- For menu bar extra, use `NSStatusItem` with `NSMenu`; highlight last-used level.
- Floating palette can be `NSPanel` with `NSVisualEffectView` for unobtrusive appearance and optional auto-hide.
- Pasting into frontmost app requires `NSApp.sendAction(#selector(NSText.insertText(_:)))` or use accessibility API; provide fallback if permission missing.
- Package app using Swift + SwiftUI or AppKit hybrid; minimal dependencies.
- Include unit tests for parsing and adjustment logic, golden-file tests for representative Markdown inputs, and integration tests for clipboard and CLI flows where feasible.
- Document standard dev commands (`swift test`, `swift run heading-cli`) in `DEVELOPMENT.md` so automated tools can run them reliably.

## Development Principles
### Agent loop
* Make sure an agent can do the core dev loop with 2–3 stable commands, e.g.:

  ```bash
  # Build & run tests
  make test       # or: swift test

  # Run core logic via CLI
  swift run heading-cli --base-level 3 < input.md > output.md

  # Optional: launch the app in a predictable mode
  make run-app    # or: open HeadingAdjuster.app
  ```

### Organization
* Codify this in a top-level `DEVELOPMENT.md` (and maybe `Makefile` or `justfile`) so both humans and LLMs know: “To test changes, run X; to exercise the logic headless, run Y.”

Proposal: Organize the code as:

* `HeadingCore` (SwiftPM target / module)

  * Pure Swift functions:

    * `parseHeadings(in:)`
    * `rebaseHeadings(in:toBaseLevel:)`
  * No AppKit/SwiftUI imports.
* `HeadingCLI`

  * Small wrapper that:

    * Reads stdin or a file.
    * Calls `HeadingCore`.
    * Writes to stdout.
* `HeadingApp` (AppKit/SwiftUI macOS app)

  * Glue logic for:

    * `NSPasteboard`, `NSStatusItem`, `NSPanel`, accessibility.
    * Calls into `HeadingCore`.

**Implications**

* Agents mostly touch `HeadingCore`:

  * Easy to test.
  * Easy to reason about.
* UI is adaptors; less risk of “oops I broke the menu bar extra.”

### 1.3 First-class CLI surface for core behavior

**Proposal**

Treat the CLI as a citizen, not a throwaway dev tool:

* `heading-cli` with something like:

  ```bash
  heading-cli \
    --base-level 3 \
    --mode rebase \
    --input - \
    --format markdown
  ```

* Flags clearly documented in `--help` and `CLI.md`.

* Stable text formats:

  * Main mode: “transform stdin → stdout”.
  * Optional: `--inspect` that prints a heading summary in JSON, e.g.:

    ```json
    {
      "minLevel": 2,
      "maxLevel": 4,
      "headings": [
        { "line": 1, "level": 2, "title": "Intro" },
        ...
      ]
    }
    ```

### 1.4 Deterministic behavior & strong tests

* Keep `HeadingCore` as:

  * Pure functions: no timestamp, random, locale-dependent surprises.
  * Given the same input, always same output.
* Invest in:

  * High-coverage unit tests on parsing & rebasing (including Unicode edge cases).
  * “Golden” tests:

    * For a set of sample markdown files, store expected transformed outputs.
    * Tests compare output exactly.

### 1.5 Text-first config and documentation

**Proposal**

* Configuration:

  * Any tunables (poll interval, default base level behavior, etc.) should be represented in simple structures.
  * If there are more advanced options later, store them as a small JSON/YAML config file rather than buried in multiple unrelated `UserDefaults` keys.
* Docs:

  * `README.md` for high-level.
  * `DEVELOPMENT.md` for how to build/test.
  * `ARCHITECTURE.md` or lighter “How things fit together” section:

    * Modules (Core, CLI, App).
    * The main data structure (e.g. `HeadingMatch`).

**Implications**

* LLMs are very good at editing text files and structured configs.
* It’s easier to say: “Adjust the rebasing rules described in `ARCHITECTURE.md` and ensure tests still pass.”

**Alternative**

* All behavior hidden in code paths; no single place that explains the mental model.
* Agents might misunderstand invariants and make logically “OK” changes that violate your intent.

### 1.6 Observable, machine-parseable debug output

* Add a `--debug` flag (CLI) and a log level setting for the app that can:

  * Print structured, parseable logs (JSON lines) for key steps:

    * Parsed headings.
    * Chosen base level.
    * Before/after sample lines.
* Keep a minimal human-readable default; but make the structured form stable.

**Implications**

* An LLM can run something like:

  ```bash
  heading-cli --base-level 3 --debug < weird.md
  ```

  and then parse logs to understand what the algorithm did and why.

### 1.7 Explicit extension points & naming conventions

**Proposal**

* In core code, mark extension points clearly, e.g.:

  ```swift
  // MARK: - Heading Rebase Strategy
  // Extension point: if we ever support non-Markdown headings or ATX+Setext,
  // adjust logic here and keep tests in Tests/HeadingCoreTests/RebaseStrategyTests.swift
  ```

* Use consistent naming:

  * `parseHeadings` vs `doMagic`.
  * `HeadingMatch`, `HeadingRebaseOptions`, etc.

## Open Questions & Assumptions
- Should the adjustment logic collapse heading levels below level 1 (e.g., when base level is 0) to support document roots?
- Accessibility permissions for paste: assume user will grant when prompted; need confirmation on fallback messaging.
- Determine whether floating palette should auto-dismiss after action or stay visible for quick repeats.

## Release Criteria
- Automated tests cover heading parsing and adjustment edge cases (including no-heading and max-heading inputs).
- Manual test checklist executed for menu bar workflow, floating palette workflow, and permission-denied scenarios.
- Accessibility audit completed for keyboard navigation and VoiceOver labels.
- User documentation (help menu entry or onboarding tooltip) describing default shortcut and behavior.
