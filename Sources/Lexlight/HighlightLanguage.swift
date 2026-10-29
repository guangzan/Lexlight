/// A normalized language identifier used by the tokenizer.
///
/// Known aliases such as `js`, `ts`, `c++`, and `language-swift` normalize on
/// initialization. Unknown identifiers are retained by the value type and
/// become `plain` when the tokenizer compares them with its language list.
public struct HighlightLanguage: RawRepresentable, Hashable, Sendable, Codable, ExpressibleByStringLiteral {
    /// The normalized identifier.
    public let rawValue: String

    /// Creates a language and applies alias normalization.
    public init(rawValue: String) {
        self.rawValue = Self.normalize(rawValue)
    }

    /// Creates a language from a source identifier.
    public init(identifier: String) {
        self.init(rawValue: identifier)
    }

    /// Creates a language from a string literal.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    public static let plain = HighlightLanguage(rawValue: "plain")
    public static let swift = HighlightLanguage(rawValue: "swift")
    public static let javascript = HighlightLanguage(rawValue: "javascript")
    public static let js = HighlightLanguage(rawValue: "javascript")
    public static let typescript = HighlightLanguage(rawValue: "typescript")
    public static let ts = HighlightLanguage(rawValue: "typescript")
    public static let json = HighlightLanguage(rawValue: "json")
    public static let html = HighlightLanguage(rawValue: "html")
    public static let css = HighlightLanguage(rawValue: "css")
    public static let python = HighlightLanguage(rawValue: "python")
    public static let bash = HighlightLanguage(rawValue: "bash")

    /// Normalizes a language identifier, returning `plain` for nil or empty input.
    public static func normalize(_ value: String?) -> String {
        guard let value else { return "plain" }
        var candidate = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if candidate.hasPrefix("language-") {
            candidate.removeFirst("language-".count)
        }
        guard !candidate.isEmpty else { return "plain" }

        switch candidate {
        case "c#": return "csharp"
        case "c++": return "cpp"
        case "obj-c", "objc": return "objective-c"
        case "shellscript", "shell-session", "source-shell": return "shell"
        case "source-code", "no-highlight", "nohighlight": return "plain"
        case "js": return "javascript"
        case "ts": return "typescript"
        default: return candidate
        }
    }
}
