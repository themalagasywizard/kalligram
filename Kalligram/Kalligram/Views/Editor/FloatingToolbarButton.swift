import SwiftUI

struct FloatingToolbarButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: isActive ? .bold : .regular))
                .foregroundStyle(isActive ? .white : ColorPalette.textPrimary)
                .frame(width: Spacing.toolbarButtonSize, height: Spacing.toolbarButtonSize)
                .background(isActive ? ColorPalette.accentBlue : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(AnimationTokens.snappy) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
