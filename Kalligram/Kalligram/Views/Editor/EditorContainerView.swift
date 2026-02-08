import SwiftUI
import SwiftData

struct EditorContainerView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(AppState.self) private var appState
    @State private var editorVM = EditorViewModel()
    @State private var formattingVM = FormattingViewModel()
    @State private var autosaveService = AutosaveService()
    @State private var paginationVM = PaginationViewModel()
    @Query private var settingsQuery: [UserSettings]
    @State private var editorAreaOriginY: CGFloat = 0

    private var settings: UserSettings { settingsQuery.first ?? UserSettings() }

    var aiRewriteVM: AIRewriteViewModel?

    var body: some View {
        VStack(spacing: 0) {
            DocumentTabBar()

            Group {
                if let document = appViewModel.selectedDocument {
                    editorContent(for: document)
                        .id(document.id)
                        .onAppear {
                            editorVM.loadDocument(document)
                            autosaveService.start {
                                if let textView = editorVM.textView, editorVM.isDirty {
                                    editorVM.saveContent(from: textView)
                                }
                            }
                        }
                        .onDisappear {
                            if let textView = editorVM.textView {
                                editorVM.saveContent(from: textView)
                            }
                            autosaveService.stop()
                        }
                        .onChange(of: appViewModel.selectedDocument?.id) { oldID, newID in
                            guard oldID != newID else { return }
                            // Save previous document before switching
                            if let textView = editorVM.textView, editorVM.isDirty {
                                editorVM.saveContent(from: textView)
                            }
                            // Load the new document
                            if let doc = appViewModel.selectedDocument {
                                editorVM.loadDocument(doc)
                            }
                        }
                        .onChange(of: editorVM.selectedText) { _, newValue in
                            aiRewriteVM?.selectedText = newValue
                        }
                        .onChange(of: appState.pendingInsertText) { _, newValue in
                            guard let text = newValue else { return }
                            editorVM.replaceSelection(with: text)
                            appState.pendingInsertText = nil
                        }
                } else {
                    KEmptyState(
                        icon: "doc.text.below.ecg",
                        title: "No Document Selected",
                        message: "Select a document from the sidebar or create a new one to start writing.",
                        actionTitle: "New Document"
                    ) {
                        appState.isNewDocumentSheetPresented = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.editorBackground)
    }

    @ViewBuilder
    private func editorContent(for document: Document) -> some View {
        let viewMode = document.viewModeEnum
        let formattingSnapshot = DocumentFormattingSnapshot(document: document)

        VStack(spacing: 0) {
            if shouldShowEditorToolbar {
                EditorFormattingToolbar(
                    editorVM: editorVM,
                    formattingVM: formattingVM
                )
            }

            switch viewMode {
            case .draft:
                draftView(for: document)
            case .print:
                printView(for: document)
            case .reader:
                readerView(for: document)
            case .paginated:
                paginatedView(for: document)
            }
        }
        .onChange(of: formattingSnapshot) { oldValue, newValue in
            guard oldValue.documentID == newValue.documentID else { return }
            applyDocumentFormatting(document)
        }
    }

    private var shouldShowEditorToolbar: Bool {
        if appState.isFocusModeActive && settings.focusModeHideToolbar {
            return false
        }
        return true
    }

    // MARK: - Draft Mode (default)

    @ViewBuilder
    private func draftView(for document: Document) -> some View {
        paginatedView(for: document)
    }

    // MARK: - Print Mode

    @ViewBuilder
    private func printView(for document: Document) -> some View {
        let paperSize = document.paperSizeEnum
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: Spacing.canvas)

                    // Page canvas
                    ZStack {
                        // Paper shadow
                        RoundedRectangle(cornerRadius: 1)
                            .fill(ColorPalette.surfacePrimary)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 12,
                                x: 0,
                                y: 4
                            )
                            .frame(width: paperSize.widthPoints)

                        // Editor constrained to paper width
                        RichTextEditor(
                            document: document,
                            editorVM: editorVM,
                            formattingVM: formattingVM
                        )
                        .frame(width: paperSize.widthPoints)
                    }

                    Spacer().frame(height: Spacing.canvas)
                }
                .frame(maxWidth: .infinity)
            }
            .background(ColorPalette.surfaceTertiary.opacity(0.5))

            floatingToolbarOverlay()
            wordCountOverlay(for: document)
        }
        .background(editorAreaTracker)
    }

    // MARK: - Reader Mode

    @ViewBuilder
    private func readerView(for document: Document) -> some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: Spacing.canvas)

                    RichTextEditor(
                        document: document,
                        editorVM: editorVM,
                        formattingVM: formattingVM
                    )
                    .frame(maxWidth: 680)

                    Spacer().frame(height: Spacing.canvas)
                }
                .frame(maxWidth: .infinity)
            }
            .background(ColorPalette.readerSepia.opacity(0.15))

            floatingToolbarOverlay()
            wordCountOverlay(for: document)
        }
        .background(editorAreaTracker)
    }

    // MARK: - Paginated Mode

    @ViewBuilder
    private func paginatedView(for document: Document) -> some View {
        let paperSize = document.paperSizeEnum
        let margins = NSEdgeInsets(
            top: document.marginTop,
            left: document.marginLeft,
            bottom: document.marginBottom,
            right: document.marginRight
        )
        let bleed: CGFloat = 12

        HStack(spacing: 0) {
            // Thumbnail rail
            PageThumbnailRail(
                pageCount: max(1, paginationVM.pageCount),
                currentPage: paginationVM.currentPage
            ) { page in
                paginationVM.currentPage = page
                paginationVM.scrollToPage = page
            }

            KDivider(orientation: .vertical)

            // Main editor area
            ZStack(alignment: .top) {
                PaginatedEditorView(
                    document: document,
                    editorVM: editorVM,
                    formattingVM: formattingVM,
                    paginationVM: paginationVM,
                    paperSize: paperSize,
                    margins: margins,
                    bleed: bleed,
                    showsGuides: true
                )
                .background(ColorPalette.surfaceTertiary.opacity(0.5))

                floatingToolbarOverlay()
                wordCountOverlay(for: document)
            }
            .background(editorAreaTracker)
        }
    }

    // MARK: - Shared Overlays

    @ViewBuilder
    private func floatingToolbarOverlay() -> some View {
        if editorVM.hasSelection {
            FloatingToolbar(
                isVisible: editorVM.hasSelection,
                isRewriting: editorVM.isRewriting,
                onRewrite: {
                    editorVM.requestInlineRewrite(using: settings)
                }
            )
            .padding(.top, max(editorVM.selectionRect.minY - editorAreaOriginY - 48, 8))
            .animation(AnimationTokens.snappy, value: editorVM.hasSelection)
        }
    }

    private var editorAreaTracker: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    editorAreaOriginY = geo.frame(in: .global).origin.y
                }
                .onChange(of: geo.frame(in: .global).origin.y) { _, newY in
                    editorAreaOriginY = newY
                }
        }
    }

    @ViewBuilder
    private func wordCountOverlay(for document: Document) -> some View {
        VStack {
            Spacer()
            WordCountView(
                wordCount: editorVM.wordCount,
                characterCount: editorVM.characterCount,
                goalCount: document.wordCountGoal
            )
            .padding(.bottom, Spacing.sm)
        }
    }

    private func applyDocumentFormatting(_ document: Document) {
        guard let textView = editorVM.textView,
              let textStorage = textView.textStorage else { return }
        DocumentFormattingService.applyBodyStyle(to: textStorage, document: document)
        DocumentFormattingService.configureTextViewDefaults(textView, document: document)
        editorVM.markDirty()
        editorVM.saveContent(from: textView)
    }
}

