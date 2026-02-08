import SwiftUI
import AppKit

@Observable
final class FormattingViewModel {
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    var currentHeadingLevel: Int = 0
    var currentFontSize: CGFloat = Typography.editorBodyNS.pointSize

    func updateFromSelection(in textView: NSTextView) {
        let range = textView.selectedRange()
        guard range.length > 0, let textStorage = textView.textStorage else {
            resetAll()
            if let font = textView.typingAttributes[.font] as? NSFont {
                currentFontSize = font.pointSize
            } else {
                currentFontSize = Typography.editorBodyNS.pointSize
            }
            return
        }

        isBold = false
        isItalic = false
        isUnderline = false
        isStrikethrough = false
        currentHeadingLevel = 0

        var capturedFontSize = Typography.editorBodyNS.pointSize
        textStorage.enumerateAttributes(in: range) { attrs, _, _ in
            if let font = attrs[.font] as? NSFont {
                let traits = font.fontDescriptor.symbolicTraits
                if traits.contains(.bold) { isBold = true }
                if traits.contains(.italic) { isItalic = true }
                capturedFontSize = font.pointSize

                // Detect heading level by font size
                if font.pointSize >= 28 { currentHeadingLevel = 1 }
                else if font.pointSize >= 22 { currentHeadingLevel = 2 }
                else if font.pointSize >= 18 { currentHeadingLevel = 3 }
            }
            if let underline = attrs[.underlineStyle] as? Int, underline != 0 {
                isUnderline = true
            }
            if let strike = attrs[.strikethroughStyle] as? Int, strike != 0 {
                isStrikethrough = true
            }
        }
        currentFontSize = capturedFontSize
    }

    private func resetAll() {
        isBold = false
        isItalic = false
        isUnderline = false
        isStrikethrough = false
        currentHeadingLevel = 0
    }
}
