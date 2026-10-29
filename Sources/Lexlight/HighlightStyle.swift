public struct HighlightStyle: Hashable, Sendable, Codable {
    public let foreground: LexlightColor?
    public let background: LexlightColor?
    public let fontStyle: HighlightFontStyle

    public init(
        foreground: LexlightColor? = nil,
        background: LexlightColor? = nil,
        fontStyle: HighlightFontStyle = []
    ) {
        self.foreground = foreground
        self.background = background
        self.fontStyle = fontStyle
    }
}
