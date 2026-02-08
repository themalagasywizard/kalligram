import Foundation

@Observable
final class AutosaveService {
    var isEnabled: Bool = true
    var interval: TimeInterval = AnimationTokens.autosaveInterval
    var lastSaveDate: Date?

    private var timer: Timer?
    private var saveAction: (() -> Void)?

    func start(saveAction: @escaping () -> Void) {
        self.saveAction = saveAction
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performSave()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func saveNow() {
        performSave()
    }

    private func performSave() {
        guard isEnabled else { return }
        saveAction?()
        lastSaveDate = Date()
    }

    deinit {
        timer?.invalidate()
    }
}
