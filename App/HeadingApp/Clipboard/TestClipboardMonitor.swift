import Combine
import Foundation

final class TestClipboardMonitor: ClipboardMonitoring {
    @Published private(set) var latestText: String

    init(initialText: String) {
        self.latestText = initialText
    }

    func update(text: String) {
        latestText = text
    }

    var latestTextPublisher: AnyPublisher<String, Never> {
        $latestText.eraseToAnyPublisher()
    }
}
