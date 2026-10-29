/// The runtime currently executing Lexlight's JavaScript tokenizer.
public enum LexlightEngineKind: String, Sendable, Equatable {
    /// The embedded JavaScriptCore runtime.
    case javaScriptCore
    /// The fallback runtime hosted by an internal `WKWebView`.
    case webKit

    /// A display label suitable for diagnostics and examples.
    public var displayName: String {
        switch self {
        case .javaScriptCore:
            "JavaScriptCore"
        case .webKit:
            "WebKit"
        }
    }
}
