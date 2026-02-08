import SwiftUI
import SwiftData

struct CommentRowView: View {
    let comment: Comment
    let replies: [Comment]
    let commentsVM: CommentsViewModel
    let onJump: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var isHovered = false
    @State private var isReplying = false
    @State private var replyText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Highlighted text
            Button(action: onJump) {
                Text("\"\(comment.highlightedText.truncated(to: 80))\"")
                    .font(Typography.caption1)
                    .italic()
                    .foregroundStyle(ColorPalette.accentAmber)
                    .lineLimit(2)
            }
            .buttonStyle(.plain)

            // Comment content
            Text(comment.content)
                .font(Typography.bodySmall)
                .foregroundStyle(ColorPalette.textPrimary)

            // Metadata
            HStack {
                Text(comment.authorName)
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textSecondary)
                Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)

                Spacer()

                if isHovered && !comment.isResolved {
                    HStack(spacing: Spacing.xs) {
                        Button {
                            isReplying.toggle()
                        } label: {
                            Image(systemName: "arrowshape.turn.up.left")
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)

                        Button {
                            commentsVM.resolveComment(comment)
                        } label: {
                            Image(systemName: SFSymbolTokens.resolve)
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundStyle(ColorPalette.textTertiary)
                    .transition(.opacity)
                }
            }

            // Replies
            if !replies.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(replies, id: \.id) { reply in
                        HStack(alignment: .top, spacing: Spacing.xs) {
                            Rectangle()
                                .fill(ColorPalette.borderSubtle)
                                .frame(width: 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reply.content)
                                    .font(Typography.caption1)
                                    .foregroundStyle(ColorPalette.textPrimary)
                                Text(reply.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(Typography.caption2)
                                    .foregroundStyle(ColorPalette.textTertiary)
                            }
                        }
                    }
                }
                .padding(.leading, Spacing.sm)
            }

            // Reply input
            if isReplying {
                CommentInputView(text: $replyText) {
                    if let document = comment.document {
                        commentsVM.addReply(
                            content: replyText,
                            to: comment,
                            document: document,
                            modelContext: modelContext
                        )
                        isReplying = false
                        replyText = ""
                    }
                }
            }
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .fill(ColorPalette.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .strokeBorder(
                            isHovered ? ColorPalette.accentAmber.opacity(0.3) : ColorPalette.borderSubtle,
                            lineWidth: 1
                        )
                )
        )
        .onHover { hovering in
            withAnimation(AnimationTokens.snappy) {
                isHovered = hovering
            }
        }
    }
}
