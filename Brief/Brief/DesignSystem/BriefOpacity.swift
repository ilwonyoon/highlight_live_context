import CoreGraphics

// MARK: - Opacity scale
// Named opacities cover three distinct uses:
//   1. Element states     (rest / hover / pressed / disabled / inactive)
//   2. Underline weights  (faint / soft / strong)
//   3. Overlay washes     (very-soft .. heavy)

enum BriefOpacity {
    // Element states (multiplicative on rest color)
    static let rest:      Double = 1.00
    static let hover:     Double = 1.00
    static let active:    Double = 0.90
    static let inactive:  Double = 0.75
    static let muted:     Double = 0.50
    static let disabled:  Double = 0.25

    // Underline / hairline strengths
    static let lineFaint:    Double = 0.35
    static let lineSoft:     Double = 0.50
    static let lineStandard: Double = 0.65
    static let lineStrong:   Double = 0.80

    // Translucent overlays
    static let washFaint:  Double = 0.08
    static let washSoft:   Double = 0.12
    static let washMedium: Double = 0.30
    static let washHeavy:  Double = 0.45
}
