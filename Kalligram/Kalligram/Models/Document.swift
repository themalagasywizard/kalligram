import SwiftData
import Foundation

@Model
final class Document {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var wordCountGoal: Int?
    var documentType: String
    var viewMode: String
    var paperSize: String
    var marginTop: Double
    var marginBottom: Double
    var marginLeft: Double
    var marginRight: Double
    var lineSpacing: Double
    var paragraphSpacingBefore: Double = 0
    var paragraphSpacing: Double
    var firstLineIndent: Double = 0
    var bodyFontName: String = "Georgia"
    var bodyFontSize: Double = 16
    var bodyAlignment: String = ParagraphAlignment.left.rawValue
    var hyphenationEnabled: Bool = false
    var includePageNumbers: Bool = true
    var includeTableOfContents: Bool = false
    var isPinned: Bool
    var isFavorite: Bool
    var lastCursorPosition: Int
    var sortOrder: Int

    // Import metadata (nil for documents created natively)
    var sourceFilePath: String?
    var sourceFileType: String?
    var importedAt: Date?

    var contentRTFData: Data?
    var contentPlainText: String

    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \DocumentSection.document)
    var sections: [DocumentSection]

    @Relationship(deleteRule: .cascade, inverse: \Citation.document)
    var citations: [Citation]

    @Relationship(deleteRule: .cascade, inverse: \Comment.document)
    var comments: [Comment]

    @Relationship(deleteRule: .cascade, inverse: \Version.document)
    var versions: [Version]

    @Relationship(deleteRule: .cascade, inverse: \AIAction.document)
    var aiActions: [AIAction]

    init(
        title: String,
        documentType: DocumentType = .article
    ) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.documentType = documentType.rawValue
        self.viewMode = ViewMode.paginated.rawValue
        self.paperSize = PaperSize.letter.rawValue
        self.marginTop = 72
        self.marginBottom = 72
        self.marginLeft = 72
        self.marginRight = 72
        self.lineSpacing = 1.5
        self.paragraphSpacingBefore = 0
        self.paragraphSpacing = 12
        self.firstLineIndent = 0
        self.bodyFontName = "Georgia"
        self.bodyFontSize = 16
        self.bodyAlignment = ParagraphAlignment.left.rawValue
        self.hyphenationEnabled = false
        self.includePageNumbers = true
        self.includeTableOfContents = false
        self.isPinned = false
        self.isFavorite = false
        self.lastCursorPosition = 0
        self.sortOrder = 0
        self.contentPlainText = ""
        self.sections = []
        self.citations = []
        self.comments = []
        self.versions = []
        self.aiActions = []
    }

    // MARK: - Computed

    var documentTypeEnum: DocumentType {
        get { DocumentType(rawValue: documentType) ?? .article }
        set { documentType = newValue.rawValue }
    }

    var viewModeEnum: ViewMode {
        get { ViewMode(rawValue: viewMode) ?? .draft }
        set { viewMode = newValue.rawValue }
    }

    var paperSizeEnum: PaperSize {
        get { PaperSize(rawValue: paperSize) ?? .letter }
        set { paperSize = newValue.rawValue }
    }

    var bodyAlignmentEnum: ParagraphAlignment {
        get { ParagraphAlignment(rawValue: bodyAlignment) ?? .left }
        set { bodyAlignment = newValue.rawValue }
    }

    var isImported: Bool { sourceFilePath != nil }

    var sourceFileTypeDisplay: String? { sourceFileType?.uppercased() }

    var wordCount: Int {
        contentPlainText.split(whereSeparator: \.isWhitespace).count
    }

    var characterCount: Int {
        contentPlainText.count
    }
}
