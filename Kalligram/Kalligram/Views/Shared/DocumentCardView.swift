import SwiftUI

struct DocumentCardView: View {
    let document: Document
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: document.documentTypeEnum.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(ColorPalette.accentBlue)
                    Spacer()
                    if document.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(ColorPalette.accentAmber)
                    }
                }

                Text(document.title)
                    .font(Typography.headline)
                    .foregroundStyle(ColorPalette.textPrimary)
                    .lineLimit(2)

                Text(document.updatedAt.formatted(.relative(presentation: .named)))
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)

                if document.wordCount > 0 {
                    KBadge(text: "\(document.wordCount) words")
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorPalette.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}
