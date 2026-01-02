# Development

## Common Commands

```bash
# Run tests
swift test

# Run CLI (stdin to stdout)
swift run heading-cli < input.md > output.md
```

## Notes
- The macOS app code will live under `App/` when implementation starts.
- Keep `HeadingCore` platform-agnostic so it can be shared by the CLI and app.
