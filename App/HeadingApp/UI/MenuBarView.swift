import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    private var detectedLabel: String {
        if let minLevel = model.summary.minLevel, let maxLevel = model.summary.maxLevel {
            return "Detected: H\(minLevel) - H\(maxLevel)"
        }
        return "Detected: none"
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(detectedLabel)
                .accessibilityIdentifier("menu-detected-label")

            Divider()

            Text("Rebase")
                .font(.caption)
                .foregroundStyle(.secondary)

            Menu("Copy") {
                ForEach(1...6, id: \.self) { level in
                    Button("H\(level)") {
                        model.copyRebased(to: level)
                    }
                    .accessibilityIdentifier("menu-copy-level-\(level)")
                }
            }
            .accessibilityIdentifier("menu-copy")

            Menu("Paste") {
                ForEach(1...6, id: \.self) { level in
                    Button("H\(level)") {
                        model.pasteRebased(to: level)
                    }
                    .accessibilityIdentifier("menu-paste-level-\(level)")
                }
            }
            .accessibilityIdentifier("menu-paste")

            Divider()

            Button("Open Palette") {
                openWindow(id: "palette")
            }
            .accessibilityIdentifier("menu-open-palette")

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .accessibilityIdentifier("menu-quit")
        }
        .padding(.vertical, 4)
    }
}
