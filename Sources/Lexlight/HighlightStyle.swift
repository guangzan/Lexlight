/// Visual attributes applied to one syntax scope.
public struct HighlightStyle: Hashable, Sendable, Codable {
    /// Optional foreground colour.
    public let foreground: LexlightColor?
    /// Optional background colour.
    public let background: LexlightColor?
    /// Optional bold, italic, underline, or strikethrough traits.
    public let fontStyle: HighlightFontStyle

    /// Creates a syntax style.
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
