import SwiftUI
import SwiftData

@Observable
final class ProjectViewModel {
    func createProject(name: String, in context: ModelContext) -> Project {
        let project = Project(name: name)
        context.insert(project)
        return project
    }

    func deleteProject(_ project: Project, in context: ModelContext) {
        context.delete(project)
    }

    func renameProject(_ project: Project, to name: String) {
        project.name = name
        project.updatedAt = Date()
    }
}
