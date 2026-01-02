---
id: task-2.1
title: Make Swift tests runnable in sandbox
status: Done
assignee: []
created_date: '2026-01-02 05:35'
updated_date: '2026-01-02 00:05'
labels: []
dependencies: []
parent_task_id: task-2
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Investigate SwiftPM sandbox issues and document a supported workflow.

Findings so far:
- SwiftPM sandbox + user caches cause permission errors in this environment.
- Using local cache/config/scratch paths plus --disable-sandbox avoids those errors.
- XCTest is missing from the CommandLineTools install, causing `no such module XCTest`.

Working command (still fails due to missing XCTest):
HOME=/Users/ibomash/Documents/Code/markdown-formatter-macos/.home \
CLANG_MODULE_CACHE_PATH=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/clang-module-cache \
SWIFT_MODULE_CACHE_PATH=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/swift-module-cache \
TMPDIR=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/tmp \
SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk \
swift test --disable-sandbox \
  --manifest-cache local \
  --cache-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/cache \
  --config-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/config \
  --security-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/security \
  --scratch-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/scratch

Update:
- Verified Xcode toolchain is available via `xcode-select -p` (`/Applications/Xcode.app/Contents/Developer`).
- Swift tests pass using the command above with `--disable-sandbox` and local cache paths.
- Added a fallback in tests for resource lookup when SwiftPM flattens processed resources.
<!-- SECTION:DESCRIPTION:END -->
