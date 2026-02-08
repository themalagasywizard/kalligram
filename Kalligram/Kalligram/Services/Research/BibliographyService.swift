import Foundation
import SwiftData

final class BibliographyService {
    static func generateBibliography(
        from citations: [Citation],
        style: CitationStyle
    ) -> String {
        let header: String
        switch style {
        case .apa: header = "References"
        case .mla: header = "Works Cited"
        case .chicago: header = "Bibliography"
        }

        let sortedCitations = citations.sorted { $0.authors < $1.authors }
        let entries = sortedCitations.map { citation in
            formatCitation(citation, style: style)
        }

        return "\(header)\n\n" + entries.joined(separator: "\n\n")
    }

    private static func formatCitation(_ citation: Citation, style: CitationStyle) -> String {
        let authors = citation.authors.isEmpty ? "Unknown Author" : citation.authors
        let title = citation.source

        switch style {
        case .apa:
            var result = "\(authors). \(title)."
            if let url = citation.url, !url.isEmpty { result += " Retrieved from \(url)" }
            return result

        case .mla:
            var result = "\(authors). \"\(title).\""
            if let url = citation.url, !url.isEmpty { result += " Web. \(url)." }
            return result

        case .chicago:
            var result = "\(authors). \"\(title).\""
            if let url = citation.url, !url.isEmpty { result += " \(url)." }
            return result
        }
    }
}
