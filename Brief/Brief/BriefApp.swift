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
        // Live Context panel — primary window on the live-context-panel branch.
        // (DesignSystemView remains available; swap the view below to see it.)
        WindowGroup("Live Context") {
            LiveContextView()
                .environmentObject(selection)
                .frame(minWidth: 1000, minHeight: 720)
        }
        .windowResizability(.contentSize)
    }
}
