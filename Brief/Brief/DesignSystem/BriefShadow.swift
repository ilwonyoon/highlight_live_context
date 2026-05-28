import SwiftUI

// MARK: - Shadow presets
// Three elevation levels. Always combine with a `compositingGroup()` when
// applied to a multi-layer view so the shadow doesn't bleed.

enum BriefShadow {
    /// Subtle surface lift — cards, sections.
    static let raised = ShadowSpec(
        color: .black.opacity(0.06),
        radius: 4, x: 0, y: 1
    )
    /// Floating elements — popovers, dropdowns.
    static let floating = ShadowSpec(
        color: .black.opacity(0.14),
        radius: 18, x: 0, y: 8
    )
    /// Modal surface — dialogs, full-screen sheets.
    static let modal = ShadowSpec(
        color: .black.opacity(0.20),
        radius: 32, x: 0, y: 14
    )
}

struct ShadowSpec {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    /// Apply a named Brief shadow preset.
    func briefShadow(_ spec: ShadowSpec) -> some View {
        self.shadow(color: spec.color, radius: spec.radius, x: spec.x, y: spec.y)
    }
}
