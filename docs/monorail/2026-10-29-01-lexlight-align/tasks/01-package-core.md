# 01 — Package scaffold and portable core

Status: done
Blocked by: None
Seams: `Tests/LexlightTests/HighlighterTests.swift` public protocol seam; `Tests/LexlightTests/LanguageTests.swift` public language seam; `Tests/LexlightTests/ThemeRegistryTests.swift` public theme seam.
Touchpoints: `Package.swift`, `Sources/Lexlight/**`, `Tests/LexlightTests/**`, `.gitignore`

## What to build

Replace the placeholder skeleton with a valid Swift 6 package exposing one
`Lexlight` product. Add stable public values for errors, languages, themes,
tokens, results, resource URLs, the `Highlighter` protocol, `ActorHighlighter`,
and `Lexlight.shared`. Provide a fake engine seam test target and initial unit
coverage for plain fallback, alias normalization, theme lookup, UTF-16 token
storage, cancellation, and typed errors.

## Acceptance criteria

- [x] `swift test` builds the package and initial tests pass.
- [x] Unknown or omitted languages normalize to `plain`.
- [x] Public value types used across actor boundaries are `Sendable`.
- [x] Cancelled requests throw `LexlightError.cancelled` and return no partial result.
- [x] The package has one public library product.

## Comments

Run 2026-10-29: start — initial commit
done — pending task commit
- seams used: `Tests/LexlightTests/HighlighterTests.swift`, `LanguageTests.swift`, `ThemeRegistryTests.swift`
- typecheck: green
- relevant tests: green (`swift test`, 9 tests)
- acceptance criteria: met
