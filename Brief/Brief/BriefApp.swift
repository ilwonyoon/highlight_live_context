import SwiftUI

@main
struct BriefApp: App {
    init() {
        // Run `BRIEF_VERIFY_MOCKS=1 ./Brief` to self-check that the mock
        // Live Context decodes cleanly, then exit. No effect in normal use.
        #if DEBUG
        if ProcessInfo.processInfo.environment["BRIEF_VERIFY_MOCKS"] != nil {
            LiveContextStore.verifyAndExit()
        }
        #endif
    }

    @StateObject private var selection = SelectionContext()

    var body: some Scene {
        WindowGroup {
            DesignSystemView()
                .environmentObject(selection)
                .frame(minWidth: 1000, minHeight: 720)
                // App accent (sidebar selection, controls) comes from the
                // Asset Catalog AccentColor — SwiftUI sidebar selection ignores
                // .tint() and follows the global accent. See Assets.xcassets.
        }
        .windowResizability(.contentSize)
    }
}
