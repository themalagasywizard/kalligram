import AppKit

extension NSTextView {
    var selectedAttributedText: NSAttributedString? {
        guard selectedRange().length > 0 else { return nil }
        return attributedString().attributedSubstring(from: selectedRange())
    }

    func applyFontTrait(_ trait: NSFontDescriptor.SymbolicTraits) {
        guard let textStorage = textStorage else { return }
        let range = selectedRange()
        guard range.length > 0 else { return }

        textStorage.beginEditing()
        textStorage.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            guard let font = value as? NSFont else { return }
            let descriptor = font.fontDescriptor
            let newDescriptor: NSFontDescriptor
            if descriptor.symbolicTraits.contains(trait) {
                newDescriptor = descriptor.withSymbolicTraits(descriptor.symbolicTraits.subtracting(trait))
            } else {
                newDescriptor = descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(trait))
            }
            let newFont = NSFont(descriptor: newDescriptor, size: font.pointSize) ?? font
            textStorage.addAttribute(.font, value: newFont, range: attrRange)
        }
        textStorage.endEditing()
    }

    func toggleBold() {
        applyFontTrait(.bold)
    }

    func toggleItalic() {
        applyFontTrait(.italic)
    }

    func toggleUnderline() {
        guard let textStorage = textStorage else { return }
        let range = selectedRange()
        guard range.length > 0 else { return }

        textStorage.beginEditing()
        var hasUnderline = false
        textStorage.enumerateAttribute(.underlineStyle, in: range) { value, _, _ in
            if let style = value as? Int, style != 0 { hasUnderline = true }
        }
        let newValue = hasUnderline ? 0 : NSUnderlineStyle.single.rawValue
        textStorage.addAttribute(.underlineStyle, value: newValue, range: range)
        textStorage.endEditing()
    }

    func toggleStrikethrough() {
        guard let textStorage = textStorage else { return }
        let range = selectedRange()
        guard range.length > 0 else { return }

        textStorage.beginEditing()
        var hasStrikethrough = false
        textStorage.enumerateAttribute(.strikethroughStyle, in: range) { value, _, _ in
            if let style = value as? Int, style != 0 { hasStrikethrough = true }
        }
        let newValue = hasStrikethrough ? 0 : NSUnderlineStyle.single.rawValue
        textStorage.addAttribute(.strikethroughStyle, value: newValue, range: range)
        textStorage.endEditing()
    }

    func applyHeadingStyle(level: Int) {
        guard let textStorage = textStorage else { return }
        let range = selectedRange()

        let paragraphRange = (textStorage.string as NSString).paragraphRange(for: range)

        let font: NSFont
        let paragraphStyle = NSMutableParagraphStyle()

        switch level {
        case 1:
            font = Typography.heading1NS
            paragraphStyle.lineSpacing = Typography.heading1Leading - font.pointSize
            paragraphStyle.paragraphSpacingBefore = 24
            paragraphStyle.paragraphSpacing = 12
        case 2:
            font = Typography.heading2NS
            paragraphStyle.lineSpacing = Typography.heading2Leading - font.pointSize
            paragraphStyle.paragraphSpacingBefore = 20
            paragraphStyle.paragraphSpacing = 8
        case 3:
            font = Typography.heading3NS
            paragraphStyle.lineSpacing = Typography.heading3Leading - font.pointSize
            paragraphStyle.paragraphSpacingBefore = 16
            paragraphStyle.paragraphSpacing = 6
        default:
            font = Typography.editorBodyNS
            paragraphStyle.lineSpacing = Typography.editorBodyLeading - font.pointSize
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 4
        }

        textStorage.beginEditing()
        textStorage.addAttribute(.font, value: font, range: paragraphRange)
        textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: paragraphRange)
        textStorage.endEditing()
    }

    func applyFontSize(_ size: CGFloat) {
        guard let textStorage = textStorage else { return }
        let range = selectedRange()

        if range.length == 0 {
            let currentFont = (typingAttributes[.font] as? NSFont) ?? Typography.editorBodyNS
            let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: size) ?? currentFont
            typingAttributes[.font] = newFont
            return
        }

        textStorage.beginEditing()
        textStorage.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            let currentFont = (value as? NSFont) ?? Typography.editorBodyNS
            let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: size) ?? currentFont
            textStorage.addAttribute(.font, value: newFont, range: attrRange)
        }
        textStorage.endEditing()
    }

    var currentFontSize: CGFloat {
        if selectedRange().length > 0, let textStorage = textStorage {
            var size = Typography.editorBodyNS.pointSize
            textStorage.enumerateAttribute(.font, in: selectedRange()) { value, _, stop in
                if let font = value as? NSFont {
                    size = font.pointSize
                    stop.pointee = true
                }
            }
            return size
        }

        if let font = typingAttributes[.font] as? NSFont {
            return font.pointSize
        }
        return Typography.editorBodyNS.pointSize
    }

    var currentSelectionHasBold: Bool {
        guard let textStorage = textStorage else { return false }
        let range = selectedRange()
        guard range.length > 0 else { return false }
        var hasBold = false
        textStorage.enumerateAttribute(.font, in: range) { value, _, _ in
            if let font = value as? NSFont, font.fontDescriptor.symbolicTraits.contains(.bold) {
                hasBold = true
            }
        }
        return hasBold
    }

    var currentSelectionHasItalic: Bool {
        guard let textStorage = textStorage else { return false }
        let range = selectedRange()
        guard range.length > 0 else { return false }
        var hasItalic = false
        textStorage.enumerateAttribute(.font, in: range) { value, _, _ in
            if let font = value as? NSFont, font.fontDescriptor.symbolicTraits.contains(.italic) {
                hasItalic = true
            }
        }
        return hasItalic
    }
}
