import Foundation
import AppKit

protocol ExportServiceProtocol {
    var format: ExportFormat { get }
    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data
}

struct ExportMetadata {
    let title: String
    let author: String
    let paperSize: PaperSize
    let margins: NSEdgeInsets
    let lineSpacing: Double
    let includePageNumbers: Bool
    let includeTableOfContents: Bool
}
