import SwiftUI
import SwiftData

@Observable
final class AppViewModel {
    var selectedDocument: Document?
    var sidebarSelection: SidebarItem = .allDocuments

    enum SidebarItem: Hashable {
        case allDocuments
        case favorites
        case recent
        case project(UUID)
        case templates
    }

    func selectDocument(_ document: Document) {
        selectedDocument = document
    }

    // MARK: - Open Document Management

    /// Opens a document: adds to the tab bar (if not already there) and selects it.
    func openDocument(_ document: Document, in appState: AppState) {
        if !appState.openDocumentIDs.contains(document.id) {
            appState.openDocumentIDs.append(document.id)
        }
        selectedDocument = document
        appState.lastSelectedDocumentID = document.id
    }

    /// Closes a document from the tab bar. Selects an adjacent tab if it was active.
    func closeDocument(_ document: Document, allDocuments: [Document], in appState: AppState) {
        guard let index = appState.openDocumentIDs.firstIndex(of: document.id) else { return }
        appState.openDocumentIDs.remove(at: index)

        if selectedDocument?.id == document.id {
            if appState.openDocumentIDs.isEmpty {
                selectedDocument = nil
                appState.lastSelectedDocumentID = nil
            } else {
                let newIndex = min(index, appState.openDocumentIDs.count - 1)
                let newID = appState.openDocumentIDs[newIndex]
                if let doc = allDocuments.first(where: { $0.id == newID }) {
                    selectedDocument = doc
                    appState.lastSelectedDocumentID = doc.id
                }
            }
        }
    }

    /// Closes all documents except the given one.
    func closeOtherDocuments(except document: Document, in appState: AppState) {
        appState.openDocumentIDs = [document.id]
        selectedDocument = document
        appState.lastSelectedDocumentID = document.id
    }

    /// Closes all open documents.
    func closeAllDocuments(in appState: AppState) {
        appState.openDocumentIDs.removeAll()
        selectedDocument = nil
        appState.lastSelectedDocumentID = nil
    }

    /// Selects the next open document (cycle forward).
    func selectNextOpenDocument(allDocuments: [Document], in appState: AppState) {
        guard appState.openDocumentIDs.count > 1,
              let currentID = selectedDocument?.id,
              let currentIndex = appState.openDocumentIDs.firstIndex(of: currentID)
        else { return }

        let nextIndex = (currentIndex + 1) % appState.openDocumentIDs.count
        let nextID = appState.openDocumentIDs[nextIndex]
        if let doc = allDocuments.first(where: { $0.id == nextID }) {
            selectedDocument = doc
            appState.lastSelectedDocumentID = doc.id
        }
    }

    /// Selects the previous open document (cycle backward).
    func selectPreviousOpenDocument(allDocuments: [Document], in appState: AppState) {
        guard appState.openDocumentIDs.count > 1,
              let currentID = selectedDocument?.id,
              let currentIndex = appState.openDocumentIDs.firstIndex(of: currentID)
        else { return }

        let prevIndex = (currentIndex - 1 + appState.openDocumentIDs.count) % appState.openDocumentIDs.count
        let prevID = appState.openDocumentIDs[prevIndex]
        if let doc = allDocuments.first(where: { $0.id == prevID }) {
            selectedDocument = doc
            appState.lastSelectedDocumentID = doc.id
        }
    }

    // MARK: - CRUD

    func createDocument(
        title: String,
        type: DocumentType,
        project: Project?,
        in context: ModelContext
    ) -> Document {
        let doc = Document(title: title, documentType: type)
        doc.project = project
        context.insert(doc)
        selectedDocument = doc
        return doc
    }

    func deleteDocument(_ document: Document, allDocuments: [Document], in context: ModelContext, appState: AppState) {
        closeDocument(document, allDocuments: allDocuments, in: appState)
        context.delete(document)
    }
}
