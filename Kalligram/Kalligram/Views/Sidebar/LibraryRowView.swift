import SwiftUI

struct LibraryRowView: View {
    let document: Document
    let isOpen: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Open indicator dot
            Circle()
                .fill(isOpen ? ColorPalette.accentBlue : Color.clear)
                .frame(width: 6, height: 6)

            Image(systemName: document.documentTypeEnum.iconName)
                .font(.system(size: 14))
                .foregroundStyle(ColorPalette.accentBlue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(Typography.bodySmall)
                    .foregroundStyle(ColorPalette.textPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Text(document.updatedAt.formatted(.relative(presentation: .named)))
                        .font(Typography.caption2)
                        .foregroundStyle(ColorPalette.textTertiary)

                    if document.wordCount > 0 {
                        Text("\(document.wordCount) words")
                            .font(Typography.caption2)
                            .foregroundStyle(ColorPalette.textTertiary)
                    }

                    // Import source badge
                    if let fileType = document.sourceFileTypeDisplay {
                        KBadge(text: fileType, color: importBadgeColor(fileType))
                    }
                }
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: SFSymbolTokens.trash)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ColorPalette.textTertiary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .help("Delete")

            if document.isFavorite {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(ColorPalette.accentAmber)
            }
        }
        .padding(.vertical, 2)
    }

    private func importBadgeColor(_ type: String) -> Color {
        switch type {
        case "PDF": return .red
        case "DOCX": return ColorPalette.accentBlue
        case "MD": return .green
        case "RTF": return .purple
        default: return ColorPalette.textSecondary
        }
    }
}
