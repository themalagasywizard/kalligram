import SwiftUI

struct ProjectListView: View {
    let projects: [Project]
    let openDocumentIDs: [UUID]
    let onDelete: (Document) -> Void

    var body: some View {
        ForEach(projects, id: \.id) { project in
            ProjectRowView(
                project: project,
                openDocumentIDs: openDocumentIDs,
                onDelete: onDelete
            )
        }
    }
}
