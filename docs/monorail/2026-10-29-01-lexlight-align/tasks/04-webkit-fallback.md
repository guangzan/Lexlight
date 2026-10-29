# 04 — WebKit fallback engine and automatic selection

Status: open
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

- [ ] WebKit engine tokenizes the same Swift sample as JavaScriptCore.
- [ ] Fallback activates after a failed JavaScriptCore Wasm probe.
- [ ] Requests remain serialized and cancellation is honored.
- [ ] WebView lifecycle is fully owned by Lexlight and released with the highlighter.
- [ ] Engine failures surface as `LexlightError`, not empty results.
