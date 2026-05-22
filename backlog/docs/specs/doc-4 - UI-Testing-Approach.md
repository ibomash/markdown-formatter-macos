---
id: doc-4
title: UI Testing Approach
type: other
created_date: '2026-01-03 21:06'
---

# UI Testing Approach (macOS Menu Bar + Palette)

## Overview
This document outlines approaches for UI testing the macOS app (menu bar extra + floating palette) and recommends a practical strategy that balances reliability, coverage, and maintenance cost.

## Goals
- Validate key end-to-end user flows (menu bar actions, palette interactions).
- Ensure UI surfaces respond to clipboard changes and user actions correctly.
- Keep tests deterministic and stable in CI and local runs.
- Avoid brittle tests dependent on OS timing, accessibility permission prompts, or flaky UI discovery.

## Constraints & Risks
- **Menu bar extras** are notoriously hard to locate reliably in UI automation.
- **Clipboard and Accessibility permissions** can block or prompt UI in a way that breaks tests.
- **Timing sensitivity** (clipboard polling and auto-dismiss) causes flakiness without hooks.
- **Running UI tests in CI** is constrained by environment (headless, sandbox restrictions).

## Tooling Options (Analysis)

### 1) XCUITest (XCTest UI Testing)
- **Pros**: Official Apple tooling; integrates with Xcode; supports macOS UI automation.
- **Cons**: Menu bar extras can be difficult to select; implicit timing can be flaky; permission prompts are tricky; requires Xcode.
- **Best for**: Basic window-level UI tests, palette interactions, and navigation flows.

### 2) Accessibility-Driven UI Automation (AX APIs)
- **Pros**: Can directly inspect UI elements and labels; can be more precise than UI queries.
- **Cons**: Complex and verbose; requires enabling Accessibility permissions for the test runner; still flaky in CI.
- **Best for**: Validating menu bar extra UI in a controlled environment.

### 3) Snapshot Testing (SwiftUI Snapshot or View Image Snapshots)
- **Pros**: Fast, deterministic, good for UI regressions on static view states.
- **Cons**: Requires additional libraries or custom harness; less confidence on interaction flows.
- **Best for**: Palette visual regressions, menu content rendering (if testable in isolation).

### 4) View Model / Integration Tests (Non-UI)
- **Pros**: Stable, fast, can cover 80% of logic; does not require UI automation.
- **Cons**: Does not fully validate UI wiring or actual UI behavior.
- **Best for**: Most behavior around clipboard monitoring, rebase actions, and state transitions.

## Recommended Strategy (Layered)

### Layer 1: High-confidence non-UI tests (default)
- **Goal**: Validate most behaviors without UI automation.
- **Method**: Test view models + state reducers + services directly.
- **Hooks needed**:
  - Dependency injection for clipboard service, paste service, and timing.
  - Deterministic clock or scheduler.
  - Ability to simulate clipboard contents.

### Layer 2: Window-based UI tests (palette only)
- **Goal**: Validate the floating palette workflow.
- **Method**: XCUITest against a windowed palette mode launched specifically for tests.
- **Hooks needed**:
  - Launch argument to force palette visible and disable auto-dismiss.
  - Toggle to bypass clipboard polling, feeding fixed sample data.
  - Accessibility identifiers on key UI elements.

### Layer 3: Menu bar integration tests (local/dev only)
- **Goal**: Validate menu bar extra interactions.
- **Method**: Either XCUITest or AX-based custom test harness, run locally.
- **Hooks needed**:
  - Stable status item title or accessibility label.
  - Internal test mode that pins menu open.
- **Notes**: These tests should be opt-in and not required in CI.

## Architecture Hooks to Enable Reliable Tests

### Test Mode Configuration
Provide app launch arguments or environment variables:
- `UI_TEST_MODE=1`
- `PALETTE_ALWAYS_VISIBLE=1`
- `DISABLE_CLIPBOARD_POLLING=1`
- `FIXTURE_CLIPBOARD_PATH=...`

### Dependency Injection
- Inject `ClipboardMonitor` and `PasteService` via protocols.
- Add a `TestClipboardService` to simulate clipboard contents.
- Provide a `TestPasteService` that records output instead of using accessibility APIs.

### Accessibility Identifiers
Add identifiers to:
- Palette root view
- Heading histogram
- Level picker controls
- Copy/Paste buttons
- Status text

### Deterministic Scheduling
- Replace polling timers with injected schedulers (e.g., a `Scheduler` protocol or a `DispatchQueue` wrapper).
- Provide a test scheduler for predictable timing.

## Test Scope Proposal

### Palette UI Tests (CI-safe)
- Detect heading levels displayed correctly for a fixture.
- Change base level and verify status text update.
- Trigger Copy vs Paste (in test mode, verify captured output).
- Auto-dismiss logic (tested via view model rather than UI).

### Menu Bar Tests (local only)
- Menu bar shows correct detected levels (e.g., `H2, H3`).
- Selecting level updates clipboard output in test mode.
- Verify menu availability disabled when no headings.

## CI Strategy
- Run **unit + integration tests** (HeadingCore + CLI + view models).
- Run **palette UI tests** only if a macOS UI runner is available and stable.
- Skip menu bar tests in CI, but document local run steps.

## Open Questions
- Is CI expected to run UI tests, or only local/dev workflows?
- Do we want to adopt a snapshot testing library for palette UI?
- Should menu bar behavior be validated only via unit tests to avoid UI flakiness?
