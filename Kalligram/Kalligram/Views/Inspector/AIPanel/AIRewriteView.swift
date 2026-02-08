import SwiftUI
import SwiftData

struct AIRewriteView: View {
    @Environment(\.modelContext) private var modelContext
    let rewriteVM: AIRewriteViewModel
    let onAccept: (String) -> Void

    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings { settingsQuery.first ?? UserSettings() }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Selected text preview
            if !rewriteVM.selectedText.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Selected Text")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)
                    Text(rewriteVM.selectedText.truncated(to: 200))
                        .font(Typography.bodySmall)
                        .foregroundStyle(ColorPalette.textPrimary)
                        .lineLimit(4)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ColorPalette.surfaceTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                }
            }

            // Tone picker
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Tone")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                Picker("", selection: Bindable(rewriteVM).selectedTone) {
                    ForEach(AITone.allCases, id: \.self) { tone in
                        Text(tone.displayName).tag(tone)
                    }
                }
                .labelsHidden()
            }

            // Goal (optional)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Goal (Optional)")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                TextField("e.g. Make it more concise", text: Bindable(rewriteVM).goal)
                    .textFieldStyle(.roundedBorder)
                    .font(Typography.bodySmall)
            }

            // Rewrite button
            KButton("Rewrite", icon: SFSymbolTokens.rewrite) {
                Task {
                    await rewriteVM.rewrite(using: settings)
                }
            }

            // Error
            if let error = rewriteVM.error {
                Text(error)
                    .font(Typography.caption1)
                    .foregroundStyle(.red)
            }

            // Loading
            if rewriteVM.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating options...")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
            }

            // Options
            if !rewriteVM.options.isEmpty {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(rewriteVM.options.enumerated()), id: \.offset) { index, option in
                        AIOptionCard(
                            index: index,
                            text: option,
                            diff: index < rewriteVM.diffs.count ? rewriteVM.diffs[index] : [],
                            isSelected: rewriteVM.selectedOptionIndex == index
                        ) {
                            rewriteVM.selectedOptionIndex = index
                        }
                    }
                }

                if let selectedIndex = rewriteVM.selectedOptionIndex {
                    KButton("Use This", icon: SFSymbolTokens.success, style: .primary) {
                        onAccept(rewriteVM.options[selectedIndex])
                        rewriteVM.reset()
                    }
                }
            }
        }
    }
}
