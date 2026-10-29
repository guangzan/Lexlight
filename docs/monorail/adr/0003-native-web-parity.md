# 0003: Native and Web highlighters share one tokenizer

## Status

Accepted

## Context

Apps that render Markdown often highlight code twice: once in an AppKit or UIKit
editor, and again in a `WKWebView` preview. Two independent highlighters can
drift in language support, token boundaries, and colours.

## Decision

Lexlight's primary product promise is that its native JavaScriptCore path and
its WebView path use the same `@pierre/highlights` Wasm tokenizer and the same
theme definitions. The library optimises for this shared result rather
than promising drop-in compatibility with Highlightr.

## Consequences

- Theme and language support changes must be verified on both paths.
- Tests must exercise JavaScriptCore and a real `WKWebView`.
- Highlightr-style convenience APIs are not part of the library contract.
