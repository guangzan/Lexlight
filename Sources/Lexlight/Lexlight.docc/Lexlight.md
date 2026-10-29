# ``Lexlight``

One offline tokenizer for native attributed text and host-owned WebViews.

## Overview

Lexlight wraps a pinned `@pierre/highlights` bundle and exposes a Swift 6 async
API. The same token stream and theme catalogue drive `AttributedString`,
`NSAttributedString`, and a narrow JavaScript contract that your app can inject
into its own `WKWebView`.

```swift
import Lexlight

let highlighter = try await ActorHighlighter(themeID: "github-light")
let result = try await highlighter.tokenize(
    #"let answer = 42"#,
    language: .swift
)

let text = result.attributedString()
```

Lexlight prefers JavaScriptCore on macOS. On iOS it probes JavaScriptCore's
WebAssembly support and falls back to a private `WKWebView` tokenizer when the
runtime cannot execute the bundle. Call ``ActorHighlighter/activeEngine()`` to
display or log the selected runtime.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:NativeRendering>
- <doc:WebIntegration>

### Contracts

- <doc:ThemesAndLanguages>
- <doc:ErrorsAndCancellation>
