import SwiftUI
import SwiftData

@Observable
final class CommentsViewModel {
    var comments: [Comment] = []
    var newCommentText: String = ""
    var replyingTo: Comment?

    func loadComments(for document: Document) {
        comments = document.comments.sorted { $0.characterRange < $1.characterRange }
    }

    func addComment(
        content: String,
        characterRange: Int,
        characterLength: Int,
        highlightedText: String,
        to document: Document,
        modelContext: ModelContext
    ) {
        let comment = Comment(
            content: content,
            authorName: "Author",
            characterRange: characterRange,
            characterLength: characterLength,
            highlightedText: highlightedText
        )
        comment.document = document
        modelContext.insert(comment)
        comments.append(comment)
        comments.sort { $0.characterRange < $1.characterRange }
        newCommentText = ""
    }

    func addReply(
        content: String,
        to parent: Comment,
        document: Document,
        modelContext: ModelContext
    ) {
        let reply = Comment(
            content: content,
            authorName: "Author",
            characterRange: parent.characterRange,
            characterLength: parent.characterLength,
            highlightedText: parent.highlightedText
        )
        reply.parentCommentID = parent.id
        reply.document = document
        modelContext.insert(reply)
        comments.append(reply)
        replyingTo = nil
        newCommentText = ""
    }

    func resolveComment(_ comment: Comment) {
        comment.isResolved = true
    }

    func deleteComment(_ comment: Comment, modelContext: ModelContext) {
        modelContext.delete(comment)
        comments.removeAll { $0.id == comment.id }
    }

    var unresolvedComments: [Comment] {
        comments.filter { !$0.isResolved && $0.parentCommentID == nil }
    }

    var resolvedComments: [Comment] {
        comments.filter { $0.isResolved && $0.parentCommentID == nil }
    }

    func replies(for comment: Comment) -> [Comment] {
        comments.filter { $0.parentCommentID == comment.id }
            .sorted { $0.createdAt < $1.createdAt }
    }
}
