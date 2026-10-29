import Foundation

/// Packaged JavaScript, CSS, and theme assets for host-owned WebViews.
///
/// Lexlight does not create or retain a `WKWebView`. Hosts decide when to load,
/// inject, cache, or reload these resources.
public enum LexlightResources {
    /// The Swift package resource bundle containing Lexlight's generated assets.
    public static var bundle: Bundle {
        .module
    }

    /// JavaScript that installs `globalThis.Lexlight` in a browser document.
    public static func javascriptURL() throws -> URL {
        try resource(named: "lexlight-highlights", extension: "js")
    }

    /// Alias for ``javascriptURL()`` that names the intended WebView use.
    public static func webViewScriptURL() throws -> URL {
        try javascriptURL()
    }

    /// Baseline stylesheet for highlighted `pre code` blocks.
    public static func stylesheetURL() throws -> URL {
        try resource(named: "lexlight", extension: "css")
    }

    /// Alias for ``stylesheetURL()`` that names the intended WebView use.
    public static func webViewStylesheetURL() throws -> URL {
        try stylesheetURL()
    }

    /// The typed theme catalogue serialized for Swift.
    public static func themesURL() throws -> URL {
        try resource(named: "themes", extension: "json")
    }

    /// Reads the generated JavaScript as UTF-8 for host-owned injection.
    public static func javascript() throws -> String {
        do {
            return try String(contentsOf: javascriptURL(), encoding: .utf8)
        } catch let error as LexlightError {
            throw error
        } catch {
            throw LexlightError.resourceMissing("lexlight-highlights.js")
        }
    }

    /// Reads the baseline stylesheet as UTF-8 for host-owned injection.
    public static func stylesheet() throws -> String {
        do {
            return try String(contentsOf: stylesheetURL(), encoding: .utf8)
        } catch let error as LexlightError {
            throw error
        } catch {
            throw LexlightError.resourceMissing("lexlight.css")
        }
    }

    private static func resource(named name: String, extension ext: String) throws -> URL {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw LexlightError.resourceMissing("\(name).\(ext)")
        }
        return url
    }
}
