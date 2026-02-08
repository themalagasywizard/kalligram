import SwiftUI
import SwiftData

@Observable
final class AIRewriteViewModel {
    var selectedText: String = ""
    var selectedTone: AITone = .neutral
    var goal: String = ""
    var options: [String] = []
    var diffs: [[DiffChunk]] = []
    var isLoading: Bool = false
    var error: String?
    var selectedOptionIndex: Int?

    func rewrite(using settings: UserSettings) async {
        guard !selectedText.isEmpty else { return }
        guard let service = AIServiceFactory.createFromSettings(settings) else {
            error = AIError.notConfigured.errorDescription
            return
        }

        isLoading = true
        error = nil
        options = []
        diffs = []
        selectedOptionIndex = nil

        do {
            let results = try await service.rewrite(text: selectedText, tone: selectedTone, goal: goal.isEmpty ? nil : goal, count: 3)
            options = results
            diffs = results.map { DiffEngine.diff(old: selectedText, new: $0) }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        selectedText = ""
        options = []
        diffs = []
        isLoading = false
        error = nil
        selectedOptionIndex = nil
        goal = ""
    }
}
