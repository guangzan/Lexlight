# 0001: macOS 14 and iOS 17 platform floor

## Status

Accepted

## Context

Lexlight is a new Swift package for syntax highlighting on Apple platforms. The
first release must choose a deployment floor before the public API, concurrency
model, and test matrix are specified.

## Decision

Supported platforms are macOS 14+ and iOS 17+. Older Apple platforms are
out of scope for the current supported scope.

## Consequences

- The package can use modern Swift and Apple platform APIs without carrying
  compatibility shims for older OS versions.
- The test matrix covers macOS 14+ and iOS 17+ only.
- Supporting macOS 12+ or iOS 15+ later requires an explicit compatibility
  review rather than being assumed.
