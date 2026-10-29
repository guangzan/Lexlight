# 0002: Commit the prebuilt JavaScript bundle

## Status

Accepted

## Context

The highlighter depends on `@pierre/highlights` and a JavaScriptCore-compatible
polyfill layer. Requiring consumers to run Node.js would make a Swift package
depend on a toolchain unrelated to its public API and would make releases hard
to audit.

## Decision

Lexlight commits the generated JavaScript bundle as a Swift Package resource.
The repository also keeps the reproducible build scripts, the pinned npm
dependency metadata, and the upstream Apache-2.0 LICENSE/NOTICE files.

## Consequences

- Consumers need no Node.js toolchain.
- Each release can be audited against its pinned upstream version.
- The generated file must not be edited by hand; source changes go through the
  build scripts.
- Updating `@pierre/highlights` requires regenerating the bundle, rerunning the
  WebKit and JavaScriptCore tests, and updating the recorded upstream version.
