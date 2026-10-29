# Lexlight Domain Glossary

## Terms

| Term | Meaning |
| --- | --- |
| Lexlight | The Swift package that exposes syntax highlighting for Apple platforms. |
| Token | A contiguous piece of source text with an optional foreground colour, background colour, and font style. |
| Native highlighter | The native-result path that tokenizes through JavaScriptCore or the iOS WebKit fallback and renders attributed text. |
| Web highlighter | The bundled JavaScript entry point that highlights DOM code blocks in a `WKWebView`. |
| Shared tokenizer | The single `@pierre/highlights` Wasm lexer bundle used by both native and Web highlighters. |
| Tokenization engine | The internal abstraction that loads the shared tokenizer bundle in JavaScriptCore or an internal `WKWebView`. |
| Theme registry | The typed Swift catalogue of bundled themes plus lookup and custom-theme registration. |
| Highlightr compatibility | A deliberate non-goal: Lexlight does not promise Highlightr API or behavioural parity. |
