import SwiftUI

struct EditorFormattingToolbar: View {
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel

    var body: some View {
        HStack(spacing: Spacing.sm) {
            styleGroup

            KDivider()
                .frame(height: 20)

            headingMenu

            KDivider()
                .frame(height: 20)

            sizeGroup

            KDivider()
                .frame(height: 20)

            alignmentGroup

            Spacer()

            if editorVM.inlineRewrite != nil {
                RewriteToggleBar(
                    isShowingRewritten: editorVM.inlineRewrite?.isShowingRewritten ?? true,
                    onToggle: { editorVM.toggleRewriteVersion() },
                    onAccept: { editorVM.acceptRewrite() },
                    onDismiss: { editorVM.dismissRewrite() }
                )
                .transition(.opacity)
                .animation(AnimationTokens.snappy, value: editorVM.inlineRewrite != nil)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .frame(height: Spacing.editorToolbarHeight)
        .background(ColorPalette.surfaceSecondary)
        .overlay(alignment: .top) { KDivider() }
        .overlay(alignment: .bottom) { KDivider() }
    }

    private var styleGroup: some View {
        HStack(spacing: 2) {
            toolbarButton(
                icon: SFSymbolTokens.bold,
                isActive: formattingVM.isBold
            ) {
                editorVM.toggleBold()
                refreshFormatting()
            }
            toolbarButton(
                icon: SFSymbolTokens.italic,
                isActive: formattingVM.isItalic
            ) {
                editorVM.toggleItalic()
                refreshFormatting()
            }
            toolbarButton(
                icon: SFSymbolTokens.underline,
                isActive: formattingVM.isUnderline
            ) {
                editorVM.toggleUnderline()
                refreshFormatting()
            }
            toolbarButton(
                icon: SFSymbolTokens.strikethrough,
                isActive: formattingVM.isStrikethrough
            ) {
                editorVM.toggleStrikethrough()
                refreshFormatting()
            }
        }
    }

    private var headingMenu: some View {
        Menu {
            Button("Body") {
                editorVM.applyHeading(level: 0)
                refreshFormatting()
            }
            Button("Heading 1") {
                editorVM.applyHeading(level: 1)
                refreshFormatting()
            }
            Button("Heading 2") {
                editorVM.applyHeading(level: 2)
                refreshFormatting()
            }
            Button("Heading 3") {
                editorVM.applyHeading(level: 3)
                refreshFormatting()
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                Text(currentHeadingLabel)
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(ColorPalette.textTertiary)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 6)
            .background(ColorPalette.surfaceTertiary)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
        }
        .menuStyle(.borderlessButton)
    }

    private var sizeGroup: some View {
        HStack(spacing: 4) {
            toolbarButton(
                icon: SFSymbolTokens.textSmaller,
                isActive: false
            ) {
                editorVM.decreaseFontSize()
                refreshFormatting()
            }

            Text("\(Int(formattingVM.currentFontSize))")
                .font(Typography.caption1)
                .foregroundStyle(ColorPalette.textPrimary)
                .frame(minWidth: 28)

            toolbarButton(
                icon: SFSymbolTokens.textLarger,
                isActive: false
            ) {
                editorVM.increaseFontSize()
                refreshFormatting()
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(ColorPalette.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
    }

    private var alignmentGroup: some View {
        HStack(spacing: 2) {
            toolbarButton(icon: SFSymbolTokens.alignLeft, isActive: false) {
                editorVM.alignLeft()
            }
            toolbarButton(icon: SFSymbolTokens.alignCenter, isActive: false) {
                editorVM.alignCenter()
            }
            toolbarButton(icon: SFSymbolTokens.alignRight, isActive: false) {
                editorVM.alignRight()
            }
            toolbarButton(icon: SFSymbolTokens.alignJustify, isActive: false) {
                editorVM.alignJustified()
            }
        }
    }

    private var currentHeadingLabel: String {
        switch formattingVM.currentHeadingLevel {
        case 1: "Heading 1"
        case 2: "Heading 2"
        case 3: "Heading 3"
        default: "Body"
        }
    }

    private func refreshFormatting() {
        if let textView = editorVM.textView {
            formattingVM.updateFromSelection(in: textView)
        }
    }

    private func toolbarButton(icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: isActive ? .bold : .regular))
                .foregroundStyle(isActive ? .white : ColorPalette.textPrimary)
                .frame(width: Spacing.toolbarButtonSize, height: Spacing.toolbarButtonSize)
                .background(isActive ? ColorPalette.accentBlue : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusSmall))
        }
        .buttonStyle(.plain)
    }
}
