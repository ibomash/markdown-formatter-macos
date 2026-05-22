import AppKit
import Combine
import Foundation
import HeadingCore

final class AppModel: ObservableObject {
    @Published private(set) var summary: HeadingInspectSummary
    @Published private(set) var clipboardText: String
    @Published var baseLevel: Int
    @Published var statusMessage: String?

    let clipboardMonitor: ClipboardMonitoring
    private let clipboardWriter: ClipboardWriting
    private let pasteService: PasteServicing
    private let configuration: AppConfiguration
    private var cancellable: AnyCancellable?

    init(
        configuration: AppConfiguration,
        clipboardMonitor: ClipboardMonitoring,
        clipboardWriter: ClipboardWriting,
        pasteService: PasteServicing,
        baseLevel: Int = 2
    ) {
        self.configuration = configuration
        self.clipboardMonitor = clipboardMonitor
        self.clipboardWriter = clipboardWriter
        self.pasteService = pasteService
        self.baseLevel = baseLevel
        self.clipboardText = clipboardMonitor.latestText
        self.summary = inspectHeadings(in: clipboardMonitor.latestText)

        cancellable = clipboardMonitor.latestTextPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.clipboardText = text
                self?.summary = inspectHeadings(in: text)
                self?.statusMessage = nil
            }
    }

    static func makeDefault(configuration: AppConfiguration) -> AppModel {
        let fixtureText = configuration.resolvedFixtureText() ?? ""
        let monitor: ClipboardMonitoring
        if configuration.uiTestMode || configuration.disableClipboardPolling {
            monitor = TestClipboardMonitor(initialText: fixtureText)
        } else {
            monitor = ClipboardMonitor(initialText: fixtureText.isEmpty ? nil : fixtureText)
        }

        let writer: ClipboardWriting = PasteboardWriter()
        let pasteService: PasteServicing = configuration.uiTestMode ? TestPasteService() : PasteService()

        return AppModel(
            configuration: configuration,
            clipboardMonitor: monitor,
            clipboardWriter: writer,
            pasteService: pasteService
        )
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
        let output = rebaseHeadings(in: clipboardText, toBaseLevel: level)
        guard !output.isEmpty else {
            statusMessage = "No markdown to copy."
            return
        }
        clipboardWriter.write(text: output)
        statusMessage = "Copied rebased markdown."
    }

    func pasteRebased(to level: Int) {
        baseLevel = level
        let output = rebaseHeadings(in: clipboardText, toBaseLevel: level)
        guard !output.isEmpty else {
            statusMessage = "No markdown to paste."
            return
        }
        clipboardWriter.write(text: output)

        let promptForPermission = !configuration.uiTestMode
        guard pasteService.hasAccessibilityPermission(prompt: promptForPermission) else {
            statusMessage = "Enable Accessibility permission to paste."
            return
        }

        let success = pasteService.performPaste(text: output)
        statusMessage = success ? "Pasted into the frontmost app." : "Paste failed. Try manual paste."
    }
}
