import SwiftUI
import SwiftData

struct SettingsExportTab: View {
    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings? { settingsQuery.first }

    var body: some View {
        Form {
            if let settings {
                SwiftUI.Section("Default Export") {
                    Picker("Default Format", selection: Bindable(settings).defaultExportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format.rawValue)
                        }
                    }

                    Picker("Paper Size", selection: Bindable(settings).defaultPaperSize) {
                        ForEach(PaperSize.allCases, id: \.self) { size in
                            Text(size.displayName).tag(size.rawValue)
                        }
                    }
                }

                SwiftUI.Section("Citations") {
                    Picker("Default Style", selection: Bindable(settings).defaultCitationStyle) {
                        ForEach(CitationStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style.rawValue)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding(Spacing.lg)
    }
}
