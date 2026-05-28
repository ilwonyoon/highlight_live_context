import SwiftUI

// MARK: - Motion presets
// Named Animation values composed from BriefDuration. Always prefer these
// over inline `.easeOut(duration: ...)` so motion stays consistent.

extension Animation {
    /// 0.08s ease-out — micro feedback for press / instant flash.
    static let briefInstant: Animation = .easeOut(duration: BriefDuration.instant)
    /// 0.12s ease-out — most hover transitions (background / color / opacity).
    static let briefHover: Animation = .easeOut(duration: BriefDuration.quick)
    /// 0.16s ease-out — standard UI transition.
    static let briefStandard: Animation = .easeOut(duration: BriefDuration.standard)
    /// 0.25s ease-in-out — slower reveal / dismiss.
    static let briefSlow: Animation = .easeInOut(duration: BriefDuration.slow)
    /// Snappy spring for tactile interactions (popover present, card lift).
    static let briefSpring: Animation = .spring(response: 0.30, dampingFraction: 0.80)
}
