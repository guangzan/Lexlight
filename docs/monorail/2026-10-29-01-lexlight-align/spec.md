## Problem Statement

Apple apps that render code in both native views and a `WKWebView` usually
adopt two highlighters. Language support, token boundaries, and theme colours
drift, and projects migrating from Highlightr inherit a large bundled grammar
catalogue with no shared Web contract. The WebAssembly-based
`@pierre/highlights` tokenizer can remove that split, but using it directly from
Swift requires a production wrapper for bundle distribution, async execution,
runtime fallback, typed themes, attributed-string rendering, and WebView APIs.

## Solution

Lexlight is a Swift package that wraps one pinned `@pierre/highlights` bundle
and presents a Swift-native, async, cancellable highlighter. A tokenization
engine abstraction uses JavaScriptCore where WebAssembly is available and an
internal `WKWebView` fallback on iOS when it is not. The same bundle is exposed
to host-owned WebViews through a narrow `Lexlight` JavaScript namespace.

The package ships portable token values, AppKit/UIKit and SwiftUI rendering
adapters, typed themes and a complete bundled theme registry, explicit language
aliases with `plain` fallback, structured errors, reproducible JavaScript
resources, a macOS/iOS example app, API documentation, bilingual READMEs, and
CI gates suitable for third-party adoption.

## User Stories

1. As an Apple app developer, I want to add one Swift package product and
   highlight code asynchronously with a supported language so that I do not
   maintain a separate tokenizer.
2. As a macOS editor developer, I want `NSAttributedString` output rendered on
   the main actor so that code is highlighted without blocking input.
3. As an iOS app developer, I want the same native API to work even when an
   embedded JavaScriptCore context cannot execute WebAssembly so that app code
   does not branch by platform.
4. As a SwiftUI developer, I want `AttributedString` output and a runnable
   example so that I can display highlighted code without relying on a hidden
   view abstraction.
5. As a Markdown preview author, I want to inject one stable JavaScript and CSS
   resource into my own `WKWebView` so that preview code matches native output.
6. As a caller editing large code blocks, I want cancellation and structured
   errors so that stale work is skipped and failures are diagnosable.
7. As a theme author, I want typed built-in themes plus custom theme creation
   so that I can ship an app identity without depending on upstream JSON.
8. As a maintainer, I want pinned generation scripts, resource checks, tests,
   CI, and licence notices so that releases are reproducible and auditable.

## Implementation Decisions

### Package and modules

- Swift tools version is 6.0 with Swift 6 language mode and strict concurrency.
- The package exposes one library product named `Lexlight`.
- Public API files live in `Sources/Lexlight`; JavaScript resources live in
  `Sources/Lexlight/Resources`; generation inputs live in `scripts/highlights`.
- The package includes a DocC catalogue and a SwiftUI example app under
  `Examples/LexlightDemo`.

### Public Swift API

- `LexlightError` is a `Sendable` error with stable categories for missing
  resources, engine initialization, unsupported runtime, script evaluation,
  decoding, and cancelled work.
- `HighlightTheme` is a `Sendable` value with name, appearance, editor
  foreground/background, and syntax styles keyed by a typed `HighlightScope`.
  `HighlightStyle` carries optional RGBA colour, background colour, and font
  style flags.
- `ThemeRegistry` exposes the complete bundled theme catalogue, lookup by
  identifier, default light/dark selections, and custom-theme registration.
- `HighlightLanguage` is a raw-value value type with common static constants,
  alias normalization, and `plain` fallback.
- `HighlightToken` and `HighlightResult` are `Sendable` portable values.
  Offsets are UTF-16 code-unit offsets and preserve the source exactly.
- `Highlighter` is an async protocol. `ActorHighlighter` is the actor-backed
  implementation; `Lexlight.shared` is an explicit convenience.
- `highlighter.tokenize(_:)` returns a portable result.
  Main-actor extensions render the same result as `NSAttributedString` or
  `AttributedString` using a caller-supplied base font.
- All async entry points honor task cancellation and throw
  `LexlightError.cancelled` before returning partial output.
- `LexlightResources` exposes resource-bundle URLs for JavaScript and CSS and
  fails with a typed error when a packaged resource is missing.

### Engines

- `TokenizationEngine` is an internal async protocol with tokenization,
  language-list, and shutdown requirements.
- `JavaScriptCoreEngine` is actor-isolated and owns one `JSContext`; it probes
  for `WebAssembly.Module` before accepting the engine.
- `WebKitTokenizationEngine` is main-actor bound for `WKWebView` lifecycle but
  serializes requests through an internal request queue. It loads a local HTML
  shell containing the bundled tokenizer and evaluates a JSON-only bridge.
