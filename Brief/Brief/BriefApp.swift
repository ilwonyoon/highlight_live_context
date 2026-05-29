import SwiftUI
import AppKit

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
                .background(WindowConfigurator())   // make the host window non-opaque for sidebar glass
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}

// MARK: - WindowConfigurator
// Reaches the host NSWindow and makes it non-opaque with a clear background,
// so the sidebar's .behindWindow glass can sample the desktop behind it.
// Without this the window paints an opaque backing and the glass reads flat.

private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.isOpaque = false
            window.backgroundColor = .clear
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
