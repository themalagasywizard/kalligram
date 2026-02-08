import SwiftUI

struct MainToolbar: ToolbarContent {
    @Environment(AppState.self) private var appState
    @Environment(AppViewModel.self) private var appViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                appState.isNewDocumentSheetPresented = true
            } label: {
                Image(systemName: SFSymbolTokens.newDocument)
            }
            .help("New Document (Cmd+N)")
            .keyboardShortcut("n", modifiers: .command)
        }

        ToolbarItem(placement: .primaryAction) {
            Menu {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Button {
                        if let doc = appViewModel.selectedDocument {
                            doc.viewModeEnum = mode
                        }
                    } label: {
                        HStack {
                            Label(mode.displayName, systemImage: mode.iconName)
                            if appViewModel.selectedDocument?.viewModeEnum == mode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: SFSymbolTokens.viewMode)
            }
            .help("View Mode")
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                withAnimation(AnimationTokens.standard) {
                    appState.isFocusModeActive.toggle()
                }
            } label: {
                Image(systemName: SFSymbolTokens.focusMode)
                    .symbolVariant(appState.isFocusModeActive ? .fill : .none)
            }
            .help("Focus Mode (Cmd+Shift+F)")
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}
