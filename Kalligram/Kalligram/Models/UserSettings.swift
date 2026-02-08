import SwiftData
import Foundation

@Model
final class UserSettings {
    var id: UUID

    // MARK: - Appearance
    var preferredColorScheme: String
    var editorFontName: String
    var editorFontSize: Double
    var defaultLineSpacing: Double
    var defaultPaperSize: String
    var showWordCount: Bool
    var showPageCount: Bool
    var typewriterScrolling: Bool
    var modelPickerModels: String = AIModelCatalog.allModels.joined(separator: ",")
    var searchModel: String = AIModelCatalog.defaultSearchModel

    // MARK: - AI
    var preferredAIProvider: String
    var preferredModel: String
    var defaultAITone: String
    var enableGhostText: Bool

    // MARK: - Autosave
    var autosaveIntervalSeconds: Int
    var maxVersionsPerDocument: Int

    // MARK: - Export
    var defaultExportFormat: String
    var defaultCitationStyle: String

    // MARK: - Focus Mode
    var focusModeHideWordCount: Bool
    var focusModeHideToolbar: Bool

    init() {
        self.id = UUID()
        self.preferredColorScheme = "system"
        self.editorFontName = "Georgia"
        self.editorFontSize = 16
        self.defaultLineSpacing = 1.5
        self.defaultPaperSize = PaperSize.letter.rawValue
        self.showWordCount = true
        self.showPageCount = true
        self.typewriterScrolling = false
        self.modelPickerModels = AIModelCatalog.allModels.joined(separator: ",")
        self.searchModel = AIModelCatalog.defaultSearchModel
        self.preferredAIProvider = "openrouter"
        self.preferredModel = "anthropic/claude-sonnet-4"
        self.defaultAITone = AITone.neutral.rawValue
        self.enableGhostText = true
        self.autosaveIntervalSeconds = 30
        self.maxVersionsPerDocument = 50
        self.defaultExportFormat = ExportFormat.pdf.rawValue
        self.defaultCitationStyle = "APA"
        self.focusModeHideWordCount = true
        self.focusModeHideToolbar = false
    }
}
