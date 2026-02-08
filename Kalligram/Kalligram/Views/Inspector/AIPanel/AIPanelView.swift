import SwiftUI
import SwiftData
import AppKit

struct AIPanelView: View {
    let rewriteVM: AIRewriteViewModel
    let hasSelection: Bool
    let onAcceptRewrite: (String) -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var generateVM = AIGenerateViewModel()
    @State private var inputText: String = ""
    @State private var inputHeight: CGFloat = 56
    @State private var messages: [AIChatMessage] = []
    @State private var showGenerateSettings = false
    @State private var settings: UserSettings? = nil
    @State private var hasLoadedSettings = false

    var body: some View {
        VStack(spacing: 0) {
            chatTranscript

            KDivider()

            chatComposer
        }
        .background(ColorPalette.surfacePrimary)
        .onAppear {
            loadSettingsIfNeeded()
        }
        .sheet(isPresented: $showGenerateSettings) {
            AIGenerateSettingsSheet(generateVM: generateVM)
        }
    }

    private var chatTranscript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.md) {
                    if messages.isEmpty {
                        aiEmptyState
                    } else {
                        ForEach(messages) { message in
                            AIChatMessageRow(
                                message: message,
                                onInsert: { text in
                                    onAcceptRewrite(text)
                                }
                            )
                        }
                    }

                    if generateVM.isLoading {
                        AIChatMessageRow(
                            message: AIChatMessage(role: .assistant, text: "Thinking...")
                        )
                    }

                    if let error = generateVM.error {
                        Text(error)
                            .font(Typography.caption1)
                            .foregroundStyle(.red)
                            .padding(.horizontal, Spacing.sm)
                    }

                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(Spacing.lg)
            }
            .background(ColorPalette.surfaceSecondary)
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy)
            }
            .onChange(of: generateVM.isLoading) { _, _ in
                scrollToBottom(proxy)
            }
        }
    }

    private var chatComposer: some View {
        VStack(spacing: Spacing.sm) {
            composerBubble
        }
        .padding(Spacing.md)
        .background(ColorPalette.surfaceSecondary)
    }

    private var composerBubble: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ZStack(alignment: .topLeading) {
                ChatInputTextView(
                    text: $inputText,
                    dynamicHeight: $inputHeight
                ) {
                    sendMessage()
                }
                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 200, alignment: .topLeading)
                .frame(height: max(56, min(200, inputHeight)))

                if inputText.isEmpty {
                    Text("Ask Kalligram...")
                        .font(Typography.bodySmall)
                        .foregroundStyle(ColorPalette.textTertiary)
                        .padding(.top, 2)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: Spacing.sm) {
                modelSelector

                Spacer()

                Button {
                    showGenerateSettings = true
                } label: {
                    Image(systemName: SFSymbolTokens.settings)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ColorPalette.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(ColorPalette.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .help("Generate settings")

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(ColorPalette.aiAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || generateVM.isLoading)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity)
        .background(ColorPalette.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var modelSelector: some View {
        Group {
            if let settings {
                Menu {
                    ForEach(modelOptions(for: settings), id: \.self) { model in
                        Button {
                            settings.preferredModel = model
                        } label: {
                            Text(model)
                        }
                    }
                } label: {
                    Text(shortModelName(settings.preferredModel))
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textPrimary)
                        .lineLimit(1)
                }
                .menuStyle(.borderlessButton)
                .help("Model")
            } else {
                Text("Model")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textTertiary)
            }
        }
    }

    private var aiEmptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: SFSymbolTokens.ai)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(ColorPalette.aiAccent.opacity(0.5))
            Text("Ask a question or describe what you want to write.")
                .font(Typography.bodySmall)
                .foregroundStyle(ColorPalette.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxxl)
    }

    private func loadSettingsIfNeeded() {
        guard !hasLoadedSettings else { return }
        hasLoadedSettings = true
        let service = SettingsService(modelContext: modelContext)
        let loaded = service.getSettings()
        settings = loaded

        if let tone = AITone(rawValue: loaded.defaultAITone) {
            generateVM.selectedTone = tone
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(AIChatMessage(role: .user, text: trimmed))
        inputText = ""
        inputHeight = 56

        generateVM.prompt = trimmed
        generateVM.generatedText = ""

        Task {
            guard let settings else { return }
            await generateVM.generate(using: settings)
            let response = generateVM.generatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !response.isEmpty {
                messages.append(AIChatMessage(role: .assistant, text: response))
            }
            generateVM.prompt = ""
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }

    private func modelOptions(for settings: UserSettings) -> [String] {
        var options: [String] = []

        func add(_ model: String) {
            guard !options.contains(model) else { return }
            options.append(model)
        }

        add(settings.preferredModel)

        switch settings.preferredAIProvider {
        case "openai":
            add("gpt-4o")
            add("gpt-4o-mini")
            add("gpt-4.1")
        case "claude":
            add("claude-sonnet-4-5-20250929")
            add("claude-3-5-sonnet-latest")
            add("claude-3-haiku-20240307")
        default:
            add("anthropic/claude-sonnet-4")
            add("openai/gpt-4o")
            add("google/gemini-1.5-pro")
        }

        return options
    }

    private func shortModelName(_ model: String) -> String {
        if let last = model.split(separator: "/").last {
            return String(last)
        }
        return model
    }
}

private struct AIChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let text: String
}

