import SwiftUI
import AppKit

@Observable
final class OutlineViewModel {
    var headings: [OutlineHeading] = []
    var currentHeadingID: UUID?

    struct OutlineHeading: Identifiable {
        let id = UUID()
        let title: String
        let level: Int
        let characterRange: NSRange
        var children: [OutlineHeading]
    }

    func extractHeadings(from textStorage: NSTextStorage) {
        var extracted: [OutlineHeading] = []
        let fullRange = NSRange(location: 0, length: textStorage.length)

        textStorage.enumerateAttribute(.font, in: fullRange) { value, range, _ in
            guard let font = value as? NSFont else { return }
            let level: Int
            if font.pointSize >= 28 { level = 1 }
            else if font.pointSize >= 22 { level = 2 }
            else if font.pointSize >= 18 { level = 3 }
            else { return }

            let text = (textStorage.string as NSString).substring(with: range)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }

            extracted.append(OutlineHeading(
                title: text,
                level: level,
                characterRange: range,
                children: []
            ))
        }

        headings = buildTree(from: extracted)
    }

    func updateCurrentHeading(cursorPosition: Int) {
        // Find the heading closest to and before the cursor
        let flat = flattenHeadings(headings)
        currentHeadingID = flat.last(where: { $0.characterRange.location <= cursorPosition })?.id
    }

    private func buildTree(from flat: [OutlineHeading]) -> [OutlineHeading] {
        // Simple: return flat for now, nesting can be added later
        return flat
    }

    private func flattenHeadings(_ items: [OutlineHeading]) -> [OutlineHeading] {
        var result: [OutlineHeading] = []
        for item in items {
            result.append(item)
            result.append(contentsOf: flattenHeadings(item.children))
        }
        return result
    }
}
