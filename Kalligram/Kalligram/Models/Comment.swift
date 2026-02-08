import SwiftData
import Foundation

@Model
final class Comment {
    var id: UUID
    var content: String
    var authorName: String
    var createdAt: Date
    var updatedAt: Date
    var isResolved: Bool
    var characterRange: Int
    var characterLength: Int
    var highlightedText: String
    var parentCommentID: UUID?

    var document: Document?

    init(
        content: String,
        authorName: String,
        characterRange: Int,
        characterLength: Int,
        highlightedText: String
    ) {
        self.id = UUID()
        self.content = content
        self.authorName = authorName
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isResolved = false
        self.characterRange = characterRange
        self.characterLength = characterLength
        self.highlightedText = highlightedText
    }
}
