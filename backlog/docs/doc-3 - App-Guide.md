---
id: doc-3
title: App Guide
type: other
created_date: '2026-01-03 03:33'
---

# App Guide

## Overview
The macOS app monitors the clipboard for Markdown text, detects heading levels, and lets you rebase headings by copying or pasting updated Markdown. It exposes two UI surfaces:

- Menu bar extra for quick actions.
- Floating palette for a richer preview and controls.

## Launching the App
From the repo root:

```bash
swift run HeadingApp
```

The app runs as a menu bar extra and can open the palette window from the menu.

## Menu Bar Extra
The menu bar entry shows detected heading range and exposes actions:

- Copy -> H1..H6: rebases the clipboard content and copies the result.
- Paste -> H1..H6: rebases, copies, and attempts to paste into the frontmost app.
- Open Palette: opens the floating palette window.

## Floating Palette
The palette provides:

- Heading histogram (counts for H1..H6).
- Base-level picker.
- Clipboard preview.
- Copy and Paste buttons for the selected base level.

## Permissions
Paste requires Accessibility permission so the app can send a paste action to the frontmost app. If permission is missing, the app will prompt and fall back to copy-only behavior.

## Troubleshooting
- No headings detected: ensure the clipboard contains Markdown headings like `# Title`.
- Paste failed: grant Accessibility permission in System Settings and retry; manual paste is always possible after copy.
