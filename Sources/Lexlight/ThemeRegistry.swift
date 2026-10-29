import Foundation

public struct ThemeRegistry: Sendable {
    private var themesByID: [String: HighlightTheme]
    private var orderedIDs: [String]

    public init(themes: [HighlightTheme] = []) {
        var byID: [String: HighlightTheme] = [:]
        var order: [String] = []
        for theme in themes {
            if byID.updateValue(theme, forKey: theme.id) == nil {
                order.append(theme.id)
            }
        }
        self.themesByID = byID
        self.orderedIDs = order
    }

    public static func bundled() throws -> ThemeRegistry {
        let url = try LexlightResources.themesURL()
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LexlightError.resourceMissing("themes.json")
        }
        let file: ThemeFile
        do {
            file = try JSONDecoder().decode(ThemeFile.self, from: data)
        } catch {
            throw LexlightError.decodingFailed("Invalid themes.json: \(error)")
        }
        return ThemeRegistry(themes: file.themes.map(\.highlightTheme))
    }

    public var allThemes: [HighlightTheme] {
        orderedIDs.compactMap { themesByID[$0] }
    }

    public var themeIDs: [String] {
        orderedIDs
    }

    public func theme(identifier: String) -> HighlightTheme? {
        themesByID[identifier]
    }

    public mutating func register(_ theme: HighlightTheme) {
        if themesByID.updateValue(theme, forKey: theme.id) == nil {
            orderedIDs.append(theme.id)
        }
    }
}

private struct ThemeFile: Decodable {
    let themes: [ThemeRecord]
}

private struct ThemeRecord: Decodable {
    let id: String
    let name: String
    let appearance: HighlightAppearance
    let foreground: String?
    let background: String?
    let syntax: [String: StyleRecord]

    var highlightTheme: HighlightTheme {
        HighlightTheme(
            id: id,
            name: name,
            appearance: appearance,
            editorForeground: foreground.flatMap(LexlightColor.init(hex:)),
            editorBackground: background.flatMap(LexlightColor.init(hex:)),
            syntax: Dictionary(
                uniqueKeysWithValues: syntax.map { scope, style in
                    (
                        HighlightScope(rawValue: scope),
                        HighlightStyle(
                            foreground: style.color.flatMap(LexlightColor.init(hex:)),
                            background: style.background.flatMap(LexlightColor.init(hex:)),
                            fontStyle: HighlightFontStyle(rawValue: style.fontStyle ?? 0)
                        )
                    )
                }
            )
        )
    }
}

private struct StyleRecord: Decodable {
    let color: String?
    let background: String?
    let fontStyle: Int?

    enum CodingKeys: String, CodingKey {
        case color
        case background
        case fontStyle = "font_style"
    }
}
