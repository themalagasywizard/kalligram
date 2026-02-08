import SwiftUI
import SwiftData
import AppKit

@Observable
final class EditorViewModel {
    var document: Document?
    var wordCount: Int = 0
    var characterCount: Int = 0
    var hasSelection: Bool = false
    var selectionRect: CGRect = .zero
    var isDirty: Bool = false
    var selectedText: String = ""
    var currentHeadingLevel: Int = 0

    // Reference to the NSTextView for direct operations
    weak var textView: NSTextView?

    func loadDocument(_ doc: Document) {
        document = doc
        isDirty = false
    }

    func updateCounts(from textStorage: NSTextStorage) {
        let text = textStorage.string
        wordCount = text.split(whereSeparator: \.isWhitespace).count
        characterCount = text.count
        document?.contentPlainText = text
        document?.updatedAt = Date()
    }

    func updateSelection(hasSelection: Bool, rect: CGRect) {
        self.hasSelection = hasSelection
        self.selectionRect = rect

        if hasSelection, let textView,
           let textStorage = textView.textStorage {
            let range = textView.selectedRange()
            if range.length > 0 && range.location + range.length <= textStorage.length {
                selectedText = (textStorage.string as NSString).substring(with: range)
            } else {
                selectedText = ""
            }
        } else {
            selectedText = ""
        }
    }

    func replaceSelection(with text: String) {
        guard let textView else { return }
        let range = textView.selectedRange()
        textView.insertText(text, replacementRange: range)
        markDirty()
    }

    func markDirty() {
        isDirty = true
    }

    func saveContent(from textView: NSTextView) {
        guard let document else { return }
        guard let textStorage = textView.textStorage else { return }

        let attrString = NSAttributedString(attributedString: textStorage)
        document.contentRTFData = attrString.toRTFData()
        document.contentPlainText = textStorage.string
        document.updatedAt = Date()
        document.lastCursorPosition = textView.selectedRange().location
        isDirty = false
    }

    // MARK: - Formatting Commands

    func toggleBold() {
        textView?.toggleBold()
        markDirty()
    }

    func toggleItalic() {
        textView?.toggleItalic()
        markDirty()
    }

    func toggleUnderline() {
        textView?.toggleUnderline()
        markDirty()
    }

    func toggleStrikethrough() {
        textView?.toggleStrikethrough()
        markDirty()
    }

    func applyHeading(level: Int) {
        textView?.applyHeadingStyle(level: level)
        markDirty()
    }

    func setFontSize(_ size: CGFloat) {
        textView?.applyFontSize(size)
        markDirty()
    }

    func increaseFontSize() {
        guard let textView else { return }
        let newSize = min(72, textView.currentFontSize + 1)
        setFontSize(newSize)
    }

    func decreaseFontSize() {
        guard let textView else { return }
        let newSize = max(8, textView.currentFontSize - 1)
        setFontSize(newSize)
    }

    func alignLeft() {
        textView?.alignLeft(nil)
        markDirty()
    }

    func alignCenter() {
        textView?.alignCenter(nil)
        markDirty()
    }

    func alignRight() {
        textView?.alignRight(nil)
        markDirty()
    }

    func alignJustified() {
        textView?.alignJustified(nil)
        markDirty()
    }
}
