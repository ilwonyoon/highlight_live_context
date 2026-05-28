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

    var body: some Scene {
        WindowGroup {
            TypeSpecimenView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
