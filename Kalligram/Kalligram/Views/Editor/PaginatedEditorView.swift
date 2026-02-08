import SwiftUI
import AppKit

struct PaginatedEditorView: View {
    let document: Document
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel
    let paginationVM: PaginationViewModel
    let paperSize: PaperSize
    let margins: NSEdgeInsets
    let bleed: CGFloat
    let showsGuides: Bool

    @State private var textSystem = PaginatedTextSystem()

    private var contentSize: CGSize {
        CGSize(
            width: paperSize.widthPoints - margins.left - margins.right,
            height: paperSize.heightPoints - margins.top - margins.bottom
        )
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Spacing.page) {
                    ForEach(1...max(1, paginationVM.pageCount), id: \.self) { page in
                        PageContainer(
                            pageNumber: page,
                            totalPages: paginationVM.pageCount,
                            paperSize: paperSize,
                            isCurrentPage: page == paginationVM.currentPage,
                            content: nil,
                            margins: margins,
                            bleed: bleed,
                            showsGuides: showsGuides,
                            showsPageNumbers: document.includePageNumbers
                        )
                        .overlay(alignment: .topLeading) {
                            PaginatedPageTextView(
                                textSystem: textSystem,
                                document: document,
                                editorVM: editorVM,
                                formattingVM: formattingVM,
                                paginationVM: paginationVM,
                                pageIndex: page,
                                contentSize: contentSize
                            )
                            .frame(
                                width: contentSize.width,
                                height: contentSize.height
                            )
                            .padding(.top, bleed + margins.top)
                            .padding(.leading, bleed + margins.left)
                        }
                        .id(page)
                    }
                }
                .padding(.vertical, Spacing.canvas)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: paginationVM.scrollToPage) { _, newValue in
                guard let page = newValue else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(page, anchor: .top)
                }
                paginationVM.scrollToPage = nil
            }
        }
    }
}

private struct PaginatedPageTextView: NSViewRepresentable {
    let textSystem: PaginatedTextSystem
    let document: Document
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel
    let paginationVM: PaginationViewModel
    let pageIndex: Int
    let contentSize: CGSize

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        updateTextSystem(context: context)

        let textView = textSystem.textView(
            for: pageIndex,
            contentSize: contentSize,
            coordinator: context.coordinator
        )

        attach(textView, to: container)
        return container
    }

    func updateNSView(_ container: NSView, context: Context) {
        updateTextSystem(context: context)
        let textView = textSystem.textView(
            for: pageIndex,
            contentSize: contentSize,
            coordinator: context.coordinator
        )
        attach(textView, to: container)
    }

    func makeCoordinator() -> PaginatedTextCoordinator {
        textSystem.coordinator(
            editorVM: editorVM,
            formattingVM: formattingVM,
            paginationVM: paginationVM
        )
    }

    private func updateTextSystem(context: Context) {
        textSystem.configure(
            document: document,
            editorVM: editorVM,
            formattingVM: formattingVM,
            paginationVM: paginationVM,
            contentSize: contentSize,
            coordinator: context.coordinator
        )
    }

    private func attach(_ textView: NSTextView, to container: NSView) {
        if textView.superview !== container {
            textView.removeFromSuperview()
            container.subviews.forEach { $0.removeFromSuperview() }
            container.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                textView.topAnchor.constraint(equalTo: container.topAnchor),
                textView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
    }
}

@MainActor
final class PaginatedTextCoordinator: NSObject, NSTextViewDelegate {
    let editorVM: EditorViewModel
    let formattingVM: FormattingViewModel
    let paginationVM: PaginationViewModel
    private weak var textSystem: PaginatedTextSystem?
    private let saveDebouncer = DebouncedTask(duration: 2.0)

    init(
        editorVM: EditorViewModel,
        formattingVM: FormattingViewModel,
        paginationVM: PaginationViewModel
    ) {
        self.editorVM = editorVM
        self.formattingVM = formattingVM
        self.paginationVM = paginationVM
        super.init()
    }

