# 0009: Instance-based highlighter with optional shared convenience

## Status

Accepted

## Context

A JavaScriptCore context and its Wasm instance have non-trivial startup and
memory cost. A process-wide singleton hides that lifetime from callers and
makes tests, multiple windows, and theme isolation harder to reason about.

## Decision

Lexlight exposes a `Highlighter` protocol and an actor-backed implementation
that callers create and retain. A shared instance may be offered as an explicit
convenience, but the core API does not require global state.

## Consequences

- Applications can scope highlighters to windows, documents, tests, or worker
  pipelines.
- Expensive JavaScriptCore state can be reused deliberately.
- Tests can create isolated instances and avoid cross-test state leakage.
