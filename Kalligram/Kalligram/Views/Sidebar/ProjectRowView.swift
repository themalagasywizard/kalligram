import SwiftUI

struct ProjectRowView: View {
    let project: Project
    let openDocumentIDs: [UUID]
    let onDelete: (Document) -> Void

    var body: some View {
        DisclosureGroup {
            if project.documents.isEmpty {
                Text("No documents")
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)
                    .padding(.leading, Spacing.lg)
            } else {
                ForEach(project.documents, id: \.id) { document in
                    LibraryRowView(
                        document: document,
                        isOpen: openDocumentIDs.contains(document.id),
                        onDelete: { onDelete(document) }
                    )
                        .padding(.leading, Spacing.sm)
                }
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: SFSymbolTokens.project)
                    .font(.system(size: 13))
                    .foregroundStyle(
                        project.colorTag.map { Color(hex: $0) } ?? ColorPalette.textSecondary
                    )
                Text(project.name)
                    .font(Typography.bodySmall)
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
                KBadge(text: "\(project.documents.count)")
            }
        }
    }
}
