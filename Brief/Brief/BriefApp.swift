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
        // Two independent windows so each surface can be worked on / reviewed
        // separately. Both open at launch; close whichever you don't need.

        // 1) Live Context — the product surface.
        WindowGroup("Live Context", id: "live-context") {
            LiveContextView()
                .environmentObject(selection)
                .frame(minWidth: 1000, minHeight: 720)
        }
        .windowResizability(.contentSize)

        // 2) Design System — the token / component reference.
        WindowGroup("Design System", id: "design-system") {
            DesignSystemView()
                .environmentObject(selection)
                .frame(minWidth: 1000, minHeight: 720)
        }
        .windowResizability(.contentSize)
    }
}
