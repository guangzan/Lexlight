public struct HighlightFontStyle: OptionSet, Hashable, Sendable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let italic = HighlightFontStyle(rawValue: 1)
    public static let bold = HighlightFontStyle(rawValue: 2)
    public static let underline = HighlightFontStyle(rawValue: 4)
    public static let strikethrough = HighlightFontStyle(rawValue: 8)
}
