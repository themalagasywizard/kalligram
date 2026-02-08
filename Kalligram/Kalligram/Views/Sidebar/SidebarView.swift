import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Document.updatedAt, order: .reverse) private var allDocuments: [Document]
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var searchText = ""

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            KSearchField(text: $searchText, placeholder: "Search documents...")
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

            KDivider()

            List(selection: Binding(
                get: { appViewModel.selectedDocument?.id },
                set: { newID in
                    if let newID, let doc = allDocuments.first(where: { $0.id == newID }) {
                        appViewModel.openDocument(doc, in: appState)
                    }
                }
            )) {
                // Library Section
                SwiftUI.Section {
                    LibraryView(
                        documents: filteredDocuments,
                        openDocumentIDs: appState.openDocumentIDs,
                        onSelect: { appViewModel.openDocument($0, in: appState) },
                        onDelete: { appViewModel.deleteDocument($0, allDocuments: allDocuments, in: modelContext, appState: appState) }
                    )
                } header: {
                    Label("Library", systemImage: SFSymbolTokens.library)
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)
                }

                // Projects Section
                if !projects.isEmpty {
                    SwiftUI.Section {
                        ProjectListView(
                            projects: projects,
                            openDocumentIDs: appState.openDocumentIDs,
                            onDelete: { appViewModel.deleteDocument($0, allDocuments: allDocuments, in: modelContext, appState: appState) }
                        )
                    } header: {
                        Label("Projects", systemImage: SFSymbolTokens.project)
                            .font(Typography.caption1)
                            .foregroundStyle(ColorPalette.textSecondary)
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .background(ColorPalette.surfaceSecondary)
    }

    private var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return allDocuments
        }
        return allDocuments.filter { doc in
            doc.title.localizedCaseInsensitiveContains(searchText) ||
            doc.contentPlainText.localizedCaseInsensitiveContains(searchText)
        }
    }
}
