# 0004: Async token core with a MainActor rendering boundary

## Status

Accepted

## Context

JavaScriptCore and WebAssembly work can be expensive enough to stall a UI when
large code blocks are highlighted. Swift 6 concurrency checks also make a
main-actor-only synchronous API awkward for reusable package code.

## Decision

Lexlight exposes an asynchronous tokenization core. Its JavaScriptCore context
is owned by a dedicated actor and calls are serialized there. Platform-specific
`NSAttributedString` rendering is a `MainActor` convenience layer over the
portable token result.

## Consequences

- The public core can be called off the main thread and tested without UI
dependencies.
- There is no separate synchronous public API.
- Rendering still happens on the main actor for AppKit and UIKit clients.
