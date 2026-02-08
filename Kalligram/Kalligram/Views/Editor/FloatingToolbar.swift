import SwiftUI

struct FloatingToolbar: View {
    let isVisible: Bool
    var isRewriting: Bool = false
    var onRewrite: (() -> Void)?

    var body: some View {
        if isVisible {
            HStack(spacing: 2) {
                if onRewrite != nil {
                    // AI Rewrite
                    if isRewriting {
                        ProgressView()
                            .controlSize(.small)
                            .frame(width: Spacing.toolbarButtonSize, height: Spacing.toolbarButtonSize)
                    } else {
                        Button {
                            onRewrite?()
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: SFSymbolTokens.rewrite)
                                    .font(.system(size: 11, weight: .medium))
                                Text("Rewrite")
                                    .font(Typography.caption2)
                            }
                            .foregroundStyle(ColorPalette.aiAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(ColorPalette.aiAccent.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, Spacing.floatingToolbarPaddingH)
            .padding(.vertical, Spacing.floatingToolbarPaddingV)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusLarge))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
}
