/// The runtime currently executing Lexlight's JavaScript tokenizer.
public enum LexlightEngineKind: String, Sendable, Equatable {
    case javaScriptCore
    case webKit

    public var displayName: String {
        switch self {
        case .javaScriptCore:
            "JavaScriptCore"
        case .webKit:
            "WebKit"
        }
    }
}
