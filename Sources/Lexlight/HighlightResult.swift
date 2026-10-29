/// Portable tokenization output that preserves the exact input source.
///
/// Token offsets are UTF-16 code-unit offsets, matching `NSRange` and
/// JavaScript string indexing on Apple platforms.
public struct HighlightResult: Hashable, Sendable {
    /// The exact source string supplied to the tokenizer.
    public let source: String
    /// The normalized language selected by the tokenizer.
    public let language: String
    /// The identifier of the theme used for this result.
    public let themeID: String
    /// Tokens grouped by source line.
    public let lines: [[HighlightToken]]
    /// Default foreground colour supplied by the theme.
    public let foreground: LexlightColor?
    /// Default background colour supplied by the theme.
    public let background: LexlightColor?

    /// Creates a tokenization result.
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

    /// All tokens flattened in source order.
    public var tokens: [HighlightToken] {
        lines.flatMap { $0 }
    }
}
