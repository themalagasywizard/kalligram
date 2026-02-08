import Foundation

actor DebouncedTask {
    private var task: Task<Void, Never>?
    private let duration: TimeInterval

    init(duration: TimeInterval = 0.25) {
        self.duration = duration
    }

    func submit(operation: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            await operation()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
