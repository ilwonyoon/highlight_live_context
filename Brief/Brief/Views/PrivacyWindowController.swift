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
    /// Height of the SEPARATE input window below the conversation.
    private let inputHeight: CGFloat = 92
    /// Gap between the conversation panel and the input window.
    private let stackGap: CGFloat = 10

    private var panel: NSPanel?        // conversation (header + thread)
    private var inputPanel: NSPanel?   // composer — a separate window below
    private var isPresented = false

    /// The shared conversation — both windows observe/mutate this one session.
    /// Seeded with a default store; call configure(store:) to wire the real one.
    private var session = ChatPanelSession(scenario: PrivacyScenario())

    /// The real store, captured at configure(); used to rebuild the scenario when
    /// the panel is opened from a different entry point.
    private var store: PrivacyStore?
    /// Which entry the cached session/panels were built for. Opening from a
    /// different entry rebuilds them with a freshly tailored scenario.
    private var currentEntry: PrivacyChatEntry = .global

    /// Wire the shared PrivacyStore so chat edits and settings UI stay in sync.
    /// Call once from LiveContextView.onAppear before the panel is first opened.
    func configure(store: PrivacyStore) {
        // Only rebuild if the panel hasn't been presented yet
        guard !isPresented else { return }
        self.store = store
        rebuildSession(entry: .global)
    }

    /// Rebuild the shared session (and drop cached panels) for a given entry, so
    /// the opening turns + composer placeholder match where chat was opened from.
    private func rebuildSession(entry: PrivacyChatEntry) {
        currentEntry = entry
        let store = store ?? PrivacyStore()
        session = ChatPanelSession(scenario: PrivacyScenario(store: store, entry: entry))
        // Reset cached panels so they're rebuilt with the new session on next present()
        panel = nil
        inputPanel = nil
    }

    // Event monitors for light-dismiss: Esc (local key) and a click outside the
    // panel (global mouse + local for clicks landing in our own other windows).
    private var keyMonitor: Any?
    private var globalClickMonitor: Any?
    private var localClickMonitor: Any?

    // MARK: Toggle / present / dismiss

    func toggle() {
        NSLog("[PrivacyPanel] toggle() — isPresented=\(isPresented)")
        if isPresented { dismiss() } else { present(entry: .global) }
    }

    /// Open the panel, tailored to the entry point it was launched from. If a
    /// different entry than the cached one is requested, the session is rebuilt
    /// so the opening brief + placeholder match.
    func present(entry: PrivacyChatEntry = .global) {
        guard !isPresented else { return }
        if entry != currentEntry || panel == nil {
            rebuildSession(entry: entry)
        }
        let panel = panel ?? makeConversationPanel()
        self.panel = panel
        let inputPanel = inputPanel ?? makeInputPanel()
        self.inputPanel = inputPanel

        guard let screen = targetScreen() else { return }
        let rest = restFrame(on: screen)
        let inputRest = inputRestFrame(on: screen)

        // Both windows start off the right edge, order on, then slide left
        // together. Native animated setFrame is reliable for borderless panels.
        panel.setFrame(offscreen(rest, on: screen), display: false)
        inputPanel.setFrame(offscreen(inputRest, on: screen), display: false)
        panel.alphaValue = 1
        inputPanel.alphaValue = 1
        panel.orderFrontRegardless()
        inputPanel.orderFrontRegardless()
        panel.setFrame(rest, display: true, animate: true)
        inputPanel.setFrame(inputRest, display: true, animate: true)
        // Give the composer keyboard focus.
        inputPanel.makeKey()

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
            guard let self else { return event }
            // Clicks in EITHER of our windows are "inside"; anything else closes.
            let inside = event.window === self.panel || event.window === self.inputPanel
            if !inside { self.dismiss() }
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
        isPresented = false
        guard let screen = targetScreen() else {
            panel.orderOut(nil); inputPanel?.orderOut(nil); return
        }
        // Slide both windows back off the right edge, then order out.
        panel.setFrame(offscreen(panel.frame, on: screen), display: true, animate: true)
        if let inputPanel {
            inputPanel.setFrame(offscreen(inputPanel.frame, on: screen), display: true, animate: true)
            inputPanel.orderOut(nil)
        }
        panel.orderOut(nil)
    }

    // MARK: Window construction

    /// The conversation window — header + thread. Non-activating (it shouldn't
    /// steal key focus from the input window).
    private func makeConversationPanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: 760),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        configureCommon(panel)

        // The floating panel hosts the general AI ChatPanel (header + thread),
        // driven by the shared session. The composer is a SEPARATE input window.
        let host = NSHostingView(rootView: ChatPanel(session: session))
        host.frame = panel.contentView?.bounds ?? .zero
        host.autoresizingMask = [.width, .height]
        panel.contentView = host
        return panel
    }

    /// The input window — a KeyablePanel (can take keyboard focus) hosting the
    /// composer, sharing the same session so sends land in the conversation.
    private func makeInputPanel() -> NSPanel {
        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: inputHeight),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        configureCommon(panel)

        let composer = ComposerHost(session: session)
        let host = NSHostingView(rootView: composer)
        host.frame = panel.contentView?.bounds ?? .zero
        host.autoresizingMask = [.width, .height]
        panel.contentView = host
        return panel
    }

    /// Shared NSPanel chrome for both windows.
    private func configureCommon(_ panel: NSPanel) {
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear          // content draws its own surface
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    // MARK: Frame math

    /// Prefer the screen with the key window / mouse; fall back to main.
    private func targetScreen() -> NSScreen? {
        NSApp.keyWindow?.screen ?? NSScreen.main ?? NSScreen.screens.first
    }

    /// Resting frame for the CONVERSATION panel: right edge, full height minus
    /// the input window + gap below it.
    private func restFrame(on screen: NSScreen) -> NSRect {
        let vf = screen.visibleFrame
        let x = vf.maxX - panelWidth - edgeInset
        let bottom = vf.minY + edgeInset
        let inputTop = bottom + inputHeight + stackGap
        let height = vf.maxY - edgeInset - inputTop
        return NSRect(x: x, y: inputTop, width: panelWidth, height: height)
    }

    /// Resting frame for the INPUT window: right edge, parked at the bottom.
    private func inputRestFrame(on screen: NSScreen) -> NSRect {
        let vf = screen.visibleFrame
        let x = vf.maxX - panelWidth - edgeInset
        let y = vf.minY + edgeInset
        return NSRect(x: x, y: y, width: panelWidth, height: inputHeight)
    }

    /// Off-screen variant: same y/height, pushed fully past the right edge.
    private func offscreen(_ frame: NSRect, on screen: NSScreen) -> NSRect {
        var f = frame
        f.origin.x = screen.frame.maxX + edgeInset
        return f
    }
}

// MARK: - KeyablePanel — a borderless panel that can become key
//
// The input window holds a TextField, so it must accept first-responder/key
// status. A plain borderless NSPanel returns false for canBecomeKey; this
// override lets the composer take keyboard focus without a title bar.

final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
