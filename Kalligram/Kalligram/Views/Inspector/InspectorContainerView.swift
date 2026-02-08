import SwiftUI

struct InspectorContainerView: View {
    @Environment(AppState.self) private var appState
    @Namespace private var tabAnimation

    var outlineVM: OutlineViewModel?
    var onSelectHeading: ((NSRange) -> Void)?

    var aiRewriteVM: AIRewriteViewModel?
    var hasEditorSelection: Bool = false
    var onAcceptRewrite: ((String) -> Void)?

    var researchVM: ResearchViewModel?
    var citationVM: CitationViewModel?
    var commentsVM: CommentsViewModel?
    var historyVM: VersionHistoryViewModel?
    var document: Document?
    var onInsertText: ((String) -> Void)?
    var onJumpToRange: ((NSRange) -> Void)?
    var onRestore: (() -> Void)?
    var onBranchCreated: ((Document) -> Void)?

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(AppState.InspectorTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(AnimationTokens.snappy) {
                            appState.inspectorTab = tab
                        }
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 14))
                                .foregroundStyle(
                                    appState.inspectorTab == tab
                                        ? ColorPalette.accentBlue
                                        : ColorPalette.textTertiary
                                )
                                .frame(height: 20)

                            if appState.inspectorTab == tab {
                                Capsule()
                                    .fill(ColorPalette.accentBlue)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "tab_indicator", in: tabAnimation)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(tab.label)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.editorToolbarHeight)
            .background(ColorPalette.surfaceSecondary)
            .overlay(alignment: .top) { KDivider() }
            .overlay(alignment: .bottom) { KDivider() }

            // Tab content
            Group {
                switch appState.inspectorTab {
                case .outline:
                    if let outlineVM {
                        OutlinePanelView(
                            outlineVM: outlineVM,
                            onSelectHeading: { range in
                                onSelectHeading?(range)
                            }
                        )
                    } else {
                        InspectorPlaceholder(tab: "Outline", icon: SFSymbolTokens.outline)
                    }
                case .format:
                    if let document {
                        FormatPanelView(document: document)
                    } else {
                        InspectorPlaceholder(tab: "Format", icon: SFSymbolTokens.format)
                    }
                case .ai:
                    if let aiRewriteVM {
                        AIPanelView(
                            rewriteVM: aiRewriteVM,
                            hasSelection: hasEditorSelection,
                            onAcceptRewrite: { text in
                                onAcceptRewrite?(text)
                            }
                        )
                    } else {
                        InspectorPlaceholder(tab: "AI", icon: SFSymbolTokens.ai)
                    }
                case .research:
                    if let researchVM, let citationVM {
                        ResearchPanelView(
                            researchVM: researchVM,
                            citationVM: citationVM,
                            document: document,
                            onInsertCitation: { text in
                                onInsertText?(text)
                            }
                        )
                    } else {
                        InspectorPlaceholder(tab: "Research", icon: SFSymbolTokens.research)
                    }
                case .comments:
                    if let commentsVM {
                        CommentsPanelView(
                            commentsVM: commentsVM,
                            onJumpToComment: { range in
                                onJumpToRange?(range)
                            }
                        )
                    } else {
                        InspectorPlaceholder(tab: "Comments", icon: SFSymbolTokens.comments)
                    }
                case .history:
                    if let historyVM {
                        HistoryPanelView(
                            historyVM: historyVM,
                            document: document,
                            onRestore: {
                                onRestore?()
                            },
                            onBranchCreated: { newDoc in
                                onBranchCreated?(newDoc)
                            }
                        )
                    } else {
                        InspectorPlaceholder(tab: "History", icon: SFSymbolTokens.history)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
        .background(ColorPalette.surfaceSecondary)
    }
}

struct InspectorPlaceholder: View {
    let tab: String
    let icon: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(ColorPalette.textTertiary)
            Text(tab)
                .font(Typography.headline)
                .foregroundStyle(ColorPalette.textSecondary)
            Text("Coming soon")
                .font(Typography.caption1)
                .foregroundStyle(ColorPalette.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
