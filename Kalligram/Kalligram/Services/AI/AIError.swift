import Foundation

enum AIError: LocalizedError {
    case notConfigured
    case invalidAPIKey
    case networkError(Error)
    case rateLimited
    case serverError(Int, String)
    case decodingError(Error)
    case noResponse
    case cancelled

    var errorDescription: String? {
        switch self {
        case .notConfigured: "AI provider is not configured. Please add an API key in Settings."
        case .invalidAPIKey: "Invalid API key. Please check your API key in Settings."
        case .networkError(let error): "Network error: \(error.localizedDescription)"
        case .rateLimited: "Rate limited. Please try again in a moment."
        case .serverError(let code, let message): "Server error (\(code)): \(message)"
        case .decodingError(let error): "Failed to parse response: \(error.localizedDescription)"
        case .noResponse: "No response received from the AI provider."
        case .cancelled: "Request was cancelled."
        }
    }
}
