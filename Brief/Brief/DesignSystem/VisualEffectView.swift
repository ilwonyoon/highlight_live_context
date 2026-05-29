import SwiftUI
import AppKit

// MARK: - VisualEffectView
// Bridges NSVisualEffectView so SwiftUI can use real macOS materials —
// the system "liquid glass" that samples what's behind the window.
//
// We use `.sidebar` material + `.behindWindow` blending for the nav column,
// which is exactly the glass macOS gives native sidebars. Because our chrome
// is a custom HStack (not NavigationSplitView), we have to opt into it here.

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar
    var blending: NSVisualEffectView.BlendingMode = .behindWindow
    var emphasized: Bool = false

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blending
        view.state = .followsWindowActiveState
        view.isEmphasized = emphasized
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.material = material
        view.blendingMode = blending
        view.isEmphasized = emphasized
    }
}
