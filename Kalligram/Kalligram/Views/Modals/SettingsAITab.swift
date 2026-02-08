import SwiftUI
import SwiftData

struct SettingsAITab: View {
    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings? { settingsQuery.first }

    var body: some View {
        Form {
            SwiftUI.Section("AI Provider") {
                if let settings {
                    Picker("Provider", selection: Bindable(settings).preferredAIProvider) {
                        Text("OpenRouter").tag("openrouter")
                        Text("Claude (Direct)").tag("claude")
                        Text("OpenAI (Direct)").tag("openai")
                    }
                    .pickerStyle(.segmented)

                    TextField("Model ID", text: Bindable(settings).preferredModel)
                        .textFieldStyle(.roundedBorder)
                        .font(Typography.bodySmall)
                }
            }

            if let settings {
                SwiftUI.Section("Models") {
                    Picker("Search Model", selection: Bindable(settings).searchModel) {
                        ForEach(AIModelCatalog.allModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Models shown in the dropdown")
                            .font(Typography.caption1)
                            .foregroundStyle(ColorPalette.textSecondary)

                        ForEach(AIModelCatalog.allModels, id: \.self) { model in
                            Toggle(model, isOn: modelSelectionBinding(model, settings: settings))
                                .font(Typography.bodySmall)
                        }
                    }
                }
            }

            SwiftUI.Section("API Keys") {
                APIKeyInputView(provider: "openrouter", label: "OpenRouter API Key")
                APIKeyInputView(provider: "claude", label: "Anthropic API Key")
                APIKeyInputView(provider: "openai", label: "OpenAI API Key")
            }

            SwiftUI.Section("Defaults") {
                if let settings {
                    Picker("Default Tone", selection: Bindable(settings).defaultAITone) {
                        ForEach(AITone.allCases, id: \.self) { tone in
                            Text(tone.displayName).tag(tone.rawValue)
                        }
                    }

                    Toggle("Enable Ghost Text", isOn: Bindable(settings).enableGhostText)
                }
            }
        }
        .formStyle(.grouped)
        .padding(Spacing.lg)
    }

    private func modelSelectionBinding(_ model: String, settings: UserSettings) -> Binding<Bool> {
        Binding(
            get: { selectedModelSet(settings).contains(model) },
            set: { isOn in
                updateModelSelection(model, isOn: isOn, settings: settings)
            }
        )
    }

    private func selectedModelSet(_ settings: UserSettings) -> Set<String> {
        let models = settings.modelPickerModels
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Set(models)
    }

    private func updateModelSelection(_ model: String, isOn: Bool, settings: UserSettings) {
        var set = selectedModelSet(settings)
        if isOn {
            set.insert(model)
        } else {
            set.remove(model)
            if set.isEmpty {
                set.insert(model)
            }
        }

        let ordered = AIModelCatalog.allModels.filter { set.contains($0) }
        settings.modelPickerModels = ordered.joined(separator: ",")

        if !set.contains(settings.preferredModel) {
            settings.preferredModel = ordered.first ?? settings.preferredModel
        }
    }
}
