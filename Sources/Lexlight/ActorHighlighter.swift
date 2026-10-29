/// The actor-backed production highlighter.
///
/// One instance serializes work through a single JavaScript runtime. Create a
/// highlighter when the screen or document is created and keep it for the
/// lifetime of that surface so tokenizer startup is paid once.
public actor ActorHighlighter: Highlighter {
    private let engine: any TokenizationEngine
    private let registry: ThemeRegistry
    private let defaultTheme: HighlightTheme
    private var cachedLanguages: [String]?

    init(
        engine: any TokenizationEngine,
        registry: ThemeRegistry,
        defaultTheme: HighlightTheme
    ) {
        self.engine = engine
        self.registry = registry
        self.defaultTheme = defaultTheme
    }

    /// Creates a highlighter and selects JavaScriptCore or WebKit automatically.
    ///
    /// - Parameter themeID: The default theme used when a request has no explicit theme.
    public init(
        themeID: String = "github-light"
    ) async throws {
        let registry = try ThemeRegistry.bundled()
        guard let theme = registry.theme(identifier: themeID) else {
            throw LexlightError.invalidTheme(themeID)
        }
        self.init(
            engine: try await EngineFactory.makeDefault(),
            registry: registry,
            defaultTheme: theme
        )
    }

    /// Returns a new shared-style highlighter using the default theme.
    ///
    /// The method creates an independent actor for each call. Keep a reference
    /// when repeated highlighting should share one engine instance.
    public static func shared() async throws -> ActorHighlighter {
        try await ActorHighlighter()
    }

    /// Reports which runtime is executing tokenization requests.
    public func activeEngine() async -> LexlightEngineKind {
        await engine.kind
    }

    /// Returns the language identifiers reported by the active runtime.
    public func supportedLanguages() async throws -> [String] {
        if let cachedLanguages {
            return cachedLanguages
        }
        try Task.checkCancellation()
        let languages = try await engine.supportedLanguages()
        try Task.checkCancellation()
        cachedLanguages = languages
        return languages
    }

    /// Tokenizes source while honoring Swift task cancellation.
    public func tokenize(
        _ source: String,
        language: HighlightLanguage,
        theme: HighlightTheme?
    ) async throws -> HighlightResult {
        try Task.checkCancellation()
        let resolvedTheme = theme ?? defaultTheme
        let request = EngineRequest(
            source: source,
            language: language.rawValue,
            theme: resolvedTheme
        )
        let result = try await engine.tokenize(request)
        try Task.checkCancellation()
        return HighlightResult(
            source: source,
            language: result.language,
            themeID: resolvedTheme.id,
            lines: result.lines,
            foreground: result.foreground,
            background: result.background
        )
    }

    /// Looks up a bundled theme by identifier.
    public func theme(identifier: String) throws -> HighlightTheme {
        guard let theme = registry.theme(identifier: identifier) else {
            throw LexlightError.invalidTheme(identifier)
        }
        return theme
    }
}
