import Combine
import Foundation

protocol ClipboardMonitoring: AnyObject {
    var latestText: String { get }
    var latestTextPublisher: AnyPublisher<String, Never> { get }
}

protocol ClipboardWriting {
    func write(text: String)
}

protocol PasteServicing {
    func hasAccessibilityPermission(prompt: Bool) -> Bool
    func performPaste(text: String) -> Bool
}

final class TestClipboardWriter: ClipboardWriting {
    private(set) var lastWrittenText: String = ""

    func write(text: String) {
        lastWrittenText = text
    }
}

final class TestPasteService: PasteServicing {
    private(set) var lastPastedText: String?

    func hasAccessibilityPermission(prompt: Bool) -> Bool {
        true
    }

    func performPaste(text: String) -> Bool {
        lastPastedText = text
        return true
    }
}
