import SwiftUI

struct PageView: View {
    let pageNumber: Int
    let paperSize: PaperSize
    let isCurrentPage: Bool
    let margins: NSEdgeInsets
    let bleed: CGFloat
    let showsGuides: Bool

    var body: some View {
        PageContainer(
            pageNumber: pageNumber,
            totalPages: pageNumber,
            paperSize: paperSize,
            isCurrentPage: isCurrentPage,
            content: nil,
            margins: margins,
            bleed: bleed,
            showsGuides: showsGuides
        )
    }
}

struct PageContainer: View {
    let pageNumber: Int
    let totalPages: Int
    let paperSize: PaperSize
    let isCurrentPage: Bool
    let content: NSAttributedString?
    let margins: NSEdgeInsets
    let bleed: CGFloat
    let showsGuides: Bool

    var body: some View {
        ZStack {
            ZStack {
                // Page background with shadow
                RoundedRectangle(cornerRadius: 1)
                    .fill(ColorPalette.surfacePrimary)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: isCurrentPage ? 12 : 6,
                        x: 0,
                        y: isCurrentPage ? 4 : 2
                    )

                RoundedRectangle(cornerRadius: 1)
                    .strokeBorder(ColorPalette.borderSubtle, lineWidth: 1)

                if showsGuides {
                    Rectangle()
                        .stroke(
                            ColorPalette.accentBlue.opacity(0.4),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                        .frame(
                            width: paperSize.widthPoints - margins.left - margins.right,
                            height: paperSize.heightPoints - margins.top - margins.bottom
                        )
                }

                // Page content area
                if let content {
                    PageContentView(
                        attributedString: content,
                        contentWidth: paperSize.widthPoints - margins.left - margins.right
                    )
                    .padding(.top, margins.top)
                    .padding(.bottom, margins.bottom)
                    .padding(.leading, margins.left)
                    .padding(.trailing, margins.right)
                }

                // Page number footer
                VStack {
                    Spacer()
                    Text("\(pageNumber)")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorPalette.textTertiary)
                        .padding(.bottom, max(8, margins.bottom / 2))
                }
            }
            .frame(
                width: paperSize.widthPoints,
                height: paperSize.heightPoints
            )
            .clipShape(Rectangle())
        }
        .frame(width: paperSize.widthPoints + bleed * 2, height: paperSize.heightPoints + bleed * 2)
    }
}

struct PageContentView: NSViewRepresentable {
    let attributedString: NSAttributedString
    let contentWidth: CGFloat

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: "")
        field.isEditable = false
        field.isSelectable = false
        field.isBordered = false
        field.drawsBackground = false
        field.preferredMaxLayoutWidth = contentWidth
        field.attributedStringValue = attributedString
        return field
    }

    func updateNSView(_ field: NSTextField, context: Context) {
        field.attributedStringValue = attributedString
        field.preferredMaxLayoutWidth = contentWidth
    }
}
