import SwiftUI

extension View {
    func kalligramSurface() -> some View {
        self
            .background(ColorPalette.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
    }

    func kalligramCard() -> some View {
        self
            .padding(Spacing.lg)
            .background(ColorPalette.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}
