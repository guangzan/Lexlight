## Intent

Build Lexlight as a production-grade open-source syntax-highlighting library
for Apple platforms. It replaces the Highlightr role in apps such as ShiYue
while providing one tokenizer and one theme model for both native attributed
text and `WKWebView` code blocks.

## Decisions settled

- The project lives at `/Users/zane/files/code/open-source/Lexlight` and is
  published as a Swift package named `Lexlight`.
- Supported platforms are macOS 14+ and iOS 17+.
- The package exposes one public library product, `Lexlight`.
- The bundled tokenizer is `@pierre/highlights` pinned at `0.2.0`, distributed
  as a prebuilt JavaScript/Wasm resource with reproducible build scripts and
  upstream LICENSE/NOTICE files.
- Native and Web highlighters share the same tokenizer bundle, language alias
  rules, and theme serialization.
- Native tokenization uses a `TokenizationEngine` abstraction. JavaScriptCore
  is preferred where WebAssembly works; iOS falls back to an internal
  `WKWebView` tokenizer when JavaScriptCore cannot execute the bundle.
- The public core is asynchronous and supports Swift task cancellation. A
  dedicated actor serializes engine work; native attributed renderers run on
  the main actor at the UI boundary.
- Results are exposed as a portable token model plus `NSAttributedString` and
  `AttributedString` renderers.
- Themes are typed Swift values with a `ThemeRegistry`. Raw upstream theme
  objects remain internal adapter data.
- The registry includes the complete usable upstream theme catalogue; callers
  can also construct custom themes.
- Language selection is explicit. Common aliases are normalized; omitted or
  unknown languages fall back to `plain`. Automatic language detection is not
  included.
- Errors use stable `LexlightError` cases. Initialization, runtime, and
  serialization failures never become empty or optional results.
- A `Highlighter` protocol and actor-backed implementation are public. A shared
  convenience instance is available but not required.
- The WebView integration is resource-oriented: Lexlight ships JavaScript and
  CSS URLs and a narrow stable `Lexlight` JavaScript namespace; the host owns
  its `WKWebView` lifecycle.
- The public JavaScript namespace exposes `highlightElement`, `highlightAll`,
  `tokenize`, `supportedLanguages`, `normalizeLanguage`, and theme selection.
  It does not expose the upstream `0.x` API as a stable contract.
- The package does not include a prebuilt SwiftUI code-block view. A runnable
  example application demonstrates native, SwiftUI, and WebView integration on
  macOS and iOS.
- The repository uses Swift 6 language mode with strict concurrency and
  Apache-2.0 licensing.
- GitHub Actions verifies macOS and iOS simulator builds, tests, formatting,
  DocC, resource integrity, and release-tag consistency.
- The README is English-first with a Chinese translation and visible language
  switching.

## Deferred

None.

## Out of scope

- Automatic programming-language detection.
- Highlightr API compatibility or drop-in source compatibility.
- watchOS, tvOS, and visionOS support.
- Built-in SwiftUI code-block UI, line numbers, copy buttons, or editor views.
- Runtime downloads of languages or themes.
- Streaming, incremental editor tokenization beyond complete async requests.

## Domain pointers

- `docs/monorail/CONTEXT.md`
- `docs/monorail/adr/0001-platform-floor.md`
- `docs/monorail/adr/0002-bundle-distribution.md`
- `docs/monorail/adr/0003-native-web-parity.md`
- `docs/monorail/adr/0004-async-core-render-boundary.md`
- `docs/monorail/adr/0005-single-package-product.md`
- `docs/monorail/adr/0006-typed-theme-boundary.md`
- `docs/monorail/adr/0007-token-core-native-renderers.md`
- `docs/monorail/adr/0008-explicit-language-selection.md`
- `docs/monorail/adr/0009-instance-based-highlighter.md`
- `docs/monorail/adr/0010-webview-resource-boundary.md`
- `docs/monorail/adr/0011-apache-license.md`
- `docs/monorail/adr/0012-swift-6-language-mode.md`
- `docs/monorail/adr/0013-complete-language-bundle.md`
- `docs/monorail/adr/0014-runtime-engine-fallback.md`
