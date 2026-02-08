import SwiftUI
import SwiftData

@Observable
final class AIGenerateViewModel {
    var prompt: String = ""
    var selectedTone: AITone = .neutral
    var audience: String = ""
    var targetLength: Int = 200
    var generatedText: String = ""
    var isLoading: Bool = false
    var error: String?

    func generate(using settings: UserSettings) async {
        guard !prompt.isEmpty else { return }
        guard let service = AIServiceFactory.createFromSettings(settings) else {
            error = AIError.notConfigured.errorDescription
            return
        }

        isLoading = true
        error = nil
        generatedText = ""

        do {
            generatedText = try await service.generate(
                prompt: prompt,
                tone: selectedTone,
                audience: audience.isEmpty ? nil : audience,
                lengthWords: targetLength,
                citationContext: nil
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        prompt = ""
        generatedText = ""
        isLoading = false
        error = nil
        audience = ""
        targetLength = 200
    }
}
