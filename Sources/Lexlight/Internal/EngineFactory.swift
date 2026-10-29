enum EngineFactory {
    static func makeDefault() async throws -> any TokenizationEngine {
        do {
            return try JavaScriptCoreEngine()
        } catch {
            do {
                return try await WebKitTokenizationEngine()
            } catch let fallbackError {
                throw LexlightError.runtimeUnavailable(
                    "JavaScriptCore: \(error.localizedDescription); WebKit: \(fallbackError.localizedDescription)"
                )
            }
        }
    }
}
