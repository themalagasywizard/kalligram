import SwiftUI

struct CommentsPanelView: View {
    let commentsVM: CommentsViewModel
    let onJumpToComment: (NSRange) -> Void

    @State private var showResolved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                HStack {
                    Image(systemName: SFSymbolTokens.comments)
                        .foregroundStyle(ColorPalette.accentBlue)
                    Text("Comments")
                        .font(Typography.headline)
                        .foregroundStyle(ColorPalette.textPrimary)
                    Spacer()
                    Text("\(commentsVM.unresolvedComments.count)")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textTertiary)
                }

                if commentsVM.comments.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: SFSymbolTokens.comments)
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(ColorPalette.textTertiary.opacity(0.5))
                        Text("No comments yet")
                            .font(Typography.bodySmall)
                            .foregroundStyle(ColorPalette.textTertiary)
                        Text("Select text and press Cmd+Opt+M to add a comment")
                            .font(Typography.caption1)
                            .foregroundStyle(ColorPalette.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xxxl)
                } else {
                    // Unresolved comments
                    ForEach(commentsVM.unresolvedComments, id: \.id) { comment in
                        CommentRowView(
                            comment: comment,
                            replies: commentsVM.replies(for: comment),
                            commentsVM: commentsVM,
                            onJump: {
                                onJumpToComment(NSRange(
                                    location: comment.characterRange,
                                    length: comment.characterLength
                                ))
                            }
                        )
                    }

                    // Resolved toggle
                    if !commentsVM.resolvedComments.isEmpty {
                        DisclosureGroup("Resolved (\(commentsVM.resolvedComments.count))", isExpanded: $showResolved) {
                            ForEach(commentsVM.resolvedComments, id: \.id) { comment in
                                CommentRowView(
                                    comment: comment,
                                    replies: commentsVM.replies(for: comment),
                                    commentsVM: commentsVM,
                                    onJump: {
                                        onJumpToComment(NSRange(
                                            location: comment.characterRange,
                                            length: comment.characterLength
                                        ))
                                    }
                                )
                                .opacity(0.6)
                            }
                        }
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textTertiary)
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
}
