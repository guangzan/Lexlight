# 07 — macOS and iOS example application

Status: open
Blocked by: 03, 04, 05, 06
Seams: Xcode build-only gates for `Examples/LexlightDemo`; public APIs from tasks 03-06.
Touchpoints: `Examples/LexlightDemo/**`

## What to build

Add a SwiftUI multiplatform example app that highlights editable code with the
native API, renders `AttributedString` and `NSAttributedString`, switches
language and theme, and embeds a `WKWebView` using the Lexlight resources.
Include clear labels explaining which engine is active.

## Acceptance criteria

- [ ] Example builds for macOS and iOS simulator.
- [ ] Native and Web examples use the same selected theme/language.
- [ ] Invalid language falls back to plain visibly.
- [ ] Example does not fork Lexlight internals or copy bundled resources.
- [ ] App remains a demonstration, not a second public product.
