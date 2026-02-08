import Foundation

final class ResearchService {
    private let settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings
    }

    func research(query: String, documentContext: String?) async throws -> ResearchResult {
        guard let service = AIServiceFactory.createFromSettings(settings) else {
            throw AIError.notConfigured
        }
        return try await service.research(query: query, context: documentContext)
    }

    func findSources(claim: String, count: Int = 5) async throws -> [SourceSuggestion] {
        guard let service = AIServiceFactory.createFromSettings(settings) else {
            throw AIError.notConfigured
        }
        return try await service.findSources(claim: claim, count: count)
    }
}
