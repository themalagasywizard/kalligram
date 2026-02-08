import SwiftUI
import AppKit

@Observable
final class PaginationViewModel {
    var pageCount: Int = 1
    var currentPage: Int = 1
    var pages: [PageInfo] = []
    /// Set this to trigger an explicit scroll (e.g. from thumbnail clicks). Cleared after scroll.
    var scrollToPage: Int?

    struct PageInfo: Identifiable {
        let id: Int // page number (1-based)
        let characterRange: NSRange
        let content: NSAttributedString
    }

    func paginate(
        attributedString: NSAttributedString,
        paperSize: PaperSize,
        margins: NSEdgeInsets
    ) {
        let contentWidth = paperSize.widthPoints - margins.left - margins.right
        let contentHeight = paperSize.heightPoints - margins.top - margins.bottom

        guard contentWidth > 0, contentHeight > 0 else { return }

        if attributedString.length == 0 {
            let empty = NSAttributedString(string: "")
            pages = [PageInfo(id: 1, characterRange: NSRange(location: 0, length: 0), content: empty)]
            pageCount = 1
            currentPage = 1
            return
        }

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = true
        textStorage.addLayoutManager(layoutManager)

        var newPages: [PageInfo] = []
        var pageNumber = 1
        var lastGlyphLocation = 0
        var safetyCounter = 0

        while safetyCounter < 2000 {
            safetyCounter += 1
            let container = NSTextContainer(size: CGSize(width: contentWidth, height: contentHeight))
            container.lineFragmentPadding = 0
            layoutManager.addTextContainer(container)
            layoutManager.ensureLayout(for: container)

            let glyphRange = layoutManager.glyphRange(for: container)
            if glyphRange.length == 0 {
                break
            }

            let glyphEnd = NSMaxRange(glyphRange)
            if glyphEnd <= lastGlyphLocation {
                break
            }
            lastGlyphLocation = glyphEnd

            let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let slice = attributedString.attributedSubstring(from: charRange)
            newPages.append(PageInfo(id: pageNumber, characterRange: charRange, content: slice))

            pageNumber += 1
            if glyphEnd >= layoutManager.numberOfGlyphs {
                break
            }
        }

        if newPages.isEmpty {
            let fallback = NSAttributedString(string: attributedString.string)
            newPages.append(PageInfo(id: 1, characterRange: NSRange(location: 0, length: attributedString.length), content: fallback))
        }

        pages = newPages
        pageCount = newPages.count
        currentPage = min(max(1, currentPage), pageCount)
    }

    func updateCurrentPage(from scrollPosition: CGFloat, pageHeight: CGFloat) {
        guard pageHeight > 0, pageCount > 0 else { return }
        let pageWithSpacing = pageHeight + Spacing.page
        let page = Int(scrollPosition / pageWithSpacing) + 1
        currentPage = max(1, min(page, pageCount))
    }
}

extension NSEdgeInsets {
    static func uniform(_ value: CGFloat) -> NSEdgeInsets {
        NSEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
}
