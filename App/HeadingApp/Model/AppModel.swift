import AppKit
import Combine
import Foundation
import HeadingCore

final class AppModel: ObservableObject {
    @Published private(set) var summary: HeadingInspectSummary
    @Published var baseLevel: Int

    let clipboardMonitor: ClipboardMonitor
    private var cancellable: AnyCancellable?

    init(clipboardMonitor: ClipboardMonitor = ClipboardMonitor(), baseLevel: Int = 2) {
        self.clipboardMonitor = clipboardMonitor
        self.baseLevel = baseLevel
        self.summary = inspectHeadings(in: clipboardMonitor.latestText)

        cancellable = clipboardMonitor.$latestText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.summary = inspectHeadings(in: text)
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

    func rebaseClipboard(to level: Int) {
        baseLevel = level
        let output = rebaseHeadings(in: clipboardMonitor.latestText, toBaseLevel: level)
        guard !output.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)
    }
}
