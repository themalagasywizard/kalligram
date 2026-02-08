import Foundation

enum PaperSize: String, Codable, CaseIterable, Sendable {
    case letter
    case a4
    case a5
    case legal
    case custom

    var displayName: String {
        switch self {
        case .letter: "US Letter"
        case .a4: "A4"
        case .a5: "A5"
        case .legal: "Legal"
        case .custom: "Custom"
        }
    }

    /// Width in points (1 inch = 72 points)
    var widthPoints: CGFloat {
        switch self {
        case .letter: 612    // 8.5 x 72
        case .a4: 595.28     // 210mm
        case .a5: 419.53     // 148mm
        case .legal: 612     // 8.5 x 72
        case .custom: 612    // Default to letter
        }
    }

    /// Height in points
    var heightPoints: CGFloat {
        switch self {
        case .letter: 792    // 11 x 72
        case .a4: 841.89     // 297mm
        case .a5: 595.28     // 210mm
        case .legal: 1008    // 14 x 72
        case .custom: 792    // Default to letter
        }
    }
}
