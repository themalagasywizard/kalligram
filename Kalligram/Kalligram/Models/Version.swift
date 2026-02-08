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
    var triggerType: String
    var aiActionID: UUID?

    var document: Document?

    init(
        label: String,
        contentRTFData: Data?,
        contentPlainText: String,
        wordCount: Int,
        triggerType: String
    ) {
        self.id = UUID()
        self.label = label
        self.createdAt = Date()
        self.contentRTFData = contentRTFData
        self.contentPlainText = contentPlainText
        self.wordCount = wordCount
        self.triggerType = triggerType
    }
}
