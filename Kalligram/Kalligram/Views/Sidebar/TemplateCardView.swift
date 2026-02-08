import SwiftUI

struct TemplateCardView: View {
    let name: String
    let description: String
    let icon: String
    let isSelected: Bool

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(isSelected ? ColorPalette.accentBlue : ColorPalette.textSecondary)
                .frame(height: 32)

            VStack(spacing: 2) {
                Text(name)
                    .font(Typography.bodySmall)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorPalette.textPrimary)
                    .lineLimit(1)
                Text(description)
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .fill(isSelected ? ColorPalette.accentBlue.opacity(0.08) : ColorPalette.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .strokeBorder(
                            isSelected ? ColorPalette.accentBlue : ColorPalette.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: .black.opacity(isHovered ? 0.08 : 0.02), radius: isHovered ? 4 : 1, y: isHovered ? 2 : 0)
        .onHover { hovering in
            withAnimation(AnimationTokens.snappy) {
                isHovered = hovering
            }
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: SFSymbolTokens.success)
                    .font(.system(size: 14))
                    .foregroundStyle(ColorPalette.accentBlue)
                    .padding(Spacing.xs)
            }
        }
    }
}
