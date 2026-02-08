import Foundation
import AppKit

final class PDFExportService: ExportServiceProtocol {
    let format: ExportFormat = .pdf

    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data {
        let printInfo = NSPrintInfo()
        printInfo.paperSize = NSSize(
            width: metadata.paperSize.widthPoints,
            height: metadata.paperSize.heightPoints
        )
        printInfo.topMargin = metadata.margins.top
        printInfo.bottomMargin = metadata.margins.bottom
        printInfo.leftMargin = metadata.margins.left
        printInfo.rightMargin = metadata.margins.right
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false

        let contentWidth = metadata.paperSize.widthPoints - metadata.margins.left - metadata.margins.right
        let contentHeight = metadata.paperSize.heightPoints - metadata.margins.top - metadata.margins.bottom

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(
            containerSize: NSSize(width: contentWidth, height: contentHeight)
        )
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        let textView = NSTextView(frame: NSRect(
            x: 0, y: 0,
            width: contentWidth,
            height: contentHeight
        ))
        textView.textStorage?.setAttributedString(attributedString)
        textView.sizeToFit()

        let pdfData = NSMutableData()

        let printOp = NSPrintOperation(view: textView, printInfo: printInfo)
        printOp.showsPrintPanel = false
        printOp.showsProgressPanel = false

        // Use the PDF output method
        if let data = textView.dataWithPDF(inside: textView.bounds) as Data? {
            return data
        }

        // Fallback: create a simple PDF from attributed string
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

        pdfContext.beginPage(mediaBox: &mediaBox)

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        let framePath = CGPath(rect: CGRect(
            x: metadata.margins.left,
            y: metadata.margins.bottom,
            width: contentWidth,
            height: contentHeight
        ), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), framePath, nil)
        CTFrameDraw(frame, pdfContext)

        pdfContext.endPage()
        pdfContext.closePDF()

        return pdfData as Data
    }
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
