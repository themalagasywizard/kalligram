import SwiftUI

struct OutlineRowView: View {
    let heading: OutlineViewModel.OutlineHeading
    let isCurrent: Bool
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                // Indentation
                Spacer()
                    .frame(width: CGFloat(heading.level - 1) * Spacing.lg)

                // Level indicator
                Circle()
                    .fill(isCurrent ? ColorPalette.accentBlue : ColorPalette.textTertiary)
                    .frame(width: levelDotSize, height: levelDotSize)

                Text(heading.title)
                    .font(fontForLevel)
                    .foregroundStyle(isCurrent ? ColorPalette.accentBlue : ColorPalette.textPrimary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.vertical, Spacing.xs)
            .padding(.horizontal, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                    .fill(isCurrent ? ColorPalette.accentBlue.opacity(0.08) :
                          isHovered ? ColorPalette.surfaceTertiary : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AnimationTokens.colorTransition) {
                isHovered = hovering
            }
        }
    }

    private var fontForLevel: Font {
        switch heading.level {
        case 1: Typography.bodySmall.weight(.semibold)
        case 2: Typography.bodySmall.weight(.medium)
        default: Typography.caption1
        }
    }

    private var levelDotSize: CGFloat {
        switch heading.level {
        case 1: 6
        case 2: 5
        default: 4
        }
    }
}
