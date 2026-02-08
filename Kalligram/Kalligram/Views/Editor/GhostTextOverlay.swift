import SwiftUI
import AppKit

@Observable
final class GhostTextManager {
    var ghostText: String = ""
    var isVisible: Bool = false
    var isLoading: Bool = false
    var position: CGPoint = .zero

    private var debounceTask: Task<Void, Never>?

    func scheduleGhostText(
        textView: NSTextView,
        settings: UserSettings,
        contextText: String
    ) {
        guard settings.enableGhostText else { return }

        cancelGhostText()

        // Only trigger when cursor is at the end of a line or in an empty paragraph
        let selectedRange = textView.selectedRange()
        guard selectedRange.length == 0 else { return }

        let text = textView.string
        let cursorIndex = text.index(text.startIndex, offsetBy: min(selectedRange.location, text.count))

        // Check if we're at end of line or in empty paragraph
        let lineRange = text.lineRange(for: cursorIndex..<cursorIndex)
        let lineText = String(text[lineRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard lineText.isEmpty else { return }

        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }

            isLoading = true
            defer { isLoading = false }

            guard let service = AIServiceFactory.createFromSettings(settings) else { return }

            // Get preceding context (up to 500 words)
            let contextEnd = selectedRange.location
            let contextStart = max(0, contextEnd - 2000)
            let range = NSRange(location: contextStart, length: contextEnd - contextStart)
            let context = (text as NSString).substring(with: range)

            do {
                let suggestion = try await service.complete(
                    prompt: "Continue writing the following text naturally. Write 1-2 sentences that would logically follow. Return ONLY the continuation text, nothing else.\n\n\(context)",
                    systemPrompt: "You are a writing assistant. Continue the text naturally and seamlessly. Match the style and tone.",
                    maxTokens: 100
                )

                guard !Task.isCancelled else { return }
                ghostText = suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
                isVisible = true

                // Calculate position
                if let layoutManager = textView.layoutManager,
                   textView.textContainer != nil {
                    let glyphIndex = layoutManager.glyphIndexForCharacter(at: selectedRange.location)
                    let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
                    let textOrigin = textView.textContainerOrigin
                    position = CGPoint(
                        x: lineRect.origin.x + textOrigin.x + textView.textContainerInset.width,
                        y: lineRect.origin.y + textOrigin.y + textView.textContainerInset.height
                    )
                }
            } catch {
                // Silently fail — ghost text is non-essential
            }
        }
    }

    func cancelGhostText() {
        debounceTask?.cancel()
        debounceTask = nil
        ghostText = ""
        isVisible = false
    }

    func acceptGhostText(into textView: NSTextView) {
        guard isVisible, !ghostText.isEmpty else { return }
        let range = textView.selectedRange()
        textView.insertText(ghostText, replacementRange: range)
        cancelGhostText()
    }
}

struct GhostTextOverlay: View {
    let ghostText: String
    let isVisible: Bool
    let position: CGPoint

    var body: some View {
        if isVisible && !ghostText.isEmpty {
            Text(ghostText)
                .font(Typography.editorBody)
                .italic()
                .foregroundStyle(ColorPalette.textTertiary.opacity(0.6))
                .position(x: position.x + 4, y: position.y)
                .allowsHitTesting(false)
                .transition(.opacity.animation(AnimationTokens.fadeIn))
        }
    }
}
