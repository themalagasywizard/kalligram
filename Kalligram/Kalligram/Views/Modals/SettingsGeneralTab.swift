import SwiftUI
import SwiftData

struct SettingsGeneralTab: View {
    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings? { settingsQuery.first }

    var body: some View {
        Form {
            if let settings {
                SwiftUI.Section("Appearance") {
                    Picker("Color Scheme", selection: Bindable(settings).preferredColorScheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }

                SwiftUI.Section("Editor") {
                    TextField("Font Name", text: Bindable(settings).editorFontName)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Text("Font Size")
                        Slider(value: Bindable(settings).editorFontSize, in: 12...24, step: 1)
                        Text("\(Int(settings.editorFontSize)) pt")
                            .frame(width: 40)
                    }

                    Picker("Line Spacing", selection: Bindable(settings).defaultLineSpacing) {
                        Text("1.0").tag(1.0)
                        Text("1.15").tag(1.15)
                        Text("1.5").tag(1.5)
                        Text("2.0").tag(2.0)
                    }

                    Toggle("Show Word Count", isOn: Bindable(settings).showWordCount)
                    Toggle("Show Page Count", isOn: Bindable(settings).showPageCount)
                    Toggle("Typewriter Scrolling", isOn: Bindable(settings).typewriterScrolling)
                }

                SwiftUI.Section("Autosave") {
                    Picker("Interval", selection: Bindable(settings).autosaveIntervalSeconds) {
                        Text("15 seconds").tag(15)
                        Text("30 seconds").tag(30)
                        Text("60 seconds").tag(60)
                        Text("2 minutes").tag(120)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding(Spacing.lg)
    }
}
