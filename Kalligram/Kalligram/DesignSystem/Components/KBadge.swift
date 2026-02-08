import SwiftUI

struct KBadge: View {
    let text: String
    var color: Color = ColorPalette.textSecondary

    var body: some View {
        Text(text)
            .font(Typography.caption2)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
