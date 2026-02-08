import SwiftUI

struct ExportPreviewPane: View {
    let previewText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Preview")
                .font(Typography.caption1)
                .fontWeight(.medium)
                .foregroundStyle(ColorPalette.textSecondary)

            ScrollView {
                Text(previewText)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(ColorPalette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.md)
            }
            .background(ColorPalette.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .strokeBorder(ColorPalette.borderSubtle, lineWidth: 1)
            )
        }
        .padding(Spacing.xxl)
    }
}
