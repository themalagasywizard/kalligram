import SwiftUI

struct KTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(ColorPalette.textTertiary)
            }
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(Typography.bodySmall)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(ColorPalette.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                .strokeBorder(ColorPalette.borderSubtle, lineWidth: 1)
        )
    }
}
