import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    let document: Document
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        // Core configuration
        textView.isRichText = true
        textView.allowsUndo = true
        textView.usesFindPanel = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true

        // Smart text features
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = true
        textView.isGrammarCheckingEnabled = true
        textView.smartInsertDeleteEnabled = true

        // Appearance
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: Spacing.editor, height: Spacing.canvas)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: 0,
            height: CGFloat.greatestFiniteMagnitude
        )

        // Default font + paragraph style (document-specific)
        DocumentFormattingService.configureTextViewDefaults(textView, document: document)

        // Delegate
        textView.delegate = context.coordinator

        // Store reference
        editorVM.textView = textView

        // Load content
        loadContent(into: textView)

        // Scroll appearance
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.scrollerStyle = .overlay

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        // Only reload if the document ID changed
        if context.coordinator.currentDocumentID != document.id {
            context.coordinator.currentDocumentID = document.id
            loadContent(into: textView)
            editorVM.textView = textView
        }
    }

    func makeCoordinator() -> RichTextCoordinator {
        RichTextCoordinator(editorVM: editorVM, formattingVM: formattingVM, documentID: document.id)
    }

    private func loadContent(into textView: NSTextView) {
        if let rtfData = document.contentRTFData,
           let attrString = NSAttributedString.fromRTFData(rtfData) {
            textView.textStorage?.setAttributedString(attrString)
        } else if !document.contentPlainText.isEmpty {
            textView.string = document.contentPlainText
        } else {
            textView.string = ""
        }

        // Restore cursor
        let cursorPos = min(document.lastCursorPosition, textView.string.count)
        textView.setSelectedRange(NSRange(location: cursorPos, length: 0))

        // Update counts
        if let textStorage = textView.textStorage {
            editorVM.updateCounts(from: textStorage)
        }
    }
}
