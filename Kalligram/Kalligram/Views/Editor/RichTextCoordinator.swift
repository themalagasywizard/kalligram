import AppKit
import SwiftUI

@MainActor
class RichTextCoordinator: NSObject, NSTextViewDelegate {
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel
    var currentDocumentID: UUID?
    private let saveDebouncer = DebouncedTask(duration: 2.0)

    init(editorVM: EditorViewModel, formattingVM: FormattingViewModel, documentID: UUID? = nil) {
        self.editorVM = editorVM
        self.formattingVM = formattingVM
        self.currentDocumentID = documentID
        super.init()
    }

    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView,
              let textStorage = textView.textStorage else { return }

        // If a programmatic rewrite edit triggered this, skip clearing state / debounced save
        if editorVM.isProgrammaticRewriteEdit {
            editorVM.updateCounts(from: textStorage)
            return
        }

        // User typed manually — invalidate any pending rewrite
        if editorVM.inlineRewrite != nil {
            editorVM.inlineRewrite = nil
        }

        editorVM.updateCounts(from: textStorage)
        editorVM.markDirty()

        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.saveDebouncer.submit { @MainActor [weak self] in
                guard let self, let tv = self.editorVM.textView else { return }
                self.editorVM.saveContent(from: tv)
            }
        }
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

        let range = textView.selectedRange()
        let hasSelection = range.length > 0

        if hasSelection {
            let glyphRange = textView.layoutManager?.glyphRange(
                forCharacterRange: range, actualCharacterRange: nil
            ) ?? NSRange(location: 0, length: 0)
            var rect = textView.layoutManager?.boundingRect(
                forGlyphRange: glyphRange, in: textView.textContainer!
            ) ?? .zero
            rect.origin.x += textView.textContainerInset.width
            rect.origin.y += textView.textContainerInset.height

            // Convert to the window's content view (flipped, matching SwiftUI .global coords)
            let targetView = textView.window?.contentView
            let convertedRect = textView.convert(rect, to: targetView)
            editorVM.updateSelection(hasSelection: true, rect: convertedRect)
        } else {
            editorVM.updateSelection(hasSelection: false, rect: .zero)
        }

        formattingVM.updateFromSelection(in: textView)
    }

    func undoManager(for view: NSTextView) -> UndoManager? {
        view.window?.undoManager
    }
}
