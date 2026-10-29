import XCTest

@testable import Lexlight

final class LanguageTests: XCTestCase {
    func testAliasesNormalize() {
        XCTAssertEqual(HighlightLanguage(identifier: " JS "), .javascript)
        XCTAssertEqual(HighlightLanguage(identifier: "language-ts"), .typescript)
        XCTAssertEqual(HighlightLanguage(identifier: "C++"), HighlightLanguage(rawValue: "cpp"))
        XCTAssertEqual(HighlightLanguage(identifier: "no-highlight"), .plain)
    }

    func testNilAndEmptyFallBackToPlain() {
        XCTAssertEqual(HighlightLanguage.normalize(nil), "plain")
        XCTAssertEqual(HighlightLanguage.normalize("   "), "plain")
    }
}
