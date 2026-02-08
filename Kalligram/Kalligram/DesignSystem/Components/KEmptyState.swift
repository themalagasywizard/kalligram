import SwiftUI

struct KEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(ColorPalette.textTertiary)

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundStyle(ColorPalette.textPrimary)
                Text(message)
                    .font(Typography.bodySmall)
                    .foregroundStyle(ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                KButton(actionTitle, icon: SFSymbolTokens.newDocument, action: action)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}
