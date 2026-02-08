import SwiftUI

struct PageThumbnailView: View {
    let pageNumber: Int
    let isCurrentPage: Bool
    let onTap: () -> Void

    @State private var isHovered = false

    private let thumbnailWidth: CGFloat = 60
    private let thumbnailHeight: CGFloat = 78

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ColorPalette.surfacePrimary)
                        .shadow(
                            color: Color.black.opacity(isCurrentPage ? 0.15 : 0.08),
                            radius: isCurrentPage ? 3 : 1,
                            x: 0,
                            y: 1
                        )

                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(
                            isCurrentPage ? ColorPalette.accentBlue :
                            isHovered ? ColorPalette.borderSubtle :
                            Color.clear,
                            lineWidth: isCurrentPage ? 2 : 1
                        )

                    // Mini text lines representation
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(0..<6, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 0.5)
                                .fill(ColorPalette.textTertiary.opacity(0.3))
                                .frame(
                                    width: i == 5 ? thumbnailWidth * 0.45 : thumbnailWidth * 0.7,
                                    height: 1.5
                                )
                        }
                    }
                    .padding(6)
                }
                .frame(width: thumbnailWidth, height: thumbnailHeight)

                Text("\(pageNumber)")
                    .font(Typography.caption2)
                    .foregroundStyle(
                        isCurrentPage ? ColorPalette.accentBlue : ColorPalette.textTertiary
                    )
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AnimationTokens.snappy) {
                isHovered = hovering
            }
        }
    }
}
