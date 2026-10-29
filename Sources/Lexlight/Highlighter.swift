/// Asynchronous syntax-highlighting interface shared by all Lexlight engines.
public protocol Highlighter: Sendable {
    /// Returns the tokenizer's supported normalized language identifiers.
    func supportedLanguages() async throws -> [String]
    /// Tokenizes source using an explicit language and optional theme.
    func tokenize(
        _ source: String,
        language: HighlightLanguage,
        theme: HighlightTheme?
    ) async throws -> HighlightResult
}

extension Highlighter {
    /// Tokenizes source with an explicit language and the highlighter's default theme.
    public func tokenize(
        _ source: String,
        language: HighlightLanguage = .plain
    ) async throws -> HighlightResult {
        try await tokenize(source, language: language, theme: nil)
    }
}
