import SwiftUI

enum KeyboardShortcuts {
    // Document
    static let newDocument = KeyboardShortcut("n", modifiers: .command)
    static let save = KeyboardShortcut("s", modifiers: .command)
    static let exportDocument = KeyboardShortcut("e", modifiers: [.command, .shift])

    // Navigation
    static let toggleSidebar = KeyboardShortcut("l", modifiers: [.command, .shift])
    static let toggleInspector = KeyboardShortcut("i", modifiers: [.command, .option])

    // Editor
    static let focusMode = KeyboardShortcut("f", modifiers: [.command, .shift])
    static let findInDocument = KeyboardShortcut("f", modifiers: .command)

    // AI
    static let aiRewrite = KeyboardShortcut("r", modifiers: [.command, .shift])
    static let aiGenerate = KeyboardShortcut("g", modifiers: [.command, .shift])

    // Comments
    static let addComment = KeyboardShortcut("m", modifiers: [.command, .option])
}
