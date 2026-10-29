# 06 — Host WebView contract

Status: done
Blocked by: 02
Seams: `Tests/LexlightTests/WebResourceTests.swift` real `WKWebView` seam.
Touchpoints: `Sources/Lexlight/Resources/**`, `Sources/Lexlight/Web/**`, `Tests/LexlightTests/WebResourceTests.swift`

## What to build

Finalize public resource helpers for the JavaScript and stylesheet URLs, add
documentation comments for host-owned injection, and test the generated
`Lexlight` namespace in a real `WKWebView`. Cover `highlightAll`,
`highlightElement`, `tokenize`, language aliases, theme switching, and
`data-no-highlight`.

## Acceptance criteria

- [x] Host can locate JS and CSS resources through public Swift API.
- [x] `Lexlight.highlightAll` leaves unsupported/configuration blocks untouched.
- [x] `Lexlight.tokenize` returns the same normalized data as the native bridge.
- [x] Theme changes repaint existing test blocks through the public API.
- [x] Missing resources throw a stable `LexlightError`.

## Comments

Run 2026-10-29: start — fe029cf
done — pending task commit
- seams used: `Tests/LexlightTests/WebResourceTests.swift` real `WKWebView` seam
- typecheck: green
- relevant tests: green (`swift test`, 19 tests)
- acceptance criteria: met
