import SwiftData
import Foundation

@Model
final class Citation {
    var id: UUID
    var title: String
    var authors: String
    var publicationDate: Date?
    var source: String
    var url: String?
    var doi: String?
    var abstract: String?
    var reliabilityScore: Double?
    var citationStyle: String
    var formattedCitation: String
    var characterRange: Int
    var sortOrder: Int

    var document: Document?

    init(
        authors: String,
        source: String,
        title: String = "",
        url: String? = nil,
        abstract: String? = nil,
        reliabilityScore: Double? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.authors = authors
        self.source = source
        self.url = url
        self.abstract = abstract
        self.reliabilityScore = reliabilityScore
        self.citationStyle = "APA"
        self.formattedCitation = ""
        self.characterRange = 0
        self.sortOrder = 0
    }
}
