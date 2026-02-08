import Foundation

enum DocumentType: String, Codable, CaseIterable, Sendable {
    case article
    case academicPaper
    case book
    case blogPost
    case report
    case custom

    var displayName: String {
        switch self {
        case .article: "Article"
        case .academicPaper: "Academic Paper"
        case .book: "Book"
        case .blogPost: "Blog Post"
        case .report: "Report"
        case .custom: "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .article: SFSymbolTokens.article
        case .academicPaper: SFSymbolTokens.academicPaper
        case .book: SFSymbolTokens.book
        case .blogPost: SFSymbolTokens.blogPost
        case .report: SFSymbolTokens.report
        case .custom: SFSymbolTokens.allDocuments
        }
    }
}
