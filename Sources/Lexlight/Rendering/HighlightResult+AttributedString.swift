import Foundation
import SwiftUI

@MainActor
extension HighlightResult {
    /// Renders the token stream as a SwiftUI `AttributedString`.
    ///
    /// - Parameters:
    ///   - baseFont: Font applied to the full source before token traits.
    ///   - defaultForeground: Fallback when the result has no theme foreground.
    public func attributedString(
        baseFont: Font? = nil,
        defaultForeground: Color? = nil
    ) -> AttributedString {
        var output = AttributedString(source)
        let base: Font = baseFont ?? .system(.body, design: .monospaced)
        let fullRange = output.startIndex..<output.endIndex
        output[fullRange].font = base
        if let foreground {
            output[fullRange].foregroundColor = Color(
                red: Double(foreground.red) / 255,
                green: Double(foreground.green) / 255,
                blue: Double(foreground.blue) / 255,
                opacity: Double(foreground.alpha) / 255
            )
        } else if let defaultForeground {
            output[fullRange].foregroundColor = defaultForeground
        }
        if let background {
            output[fullRange].backgroundColor = Color(
                red: Double(background.red) / 255,
                green: Double(background.green) / 255,
                blue: Double(background.blue) / 255,
                opacity: Double(background.alpha) / 255
            )
        }

        for token in tokens where !token.content.isEmpty {
            let nsRange = NSRange(location: token.offset, length: token.content.utf16.count)
            guard let stringRange = Range(nsRange, in: source),
                let lower = AttributedString.Index(stringRange.lowerBound, within: output),
                let upper = AttributedString.Index(stringRange.upperBound, within: output)
            else {
                continue
            }
            let range = lower..<upper
            if let color = token.foreground {
                output[range].foregroundColor = Color(
                    red: Double(color.red) / 255,
                    green: Double(color.green) / 255,
                    blue: Double(color.blue) / 255,
                    opacity: Double(color.alpha) / 255
                )
            }
            if let color = token.background {
                output[range].backgroundColor = Color(
                    red: Double(color.red) / 255,
                    green: Double(color.green) / 255,
                    blue: Double(color.blue) / 255,
                    opacity: Double(color.alpha) / 255
                )
            }
            var tokenFont: Font = base
            if token.fontStyle.contains(.bold) {
                tokenFont = tokenFont.bold()
            }
            if token.fontStyle.contains(.italic) {
                tokenFont = tokenFont.italic()
            }
            if !token.fontStyle.isEmpty {
                output[range].font = tokenFont
            }
            if token.fontStyle.contains(.underline) {
                output[range].underlineStyle = Text.LineStyle.single
            }
            if token.fontStyle.contains(.strikethrough) {
                output[range].strikethroughStyle = Text.LineStyle.single
            }
        }
        return output
    }
}
