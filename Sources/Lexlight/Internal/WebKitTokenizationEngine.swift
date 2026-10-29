import Foundation
import WebKit

@MainActor
final class WebKitTokenizationEngine: TokenizationEngine {
    nonisolated let kind: LexlightEngineKind = .webKit

    private var webView: WKWebView?
    private var ready = false
    private var cachedLanguages: [String]?

    init(script: String? = nil) throws {
        let source: String
        if let script {
            source = script
        } else {
            source = try LexlightResources.javascript()
        }
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView = webView
        webView.loadHTMLString(
            Self.htmlShell(base64Script: Data(source.utf8).base64EncodedString()),
            baseURL: nil
        )
    }

    func supportedLanguages() async throws -> [String] {
        if let cachedLanguages {
            return cachedLanguages
        }
        try await waitUntilReady()
        try Task.checkCancellation()
        guard let value = try await evaluate("Lexlight.supportedLanguages()"),
            let languages = value as? [String]
        else {
            throw LexlightError.decodingFailed(
                "Lexlight.supportedLanguages() did not return strings."
            )
        }
        try Task.checkCancellation()
        cachedLanguages = languages
        return languages
    }

    func tokenize(_ request: EngineRequest) async throws -> EngineResult {
        try Task.checkCancellation()
        try await waitUntilReady()
        let themeJSON = try ThemeJSEncoder.encode(request.theme)
        guard let themeLiteral = Self.javascriptStringLiteral(themeJSON),
            let sourceLiteral = Self.javascriptStringLiteral(request.source),
            let languageLiteral = Self.javascriptStringLiteral(request.language)
        else {
            throw LexlightError.serializationFailed("Could not encode tokenizer arguments.")
        }
        let script = """
            Lexlight.tokenize(
              \(sourceLiteral),
              \(languageLiteral),
              JSON.parse(\(themeLiteral))
            )
            """
        guard let value = try await evaluate(script), let json = value as? String else {
            throw LexlightError.scriptEvaluationFailed("Lexlight.tokenize returned no string.")
        }
        try Task.checkCancellation()
        return try BridgeDecoder.decode(json, source: request.source, themeID: request.theme.id)
    }

    func shutdown() async {
        webView?.stopLoading()
        webView = nil
        ready = false
        cachedLanguages = nil
    }

    private func waitUntilReady() async throws {
        guard webView != nil else {
            throw LexlightError.engineInitializationFailed("WebKit engine was shut down.")
        }
        if ready { return }

        for _ in 0..<150 {
            try Task.checkCancellation()
            if let value = try? await evaluate("window.__lexlightReady === true"),
                value as? Bool == true
            {
                ready = true
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        throw LexlightError.engineInitializationFailed(
            "WebKit did not finish loading the Lexlight tokenizer."
        )
    }

    private func evaluate(_ script: String) async throws -> Any? {
        guard let webView else {
            throw LexlightError.engineInitializationFailed("WebKit engine was shut down.")
        }
        do {
            return try await webView.evaluateJavaScript(script)
        } catch {
            throw LexlightError.scriptEvaluationFailed(error.localizedDescription)
        }
    }

    private static func htmlShell(base64Script: String) -> String {
        """
        <!doctype html>
        <html>
        <head><meta charset="utf-8"></head>
        <body>
        <script>
        try {
          eval(atob("\(base64Script)"));
          window.__lexlightReady = typeof Lexlight === "object";
        } catch (error) {
          window.__lexlightError = String(error);
          window.__lexlightReady = false;
          console.error(error);
        }
        </script>
        </body>
        </html>
        """
    }

    private static func javascriptStringLiteral(_ value: String) -> String? {
        guard let data = try? JSONSerialization.data(
            withJSONObject: value,
            options: [.fragmentsAllowed]
        ) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
