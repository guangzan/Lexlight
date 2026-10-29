# Web Integration

Lexlight ships resources, not a WebView wrapper. Your app owns navigation,
content security policy, and script injection.

## Locate resources

```swift
let scriptURL = try LexlightResources.webViewScriptURL()
let stylesheetURL = try LexlightResources.webViewStylesheetURL()
```

You can also read UTF-8 strings for an existing document:

```swift
let script = try LexlightResources.javascript()
let stylesheet = try LexlightResources.stylesheet()
```

## JavaScript contract

The bundle installs `globalThis.Lexlight` with these functions:

- `tokenize(code, language, themeID)`
- `highlightElement(element, options)`
- `highlightAll(root, options)`
- `supportedLanguages()`
- `normalizeLanguage(language)`
- `setTheme(themeID)`
- `version`

Mark code as:

```html
<pre><code class="language-swift">let answer = 42</code></pre>
```

Then highlight supported blocks:

```javascript
Lexlight.highlightAll(document, { theme: "github-light" });
```

Blocks inside `[data-no-highlight]` and diagram languages such as Mermaid,
PlantUML, and Markmap are left untouched. Unknown languages resolve to `plain`.

## Theme switching

```javascript
Lexlight.setTheme("one-dark-pro");
Lexlight.highlightAll(document);
```

Theme identifiers are the same strings exposed by ``ThemeRegistry/themeIDs``.
