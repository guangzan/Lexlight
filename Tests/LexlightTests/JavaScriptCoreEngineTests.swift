import XCTest

@testable import Lexlight

final class JavaScriptCoreEngineTests: XCTestCase {
    func testBundledTokenizerHighlightsSwift() async throws {
        let registry = try ThemeRegistry.bundled()
        let theme = try XCTUnwrap(registry.theme(identifier: "github-light"))
        let engine = try makeEngine()
        let highlighter = ActorHighlighter(
            engine: engine,
            registry: registry,
            defaultTheme: theme
        )

        let result = try await highlighter.tokenize(
            #"let answer = "42" // note"#,
            language: .swift,
            theme: theme
        )

        XCTAssertEqual(result.language, "swift")
        XCTAssertEqual(result.tokens.map(\.content).joined(), #"let answer = "42" // note"#)
        XCTAssertFalse(result.foreground == nil)
        let comment = try XCTUnwrap(
            result.tokens.first(where: { $0.content.contains("// note") })
        )
        XCTAssertNotNil(comment.foreground)
    }

    func testUTF16OffsetsSurviveEmoji() async throws {
        let registry = try ThemeRegistry.bundled()
        let theme = try XCTUnwrap(registry.theme(identifier: "github-light"))
        let highlighter = ActorHighlighter(
            engine: try makeEngine(),
            registry: registry,
            defaultTheme: theme
        )

        let source = #"let s = "😀"; let n = 1"#
        let result = try await highlighter.tokenize(source, language: .swift, theme: theme)
        XCTAssertEqual(result.source.utf16.count, source.utf16.count)
        XCTAssertEqual(result.tokens.map(\.content).joined(), source)
        XCTAssertTrue(
            result.tokens.allSatisfy { $0.offset >= 0 && $0.offset < source.utf16.count || $0.content.isEmpty })
    }

    func testUnknownLanguageFallsBackToPlain() async throws {
        let registry = try ThemeRegistry.bundled()
        let theme = try XCTUnwrap(registry.theme(identifier: "github-light"))
        let highlighter = ActorHighlighter(
            engine: try makeEngine(),
            registry: registry,
            defaultTheme: theme
        )

        let result = try await highlighter.tokenize(
            "plain text",
            language: HighlightLanguage(identifier: "not-a-language"),
            theme: theme
        )
        XCTAssertEqual(result.language, "plain")
        XCTAssertEqual(result.tokens.map(\.content).joined(), "plain text")
    }

    func testSupportedLanguagesComeFromTheBundle() async throws {
        let engine = try makeEngine()
        let languages = try await engine.supportedLanguages()
        XCTAssertTrue(languages.contains("swift"))
        XCTAssertTrue(languages.contains("typescript"))
        XCTAssertGreaterThan(languages.count, 100)
    }

    private func makeEngine() throws -> JavaScriptCoreEngine {
        do {
            return try JavaScriptCoreEngine()
        } catch {
            throw XCTSkip("JavaScriptCore WebAssembly is unavailable: \(error)")
        }
    }
}
