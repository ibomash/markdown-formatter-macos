import SwiftUI

@main
struct HeadingApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra("Heading", systemImage: "textformat") {
            MenuBarView()
                .environmentObject(model)
        }

        Window("Heading Palette", id: "palette") {
            ContentView()
                .environmentObject(model)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
