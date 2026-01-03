import AppKit

struct PasteboardWriter: ClipboardWriting {
    let pasteboard: NSPasteboard

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    func write(text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
