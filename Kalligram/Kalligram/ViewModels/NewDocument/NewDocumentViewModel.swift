import SwiftUI
import SwiftData

@Observable
final class NewDocumentViewModel {
    var title: String = ""
    var selectedType: DocumentType = .article
    var selectedProjectID: UUID?
    var paperSize: PaperSize = .letter
    var lineSpacing: Double = 1.5
    var wordCountGoal: String = ""
    var showAdvanced: Bool = false
    var selectedTemplateIndex: Int?

    struct TemplateInfo: Identifiable {
        let id = UUID()
        let name: String
        let description: String
        let icon: String
        let documentType: DocumentType
        let sections: [SectionDef]
        let lineSpacing: Double

        struct SectionDef: Codable {
            let title: String
            let level: Int
        }
    }

    var builtInTemplates: [TemplateInfo] {
        [
            TemplateInfo(
                name: "Blank Document",
                description: "Start from scratch",
                icon: "doc",
                documentType: .article,
                sections: [],
                lineSpacing: 1.5
            ),
            TemplateInfo(
                name: "Academic Paper",
                description: "APA-style with sections",
                icon: SFSymbolTokens.academicPaper,
                documentType: .academicPaper,
                sections: [
                    .init(title: "Abstract", level: 1),
                    .init(title: "Introduction", level: 1),
                    .init(title: "Literature Review", level: 1),
                    .init(title: "Methodology", level: 1),
                    .init(title: "Results", level: 1),
                    .init(title: "Discussion", level: 1),
                    .init(title: "Conclusion", level: 1),
                    .init(title: "References", level: 1)
                ],
                lineSpacing: 2.0
            ),
            TemplateInfo(
                name: "Book Manuscript",
                description: "Standard manuscript with chapters",
                icon: SFSymbolTokens.book,
                documentType: .book,
                sections: [
                    .init(title: "Chapter 1", level: 1),
                    .init(title: "Chapter 2", level: 1),
                    .init(title: "Chapter 3", level: 1)
                ],
                lineSpacing: 2.0
            ),
            TemplateInfo(
                name: "Blog Post",
                description: "Web-ready article",
                icon: SFSymbolTokens.blogPost,
                documentType: .blogPost,
                sections: [
                    .init(title: "Introduction", level: 1),
                    .init(title: "Main Point", level: 1),
                    .init(title: "Conclusion", level: 1)
                ],
                lineSpacing: 1.5
            ),
            TemplateInfo(
                name: "Report",
                description: "Professional report",
                icon: SFSymbolTokens.report,
                documentType: .report,
                sections: [
                    .init(title: "Executive Summary", level: 1),
                    .init(title: "Background", level: 1),
                    .init(title: "Findings", level: 1),
                    .init(title: "Recommendations", level: 1)
                ],
                lineSpacing: 1.5
            )
        ]
    }

    func createDocument(in context: ModelContext, projects: [Project]) -> Document {
        let template = selectedTemplateIndex.flatMap { idx in
            idx < builtInTemplates.count ? builtInTemplates[idx] : nil
        }

        let docTitle = title.isEmpty ? "Untitled Document" : title
        let docType = template?.documentType ?? selectedType
        let doc = Document(title: docTitle, documentType: docType)
        doc.lineSpacing = template?.lineSpacing ?? lineSpacing
        doc.paperSize = paperSize.rawValue

        if let goalStr = Int(wordCountGoal), goalStr > 0 {
            doc.wordCountGoal = goalStr
        }

        if let projectID = selectedProjectID,
           let project = projects.first(where: { $0.id == projectID }) {
            doc.project = project
        }

        // Build section content from template
        if let sections = template?.sections, !sections.isEmpty {
            let content = buildTemplateContent(sections)
            doc.contentRTFData = content.toRTFData()
            doc.contentPlainText = content.string
        }

        context.insert(doc)
        return doc
    }

    private func buildTemplateContent(_ sections: [TemplateInfo.SectionDef]) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for (index, section) in sections.enumerated() {
            let font: NSFont
            let paragraphStyle = NSMutableParagraphStyle()

            switch section.level {
            case 1:
                font = Typography.heading1NS
                paragraphStyle.paragraphSpacingBefore = index == 0 ? 0 : 24
                paragraphStyle.paragraphSpacing = 12
            case 2:
                font = Typography.heading2NS
                paragraphStyle.paragraphSpacingBefore = 20
                paragraphStyle.paragraphSpacing = 8
            default:
                font = Typography.heading3NS
                paragraphStyle.paragraphSpacingBefore = 16
                paragraphStyle.paragraphSpacing = 6
            }

            let heading = NSAttributedString(
                string: section.title + "\n\n",
                attributes: [
                    .font: font,
                    .foregroundColor: NSColor.textColor,
                    .paragraphStyle: paragraphStyle
                ]
            )
            result.append(heading)
        }

        return result
    }
}
