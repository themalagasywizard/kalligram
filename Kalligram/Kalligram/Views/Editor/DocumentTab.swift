import SwiftUI
import AppKit

struct DocumentTab: View {
    let document: Document
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    let onCloseOthers: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: Spacing.xs) {
            // Icon: source type badge for imports, document type icon for native
            if document.isImported, let fileType = document.sourceFileTypeDisplay {
                KBadge(text: fileType, color: badgeColor(for: document.sourceFileType))
            } else {
                Image(systemName: document.documentTypeEnum.iconName)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? ColorPalette.accentBlue : ColorPalette.textTertiary)
            }

            Text(document.title)
                .font(Typography.caption1)
                .foregroundStyle(isSelected ? ColorPalette.textPrimary : ColorPalette.textSecondary)
                .lineLimit(1)

            // Close button — visible on hover or when selected
            Button {
                onClose()
            } label: {
                Image(systemName: SFSymbolTokens.closeTab)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(ColorPalette.textTertiary)
                    .frame(width: 14, height: 14)
                    .background(isHovering ? ColorPalette.surfaceTertiary : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .opacity(isHovering || isSelected ? 1 : 0)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .frame(height: 30)
        .background(isSelected ? ColorPalette.surfacePrimary : Color.clear)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(ColorPalette.accentBlue)
                    .frame(height: 2)
            }
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(ColorPalette.borderSubtle)
                .frame(width: 1, height: 16)
                .opacity(isSelected ? 0 : 0.5)
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Close") { onClose() }
            Button("Close Others") { onCloseOthers() }
            if document.isImported, let path = document.sourceFilePath {
                Divider()
                Button("Show in Finder") {
                    NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
                }
            }
        }
        .animation(AnimationTokens.colorTransition, value: isSelected)
        .animation(AnimationTokens.colorTransition, value: isHovering)
    }

    private func badgeColor(for fileType: String?) -> Color {
        switch fileType {
        case "pdf": return .red
        case "docx": return ColorPalette.accentBlue
        case "md": return .green
        case "rtf": return .purple
        default: return ColorPalette.textSecondary
        }
    }
}
