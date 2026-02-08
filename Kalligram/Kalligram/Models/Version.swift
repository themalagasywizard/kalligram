import SwiftData
import Foundation

@Model
final class Version {
    var id: UUID
    var label: String
    var createdAt: Date
    var contentRTFData: Data?
    var contentPlainText: String
    var wordCount: Int
    var pageCount: Int = 1
    var triggerType: String
    var aiActionID: UUID?
    var previewImagePath: String?
    var branchName: String = "Main"
    var parentVersionID: UUID?

    // Layout snapshot
    var paperSize: String = PaperSize.letter.rawValue
    var marginTop: Double = 72
    var marginBottom: Double = 72
    var marginLeft: Double = 72
    var marginRight: Double = 72
    var lineSpacing: Double = 1.5
    var paragraphSpacingBefore: Double = 0
    var paragraphSpacing: Double = 12
    var firstLineIndent: Double = 0
    var bodyFontName: String = "Georgia"
    var bodyFontSize: Double = 16
    var bodyAlignment: String = ParagraphAlignment.left.rawValue
    var hyphenationEnabled: Bool = false
    var includePageNumbers: Bool = true
    var includeTableOfContents: Bool = false

    var document: Document?

    init(
        label: String,
        contentRTFData: Data?,
        contentPlainText: String,
        wordCount: Int,
        triggerType: String,
        pageCount: Int = 1
    ) {
        self.id = UUID()
        self.label = label
        self.createdAt = Date()
        self.contentRTFData = contentRTFData
        self.contentPlainText = contentPlainText
        self.wordCount = wordCount
        self.triggerType = triggerType
        self.pageCount = pageCount
    }
}
