import SwiftUI

struct CitationDragView: View {
    let formattedCitation: String
    let source: SourceSuggestion

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "quote.opening")
                .font(.system(size: 10))
                .foregroundStyle(ColorPalette.aiAccent)
            Text(source.title)
                .font(Typography.caption2)
                .foregroundStyle(ColorPalette.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(ColorPalette.aiAccent.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(ColorPalette.aiAccent.opacity(0.3), lineWidth: 1)
        )
        .draggable(formattedCitation)
    }
}
