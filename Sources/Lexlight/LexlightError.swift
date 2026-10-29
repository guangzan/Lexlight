import Foundation

public enum LexlightError: Error, Sendable, Equatable, LocalizedError {
    case resourceMissing(String)
    case engineInitializationFailed(String)
    case runtimeUnavailable(String)
    case scriptEvaluationFailed(String)
    case decodingFailed(String)
    case invalidTheme(String)
    case cancelled

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
        case .invalidTheme(let identifier):
            "Lexlight theme is unavailable: \(identifier)"
        case .cancelled:
            "Lexlight highlighting was cancelled."
        }
    }
}
