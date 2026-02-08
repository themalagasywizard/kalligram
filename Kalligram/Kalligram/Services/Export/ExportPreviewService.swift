import Foundation
import AppKit

enum ExportPreviewService {
    static func previewText(for format: ExportFormat, attributedString: NSAttributedString, metadata: ExportMetadata) -> String {
        switch format {
        case .pdf:
            return "PDF preview will be generated on export.\n\nPages: ~\(estimatePageCount(attributedString: attributedString, metadata: metadata))\nPaper: \(metadata.paperSize.displayName)"
        case .docx:
            return "Word document with rich text formatting.\n\nWord count: \(attributedString.string.split(whereSeparator: \.isWhitespace).count)"
        case .markdown:
            let service = MarkdownExportService()
            if let data = try? service.export(attributedString: attributedString, metadata: metadata),
               let preview = String(data: data, encoding: .utf8) {
                return String(preview.prefix(1000))
            }
            return "Markdown preview unavailable"
        case .latex:
            let service = LaTeXExportService()
            if let data = try? service.export(attributedString: attributedString, metadata: metadata),
               let preview = String(data: data, encoding: .utf8) {
                return String(preview.prefix(1000))
            }
            return "LaTeX preview unavailable"
        case .epub:
            return "EPUB3 electronic book format.\n\nChapters: Derived from headings\nWord count: \(attributedString.string.split(whereSeparator: \.isWhitespace).count)"
        }
    }

    private static func estimatePageCount(attributedString: NSAttributedString, metadata: ExportMetadata) -> Int {
        let contentHeight = metadata.paperSize.heightPoints - metadata.margins.top - metadata.margins.bottom
        let linesPerPage = Int(contentHeight / 20) // rough estimate
        let totalLines = attributedString.string.components(separatedBy: "\n").count
        return max(1, totalLines / linesPerPage + 1)
    }
}
