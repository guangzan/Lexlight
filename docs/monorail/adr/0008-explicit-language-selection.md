# 0008: Explicit language selection with plaintext fallback

## Status

Accepted

## Context

`@pierre/highlights` tokenizes a language selected by the caller and does not
provide automatic language detection. Lexlight must define predictable
behaviour for Markdown fences, untagged code blocks, aliases, and unknown
languages.

## Decision

Lexlight accepts an explicit language identifier, normalizes common aliases,
and falls back to `plain` when the language is omitted or unsupported. It does
not implement automatic language detection in its public surface.

## Consequences

- Native and WebView paths choose languages by the same rules.
- Untagged Markdown code remains readable and does not produce an error.
- Detection quality is not a hidden source of inconsistent highlighting.
- Automatic detection could be added later as a separate, explicitly named
  capability without changing the token contract.
