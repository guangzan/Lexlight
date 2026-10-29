# 04 — WebKit fallback engine and automatic selection

Status: done
Blocked by: 03
Seams: `Tests/LexlightTests/EngineParityTests.swift` cross-engine parity seam; `Tests/LexlightTests/HighlighterTests.swift` cancellation seam.
Touchpoints: `Sources/Lexlight/Internal/WebKitTokenizationEngine.swift`, `EngineFactory.swift`

## What to build

Add the internal `WKWebView` tokenizer that loads the same packaged bundle and
returns the same JSON result. Implement automatic engine selection: prefer
JavaScriptCore where Wasm probing succeeds, fall back to WebKit on iOS when the
probe or initialization fails. Expose selected-engine diagnostics for tests and
logging without adding a public configuration switch.

## Acceptance criteria

- [x] WebKit engine tokenizes the same Swift sample as JavaScriptCore.
- [x] Fallback activates after a failed JavaScriptCore Wasm probe.
- [x] Requests remain serialized and cancellation is honored.
- [x] WebView lifecycle is fully owned by Lexlight and released with the highlighter.
- [x] Engine failures surface as `LexlightError`, not empty results.

## Comments

Run 2026-10-29: start — 698fa96
done — pending task commit
- seams used: `Tests/LexlightTests/EngineParityTests.swift`, `HighlighterTests.swift`
- typecheck: green
- relevant tests: green (`swift test`, 15 tests)
- acceptance criteria: met
