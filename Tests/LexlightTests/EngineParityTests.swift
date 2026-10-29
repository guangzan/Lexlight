import XCTest

@testable import Lexlight

@MainActor
final class EngineParityTests: XCTestCase {
    func testWebKitMatchesJavaScriptCoreForSwift() async throws {
        let registry = try ThemeRegistry.bundled()
        let theme = try XCTUnwrap(registry.theme(identifier: "github-light"))
        let source = #"let answer = "42" // note"#

        let jsEngine: JavaScriptCoreEngine
        do {
            jsEngine = try JavaScriptCoreEngine()
        } catch {
            throw XCTSkip("JavaScriptCore WebAssembly is unavailable: \(error)")
        }
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
        let javaScriptCoreIsAvailable = (try? JavaScriptCoreEngine()) != nil
        let engine = try await EngineFactory.makeDefault()
        let kind = await engine.kind
        XCTAssertEqual(kind, javaScriptCoreIsAvailable ? .javaScriptCore : .webKit)
        await engine.shutdown()
    }

    func testFactoryFallsBackToWebKitWhenJavaScriptCoreInitializationFails() async throws {
        let engine = try await EngineFactory.makeDefault(
            javaScriptCoreScript: #"throw new Error("unsupported WebAssembly module")"#
        )
        let kind = await engine.kind

        XCTAssertEqual(kind, .webKit)
        let languages = try await engine.supportedLanguages()
        XCTAssertTrue(languages.contains("swift"))
        await engine.shutdown()
    }
}
