import SwiftUI
import SwiftData

struct SettingsEditorTab: View {
    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings? { settingsQuery.first }

    var body: some View {
        Form {
            if let settings {
                SwiftUI.Section("Focus Mode") {
                    Toggle("Hide Word Count", isOn: Bindable(settings).focusModeHideWordCount)
                    Toggle("Hide Toolbar", isOn: Bindable(settings).focusModeHideToolbar)
                    Toggle("Typewriter Scrolling", isOn: Bindable(settings).typewriterScrolling)
                }

                SwiftUI.Section("Keyboard") {
                    Toggle("Smart Quotes", isOn: .constant(true))
                        .disabled(true)
                    Toggle("Smart Dashes", isOn: .constant(true))
                        .disabled(true)
                    Toggle("Spell Check", isOn: .constant(true))
                        .disabled(true)
                }
            }
        }
        .formStyle(.grouped)
        .padding(Spacing.lg)
    }
}
