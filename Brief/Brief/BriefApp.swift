import SwiftUI

@main
struct BriefApp: App {
    init() {
        PrivacyWindowController.debug("BriefApp.init ran")   // TEST: filesystem-writable probe
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
                // TEST: auto-present the screen-edge Privacy panel ~1.2s after
                // the main window appears, so the slide-in is visible without
                // interaction. onAppear is reliable (unlike the delegate path).
                // Remove once wiring is confirmed.
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        NSLog("[PrivacyPanel] onAppear test present")
                        PrivacyWindowController.shared.present()
                    }
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)   // no title text in the bar; keep traffic lights

        // 2) Design System — the token / component reference.
        WindowGroup("Design System", id: "design-system") {
            DesignSystemView()
                .environmentObject(selection)
                .frame(minWidth: 1000, minHeight: 720)
        }
        .windowResizability(.contentSize)

        .commands {
            // Window ▸ Open menu items so each surface can be summoned
            // independently (⌘1 Live Context, ⌘2 Design System, ⌘, Privacy).
            CommandGroup(after: .windowList) {
                OpenWindowButtons()
            }
        }
    }
}

/// Menu buttons to open each named window on demand.
private struct OpenWindowButtons: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Button("Live Context") { openWindow(id: "live-context") }
            .keyboardShortcut("1", modifiers: .command)
        Button("Design System") { openWindow(id: "design-system") }
            .keyboardShortcut("2", modifiers: .command)
        // ⌘, slides the screen-edge Privacy panel in/out (claimed explicitly
        // since macOS would otherwise route ⌘, to Settings).
        Button("Privacy") { PrivacyWindowController.shared.toggle() }
            .keyboardShortcut(",", modifiers: .command)
    }
}
