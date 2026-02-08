import SwiftUI

struct ResearchResultCard: View {
    let source: SourceSuggestion
    let citationStyle: CitationStyle
    let onInsert: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Title
            Text(source.title)
                .font(Typography.bodySmall)
                .fontWeight(.medium)
                .foregroundStyle(ColorPalette.textPrimary)
                .lineLimit(2)

            // Authors
            if !source.authors.isEmpty {
                Text(source.authors)
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                    .lineLimit(1)
            }

            // Abstract
            if let abstract = source.abstract, !abstract.isEmpty {
                Text(abstract)
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textTertiary)
                    .lineLimit(3)
            }

            HStack {
                // Reliability badge
                ReliabilityBadge(score: source.reliabilityScore)

                if let date = source.publishDate {
                    Text(date)
                        .font(Typography.caption2)
                        .foregroundStyle(ColorPalette.textTertiary)
                }

                Spacer()

                // Insert citation button
                Button {
                    onInsert()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 10))
                        Text("Cite")
                            .font(Typography.caption2)
                    }
                    .foregroundStyle(ColorPalette.accentBlue)
                }
                .buttonStyle(.plain)
                .opacity(isHovered ? 1 : 0.6)
            }
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .fill(ColorPalette.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .strokeBorder(
                            isHovered ? ColorPalette.accentBlue.opacity(0.3) : ColorPalette.borderSubtle,
                            lineWidth: 1
                        )
                )
        )
        .onHover { hovering in
            withAnimation(AnimationTokens.snappy) {
                isHovered = hovering
            }
        }
    }
}

struct ReliabilityBadge: View {
    let score: Double

    private var label: String {
        switch score {
        case 0.8...: "High"
        case 0.5..<0.8: "Medium"
        default: "Low"
        }
    }

    private var color: Color {
        switch score {
        case 0.8...: ColorPalette.diffAdded
        case 0.5..<0.8: ColorPalette.accentAmber
        default: ColorPalette.diffRemoved
        }
    }

    var body: some View {
        Text(label)
            .font(Typography.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
