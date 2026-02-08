import Foundation

enum AIServiceFactory {
    static func create(provider: String, model: String? = nil) -> (any AIServiceProtocol)? {
        let keychain = KeychainService.shared

        switch provider {
        case "openrouter":
            guard let key = keychain.getAPIKey(for: "openrouter") else { return nil }
            return OpenRouterService(apiKey: key, model: model ?? "anthropic/claude-sonnet-4")
        case "claude":
            guard let key = keychain.getAPIKey(for: "claude") else { return nil }
            return ClaudeService(apiKey: key, model: model ?? "claude-sonnet-4-5-20250929")
        case "openai":
            guard let key = keychain.getAPIKey(for: "openai") else { return nil }
            return OpenAIService(apiKey: key, model: model ?? "gpt-4o")
        default:
            return nil
        }
    }

    static func createFromSettings(_ settings: UserSettings) -> (any AIServiceProtocol)? {
        create(provider: settings.preferredAIProvider, model: settings.preferredModel)
    }
}
