import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
public extension HighlightResult {
    func nsAttributedString(baseFont: LexlightFont) -> NSAttributedString {
        let output = NSMutableAttributedString(string: source)
        let fullRange = NSRange(location: 0, length: output.length)
        let baseForeground = foreground?.platformColor
        let baseBackground = background?.platformColor

        if let baseForeground {
            output.addAttribute(.foregroundColor, value: baseForeground, range: fullRange)
        }
        if let baseBackground {
            output.addAttribute(.backgroundColor, value: baseBackground, range: fullRange)
        }
        output.addAttribute(.font, value: baseFont, range: fullRange)

        for token in tokens where !token.content.isEmpty {
            let range = NSRange(location: token.offset, length: token.content.utf16.count)
            guard range.location >= 0, NSMaxRange(range) <= output.length else {
                continue
            }
            if let color = token.foreground {
                output.addAttribute(.foregroundColor, value: color.platformColor, range: range)
            }
            if let color = token.background {
                output.addAttribute(.backgroundColor, value: color.platformColor, range: range)
            }
            if !token.fontStyle.isEmpty {
                output.addAttribute(
                    .font,
                    value: PlatformFont.applying(token.fontStyle, to: baseFont),
                    range: range
                )
            }
            if token.fontStyle.contains(.underline) {
                output.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: range
                )
            }
            if token.fontStyle.contains(.strikethrough) {
                output.addAttribute(
                    .strikethroughStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: range
                )
            }
        }
        return output
    }
}
