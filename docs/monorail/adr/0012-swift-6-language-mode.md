# 0012: Swift 6 language mode with strict concurrency

## Status

Accepted

## Context

Lexlight targets macOS 14+ and iOS 17+, and its core crosses actor, async, and
JavaScriptCore boundaries. Allowing legacy concurrency behaviour would hide
data-race risks in the public API and tests.

## Decision

The package uses `swift-tools-version: 6.0` and Swift 6 language mode with
strict concurrency checking enabled. Public value types that cross actor
boundaries conform to `Sendable`; JavaScriptCore remains isolated behind an
actor.

## Consequences

- The package API is designed for current Swift concurrency rather than
  retrofitted later.
- CI must build with a Swift 6 compiler.
- Any non-sendable platform rendering type stays on its proper actor boundary.
