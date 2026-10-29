# 0006: Typed Swift themes at the public boundary

## Status

Accepted

## Context

`@pierre/highlights` exposes Zed-compatible theme objects with an evolving,
partially optional schema. Passing those raw objects through Lexlight would
make the upstream schema part of the package's public contract and would leave
Swift callers without compile-time validation.

## Decision

Lexlight exposes a Swift-native `HighlightTheme` model (with token styles,
appearance, editor colours, and upstream-compatible syntax scopes) plus a theme
registry. The package converts those values into the exact objects consumed by
the bundled JavaScript. The upstream theme catalogue may be generated or
imported into the registry, but raw upstream theme objects are an internal
adapter detail rather than the main public API.

## Consequences

- Lexlight controls its own semver boundary instead of exposing the upstream
  `0.x` theme schema directly.
- Themes can be validated, documented, and tested in Swift.
- Native and WebView paths consume one serialized theme representation.
- Upstream-only theme features require a deliberate Swift API addition when
  their behaviour must be supported.
