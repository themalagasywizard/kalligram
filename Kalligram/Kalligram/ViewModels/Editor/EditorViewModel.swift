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

    // MARK: - Inline Rewrite

    struct InlineRewriteState {
        let originalText: String
        let rewrittenText: String
        var range: NSRange
        var isShowingRewritten: Bool
    }

    var inlineRewrite: InlineRewriteState?
    var isRewriting: Bool = false
    var isProgrammaticRewriteEdit: Bool = false

    private static let rewriteHighlightColor = NSColor.systemGreen.withAlphaComponent(0.18)

    func loadDocument(_ doc: Document) {
        document = doc
        isDirty = false
        inlineRewrite = nil
        isRewriting = false
    }

    func updateCounts(from textStorage: NSTextStorage) {
        let text = textStorage.string
        wordCount = text.split(whereSeparator: \.isWhitespace).count
        characterCount = text.count
        // Do NOT update document.contentPlainText or document.updatedAt here.
        // Those SwiftData model mutations trigger SwiftUI re-renders on every
        // keystroke, which can cause formatting destruction. Both fields are
        // already persisted by saveContent().
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

        // Clear rewrite highlighting before saving so green bg isn't persisted
        if let state = inlineRewrite {
            isProgrammaticRewriteEdit = true
            textStorage.beginEditing()
            textStorage.removeAttribute(.backgroundColor, range: state.range)
            textStorage.endEditing()
            isProgrammaticRewriteEdit = false
            inlineRewrite = nil
        }

        let attrString = NSAttributedString(attributedString: textStorage)
        document.contentRTFData = attrString.toRTFData()
        document.contentPlainText = textStorage.string
        document.updatedAt = Date()
        document.lastCursorPosition = textView.selectedRange().location
        isDirty = false
    }

    func reloadContent() {
        guard let document, let textView else { return }

        if let rtfData = document.contentRTFData,
           let attrString = NSAttributedString.fromRTFData(rtfData) {
            textView.textStorage?.setAttributedString(attrString)
        } else {
            textView.string = document.contentPlainText
        }

        let cursorPos = min(document.lastCursorPosition, textView.string.count)
        textView.setSelectedRange(NSRange(location: cursorPos, length: 0))

        if let textStorage = textView.textStorage {
            updateCounts(from: textStorage)
        }
        isDirty = false
    }

    // MARK: - Formatting Commands

    func toggleBold() {
        textView?.toggleBold()
        notifyFormattingChange()
    }

    func toggleItalic() {
        textView?.toggleItalic()
        notifyFormattingChange()
    }

    func toggleUnderline() {
        textView?.toggleUnderline()
        notifyFormattingChange()
    }

    func toggleStrikethrough() {
        textView?.toggleStrikethrough()
        notifyFormattingChange()
    }

    func applyHeading(level: Int) {
        textView?.applyHeadingStyle(level: level)
        notifyFormattingChange()
    }

    func setFontSize(_ size: CGFloat) {
        textView?.applyFontSize(size)
        notifyFormattingChange()
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
        notifyFormattingChange()
    }

    func alignCenter() {
        textView?.alignCenter(nil)
        notifyFormattingChange()
    }

    func alignRight() {
        textView?.alignRight(nil)
        notifyFormattingChange()
    }

    func alignJustified() {
        textView?.alignJustified(nil)
        notifyFormattingChange()
    }

    private func notifyFormattingChange() {
        guard let textView else { return }
        markDirty()
        // Save immediately so formatting changes are persisted to RTF data
        // right away, rather than waiting for the 2-second debounce.
        saveContent(from: textView)
    }

    // MARK: - Inline Rewrite Actions

    func requestInlineRewrite(using settings: UserSettings) {
        guard let textView, let textStorage = textView.textStorage else { return }
        let selRange = textView.selectedRange()
        guard selRange.length > 0 else { return }

        let selected = (textStorage.string as NSString).substring(with: selRange)
        guard !selected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let service = AIServiceFactory.createFromSettings(settings) else { return }

        // Clear any existing rewrite first
        clearRewriteHighlight()

        isRewriting = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.isRewriting = false }

            do {
                let results = try await service.rewrite(text: selected, tone: .neutral, count: 1)
                guard let rewritten = results.first?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !rewritten.isEmpty else { return }
                self.applyRewrite(original: selected, rewritten: rewritten, at: selRange)
            } catch {
                // Silent fail — user sees the loading spinner stop
            }
        }
    }

    private func applyRewrite(original: String, rewritten: String, at range: NSRange) {
        guard let textView, let textStorage = textView.textStorage else { return }

        // Preserve existing text attributes (font, paragraph style, etc.)
        let attrs: [NSAttributedString.Key: Any]
        if range.location < textStorage.length {
            attrs = textStorage.attributes(at: range.location, effectiveRange: nil)
        } else {
            attrs = textView.typingAttributes
        }

        // Build attributed string with green highlight
        var newAttrs = attrs
        newAttrs[.backgroundColor] = Self.rewriteHighlightColor
        let attrString = NSAttributedString(string: rewritten, attributes: newAttrs)

        isProgrammaticRewriteEdit = true
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: range, with: attrString)
        textStorage.endEditing()
        isProgrammaticRewriteEdit = false

        let newRange = NSRange(location: range.location, length: (rewritten as NSString).length)
        textView.setSelectedRange(newRange)

        inlineRewrite = InlineRewriteState(
            originalText: original,
            rewrittenText: rewritten,
            range: newRange,
            isShowingRewritten: true
        )
        markDirty()
    }

    func toggleRewriteVersion() {
        guard var state = inlineRewrite,
              let textView,
              let textStorage = textView.textStorage else { return }

        let targetText: String
        let applyGreen: Bool

        if state.isShowingRewritten {
            targetText = state.originalText
            applyGreen = false
        } else {
            targetText = state.rewrittenText
            applyGreen = true
        }

        // Preserve text attributes minus any background color
        let attrs: [NSAttributedString.Key: Any]
        if state.range.location < textStorage.length {
            var a = textStorage.attributes(at: state.range.location, effectiveRange: nil)
            a.removeValue(forKey: .backgroundColor)
            attrs = a
        } else {
            attrs = textView.typingAttributes
        }

        var newAttrs = attrs
        if applyGreen {
            newAttrs[.backgroundColor] = Self.rewriteHighlightColor
        }
        let attrString = NSAttributedString(string: targetText, attributes: newAttrs)

        isProgrammaticRewriteEdit = true
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: state.range, with: attrString)
        textStorage.endEditing()
        isProgrammaticRewriteEdit = false

        let newRange = NSRange(location: state.range.location, length: (targetText as NSString).length)
        state.range = newRange
        state.isShowingRewritten = !state.isShowingRewritten
        inlineRewrite = state

        textView.setSelectedRange(newRange)
    }

    func acceptRewrite() {
        guard let state = inlineRewrite,
              let textView,
              let textStorage = textView.textStorage else { return }

        // If showing original, switch to rewritten first
        if !state.isShowingRewritten {
            toggleRewriteVersion()
        }

        // Remove green highlighting, keep the text
        guard let current = inlineRewrite else { return }
        isProgrammaticRewriteEdit = true
        textStorage.beginEditing()
        textStorage.removeAttribute(.backgroundColor, range: current.range)
        textStorage.endEditing()
        isProgrammaticRewriteEdit = false

        inlineRewrite = nil
        markDirty()
    }

    func dismissRewrite() {
        guard let state = inlineRewrite else { return }

        // If showing rewritten, swap back to original
        if state.isShowingRewritten {
            toggleRewriteVersion()
        }

        inlineRewrite = nil
    }

    /// Clears any active rewrite highlight without restoring original text.
    private func clearRewriteHighlight() {
        guard let state = inlineRewrite,
              let textView,
              let textStorage = textView.textStorage else { return }

        isProgrammaticRewriteEdit = true
        textStorage.beginEditing()
        textStorage.removeAttribute(.backgroundColor, range: state.range)
        textStorage.endEditing()
        isProgrammaticRewriteEdit = false

        inlineRewrite = nil
    }
}
