import AppKit
import SwiftUI

// MARK: - PrivacyWindowController
//
// Presents `PrivacyPanel` as a borderless panel that slides IN from the right
// EDGE OF THE SCREEN and slides back out to dismiss (Ilwon's "B": the panel
// enters from outside the right edge of the display, not from inside a window).
//
// SwiftUI's WindowGroup can't position a window off-screen or animate its frame,
// so the panel is a hand-rolled AppKit NSPanel:
//   • parked just past the screen's right edge (x = visibleFrame.maxX)
//   • setFrame(animate:) slides it left to its on-screen rest position
//   • dismissal reverses the slide, then orders the window out
//
// The window is non-activating and floats above other apps (like a system
// utility panel). Content is a plain NSHostingView — PrivacyPanel has no
// environment dependencies, so nothing else needs wiring.

@MainActor
final class PrivacyWindowController {

    /// Shared instance — a stable owner for the NSPanel that any call site
    /// (menu command, test hook) can reach without threading a reference
    /// through SwiftUI's view/scene graph.
    static let shared = PrivacyWindowController()

    /// Panel width — matches the in-window slide-over spec.
    private let panelWidth: CGFloat = 400
    /// Inset from the screen's right edge / top / bottom when resting on-screen.
    private let edgeInset: CGFloat = 12

    private var panel: NSPanel?
    private var isPresented = false

    /// The shared conversation — the chat panel renders it; the input window
    /// (added next) mutates it. One session so both surfaces stay in sync.
    private let session = ChatPanelSession(scenario: PrivacyScenario())

    // Event monitors for light-dismiss: Esc (local key) and a click outside the
    // panel (global mouse + local for clicks landing in our own other windows).
    private var keyMonitor: Any?
    private var globalClickMonitor: Any?
    private var localClickMonitor: Any?

    // MARK: Toggle / present / dismiss

    func toggle() {
        NSLog("[PrivacyPanel] toggle() — isPresented=\(isPresented)")
        if isPresented { dismiss() } else { present() }
    }

    func present() {
        Self.debug("present() called; isPresented=\(isPresented)")
        guard !isPresented else { Self.debug("already presented, bail"); return }
        let panel = panel ?? makePanel()
        self.panel = panel

        guard let screen = targetScreen() else { Self.debug("NO SCREEN"); return }
        let rest = restFrame(on: screen)
        let offscreen = offscreenFrame(on: screen)
        Self.debug("visibleFrame=\(NSStringFromRect(screen.visibleFrame)) rest=\(NSStringFromRect(rest)) offscreen=\(NSStringFromRect(offscreen))")

        // Start fully off the right edge, order on screen, then slide left.
        // NSWindow's native animated setFrame is reliable for borderless panels
        // (the `.animator()` proxy inside NSAnimationContext does NOT move a
        // non-activating borderless panel — it stayed parked off-screen).
        panel.setFrame(offscreen, display: false)
        panel.alphaValue = 1
        panel.orderFrontRegardless()
        panel.setFrame(rest, display: true, animate: true)

        Self.debug("after setFrame animate; isVisible=\(panel.isVisible) frame=\(NSStringFromRect(panel.frame))")
        isPresented = true
        installDismissMonitors()
    }

    // MARK: Light-dismiss — Esc + click-outside

    private func installDismissMonitors() {
        // Esc closes the panel.
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {   // Esc
                self?.dismiss()
                return nil             // swallow it
            }
            return event
        }
        // A click anywhere outside the panel closes it. Global catches other
        // apps; local catches our own windows (and lets the event through).
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.dismiss()
        }
        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let panel = self.panel else { return event }
            // If the click is NOT in our panel, dismiss; otherwise leave it be.
            if event.window != panel {
                self.dismiss()
            }
            return event
        }
    }

    private func removeDismissMonitors() {
        [keyMonitor, globalClickMonitor, localClickMonitor].forEach { m in
            if let m { NSEvent.removeMonitor(m) }
        }
        keyMonitor = nil
        globalClickMonitor = nil
        localClickMonitor = nil
    }

    /// File-based debug log — the unified log / NSLog isn't captured in this
    /// run context, so we append to a temp file we can read back. Test-only.
    static func debug(_ msg: String) {
        let line = "[PrivacyPanel] \(msg)\n"
        let url = URL(fileURLWithPath: "/tmp/privacy-debug.txt")
        if let data = line.data(using: .utf8) {
            if let h = try? FileHandle(forWritingTo: url) {
                h.seekToEndOfFile(); h.write(data); try? h.close()
            } else {
                try? data.write(to: url)
            }
        }
    }

    func dismiss() {
        guard isPresented, let panel else { return }
        removeDismissMonitors()
        guard let screen = targetScreen() else { panel.orderOut(nil); isPresented = false; return }
        let offscreen = offscreenFrame(on: screen)

        // Native animated setFrame (same reason as present()), then order out
        // after the slide completes.
        panel.setFrame(offscreen, display: true, animate: true)
        panel.orderOut(nil)
        isPresented = false
    }

    // MARK: Window construction

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: 760),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear          // the panel content draws its own surface
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // The floating panel hosts the general AI ChatPanel (header + back, a
        // streamed thread) driven by a shared ChatSession with the privacy
        // scenario. The composer lives in a SEPARATE input window (added next),
        // which shares this same session.
        let host = NSHostingView(rootView: ChatPanel(session: session))
        host.frame = panel.contentView?.bounds ?? .zero
        host.autoresizingMask = [.width, .height]
        panel.contentView = host
        return panel
    }

    // MARK: Frame math

    /// Prefer the screen with the key window / mouse; fall back to main.
    private func targetScreen() -> NSScreen? {
        NSApp.keyWindow?.screen ?? NSScreen.main ?? NSScreen.screens.first
    }

    /// Resting frame: flush to the right edge (minus inset), full usable height.
    private func restFrame(on screen: NSScreen) -> NSRect {
        let vf = screen.visibleFrame
        let height = vf.height - edgeInset * 2
        let x = vf.maxX - panelWidth - edgeInset
        let y = vf.minY + edgeInset
        return NSRect(x: x, y: y, width: panelWidth, height: height)
    }

    /// Off-screen frame: same y/height, pushed fully past the right edge.
    private func offscreenFrame(on screen: NSScreen) -> NSRect {
        var f = restFrame(on: screen)
        f.origin.x = screen.frame.maxX + edgeInset   // entirely beyond the edge
        return f
    }
}
