import SwiftUI
import SwiftData

struct AIGenerateView: View {
    @Environment(\.modelContext) private var modelContext
    let generateVM: AIGenerateViewModel
    let onInsert: (String) -> Void

    @Query private var settingsQuery: [UserSettings]
    private var settings: UserSettings { settingsQuery.first ?? UserSettings() }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Prompt
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("What would you like to write?")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                TextField("e.g. An introduction about climate change...", text: Bindable(generateVM).prompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .font(Typography.bodySmall)
                    .lineLimit(3...6)
            }

            // Tone
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Tone")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                Picker("", selection: Bindable(generateVM).selectedTone) {
                    ForEach(AITone.allCases, id: \.self) { tone in
                        Text(tone.displayName).tag(tone)
                    }
                }
                .labelsHidden()
            }

            // Target length
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Target Length")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                HStack {
                    Slider(value: .init(
                        get: { Double(generateVM.targetLength) },
                        set: { generateVM.targetLength = Int($0) }
                    ), in: 50...1000, step: 50)
                    Text("\(generateVM.targetLength) words")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textTertiary)
                        .frame(width: 70)
                }
            }

            // Audience (optional)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Audience (Optional)")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                TextField("e.g. General readers, academics", text: Bindable(generateVM).audience)
                    .textFieldStyle(.roundedBorder)
                    .font(Typography.bodySmall)
            }

            // Generate button
            KButton("Generate", icon: SFSymbolTokens.generate) {
                Task {
                    await generateVM.generate(using: settings)
                }
            }

            // Error
            if let error = generateVM.error {
                Text(error)
                    .font(Typography.caption1)
                    .foregroundStyle(.red)
            }

            // Loading
            if generateVM.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating...")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
            }

            // Result
            if !generateVM.generatedText.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Generated Text")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textSecondary)

                    Text(generateVM.generatedText)
                        .font(Typography.bodySmall)
                        .foregroundStyle(ColorPalette.textPrimary)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ColorPalette.surfaceTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))

                    KButton("Insert at Cursor", icon: SFSymbolTokens.success, style: .primary) {
                        onInsert(generateVM.generatedText)
                        generateVM.reset()
                    }
                }
            }
        }
    }
}
