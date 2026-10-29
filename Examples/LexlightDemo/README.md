# LexlightDemo

This SwiftUI executable is the integration example for Lexlight. It is not a
public package product.

It demonstrates:

- editable source and cancellable asynchronous highlighting;
- SwiftUI `AttributedString` and platform `NSAttributedString` rendering;
- a host-owned `WKWebView` using `LexlightResources`;
- synchronized language and theme selection;
- the active JavaScriptCore or WebKit engine;
- unknown-language fallback to `plain`.

Build the macOS target with:

```sh
xcodebuild -scheme LexlightDemo -destination 'platform=macOS' build
```

Build the iOS target with:

```sh
xcodebuild -scheme LexlightDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```
