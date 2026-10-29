# Getting Started

Add one package product and create an actor-backed highlighter.

## Add the package

In Xcode, choose **File > Add Package Dependencies** and enter the GitHub
repository URL. Select the `Lexlight` library product. The package supports
macOS 14 and later, and iOS 17 and later.

For a `Package.swift` dependency:

```swift
.package(url: "https://github.com/guangzan/Lexlight.git", from: "1.0.0")
```

Then add `"Lexlight"` to the target's dependencies.

## Create a highlighter

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
```

Keep one ``ActorHighlighter`` per editor or document surface. One instance
serializes requests through one JavaScript runtime and pays tokenizer startup
once.

## Inspect the active runtime

```swift
let engine = await highlighter.activeEngine()
print(engine.displayName)
```

JavaScriptCore is preferred when it can construct a WebAssembly module. The
WebKit fallback is automatic and does not require a separate helper.

## Use the default theme

```swift
let result = try await highlighter.tokenize(code, language: .typescript)
```

Override the theme per request when a document can switch themes without
recreating the highlighter.
