import SwiftUI
import SwiftData

struct AIExpandCondenseView: View {
    @Environment(\.modelContext) private var modelContext
    let expandCondenseVM: AIExpandCondenseViewModel
    let onAccept: (String) -> Void

    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings { settingsQuery.first ?? UserSettings() }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Selected text preview
            if !expandCondenseVM.selectedText.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Selected Text")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)
                    Text(expandCondenseVM.selectedText.truncated(to: 200))
                        .font(Typography.bodySmall)
                        .foregroundStyle(ColorPalette.textPrimary)
                        .lineLimit(4)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ColorPalette.surfaceTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                }
            }

            // Direction toggle
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Action")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                Picker("", selection: Bindable(expandCondenseVM).direction) {
                    Text("Expand").tag(LengthDirection.expand)
                    Text("Condense").tag(LengthDirection.condense)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            // Factor slider
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Amount")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                HStack {
                    Slider(value: Bindable(expandCondenseVM).factor,
                           in: expandCondenseVM.direction == .expand ? 1.5...3.0 : 0.25...0.75,
                           step: 0.25)
                    Text(expandCondenseVM.factorLabel)
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textTertiary)
                        .frame(width: 100)
                }
            }

            // Action button
            KButton(
                expandCondenseVM.direction == .expand ? "Expand" : "Condense",
                icon: expandCondenseVM.direction == .expand ? SFSymbolTokens.expand : SFSymbolTokens.condense
            ) {
                Task {
                    await expandCondenseVM.adjustLength(using: settings)
                }
            }

            // Error
            if let error = expandCondenseVM.error {
                Text(error)
                    .font(Typography.caption1)
                    .foregroundStyle(.red)
            }

            // Loading
            if expandCondenseVM.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing...")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
            }

            // Result with diff
            if !expandCondenseVM.result.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Result")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)

                    AIDiffPreview(chunks: expandCondenseVM.diff)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ColorPalette.surfaceTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))

                    KButton("Use This", icon: SFSymbolTokens.success, style: .primary) {
                        onAccept(expandCondenseVM.result)
                        expandCondenseVM.reset()
                    }
                }
            }
        }
    }
}
