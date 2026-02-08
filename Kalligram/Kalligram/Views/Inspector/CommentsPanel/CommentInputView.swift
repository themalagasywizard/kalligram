import SwiftUI

struct CommentInputView: View {
    @Binding var text: String
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Add a comment...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(Typography.caption1)
                .lineLimit(1...4)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs + 2)
                .background(ColorPalette.surfaceTertiary)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                .onSubmit {
                    if !text.isEmpty { onSubmit() }
                }

            Button(action: {
                if !text.isEmpty { onSubmit() }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        text.isEmpty ? ColorPalette.textTertiary : ColorPalette.accentBlue
                    )
            }
            .buttonStyle(.plain)
            .disabled(text.isEmpty)
        }
    }
}
