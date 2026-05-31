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

// MARK: - LiquidGlassView
// The REAL macOS 26 Liquid Glass material (AppKit's NSGlassEffectView).
// SwiftUI's `.glassEffect()` modifier is absent from this SDK, but the
// AppKit class is present — so we bridge it. Used as a background layer
// (no contentView), optionally tinted to keep it in our warm family.
//
// `available(macOS 26.0)` — caller gates with #available and falls back to
// VisualEffectView on older systems.

//
// SDK GUARD: `NSGlassEffectView` only exists in the macOS 26 SDK. Built against an
// older SDK (Xcode 16 / macOS 15) the type is absent, so we fall back to
// `NSVisualEffectView`. `canImport(FoundationModels)` is a proxy for "compiling
// against the 26 SDK" (FoundationModels ships in 26+). Build with the 26 SDK and
// the original glass implementation is used automatically — nothing to revert.

#if canImport(FoundationModels)

@available(macOS 26.0, *)
struct LiquidGlassView: NSViewRepresentable {
    var cornerRadius: CGFloat = 0
    var tint: NSColor? = nil
    var clear: Bool = false

    func makeNSView(context: Context) -> NSGlassEffectView {
        let view = NSGlassEffectView()
        view.cornerRadius = cornerRadius
        view.tintColor = tint
        view.style = clear ? .clear : .regular
        return view
    }

    func updateNSView(_ view: NSGlassEffectView, context: Context) {
        view.cornerRadius = cornerRadius
        view.tintColor = tint
        view.style = clear ? .clear : .regular
    }
}

#else

// Older-SDK fallback — same API surface, backed by the closest pre-Tahoe material
// so callers still compile and run.
@available(macOS 26.0, *)
struct LiquidGlassView: NSViewRepresentable {
    var cornerRadius: CGFloat = 0
    var tint: NSColor? = nil
    var clear: Bool = false

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

#endif