    func attach(textSystem: PaginatedTextSystem) {
        self.textSystem = textSystem
    }

    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView,
              let textStorage = textView.textStorage else { return }

        // If a programmatic rewrite edit triggered this, skip clearing state / debounced save
        if editorVM.isProgrammaticRewriteEdit {
            editorVM.updateCounts(from: textStorage)
            textSystem?.ensurePages()
            if let textSystem {
                paginationVM.pageCount = max(1, textSystem.pageCount)
            }
            return
        }

        // User typed manually — invalidate any pending rewrite
        if editorVM.inlineRewrite != nil {
            editorVM.inlineRewrite = nil
        }

        editorVM.updateCounts(from: textStorage)
        editorVM.markDirty()

        textSystem?.ensurePages()
        if let textSystem {
            paginationVM.pageCount = max(1, textSystem.pageCount)
        }

        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.saveDebouncer.submit { @MainActor [weak self] in
                guard let self else { return }
                self.editorVM.saveContent(from: textView)
            }
        }
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

        editorVM.textView = textView
        if let identifier = textView.identifier?.rawValue,
           identifier.hasPrefix("page-"),
           let page = Int(identifier.dropFirst(5)) {
            paginationVM.currentPage = page
        }

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

@MainActor
final class PaginatedTextSystem {
    private(set) var pageCount: Int = 1
    private let textStorage = NSTextStorage()
    private let layoutManager = NSLayoutManager()
    private var textContainers: [NSTextContainer] = []
    private var textViews: [NSTextView] = []
    private var documentID: UUID?
    private var document: Document?
    private var contentSize: CGSize = .zero
    private weak var editorVM: EditorViewModel?
    private weak var paginationVM: PaginationViewModel?
    private var coordinatorInstance: PaginatedTextCoordinator?
    private var needsInitialSelection = false

    init() {
        layoutManager.usesFontLeading = true
        textStorage.addLayoutManager(layoutManager)
    }

    func coordinator(
        editorVM: EditorViewModel,
        formattingVM: FormattingViewModel,
        paginationVM: PaginationViewModel
    ) -> PaginatedTextCoordinator {
        if let coordinatorInstance {
            return coordinatorInstance
        }
        let coordinator = PaginatedTextCoordinator(
            editorVM: editorVM,
            formattingVM: formattingVM,
            paginationVM: paginationVM
        )
        coordinator.attach(textSystem: self)
        coordinatorInstance = coordinator
        return coordinator
    }

    func configure(
        document: Document,
        editorVM: EditorViewModel,
        formattingVM: FormattingViewModel,
        paginationVM: PaginationViewModel,
        contentSize: CGSize,
        coordinator: PaginatedTextCoordinator
    ) {
        self.editorVM = editorVM
        self.paginationVM = paginationVM
        self.document = document
        coordinator.attach(textSystem: self)

        if documentID != document.id {
            loadContent(from: document)
            documentID = document.id
            paginationVM.currentPage = 1
            needsInitialSelection = true
        }

        if self.contentSize != contentSize {
            self.contentSize = contentSize
            updateContainerSizes()
        }

        ensurePages()
        paginationVM.pageCount = max(1, pageCount)
        updateTextViewDefaults()
        if paginationVM.currentPage > paginationVM.pageCount {
            paginationVM.currentPage = paginationVM.pageCount
        }
        if needsInitialSelection, let first = textViews.first {
            let cursorPos = min(document.lastCursorPosition, textStorage.length)
            first.setSelectedRange(NSRange(location: cursorPos, length: 0))
            needsInitialSelection = false
        }
        if editorVM.textView == nil, let first = textViews.first {
            editorVM.textView = first
        }
    }

