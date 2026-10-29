import Lexlight
import SwiftUI

struct DemoView: View {
    @State private var model = DemoModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    controls
                    editor

                    if let errorMessage = model.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    }

                    if let result = model.result {
                        resultHeader(result)
                        adaptivePreviews
                    } else if model.isPreparing {
                        ProgressView("Starting Lexlight...")
                            .frame(maxWidth: .infinity)
                            .padding(30)
                    }
                }
                .padding(20)
            }
            .background(Color.demoPaper)
            .navigationTitle("Lexlight")
        }
        .task {
            await model.prepare()
        }
        .task(id: model.refreshKey) {
            guard !model.isPreparing else { return }
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            await model.refresh()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ONE TOKENIZER · TWO SURFACES")
                .font(.caption.weight(.semibold).monospaced())
                .tracking(1.5)
                .foregroundStyle(Color.demoAccent)
            Text("Native code, identical Web highlights.")
                .font(.system(size: 29, weight: .semibold, design: .serif))
            Text(
                "Edit once. Lexlight renders the same token stream with "
                    + "AttributedString, NSAttributedString, and a host-owned WKWebView."
            )
            .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                StatusPill(label: model.engineLabel, filled: true)
                StatusPill(label: "Resolved: \(model.resolvedLanguage)", filled: false)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LANGUAGE AND THEME")
                .font(.caption.weight(.semibold).monospaced())
                .tracking(1.2)
                .foregroundStyle(.secondary)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    languagePicker
                    themePicker
                }
                VStack(spacing: 10) {
                    languagePicker
                    themePicker
                }
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.08))
        }
    }

    private var languagePicker: some View {
        LabeledContent("Language") {
            Picker("Language", selection: $model.selectedLanguageID) {
                ForEach(DemoModel.languages) { language in
                    Text(language.title).tag(language.id)
                }
            }
            .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var themePicker: some View {
        LabeledContent("Theme") {
            Picker("Theme", selection: $model.selectedThemeID) {
                ForEach(model.themes) { theme in
                    Text(theme.name).tag(theme.id)
                }
            }
            .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("EDITABLE SOURCE", subtitle: "Selection drives every renderer below.")
            TextEditor(text: $model.source)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 170)
                .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.08))
                }
        }
    }

    private var adaptivePreviews: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 16) {
                nativePreview
                webPreview
            }
            VStack(spacing: 16) {
                nativePreview
                webPreview
            }
        }
    }

    private func resultHeader(_ result: HighlightResult) -> some View {
        HStack {
            Text("\(result.tokens.count) tokens")
            Spacer()
            Text("theme: \(result.themeID)")
        }
        .font(.caption.monospaced())
        .foregroundStyle(.secondary)
    }

    private var nativePreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(
                "NATIVE",
                subtitle: "SwiftUI AttributedString and platform NSAttributedString."
            )
            if let attributed = model.swiftUIAttributedString {
                ScrollView([.horizontal, .vertical]) {
                    Text(attributed)
                        .textSelection(.enabled)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 180, maxHeight: 280)
                .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
            }
            if let native = model.platformAttributedString {
                PlatformCodeView(attributedText: native)
                    .frame(minHeight: 180, maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .demoCard()
    }

    private var webPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(
                "WEBKIT",
                subtitle: "Host-owned WKWebView fed by LexlightResources."
            )
            HighlightedWebView(
                source: model.source,
                language: model.selectedLanguageID,
                theme: model.selectedTheme
            )
            .frame(minHeight: 380)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .demoCard()
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.bold).monospaced())
                .tracking(1)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct StatusPill: View {
    let label: String
    let filled: Bool

    var body: some View {
        Text(label)
            .font(.caption.monospaced())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                filled ? Color.demoAccent : Color.primary.opacity(0.07),
                in: Capsule()
            )
            .foregroundStyle(filled ? .white : .primary)
    }
}

private extension View {
    func demoCard() -> some View {
        padding(14)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.background, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.08))
            }
    }
}

private extension Color {
    static let demoPaper = Color(red: 0.965, green: 0.953, blue: 0.925)
    static let demoAccent = Color(red: 0.18, green: 0.42, blue: 0.39)
}
