import SwiftData
import Foundation

@Model
final class AIAction {
    var id: UUID
    var actionType: String
    var prompt: String
    var inputText: String
    var outputText: String
    var selectedOptionIndex: Int?
    var wasAccepted: Bool
    var createdAt: Date
    var providerName: String
    var modelName: String
    var tokenCount: Int?

    var document: Document?

    init(
        actionType: AIActionType,
        prompt: String,
        inputText: String,
        outputText: String,
        providerName: String,
        modelName: String
    ) {
        self.id = UUID()
        self.actionType = actionType.rawValue
        self.prompt = prompt
        self.inputText = inputText
        self.outputText = outputText
        self.wasAccepted = false
        self.createdAt = Date()
        self.providerName = providerName
        self.modelName = modelName
    }

    var actionTypeEnum: AIActionType {
        AIActionType(rawValue: actionType) ?? .rewrite
    }
}
