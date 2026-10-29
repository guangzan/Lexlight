public protocol Highlighter: Sendable {
    func supportedLanguages() async throws -> [String]
    func tokenize(
        _ source: String,
        language: HighlightLanguage,
        theme: HighlightTheme?
    ) async throws -> HighlightResult
}

extension Highlighter {
    public func tokenize(
        _ source: String,
        language: HighlightLanguage = .plain
    ) async throws -> HighlightResult {
        try await tokenize(source, language: language, theme: nil)
    }
}