private struct DocumentFormattingSnapshot: Equatable {
    let documentID: UUID
    let bodyFontName: String
    let bodyFontSize: Double
    let lineSpacing: Double
    let paragraphSpacingBefore: Double
    let paragraphSpacing: Double
    let firstLineIndent: Double
    let bodyAlignment: String
    let hyphenationEnabled: Bool

    init(document: Document) {
        documentID = document.id
        bodyFontName = document.bodyFontName
        bodyFontSize = document.bodyFontSize
        lineSpacing = document.lineSpacing
        paragraphSpacingBefore = document.paragraphSpacingBefore
        paragraphSpacing = document.paragraphSpacing
        firstLineIndent = document.firstLineIndent
        bodyAlignment = document.bodyAlignment
        hyphenationEnabled = document.hyphenationEnabled
    }
}

// MARK: - Rewrite Toggle Bar

struct RewriteToggleBar: View {
    let isShowingRewritten: Bool
    let onToggle: () -> Void
    let onAccept: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Toggle between versions
            Button(action: onToggle) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 11, weight: .medium))
                    Text(isShowingRewritten ? "Rewritten" : "Original")
                        .font(Typography.caption1)
                }
                .foregroundStyle(isShowingRewritten ? Color.green : ColorPalette.textSecondary)
            }
            .buttonStyle(.plain)
            .help("Toggle between original and rewritten text")

            KDivider()
                .frame(height: 16)

            // Accept
            Button(action: onAccept) {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.green)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .help("Accept rewrite")

            // Dismiss / Revert
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ColorPalette.textTertiary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .help("Revert to original")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.radiusMedium))
        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }
}
