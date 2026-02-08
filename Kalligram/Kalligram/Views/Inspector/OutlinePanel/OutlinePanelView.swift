import SwiftUI

struct OutlinePanelView: View {
    let outlineVM: OutlineViewModel
    let onSelectHeading: (NSRange) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Outline")
                    .font(Typography.headline)
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
                KBadge(text: "\(outlineVM.headings.count)")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)

            KDivider()

            if outlineVM.headings.isEmpty {
                KEmptyState(
                    icon: SFSymbolTokens.outline,
                    title: "No Headings",
                    message: "Add headings to your document to see the outline here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(outlineVM.headings) { heading in
                            OutlineRowView(
                                heading: heading,
                                isCurrent: outlineVM.currentHeadingID == heading.id,
                                onTap: { onSelectHeading(heading.characterRange) }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
    }
}
