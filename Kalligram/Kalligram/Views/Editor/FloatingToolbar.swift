import SwiftUI

struct FloatingToolbar: View {
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel
    let isVisible: Bool
    let position: CGPoint

    var body: some View {
        if isVisible {
            HStack(spacing: 2) {
                // Text formatting
                Group {
                    FloatingToolbarButton(
                        icon: SFSymbolTokens.bold,
                        isActive: formattingVM.isBold
                    ) { editorVM.toggleBold() }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.italic,
                        isActive: formattingVM.isItalic
                    ) { editorVM.toggleItalic() }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.underline,
                        isActive: formattingVM.isUnderline
                    ) { editorVM.toggleUnderline() }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.strikethrough,
                        isActive: formattingVM.isStrikethrough
                    ) { editorVM.toggleStrikethrough() }
                }

                KDivider()
                    .frame(height: 20)
                    .padding(.horizontal, 2)

                // Headings
                Group {
                    FloatingToolbarButton(
                        icon: SFSymbolTokens.heading1,
                        isActive: formattingVM.currentHeadingLevel == 1
                    ) { editorVM.applyHeading(level: 1) }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.heading2,
                        isActive: formattingVM.currentHeadingLevel == 2
                    ) { editorVM.applyHeading(level: 2) }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.heading3,
                        isActive: formattingVM.currentHeadingLevel == 3
                    ) { editorVM.applyHeading(level: 3) }
                }

                KDivider()
                    .frame(height: 20)
                    .padding(.horizontal, 2)

                // Block formatting
                Group {
                    FloatingToolbarButton(
                        icon: SFSymbolTokens.blockquote,
                        isActive: false
                    ) { /* Quote toggle */ }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.bulletList,
                        isActive: false
                    ) { /* Bullet list toggle */ }

                    FloatingToolbarButton(
                        icon: SFSymbolTokens.numberedList,
                        isActive: false
                    ) { /* Numbered list toggle */ }
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
