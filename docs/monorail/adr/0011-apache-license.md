# 0011: License Lexlight under Apache-2.0

## Status

Accepted

## Context

Lexlight distributes a JavaScript/Wasm bundle derived from
`@pierre/highlights`, which is Apache-2.0. The package is intended for
production use by both open-source and commercial Apple applications.

## Decision

Lexlight itself is licensed under Apache-2.0. The repository preserves the
upstream Apache-2.0 LICENSE, NOTICE, attribution, and modification information
for the bundled dependency.

## Consequences

- The project licence and bundled dependency use the same legal framework.
- Consumers receive an explicit patent grant.
- Releases must retain the upstream notices and clearly distinguish Lexlight
  code from bundled third-party code.
