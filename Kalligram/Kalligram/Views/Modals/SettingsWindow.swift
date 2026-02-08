import SwiftUI

struct SettingsWindow: View {
    var body: some View {
        TabView {
            SettingsGeneralTab()
                .tabItem {
                    Label("General", systemImage: SFSymbolTokens.settings)
                }

            SettingsEditorTab()
                .tabItem {
                    Label("Editor", systemImage: "textformat")
                }

            SettingsAITab()
                .tabItem {
                    Label("AI", systemImage: SFSymbolTokens.ai)
                }

            SettingsExportTab()
                .tabItem {
                    Label("Export", systemImage: SFSymbolTokens.export)
                }
        }
        .frame(width: 520, height: 520)
    }
}
