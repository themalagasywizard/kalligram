import SwiftUI
import AppKit

@Observable
final class ExportViewModel {
    var selectedFormat: ExportFormat = .pdf
    var filename: String = "Untitled"
    var includePageNumbers: Bool = true
    var includeTableOfContents: Bool = false
    var isExporting: Bool = false
    var error: String?
    var previewText: String = ""

    func updatePreview(attributedString: NSAttributedString, metadata: ExportMetadata) {
        previewText = ExportPreviewService.previewText(
            for: selectedFormat,
            attributedString: attributedString,
            metadata: metadata
        )
    }

    func export(
        attributedString: NSAttributedString,
        metadata: ExportMetadata
    ) async -> Data? {
        isExporting = true
        error = nil

        do {
            let service = createService(for: selectedFormat)
            let data = try service.export(attributedString: attributedString, metadata: metadata)
            isExporting = false
            return data
        } catch {
            self.error = error.localizedDescription
            isExporting = false
            return nil
        }
    }

    func saveToFile(data: Data) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [selectedFormat.contentType]
        panel.nameFieldStringValue = "\(filename).\(selectedFormat.fileExtension)"
        panel.canCreateDirectories = true

        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? data.write(to: url)
            }
        }
    }

    private func createService(for format: ExportFormat) -> ExportServiceProtocol {
        switch format {
        case .pdf: PDFExportService()
        case .docx: DOCXExportService()
        case .markdown: MarkdownExportService()
        case .latex: LaTeXExportService()
        case .epub: EPUBExportService()
        }
    }
}
