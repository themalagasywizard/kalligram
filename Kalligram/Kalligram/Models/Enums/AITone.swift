import Foundation

enum AITone: String, Codable, CaseIterable, Sendable {
    case neutral
    case formal
    case casual
    case academic
    case persuasive
    case concise
    case creative

    var displayName: String {
        switch self {
        case .neutral: "Neutral"
        case .formal: "Formal"
        case .casual: "Casual"
        case .academic: "Academic"
        case .persuasive: "Persuasive"
        case .concise: "Concise"
        case .creative: "Creative"
        }
    }

    var promptModifier: String {
        switch self {
        case .neutral: "Write in a clear, balanced tone."
        case .formal: "Write in a formal, professional tone suitable for business or official communication."
        case .casual: "Write in a relaxed, conversational tone as if speaking to a friend."
        case .academic: "Write in a scholarly, precise tone with careful reasoning and citations where appropriate."
        case .persuasive: "Write in a compelling, persuasive tone that builds a strong argument."
        case .concise: "Write as concisely as possible while preserving all key information."
        case .creative: "Write in a vivid, engaging, and creative tone that captivates the reader."
        }
    }
}
