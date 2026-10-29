/// Optional font traits carried by a highlight token or theme style.
public struct HighlightFontStyle: OptionSet, Hashable, Sendable, Codable {
    /// Bit mask used by the portable token model.
    public let rawValue: Int

    /// Creates a font-style mask.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Italic text.
    public static let italic = HighlightFontStyle(rawValue: 1)
    /// Bold text.
    public static let bold = HighlightFontStyle(rawValue: 2)
    /// Underlined text.
    public static let underline = HighlightFontStyle(rawValue: 4)
    /// Struck-through text.
    public static let strikethrough = HighlightFontStyle(rawValue: 8)
}
