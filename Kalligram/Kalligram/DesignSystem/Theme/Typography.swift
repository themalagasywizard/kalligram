import SwiftUI

enum Typography {
    // MARK: - Editor Fonts (Serif body, Sans-serif headings)

    static let editorBody = Font.custom("Georgia", size: 16)
    static let editorBodyNS = NSFont(name: "Georgia", size: 16) ?? .systemFont(ofSize: 16)

    static let heading1 = Font.system(size: 28, weight: .bold, design: .default)
    static let heading1NS = NSFont.systemFont(ofSize: 28, weight: .bold)

    static let heading2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let heading2NS = NSFont.systemFont(ofSize: 22, weight: .semibold)

    static let heading3 = Font.system(size: 18, weight: .medium, design: .default)
    static let heading3NS = NSFont.systemFont(ofSize: 18, weight: .medium)

    // MARK: - UI Fonts

    static let display = Font.system(size: 32, weight: .bold, design: .default)
    static let headline = Font.system(size: 16, weight: .medium, design: .default)
    static let body = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Line Heights

    static let editorBodyLeading: CGFloat = 26
    static let heading1Leading: CGFloat = 36
    static let heading2Leading: CGFloat = 28
    static let heading3Leading: CGFloat = 24

    // MARK: - Reader Mode

    static let readerBody = Font.custom("Georgia", size: 18)
    static let readerBodyNS = NSFont(name: "Georgia", size: 18) ?? .systemFont(ofSize: 18)
}
