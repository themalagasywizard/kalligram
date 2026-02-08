import SwiftData
import Foundation

@Observable
final class DocumentService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(title: String, type: DocumentType, project: Project? = nil) -> Document {
        let document = Document(title: title, documentType: type)
        document.project = project
        modelContext.insert(document)
        return document
    }

    func fetchAll() -> [Document] {
        let descriptor = FetchDescriptor<Document>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func delete(_ document: Document) {
        modelContext.delete(document)
    }

    func duplicate(_ document: Document) -> Document {
        let copy = Document(title: "\(document.title) (Copy)", documentType: document.documentTypeEnum)
        copy.contentRTFData = document.contentRTFData
        copy.contentPlainText = document.contentPlainText
        copy.project = document.project
        copy.marginTop = document.marginTop
        copy.marginBottom = document.marginBottom
        copy.marginLeft = document.marginLeft
        copy.marginRight = document.marginRight
        copy.lineSpacing = document.lineSpacing
        copy.paragraphSpacingBefore = document.paragraphSpacingBefore
        copy.paragraphSpacing = document.paragraphSpacing
        copy.firstLineIndent = document.firstLineIndent
        copy.bodyFontName = document.bodyFontName
        copy.bodyFontSize = document.bodyFontSize
        copy.bodyAlignment = document.bodyAlignment
        copy.hyphenationEnabled = document.hyphenationEnabled
        copy.includePageNumbers = document.includePageNumbers
        copy.includeTableOfContents = document.includeTableOfContents
        copy.paperSize = document.paperSize
        modelContext.insert(copy)
        return copy
    }

    func updatePlainTextIndex(_ document: Document, from attributedString: NSAttributedString) {
        document.contentPlainText = attributedString.string
        document.updatedAt = Date()
    }
}
