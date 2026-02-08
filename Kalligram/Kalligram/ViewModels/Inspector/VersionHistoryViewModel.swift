import SwiftUI
import SwiftData

@Observable
final class VersionHistoryViewModel {
    var versions: [Version] = []
    var selectedVersion: Version?

    func loadVersions(for document: Document) {
        versions = document.versions.sorted { $0.createdAt > $1.createdAt }
    }

    func createManualSnapshot(for document: Document, modelContext: ModelContext) {
        let version = VersionService.createSnapshot(
            for: document,
            triggerType: "manual",
            modelContext: modelContext
        )
        versions.insert(version, at: 0)
    }

    func restore(_ version: Version, to document: Document, modelContext: ModelContext) {
        VersionService.restore(version: version, to: document, modelContext: modelContext)
        loadVersions(for: document)
    }

    func branch(_ version: Version, title: String, modelContext: ModelContext) -> Document {
        VersionService.branchToNewDocument(from: version, title: title, modelContext: modelContext)
    }

    var triggerTypeIcon: (String) -> String = { triggerType in
        switch triggerType {
        case "autosave": SFSymbolTokens.autosave
        case "manual": SFSymbolTokens.manualSave
        case "ai_action": SFSymbolTokens.aiAction
        case "pre_restore": SFSymbolTokens.restore
        default: SFSymbolTokens.autosave
        }
    }
}
