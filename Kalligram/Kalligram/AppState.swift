import SwiftUI
import SwiftData

@Observable
final class AppState {
    var selectedDocumentID: UUID?
    var selectedProjectID: UUID?
    var isSidebarVisible: Bool = true
    var isInspectorVisible: Bool = true
    var inspectorTab: InspectorTab = .outline
    var isFocusModeActive: Bool = false
    var isNewDocumentSheetPresented: Bool = false
    var isExportSheetPresented: Bool = false
    var searchQuery: String = ""
    var pendingInsertText: String? = nil

    /// Ordered list of currently open document IDs (tab order). Persisted to UserDefaults.
    var openDocumentIDs: [UUID] {
        didSet {
            let strings = openDocumentIDs.map { $0.uuidString }
            UserDefaults.standard.set(strings, forKey: "openDocumentIDs")
        }
    }

    /// Last selected document for session restore. Persisted to UserDefaults.
    var lastSelectedDocumentID: UUID? {
        didSet {
            if let id = lastSelectedDocumentID {
                UserDefaults.standard.set(id.uuidString, forKey: "lastSelectedDocumentID")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastSelectedDocumentID")
            }
        }
    }

    init() {
        let strings = UserDefaults.standard.stringArray(forKey: "openDocumentIDs") ?? []
        self.openDocumentIDs = strings.compactMap { UUID(uuidString: $0) }

        if let idString = UserDefaults.standard.string(forKey: "lastSelectedDocumentID") {
            self.lastSelectedDocumentID = UUID(uuidString: idString)
        }
    }

    enum InspectorTab: String, CaseIterable {
        case outline
        case ai
        case research
        case comments
        case history

        var iconName: String {
            switch self {
            case .outline: SFSymbolTokens.outline
            case .ai: SFSymbolTokens.ai
            case .research: SFSymbolTokens.research
            case .comments: SFSymbolTokens.comments
            case .history: SFSymbolTokens.history
            }
        }

        var label: String {
            switch self {
            case .outline: "Outline"
            case .ai: "AI"
            case .research: "Research"
            case .comments: "Comments"
            case .history: "History"
            }
        }
    }
}
