# 07 — macOS and iOS example application

Status: done
Blocked by: 03, 04, 05, 06
Seams: Xcode build-only gates for `Examples/LexlightDemo`; public APIs from tasks 03-06.
Touchpoints: `Examples/LexlightDemo/**`

## What to build

Add a SwiftUI multiplatform example app that highlights editable code with the
native API, renders `AttributedString` and `NSAttributedString`, switches
language and theme, and embeds a `WKWebView` using the Lexlight resources.
Include clear labels explaining which engine is active.

## Acceptance criteria

- [x] Example builds for macOS and iOS simulator.
- [x] Native and Web examples use the same selected theme/language.
- [x] Invalid language falls back to plain visibly.
- [x] Example does not fork Lexlight internals or copy bundled resources.
- [x] App remains a demonstration, not a second public product.

## Comments

Run 2026-10-29: start — 28ec825
done — pending task commit
- seams used: Xcode build-only gates for `Examples/LexlightDemo`; public APIs from tasks 03-06
- typecheck: green
- relevant tests: green (`swift build`, `swift test` 20 tests, macOS demo build, iOS simulator demo build)
- acceptance criteria: met
