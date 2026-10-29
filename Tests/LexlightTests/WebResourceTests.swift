import WebKit
import XCTest

@testable import Lexlight

@MainActor
final class WebResourceTests: XCTestCase {
    func testGeneratedJavaScriptTokenizesAndHighlightsInWebKit() async throws {
        let webView = try makeWebView(
            body: """
                <pre><code id="code" class="language-swift">let answer = "42" // note</code></pre>
                <pre data-no-highlight><code id="skip" class="language-swift">let untouched = 1</code></pre>
                """
        )
        try await waitUntilReady(webView)

        let firstJSON = try await evaluateString(
            webView,
            "Lexlight.tokenize('let answer = 42', 'swift', 'github-light')"
        )
        let first = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: Data(firstJSON.utf8)) as? [String: Any]
        )
        XCTAssertEqual(first["language"] as? String, "swift")
        XCTAssertFalse((first["tokens"] as? [[Any]])?.isEmpty ?? true)

        let count = try await evaluateInt(
            webView,
            "Lexlight.highlightAll(document, { theme: 'github-light' })"
        )
        XCTAssertEqual(count, 1)
        let skipped = try await evaluateString(
            webView,
            "document.querySelector('#skip').textContent"
        )
        XCTAssertEqual(skipped, "let untouched = 1")
        let highlighted = try await evaluateString(
            webView,
            "document.querySelector('#code').dataset.highlighted"
        )
        XCTAssertEqual(highlighted, "yes")
        let spanCount = try await evaluateInt(
            webView,
            "document.querySelectorAll('#code span').length"
        )
        XCTAssertGreaterThan(spanCount, 0)

        let darkColor = try await evaluateString(
            webView,
            """
            (() => {
              Lexlight.setTheme('one-dark-pro');
              Lexlight.highlightAll(document);
              return document.querySelector('#code span').style.color;
            })()
            """
        )
        XCTAssertFalse(darkColor.isEmpty)

        let plainLanguage = try await evaluateString(
            webView,
            "Lexlight.normalizeLanguage('not-a-language')"
        )
        XCTAssertEqual(plainLanguage, "plain")
    }

    func testResourceHelpersExposeInjectionText() throws {
        XCTAssertTrue(try LexlightResources.javascript().contains("globalThis.Lexlight"))
        XCTAssertTrue(try LexlightResources.stylesheet().contains("pre code.hljs.highlights"))
    }

    private func makeWebView(body: String) throws -> WKWebView {
        let script = try LexlightResources.javascript()
        let base64 = Data(script.utf8).base64EncodedString()
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.loadHTMLString(
            """
            <!doctype html>
            <html>
            <head><meta charset="utf-8"></head>
            <body>
            \(body)
            <script>
              try {
                eval(atob("\(base64)"));
                window.__ready = typeof Lexlight === "object";
              } catch (error) {
                window.__error = String(error);
                window.__ready = false;
              }
            </script>
            </body>
            </html>
            """,
            baseURL: nil
        )
        return webView
    }

    private func waitUntilReady(_ webView: WKWebView) async throws {
        for _ in 0..<200 {
            if let ready = try? await webView.evaluateJavaScript("window.__ready === true"),
                ready as? Bool == true
            {
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        let error = try? await webView.evaluateJavaScript("window.__error")
        XCTFail("WebView did not become ready: \(String(describing: error))")
    }

    private func evaluateString(_ webView: WKWebView, _ script: String) async throws -> String {
        let value = try await webView.evaluateJavaScript(script)
        return try XCTUnwrap(value as? String)
    }

    private func evaluateInt(_ webView: WKWebView, _ script: String) async throws -> Int {
        let value = try await webView.evaluateJavaScript(script)
        return try XCTUnwrap(value as? Int)
    }
}
