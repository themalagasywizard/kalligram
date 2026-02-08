import Foundation
import AppKit

final class MarkdownExportService: ExportServiceProtocol {
    let format: ExportFormat = .markdown

    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data {
        var markdown = ""
        let string = attributedString.string

        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) { attrs, range, _ in
            let text = (string as NSString).substring(with: range)

            // Check for heading
            if let font = attrs[.font] as? NSFont {
                let size = font.pointSize
                if size >= 26 {
                    markdown += "# \(text)"
                    return
                } else if size >= 20 {
                    markdown += "## \(text)"
                    return
                } else if size >= 17 {
                    markdown += "### \(text)"
                    return
                }

                // Bold + Italic
                let traits = font.fontDescriptor.symbolicTraits
                var wrapped = text
                if traits.contains(.bold) && traits.contains(.italic) {
                    wrapped = "***\(wrapped)***"
                } else if traits.contains(.bold) {
                    wrapped = "**\(wrapped)**"
                } else if traits.contains(.italic) {
                    wrapped = "*\(wrapped)*"
                }

                // Strikethrough
                if let strikethrough = attrs[.strikethroughStyle] as? Int, strikethrough != 0 {
                    wrapped = "~~\(wrapped)~~"
                }

                // Underline (no standard markdown, use HTML)
                if let underline = attrs[.underlineStyle] as? Int, underline != 0 {
                    wrapped = "<u>\(wrapped)</u>"
                }

                markdown += wrapped
            } else {
                markdown += text
            }
        }

        guard let data = markdown.data(using: .utf8) else {
            throw ExportError.invalidContent
        }
        return data
    }
}