private struct AIChatMessageRow: View {
    let message: AIChatMessage
    var onInsert: ((String) -> Void)? = nil

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: Spacing.xl)
            } else {
                Spacer(minLength: Spacing.xl)
                bubble
            }
        }
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(message.text)
                .font(Typography.bodySmall)
                .foregroundStyle(ColorPalette.textPrimary)
                .textSelection(.enabled)

            if message.role == .assistant, let onInsert {
                HStack {
                    Spacer()
                    Button {
                        onInsert(message.text)
                    } label: {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ColorPalette.aiAccent)
                            .frame(width: 22, height: 22)
                            .background(ColorPalette.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .help("Insert at cursor")
                }
            }
        }
        .padding(Spacing.sm)
        .background(bubbleBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var bubbleBackground: Color {
        switch message.role {
        case .assistant:
            ColorPalette.surfaceTertiary
        case .user:
            ColorPalette.aiAccentLight
        }
    }
}

private struct AIGenerateSettingsSheet: View {
    let generateVM: AIGenerateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Image(systemName: SFSymbolTokens.settings)
                    .foregroundStyle(ColorPalette.textSecondary)
                Text("Generate Settings")
                    .font(Typography.headline)
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Tone")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                Picker("", selection: Bindable(generateVM).selectedTone) {
                    ForEach(AITone.allCases, id: \.self) { tone in
                        Text(tone.displayName).tag(tone)
                    }
                }
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Target Length")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                HStack {
                    Slider(value: .init(
                        get: { Double(generateVM.targetLength) },
                        set: { generateVM.targetLength = Int($0) }
                    ), in: 50...1000, step: 50)
                    Text("\(generateVM.targetLength) words")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textTertiary)
                        .frame(width: 80)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Audience (Optional)")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                TextField("e.g. General readers, executives", text: Bindable(generateVM).audience)
                    .textFieldStyle(.roundedBorder)
                    .font(Typography.bodySmall)
            }

            Spacer()
        }
        .padding(Spacing.lg)
        .frame(minWidth: 360, minHeight: 320)
    }
}

private struct ChatInputTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    var onSubmit: () -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let textView = ChatInputNSTextView()
        textView.delegate = context.coordinator
        textView.onSubmit = onSubmit

        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textContainerInset = .zero
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        textView.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        textView.textColor = NSColor(ColorPalette.textPrimary)
        textView.string = text

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        textView.textContainer?.containerSize = CGSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? ChatInputNSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
        context.coordinator.updateHeight(for: textView, deferUpdate: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, dynamicHeight: $dynamicHeight)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        @Binding var dynamicHeight: CGFloat

        init(text: Binding<String>, dynamicHeight: Binding<CGFloat>) {
            _text = text
            _dynamicHeight = dynamicHeight
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
            updateHeight(for: textView, deferUpdate: false)
        }

        func updateHeight(for textView: NSTextView, deferUpdate: Bool) {
            guard let container = textView.textContainer,
                  let layoutManager = textView.layoutManager else { return }
            layoutManager.ensureLayout(for: container)
            let used = layoutManager.usedRect(for: container).size
            let height = used.height
            let clamped = max(56, min(200, height))
            if deferUpdate {
                DispatchQueue.main.async {
                    self.dynamicHeight = clamped
                }
            } else {
                dynamicHeight = clamped
            }
        }
    }
}

private final class ChatInputNSTextView: NSTextView {
    var onSubmit: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        let isReturn = event.keyCode == 36 || event.keyCode == 76
        if isReturn {
            if event.modifierFlags.contains(.shift) {
                insertNewline(nil)
            } else {
                onSubmit?()
            }
            return
        }
        super.keyDown(with: event)
    }
}
