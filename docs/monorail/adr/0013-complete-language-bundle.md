# 0013: Ship the complete upstream language set

## Status

Accepted

## Context

`@pierre/highlights` bundles one WebAssembly lexer module and a language alias
table. Splitting languages would introduce downloads, cache invalidation, and
different results between offline and online use.

## Decision

Lexlight ships the complete upstream language set in the same bundled
resource. Language aliases are normalized inside Lexlight and unsupported
languages fall back to `plain`.

## Consequences

- Language behaviour stays aligned with the pinned upstream release.
- Consumers do not need network access or language-specific packages.
- The package carries the upstream bundle size as a fixed cost.
