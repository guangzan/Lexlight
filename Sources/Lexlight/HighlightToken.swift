public struct HighlightToken: Hashable, Sendable, Codable {
    public let content: String
    public let offset: Int
    public let foreground: LexlightColor?
    public let background: LexlightColor?
    public let fontStyle: HighlightFontStyle

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
