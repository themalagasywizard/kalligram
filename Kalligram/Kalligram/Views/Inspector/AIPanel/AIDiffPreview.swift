import SwiftUI

struct AIDiffPreview: View {
    let chunks: [DiffChunk]

    var body: some View {
        Text(buildAttributedDiff())
            .font(Typography.bodySmall)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func buildAttributedDiff() -> AttributedString {
        var result = AttributedString()
        for chunk in chunks {
            var part = AttributedString(chunk.text)
            switch chunk.type {
            case .unchanged:
                part.foregroundColor = ColorPalette.textPrimary
            case .added:
                part.foregroundColor = ColorPalette.diffAdded
                part.backgroundColor = ColorPalette.diffAddedBackground
            case .removed:
                part.foregroundColor = ColorPalette.diffRemoved
                part.backgroundColor = ColorPalette.diffRemovedBackground
                part.strikethroughStyle = .single
            }
            result.append(part)
            result.append(AttributedString(" "))
        }
        return result
    }
}
