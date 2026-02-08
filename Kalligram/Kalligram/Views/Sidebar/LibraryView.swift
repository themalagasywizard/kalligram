import SwiftUI
import AppKit

struct LibraryView: View {
    let documents: [Document]
    let openDocumentIDs: [UUID]
    let onSelect: (Document) -> Void
    let onDelete: (Document) -> Void

    var body: some View {
        if documents.isEmpty {
            Text("No documents yet")
                .font(Typography.caption1)
                .foregroundStyle(ColorPalette.textTertiary)
                .padding(.vertical, Spacing.sm)
        } else {
            ForEach(documents, id: \.id) { document in
                LibraryRowView(
                    document: document,
                    isOpen: openDocumentIDs.contains(document.id),
                    onDelete: { onDelete(document) }
                )
                    .tag(document.id)
                    .contextMenu {
                        Button("Duplicate") {
                            // Will be implemented later
                        }
                        if document.isImported, let path = document.sourceFilePath {
                            Divider()
                            Button("Show in Finder") {
                                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
                            }
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            onDelete(document)
                        }
                    }
            }
        }
    }
}
