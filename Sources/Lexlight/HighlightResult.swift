public struct HighlightResult: Hashable, Sendable {
    public let source: String
    public let language: String
    public let themeID: String
    public let lines: [[HighlightToken]]
    public let foreground: LexlightColor?
    public let background: LexlightColor?

    public init(
        source: String,
        language: String,
        themeID: String,
        lines: [[HighlightToken]],
        foreground: LexlightColor?,
        background: LexlightColor?
    ) {
        self.source = source
        self.language = language
        self.themeID = themeID
        self.lines = lines
        self.foreground = foreground
        self.background = background
    }

    public var tokens: [HighlightToken] {
        lines.flatMap { $0 }
    }
}
