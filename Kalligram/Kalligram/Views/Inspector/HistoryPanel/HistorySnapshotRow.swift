import SwiftUI

struct HistorySnapshotRow: View {
    let version: Version
    let isSelected: Bool
    let iconName: String
    let onSelect: () -> Void
    let onRestore: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.sm) {
                // Timeline indicator
                VStack(spacing: 0) {
                    Circle()
                        .fill(isSelected ? ColorPalette.accentBlue : ColorPalette.borderSubtle)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(ColorPalette.borderSubtle)
                        .frame(width: 1)
                }
                .frame(width: 8)

                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Image(systemName: iconName)
                            .font(.system(size: 10))
                            .foregroundStyle(ColorPalette.textTertiary)
                        Text(version.label)
                            .font(Typography.bodySmall)
                            .fontWeight(isSelected ? .medium : .regular)
                            .foregroundStyle(ColorPalette.textPrimary)
                            .lineLimit(1)
                    }

                    HStack(spacing: Spacing.sm) {
                        Text(version.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(Typography.caption2)
                            .foregroundStyle(ColorPalette.textTertiary)
                        Text("\(version.wordCount) words")
                            .font(Typography.caption2)
                            .foregroundStyle(ColorPalette.textTertiary)
                    }
                }

                Spacer()

                // Restore button (visible on hover)
                if isHovered {
                    Button(action: onRestore) {
                        Text("Restore")
                            .font(Typography.caption2)
                            .foregroundStyle(ColorPalette.accentBlue)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 2)
                            .background(ColorPalette.accentBlue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.vertical, Spacing.xs)
            .padding(.horizontal, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                    .fill(isSelected ? ColorPalette.accentBlue.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AnimationTokens.snappy) {
                isHovered = hovering
            }
        }
    }
}
