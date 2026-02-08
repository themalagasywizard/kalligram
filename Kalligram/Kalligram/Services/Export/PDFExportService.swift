import Foundation
import AppKit

final class PDFExportService: ExportServiceProtocol {
    let format: ExportFormat = .pdf

    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data {
        let paginator = PaginationViewModel()
        paginator.paginate(
            attributedString: attributedString,
            paperSize: metadata.paperSize,
            margins: metadata.margins
        )

        let pdfData = NSMutableData()
        let pdfBounds = CGRect(
            x: 0, y: 0,
            width: metadata.paperSize.widthPoints,
            height: metadata.paperSize.heightPoints
        )

        let consumer = CGDataConsumer(data: pdfData)!
        var mediaBox = pdfBounds
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ExportError.pdfCreationFailed
        }

        let contentRect = CGRect(
            x: metadata.margins.left,
            y: metadata.margins.bottom,
            width: metadata.paperSize.widthPoints - metadata.margins.left - metadata.margins.right,
            height: metadata.paperSize.heightPoints - metadata.margins.top - metadata.margins.bottom
        )

        let pages = paginator.pages.isEmpty
            ? [PaginationViewModel.PageInfo(id: 1, characterRange: NSRange(location: 0, length: attributedString.length), content: attributedString)]
            : paginator.pages

        for (index, page) in pages.enumerated() {
            pdfContext.beginPage(mediaBox: &mediaBox)

            let framesetter = CTFramesetterCreateWithAttributedString(page.content as CFAttributedString)
            let framePath = CGPath(rect: contentRect, transform: nil)
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), framePath, nil)
            CTFrameDraw(frame, pdfContext)

            if metadata.includePageNumbers {
                drawPageNumber(
                    pageNumber: index + 1,
                    in: pdfContext,
                    paperSize: metadata.paperSize,
                    margins: metadata.margins
                )
            }

            pdfContext.endPage()
        }

        pdfContext.closePDF()
        return pdfData as Data
    }
}

private func drawPageNumber(
    pageNumber: Int,
    in context: CGContext,
    paperSize: PaperSize,
    margins: NSEdgeInsets
) {
    let numberString = "\(pageNumber)"
    let font = NSFont.systemFont(ofSize: 10)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.secondaryLabelColor
    ]
    let attributed = NSAttributedString(string: numberString, attributes: attrs)
    let line = CTLineCreateWithAttributedString(attributed)
    let lineWidth = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    let x = (paperSize.widthPoints - lineWidth) / 2
    let y = max(8, margins.bottom / 2)
    context.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, context)
}

enum ExportError: LocalizedError {
    case pdfCreationFailed
    case docxCreationFailed
    case epubCreationFailed
    case invalidContent

    var errorDescription: String? {
        switch self {
        case .pdfCreationFailed: "Failed to create PDF"
        case .docxCreationFailed: "Failed to create DOCX"
        case .epubCreationFailed: "Failed to create EPUB"
        case .invalidContent: "Invalid document content"
        }
    }
}
