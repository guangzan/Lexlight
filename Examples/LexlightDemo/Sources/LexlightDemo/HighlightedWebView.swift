import Lexlight
import SwiftUI
import WebKit

#if os(macOS)
struct HighlightedWebView: NSViewRepresentable {
    let source: String
    let language: String
    let theme: HighlightTheme?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        makeWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        update(webView, coordinator: context.coordinator)
    }
}
#else
struct HighlightedWebView: UIViewRepresentable {
    let source: String
    let language: String
    let theme: HighlightTheme?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        makeWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        update(webView, coordinator: context.coordinator)
    }
}
#endif

extension HighlightedWebView {
    final class Coordinator {
        var signature: String?
    }

    private var signature: String {
        "\(source.hashValue):\(language):\(theme?.id ?? "none")"
    }

    private func makeWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent()
        return WKWebView(frame: .zero, configuration: configuration)
    }

    private func update(_ webView: WKWebView, coordinator: Coordinator) {
        guard coordinator.signature != signature else { return }
        coordinator.signature = signature
        do {
            webView.loadHTMLString(try WebDocument.html(
                source: source,
                language: language,
                theme: theme
            ), baseURL: nil)
        } catch {
            webView.loadHTMLString(
                "<html><body style='font-family:monospace;padding:16px'>"
                    + "Unable to load Lexlight resources: \(WebDocument.escape(error.localizedDescription))"
                    + "</body></html>",
                baseURL: nil
            )
        }
    }
}

private enum WebDocument {
    static func html(source: String, language: String, theme: HighlightTheme?) throws -> String {
        let script = try LexlightResources.javascript()
        let stylesheet = try LexlightResources.stylesheet()
        let scriptBase64 = Data(script.utf8).base64EncodedString()
        let themeID = theme?.id ?? "github-light"
        let foreground = theme?.editorForeground?.hexRGBA ?? "#24292F"
        let background = theme?.editorBackground?.hexRGBA ?? "#FFFFFF"

        return """
            <!doctype html>
            <html>
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <style>
                :root { color-scheme: light dark; }
                html, body { margin: 0; min-height: 100%; background: \(background); color: \(foreground); }
                body {
                  box-sizing: border-box;
                  min-height: 100vh;
                  padding: 12px;
                  font-family: ui-monospace, "SFMono-Regular", Menlo, monospace;
                }
                pre { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; }
                code { font: inherit; line-height: 1.55; }
                \(stylesheet)
              </style>
            </head>
            <body>
              <pre><code class="language-\(escapeAttribute(language))">\(escape(source))</code></pre>
              <script>
                try {
                  eval(atob("\(scriptBase64)"));
                  Lexlight.highlightAll(document, { theme: "\(escapeJavaScript(themeID))" });
                } catch (error) {
                  document.body.textContent = "Web tokenization failed: " + error;
                }
              </script>
            </body>
            </html>
            """
    }

    static func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    static func escapeAttribute(_ value: String) -> String {
        escape(value)
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    static func escapeJavaScript(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
