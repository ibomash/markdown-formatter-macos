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

            Divider()

            Text("Rebase")
                .font(.caption)
                .foregroundStyle(.secondary)

            Menu("Copy") {
                ForEach(1...6, id: \.self) { level in
                    Button("H\(level)") {
                        model.copyRebased(to: level)
                    }
                }
            }

            Menu("Paste") {
                ForEach(1...6, id: \.self) { level in
                    Button("H\(level)") {
                        model.pasteRebased(to: level)
                    }
                }
            }

            Divider()

            Button("Open Palette") {
                openWindow(id: "palette")
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding(.vertical, 4)
    }
}
