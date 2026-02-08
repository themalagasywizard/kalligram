import SwiftData
import Foundation

@Model
final class Project {
    var id: UUID
    var name: String
    var projectDescription: String
    var createdAt: Date
    var updatedAt: Date
    var colorTag: String?
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Document.project)
    var documents: [Document]

    init(name: String, projectDescription: String = "") {
        self.id = UUID()
        self.name = name
        self.projectDescription = projectDescription
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = 0
        self.documents = []
    }
}
