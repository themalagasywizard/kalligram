import SwiftUI
import SwiftData

@Observable
final class CitationViewModel {
    var citationStyle: CitationStyle = .apa
    var citations: [Citation] = []

    func addCitation(from source: SourceSuggestion, to document: Document, modelContext: ModelContext) {
        let citation = Citation(
            authors: source.authors,
            source: source.title,
            url: source.url,
            abstract: source.abstract,
            reliabilityScore: source.reliabilityScore
        )
        citation.formattedCitation = CitationService.format(source: source, style: citationStyle)
        citation.document = document
        modelContext.insert(citation)
        citations.append(citation)
    }

    func removeCitation(_ citation: Citation, modelContext: ModelContext) {
        modelContext.delete(citation)
        citations.removeAll { $0.id == citation.id }
    }

    func generateBibliography() -> String {
        BibliographyService.generateBibliography(from: citations, style: citationStyle)
    }

    func refreshFormattedCitations() {
        for citation in citations {
            let source = SourceSuggestion(
                id: UUID(),
                title: citation.source,
                authors: citation.authors,
                url: citation.url,
                abstract: citation.abstract,
                reliabilityScore: citation.reliabilityScore ?? 0.5,
                publishDate: nil
            )
            citation.formattedCitation = CitationService.format(source: source, style: citationStyle)
        }
    }
}
