import Foundation
import SwiftData

final class VersionService {
    static func createSnapshot(
        for document: Document,
        triggerType: String,
        modelContext: ModelContext
    ) -> Version {
        let version = Version(
            label: "\(triggerType.capitalized) — \(Date().formatted(date: .abbreviated, time: .shortened))",
            contentRTFData: document.contentRTFData,
            contentPlainText: document.contentPlainText,
            wordCount: document.wordCount,
            triggerType: triggerType
        )
        version.document = document
        modelContext.insert(version)
        return version
    }

    static func restore(
        version: Version,
        to document: Document,
        modelContext: ModelContext
    ) {
        // First save current state as a snapshot
        _ = createSnapshot(for: document, triggerType: "pre_restore", modelContext: modelContext)

        // Then restore
        document.contentRTFData = version.contentRTFData
        document.contentPlainText = version.contentPlainText
        document.updatedAt = Date()
    }

    static func branchToNewDocument(
        from version: Version,
        title: String,
        modelContext: ModelContext
    ) -> Document {
        let newDoc = Document(title: title)
        newDoc.contentRTFData = version.contentRTFData
        newDoc.contentPlainText = version.contentPlainText
        modelContext.insert(newDoc)
        return newDoc
    }

    static func pruneVersions(
        for document: Document,
        keepLast count: Int = 50,
        modelContext: ModelContext
    ) {
        let sorted = document.versions.sorted { $0.createdAt > $1.createdAt }
        if sorted.count > count {
            for version in sorted.dropFirst(count) {
                modelContext.delete(version)
            }
        }
    }
}
