# 0007: Portable token result with AppKit and SwiftUI renderers

## Status

Accepted

## Context

Callers need different native representations: AppKit and UIKit editors expect
`NSAttributedString`, while SwiftUI prefers `AttributedString`. Keeping token
generation inside either renderer would tie syntax highlighting to one UI
framework.

## Decision

Lexlight exposes a portable `HighlightResult` token model as the shared output
of the highlighter. It provides native rendering adapters for both
`NSAttributedString` and `AttributedString`, with AppKit/UIKit and SwiftUI
attribute mapping kept at the edge.

## Consequences

- The tokenization core remains UI-framework independent and sendable.
- AppKit/UIKit and SwiftUI integrations share the same token data.
- Renderer behaviour can be tested separately from JavaScriptCore and theme
  serialization.
