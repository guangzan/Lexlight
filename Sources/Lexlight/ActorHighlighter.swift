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

    public static func shared() async throws -> ActorHighlighter {
        try await ActorHighlighter()
    }

    func activeEngine() async -> TokenizationEngineKind {
        await engine.kind
    }

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

    public func theme(identifier: String) throws -> HighlightTheme {
        guard let theme = registry.theme(identifier: identifier) else {
            throw LexlightError.invalidTheme(identifier)
        }
        return theme
    }
}
