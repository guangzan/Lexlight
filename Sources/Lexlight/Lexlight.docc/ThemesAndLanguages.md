# Themes and Languages

Themes and language identifiers form the shared contract between Swift and
JavaScript.

## Load themes

```swift
let registry = try ThemeRegistry.bundled()
let theme = registry.theme(identifier: "github-light")
```

``ThemeRegistry`` preserves a deterministic display order and includes the full
usable catalogue generated from `@pierre/highlights`.

## Build a custom theme

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

Use ``ThemeRegistry/register(_:)`` to make a custom theme available for lookup
in a registry, then pass the ``HighlightTheme`` to a tokenization request.

## Language normalization

``HighlightLanguage`` normalizes common source identifiers:

- `js`, `JS`, and `language-js` become `javascript`
- `ts` becomes `typescript`
- `c++` becomes `cpp`
- `objc` becomes `objective-c`
- empty or `no-highlight` become `plain`

Lexlight does not auto-detect languages. Pass a language from your parser,
Markdown fence info string, or editor state. An unknown identifier falls back to
`plain` in both the native and Web tokenizers.
