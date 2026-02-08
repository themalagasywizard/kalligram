import SwiftData
import Foundation

@Model
final class DocumentSection {
    var id: UUID
    var title: String
    var headingLevel: Int
    var sortOrder: Int
    var characterRange: Int
    var characterLength: Int
    var isCollapsed: Bool

    var document: Document?

    init(
        title: String,
        headingLevel: Int,
        sortOrder: Int,
        characterRange: Int,
        characterLength: Int
    ) {
        self.id = UUID()
        self.title = title
        self.headingLevel = headingLevel
        self.sortOrder = sortOrder
        self.characterRange = characterRange
        self.characterLength = characterLength
        self.isCollapsed = false
    }
}
