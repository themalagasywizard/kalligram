import SwiftData
import Foundation

@Model
final class ResearchNote {
    var id: UUID
    var content: String
    var sourceQuery: String
    var tags: String
    var createdAt: Date
    var isClipped: Bool
    var relatedDocumentID: UUID?
    var relatedCitationID: UUID?

    init(content: String, sourceQuery: String) {
        self.id = UUID()
        self.content = content
        self.sourceQuery = sourceQuery
        self.tags = ""
        self.createdAt = Date()
        self.isClipped = false
    }

    var tagList: [String] {
        get {
            tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        set {
            tags = newValue.joined(separator: ", ")
        }
    }
}
