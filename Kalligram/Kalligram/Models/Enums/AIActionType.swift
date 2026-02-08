import Foundation

enum AIActionType: String, Codable, CaseIterable, Sendable {
    case rewrite
    case generate
    case expand
    case condense
    case research
    case findSources

    var displayName: String {
        switch self {
        case .rewrite: "Rewrite"
        case .generate: "Generate"
        case .expand: "Expand"
        case .condense: "Condense"
        case .research: "Research"
        case .findSources: "Find Sources"
        }
    }

    var iconName: String {
        switch self {
        case .rewrite: SFSymbolTokens.rewrite
        case .generate: SFSymbolTokens.generate
        case .expand: SFSymbolTokens.expand
        case .condense: SFSymbolTokens.condense
        case .research: SFSymbolTokens.research
        case .findSources: SFSymbolTokens.search
        }
    }
}
