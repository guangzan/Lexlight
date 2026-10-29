# Lexlight

**English** | [简体中文](README.zh-CN.md)

[![CI](https://github.com/guangzan/Lexlight/actions/workflows/ci.yml/badge.svg)](https://github.com/guangzan/Lexlight/actions/workflows/ci.yml)
[![Swift 6](https://img.shields.io/badge/Swift-6-F05138.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-macOS%2014%2B%20%7C%20iOS%2017%2B-blue.svg)](#requirements)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

Lexlight is a production-oriented syntax-highlighting library for Apple
platforms. It wraps one pinned `@pierre/highlights` tokenizer and gives native
SwiftUI/AppKit/UIKit views and host-owned `WKWebView` previews the same token
stream, language aliases, and theme catalogue.

It occupies the role that Highlightr commonly serves in Apple apps, without
shipping a second grammar engine for Web content or changing runtime behavior
between native previews and generated HTML.

## Why Lexlight

- **One tokenizer, two surfaces.** Native attributed strings and Web code
  blocks resolve the same tokens and colors.
- **Offline by design.** JavaScript, Wasm, all languages, and 75 typed themes
  ship inside the package. No runtime downloads.
- **Swift 6 async API.** One actor serializes work, cancellation is cooperative,
  results are `Sendable`, and rendering happens at the UI boundary.
- **Automatic runtime fallback.** JavaScriptCore is preferred where Wasm works;
  an internal `WKWebView` tokenizer takes over when it does not.
- **Host-owned Web UI.** Lexlight ships stable JavaScript/CSS resources and a
  narrow `globalThis.Lexlight` namespace, not an opinionated browser wrapper.
- **Typed themes.** Built-in themes are Swift values with scope inheritance;
  custom themes do not expose upstream JavaScript objects as public API.
- **Reproducible assets.** The generated bundle, manifest hash, build scripts,
  and upstream licence notices are tracked and verified in CI.

## Requirements

- macOS 14 or later
- iOS 17 or later
- Swift 6 language mode
- Xcode 16 or later

Lexlight does not support watchOS, tvOS, visionOS, Mac Catalyst, or automatic
language detection.

## Installation

In Xcode, choose **File > Add Package Dependencies** and enter:

```text
https://github.com/guangzan/Lexlight.git
```

Select the `Lexlight` library product.

Or declare it in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/guangzan/Lexlight.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["Lexlight"]
    )
]
```

The package exposes one public library product: `Lexlight`.

## Quick Start

```swift
import Lexlight

let highlighter = try await ActorHighlighter(themeID: "github-light")
let result = try await highlighter.tokenize(
    """
    struct Greeting {
        let name: String
    }
    """,
    language: .swift
)

let engine = await highlighter.activeEngine()
print("Lexlight runtime: \(engine.displayName)")
```

Keep one `ActorHighlighter` per editor or document surface. It serializes work
through one JavaScript runtime, so tokenizer startup is paid once.

## Native Rendering

### SwiftUI

```swift
import Lexlight
import SwiftUI

struct HighlightedCode: View {
    let result: HighlightResult

    var body: some View {
        Text(
            result.attributedString(
                baseFont: .system(.body, design: .monospaced)
            )
        )
        .textSelection(.enabled)
    }
}
```

### AppKit and UIKit

```swift
let attributed = result.nsAttributedString(
    baseFont: LexlightFont.monospacedSystemFont(ofSize: 13, weight: .regular)
)
```

Assign the result to `NSTextStorage` on AppKit or `UITextView.attributedText` on
UIKit. Token offsets are UTF-16 code units, so emoji and composed text stay
aligned with `NSRange`.

## WebView Integration

Lexlight does not own your `WKWebView`. It provides the exact JavaScript and CSS
resources used by its native tokenizer:

```swift
let scriptURL = try LexlightResources.webViewScriptURL()
let stylesheetURL = try LexlightResources.webViewStylesheetURL()
```

For inline injection:

```swift
let script = try LexlightResources.javascript()
let stylesheet = try LexlightResources.stylesheet()
```

Mark code blocks with a language class:

```html
<pre><code class="language-swift">let answer = 42</code></pre>
```

After the bundle is loaded:

```javascript
Lexlight.highlightAll(document, { theme: "github-light" });
```

The public JavaScript namespace is intentionally small:

- `tokenize(code, language, themeID)`
- `highlightElement(element, options)`
- `highlightAll(root, options)`
- `supportedLanguages()`
- `normalizeLanguage(language)`
- `setTheme(themeID)`
- `version`

Blocks under `[data-no-highlight]` and diagram languages such as Mermaid,
PlantUML, and Markmap are skipped.

## Runtime Selection

Lexlight starts with JavaScriptCore. The engine verifies that the runtime can
construct a WebAssembly module before accepting the bundle. If JavaScriptCore
cannot execute the tokenizer, Lexlight initializes an internal `WKWebView`
engine and runs the same JavaScript through a JSON-only bridge.

```swift
switch await highlighter.activeEngine() {
case .javaScriptCore:
    print("Using JavaScriptCore")
case .webKit:
    print("Using WebKit fallback")
}
```

The fallback is automatic; callers do not branch by platform.

## Themes and Languages

```swift
let registry = try ThemeRegistry.bundled()
let theme = registry.theme(identifier: "one-dark-pro")

let result = try await highlighter.tokenize(
    source,
    language: HighlightLanguage(identifier: "js"),
    theme: theme
)
```

Common aliases such as `js`, `ts`, `c++`, `objc`, and `language-javascript`
normalize before tokenization. Empty or unknown languages resolve to `plain`.

Create a custom theme with portable values:

```swift
let brand = HighlightTheme(
    id: "brand",
    name: "Brand",
    appearance: .dark,
    editorForeground: LexlightColor(hex: "#F4F1E8"),
    editorBackground: LexlightColor(hex: "#1D211F"),
    syntax: [
        .keyword: HighlightStyle(
            foreground: LexlightColor(hex: "#7FD1C7"),
            fontStyle: .bold
        )
    ]
)
```

## Cancellation

All async entry points honor Swift task cancellation.

```swift
@State private var highlightTask: Task<Void, Never>?

func refresh() {
    highlightTask?.cancel()
    highlightTask = Task {
        guard let result = try? await highlighter.tokenize(source, language: language)
        else { return }
        guard !Task.isCancelled else { return }
        self.result = result
    }
}
```

Lexlight checks cancellation before engine work and again before returning a
result. A cancelled request never becomes a stale rendered value.

## Errors

Public failures use stable `LexlightError` cases:

```swift
do {
    let result = try await highlighter.tokenize(source, language: .swift)
    render(result)
} catch let error as LexlightError {
    diagnostics.record(error)
} catch {
    diagnostics.record(error)
}
```

Cases cover missing resources, engine initialization, unavailable runtimes,
JavaScript evaluation, decoding, serialization, invalid themes, and
cancellation.

## Example App

`Examples/LexlightDemo` is a SwiftUI executable for macOS and iOS. It
demonstrates editable source, `AttributedString`, `NSAttributedString`, a
resource-powered `WKWebView`, language/theme switching, engine diagnostics, and
unknown-language fallback.

```sh
xcodebuild -scheme LexlightDemo -destination 'platform=macOS' build
```

```sh
xcodebuild -scheme LexlightDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

The example is a demonstration target, not a second public product.

## Reproducing Resources

Generated files under `Sources/Lexlight/Resources` are checked in so package
consumers do not need Node.js or a Wasm toolchain.

For contributors:

```sh
pnpm install --frozen-lockfile
pnpm run build:highlights
pnpm run verify:highlights
```

Do not edit `lexlight-highlights.js`, `themes.json`, or
`resource-manifest.json` by hand. CI regenerates the bundle and fails on drift.

## Development

```sh
swift build
swift test
swift-format lint --strict --recursive Sources Tests Examples Package.swift
swiftlint lint --strict
```

DocC documentation lives in `Sources/Lexlight/Lexlight.docc`.

## License

Lexlight is available under the Apache License 2.0. See [LICENSE](LICENSE) and
[NOTICE.md](NOTICE.md).

The bundled tokenizer is `@pierre/highlights` 0.2.0, also licensed under
Apache-2.0. Its upstream licence and notice are distributed at
`Sources/Lexlight/Resources/Vendor/PierreHighlights/`.
