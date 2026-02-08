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
}
