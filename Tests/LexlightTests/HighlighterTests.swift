import XCTest
@testable import Lexlight

final class HighlighterTests: XCTestCase {
    func testTokenizeUsesRequestedThemeAndPreservesSource() async throws {
        let theme = HighlightTheme(
            id: "fixture",
            name: "Fixture",
            appearance: .light,
            editorForeground: LexlightColor(hex: "#111111"),
            editorBackground: LexlightColor(hex: "#FFFFFF"),
            syntax: [.keyword: HighlightStyle(foreground: LexlightColor(hex: "#AA0000"))]
        )
        let engine = FakeEngine()
        let highlighter = ActorHighlighter(
            engine: engine,
            registry: ThemeRegistry(themes: [theme]),
            defaultTheme: theme
        )

        let source = "let answer = 42"
        let result = try await highlighter.tokenize(source, language: .swift, theme: theme)

        XCTAssertEqual(result.source, source)
        XCTAssertEqual(result.themeID, "fixture")
        XCTAssertEqual(result.language, "swift")
        XCTAssertEqual(result.tokens.first?.content, "let")
        XCTAssertEqual(result.tokens.first?.offset, 0)
    }

    func testCancelledCallDoesNotReachEngine() async throws {
        let theme = try ThemeRegistry.bundled().theme(identifier: "github-light").unwrap()
        let engine = FakeEngine()
        let highlighter = ActorHighlighter(
            engine: engine,
            registry: ThemeRegistry(themes: [theme]),
            defaultTheme: theme
        )

        let task = Task {
            try await highlighter.tokenize("let x = 1", language: .swift, theme: theme)
        }
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
        } catch LexlightError.cancelled {
        }
        let callCount = await engine.callCount
        XCTAssertEqual(callCount, 0)
    }

    func testSupportedLanguagesAreCached() async throws {
        let theme = try ThemeRegistry.bundled().theme(identifier: "github-light").unwrap()
        let engine = FakeEngine()
        let highlighter = ActorHighlighter(
            engine: engine,
            registry: ThemeRegistry(themes: [theme]),
            defaultTheme: theme
        )

        _ = try await highlighter.supportedLanguages()
        _ = try await highlighter.supportedLanguages()

        let languageCallCount = await engine.languageCallCount
        XCTAssertEqual(languageCallCount, 1)
    }

    func testActiveEngineReportsBackingRuntime() async throws {
        let theme = try ThemeRegistry.bundled().theme(identifier: "github-light").unwrap()
        let highlighter = ActorHighlighter(
            engine: FakeEngine(),
            registry: ThemeRegistry(themes: [theme]),
            defaultTheme: theme
        )

        let kind = await highlighter.activeEngine()

        XCTAssertEqual(kind, .javaScriptCore)
        XCTAssertEqual(kind.displayName, "JavaScriptCore")
    }
}

private actor FakeEngine: TokenizationEngine {
    nonisolated var kind: LexlightEngineKind { .javaScriptCore }
    private(set) var callCount = 0
    private(set) var languageCallCount = 0

    func supportedLanguages() async throws -> [String] {
        languageCallCount += 1
        return ["plain", "swift"]
    }

    func tokenize(_ request: EngineRequest) async throws -> EngineResult {
        callCount += 1
        try Task.checkCancellation()
        return EngineResult(
            language: request.language,
            lines: [[
                HighlightToken(
                    content: "let",
                    offset: 0,
                    foreground: request.theme.syntax[.keyword]?.foreground
                ),
                HighlightToken(
                    content: String(request.source.dropFirst(3)),
                    offset: 3,
                    foreground: request.theme.editorForeground
                ),
            ]],
            foreground: request.theme.editorForeground,
            background: request.theme.editorBackground
        )
    }

    func shutdown() async {}
}

private extension Optional {
    func unwrap(file: StaticString = #filePath, line: UInt = #line) throws -> Wrapped {
        guard let self else {
            throw LexlightError.decodingFailed("Missing fixture at \(file):\(line)")
        }
        return self
    }
}
