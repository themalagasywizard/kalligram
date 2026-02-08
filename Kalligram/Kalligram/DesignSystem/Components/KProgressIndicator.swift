import SwiftUI

struct KProgressIndicator: View {
    let label: String
    var progress: Double?

    var body: some View {
        VStack(spacing: Spacing.sm) {
            if let progress {
                ProgressView(value: progress)
                    .tint(ColorPalette.accentBlue)
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
            Text(label)
                .font(Typography.caption1)
                .foregroundStyle(ColorPalette.textTertiary)
        }
    }
}
