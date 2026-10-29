struct EngineRequest: Sendable {
    let source: String
    let language: String
    let theme: HighlightTheme
}

struct EngineResult: Sendable {
    let language: String
    let lines: [[HighlightToken]]
    let foreground: LexlightColor?
    let background: LexlightColor?
}

enum TokenizationEngineKind: String, Sendable, Equatable {
    case javaScriptCore
    case webKit
}

protocol TokenizationEngine: Sendable {
    var kind: TokenizationEngineKind { get async }
    func supportedLanguages() async throws -> [String]
    func tokenize(_ request: EngineRequest) async throws -> EngineResult
    func shutdown() async
}
