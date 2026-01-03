import AppKit
import ApplicationServices

final class PasteService: PasteServicing {
    func hasAccessibilityPermission(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func performPaste(text: String) -> Bool {
        let vKey: CGKeyCode = 0x09
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
            return false
        }

        guard let keyDown = CGEvent(keyboardEventSource: eventSource, virtualKey: vKey, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: eventSource, virtualKey: vKey, keyDown: false)
        else {
            return false
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
        return true
    }
}
