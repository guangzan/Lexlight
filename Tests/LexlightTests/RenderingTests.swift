import SwiftUI
import XCTest
@testable import Lexlight

@MainActor
final class RenderingTests: XCTestCase {
    private var result: HighlightResult {
        HighlightResult(
            source: "let s = \"😀\"\nlet n = 1",
            language: "swift",
            themeID: "fixture",
            lines: [
                [
                    HighlightToken(
                        content: "let",
                        offset: 0,
                        foreground: LexlightColor(hex: "#A626A4"),
                        fontStyle: .bold
                    ),
                    HighlightToken(
                        content: " s = \"😀\"",
                        offset: 3,
                        foreground: LexlightColor(hex: "#50A14F")
                    ),
                    HighlightToken(
                        content: "\n",
                        offset: 11,
                        foreground: LexlightColor(hex: "#403E3C")
                    ),
                ],
                [
                    HighlightToken(
                        content: "let n = 1",
                        offset: 12,
                        foreground: LexlightColor(hex: "#403E3C"),
                        fontStyle: [.italic, .underline]
                    )
                ],
            ],
            foreground: LexlightColor(hex: "#403E3C"),
            background: LexlightColor(hex: "#FDFCF9")
        )
    }

    func testNSAttributedStringPreservesSourceAndAppliesRanges() throws {
        let attributed = result.nsAttributedString(baseFont: .monospacedSystemFont(ofSize: 13, weight: .regular))
        XCTAssertEqual(attributed.string, result.source)
        let range = NSRange(location: 0, length: 3)
        XCTAssertNotNil(attributed.attribute(.foregroundColor, at: 0, effectiveRange: nil))
        XCTAssertEqual(
            attributed.attribute(.underlineStyle, at: 12, effectiveRange: nil) as? Int,
            NSUnderlineStyle.single.rawValue
        )
        XCTAssertEqual(
            attributed.attributedSubstring(from: range).string,
            "let"
        )
    }

    func testSwiftUIAttributedStringPreservesSource() {
        let attributed = result.attributedString()
        XCTAssertEqual(String(attributed.characters), result.source)
        XCTAssertGreaterThan(attributed.runs.count, 1)
    }
}
