//
//  KalligramApp.swift
//  Kalligram
//
//  Created by Ryan Trumble on 8/2/26.
//

import SwiftUI
import SwiftData

@main
struct KalligramApp: App {
    @State private var appState = AppState()
    @State private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(appViewModel)
                .frame(minWidth: 900, minHeight: 600)
        }
        .modelContainer(for: [
            Document.self,
            Project.self,
            DocumentSection.self,
            Template.self,
            Citation.self,
            Comment.self,
            Version.self,
            AIAction.self,
            ResearchNote.self,
            UserSettings.self
        ])
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1440, height: 900)
        .commands {
            FileCommands(appViewModel: appViewModel, appState: appState)
        }

        Settings {
            SettingsWindow()
                .environment(appState)
        }
    }
}
