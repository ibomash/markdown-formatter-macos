# Markdown Heading Adjuster PDD

## Overview
A lightweight macOS utility that reformats Markdown headings on the clipboard so their hierarchy nests under a chosen base level. Targeted at writers and developers who frequently paste Markdown into documentation systems that require consistent heading levels.

## Goals
- Offer a one-click (or keyboard-first) workflow to normalize heading levels on clipboard Markdown.
- Provide clear feedback about detected heading structure before and after adjustment.
- Support output either to the clipboard or by pasting directly into the frontmost app.
- Remember the most recently used heading level and interaction surface.

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
  - *Optional floating palette*: toggleable mini-window showing a live heading histogram, star-style level picker (`#` to `######`), and buttons for “Copy adjusted” or “Paste adjusted”. Palette auto-detects clipboard changes and updates feedback.
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

## Technical Notes
- Implement clipboard monitoring with `NSPasteboard` change count polling or `NSPasteboard.PasteboardType.string` observation.
- Parsing can reuse the web reference logic: identify headings via regex `^(#{1,6})\s+(.*)$` and compute offsets; ensure Unicode support.
- For menu bar extra, use `NSStatusItem` with `NSMenu`; highlight last-used level.
- Floating palette can be `NSPanel` with `NSVisualEffectView` for unobtrusive appearance and optional auto-hide.
- Pasting into frontmost app requires `NSApp.sendAction(#selector(NSText.insertText(_:)))` or use accessibility API; provide fallback if permission missing.
- Package app using Swift + SwiftUI or AppKit hybrid; minimal dependencies.
- Include unit tests for adjustment logic and integration tests for clipboard flow where feasible.

## Open Questions & Assumptions
- Should the adjustment logic collapse heading levels below level 1 (e.g., when base level is 0) to support document roots?
- Accessibility permissions for paste: assume user will grant when prompted; need confirmation on fallback messaging.
- Determine whether floating palette should auto-dismiss after action or stay visible for quick repeats.

## Release Criteria
- Automated tests cover heading parsing and adjustment edge cases (including no-heading and max-heading inputs).
- Manual test checklist executed for menu bar workflow, floating palette workflow, and permission-denied scenarios.
- Accessibility audit completed for keyboard navigation and VoiceOver labels.
- User documentation (help menu entry or onboarding tooltip) describing default shortcut and behavior.
