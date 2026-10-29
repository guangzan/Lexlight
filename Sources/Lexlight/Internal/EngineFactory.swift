enum EngineFactory {
    static func makeDefault(
        javaScriptCoreScript: String? = nil,
        webKitScript: String? = nil
    ) async throws -> any TokenizationEngine {
        do {
            return try JavaScriptCoreEngine(script: javaScriptCoreScript)
        } catch {
            do {
                return try await WebKitTokenizationEngine(script: webKitScript)
            } catch let fallbackError {
                throw LexlightError.runtimeUnavailable(
                    "JavaScriptCore: \(error.localizedDescription); WebKit: \(fallbackError.localizedDescription)"
                )
            }
        }
    }
}
