import Foundation
import AppKit

final class DOCXExportService: ExportServiceProtocol {
    let format: ExportFormat = .docx

    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data {
        // Use NSAttributedString's built-in DOCX support
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.officeOpenXML,
            .paperSize: NSSize(
                width: metadata.paperSize.widthPoints,
                height: metadata.paperSize.heightPoints
            ),
            .topMargin: metadata.margins.top,
            .bottomMargin: metadata.margins.bottom,
            .leftMargin: metadata.margins.left,
            .rightMargin: metadata.margins.right
        ]

        do {
            let data = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: documentAttributes
            )
            if !data.isEmpty {
                return data
            }
        } catch {
            // Fall through to file wrapper fallback.
        }

        let fileWrapper = try attributedString.fileWrapper(
            from: NSRange(location: 0, length: attributedString.length),
            documentAttributes: documentAttributes
        )

        if let data = fileWrapper.regularFileContents, !data.isEmpty {
            return data
        }

        if let serialized = fileWrapper.serializedRepresentation, !serialized.isEmpty {
            return serialized
        }

        throw ExportError.docxCreationFailed
    }
}
