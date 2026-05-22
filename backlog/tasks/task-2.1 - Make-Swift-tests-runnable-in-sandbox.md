---
id: task-2.1
title: Make Swift tests runnable in sandbox
status: Done
assignee: []
created_date: '2026-01-02 05:35'
updated_date: '2026-01-03 21:02'
labels: []
dependencies: []
parent_task_id: task-2
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Investigate SwiftPM sandbox issues and document a supported workflow.

Findings:
- SwiftPM sandbox + user caches caused permission errors under CLT-only toolchain.
- With Xcode installed and selected, tests run inside the sandbox using local cache/config/scratch paths plus --disable-sandbox.

Working command (passes in sandbox):
HOME=/Users/ibomash/Documents/Code/markdown-formatter-macos/.home \
CLANG_MODULE_CACHE_PATH=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/clang-module-cache \
SWIFT_MODULE_CACHE_PATH=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/swift-module-cache \
TMPDIR=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/tmp \
SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
swift test --disable-sandbox \
  --manifest-cache local \
  --cache-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/cache \
  --config-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/config \
  --security-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/security \
  --scratch-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/scratch

Run result (Jan 3, 2026):
- Build + tests passed (13 tests, 0 failures).
<!-- SECTION:DESCRIPTION:END -->
