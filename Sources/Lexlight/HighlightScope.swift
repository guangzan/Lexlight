/// A typed syntax scope such as `keyword`, `string`, or `comment.doc`.
///
/// The type is extensible: custom themes may use any string scope.
public struct HighlightScope: RawRepresentable, Hashable, Sendable, Codable, ExpressibleByStringLiteral {
    /// The scope text used by theme data.
    public let rawValue: String

    /// Creates a scope from its theme identifier.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a scope from a string literal.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    public static let attribute: Self = "attribute"
    public static let boolean: Self = "boolean"
    public static let comment: Self = "comment"
    public static let docComment: Self = "comment.doc"
    public static let constant: Self = "constant"
    public static let constructor: Self = "constructor"
    public static let embedded: Self = "embedded"
    public static let enumeration: Self = "enum"
    public static let function: Self = "function"
    public static let functionMethod: Self = "function.method"
    public static let keyword: Self = "keyword"
    public static let keywordOperator: Self = "keyword.operator"
    public static let label: Self = "label"
    public static let linkText: Self = "link_text"
    public static let linkURI: Self = "link_uri"
    public static let number: Self = "number"
    public static let `operator`: Self = "operator"
    public static let preprocessor: Self = "preproc"
    public static let primary: Self = "primary"
    public static let property: Self = "property"
    public static let jsonKey: Self = "property.json_key"
    public static let punctuation: Self = "punctuation"
    public static let punctuationBracket: Self = "punctuation.bracket"
    public static let punctuationDelimiter: Self = "punctuation.delimiter"
    public static let punctuationListMarker: Self = "punctuation.list_marker"
    public static let punctuationSpecial: Self = "punctuation.special"
    public static let string: Self = "string"
    public static let stringEscape: Self = "string.escape"
    public static let stringRegex: Self = "string.regex"
    public static let stringSpecial: Self = "string.special"
    public static let tag: Self = "tag"
    public static let textLiteral: Self = "text.literal"
    public static let title: Self = "title"
    public static let type: Self = "type"
    public static let typeBuiltin: Self = "type.builtin"
    public static let variable: Self = "variable"
    public static let variableBuiltin: Self = "variable.builtin"
    public static let variableParameter: Self = "variable.parameter"
    public static let variableSpecial: Self = "variable.special"
    public static let variant: Self = "variant"
    public static let namespace: Self = "namespace"
    public static let selector: Self = "selector"
    public static let diffMinus: Self = "diff.minus"
    public static let diffPlus: Self = "diff.plus"
    public static let selectorClass: Self = "selector.class"
    public static let selectorID: Self = "selector.id"
    public static let selectorPseudo: Self = "selector.pseudo"
}
