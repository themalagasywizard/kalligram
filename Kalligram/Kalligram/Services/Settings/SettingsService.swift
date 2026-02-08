import SwiftData
import Foundation

@Observable
final class SettingsService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getSettings() -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let settings = UserSettings()
        modelContext.insert(settings)
        return settings
    }

    func resetToDefaults() {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? modelContext.fetch(descriptor) {
            for settings in existing {
                modelContext.delete(settings)
            }
        }
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
    }
}
