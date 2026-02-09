import AppKit
import Foundation

enum DocumentFormattingService {
    static func bodyFont(for document: Document) -> NSFont {
        let size = CGFloat(document.bodyFontSize)
        if let font = NSFont(name: document.bodyFontName, size: size) {
            return font
        }
        return NSFont.systemFont(ofSize: size)
    }

    static func paragraphStyle(for document: Document, baseFont: NSFont) -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        style.lineHeightMultiple = max(0.8, CGFloat(document.lineSpacing))
        style.paragraphSpacingBefore = document.paragraphSpacingBefore
        style.paragraphSpacing = document.paragraphSpacing
        style.firstLineHeadIndent = document.firstLineIndent
        style.alignment = document.bodyAlignmentEnum.nsTextAlignment
        style.hyphenationFactor = document.hyphenationEnabled ? 0.9 : 0.0
        style.lineBreakMode = .byWordWrapping
        return style
    }

    static func configureTextViewDefaults(_ textView: NSTextView, document: Document) {
        let font = bodyFont(for: document)
        let paragraphStyle = paragraphStyle(for: document, baseFont: font)

        // Only set defaultParagraphStyle and typingAttributes.
        // Do NOT set textView.font or textView.textColor — those setters
        // apply to ALL existing text in the textStorage, destroying any
        // heading or inline formatting.
        textView.defaultParagraphStyle = paragraphStyle
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: NSColor.textColor,
            .paragraphStyle: paragraphStyle
        ]
    }

    static func applyBodyStyle(to textStorage: NSMutableAttributedString, document: Document) {
        let bodyFont = bodyFont(for: document)
        let baseParagraphStyle = paragraphStyle(for: document, baseFont: bodyFont)
        let nsString = textStorage.string as NSString
        let fullLength = nsString.length

        textStorage.beginEditing()
        var index = 0
        while index < fullLength {
            let range = nsString.paragraphRange(for: NSRange(location: index, length: 0))
            let font = (textStorage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont) ?? bodyFont

            if !isHeadingFont(font, bodyFont: bodyFont) {
                let updatedFont = fontPreservingTraits(from: font, base: bodyFont)
                textStorage.addAttribute(.font, value: updatedFont, range: range)

                let existingStyle = textStorage.attribute(.paragraphStyle, at: range.location, effectiveRange: nil) as? NSParagraphStyle
                let mutableStyle = (existingStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? baseParagraphStyle.mutableCopy() as! NSMutableParagraphStyle
                mutableStyle.lineHeightMultiple = baseParagraphStyle.lineHeightMultiple
                mutableStyle.lineSpacing = 0
                mutableStyle.paragraphSpacingBefore = baseParagraphStyle.paragraphSpacingBefore
                mutableStyle.paragraphSpacing = baseParagraphStyle.paragraphSpacing
                mutableStyle.firstLineHeadIndent = baseParagraphStyle.firstLineHeadIndent
                // Preserve per-paragraph alignment if it was explicitly set
                // (i.e., differs from the NSParagraphStyle default of .natural).
                // Only apply the document default when the paragraph has no
                // explicit alignment override.
                if existingStyle == nil || existingStyle?.alignment == .natural {
                    mutableStyle.alignment = baseParagraphStyle.alignment
                }
                mutableStyle.hyphenationFactor = baseParagraphStyle.hyphenationFactor
                mutableStyle.lineBreakMode = baseParagraphStyle.lineBreakMode
                textStorage.addAttribute(.paragraphStyle, value: mutableStyle, range: range)
            }

            index = NSMaxRange(range)
        }
        textStorage.endEditing()
    }

    static func applyingBodyStyle(to attributedString: NSAttributedString, document: Document) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedString)
        applyBodyStyle(to: mutable, document: document)
        return NSAttributedString(attributedString: mutable)
    }

    private static func isHeadingFont(_ font: NSFont, bodyFont: NSFont) -> Bool {
        let sizeDelta = font.pointSize - bodyFont.pointSize
        if sizeDelta >= 4 { return true }
        if sizeDelta >= 2, font.fontDescriptor.symbolicTraits.contains(.bold) { return true }
        return false
    }

    private static func fontPreservingTraits(from font: NSFont, base: NSFont) -> NSFont {
        let traits = font.fontDescriptor.symbolicTraits
        let descriptor = base.fontDescriptor.withSymbolicTraits(traits)
        return NSFont(descriptor: descriptor, size: base.pointSize) ?? base
    }
}
