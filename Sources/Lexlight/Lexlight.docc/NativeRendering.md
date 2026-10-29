# Native Rendering

Render the portable token stream with SwiftUI or AppKit/UIKit.

## SwiftUI

```swift
import Lexlight
import SwiftUI

struct CodeView: View {
    let result: HighlightResult

    var body: some View {
        Text(
            result.attributedString(
                baseFont: .system(.body, design: .monospaced)
            )
        )
        .textSelection(.enabled)
    }
}
```

``HighlightResult/attributedString(baseFont:defaultForeground:)`` applies the
base font first, then token colours and traits. It preserves the source string
exactly.

## AppKit and UIKit

```swift
let attributed = result.nsAttributedString(
    baseFont: LexlightFont.monospacedSystemFont(ofSize: 13, weight: .regular)
)
```

Use the platform text view directly:

- AppKit: assign to `NSTextStorage` in an `NSTextView`.
- UIKit: assign to `UITextView.attributedText`.

Both renderers consume the same token ranges. Offsets are UTF-16 code units, so
emoji and other surrogate pairs remain aligned with `NSRange`.
