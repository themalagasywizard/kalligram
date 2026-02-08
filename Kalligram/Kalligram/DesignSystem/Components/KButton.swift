import SwiftUI

struct KButton: View {
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void

    enum Style {
        case primary
        case secondary
        case ghost
        case destructive
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(Typography.bodySmall)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: ColorPalette.textPrimary
        case .ghost: ColorPalette.accentBlue
        case .destructive: .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: ColorPalette.accentBlue
        case .secondary: ColorPalette.surfaceTertiary
        case .ghost: .clear
        case .destructive: Color.red
        }
    }
}
