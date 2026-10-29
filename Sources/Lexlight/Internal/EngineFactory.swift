enum EngineFactory {
    static func makeDefault() throws -> any TokenizationEngine {
        #if os(macOS)
        return try JavaScriptCoreEngine()
        #else
        throw LexlightError.runtimeUnavailable("WebKit fallback is not wired yet.")
        #endif
    }
}
