# 03 — JavaScriptCore engine and live Swift bridge

Status: open
Blocked by: 01, 02
Seams: `Tests/LexlightTests/HighlighterTests.swift` public `ActorHighlighter` seam; `Tests/LexlightTests/EngineParityTests.swift` engine token normalization seam.
Touchpoints: `Sources/Lexlight/Internal/TokenizationEngine.swift`, `JavaScriptCoreEngine.swift`, `ActorHighlighter.swift`

## What to build

Implement the internal async tokenization engine protocol and the
JavaScriptCore-backed engine. Probe WebAssembly support, load the packaged JS
bundle from the Lexlight resource bundle, bridge tokenize and supported-language
calls, decode the JSON contract into `HighlightResult`, cache supported
languages, and serialize actor access. Route `ActorHighlighter` through the
engine and support cancellation.

## Acceptance criteria

- [ ] macOS JavaScriptCore tokenizes Swift, TypeScript, and plain text.
- [ ] UTF-16 offsets survive emoji and non-BMP input.
- [ ] Engine initialization failures throw stable `LexlightError` cases.
- [ ] Cancelled queued calls are skipped without partial output.
- [ ] `supportedLanguages` and alias normalization agree with the bundle.
