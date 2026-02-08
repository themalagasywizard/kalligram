import SwiftUI
import SwiftData

@Observable
final class AIExpandCondenseViewModel {
    var selectedText: String = ""
    var direction: LengthDirection = .expand
    var factor: Double = 2.0
    var result: String = ""
    var diff: [DiffChunk] = []
    var isLoading: Bool = false
    var error: String?

    var factorLabel: String {
        switch direction {
        case .expand: "\(Int(factor * 100))% longer"
        case .condense: "\(Int(factor * 100))% of original"
        }
    }

    func adjustLength(using settings: UserSettings) async {
        guard !selectedText.isEmpty else { return }
        guard let service = AIServiceFactory.createFromSettings(settings) else {
            error = AIError.notConfigured.errorDescription
            return
        }

        isLoading = true
        error = nil
        result = ""
        diff = []

        do {
            result = try await service.adjustLength(text: selectedText, direction: direction, factor: factor)
            diff = DiffEngine.diff(old: selectedText, new: result)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        selectedText = ""
        result = ""
        diff = []
        isLoading = false
        error = nil
    }
}
