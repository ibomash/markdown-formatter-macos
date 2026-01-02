import AppKit
import ApplicationServices

final class PasteService {
    func hasAccessibilityPermission(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func performPaste(text: String) -> Bool {
        if NSApp.sendAction(#selector(NSText.insertText(_:)), to: nil, from: text) {
            return true
        }
        return NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
    }
}
