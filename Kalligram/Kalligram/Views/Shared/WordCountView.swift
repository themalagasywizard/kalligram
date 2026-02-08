import SwiftUI

struct WordCountView: View {
    let wordCount: Int
    let characterCount: Int
    let goalCount: Int?

    var body: some View {
        HStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.xs) {
                Text("\(wordCount)")
                    .font(Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorPalette.textPrimary)
                    .contentTransition(.numericText())
                Text("words")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textTertiary)
            }

            HStack(spacing: Spacing.xs) {
                Text("\(characterCount)")
                    .font(Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorPalette.textPrimary)
                    .contentTransition(.numericText())
                Text("characters")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textTertiary)
            }

            if let goalCount, goalCount > 0 {
                HStack(spacing: Spacing.xs) {
                    let progress = min(Double(wordCount) / Double(goalCount), 1.0)
                    ProgressView(value: progress)
                        .frame(width: 60)
                        .tint(progress >= 1.0 ? ColorPalette.diffAdded : ColorPalette.accentBlue)
                    Text("\(Int(progress * 100))%")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorPalette.textTertiary)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(ColorPalette.surfaceSecondary.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
    }
}
