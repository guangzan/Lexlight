public struct HighlightTheme: Hashable, Sendable, Codable, Identifiable {
    public let id: String
    public let name: String
    public let appearance: HighlightAppearance
    public let editorForeground: LexlightColor?
    public let editorBackground: LexlightColor?
    public let syntax: [HighlightScope: HighlightStyle]

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
