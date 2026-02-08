import SwiftUI

struct AIOptionCard: View {
    let index: Int
    let text: String
    let diff: [DiffChunk]
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Option \(index + 1)")
                        .font(Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundStyle(ColorPalette.textSecondary)
                    Spacer()
                    if isSelected {
                        Image(systemName: SFSymbolTokens.success)
                            .foregroundStyle(ColorPalette.aiAccent)
                    }
                }

                AIDiffPreview(chunks: diff)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .fill(ColorPalette.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                            .strokeBorder(
                                isSelected ? ColorPalette.aiAccent :
                                isHovered ? ColorPalette.aiAccent.opacity(0.3) :
                                ColorPalette.borderSubtle,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.005 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AnimationTokens.snappy) {
                isHovered = hovering
            }
        }
    }
}
