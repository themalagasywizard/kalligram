import SwiftData
import Foundation

@Model
final class Template {
    var id: UUID
    var name: String
    var templateDescription: String
    var documentType: String
    var iconName: String
    var structureJSON: String
    var defaultContentRTFData: Data?
    var defaultPaperSize: String
    var defaultLineSpacing: Double
    var isBuiltIn: Bool
    var sortOrder: Int

    init(
        name: String,
        templateDescription: String,
        documentType: DocumentType,
        iconName: String
    ) {
        self.id = UUID()
        self.name = name
        self.templateDescription = templateDescription
        self.documentType = documentType.rawValue
        self.iconName = iconName
        self.structureJSON = "[]"
        self.defaultPaperSize = PaperSize.letter.rawValue
        self.defaultLineSpacing = 1.5
        self.isBuiltIn = false
        self.sortOrder = 0
    }

    var documentTypeEnum: DocumentType {
        DocumentType(rawValue: documentType) ?? .article
    }

    struct SectionDefinition: Codable {
        let title: String
        let level: Int
    }

    var sectionDefinitions: [SectionDefinition] {
        guard let data = structureJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([SectionDefinition].self, from: data)) ?? []
    }
}
