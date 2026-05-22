# Development

## Common Commands

```bash
# Run tests
swift test

# Run CLI (stdin to stdout)
swift run heading-cli < input.md > output.md

# Run macOS app
swift run HeadingApp
```

## Sandboxed Test Command (Codex/CI)

Use this when SwiftPM sandboxing or shared caches cause permission errors.
Requires Xcode toolchain (e.g. `xcode-select -p` -> `/Applications/Xcode.app/Contents/Developer`).

```bash
mkdir -p .home .swiftpm/{clang-module-cache,swift-module-cache,tmp,cache,config,security,scratch}

HOME=/Users/ibomash/Documents/Code/markdown-formatter-macos/.home \
CLANG_MODULE_CACHE_PATH=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/clang-module-cache \
SWIFT_MODULE_CACHE_PATH=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/swift-module-cache \
TMPDIR=/Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/tmp \
swift test --disable-sandbox \
  --manifest-cache local \
  --cache-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/cache \
  --config-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/config \
  --security-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/security \
  --scratch-path /Users/ibomash/Documents/Code/markdown-formatter-macos/.swiftpm/scratch
```

## Notes
- The macOS app code will live under `App/` when implementation starts.
- Keep `HeadingCore` platform-agnostic so it can be shared by the CLI and app.
