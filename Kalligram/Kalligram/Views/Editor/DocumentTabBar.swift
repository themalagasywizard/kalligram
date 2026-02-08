import SwiftUI
import SwiftData

struct DocumentTabBar: View {
    @Environment(AppState.self) private var appState
    @Environment(AppViewModel.self) private var appViewModel
    @Query private var allDocuments: [Document]

    var body: some View {
        if !appState.openDocumentIDs.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(openDocuments, id: \.id) { document in
                        DocumentTab(
                            document: document,
                            isSelected: document.id == appViewModel.selectedDocument?.id,
                            onSelect: {
                                appViewModel.selectDocument(document)
                                appState.lastSelectedDocumentID = document.id
                            },
                            onClose: {
                                appViewModel.closeDocument(
                                    document,
                                    allDocuments: allDocuments,
                                    in: appState
                                )
                            },
                            onCloseOthers: {
                                appViewModel.closeOtherDocuments(
                                    except: document,
                                    in: appState
                                )
                            }
                        )
                    }
                    Spacer()
                }
            }
            .frame(height: Spacing.tabBarHeight)
            .background(ColorPalette.surfaceSecondary)
            .overlay(alignment: .bottom) { KDivider() }
        }
    }

    /// Resolves open document IDs to actual Document objects, preserving tab order.
    private var openDocuments: [Document] {
        appState.openDocumentIDs.compactMap { id in
            allDocuments.first { $0.id == id }
        }
    }
}
