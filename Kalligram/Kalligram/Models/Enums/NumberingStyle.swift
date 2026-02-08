import Foundation

enum NumberingStyle: String, Codable, CaseIterable, Sendable {
    case arabic
    case romanLower
    case romanUpper
    case none

    var displayName: String {
        switch self {
        case .arabic: "1, 2, 3..."
        case .romanLower: "i, ii, iii..."
        case .romanUpper: "I, II, III..."
        case .none: "None"
        }
    }
}
