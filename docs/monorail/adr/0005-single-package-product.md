# 0005: One public Swift Package product

## Status

Accepted

## Context

Lexlight has several internal concerns: tokenization, JavaScriptCore, native
rendering, and WebView helpers. Exposing all of them as separate products would
make installation and documentation harder.

## Decision

The package exposes one library product named `Lexlight`. Internally, code is
split into focused modules or files that keep the portable core independent from
platform rendering.

## Consequences

- Consumers add one product dependency.
- Public API curation stays in one place.
- Internal module boundaries remain testable without becoming a public
  compatibility commitment in the supported scope.
