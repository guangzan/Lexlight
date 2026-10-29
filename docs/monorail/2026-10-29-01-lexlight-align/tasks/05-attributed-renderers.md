# 05 — AppKit/UIKit and SwiftUI renderers

Status: done
Blocked by: 01, 03
Seams: `Tests/LexlightTests/RenderingTests.swift` public rendering seam.
Touchpoints: `Sources/Lexlight/Rendering/**`, `Sources/Lexlight/HighlightResult.swift`, `Tests/LexlightTests/RenderingTests.swift`

## What to build

Implement main-actor rendering of portable `HighlightResult` values into
`NSAttributedString` and `AttributedString`. Accept a caller-supplied base font,
apply foreground/background colours, italic/bold/underline/strikethrough traits,
and preserve the exact source string. Keep platform colour types at the renderer
edge.

## Acceptance criteria

- [x] Both renderers preserve the source and UTF-16 token ranges exactly.
- [x] sRGB hex colours map correctly for 3/4/6/8-digit forms.
- [x] Font traits apply without mutating unrelated ranges.
- [x] Rendering is main-actor isolated and has no tokenizer dependency.
- [x] Tests cover emoji, multi-line code, and theme background/foreground.

## Comments

Run 2026-10-29: start — d1b992a
done — pending task commit
- seams used: `Tests/LexlightTests/RenderingTests.swift`
- typecheck: green
- relevant tests: green (`swift test`, 17 tests)
- acceptance criteria: met
