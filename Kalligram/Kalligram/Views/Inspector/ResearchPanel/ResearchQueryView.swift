import SwiftUI

struct ResearchQueryView: View {
    @Binding var query: String
    let isLoading: Bool
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: SFSymbolTokens.search)
                    .font(.system(size: 12))
                    .foregroundStyle(ColorPalette.textTertiary)

                TextField("Ask a research question...", text: $query)
                    .textFieldStyle(.plain)
                    .font(Typography.bodySmall)
                    .onSubmit {
                        onSearch()
                    }

                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(ColorPalette.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs + 2)
            .background(ColorPalette.surfaceTertiary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))

            Button(action: onSearch) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(ColorPalette.accentBlue)
                }
            }
            .buttonStyle(.plain)
            .disabled(query.isEmpty || isLoading)
        }
    }
}
