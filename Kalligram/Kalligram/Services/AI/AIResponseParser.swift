import Foundation

enum AIResponseParser {
    static func parseRewriteOptions(_ response: String) -> [String] {
        let options = response.components(separatedBy: "---OPTION---")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return options.isEmpty ? [response] : options
    }

    static func parseResearchResult(_ response: String) -> ResearchResult {
        let sections = response.components(separatedBy: "---SECTION---")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let summary = sections.first ?? response
        var sources: [SourceSuggestion] = []
        var relatedQueries: [String] = []

        if sections.count > 1 {
            let sourceLines = sections[1].components(separatedBy: "---SOURCE---")
            for line in sourceLines {
                let parts = line.components(separatedBy: " | ")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                guard parts.count >= 2 else { continue }
                sources.append(SourceSuggestion(
                    id: UUID(),
                    title: parts[0],
                    authors: parts.count > 1 ? parts[1] : "",
                    url: parts.count > 2 ? parts[2] : nil,
                    abstract: nil,
                    reliabilityScore: parts.count > 4 ? (Double(parts[4]) ?? 0.7) : 0.7,
                    publishDate: parts.count > 3 ? parts[3] : nil
                ))
            }
        }

        if sections.count > 2 {
            relatedQueries = sections[2].components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return ResearchResult(
            summary: summary,
            sources: sources,
            relatedQueries: relatedQueries
        )
    }

    // MARK: - SSE Streaming Parsing

    struct SSEChunk {
        let content: String?
        let isDone: Bool
    }

    static func parseOpenAISSELine(_ line: String) -> SSEChunk? {
        guard line.hasPrefix("data: ") else { return nil }
        let data = String(line.dropFirst(6))
        if data == "[DONE]" { return SSEChunk(content: nil, isDone: true) }

        guard let jsonData = data.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let delta = choices.first?["delta"] as? [String: Any],
              let content = delta["content"] as? String else {
            return nil
        }
        return SSEChunk(content: content, isDone: false)
    }

    static func parseClaudeSSELine(_ line: String) -> SSEChunk? {
        guard line.hasPrefix("data: ") else { return nil }
        let data = String(line.dropFirst(6))

        guard let jsonData = data.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }

        let eventType = json["type"] as? String
        if eventType == "message_stop" { return SSEChunk(content: nil, isDone: true) }
        if eventType == "content_block_delta",
           let delta = json["delta"] as? [String: Any],
           let text = delta["text"] as? String {
            return SSEChunk(content: text, isDone: false)
        }
        return nil
    }
}
