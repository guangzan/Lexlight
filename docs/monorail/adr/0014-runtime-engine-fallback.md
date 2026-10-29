# 0014: Runtime tokenization engine fallback

## Status

Accepted

## Context

Lexlight depends on a WebAssembly tokenizer. JavaScriptCore on macOS can
execute the bundle, but an embedded iOS `JSContext` may run with WebAssembly
disabled because JIT policy differs on device. The library must still provide
native attributed results on supported iOS versions.

## Decision

Native tokenization sits behind an internal `TokenizationEngine` boundary.
Lexlight prefers a JavaScriptCore engine when the runtime can load and execute
the WebAssembly module. If that capability probe fails on iOS, the highlighter
uses an internal `WKWebView` tokenizer that loads the same bundle and returns
the same JSON token contract. Engine selection is automatic and observable
through diagnostics, not a public configuration switch.

## Consequences

- The public async API, language aliases, themes, and token shape stay identical
  across engines.
- The iOS path can use WebKit's JavaScript runtime without requiring the host to
  own an additional WebView.
- Engine capability and fallback behavior need separate tests and diagnostics.
