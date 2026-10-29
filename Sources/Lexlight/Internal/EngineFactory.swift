enum EngineFactory {
    static func makeDefault() throws -> any TokenizationEngine {
        throw LexlightError.runtimeUnavailable("No tokenization engine is available yet.")
    }
}
