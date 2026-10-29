# 06 — Host WebView contract

Status: open
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

- [ ] Host can locate JS and CSS resources through public Swift API.
- [ ] `Lexlight.highlightAll` leaves unsupported/configuration blocks untouched.
- [ ] `Lexlight.tokenize` returns the same normalized data as the native bridge.
- [ ] Theme changes repaint existing test blocks through the public API.
- [ ] Missing resources throw a stable `LexlightError`.
