import XCTest

@testable import Lexlight

final class ThemeRegistryTests: XCTestCase {
    func testBundledRegistryLoadsTypedThemes() throws {
        let registry = try ThemeRegistry.bundled()
        XCTAssertGreaterThanOrEqual(registry.allThemes.count, 2)
        let light = try XCTUnwrap(registry.theme(identifier: "github-light"))
        XCTAssertEqual(light.appearance, .light)
        XCTAssertNotNil(light.syntax[.keyword]?.foreground)
        XCTAssertNotNil(light.syntax[.comment]?.fontStyle.contains(.italic))
    }

    func testCustomThemeRegistration() throws {
        let custom = HighlightTheme(
            id: "custom",
            name: "Custom",
            appearance: .dark,
            editorForeground: LexlightColor(hex: "#FFFFFF"),
            editorBackground: LexlightColor(hex: "#000000"),
            syntax: [.keyword: HighlightStyle(foreground: LexlightColor(hex: "#FF0000"))]
        )
        var registry = try ThemeRegistry.bundled()
        registry.register(custom)
        XCTAssertEqual(registry.theme(identifier: "custom"), custom)
    }

    func testScopeInheritance() {
        let theme = HighlightTheme(
            id: "test",
            name: "Test",
            appearance: .light,
            editorForeground: nil,
            editorBackground: nil,
            syntax: [.comment: HighlightStyle(foreground: LexlightColor(hex: "#777777"))]
        )
        XCTAssertNotNil(theme.style(for: .docComment))
    }
}
