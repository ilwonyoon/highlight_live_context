import Foundation

// MARK: - Animation duration scale
// Named timing tokens to keep motion consistent across interactions.

enum BriefDuration {
    /// 0.08s — micro feedback (pressed state, instant flash)
    static let instant: Double = 0.08
    /// 0.12s — short hover transitions
    static let quick:   Double = 0.12
    /// 0.16s — standard UI transition (default for most state changes)
    static let standard: Double = 0.16
    /// 0.25s — section reveal, page transition
    static let slow:    Double = 0.25
    /// 0.40s — emphasized motion (modal in/out)
    static let emphatic: Double = 0.40
    /// 0.40s — panel slide-IN; a full-height slide-over wants a touch of mass.
    static let panelIn:  Double = 0.40
    /// 0.20s — panel slide-OUT; dismissal is quicker (asymmetric-motion rule).
    static let panelOut: Double = 0.20
}

// MARK: - Interaction delays
// Time the system waits before committing to a hover-driven action.
// Tuned to feel snappy without firing on accidental cursor passes.

enum BriefDelay {
    /// 0.0s — immediate (no debounce)
    static let none:    Double = 0.0
    /// 0.25s — hover-to-trigger threshold for popovers / previews
    static let hoverOn: Double = 0.25
    /// 0.30s — grace period after hover ends, lets cursor cross into popover
    static let hoverOff: Double = 0.30
    /// 0.50s — long-press / dwell for emphasized actions
    static let longPress: Double = 0.50
}
