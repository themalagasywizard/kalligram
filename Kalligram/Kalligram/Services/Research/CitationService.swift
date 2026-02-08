import Foundation

enum CitationStyle: String, CaseIterable, Sendable {
    case apa
    case mla
    case chicago

    var displayName: String {
        switch self {
        case .apa: "APA"
        case .mla: "MLA"
        case .chicago: "Chicago"
        }
    }
}

enum CitationService {
    static func format(source: SourceSuggestion, style: CitationStyle) -> String {
        let authors = source.authors.isEmpty ? "Unknown Author" : source.authors
        let title = source.title
        let date = source.publishDate ?? "n.d."

        switch style {
        case .apa:
            var citation = "\(authors) (\(date)). \(title)."
            if let url = source.url { citation += " Retrieved from \(url)" }
            return citation

        case .mla:
            var citation = "\(authors). \"\(title).\""
            if let url = source.url { citation += " Web. \(url)." }
            citation += " \(date)."
            return citation

        case .chicago:
            var citation = "\(authors). \"\(title).\""
            if let url = source.url { citation += " \(url)." }
            citation += " Accessed \(Date().formatted(date: .long, time: .omitted))."
            return citation
        }
    }

    static func formatBibliography(sources: [SourceSuggestion], style: CitationStyle) -> String {
        let sorted = sources.sorted { $0.authors < $1.authors }
        return sorted.map { format(source: $0, style: style) }.joined(separator: "\n\n")
    }
}
