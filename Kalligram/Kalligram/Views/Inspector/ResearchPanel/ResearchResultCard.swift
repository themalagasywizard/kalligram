import SwiftUI

struct ResearchResultCard: View {
    let source: SourceSuggestion
    let citationStyle: CitationStyle
    let onInsert: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Title
            Text(displayTitle.softWrappedForUI)
                .font(Typography.bodySmall)
                .fontWeight(.medium)
                .foregroundStyle(ColorPalette.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Authors
            if !displayAuthors.isEmpty {
                Text(displayAuthors.softWrappedForUI)
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                    .lineLimit(1)
            }

            // Abstract
            if let abstract = source.abstract, !abstract.isEmpty {
                Text(abstract.softWrappedForUI)
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textTertiary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let url = displayURL {
                Text(url.softWrappedForUI)
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)
                    .lineLimit(2)
                    .truncationMode(.middle)
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
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var displayTitle: String {
        if source.title.contains(" | ") {
            return source.title.components(separatedBy: " | ").first ?? source.title
        }
        return source.title
    }

    private var displayAuthors: String {
        if !source.authors.isEmpty {
            return source.authors
        }
        let parts = source.title.components(separatedBy: " | ")
        if parts.count > 1 {
            return parts[1]
        }
        return ""
    }

    private var displayURL: String? {
        if let url = source.url, !url.isEmpty {
            return url
        }
        if let match = source.title.firstMatch(of: urlRegex) {
            return String(source.title[match.range])
        }
        return nil
    }

    private var urlRegex: Regex<Substring> {
        /https?:\/\/[^\s|]+/
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
