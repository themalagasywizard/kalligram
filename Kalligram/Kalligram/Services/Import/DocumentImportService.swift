import AppKit
import UniformTypeIdentifiers
import PDFKit

enum DocumentImportError: LocalizedError {
    case unsupportedType
    case readFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedType: "Unsupported file type."
        case .readFailed: "Failed to read the file."
        }
    }
}

struct ImportResult {
    let attributedString: NSAttributedString
    let originalFileName: String
    let sourceFileType: String
    let sourceFilePath: String
}

struct DocumentImportService {
    static let supportedTypes: [UTType] = [
        .folder,
        .plainText,
        .rtf,
        .pdf,
        UTType(filenameExtension: "docx") ?? .data
    ]
    private static let supportedExtensions: Set<String> = [
        "txt", "md", "rtf", "pdf", "docx"
    ]

    static func isSupportedFileURL(_ url: URL) -> Bool {
        supportedExtensions.contains(url.pathExtension.lowercased())
    }

    static func importFile(from url: URL) throws -> ImportResult {
        let attributed = try loadAttributedString(from: url)
        return ImportResult(
            attributedString: attributed,
            originalFileName: url.deletingPathExtension().lastPathComponent,
            sourceFileType: url.pathExtension.lowercased(),
            sourceFilePath: url.path
        )
    }

    static func loadAttributedString(from url: URL) throws -> NSAttributedString {
        let ext = url.pathExtension.lowercased()
        let options: [NSAttributedString.DocumentReadingOptionKey: Any]

        switch ext {
        case "docx":
            options = [.documentType: NSAttributedString.DocumentType.officeOpenXML]
        case "rtf":
            options = [.documentType: NSAttributedString.DocumentType.rtf]
        case "pdf":
            if let pdf = PDFDocument(url: url),
               let text = pdf.string {
                return NSAttributedString(string: text)
            }
            return NSAttributedString(string: "")
        case "txt", "md":
            options = [.documentType: NSAttributedString.DocumentType.plain]
        default:
            throw DocumentImportError.unsupportedType
        }

        do {
            return try NSAttributedString(url: url, options: options, documentAttributes: nil)
        } catch {
            if let data = try? Data(contentsOf: url),
               let string = String(data: data, encoding: .utf8) {
                return NSAttributedString(string: string)
            }
            throw DocumentImportError.readFailed
        }
    }
}
