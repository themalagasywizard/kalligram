import SwiftUI
import SwiftData

struct ResearchPanelView: View {
    let researchVM: ResearchViewModel
    let citationVM: CitationViewModel
    let document: Document?
    let onInsertCitation: (String) -> Void

    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings { settingsQuery.first ?? UserSettings() }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    HStack {
                        Image(systemName: SFSymbolTokens.research)
                            .foregroundStyle(ColorPalette.accentBlue)
                        Text("Research")
                            .font(Typography.headline)
                            .foregroundStyle(ColorPalette.textPrimary)
                    }

                    // Search
                    ResearchQueryView(
                        query: Bindable(researchVM).query,
                        isLoading: researchVM.isLoading
                    ) {
                        Task {
                            await researchVM.search(
                                using: settings,
                                documentContext: document?.contentPlainText.truncated(to: 500)
                            )
                        }
                    }

                    // Error
                    if let error = researchVM.error {
                        Text(error)
                            .font(Typography.caption1)
                            .foregroundStyle(.red)
                    }

                    // Results
                    if let result = researchVM.result {
                        // Summary
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Summary")
                                .font(Typography.caption1)
                                .fontWeight(.medium)
                                .foregroundStyle(ColorPalette.textSecondary)

                            Text(result.summary.softWrappedForUI)
                                .font(Typography.bodySmall)
                                .foregroundStyle(ColorPalette.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(Spacing.sm)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(ColorPalette.surfaceTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Sources
                        if !result.sources.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                HStack {
                                    Text("Sources")
                                        .font(Typography.caption1)
                                        .fontWeight(.medium)
                                        .foregroundStyle(ColorPalette.textSecondary)
                                    Spacer()
                                    // Citation style picker
                                    Picker("", selection: Bindable(citationVM).citationStyle) {
                                        ForEach(CitationStyle.allCases, id: \.self) { style in
                                            Text(style.displayName).tag(style)
                                        }
                                    }
                                    .fixedSize()
                                    .labelsHidden()
                                }

                                ForEach(result.sources) { source in
                                    ResearchResultCard(
                                        source: source,
                                        citationStyle: citationVM.citationStyle,
                                        onInsert: {
                                            let formatted = CitationService.format(source: source, style: citationVM.citationStyle)
                                            onInsertCitation(formatted)
                                            if document != nil {
                                                // Also save citation to document
                                            }
                                        }
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Related queries
                        if !result.relatedQueries.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Related Questions")
                                    .font(Typography.caption1)
                                    .fontWeight(.medium)
                                    .foregroundStyle(ColorPalette.textSecondary)

                                FlowLayout(spacing: Spacing.xs) {
                                    ForEach(result.relatedQueries, id: \.self) { query in
                                        Button {
                                            researchVM.query = query
                                            Task {
                                                await researchVM.search(using: settings)
                                            }
                                        } label: {
                                            Text(query.softWrappedForUI)
                                                .font(Typography.caption1)
                                                .foregroundStyle(ColorPalette.accentBlue)
                                                .padding(.horizontal, Spacing.sm)
                                                .padding(.vertical, Spacing.xs)
                                                .background(ColorPalette.accentBlue.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Recent searches
                    if researchVM.result == nil && !researchVM.searchHistory.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Recent Searches")
                                .font(Typography.caption1)
                                .foregroundStyle(ColorPalette.textTertiary)

                            ForEach(researchVM.searchHistory, id: \.self) { query in
                                Button {
                                    researchVM.query = query
                                } label: {
                                    HStack {
                                        Image(systemName: SFSymbolTokens.recent)
                                            .font(.system(size: 10))
                                            .foregroundStyle(ColorPalette.textTertiary)
                                        Text(query.softWrappedForUI)
                                            .font(Typography.bodySmall)
                                            .foregroundStyle(ColorPalette.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(Spacing.lg)
                .frame(width: max(0, geo.size.width - Spacing.lg * 2), alignment: .leading)
            }
        }
    }
}

// Simple flow layout for related query chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (positions, CGSize(width: maxX, height: currentY + lineHeight))
    }
}
