import SwiftUI
import SwiftData

@Observable
final class ResearchViewModel {
    var query: String = ""
    var result: ResearchResult?
    var isLoading: Bool = false
    var error: String?
    var searchHistory: [String] = []

    func search(using settings: UserSettings, documentContext: String? = nil) async {
        guard !query.isEmpty else { return }
        guard let service = AIServiceFactory.createFromSettings(settings) else {
            error = AIError.notConfigured.errorDescription
            return
        }

        isLoading = true
        error = nil

        do {
            result = try await service.research(query: query, context: documentContext)
            if !searchHistory.contains(query) {
                searchHistory.insert(query, at: 0)
                if searchHistory.count > 10 { searchHistory.removeLast() }
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        query = ""
        result = nil
        isLoading = false
        error = nil
    }
}
