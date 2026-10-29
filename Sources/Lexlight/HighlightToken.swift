/// One styled span in a highlighted source string.
public struct HighlightToken: Hashable, Sendable, Codable {
    /// Exact text covered by this token.
    public let content: String
    /// UTF-16 code-unit offset in the original source.
    public let offset: Int
    /// Foreground colour for this token.
    public let foreground: LexlightColor?
    /// Background colour for this token.
    public let background: LexlightColor?
    /// Optional font traits for this token.
    public let fontStyle: HighlightFontStyle

    /// Creates a token.
    public init(
        content: String,
        offset: Int,
        foreground: LexlightColor? = nil,
        background: LexlightColor? = nil,
        fontStyle: HighlightFontStyle = []
    ) {
        self.content = content
        self.offset = offset
        self.foreground = foreground
        self.background = background
        self.fontStyle = fontStyle
    }
}
