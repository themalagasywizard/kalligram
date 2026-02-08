import AppKit
import Foundation

enum ParagraphAlignment: String, Codable, CaseIterable, Sendable {
    case left
    case justified
    case center
    case right

    var displayName: String {
        switch self {
        case .left: "Left"
        case .justified: "Justified"
        case .center: "Center"
        case .right: "Right"
        }
    }

    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .left: .left
        case .justified: .justified
        case .center: .center
        case .right: .right
        }
    }
}