- Engine selection is automatic. macOS prefers JavaScriptCore. iOS probes
  JavaScriptCore first and falls back to WebKit when the Wasm module cannot be
  constructed. Diagnostics expose the selected engine to tests and logging.

### JavaScript contract

- The generated bundle installs `globalThis.Lexlight`.
- Public functions are `highlightElement`, `highlightAll`, `tokenize`,
  `supportedLanguages`, `normalizeLanguage`, `setTheme`, and `version`.
- `tokenize(code, language, themeID)` returns a JSON string matching the Swift
  decoding model. `highlightAll(root?, options?)` processes `pre code` blocks
  and supports `data-language`, `data-lang`, and `language-*`.
- Theme IDs are the same identifiers exposed by `ThemeRegistry`.
- The generated bundle is committed as `lexlight-highlights.js`; it must not be
  edited by hand.

### Bundles and themes

- `scripts/highlights/build.mjs` bundles `@pierre/highlights@0.2.0`, the
  `Lexlight` namespace wrapper, all language aliases, and the typed theme
  catalogue into one `es2020` IIFE.
- `pnpm-lock.yaml` pins npm build dependencies. `scripts/highlights/verify.mjs`
  checks the banner, upstream version, language count, theme count, and file
  hash metadata.
- Upstream LICENSE/NOTICE and Lexlight attribution live beside generated
  resources.

### Web and examples

- `LexlightResources.webViewScriptURL` and `webViewStylesheetURL` are stable
  public entry points; the host owns navigation and injection policy.
- `Examples/LexlightDemo` is a SwiftUI multiplatform application that displays
  native and WebView highlights, switches language and theme, and runs on
  macOS and iOS.

### CI and release

- CI runs `swift test` on macOS, builds and tests an iOS simulator destination,
  verifies Swift 6 strict concurrency, runs formatting/lint checks, builds DocC,
  regenerates JavaScript resources and checks for drift, and validates version
  metadata.
- Tag workflows verify `Package.swift`, `LexlightVersion.swift`, and the Git tag
  agree before creating a release.
- README files are English-first with a Chinese translation and top-level
  language links. API docs use DocC.

## Testing Decisions

External behaviour is tested through the public `Lexlight` product and through
the generated Web resource; internals are only exposed to tests via
`@testable import`.

- Public tokenization and cancellation: `Tests/LexlightTests/HighlighterTests.swift`
  uses `ActorHighlighter` and a fake `TokenizationEngine` seam to assert offsets,
  alias fallback, typed errors, cancellation, and Sendable result values.
- Theme and language contracts: `Tests/LexlightTests/ThemeRegistryTests.swift`
  and `LanguageTests.swift` assert registry completeness, deterministic IDs,
  custom-theme round trips, and `plain` fallback.
- Native rendering: `Tests/LexlightTests/RenderingTests.swift` renders a fixed
  token result into `NSAttributedString` and `AttributedString`, asserting exact
  source preservation, UTF-16 ranges, colour conversion, and font traits.
- Engine parity: `Tests/LexlightTests/EngineParityTests.swift` runs JavaScriptCore
  and WebKit engines against the same request on platforms where both are
  available and compares normalized token output.
- Web contract: `Tests/LexlightTests/WebResourceTests.swift` loads the generated
  bundle into a real `WKWebView`, calls `Lexlight.tokenize`, and checks
  `highlightAll`, theme switching, aliases, and plain fallback.
- Resource and generation checks: `scripts/highlights/verify.mjs`,
  `Tests/LexlightTests/ResourceTests.swift`, and CI shell steps anchor the
  prebuilt bundle, licence files, and drift checks.
- Example app: Xcode build-only CI gates for macOS and iOS anchor the public
  integration paths without requiring browser or visual verification.

Prior art is the macOS `HighlightsHighlighterTests` in ShiYue, especially its
UTF-16 emoji assertion and its real `WKWebView` theme-refresh test.

## Out of Scope

- Automatic language detection.
- Highlightr API compatibility.
- watchOS, tvOS, visionOS, Mac Catalyst, and macOlder than 14.
- Built-in SwiftUI code-block UI or editor components.
- Network downloads for languages or themes.
- Incremental/streaming tokenization.
- Visual/browser QA or screenshot-based comparison.

## Further Notes

- Wasm support in embedded iOS JavaScriptCore is treated as a runtime capability,
  not a compile-time assumption.
- The generated bundle's size is accepted as the cost of complete offline
  language support.
- The public JavaScript namespace is intentionally narrower than the upstream
  `@pierre/highlights` API.
- The initial repository has no product code; the current skeleton files are
  replaced by the implementation described here.
