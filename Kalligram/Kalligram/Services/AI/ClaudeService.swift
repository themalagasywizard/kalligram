import Foundation

final class ClaudeService: AIServiceProtocol, @unchecked Sendable {
    let providerName = "claude"
    private let apiKey: String
    private let model: String
    private let baseURL = "https://api.anthropic.com/v1/messages"

    var isConfigured: Bool { !apiKey.isEmpty }

    init(apiKey: String, model: String = "claude-sonnet-4-5-20250929") {
        self.apiKey = apiKey
        self.model = model
    }

    func complete(prompt: String, systemPrompt: String?, maxTokens: Int?) async throws -> String {
        var body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": maxTokens ?? 4096
        ]
        if let systemPrompt { body["system"] = systemPrompt }

        let request = try buildRequest(body: body)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else { throw AIError.noResponse }
        switch httpResponse.statusCode {
        case 200...299: break
        case 401: throw AIError.invalidAPIKey
        case 429: throw AIError.rateLimited
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw AIError.serverError(httpResponse.statusCode, msg)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw AIError.noResponse
        }
        return text
    }

    func stream(prompt: String, systemPrompt: String?, maxTokens: Int?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var body: [String: Any] = [
                        "model": model,
                        "messages": [["role": "user", "content": prompt]],
                        "max_tokens": maxTokens ?? 4096,
                        "stream": true
                    ]
                    if let systemPrompt { body["system"] = systemPrompt }

                    let request = try buildRequest(body: body)
                    let (bytes, _) = try await URLSession.shared.bytes(for: request)

                    for try await line in bytes.lines {
                        if let chunk = AIResponseParser.parseClaudeSSELine(line) {
                            if chunk.isDone { continuation.finish(); return }
                            if let content = chunk.content { continuation.yield(content) }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func rewrite(text: String, tone: AITone, goal: String?, count: Int) async throws -> [String] {
        let (system, user) = AIPromptBuilder.rewritePrompt(text: text, tone: tone, goal: goal, count: count)
        let response = try await complete(prompt: user, systemPrompt: system, maxTokens: 4000)
        return AIResponseParser.parseRewriteOptions(response)
    }

    func generate(prompt: String, tone: AITone, audience: String?, lengthWords: Int?, citationContext: String?) async throws -> String {
        let (system, user) = AIPromptBuilder.generatePrompt(prompt: prompt, tone: tone, audience: audience, lengthWords: lengthWords, citationContext: citationContext)
        return try await complete(prompt: user, systemPrompt: system, maxTokens: 4000)
    }

    func adjustLength(text: String, direction: LengthDirection, factor: Double) async throws -> String {
        let (system, user) = AIPromptBuilder.expandCondensePrompt(text: text, direction: direction, factor: factor)
        return try await complete(prompt: user, systemPrompt: system, maxTokens: 4000)
    }

    func research(query: String, context: String?) async throws -> ResearchResult {
        let (system, user) = AIPromptBuilder.researchPrompt(query: query, context: context)
        let response = try await complete(prompt: user, systemPrompt: system, maxTokens: 4000)
        return AIResponseParser.parseResearchResult(response)
    }

    func findSources(claim: String, count: Int) async throws -> [SourceSuggestion] {
        let result = try await research(query: "Find \(count) sources for: \(claim)", context: nil)
        return result.sources
    }

    func availableModels() async throws -> [AIModel] {
        [
            AIModel(id: "claude-sonnet-4-5-20250929", displayName: "Claude Sonnet 4.5", contextWindow: 200000, costPerMillionTokens: 3.0),
            AIModel(id: "claude-haiku-4-5-20251001", displayName: "Claude Haiku 4.5", contextWindow: 200000, costPerMillionTokens: 0.25),
            AIModel(id: "claude-opus-4-6", displayName: "Claude Opus 4.6", contextWindow: 200000, costPerMillionTokens: 15.0),
        ]
    }

    private func buildRequest(body: [String: Any]) throws -> URLRequest {
        guard let url = URL(string: baseURL) else { throw AIError.notConfigured }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }
}
