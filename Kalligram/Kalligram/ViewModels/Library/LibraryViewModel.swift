import SwiftUI
import SwiftData

@Observable
final class LibraryViewModel {
    var searchQuery = ""
    var sortOrder: SortOrder = .dateModified

    enum SortOrder: String, CaseIterable {
        case dateModified
        case dateCreated
        case title
        case wordCount

        var displayName: String {
            switch self {
            case .dateModified: "Date Modified"
            case .dateCreated: "Date Created"
            case .title: "Title"
            case .wordCount: "Word Count"
            }
        }
    }

    func filteredDocuments(_ documents: [Document]) -> [Document] {
        guard !searchQuery.isEmpty else { return documents }
        return documents.filter { doc in
            doc.title.localizedCaseInsensitiveContains(searchQuery) ||
            doc.contentPlainText.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
