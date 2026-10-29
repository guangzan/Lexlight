import Foundation
import JavaScriptCore

actor JavaScriptCoreEngine: TokenizationEngine {
    nonisolated let kind: TokenizationEngineKind = .javaScriptCore

    private var context: JSContext?
    private var cachedLanguages: [String]?

    init(script: String? = nil) throws {
        guard let context = JSContext() else {
            throw LexlightError.engineInitializationFailed("JSContext could not be created.")
        }
        self.context = context

        guard Self.supportsWebAssembly(in: context) else {
            throw LexlightError.runtimeUnavailable("JavaScriptCore has no WebAssembly support.")
        }

        let source: String
        if let script {
            source = script
        } else {
            source = try LexlightResources.javascript()
        }
        Self.evaluate(source, in: context)
        guard Self.isLexlightInstalled(in: context) else {
            throw LexlightError.engineInitializationFailed(
                "Bundled JavaScript did not install globalThis.Lexlight."
            )
        }
    }

    func supportedLanguages() async throws -> [String] {
        if let cachedLanguages {
            return cachedLanguages
        }
        try Task.checkCancellation()
        guard let context else {
            throw LexlightError.engineInitializationFailed("JavaScriptCore engine was shut down.")
        }
        let value = Self.call(
            "Lexlight.supportedLanguages()",
            in: context
        )
        guard let languages = value.toArray() as? [String] else {
            throw LexlightError.decodingFailed("supportedLanguages() did not return strings.")
        }
        try Task.checkCancellation()
        cachedLanguages = languages
        return languages
    }

    func tokenize(_ request: EngineRequest) async throws -> EngineResult {
        try Task.checkCancellation()
        guard let context else {
            throw LexlightError.engineInitializationFailed("JavaScriptCore engine was shut down.")
        }

        let themeJSON = try ThemeJSEncoder.encode(request.theme)
        let themeValue = try Self.parseJSON(themeJSON, in: context)
        guard let function = context.objectForKeyedSubscript("Lexlight")?
            .objectForKeyedSubscript("tokenize")
        else {
            throw LexlightError.engineInitializationFailed("Lexlight.tokenize is unavailable.")
        }

        context.exception = nil
        let value = function.call(withArguments: [
            request.source,
            request.language,
            themeValue,
        ])
        if let exception = context.exception {
            throw LexlightError.scriptEvaluationFailed(exception.toString() ?? "Unknown exception")
        }
        guard let json = value?.toString() else {
            throw LexlightError.scriptEvaluationFailed("Lexlight.tokenize returned no string.")
        }
        try Task.checkCancellation()
        return try BridgeDecoder.decode(json, source: request.source, themeID: request.theme.id)
    }

    func shutdown() async {
        context = nil
        cachedLanguages = nil
    }

    private static func supportsWebAssembly(in context: JSContext) -> Bool {
        context.exception = nil
        let result = context.evaluateScript(
            """
            (() => {
              try {
                if (typeof WebAssembly === 'undefined' ||
                    typeof WebAssembly.Module !== 'function') return false;
                new WebAssembly.Module(new Uint8Array([0,97,115,109,1,0,0,0]));
                return true;
              } catch (_) {
                return false;
              }
            })()
            """
        )
        return context.exception == nil && result?.toBool() == true
    }

    private static func evaluate(_ script: String, in context: JSContext) {
        context.exception = nil
        context.evaluateScript(script)
        if let exception = context.exception {
            assertionFailure("Lexlight JavaScript initialization failed: \(exception)")
        }
    }

    private static func isLexlightInstalled(in context: JSContext) -> Bool {
        context.exception = nil
        let object = context.evaluateScript(
            "typeof globalThis.Lexlight === 'object' && globalThis.Lexlight !== null"
        )
        return context.exception == nil && object?.toBool() == true
    }

    private static func call(_ script: String, in context: JSContext) -> JSValue {
        context.exception = nil
        let value = context.evaluateScript(script)
        if let exception = context.exception {
            return JSValue(newErrorFromMessage: exception.toString() ?? "JavaScript error", in: context)
        }
        return value ?? JSValue(undefinedIn: context)
    }

    private static func parseJSON(_ json: String, in context: JSContext) throws -> JSValue {
        context.exception = nil
        guard let literal = Self.javascriptStringLiteral(json) else {
            throw LexlightError.serializationFailed("Could not encode theme JSON.")
        }
        let value = context.evaluateScript("JSON.parse(\(literal))")
        if let exception = context.exception {
            throw LexlightError.scriptEvaluationFailed(exception.toString() ?? "Invalid theme JSON")
        }
        guard let value else {
            throw LexlightError.serializationFailed("Theme JSON produced no value.")
        }
        return value
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

enum ThemeJSEncoder {
    static func encode(_ theme: HighlightTheme) throws -> String {
        var style: [String: Any] = [:]
        if let foreground = theme.editorForeground {
            style["text"] = foreground.hexRGBA
            style["editor.foreground"] = foreground.hexRGBA
        }
        if let background = theme.editorBackground {
            style["background"] = background.hexRGBA
            style["editor.background"] = background.hexRGBA
        }
        var syntax: [String: Any] = [:]
        for (scope, value) in theme.syntax {
            var settings: [String: Any] = [:]
            if let color = value.foreground {
                settings["color"] = color.hexRGBA
            }
            if let background = value.background {
                settings["background"] = background.hexRGBA
            }
            if value.fontStyle.contains(.italic) {
                settings["font_style"] = "italic"
            }
            if value.fontStyle.contains(.bold) {
                settings["font_weight"] = 700
            }
            if !settings.isEmpty {
                syntax[scope.rawValue] = settings
            }
        }
        style["syntax"] = syntax

        let object: [String: Any] = [
            "name": theme.name,
            "appearance": theme.appearance.rawValue,
            "style": style,
        ]
        let data = try JSONSerialization.data(withJSONObject: object)
        guard let json = String(data: data, encoding: .utf8) else {
            throw LexlightError.serializationFailed("Theme produced invalid UTF-8.")
        }
        return json
    }
}

enum BridgeDecoder {
    private struct Response: Decodable {
        let tokens: [[Token]]
        let fg: String?
        let bg: String?
        let language: String?
    }

    private struct Token: Decodable {
        let content: String
        let offset: Int
        let color: String?
        let bgColor: String?
        let fontStyle: Int?
    }

    static func decode(_ json: String, source: String, themeID: String) throws -> EngineResult {
        guard let data = json.data(using: .utf8) else {
            throw LexlightError.decodingFailed("Tokenizer output is not UTF-8.")
        }
        let response: Response
        do {
            response = try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw LexlightError.decodingFailed("Invalid token JSON: \(error)")
        }
        let sourceLength = source.utf16.count
        let lines = try response.tokens.map { line in
            try line.map { token in
                let length = token.content.utf16.count
                guard token.offset >= 0, length >= 0, token.offset + length <= sourceLength else {
                    throw LexlightError.decodingFailed(
                        "Token range \(token.offset)..<\(token.offset + length) exceeds \(sourceLength)."
                    )
                }
                return HighlightToken(
                    content: token.content,
                    offset: token.offset,
                    foreground: token.color.flatMap(LexlightColor.init(hex:)),
                    background: token.bgColor.flatMap(LexlightColor.init(hex:)),
                    fontStyle: HighlightFontStyle(rawValue: token.fontStyle ?? 0)
                )
            }
        }
        return EngineResult(
            language: response.language ?? "plain",
            lines: lines,
            foreground: response.fg.flatMap(LexlightColor.init(hex:)),
            background: response.bg.flatMap(LexlightColor.init(hex:))
        )
    }
}
