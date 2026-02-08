import SwiftUI

struct APIKeyInputView: View {
    let provider: String
    let label: String
    @State private var key: String = ""
    @State private var isSaved: Bool = false
    @State private var isRevealed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(Typography.caption1)
                .foregroundStyle(ColorPalette.textSecondary)

            HStack(spacing: Spacing.sm) {
                Group {
                    if isRevealed {
                        TextField("API Key", text: $key)
                    } else {
                        SecureField("API Key", text: $key)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .font(Typography.bodySmall)

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(ColorPalette.textTertiary)
                }
                .buttonStyle(.plain)

                KButton("Save", style: .primary) {
                    try? KeychainService.shared.saveAPIKey(key, for: provider)
                    withAnimation(AnimationTokens.snappy) {
                        isSaved = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isSaved = false
                    }
                }
            }

            if isSaved {
                Text("Saved securely")
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.diffAdded)
                    .transition(.opacity)
            }
        }
        .onAppear {
            if let existing = KeychainService.shared.getAPIKey(for: provider) {
                key = existing
            }
        }
    }
}