    func textView(
        for pageIndex: Int,
        contentSize: CGSize,
        coordinator: PaginatedTextCoordinator
    ) -> NSTextView {
        if self.contentSize != contentSize {
            self.contentSize = contentSize
            updateContainerSizes()
        }

        ensurePages()
        let index = max(0, pageIndex - 1)
        while index >= textViews.count {
            addPage()
        }
        let textView = textViews[index]
        textView.delegate = coordinator
        textView.identifier = NSUserInterfaceItemIdentifier("page-\(pageIndex)")
        return textView
    }

    func ensurePages() {
        guard contentSize.width > 0, contentSize.height > 0 else { return }

        if textContainers.isEmpty {
            addPage()
        }

        var safety = 0
        while safety < 2000 {
            safety += 1
            guard let lastContainer = textContainers.last else { break }
            layoutManager.ensureLayout(for: lastContainer)
            let glyphRange = layoutManager.glyphRange(for: lastContainer)
            let glyphEnd = NSMaxRange(glyphRange)

            if glyphEnd < layoutManager.numberOfGlyphs {
                addPage()
                continue
            }
            break
        }

        while textContainers.count > 1, let lastContainer = textContainers.last {
            layoutManager.ensureLayout(for: lastContainer)
            let glyphRange = layoutManager.glyphRange(for: lastContainer)
            if glyphRange.length == 0 {
                removeLastPage()
            } else {
                break
            }
        }

        pageCount = max(1, textContainers.count)
    }

    private func addPage() {
        let container = NSTextContainer(size: contentSize)
        container.lineFragmentPadding = 0
        layoutManager.addTextContainer(container)

        let textView = NSTextView(frame: .zero, textContainer: container)
        configure(textView: textView)

        textContainers.append(container)
        textViews.append(textView)
    }

    private func removeLastPage() {
        guard let container = textContainers.popLast(),
              let textView = textViews.popLast() else { return }
        if let index = layoutManager.textContainers.firstIndex(of: container) {
            layoutManager.removeTextContainer(at: index)
        }
        textView.removeFromSuperview()
    }

    private func updateContainerSizes() {
        for container in textContainers {
            container.size = contentSize
        }
        for textView in textViews {
            textView.textContainer?.containerSize = contentSize
            textView.invalidateIntrinsicContentSize()
        }
    }

    private func configure(textView: NSTextView) {
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = true
        textView.usesFindPanel = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true

        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = true
        textView.isGrammarCheckingEnabled = true
        textView.smartInsertDeleteEnabled = true

        textView.drawsBackground = false
        textView.textContainerInset = .zero
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = true
        textView.textContainer?.containerSize = contentSize

        if let document {
            DocumentFormattingService.configureTextViewDefaults(textView, document: document)
        } else {
            textView.font = Typography.editorBodyNS
            textView.textColor = NSColor.textColor
            let defaultParagraph = NSMutableParagraphStyle()
            defaultParagraph.lineSpacing = Typography.editorBodyLeading - Typography.editorBodyNS.pointSize
            defaultParagraph.paragraphSpacing = 4
            textView.defaultParagraphStyle = defaultParagraph
            textView.typingAttributes = [
                .font: Typography.editorBodyNS,
                .foregroundColor: NSColor.textColor,
                .paragraphStyle: defaultParagraph
            ]
        }
    }

    private func updateTextViewDefaults() {
        guard let document else { return }
        for textView in textViews {
            DocumentFormattingService.configureTextViewDefaults(textView, document: document)
        }
    }

    private func loadContent(from document: Document) {
        let attributed: NSAttributedString
        if let rtfData = document.contentRTFData,
           let attrString = NSAttributedString.fromRTFData(rtfData) {
            attributed = attrString
        } else if !document.contentPlainText.isEmpty {
            attributed = NSAttributedString(string: document.contentPlainText)
        } else {
            attributed = NSAttributedString(string: "")
        }

        textStorage.setAttributedString(attributed)
        editorVM?.updateCounts(from: textStorage)
    }
}
