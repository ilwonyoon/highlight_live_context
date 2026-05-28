import CoreGraphics

// MARK: - Corner radius scale
// Three named radii cover everything in the app.
// Inline objects (citation pills) use `inline`, cards use `card`, popovers
// use `panel`. Don't introduce new values without a strong reason.

enum BriefRadius {
    /// 2pt — hairline rounding for inline marks that should still feel rectangular.
    static let inline: CGFloat = 2
    /// 8pt — default for citation backgrounds, chips, small badges.
    static let chip:   CGFloat = 8
    /// 10pt — cards, register blocks, popover content frames.
    static let card:   CGFloat = 10
    /// 14pt — panel surfaces (Brief windows, large modals).
    static let panel:  CGFloat = 14
}
