import Foundation
import Lexlight
import Observation

@MainActor
@Observable
final class DemoModel {
    struct LanguageChoice: Identifiable, Hashable {
        let id: String
        let title: String
    }

    static let languages = [
        LanguageChoice(id: "swift", title: "Swift"),
        LanguageChoice(id: "javascript", title: "JavaScript"),
        LanguageChoice(id: "typescript", title: "TypeScript"),
        LanguageChoice(id: "python", title: "Python"),
        LanguageChoice(id: "html", title: "HTML"),
        LanguageChoice(id: "css", title: "CSS"),
        LanguageChoice(id: "json", title: "JSON"),
        LanguageChoice(id: "bash", title: "Bash"),
        LanguageChoice(id: "not-a-language", title: "Unknown language"),
    ]

    var source = """
        struct Greeting: Sendable {
            let name: String

            func message() -> String {
                "Hello, \\(name)!" // Lexlight keeps native and Web output aligned.
            }
        }
        """
    var selectedLanguageID = "swift"
    var selectedThemeID = "github-light"
    var result: HighlightResult?
    var engineKind: LexlightEngineKind?
    var isPreparing = true
    var errorMessage: String?

    let themes: [HighlightTheme]
    private var registry: ThemeRegistry
    private var highlighter: ActorHighlighter?

    init() {
        let loadedRegistry = (try? ThemeRegistry.bundled()) ?? ThemeRegistry()
        registry = loadedRegistry
        themes = loadedRegistry.allThemes
        if loadedRegistry.theme(identifier: selectedThemeID) == nil {
            selectedThemeID =
                loadedRegistry.allThemes.first(where: { $0.appearance == .light })?.id
                ?? loadedRegistry.allThemes.first?.id
                ?? "github-light"
        }
    }

    var selectedLanguage: HighlightLanguage {
        HighlightLanguage(identifier: selectedLanguageID)
    }

    var selectedTheme: HighlightTheme? {
        registry.theme(identifier: selectedThemeID)
    }

    var resolvedLanguage: String {
        result?.language ?? selectedLanguage.rawValue
    }

    var engineLabel: String {
        guard let engineKind else { return "Detecting runtime..." }
        return "\(engineKind.displayName) engine"
    }

    var refreshKey: String {
        "\(source.hashValue):\(selectedLanguageID):\(selectedThemeID):\(isPreparing)"
    }

    var swiftUIAttributedString: AttributedString? {
        result?.attributedString()
    }

    var platformAttributedString: NSAttributedString? {
        result?.nsAttributedString(
            baseFont: LexlightFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        )
    }

    func prepare() async {
        guard highlighter == nil else { return }
        do {
            let highlighter = try await ActorHighlighter(themeID: selectedThemeID)
            self.highlighter = highlighter
            engineKind = await highlighter.activeEngine()
            isPreparing = false
            await refresh()
        } catch {
            isPreparing = false
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        guard let highlighter else { return }
        do {
            let tokenized = try await highlighter.tokenize(
                source,
                language: selectedLanguage,
                theme: selectedTheme
            )
            try Task.checkCancellation()
            result = tokenized
            errorMessage = nil
        } catch is CancellationError {
        } catch LexlightError.cancelled {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setTheme(_ identifier: String) {
        selectedThemeID = identifier
    }
}
