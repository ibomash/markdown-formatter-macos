import AppKit
import Combine
import Foundation
import HeadingCore

final class AppModel: ObservableObject {
    @Published private(set) var summary: HeadingInspectSummary
    @Published var baseLevel: Int
    @Published var statusMessage: String?

    let clipboardMonitor: ClipboardMonitor
    private var cancellable: AnyCancellable?
    private let pasteService = PasteService()

    init(clipboardMonitor: ClipboardMonitor = ClipboardMonitor(), baseLevel: Int = 2) {
        self.clipboardMonitor = clipboardMonitor
        self.baseLevel = baseLevel
        self.summary = inspectHeadings(in: clipboardMonitor.latestText)

        cancellable = clipboardMonitor.$latestText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.summary = inspectHeadings(in: text)
                self?.statusMessage = nil
            }
    }

    var headingCounts: [Int] {
        var counts = Array(repeating: 0, count: 6)
        for heading in summary.headings {
            guard (1...6).contains(heading.level) else { continue }
            counts[heading.level - 1] += 1
        }
        return counts
    }

    func copyRebased(to level: Int) {
        baseLevel = level
        let output = rebaseHeadings(in: clipboardMonitor.latestText, toBaseLevel: level)
        guard !output.isEmpty else {
            statusMessage = "No markdown to copy."
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)
        statusMessage = "Copied rebased markdown."
    }

    func pasteRebased(to level: Int) {
        baseLevel = level
        let output = rebaseHeadings(in: clipboardMonitor.latestText, toBaseLevel: level)
        guard !output.isEmpty else {
            statusMessage = "No markdown to paste."
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)

        guard pasteService.hasAccessibilityPermission(prompt: true) else {
            statusMessage = "Enable Accessibility permission to paste."
            return
        }

        let success = pasteService.performPaste(text: output)
        statusMessage = success ? "Pasted into the frontmost app." : "Paste failed. Try manual paste."
    }
}
