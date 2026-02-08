import Foundation
import UniformTypeIdentifiers

enum ExportFormat: String, Codable, CaseIterable, Sendable {
    case pdf
    case docx
    case markdown
    case latex
    case epub

    var displayName: String {
        switch self {
        case .pdf: "PDF"
        case .docx: "Word Document"
        case .markdown: "Markdown"
        case .latex: "LaTeX"
        case .epub: "EPUB"
        }
    }

    var fileExtension: String {
        switch self {
        case .pdf: "pdf"
        case .docx: "docx"
        case .markdown: "md"
        case .latex: "tex"
        case .epub: "epub"
        }
    }

    var iconName: String {
        switch self {
        case .pdf: SFSymbolTokens.pdf
        case .docx: SFSymbolTokens.docx
        case .markdown: SFSymbolTokens.markdown
        case .latex: SFSymbolTokens.latex
        case .epub: SFSymbolTokens.epub
        }
    }

    var contentType: UTType {
        switch self {
        case .pdf: .pdf
        case .docx: UTType(filenameExtension: "docx") ?? .data
        case .markdown: UTType(filenameExtension: "md") ?? .plainText
        case .latex: UTType(filenameExtension: "tex") ?? .plainText
        case .epub: UTType(filenameExtension: "epub") ?? .data
        }
    }
}
