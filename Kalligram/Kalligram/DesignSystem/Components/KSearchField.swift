import SwiftUI

struct KSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: SFSymbolTokens.search)
                .font(.system(size: 12))
                .foregroundStyle(ColorPalette.textTertiary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(Typography.bodySmall)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(ColorPalette.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .background(ColorPalette.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
    }
}
