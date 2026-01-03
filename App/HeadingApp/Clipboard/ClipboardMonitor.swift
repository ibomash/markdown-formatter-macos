import AppKit
import Combine
import Foundation

final class ClipboardMonitor: ObservableObject, ClipboardMonitoring {
    @Published private(set) var latestText: String = ""
    @Published private(set) var lastChangeDate: Date?

    private let pasteboard: NSPasteboard
    private let pollInterval: TimeInterval
    private let pollingEnabled: Bool
    private let scheduler: PollingScheduler
    private var lastChangeCount: Int
    private var pollingToken: PollingToken?

    init(
        pasteboard: NSPasteboard = .general,
        pollInterval: TimeInterval = 0.5,
        pollingEnabled: Bool = true,
        initialText: String? = nil,
        scheduler: PollingScheduler = TimerPollingScheduler()
    ) {
        self.pasteboard = pasteboard
        self.pollInterval = pollInterval
        self.pollingEnabled = pollingEnabled
        self.scheduler = scheduler
        self.lastChangeCount = pasteboard.changeCount
        if let initialText {
            latestText = initialText
        }
        start()
    }

    deinit {
        pollingToken?.cancel()
    }

    private func start() {
        pollingToken?.cancel()
        if pollingEnabled {
            pollingToken = scheduler.schedule(every: pollInterval, tolerance: pollInterval * 0.2) { [weak self] in
                self?.pollPasteboard()
            }
            refreshFromPasteboard()
        } else if latestText.isEmpty {
            refreshFromPasteboard()
        }
    }

    private func pollPasteboard() {
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return }
        refreshFromPasteboard()
    }

    private func refreshFromPasteboard() {
        lastChangeCount = pasteboard.changeCount
        latestText = pasteboard.string(forType: .string) ?? ""
        lastChangeDate = Date()
    }

    var latestTextPublisher: AnyPublisher<String, Never> {
        $latestText.eraseToAnyPublisher()
    }
}
