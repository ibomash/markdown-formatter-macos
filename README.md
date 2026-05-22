# Markdown Heading Adjuster (macOS)

A macOS menu bar and palette app plus CLI for rebasing Markdown heading levels.
The project is split into a pure core library, a CLI wrapper, and a macOS app.

## Requirements

- macOS 13+
- Xcode (for XCTest and Swift toolchains)

## Quick Start

```bash
# Run tests
swift test

# Run CLI (stdin to stdout)
swift run heading-cli --base-level 2 < input.md > output.md

# Inspect headings as JSON
swift run heading-cli --inspect < input.md

# Run the macOS app
swift run HeadingApp
```

If you hit sandbox or cache permission errors, use the sandboxed workflow in `DEVELOPMENT.md`.

## Project Layout

- `Sources/HeadingCore`: Pure Swift parsing + rebasing logic.
- `Sources/HeadingCLIKit`: Testable CLI logic (arg parsing + JSON output).
- `Sources/HeadingCLI`: CLI entry point.
- `App/HeadingApp`: macOS app (menu bar extra + palette).
- `Tests/HeadingCoreTests`: Core unit + golden tests.
- `Tests/HeadingCLIKitTests`: CLI behavior tests.
- `backlog/`: Planning docs and tasks.

## App Behavior (High Level)

- Menu bar extra shows detected heading levels and provides copy/paste actions by base level.
- Floating palette shows a histogram, base-level picker, and clipboard preview.
- Paste actions require Accessibility permission; the app will prompt when needed.

## Development Notes

- See `DEVELOPMENT.md` for build/test commands and sandbox-safe workflows.
- See `backlog/docs/doc-2 - Code-Overview.md` for a deeper code map.
- See `backlog/docs/doc-3 - App-Guide.md` for UI usage details.
