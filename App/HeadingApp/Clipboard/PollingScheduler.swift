import Foundation

protocol PollingToken {
    func cancel()
}

protocol PollingScheduler {
    func schedule(every interval: TimeInterval, tolerance: TimeInterval, _ action: @escaping () -> Void) -> PollingToken
}

final class TimerPollingToken: PollingToken {
    private var timer: Timer?

    init(timer: Timer) {
        self.timer = timer
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}

struct TimerPollingScheduler: PollingScheduler {
    func schedule(every interval: TimeInterval, tolerance: TimeInterval, _ action: @escaping () -> Void) -> PollingToken {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            action()
        }
        timer.tolerance = tolerance
        return TimerPollingToken(timer: timer)
    }
}

final class ManualPollingScheduler: PollingScheduler {
    private var actions: [UUID: () -> Void] = [:]

    func schedule(every interval: TimeInterval, tolerance: TimeInterval, _ action: @escaping () -> Void) -> PollingToken {
        let id = UUID()
        actions[id] = action
        return ManualPollingToken { [weak self] in
            self?.actions.removeValue(forKey: id)
        }
    }

    func fire() {
        actions.values.forEach { $0() }
    }
}

final class ManualPollingToken: PollingToken {
    private let onCancel: () -> Void

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    func cancel() {
        onCancel()
    }
}
