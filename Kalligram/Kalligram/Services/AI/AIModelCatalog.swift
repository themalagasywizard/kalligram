import Foundation

enum AIModelCatalog {
    static let allModels: [String] = [
        "openai/gpt-5.2",
        "openai/gpt-5.1",
        "anthropic/claude-sonnet-4-5",
        "anthropic/claude-opus-4-5",
        "google/gemini-3-pro",
        "google/gemini-3-flash",
        "meta-llama/llama-4-maverick",
        "mistralai/mixtral-8x22b-instruct",
        "qwen/qwen-3-235b-instruct",
        "xai/grok-4.1",
        "perplexity/sonar-pro"
    ]

    static let defaultSearchModel = "perplexity/sonar-pro"
}
