/// A typed syntax-highlighting theme shared by native and Web renderers.
///
/// `syntax` maps token scopes to visual styles. Lookups through ``style(for:)``
/// inherit from dotted parent scopes, so a theme can style `comment` once and
/// cover `comment.doc` unless the more specific scope is present.
public struct HighlightTheme: Hashable, Sendable, Codable, Identifiable {
    /// Stable identifier used by `ThemeRegistry` and the JavaScript bridge.
    public let id: String
    /// Human-readable theme name.
    public let name: String
    /// Whether the theme is designed for a light or dark surface.
    public let appearance: HighlightAppearance
    /// Default editor text colour.
    public let editorForeground: LexlightColor?
    /// Default editor background colour.
    public let editorBackground: LexlightColor?
    /// Styles keyed by typed syntax scope.
    public let syntax: [HighlightScope: HighlightStyle]

    /// Creates a theme value.
    public init(
        id: String,
        name: String,
        appearance: HighlightAppearance,
        editorForeground: LexlightColor?,
        editorBackground: LexlightColor?,
        syntax: [HighlightScope: HighlightStyle]
    ) {
        self.id = id
        self.name = name
        self.appearance = appearance
        self.editorForeground = editorForeground
        self.editorBackground = editorBackground
        self.syntax = syntax
    }

    /// Resolves a scope, falling back through dotted parent scopes.
    ///
    /// For example, a missing `.docComment` style tries `.comment`.
    public func style(for scope: HighlightScope) -> HighlightStyle? {
        var candidate = scope.rawValue
        while !candidate.isEmpty {
            if let style = syntax[HighlightScope(rawValue: candidate)] {
                return style
            }
            guard let dot = candidate.lastIndex(of: ".") else {
                break
            }
            candidate = String(candidate[..<dot])
        }
        return nil
    }
}
