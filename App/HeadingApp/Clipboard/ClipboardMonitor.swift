import AppKit
import Foundation

final class ClipboardMonitor: ObservableObject {
    @Published private(set) var latestText: String = ""
    @Published private(set) var lastChangeDate: Date?

    private let pasteboard: NSPasteboard
    private let pollInterval: TimeInterval
    private var lastChangeCount: Int
    private var timer: Timer?

    init(pasteboard: NSPasteboard = .general, pollInterval: TimeInterval = 0.5) {
        self.pasteboard = pasteboard
        self.pollInterval = pollInterval
        self.lastChangeCount = pasteboard.changeCount
        start()
    }

    deinit {
        timer?.invalidate()
    }

    private func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }
        timer?.tolerance = pollInterval * 0.2
        pollPasteboard()
    }

    private func pollPasteboard() {
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return }
        lastChangeCount = changeCount
        latestText = pasteboard.string(forType: .string) ?? ""
        lastChangeDate = Date()
    }
}
