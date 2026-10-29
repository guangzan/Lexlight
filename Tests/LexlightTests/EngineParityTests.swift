import XCTest
@testable import Lexlight

@MainActor
final class EngineParityTests: XCTestCase {
    func testWebKitMatchesJavaScriptCoreForSwift() async throws {
        let registry = try ThemeRegistry.bundled()
        let theme = try XCTUnwrap(registry.theme(identifier: "github-light"))
        let source = #"let answer = "42" // note"#

        let jsEngine = try JavaScriptCoreEngine()
        let webEngine = try WebKitTokenizationEngine()
        let jsResult = try await jsEngine.tokenize(
            EngineRequest(source: source, language: "swift", theme: theme)
        )
        let webResult = try await webEngine.tokenize(
            EngineRequest(source: source, language: "swift", theme: theme)
        )

        XCTAssertEqual(jsResult.language, webResult.language)
        XCTAssertEqual(jsResult.lines, webResult.lines)
        XCTAssertEqual(jsResult.foreground, webResult.foreground)
        XCTAssertEqual(jsResult.background, webResult.background)
        await webEngine.shutdown()
    }

    func testDefaultFactoryPrefersJavaScriptCoreWhenAvailable() async throws {
        let engine = try await EngineFactory.makeDefault()
        let kind = await engine.kind
        XCTAssertEqual(kind, .javaScriptCore)
        await engine.shutdown()
    }
}
