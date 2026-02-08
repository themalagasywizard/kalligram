import Foundation

enum LengthDirection: String, Sendable {
    case expand, condense
}

struct AIModel: Identifiable, Sendable {
    let id: String
    let displayName: String
    let contextWindow: Int
    let costPerMillionTokens: Double?
}

struct ResearchResult: Sendable {
    let summary: String
    let sources: [SourceSuggestion]
    let relatedQueries: [String]
}

struct SourceSuggestion: Identifiable, Sendable {
    let id: UUID
    let title: String
    let authors: String
    let url: String?
    let abstract: String?
    let reliabilityScore: Double
    let publishDate: String?
}

protocol AIServiceProtocol: Sendable {
    var providerName: String { get }
    var isConfigured: Bool { get }

    func complete(prompt: String, systemPrompt: String?, maxTokens: Int?) async throws -> String

    func stream(prompt: String, systemPrompt: String?, maxTokens: Int?) -> AsyncThrowingStream<String, Error>

    func rewrite(text: String, tone: AITone, goal: String?, count: Int) async throws -> [String]

    func generate(prompt: String, tone: AITone, audience: String?, lengthWords: Int?, citationContext: String?) async throws -> String

    func adjustLength(text: String, direction: LengthDirection, factor: Double) async throws -> String

    func research(query: String, context: String?) async throws -> ResearchResult

    func findSources(claim: String, count: Int) async throws -> [SourceSuggestion]

    func availableModels() async throws -> [AIModel]
}

extension AIServiceProtocol {
    func rewrite(text: String, tone: AITone, goal: String? = nil, count: Int = 3) async throws -> [String] {
        try await rewrite(text: text, tone: tone, goal: goal, count: count)
    }
}
