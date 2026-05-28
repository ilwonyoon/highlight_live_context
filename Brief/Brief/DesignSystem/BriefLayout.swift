import CoreGraphics

// MARK: - Component sizing
// Sizes and dimensions for named app components. Anywhere you see a hardcoded
// frame width or icon size, replace it with one of these.

enum BriefLayout {

    /// Inline icon sizes used inside body prose / provenance tags.
    enum InlineIcon {
        static let small:   CGFloat = 11
        static let regular: CGFloat = 12
        static let medium:  CGFloat = 14
    }

    /// Popover surface dimensions.
    enum Popover {
        static let width: CGFloat = 320
        static let inset: CGFloat = BriefSpacing.xxl     // 20pt
        static let cornerRadius: CGFloat = BriefRadius.card
    }

    /// Inline citation hit-target padding (kept constant so hover doesn't shift layout).
    enum InlineCitation {
        static let paddingH: CGFloat = BriefSpacing.xs   // 4pt
        static let paddingV: CGFloat = BriefSpacing.xxs - 1 // 1pt
        static let cornerRadius: CGFloat = BriefRadius.chip
        static let baselineNudge: CGFloat = -1
        static let underlineOffset: CGFloat = 2
        static let underlineThickness: CGFloat = 0.5
    }

    /// Card sizing for register blocks, source cards, etc.
    enum Card {
        static let inset: CGFloat = BriefSpacing.xxl
        static let cornerRadius: CGFloat = BriefRadius.card
        static let strokeWidth: CGFloat = 0.5
    }
}
