import Foundation
import AppKit

final class LaTeXExportService: ExportServiceProtocol {
    let format: ExportFormat = .latex

    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data {
        var latex = """
        \\documentclass[12pt]{article}
        \\usepackage[utf8]{inputenc}
        \\usepackage[T1]{fontenc}
        \\usepackage{geometry}
        \\geometry{
            paperwidth=\(Int(metadata.paperSize.widthPoints))pt,
            paperheight=\(Int(metadata.paperSize.heightPoints))pt,
            margin=\(Int(metadata.margins.left))pt
        }
        \\usepackage{setspace}
        \\setstretch{\(metadata.lineSpacing)}
        \\usepackage{soul}
        \\usepackage{hyperref}

        \\title{\(escapeLatex(metadata.title))}
        \\author{\(escapeLatex(metadata.author))}
        \\date{\\today}

        \\begin{document}
        \\maketitle

        """

        let string = attributedString.string

        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) { attrs, range, _ in
            let text = (string as NSString).substring(with: range)
            let escaped = escapeLatex(text)

            if let font = attrs[.font] as? NSFont {
                let size = font.pointSize
                if size >= 26 {
                    latex += "\\section*{\(escaped)}\n"
                    return
                } else if size >= 20 {
                    latex += "\\subsection*{\(escaped)}\n"
                    return
                } else if size >= 17 {
                    latex += "\\subsubsection*{\(escaped)}\n"
                    return
                }

                let traits = font.fontDescriptor.symbolicTraits
                var wrapped = escaped
                if traits.contains(.bold) { wrapped = "\\textbf{\(wrapped)}" }
                if traits.contains(.italic) { wrapped = "\\textit{\(wrapped)}" }

                if let strikethrough = attrs[.strikethroughStyle] as? Int, strikethrough != 0 {
                    wrapped = "\\st{\(wrapped)}"
                }
                if let underline = attrs[.underlineStyle] as? Int, underline != 0 {
                    wrapped = "\\underline{\(wrapped)}"
                }

                latex += wrapped
            } else {
                latex += escaped
            }
        }

        latex += "\n\\end{document}\n"

        guard let data = latex.data(using: .utf8) else {
            throw ExportError.invalidContent
        }
        return data
    }

    private func escapeLatex(_ text: String) -> String {
        text.replacingOccurrences(of: "\\", with: "\\textbackslash{}")
            .replacingOccurrences(of: "&", with: "\\&")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "$", with: "\\$")
            .replacingOccurrences(of: "#", with: "\\#")
            .replacingOccurrences(of: "_", with: "\\_")
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
            .replacingOccurrences(of: "~", with: "\\textasciitilde{}")
            .replacingOccurrences(of: "^", with: "\\textasciicircum{}")
    }
}
