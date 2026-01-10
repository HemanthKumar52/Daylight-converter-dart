import SwiftUI

@main
struct DaylightApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .preferredColorScheme(settings.theme.colorScheme)
        }
    }
}
