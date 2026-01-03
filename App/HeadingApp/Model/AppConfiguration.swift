import Foundation

struct AppConfiguration: Equatable {
    let uiTestMode: Bool
    let paletteAlwaysVisible: Bool
    let disableClipboardPolling: Bool
    let disableAutoDismiss: Bool
    let fixtureClipboardPath: String?
    let fixtureClipboardText: String?

    static func current() -> AppConfiguration {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments
        let uiTestMode = boolValue(for: "UI_TEST_MODE", in: env) || args.contains("--ui-test")
        let paletteAlwaysVisible = boolValue(for: "PALETTE_ALWAYS_VISIBLE", in: env)
        let disableClipboardPolling = boolValue(for: "DISABLE_CLIPBOARD_POLLING", in: env)
        let disableAutoDismiss = boolValue(for: "DISABLE_AUTO_DISMISS", in: env)
        let fixtureClipboardPath = env["FIXTURE_CLIPBOARD_PATH"]
        let fixtureClipboardText = env["FIXTURE_CLIPBOARD_TEXT"]

        return AppConfiguration(
            uiTestMode: uiTestMode,
            paletteAlwaysVisible: paletteAlwaysVisible,
            disableClipboardPolling: disableClipboardPolling,
            disableAutoDismiss: disableAutoDismiss,
            fixtureClipboardPath: fixtureClipboardPath,
            fixtureClipboardText: fixtureClipboardText
        )
    }

    func resolvedFixtureText() -> String? {
        if let path = fixtureClipboardPath, !path.isEmpty {
            if let data = FileManager.default.contents(atPath: path),
               let text = String(data: data, encoding: .utf8) {
                return text
            }
        }
        if let text = fixtureClipboardText, !text.isEmpty {
            return text
        }
        return nil
    }

    private static func boolValue(for key: String, in env: [String: String]) -> Bool {
        guard let raw = env[key]?.lowercased() else { return false }
        return raw == "1" || raw == "true" || raw == "yes"
    }
}
