import Foundation

/// Stable error categories thrown by Lexlight's public API.
public enum LexlightError: Error, Sendable, Equatable, LocalizedError {
    /// A packaged JavaScript, CSS, theme, or manifest asset is missing.
    case resourceMissing(String)
    /// A tokenization runtime failed to initialize.
    case engineInitializationFailed(String)
    /// Neither JavaScriptCore nor WebKit can execute the tokenizer.
    case runtimeUnavailable(String)
    /// JavaScript evaluation failed after a runtime was initialized.
    case scriptEvaluationFailed(String)
    /// Tokenizer output could not be decoded into Swift values.
    case decodingFailed(String)
    /// Input could not be serialized for the JavaScript bridge.
    case serializationFailed(String)
    /// A requested theme identifier is not registered.
    case invalidTheme(String)
    /// The enclosing Swift task was cancelled.
    case cancelled

    /// A human-readable error description suitable for logs and diagnostics.
    public var errorDescription: String? {
        switch self {
        case .resourceMissing(let name):
            "Lexlight resource is missing: \(name)"
        case .engineInitializationFailed(let reason):
            "Lexlight tokenization engine could not start: \(reason)"
        case .runtimeUnavailable(let reason):
            "No Lexlight tokenization runtime is available: \(reason)"
        case .scriptEvaluationFailed(let reason):
            "Lexlight JavaScript evaluation failed: \(reason)"
        case .decodingFailed(let reason):
            "Lexlight could not decode tokenizer output: \(reason)"
        case .serializationFailed(let reason):
            "Lexlight could not serialize tokenizer input: \(reason)"
        case .invalidTheme(let identifier):
            "Lexlight theme is unavailable: \(identifier)"
        case .cancelled:
            "Lexlight highlighting was cancelled."
        }
    }
}
