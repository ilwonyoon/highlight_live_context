import CoreGraphics

// MARK: - Component sizing
// Sizes and dimensions for named app components. Anywhere you see a hardcoded
// frame width or icon size, replace it with one of these.

enum BriefLayout {

    /// Max width for the reading column (the Brief document body). Caps line
    /// length so prose stays readable on wide windows — the single biggest
    /// readability lever (Notion/Stripe-docs style). ~78–88 chars at 14pt.
    static let readingWidth: CGFloat = 700

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
        static let underlineOffset: CGFloat = 0   // hug the text — was 2pt, too gappy
        static let underlineThickness: CGFloat = 0.5
    }

    /// Card sizing for register blocks, source cards, etc.
    enum Card {
        static let inset: CGFloat = BriefSpacing.xxl
        static let cornerRadius: CGFloat = BriefRadius.card
        static let strokeWidth: CGFloat = 0.5
    }

    /// The minimal chat composer that appears beside a selected block.
    enum Composer {
        static let width: CGFloat = 280
        static let inset: CGFloat = BriefSpacing.xxl     // 20pt — room to breathe
        static let cornerRadius: CGFloat = BriefRadius.card
    }

    /// Selection-capsule rhythm for document lines. `linePad` is each capsule's
    /// top/bottom padding (so the highlight isn't a thin band); `lineGap` is the
    /// space between stacked lines — so two capsules sit exactly `lineGap` apart.
    enum Selection {
        static let linePad: CGFloat = BriefSpacing.xs    // 4pt
        static let lineGap: CGFloat = BriefSpacing.xs    // 4pt
    }
}
