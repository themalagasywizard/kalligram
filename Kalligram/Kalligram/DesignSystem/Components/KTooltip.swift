import SwiftUI

struct KTooltip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Typography.caption2)
            .foregroundStyle(ColorPalette.textPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                    .fill(ColorPalette.surfacePrimary)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 2)
            )
    }
}
