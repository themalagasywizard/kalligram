import Foundation

enum PaperSize: String, Codable, CaseIterable, Sendable {
    case letter
    case a4
    case a5
    case legal
    case trim5x8
    case trim5_25x8
    case trim5_5x8_5
    case trim6x9
    case trim7x10
    case trim8x10
    case custom

    var displayName: String {
        switch self {
        case .letter: "US Letter"
        case .a4: "A4"
        case .a5: "A5"
        case .legal: "Legal"
        case .trim5x8: "5 x 8 in"
        case .trim5_25x8: "5.25 x 8 in"
        case .trim5_5x8_5: "5.5 x 8.5 in"
        case .trim6x9: "6 x 9 in"
        case .trim7x10: "7 x 10 in"
        case .trim8x10: "8 x 10 in"
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
        case .trim5x8: 360   // 5 x 72
        case .trim5_25x8: 378 // 5.25 x 72
        case .trim5_5x8_5: 396 // 5.5 x 72
        case .trim6x9: 432   // 6 x 72
        case .trim7x10: 504  // 7 x 72
        case .trim8x10: 576  // 8 x 72
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
        case .trim5x8: 576   // 8 x 72
        case .trim5_25x8: 576 // 8 x 72
        case .trim5_5x8_5: 612 // 8.5 x 72
        case .trim6x9: 648   // 9 x 72
        case .trim7x10: 720  // 10 x 72
        case .trim8x10: 720  // 10 x 72
        case .custom: 792    // Default to letter
        }
    }
}
