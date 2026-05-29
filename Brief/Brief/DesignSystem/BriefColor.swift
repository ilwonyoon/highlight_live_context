import SwiftUI

// MARK: - Color tokens
// Foundation: warm paper background, ink-warm grays for text.
// Accent: highlighter-trace (semantic only — appears where AI has marked
// something as mattering to the user; never decorative).
// Per project_brand_color_strategy.md.

extension Color {

    // Surface
    static let briefPaper       = Color(red: 0.984, green: 0.976, blue: 0.965) // F1ECEC / warm off-white
    static let briefPaperRaised = Color(red: 1.000, green: 0.996, blue: 0.988) // raised card surface
    static let briefPaperSunken = Color(red: 0.965, green: 0.957, blue: 0.945) // recessed area

    // Ink (text)
    static let briefInkPrimary   = Color(red: 0.137, green: 0.118, blue: 0.090) // near-black, warm
    static let briefInkSecondary = Color(red: 0.420, green: 0.392, blue: 0.353) // mid-warm-gray
    static let briefInkTertiary  = Color(red: 0.620, green: 0.588, blue: 0.541) // light-warm-gray
    static let briefInkDisabled  = Color(red: 0.788, green: 0.761, blue: 0.722)

    // Highlighter trace — E7FE0B (brighter, true-highlighter chroma).
    // Per scope: leverage brand color on positive action / productive moments.
    // Used ONLY for: AI-marked-as-mattering, intent statement, user pin/flag,
    // positive action affordances.
    static let briefHighlight       = Color(red: 0.906, green: 0.996, blue: 0.043) // E7FE0B
    static let briefHighlightSoft   = Color(red: 0.906, green: 0.996, blue: 0.043).opacity(0.45)
    /// Soft pale-yellow wash used as the hover background behind inline
    /// provenance phrases. Lighter and warmer than briefHighlightSoft so it
    /// recedes on paper while still reading as "highlighted by your AI."
    static let briefHighlightWash   = Color(red: 0.984, green: 1.000, blue: 0.804) // FBFFCD
    static let briefHighlightInk    = Color(red: 0.176, green: 0.196, blue: 0.020) // deep olive ink for text on highlight
    /// Darker but still chromatically yellow-green version of the brand highlight.
    /// Used for the voice/audio icon at rest so it carries Highlight's brand
    /// identity without being too bright on warm paper.
    static let briefHighlightDeep   = Color(red: 0.439, green: 0.859, blue: 0.016) // #70DB04 chartreuse

    // Borders / dividers
    static let briefDivider  = Color(red: 0.890, green: 0.875, blue: 0.847)
    static let briefHairline = Color(red: 0.831, green: 0.812, blue: 0.776)

    // Selection background — warm gray tuned to the paper foundation.
    // Used for selected rows and macOS-style multi-select highlighting,
    // so we don't repurpose the highlighter brand color for selection.
    static let briefSelectionRest  = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.06)
    static let briefSelectionHover = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.10)
    /// Stronger warm-gray fill for a *committed* nav selection (sidebar row).
    static let briefSelectionActive = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.13)
}
