import SwiftUI

struct KDivider: View {
    enum Orientation {
        case horizontal
        case vertical
    }

    var orientation: Orientation = .horizontal

    var body: some View {
        switch orientation {
        case .horizontal:
            Divider()
                .foregroundStyle(ColorPalette.borderSubtle)
        case .vertical:
            Rectangle()
                .fill(ColorPalette.borderSubtle)
                .frame(width: 1)
        }
    }
}
