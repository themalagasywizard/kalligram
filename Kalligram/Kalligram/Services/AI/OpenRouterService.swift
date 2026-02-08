import Foundation

final class OpenRouterService: AIServiceProtocol, @unchecked Sendable {
    let providerName = "openrouter"
    private let apiKey: String
    private let model: String
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"

    var isConfigured: Bool { !apiKey.isEmpty }

    init(apiKey: String, model: String = "anthropic/claude-sonnet-4") {
        self.apiKey = apiKey
        self.model = model
    }

    func complete(prompt: String, systemPrompt: String?, maxTokens: Int?) async throws -> String {
        var messages: [[String: String]] = []
        if let systemPrompt {
            messages.append(["role": "system", "content": systemPrompt])
        }
        messages.append(["role": "user", "content": prompt])

        var body: [String: Any] = [
            "model": model,
            "messages": messages
        ]
        if let maxTokens { body["max_tokens"] = maxTokens }

        let data = try await makeRequest(body: body)
        return try parseCompletion(data)
    }

    func stream(prompt: String, systemPrompt: String?, maxTokens: Int?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var messages: [[String: String]] = []
                    if let systemPrompt {
                        messages.append(["role": "system", "content": systemPrompt])
                    }
                    messages.append(["role": "user", "content": prompt])

                    var body: [String: Any] = [
                        "model": model,
                        "messages": messages,
                        "stream": true
                    ]
                    if let maxTokens { body["max_tokens"] = maxTokens }

                    let request = try buildRequest(body: body)
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        continuation.finish(throwing: AIError.serverError(
                            (response as? HTTPURLResponse)?.statusCode ?? 0,
                            "Stream request failed"
                        ))
                        return
                    }

                    for try await line in bytes.lines {
                        if let chunk = AIResponseParser.parseOpenAISSELine(line) {
                            if chunk.isDone {
                                continuation.finish()
                                return
                            }
                            if let content = chunk.content {
                                continuation.yield(content)
                            }
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
        let (system, user) = AIPromptBuilder.generatePrompt(
            prompt: prompt, tone: tone, audience: audience,
            lengthWords: lengthWords, citationContext: citationContext
        )
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
        let result = try await research(query: "Find \(count) credible sources for: \(claim)", context: nil)
        return result.sources
    }

    func availableModels() async throws -> [AIModel] {
        [
            AIModel(id: "anthropic/claude-sonnet-4", displayName: "Claude Sonnet 4", contextWindow: 200000, costPerMillionTokens: 3.0),
            AIModel(id: "anthropic/claude-haiku-3.5", displayName: "Claude Haiku 3.5", contextWindow: 200000, costPerMillionTokens: 0.25),
            AIModel(id: "openai/gpt-4o", displayName: "GPT-4o", contextWindow: 128000, costPerMillionTokens: 2.5),
            AIModel(id: "openai/gpt-4o-mini", displayName: "GPT-4o Mini", contextWindow: 128000, costPerMillionTokens: 0.15),
            AIModel(id: "google/gemini-2.0-flash", displayName: "Gemini 2.0 Flash", contextWindow: 1000000, costPerMillionTokens: 0.1),
        ]
    }

    // MARK: - Private

    private func buildRequest(body: [String: Any]) throws -> URLRequest {
        guard let url = URL(string: baseURL) else { throw AIError.notConfigured }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Kalligram/1.0", forHTTPHeaderField: "HTTP-Referer")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func makeRequest(body: [String: Any]) async throws -> Data {
        let request = try buildRequest(body: body)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.noResponse
        }

        switch httpResponse.statusCode {
        case 200...299: return data
        case 401: throw AIError.invalidAPIKey
        case 429: throw AIError.rateLimited
        default:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.serverError(httpResponse.statusCode, message)
        }
    }

    private func parseCompletion(_ data: Data) throws -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.decodingError(NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"]))
        }
        return content
    }
}
