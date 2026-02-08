import SwiftUI

struct FocusModeOverlay: View {
    let isActive: Bool
    let currentParagraphRect: CGRect

    var body: some View {
        if isActive {
            GeometryReader { geometry in
                // Top dim
                Rectangle()
                    .fill(ColorPalette.focusBackground.opacity(0.6))
                    .frame(
                        width: geometry.size.width,
                        height: max(0, currentParagraphRect.minY)
                    )

                // Bottom dim
                Rectangle()
                    .fill(ColorPalette.focusBackground.opacity(0.6))
                    .frame(
                        width: geometry.size.width,
                        height: max(0, geometry.size.height - currentParagraphRect.maxY)
                    )
                    .offset(y: currentParagraphRect.maxY)
            }
            .allowsHitTesting(false)
            .animation(AnimationTokens.gentle, value: currentParagraphRect)
            .transition(.opacity.animation(AnimationTokens.gentle))
        }
    }
}
