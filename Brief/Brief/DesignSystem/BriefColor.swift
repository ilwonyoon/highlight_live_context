import SwiftUI

// MARK: - Color tokens
// Foundation: warm paper background, ink-warm grays for text.
// Accent: highlighter-trace (semantic only — appears where AI has marked
// something as mattering to the user; never decorative).
// Per project_brand_color_strategy.md.

extension Color {

    // Surface — warm-yellow off-whites. Three tones, differing only slightly
    // (the "same paper under slightly different light" effect). Yellow-warm
    // (B is the lowest channel) keeps them in the E7FE0B highlight family.
    //
    // Reading-first hierarchy: the CONTENT surface is the brightest (you read
    // there). The sidebar/nav sits one step down. Cards/recesses go lower still.
    static let briefPaper       = Color(red: 0.996, green: 0.992, blue: 0.973) // FEFDF8 — content (brightest, reading surface)
    static let briefPaperRaised = Color(red: 1.000, green: 0.998, blue: 0.984) // FFFFFB — cards lifted above content
    static let briefPaperSunken = Color(red: 0.969, green: 0.961, blue: 0.937) // F7F5EF — recessed areas
    /// Sidebar / nav surface — one step down from content so reading stays brightest.
    static let briefPaperNav    = Color(red: 0.980, green: 0.973, blue: 0.945) // FAF8F1

    // Ink (text)
    static let briefInkPrimary   = Color(red: 0.137, green: 0.118, blue: 0.090) // near-black, warm
    static let briefInkSecondary = Color(red: 0.420, green: 0.392, blue: 0.353) // mid-warm-gray
    static let briefInkTertiary  = Color(red: 0.620, green: 0.588, blue: 0.541) // light-warm-gray
    static let briefInkDisabled  = Color(red: 0.788, green: 0.761, blue: 0.722)
    /// Body/value text in the Live Context document — neutral grayscale 25%
    /// (#404040), Ilwon's dialed-in pick. Sits between primary and secondary;
    /// the lead-in label uses inkPrimary so color (not weight) carries hierarchy.
    static let briefInkBody      = Color(white: 0.25) // #404040 — the standard body ink

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

    /// App accent — the brand highlight E7FE0B. Drives system selection
    /// (sidebar rows, controls). NOTE: as a selection fill this needs DARK
    /// text on top (highlightInk), since white on fluorescent yellow is
    /// unreadable — handle at the row level if macOS forces white.
    static let briefAccent          = Color(red: 0.906, green: 0.996, blue: 0.043) // == highlight E7FE0B

    // Borders / dividers
    static let briefDivider  = Color(red: 0.890, green: 0.875, blue: 0.847)
    static let briefHairline = Color(red: 0.831, green: 0.812, blue: 0.776)
    // Whisper border for card/callout edges — only a few % off the paper, so
    // the surface reads by its fill, not a drawn line (Notion/Stripe do this;
    // a higher-contrast border reads as a "form box," not a premium surface).
    static let briefHairlineSoft = Color(red: 0.925, green: 0.914, blue: 0.890) // ~ECE9E3

    // Selection background — warm gray tuned to the paper foundation.
    // Used for selected rows and macOS-style multi-select highlighting,
    // so we don't repurpose the highlighter brand color for selection.
    static let briefSelectionRest  = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.06)
    static let briefSelectionHover = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.10)
    /// Stronger warm-gray fill for a *committed* nav selection (sidebar row).
    static let briefSelectionActive = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.13)

    // Scrim — dims the window behind a slide-in panel so the panel reads as
    // floating *over* the surface, not part of it. Warm ink, not pure black.
    static let briefScrim = Color(red: 0.137, green: 0.118, blue: 0.090).opacity(0.18)

    // Inverted surface — for a solid dark CTA (black-bg / light-text), the
    // primary-action button convention in chat. `briefSurfaceDark` is the fill
    // (warm near-black = briefInkPrimary, named for intent); `briefInkInverse`
    // is the paper-white text that sits on it. Formalizes the ad-hoc
    // inkPrimary + raw `.white` pairing used by PrivacyChip.
    static let briefSurfaceDark = Color(red: 0.137, green: 0.118, blue: 0.090) // == inkPrimary, as a fill
    static let briefInkInverse  = Color(red: 0.992, green: 0.988, blue: 0.976) // warm paper-white on dark
}
