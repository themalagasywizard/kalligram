import Foundation
import AppKit

enum MarkdownParser {
    static func parse(_ markdown: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let lines = markdown.components(separatedBy: "\n")

        let bodyParagraph = NSMutableParagraphStyle()
        bodyParagraph.lineSpacing = 10

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("### ") {
                let text = String(trimmed.dropFirst(4))
                let attr = NSAttributedString(string: text + "\n", attributes: [
                    .font: Typography.heading3NS,
                    .paragraphStyle: bodyParagraph
                ])
                result.append(attr)
            } else if trimmed.hasPrefix("## ") {
                let text = String(trimmed.dropFirst(3))
                let attr = NSAttributedString(string: text + "\n", attributes: [
                    .font: Typography.heading2NS,
                    .paragraphStyle: bodyParagraph
                ])
                result.append(attr)
            } else if trimmed.hasPrefix("# ") {
                let text = String(trimmed.dropFirst(2))
                let attr = NSAttributedString(string: text + "\n", attributes: [
                    .font: Typography.heading1NS,
                    .paragraphStyle: bodyParagraph
                ])
                result.append(attr)
            } else {
                let processed = processInlineFormatting(trimmed)
                let mutable = NSMutableAttributedString(attributedString: processed)
                mutable.append(NSAttributedString(string: "\n"))
                result.append(mutable)
            }
        }

        return result
    }

    private static func processInlineFormatting(_ text: String) -> NSAttributedString {
        // Simple implementation — just return plain text with body font for now
        // Full implementation would parse **bold**, *italic*, ~~strikethrough~~, etc.
        let bodyFont = Typography.editorBodyNS
        return NSAttributedString(string: text, attributes: [
            .font: bodyFont,
            .foregroundColor: NSColor.textColor
        ])
    }
}
