# 0010: WebView integration as a resource, not a coordinator

## Status

Accepted

## Context

Lexlight must make the same tokenizer available to WebView previews, but the
host application owns its WKWebView, navigation policy, page lifecycle, and
JavaScript message handlers. A bundled coordinator would compete with those
responsibilities.

## Decision

Lexlight ships a stable JavaScript entry point and CSS as Swift Package
resources. Swift exposes resource URLs and lightweight helpers for locating and
loading those assets. The host is responsible for injecting them into its
WKWebView and calling the documented JavaScript API.

## Consequences

- Lexlight avoids owning or subclassing the host's WKWebView.
- Native and Web paths still share the same tokenizer, themes, and aliases.
- The JavaScript contract becomes part of Lexlight's public API and requires
  its own tests.
