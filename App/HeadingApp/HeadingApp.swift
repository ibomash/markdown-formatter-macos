import SwiftUI

@main
struct HeadingApp: App {
    private let configuration: AppConfiguration
    @StateObject private var model: AppModel

    init() {
        let configuration = AppConfiguration.current()
        self.configuration = configuration
        _model = StateObject(wrappedValue: AppModel.makeDefault(configuration: configuration))
    }

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
